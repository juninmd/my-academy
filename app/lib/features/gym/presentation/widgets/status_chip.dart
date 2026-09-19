import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final brl = NumberFormat.currency(locale: 'pt_BR', symbol: r'R$');
final shortDate = DateFormat('dd/MM/yyyy', 'pt_BR');

const _labels = {
  'ACTIVE': 'Ativa',
  'INACTIVE': 'Inativa',
  'CANCELLED': 'Cancelada',
  'EXPIRED': 'Expirada',
  'PENDING': 'Pendente',
  'PAID': 'Pago',
  'OVERDUE': 'Atrasado',
};

String statusLabel(String status) => _labels[status] ?? status;

/// Status badge: color is reinforced by an icon and text (not color-only).
class StatusChip extends StatelessWidget {
  const StatusChip(this.status, {super.key});
  final String status;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (Color color, IconData icon) = switch (status) {
      'ACTIVE' || 'PAID' => (Colors.green, Icons.check_circle_outline),
      'PENDING' => (Colors.amber.shade800, Icons.schedule),
      'OVERDUE' => (scheme.error, Icons.error_outline),
      _ => (scheme.outline, Icons.remove_circle_outline),
    };
    return Semantics(
      label: 'Status: ${statusLabel(status)}',
      excludeSemantics: true,
      child: Chip(
        avatar: Icon(icon, size: 16, color: color),
        label: Text(statusLabel(status)),
        labelStyle: TextStyle(color: color, fontWeight: FontWeight.w600),
        side: BorderSide(color: color.withValues(alpha: 0.4)),
        backgroundColor: color.withValues(alpha: 0.08),
        visualDensity: VisualDensity.compact,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
