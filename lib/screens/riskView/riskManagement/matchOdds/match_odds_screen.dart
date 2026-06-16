import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../bloc/fetchBlocs/fetch_open_odds_bloc.dart';
import '../../../../model/open_odds_bets_model.dart';
import '../../../../reusable/colors.dart';
import '../../../../reusable/sized_box_hw.dart';
import '../../../../reusable/snack_bar.dart';
import '../riskManagementWidgets/risk_management_custom_widget.dart';
import 'match_odds_header.dart';
import 'match_odds_tile.dart';

class MatchOddsScreen extends StatefulWidget {
  final List<OpenOddsData> openOddsData;
  final String userName;
  const MatchOddsScreen({super.key, required this.openOddsData, required this.userName});

  @override
  State<MatchOddsScreen> createState() => _MatchOddsScreenState();
}

class _MatchOddsScreenState extends State<MatchOddsScreen> {
  List<OpenOddsData> _threeRunnerData = [];
  List<OpenOddsData> _twoRunnerData = [];

  @override
  void initState() {
    super.initState();
    _separateSportsData();
  }

  @override
  void didUpdateWidget(MatchOddsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.openOddsData != widget.openOddsData) {
      _separateSportsData();
    }
  }

  void _separateSportsData() {
    _threeRunnerData = [];
    _twoRunnerData = [];

    for (final sport in widget.openOddsData) {
      final List<OddsDate> threeRunnerDates = [];
      final List<OddsDate> twoRunnerDates = [];

      for (final date in sport.dates) {
        final threeRunnerEvents = date.events.where((e) => e.risk.runners.length == 3).toList();

        final twoRunnerEvents = date.events.where((e) => e.risk.runners.length == 2).toList();

        if (threeRunnerEvents.isNotEmpty) {
          threeRunnerDates.add(OddsDate(date: date.date, events: threeRunnerEvents));
        }

        if (twoRunnerEvents.isNotEmpty) {
          twoRunnerDates.add(OddsDate(date: date.date, events: twoRunnerEvents));
        }
      }

      if (threeRunnerDates.isNotEmpty) {
        _threeRunnerData.add(OpenOddsData(sid: sport.sid, sportName: sport.sportName, dates: threeRunnerDates));
      }

      if (twoRunnerDates.isNotEmpty) {
        _twoRunnerData.add(OpenOddsData(sid: sport.sid, sportName: sport.sportName, dates: twoRunnerDates));
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
              title: "Match Odds",
              action: () {
                if (widget.userName.isNotEmpty) {
                  context.read<FetchOpenOddsBloc>().add(FetchOpenOdds(userName: widget.userName));
                } else {
                  showSnackBar(context, "Please enter a userId", error: true);
                }
              },
            ),
            hb16,

            ///3 RUNNERS SECTION
            Column(
              children: [
                const SportsTableHeader(sid: 1),
                if (_threeRunnerData.isNotEmpty)
                  Column(
                    children: _threeRunnerData.map((e) {
                      return MatchOddsTableTile(openOdds: e, sid: 1, userName: widget.userName);
                    }).toList(),
                  )
                else
                  NoData(),
                hb16,
              ],
            ),

            ///2 RUNNERS SECTION
            Column(
              children: [
                const SportsTableHeader(sid: 0),
                if (_twoRunnerData.isNotEmpty)
                  Column(
                    children: _twoRunnerData.map((e) {
                      return MatchOddsTableTile(openOdds: e, userName: widget.userName, sid: 0);
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
