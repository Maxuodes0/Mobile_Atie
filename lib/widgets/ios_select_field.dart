import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

/// Keeps Material form styling on Android and uses the native iOS wheel on iPhone.
class IosSelectField<T> extends StatelessWidget {
  final T? initialValue;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final InputDecoration decoration;
  final bool isExpanded;

  const IosSelectField({
    super.key,
    required this.initialValue,
    required this.items,
    required this.onChanged,
    required this.decoration,
    this.isExpanded = true,
  });

  Future<void> _showPicker(BuildContext context) async {
    if (items.isEmpty || onChanged == null) return;
    var selected = items.indexWhere((item) => item.value == initialValue);
    if (selected < 0) selected = 0;
    final controller = FixedExtentScrollController(initialItem: selected);
    final result = await showCupertinoModalPopup<int>(
      context: context,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: Container(
          height: 300,
          color: CupertinoColors.systemBackground.resolveFrom(sheetContext),
          child: Column(children: [
            Row(children: [
              CupertinoButton(
                onPressed: () => Navigator.pop(sheetContext),
                child: Text(context.tr(en: 'Cancel', ar: 'إلغاء')),
              ),
              Expanded(
                child: Text(
                  decoration.labelText ?? '',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              CupertinoButton(
                onPressed: () => Navigator.pop(sheetContext, selected),
                child: Text(context.tr(en: 'Done', ar: 'تم')),
              ),
            ]),
            Expanded(
              child: CupertinoPicker(
                scrollController: controller,
                itemExtent: 42,
                onSelectedItemChanged: (index) => selected = index,
                children: [
                  for (final item in items)
                    Center(
                        child: DefaultTextStyle(
                      style: TextStyle(
                        color: CupertinoColors.label.resolveFrom(sheetContext),
                        fontSize: 17,
                      ),
                      child: item.child,
                    )),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
    controller.dispose();
    if (result != null && context.mounted) onChanged?.call(items[result].value);
  }

  @override
  Widget build(BuildContext context) {
    if (Theme.of(context).platform != TargetPlatform.iOS) {
      return DropdownButtonFormField<T>(
        initialValue: initialValue,
        isExpanded: isExpanded,
        decoration: decoration,
        items: items,
        onChanged: onChanged,
      );
    }
    final selected = items.where((item) => item.value == initialValue);
    return InkWell(
      onTap: onChanged == null ? null : () => _showPicker(context),
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: decoration.copyWith(enabled: onChanged != null),
        isEmpty: selected.isEmpty,
        child: Row(children: [
          Expanded(
            child: selected.isEmpty
                ? const SizedBox.shrink()
                : DefaultTextStyle(
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    child: selected.first.child,
                  ),
          ),
          const Icon(CupertinoIcons.chevron_up_chevron_down, size: 16),
        ]),
      ),
    );
  }
}
