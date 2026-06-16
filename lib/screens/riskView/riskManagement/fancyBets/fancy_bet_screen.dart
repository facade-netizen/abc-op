import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../bloc/fetchBlocs/fetch_open_fancy_bloc.dart';
import '../../../../model/open_fancy_bets_model.dart';
import '../../../../reusable/colors.dart';
import '../../../../reusable/sized_box_hw.dart';
import '../../../../reusable/snack_bar.dart';
import '../matchOdds/match_odds_header.dart';
import '../riskManagementWidgets/risk_management_custom_widget.dart';
import 'fancy_header.dart';
import 'fancy_bet_tile.dart';

class FancyBetScreen extends StatelessWidget {
  final List<OpenFancyData> openFancyData;
  final String userName;
  const FancyBetScreen({super.key, required this.openFancyData, required this.userName});

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
              title: "Fancy Bet",
              action: () {
                if (userName.isNotEmpty) {
                  context.read<FetchOpenFancyBloc>().add(FetchOpenFancy(userName: userName));
                } else {
                  showSnackBar(context, "Please enter a userId", error: true);
                }
              },
            ),
            hb16,

            if (openFancyData.isNotEmpty) ...[
              const FancyHeader(),
              Column(
                children: openFancyData.map((e) {
                  return FancyBetTile(openFancyData: e);
                }).toList(),
              ),
              hb16,
            ],

            // Empty State
            if (openFancyData.isEmpty) Column(children: [const FancyHeader(), NoData()]),
          ],
        ),
      ),
    );
  }
}
