import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../data/models/finance_module.dart';

class FinanceExportService {
  Future<void> share(FinanceExport export, BuildContext context) async {
    final renderObject = context.findRenderObject();
    final origin = renderObject is RenderBox
        ? renderObject.localToGlobal(Offset.zero) & renderObject.size
        : const Rect.fromLTWH(0, 0, 1, 1);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile.fromData(export.bytes, mimeType: export.mimeType)],
        fileNameOverrides: [export.filename],
        sharePositionOrigin: origin,
      ),
    );
  }
}
