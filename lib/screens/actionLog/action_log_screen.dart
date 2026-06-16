import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/fetchBlocs/fetch_all_wl_bloc.dart';
import '../../model/activity_log_model.dart';
import '../../reusable/button.dart';
import '../../reusable/colors.dart';
import '../../reusable/highlighted_text_widget.dart';
import '../../reusable/normal_pagination_table.dart';
import '../../reusable/sized_box_hw.dart';
import '../logView/agencyLogHistory/balance_log_screen.dart';
import '../riskView/riskManagement/riskManagementWidgets/risk_management_custom_widget.dart';
import '../riskView/riskMonitoring/row_dropdown.dart';

class ActionLogScreen extends StatefulWidget {
  const ActionLogScreen({super.key});

  @override
  State<ActionLogScreen> createState() => _ActionLogScreenState();
}

class _ActionLogScreenState extends State<ActionLogScreen> {
  final TextEditingController userIdController = TextEditingController();
  List<String> sites = [];
  String selectedSite = "";
  double bw = 220;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return SizedBox(
      width: size.width,
      height: size.height,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RiskHeader(type: 1, title: "Action Log"),
              hb10,
              RowTFF(controller: userIdController, hintText: "enter userId...", title: "User", width: bw),
              hb10,
              BlocBuilder<FetchAllWlBloc, FetchAllWlState>(
                builder: (context, wls) {
                  if (wls is FetchAllWlSuccess) {
                    sites = wls.wlList;
                  }
                  final currentSite = selectedSite.isNotEmpty && sites.contains(selectedSite) ? selectedSite : (sites.isNotEmpty ? sites.first : '');

                  return RowDropdown<String>(
                    title: 'Site',
                    width: bw,
                    value: currentSite,
                    items: sites,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => selectedSite = value);
                      }
                    },
                  );
                },
              ),
              hb10,
              Row(
                children: [
                  Text("Site  ", style: TextStyle(fontSize: 16, color: transparent)),
                  CustomECTAButton(width: bw, title: 'Search', action: () {}),
                ],
              ),
              hb10,
              HighlightText('1. The Action Log retains records from the past 62 days for querying.'),
              //
              NormalPaginationTable<ActionLogModel>(key: Key('action_log_table_at_${DateTime.now().toIso8601String()}'), data: [], pageSize: 25, columns: actionLogColumns),
            ],
          ),
        ),
      ),
    );
  }
}
