import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

class TaskFiltersRow extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const TaskFiltersRow({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    Widget chip(String itemValue, String label) {
      final selected = value == itemValue;
      return ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onChanged(itemValue),
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: selected ? Colors.white : AppTheme.ink,
        ),
        selectedColor: const Color(0xFF0F1115),
        backgroundColor: Theme.of(context).colorScheme.surface,
        side: const BorderSide(color: AppTheme.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        padding: const EdgeInsetsDirectional.fromSTEB(12, 8, 12, 8),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          chip('all', 'الكل'),
          const SizedBox(width: 8),
          chip('pending', 'معلّقة'),
          const SizedBox(width: 8),
          chip('in_progress', 'قيد التنفيذ'),
          const SizedBox(width: 8),
          chip('done', 'مكتملة'),
        ],
      ),
    );
  }
}
