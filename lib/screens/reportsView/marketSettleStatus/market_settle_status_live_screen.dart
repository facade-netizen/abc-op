import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/fetchBlocs/fetch_settle_history_bloc.dart';
import '../../../model/settle_history_model.dart';
import '../../../reusable/button.dart';
import '../../../reusable/colors.dart';
import '../../../reusable/loader.dart';
import '../../../reusable/normal_pagination_table.dart';
import '../../../reusable/sized_box_hw.dart';
import '../../../reusable/string.dart';
import '../../filterOverlay/download_report.dart';
import '../../riskView/riskManagement/riskManagementWidgets/risk_management_custom_widget.dart';
import '../../riskView/riskMonitoring/row_dropdown.dart';

class MarketSettleStatusLiveScreen extends StatefulWidget {
  const MarketSettleStatusLiveScreen({super.key});

  @override
  State<MarketSettleStatusLiveScreen> createState() => _MarketSettleStatusLiveScreenState();
}

class _MarketSettleStatusLiveScreenState extends State<MarketSettleStatusLiveScreen> {
  String refreshTime = "15";

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);

    return SizedBox(
      width: size.width,
      height: size.height,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const RiskHeader(type: 1, title: "Market Settle Status Live"),
              Container(
                width: size.width,
                decoration: BoxDecoration(
                  color: accountStatementHeaderBg,
                  border: Border(bottom: BorderSide(color: borderColor)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 15),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    RowDropdown<String>(
                      title: 'Auto Refresh (Seconds)',
                      value: refreshTime,
                      items: refreshTimeList,
                      onChanged: (val) {
                        if (val == null) return;
                        setState(() => refreshTime = val);
                        if (val == "Stop") {
                          context.read<FetchSettleHistoryBloc>().add(StopAutoRefresh());
                        } else {
                          context.read<FetchSettleHistoryBloc>().add(StartAutoRefresh(seconds: int.parse(val)));
                        }
                      },
                    ),
                    CustomECTAButton(
                      title: 'Refresh',
                      action: () {
                        context.read<FetchSettleHistoryBloc>().add(FetchSettleHistory());
                      },
                    ),
                    BlocBuilder<FetchSettleHistoryBloc, FetchSettleHistoryState>(
                      builder: (context, shs) {
                        List<SettleHistoryData> settleHistory = [];
                        if (shs is FetchSettleHistorySuccess) {
                          settleHistory = shs.settleHistory;
                        }
                        return DownloadReport(
                          reportName: 'Market Settle Status Live',
                          headerTitles: marketSettleColumns.map((e) => e.label).toList(),
                          rowData: settleHistory.map((row) {
                            return marketSettleColumns.map((col) {
                              if (col.value != null) {
                                return col.value!(row);
                              } else if (col.customCell != null) {
                                return '';
                              }
                              return '';
                            }).toList();
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
              hb10,

              /// Table
              BlocBuilder<FetchSettleHistoryBloc, FetchSettleHistoryState>(
                builder: (context, shs) {
                  List<SettleHistoryData> settleHistory = [];
                  if (shs is FetchSettleHistorySuccess) {
                    settleHistory = shs.settleHistory;
                  }
                  return shs is FetchSettleHistoryProgress
                      ? const LoaderContainerWithMessage(message: "Loading...")
                      : settleHistory.isEmpty
                      ? SizedBox()
                      : NormalPaginationTable<SettleHistoryData>(
                          pageSize: 12,
                          key: Key('settle_history_table_at_${DateTime.now().toIso8601String()}'),
                          data: settleHistory,
                          columns: marketSettleColumns,
                        );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
