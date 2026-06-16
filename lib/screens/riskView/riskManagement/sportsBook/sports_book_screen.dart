import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web/web.dart' as html;

import '../../../../bloc/fetchBlocs/fetch_open_premium_sport_bloc.dart';
import '../../../../model/premium_sport_model.dart';
import '../../../../reusable/colors.dart';
import '../../../../reusable/formatters.dart';
import '../../../../reusable/highlighted_text_widget.dart';
import '../../../../reusable/sized_box_hw.dart';
import '../../../../reusable/snack_bar.dart';
import '../../../../router/route_paths.dart';
import '../bmView/book_maker_tile.dart';
import '../fancyBets/fancy_header.dart';
import '../fancyBets/grouped_bet_tile.dart';
import '../matchOdds/match_odds_header.dart';
import '../riskManagementWidgets/risk_management_custom_widget.dart';
import 'sports_book_header.dart';

class SportsBookScreen extends StatelessWidget {
  const SportsBookScreen({
    super.key,
    required this.premiumSport,
    required this.userName,
  });
  final List<PremiumSportData> premiumSport;
  final String userName;

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
              title: "Sports Book",
              action: () {
                if (userName.isNotEmpty) {
                  context.read<FetchOpenPremiumSportBloc>().add(FetchOpenPremiumSport(userName: userName));
                } else {
                  showSnackBar(context, "Please enter a userId", error: true);
                }
              },
            ),
            hb16,
            SportsBookHeader(),
            premiumSport.isEmpty
                ? const NoData()
                : Column(
                    children: premiumSport.map((sport) {
                      return SportsBookTile(openSB: sport, userName: userName);
                    }).toList(),
                  ),
          ],
        ),
      ),
    );
  }
}

class SportsBookTile extends StatelessWidget {
  const SportsBookTile({super.key, required this.openSB, required this.userName});
  final String userName;
  final PremiumSportData openSB;

  @override
  Widget build(BuildContext context) {
    return GroupedBetTile<PremiumDateDetail, PremiumDetail>(
      tileType: 'sb',
      sportName: openSB.sport,
      dates: openSB.dateDetail,
      getEvents: (date) => date.details,
      getDate: (date) => date.date,
      sportAction: () {
        final baseUrl = html.window.location.origin;
        final url = '$baseUrl${RoutePaths.manageSportBookReport}?sportName=${eqc(openSB.sport)}&userName=${eqc(userName)}';
        html.window.open(url, '_blank', 'width=1200,height=850,resizable=yes,scrollbars=yes,menubar=no,toolbar=no,location=no,status=no');
      },
      eventRowBuilder: (context, event, isLast, isExpanded, onExpandToggle) {
        return Row(
          children: [
            MarketNameCard(
              isLast: isLast,
              isExpanded: isExpanded,
              eventName: event.eventName,
              type: event.marketName,
            ),
            Container(
              height: 40,
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: white,
                border: Border(
                  left: const BorderSide(color: borderColor),
                  bottom: BorderSide(color: getBottomBorder(isLast)),
                ),
              ),
              width: mmw(context) * 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  HighlightText(
                    formattedAmounts(event.matchedAmount),
                    style: TextStyle(color: event.matchedAmount < 0 ? red : black, fontSize: 12),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
