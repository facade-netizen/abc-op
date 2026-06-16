import 'package:flutter/foundation.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' hide Column;

import 'file_generator_helper.dart';

Future<bool> generateAndDownloadReportInExcel(
  List<String> columnNames,
  List<List<String>> rowData,
  String reportName, {
  List<int>? numericColumns,
}) async {
  try {
    final Workbook workbook = Workbook();
    final Worksheet sheet = workbook.worksheets[0];
    sheet.showGridlines = true;

    String currDateTime = DateTime.now().toIso8601String();
    String lastColumnAlphabet = String.fromCharCode(64 + columnNames.length);

    /// ---------- STATIC INFO (Row 1-3)
    sheet.getRangeByName('A1:C1').merge();
    sheet.getRangeByName('A1').setText('Report Name');

    sheet.getRangeByName('A2:C2').merge();
    sheet.getRangeByName('A2').setText('Generated Date Time');

    sheet.getRangeByName('A3:C3').merge();
    sheet.getRangeByName('A3').setText('Number Of Records');

    /// ---------- INFO VALUES
    sheet.getRangeByName('D1:${lastColumnAlphabet}1').merge();
    sheet.getRangeByName('D1').setText(reportName);

    sheet.getRangeByName('D2:${lastColumnAlphabet}2').merge();
    sheet.getRangeByName('D2').setText(currDateTime);

    sheet.getRangeByName('D3:${lastColumnAlphabet}3').merge();
    sheet.getRangeByName('D3').setNumber(rowData.length.toDouble());
    sheet.getRangeByName('D3').cellStyle.hAlign = HAlignType.left;

    /// ---------- EMPTY ROW 4
    sheet.getRangeByName("A4:${lastColumnAlphabet}4").merge();

    /// ---------- TABLE HEADER (ROW 5)
    for (int i = 0; i < columnNames.length; i++) {
      sheet.setColumnWidthInPixels(i + 1, 150);

      sheet.getRangeByIndex(5, i + 1).setText(columnNames[i]);
      sheet.getRangeByIndex(5, i + 1).cellStyle.fontSize = 14;
      sheet.getRangeByIndex(5, i + 1).cellStyle.bold = true;
      sheet.getRangeByIndex(5, i + 1).cellStyle.backColor = "#ADD8E6";
    }

    /// ---------- ROW DATA (START ROW 6)
    for (int i = 6; i < rowData.length + 6; i++) {
      List<String> thisRow = rowData[i - 6];

      for (int j = 1; j < thisRow.length + 1; j++) {
        if (numericColumns == null || numericColumns.isEmpty) {
          sheet.getRangeByIndex(i, j).setText(thisRow[j - 1]);
        } else {
          if (numericColumns.contains(j)) {
            sheet.getRangeByIndex(i, j).setNumber(double.tryParse(thisRow[j - 1]));
          } else {
            sheet.getRangeByIndex(i, j).setText(thisRow[j - 1]);
          }
        }
      }
    }

    final List<int> bytes = workbook.saveAsStream();

    await saveAndLaunchFile(bytes, '${reportName}_$currDateTime.xlsx');

    return true;
  } catch (e, stackTrace) {
    if (kDebugMode) {
      debugPrint('Error generating Excel: $e');
      debugPrint('Stack trace: $stackTrace');
    }
    return false;
  }
}
