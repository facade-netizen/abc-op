import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../bloc/fetchBlocs/fetch_runner_wise_report_bloc.dart';
import '../../../../model/runner_wise_report_model.dart';
import '../../../../reusable/colors.dart';
import '../../../../reusable/loader.dart';
import '../eventPlBook/event_pl_tile.dart';
import 'runner_wise_report_tile.dart';

class RunnerWiseReportView extends StatefulWidget {
  const RunnerWiseReportView({
    super.key,
    required this.marketId,
    required this.runnerId,
    required this.eventType,
    required this.userName,
  });
  final String marketId;
  final String runnerId;
  final String eventType;
  final String userName;
  @override
  State<RunnerWiseReportView> createState() => _RunnerWiseReportViewState();
}

class _RunnerWiseReportViewState extends State<RunnerWiseReportView> {
  RunnerWiseReportData report = RunnerWiseReportData(
    runnerName: '',
    eventName: '',
    detail: [],
  );
  @override
  void initState() {
    context.read<FetchRunnerWiseReportBloc>().add(
          FetchRunnerWiseReport(
            marketId: widget.marketId,
            runnerId: widget.runnerId,
            userName: widget.userName,
          ),
        );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: white,
      child: Align(
        alignment: Alignment.topCenter,
        child: BlocBuilder<FetchRunnerWiseReportBloc, FetchRunnerWiseReportState>(
          builder: (context, fbs) {
            if (fbs is FetchRunnerWiseReportProgress) {
              return const LoaderContainerWithMessage();
            }

            if (fbs is FetchRunnerWiseReportSuccess) {
              report = fbs.reports;
            }

            return Column(
              children: [
                // Header Bar
                BookHeaderBar(eventName: report.eventName, eventType: widget.eventType),

                // Table Layout
                Expanded(child: RunnerWiseReportTile(report: report)),
              ],
            );
          },
        ),
      ),
    );
  }
}
