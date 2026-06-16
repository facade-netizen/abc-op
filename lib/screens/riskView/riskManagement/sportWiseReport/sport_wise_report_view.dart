import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../bloc/fetchBlocs/fetch_sport_wise_report_bloc.dart';
import '../../../../model/sport_wise_report_model.dart';
import '../../../../reusable/colors.dart';
import '../../../../reusable/loader.dart';
import '../eventPlBook/event_pl_tile.dart';
import 'sport_wise_report_tile.dart';

class SportWiseReportView extends StatefulWidget {
  const SportWiseReportView({super.key, required this.sid, required this.eventId, required this.bettingType, required this.screenType, required this.userName});
  final String sid;
  final String eventId;
  final String screenType;
  final String userName;
  final int bettingType;
  @override
  State<SportWiseReportView> createState() => _SportWiseReportViewState();
}

class _SportWiseReportViewState extends State<SportWiseReportView> {
  List<SportWiseReportData> report = [];
  @override
  void initState() {
    context.read<FetchSportWiseReportBloc>().add(FetchSportWiseReport(sid: widget.sid, bettingType: widget.bettingType, eventId: widget.eventId, userName: widget.userName));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: white,
      child: Align(
        alignment: Alignment.topCenter,
        child: BlocBuilder<FetchSportWiseReportBloc, FetchSportWiseReportState>(
          builder: (context, fbs) {
            if (fbs is FetchSportWiseReportProgress) {
              return const LoaderContainerWithMessage();
            }

            if (fbs is FetchSportWiseReportSuccess) {
              report = widget.screenType == 'otherMarkets' ? fbs.otherMarkets : fbs.reports;
            }

            return Column(
              children: [
                // Header Bar
                BookHeaderBar(eventName: sportName(widget.sid)),

                // Table Layout
                Expanded(
                  child: SportWiseReportTile(report: report, type: widget.bettingType, userName: widget.userName),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
