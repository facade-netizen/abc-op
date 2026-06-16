import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/fetchBlocs/fetch_change_pass_logs_bloc.dart';
import '../../../bloc/fetchBlocs/fetch_credit_limit_logs_bloc.dart';
import '../../../bloc/fetchBlocs/fetch_transferred_logs_bloc.dart';
import '../../../bloc/fetchBlocs/fetch_user_account_statement_logs_bloc.dart';
import '../../../bloc/fetchBlocs/fetch_user_activity_logs_bloc.dart';
import '../../../bloc/fetchBlocs/fetch_user_ispip_logs_bloc.dart';
import '../../../reusable/sized_box_hw.dart';
import '../../riskView/riskManagement/riskManagementWidgets/risk_management_custom_widget.dart';
import '../../riskView/riskMonitoring/row_dropdown.dart';
import 'account_statement_log_screen.dart';
import 'activity_logs_screen.dart';
import 'change_password_log_screen.dart';
import 'credit_limit_log_screen.dart';
import 'order_logs_screen.dart';
import 'transferred_log_screen.dart';
import 'user_ispip_log_screen.dart';

class UserActivityLogView extends StatefulWidget {
  const UserActivityLogView({super.key});

  @override
  State<UserActivityLogView> createState() => _UserActivityLogViewState();
}

class _UserActivityLogViewState extends State<UserActivityLogView> {
  late ActionItem selectedScreen;

  final List<ActionItem> screens = [
    ActionItem(
      label: 'Account Statement/Balance Overview',
      screen: const AccountStatementLogScreen(title: 'Account Statement/Balance Overview'),
      action: (ctxt) => ctxt.read<FetchUserAccountStatementLogsBloc>().add(FetchUserAccountStatementLogsInt()),
    ),
    ActionItem(
      label: 'Transferred Log',
      screen: const TransferredLogScreen(title: 'Transferred Log'),
      action: (ctxt) => ctxt.read<FetchTransferredLogsBloc>().add(FetchTransferredLogsInt()),
    ),
    ActionItem(
      label: 'Activity Log',
      screen: const UserActivityLogScreen(title: 'Activity Log'),
      action: (ctxt) => ctxt.read<FetchUserActivityLogsBloc>().add(FetchUserActivityLogsInt()),
    ),
    ActionItem(
      label: 'Order Activity Log',
      screen: const UserOrderLogScreen(title: 'Order Activity Log'),
      action: (ctxt) => ctxt.read<FetchUserActivityLogsBloc>().add(FetchUserActivityLogsInt()),
    ),
    ActionItem(
      label: 'ISP/IP Log',
      screen: const UserIspipLogScreen(title: 'ISP/IP Log'),
      action: (ctxt) => ctxt.read<FetchUserIspIpLogsBloc>().add(FetchUserIspIpLogsInt()),
    ),
    ActionItem(
      label: 'Changed Password Log',
      screen: const ChangePasswordLogScreen(title: 'Changed Password Log'),
      action: (ctxt) => ctxt.read<FetchChangePassLogsBloc>().add(FetchChangePassLogsInt()),
    ),
    ActionItem(
      label: 'Initial Credit Limit (Credit Mode)',
      screen: const CreditLimitLogScreen(title: 'Initial Credit Limit (Credit Mode)'),
      action: (ctxt) => ctxt.read<FetchCreditLimitLogsBloc>().add(FetchCreditLimitLogsInt()),
    ),
  ];

  @override
  void initState() {
    super.initState();
    selectedScreen = screens.firstWhere((screen) => screen.label == 'Activity Log');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return SizedBox(
      width: size.width,
      height: size.height,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const RiskHeader(type: 1, title: "User Activity Log"),
              hb10,
              RowDropdown<String>(
                width: 300,
                title: 'Action',
                value: selectedScreen.label,
                items: screens.map((e) => e.label).toList(),
                onChanged: (value) {
                  if (value != null) {
                    final newScreen = screens.firstWhere((screen) => screen.label == value);
                    setState(() {
                      selectedScreen = newScreen;
                    });
                    selectedScreen.action(context);
                  }
                },
              ),
              hb10,
              selectedScreen.screen,
            ],
          ),
        ),
      ),
    );
  }
}

class ActionItem {
  final String label;
  final Widget screen;
  final void Function(BuildContext ctxt) action;

  const ActionItem({
    required this.label,
    required this.screen,
    required this.action,
  });
}
