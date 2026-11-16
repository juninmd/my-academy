import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/exceptions/failure.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../health_sync/health_sync_service.dart';
import '../../domain/entities/import_result_entity.dart';
import '../../domain/entities/weight_import_result_entity.dart';
import '../../domain/repositories/data_transfer_repository.dart';
import '../../../health_sync/presentation/providers/health_sync_provider.dart';
import '../providers/data_transfer_provider.dart';
import '../widgets/hevy_key_field.dart';

/// Backup, export, and import of workout history (CSV, backup JSON, Hevy Pro).
class DataTransferPage extends ConsumerStatefulWidget {
  const DataTransferPage({super.key});

  @override
  ConsumerState<DataTransferPage> createState() => _DataTransferPageState();
}

class _DataTransferPageState extends ConsumerState<DataTransferPage> {
  bool _busy = false;
  String? _message;

  DataTransferRepository get _repository =>
      ref.read(dataTransferRepositoryProvider);

  String? get _userId => ref.read(authProvider).value?.id;

  Future<void> _run(Future<void> Function(String userId) action) async {
    final userId = _userId;
    if (userId == null) {
      setState(() => _message = 'Entre na conta para continuar.');
      return;
    }
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await action(userId);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _exportJson() => _run((userId) async {
    final result = await _repository.exportJson(userId);
    await result.fold(
      (failure) async => _show(failure.message),
      (json) => SharePlus.instance.share(
        ShareParams(text: json, subject: 'My Academy backup'),
      ),
    );
  });

  Future<void> _exportCsv() => _run((userId) async {
    final result = await _repository.exportCsv(userId);
    await result.fold(
      (failure) async => _show(failure.message),
      (csv) => SharePlus.instance.share(
        ShareParams(text: csv, subject: 'My Academy sets'),
      ),
    );
  });

  Future<void> _importCsv() => _run((userId) async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: const ['csv'],
    );
    if (file == null) return;
    final csv = utf8.decode(await file.readAsBytes());
    final result = await _repository.importCsv(userId, csv);
    _showResult(result);
  });

  Future<void> _importJson() => _run((userId) async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: const ['json'],
    );
    if (file == null) return;
    final backup = jsonDecode(utf8.decode(await file.readAsBytes()));
    if (backup is! Map<String, dynamic>) {
      _show('Arquivo de backup inválido.');
      return;
    }
    _showResult(await _repository.importJson(userId, backup));
  });

  Future<void> _importWeight() => _run((userId) async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: const ['xml', 'csv'],
    );
    if (file == null) return;
    final text = utf8.decode(await file.readAsBytes());
    final result = await _repository.importBodyWeight(userId, text);
    result.fold(
      (failure) => _show(failure.message),
      (WeightImportResultEntity r) => _show(
        'Peso: ${r.imported} dias importados (${r.format}). '
        '${r.skippedExisting} já existiam. ${r.skippedRows} ignorados.',
      ),
    );
  });

  Future<void> _syncHealth() => _run((userId) async {
        final health = ref.read(healthSyncServiceProvider);
        final granted = await health.requestWeightAccess();
        if (!granted) {
          _show('Permita o acesso a peso no Health Connect.');
          return;
        }
        final weighIns = await health.readWeighIns();
        if (weighIns.isEmpty) {
          _show('Nenhum peso encontrado no Health Connect nos últimos 30 dias.');
          return;
        }
        final result = await _repository.importBodyWeight(
          userId,
          buildWeightCsv(weighIns),
        );
        result.fold(
          (failure) => _show(failure.message),
          (r) => _show(
            'Health Connect: ${r.imported} dias importados. '
            '${r.skippedExisting} já existiam.',
          ),
        );
      });

  Future<void> _importHevy(String apiKey) => _run((userId) async {
    _showResult(await _repository.importHevy(userId, apiKey));
  });

  void _show(String message) {
    if (mounted) setState(() => _message = message);
  }

  void _showResult(Either<Failure, ImportResultEntity> result) {
    result.fold(
      (failure) => _show(failure.message),
      (r) => _show(
        '${r.logs} treinos e ${r.sets} séries importados. '
        '${r.skippedExisting} dias já existiam. '
        '${r.skippedRows} linhas ignoradas.'
        '${r.unmatchedExercises.isEmpty ? '' : ' Sem correspondência: ${r.unmatchedExercises.join(', ')}.'}',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dados')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Exportar', style: Theme.of(context).textTheme.titleLarge),
          ListTile(
            leading: const Icon(Icons.save_alt),
            title: const Text('Backup completo (JSON)'),
            onTap: _busy ? null : _exportJson,
          ),
          ListTile(
            leading: const Icon(Icons.table_chart),
            title: const Text('Séries (CSV)'),
            onTap: _busy ? null : _exportCsv,
          ),
          const SizedBox(height: 24),
          Text('Importar', style: Theme.of(context).textTheme.titleLarge),
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text(
              'Planilha CSV (Strong, Hevy, FitNotes ou própria)',
            ),
            onTap: _busy ? null : _importCsv,
          ),
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('Backup JSON'),
            onTap: _busy ? null : _importJson,
          ),
          if (HealthSyncService.isSupported)
            ListTile(
              leading: const Icon(Icons.favorite_outline),
              title: const Text('Peso do Health Connect'),
              onTap: _busy ? null : _syncHealth,
            ),
          ListTile(
            leading: const Icon(Icons.monitor_weight),
            title: const Text('Peso: Apple Health (export.xml) ou CSV'),
            onTap: _busy ? null : _importWeight,
          ),
          HevyKeyField(enabled: !_busy, onSubmit: _importHevy),
          if (ref.watch(authProvider).value?.role == 'ADMIN') ...[
            const SizedBox(height: 24),
            Text('Administração', style: Theme.of(context).textTheme.titleLarge),
            ListTile(
              leading: const Icon(Icons.vpn_key),
              title: const Text('Convites de cadastro'),
              onTap: () => context.push('/admin/invites'),
            ),
          ],
          if (_busy) const LinearProgressIndicator(),
          if (_message != null) ...[
            const SizedBox(height: 16),
            Text(_message!),
          ],
        ],
      ),
    );
  }
}
