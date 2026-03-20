import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../domain/entities/workout_entity.dart';
import '../../domain/entities/workout_series_entity.dart';

class WorkoutEditSeriesDialog extends HookWidget {
  const WorkoutEditSeriesDialog({
    required this.workout,
    required this.onSave,
    super.key,
  });

  final WorkoutEntity workout;
  final ValueChanged<WorkoutEntity> onSave;

  @override
  Widget build(BuildContext context) {
    // Wrap series in a local object with a unique key to handle list updates correctly
    final seriesList = useState<List<_SeriesWrapper>>(
      workout.series.map((s) => _SeriesWrapper(s)).toList(),
    );

    void updateSeries(int index, WorkoutSeriesEntity updatedSeries) {
      final newList = [...seriesList.value];
      newList[index] = _SeriesWrapper(updatedSeries, key: newList[index].key);
      seriesList.value = newList;
    }

    void removeSeries(int index) {
      final newList = [...seriesList.value];
      newList.removeAt(index);
      seriesList.value = newList;
    }

    void addSeries() {
      final last = seriesList.value.lastOrNull?.entity;
      final newSeries = WorkoutSeriesEntity(
        repetitions: last?.repetitions ?? 12,
        weight: last?.weight ?? 0,
        rest: last?.rest ?? 60,
      );
      seriesList.value = [...seriesList.value, _SeriesWrapper(newSeries)];
    }

    return AlertDialog(
      title: Text(
        'Editar ${workout.exercise?.name ?? 'Exercício'}',
        style: Theme.of(context).textTheme.titleLarge,
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (seriesList.value.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Nenhuma série. O exercício será removido se salvar assim.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: seriesList.value.length,
                  separatorBuilder: (c, i) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final wrapper = seriesList.value[index];
                    return _SeriesEditorRow(
                      key:
                          wrapper
                              .key, // Vital for correct controller behavior on delete
                      index: index,
                      series: wrapper.entity,
                      onUpdate: (s) => updateSeries(index, s),
                      onRemove: () => removeSeries(index),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: addSeries,
              icon: const Icon(Icons.add),
              label: const Text('Adicionar Série'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            onSave(
              workout.copyWith(
                series: seriesList.value.map((w) => w.entity).toList(),
              ),
            );
            Navigator.of(context).pop();
          },
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}

class _SeriesWrapper {
  final WorkoutSeriesEntity entity;
  final Key key;

  _SeriesWrapper(this.entity, {Key? key}) : key = key ?? UniqueKey();
}

class _SeriesEditorRow extends HookWidget {
  const _SeriesEditorRow({
    required this.index,
    required this.series,
    required this.onUpdate,
    required this.onRemove,
    super.key,
  });

  final int index;
  final WorkoutSeriesEntity series;
  final ValueChanged<WorkoutSeriesEntity> onUpdate;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final repsController = useTextEditingController(
      text: series.repetitions.toString(),
    );
    final weightController = useTextEditingController(
      text: series.weight.toString(),
    );
    final restController = useTextEditingController(
      text: series.rest.toString(),
    );

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              shape: BoxShape.circle,
            ),
            child: Text(
              '${index + 1}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _CompactInput(
              controller: repsController,
              label: 'Reps',
              onChanged: (val) {
                final reps = int.tryParse(val) ?? series.repetitions;
                onUpdate(series.copyWith(repetitions: reps));
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _CompactInput(
              controller: weightController,
              label: 'Carga',
              suffix: 'kg',
              onChanged: (val) {
                final weight = int.tryParse(val) ?? series.weight;
                onUpdate(series.copyWith(weight: weight));
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _CompactInput(
              controller: restController,
              label: 'Desc.',
              suffix: 's',
              onChanged: (val) {
                final rest = int.tryParse(val) ?? series.rest;
                onUpdate(series.copyWith(rest: rest));
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            color: Colors.redAccent,
            visualDensity: VisualDensity.compact,
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}

class _CompactInput extends StatelessWidget {
  const _CompactInput({
    required this.controller,
    required this.label,
    required this.onChanged,
    this.suffix,
  });

  final TextEditingController controller;
  final String label;
  final String? suffix;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        SizedBox(
          height: 36,
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 8,
              ),
              isDense: true,
              suffixText: suffix,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
