import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';

/// Shared Aite select field. The existing values/callbacks stay unchanged;
/// only the mobile presentation changes. Long lists open a searchable sheet.
class IosSelectField<T> extends StatefulWidget {
  final T? initialValue;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final InputDecoration decoration;
  final bool isExpanded;
  final bool? searchable;
  final bool loading;
  final bool enabled;
  final String? errorText;
  final String? sheetTitle;
  final IconData? leadingIcon;
  final FormFieldValidator<T>? validator;

  const IosSelectField({
    super.key,
    required this.initialValue,
    required this.items,
    required this.onChanged,
    required this.decoration,
    this.isExpanded = true,
    this.searchable,
    this.loading = false,
    this.enabled = true,
    this.errorText,
    this.sheetTitle,
    this.leadingIcon,
    this.validator,
  });

  @override
  State<IosSelectField<T>> createState() => _IosSelectFieldState<T>();
}

class _SelectionResult<T> {
  final T? value;
  const _SelectionResult(this.value);
}

class _IosSelectFieldState<T> extends State<IosSelectField<T>> {
  bool _open = false;

  String _labelFor(DropdownMenuItem<T> item) {
    final child = item.child;
    if (child is Text) return child.data ?? child.textSpan?.toPlainText() ?? '';
    return item.value?.toString() ?? '';
  }

  Future<void> _showOptions(FormFieldState<T> field) async {
    if (_open ||
        !widget.enabled ||
        widget.loading ||
        widget.onChanged == null) {
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _open = true);
    final searchable = widget.searchable ?? widget.items.length > 8;
    var search = '';
    try {
      final result = await showModalBottomSheet<_SelectionResult<T>>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        showDragHandle: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        builder: (sheetContext) => StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            final media = MediaQuery.of(sheetContext);
            final available = math.max(
                160.0,
                media.size.height -
                    media.padding.top -
                    media.viewInsets.bottom -
                    52);
            final desired = searchable
                ? math.min(560.0, available * .82)
                : 72.0 + widget.items.length * 58.0;
            final options = search.isEmpty
                ? widget.items
                : widget.items
                    .where((item) => _labelFor(item)
                        .toLowerCase()
                        .contains(search.toLowerCase()))
                    .toList(growable: false);
            return AnimatedPadding(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
              child: SizedBox(
                height: math.min(available, desired),
                child: Column(children: [
                  Padding(
                    padding:
                        const EdgeInsetsDirectional.fromSTEB(20, 0, 12, 10),
                    child: Row(children: [
                      Expanded(
                        child: Text(
                          widget.sheetTitle ??
                              widget.decoration.labelText ??
                              context.tr(en: 'Select', ar: 'اختر'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(sheetContext)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                      IconButton(
                        tooltip: context.tr(en: 'Close', ar: 'إغلاق'),
                        onPressed: () => Navigator.of(sheetContext).pop(),
                        icon: const Icon(CupertinoIcons.xmark, size: 18),
                      ),
                    ]),
                  ),
                  if (searchable) ...[
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 12),
                      child: TextField(
                        textInputAction: TextInputAction.search,
                        onChanged: (value) =>
                            setSheetState(() => search = value.trim()),
                        decoration: InputDecoration(
                          hintText: context.tr(en: 'Search', ar: 'بحث'),
                          prefixIcon:
                              const Icon(CupertinoIcons.search, size: 19),
                        ),
                      ),
                    ),
                  ],
                  Expanded(
                    child: options.isEmpty
                        ? Center(
                            child: Text(
                            context.tr(
                                en: 'No options found', ar: 'لا توجد خيارات'),
                            style: Theme.of(sheetContext)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: AppTheme.muted),
                          ))
                        : ListView.separated(
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            itemCount: options.length,
                            separatorBuilder: (_, __) => const Divider(
                                height: 1, indent: 20, endIndent: 20),
                            itemBuilder: (sheetContext, index) {
                              final item = options[index];
                              final selected = item.value == field.value;
                              return InkWell(
                                onTap: () => Navigator.of(sheetContext)
                                    .pop(_SelectionResult<T>(item.value)),
                                child: ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(minHeight: 56),
                                  child: Padding(
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            20, 12, 20, 12),
                                    child: Row(children: [
                                      Expanded(
                                          child: Text(
                                        _labelFor(item),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(sheetContext)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                              fontWeight: selected
                                                  ? FontWeight.w800
                                                  : FontWeight.w600,
                                            ),
                                      )),
                                      if (selected) ...[
                                        const SizedBox(width: 12),
                                        Icon(CupertinoIcons.check_mark,
                                            size: 20,
                                            color: Theme.of(sheetContext)
                                                .colorScheme
                                                .primary),
                                      ],
                                    ]),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ]),
              ),
            );
          },
        ),
      );
      if (result != null && mounted) {
        field.didChange(result.value);
        widget.onChanged?.call(result.value);
      }
    } finally {
      if (mounted) setState(() => _open = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final canOpen =
        widget.enabled && !widget.loading && widget.onChanged != null;
    return FormField<T>(
      key: ValueKey<T?>(widget.initialValue),
      initialValue: widget.initialValue,
      validator: widget.validator,
      builder: (field) {
        final selectedIndex =
            widget.items.indexWhere((item) => item.value == field.value);
        final selectedText = selectedIndex < 0
            ? widget.decoration.hintText ??
                context.tr(en: 'Select an option', ar: 'اختر خيارًا')
            : _labelFor(widget.items[selectedIndex]);
        final error =
            widget.errorText ?? field.errorText ?? widget.decoration.errorText;
        final borderColor = error != null
            ? scheme.error
            : _open
                ? scheme.primary
                : theme.brightness == Brightness.dark
                    ? scheme.outlineVariant
                    : AppTheme.border;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if ((widget.decoration.labelText ?? '').isNotEmpty) ...[
              Text(widget.decoration.labelText!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                      color:
                          canOpen ? scheme.onSurfaceVariant : scheme.outline)),
              const SizedBox(height: 7),
            ],
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: canOpen ? () => _showOptions(field) : null,
                borderRadius: BorderRadius.circular(20),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  constraints: const BoxConstraints(minHeight: 56),
                  padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 14, 12),
                  decoration: BoxDecoration(
                    color: widget.decoration.fillColor ?? scheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: borderColor,
                        width: _open || error != null ? 1.5 : 1),
                  ),
                  child: Row(children: [
                    if (widget.leadingIcon != null) ...[
                      Icon(widget.leadingIcon,
                          size: 20, color: scheme.onSurfaceVariant),
                      const SizedBox(width: 10),
                    ],
                    Expanded(
                        child: Text(
                      selectedText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                          color: selectedIndex < 0 || !canOpen
                              ? scheme.onSurfaceVariant
                              : scheme.onSurface),
                    )),
                    const SizedBox(width: 12),
                    if (widget.loading)
                      const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2))
                    else
                      Icon(CupertinoIcons.chevron_down,
                          size: 18,
                          color: canOpen
                              ? scheme.onSurfaceVariant
                              : scheme.outline),
                  ]),
                ),
              ),
            ),
            if (error != null) ...[
              const SizedBox(height: 6),
              Text(error,
                  style:
                      theme.textTheme.bodySmall?.copyWith(color: scheme.error)),
            ],
          ],
        );
      },
    );
  }
}
