import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../bloc/fetchBlocs/fetch_open_bm_bloc.dart';
import '../../../../model/open_bm_bets_model.dart';
import '../../../../reusable/colors.dart';
import '../../../../reusable/sized_box_hw.dart';
import '../../../../reusable/snack_bar.dart';
import '../matchOdds/match_odds_header.dart';
import '../riskManagementWidgets/risk_management_custom_widget.dart';
import 'book_maker_tile.dart';

class BookMakerScreen extends StatefulWidget {
  final List<OpenBMData> openBMData;
  final String userName;
  const BookMakerScreen({super.key, required this.openBMData, required this.userName});

  @override
  State<BookMakerScreen> createState() => _BookMakerScreenState();
}

class _BookMakerScreenState extends State<BookMakerScreen> {
  List<OpenBMData> _threeRunnerData = [];
  List<OpenBMData> _twoRunnerData = [];

  @override
  void initState() {
    super.initState();
    _separateSportsData();
  }

  @override
  void didUpdateWidget(BookMakerScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.openBMData != widget.openBMData) {
      _separateSportsData();
    }
  }

  void _separateSportsData() {
    _threeRunnerData = [];
    _twoRunnerData = [];

    for (final sport in widget.openBMData) {
      final List<BMDate> threeRunnerDates = [];
      final List<BMDate> twoRunnerDates = [];

      for (final date in sport.dates) {
        final threeRunnerEvents = date.events.where((e) => e.risk.runners.length == 3).toList();

        final twoRunnerEvents = date.events.where((e) => e.risk.runners.length == 2).toList();

        if (threeRunnerEvents.isNotEmpty) {
          threeRunnerDates.add(BMDate(date: date.date, events: threeRunnerEvents));
        }

        if (twoRunnerEvents.isNotEmpty) {
          twoRunnerDates.add(BMDate(date: date.date, events: twoRunnerEvents));
        }
      }

      if (threeRunnerDates.isNotEmpty) {
        _threeRunnerData.add(OpenBMData(sid: sport.sid, sportName: sport.sportName, dates: threeRunnerDates));
      }

      if (twoRunnerDates.isNotEmpty) {
        _twoRunnerData.add(OpenBMData(sid: sport.sid, sportName: sport.sportName, dates: twoRunnerDates));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: primaryCardColor,
          border: Border(
            top: BorderSide(color: Colors.grey.shade400),
            bottom: const BorderSide(color: Colors.white, width: 2),
          ),
        ),
        child: Column(
          children: [
            RiskHeader(
              title: "Book Maker",
              action: () {
                if (widget.userName.isNotEmpty) {
                  context.read<FetchOpenBMBloc>().add(FetchOpenBM(userName: widget.userName));
                } else {
                  showSnackBar(context, "Please enter a userId", error: true);
                }
              },
            ),
            hb16,

            /// 3 RUNNERS
            Column(
              children: [
                const SportsTableHeader(sid: 1),
                if (_threeRunnerData.isNotEmpty)
                  Column(
                    children: _threeRunnerData.map((e) {
                      return BookMakerTile(openBM: e, sid: 1, userName: widget.userName);
                    }).toList(),
                  )
                else
                  NoData(),
                hb16,
              ],
            ),

            /// 2 RUNNERS
            Column(
              children: [
                const SportsTableHeader(sid: 0),
                if (_twoRunnerData.isNotEmpty)
                  Column(
                    children: _twoRunnerData.map((e) {
                      return BookMakerTile(openBM: e, sid: 0, userName: widget.userName);
                    }).toList(),
                  )
                else
                  NoData(),
                hb16,
              ],
            ),
          ],
        ),
      ),
    );
  }
}
