import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/utils/formatters.dart';
import '../../domain/entities/loan_input.dart';
import '../../domain/entities/loan_result.dart';
import '../../domain/entities/schedule_item.dart';

/// 导出服务：还款计划 PDF / CSV
///
/// PDF 内嵌 Noto Sans SC 子集字体以支持中文渲染。
class ExportService {
  ExportService._();

  static pw.Font? _regular;
  static pw.Font? _bold;

  /// 加载内嵌中文字体（幂等）
  static Future<pw.ThemeData> _theme() async {
    _regular ??= pw.Font.ttf(
      await rootBundle.load('assets/fonts/NotoSansSC-Regular.ttf'),
    );
    _bold ??= pw.Font.ttf(
      await rootBundle.load('assets/fonts/NotoSansSC-Bold.ttf'),
    );
    return pw.ThemeData.withFont(base: _regular!, bold: _bold!);
  }

  /// 导出还款计划 PDF 并调起系统分享
  ///
  /// [labels] 依次为：标题、期数、月供、本金、利息、剩余本金、
  /// 月供标签、总利息标签、总还款标签、免责声明。
  static Future<void> exportSchedulePdf({
    required LoanInput input,
    required LoanResult result,
    required List<ScheduleItem> schedule,
    required List<String> labels,
  }) async {
    final theme = await _theme();
    final doc = pw.Document(theme: theme);

    final headerStyle = pw.TextStyle(
      fontWeight: pw.FontWeight.bold,
      fontSize: 9,
    );
    const cellStyle = pw.TextStyle(fontSize: 8);

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (context) => [
          pw.Text(
            labels[0],
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            '${labels[6]}: ${Formatters.currency2(result.total.monthlyPayment)}    '
            '${labels[7]}: ${Formatters.currency2(result.total.totalInterest)}    '
            '${labels[8]}: ${Formatters.currency2(result.total.totalPayment)}',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.SizedBox(height: 12),
          pw.TableHelper.fromTextArray(
            headerStyle: headerStyle,
            cellStyle: cellStyle,
            cellAlignment: pw.Alignment.centerRight,
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            headers: [labels[1], labels[2], labels[3], labels[4], labels[5]],
            data: schedule
                .map(
                  (e) => [
                    '${e.month}',
                    Formatters.currency2(e.payment),
                    Formatters.currency2(e.principal),
                    Formatters.currency2(e.interest),
                    Formatters.currency2(e.remainingPrincipal),
                  ],
                )
                .toList(),
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            labels[9],
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
          ),
        ],
      ),
    );

    await Printing.sharePdf(
      bytes: await doc.save(),
      filename: 'repayment_schedule.pdf',
    );
  }

  /// 导出还款计划 CSV 并调起系统分享
  ///
  /// [headers] 依次为：期数、月供、本金、利息、剩余本金。
  static Future<void> exportScheduleCsv({
    required List<ScheduleItem> schedule,
    required List<String> headers,
  }) async {
    final buffer = StringBuffer()
      // UTF-8 BOM，保证 Excel 正确识别中文
      ..write('﻿')
      ..writeln(headers.join(','));
    for (final e in schedule) {
      buffer.writeln(
        [
          e.month,
          e.payment.toStringAsFixed(2),
          e.principal.toStringAsFixed(2),
          e.interest.toStringAsFixed(2),
          e.remainingPrincipal.toStringAsFixed(2),
        ].join(','),
      );
    }

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/repayment_schedule.csv');
    await file.writeAsString(buffer.toString(), flush: true);

    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)], subject: 'repayment_schedule.csv'),
    );
  }
}
