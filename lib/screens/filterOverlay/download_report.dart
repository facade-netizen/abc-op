import 'package:flutter/material.dart';

import '../../reusable/colors.dart';
import '../../reusable/highlighted_text_widget.dart';
import '../../reusable/snack_bar.dart';
import '../../services/file_generator_helper.dart';
import '../../services/get_excel_file_from_passed_data_service.dart';

class DownloadReport extends StatelessWidget {
  const DownloadReport({
    super.key,
    this.rowData,
    this.reportName,
    this.headerTitles,
    this.numericColumns,
    this.height,
  });

  final double? height;
  final String? reportName;
  final List<int>? numericColumns;
  final List<String>? headerTitles;
  final List<List<String>>? rowData;

  @override
  Widget build(BuildContext context) {
    final bool hasData = rowData != null && rowData!.isNotEmpty;

    return Wrap(
      spacing: 10,
      runSpacing: 8,
      children: [
        DownloadReportButton(
          height: height,
          title: 'Excel',
          icon: Icons.border_all,
          action: hasData
              ? () async {
                  try {
                    await generateAndDownloadReportInExcel(
                      headerTitles!,
                      rowData!,
                      reportName!,
                    ).then((value) {
                      if (context.mounted) {
                        showSnackBar(context, 'Excel downloaded successfully.');
                      }
                    });
                  } catch (e) {
                    if (context.mounted) {
                      showSnackBar(context, 'Failed: $e', error: true);
                    }
                  }
                }
              : null,
        ),
        DownloadReportButton(
          height: height,
          icon: Icons.picture_as_pdf,
          title: 'PDF',
          action: hasData
              ? () async {
                  try {
                    final bytes = await runPdfWorker({
                      'reportName': reportName,
                      'rowData': rowData,
                      'columnNames': headerTitles,
                    });

                    if (!context.mounted) return;
                    await saveAndLaunchFile(
                      bytes,
                      '${reportName}_${DateTime.now().toUtc()}.pdf',
                    ).then((value) {
                      if (context.mounted) {
                        showSnackBar(context, 'File downloaded successfully.');
                      }
                    });
                  } catch (err) {
                    if (context.mounted) {
                      showSnackBar(context, 'Failed: $err', error: true);
                    }
                  }
                }
              : null,
        ),
      ],
    );
  }
}

class DownloadReportButton extends StatelessWidget {
  const DownloadReportButton({
    super.key,
    required this.title,
    this.action,
    this.icon,
    this.height,
  });

  final double? height;
  final String title;
  final void Function()? action;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = action == null;

    return SizedBox(
      height: height ?? 28,
      width: 120,
      child: ElevatedButton.icon(
        icon: Icon(icon ?? Icons.download, size: 16),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(
            isDisabled ? const Color(0xFF9CA3AF) : const Color(0xFF16A34A),
          ),
          foregroundColor: MaterialStateProperty.all(white),
          side: MaterialStateProperty.all(
            BorderSide(
              color: isDisabled ? const Color(0xFF9CA3AF) : const Color(0xFF16A34A),
            ),
          ),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          overlayColor: MaterialStateProperty.all(white.withOpacity(0.08)),
          padding: MaterialStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 8),
          ),
          elevation: MaterialStateProperty.all(1),
        ),
        onPressed: action,
        label: HighlightText(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
