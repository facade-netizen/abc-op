import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/fetchBlocs/fetch_open_bm_bloc.dart';
import '../../../bloc/fetchBlocs/fetch_open_fancy_bloc.dart';
import '../../../bloc/fetchBlocs/fetch_open_odds_bloc.dart';
import '../../../bloc/fetchBlocs/fetch_open_premium_sport_bloc.dart';
import '../../../bloc/fetchBlocs/fetch_top_exposure_player_bloc.dart';
import '../../../model/open_bm_bets_model.dart';
import '../../../model/open_fancy_bets_model.dart';
import '../../../model/open_odds_bets_model.dart';
import '../../../model/premium_sport_model.dart';
import '../../../model/top_exposure_player_model.dart';
import '../../../reusable/button.dart';
import '../../../reusable/loader.dart';
import '../../../reusable/sized_box_hw.dart';
import '../../../reusable/snack_bar.dart';
import '../../../reusable/style.dart';
import 'bmView/book_maker_screen.dart';
import 'fancyBets/fancy_bet_screen.dart';
import 'matchOdds/match_odds_screen.dart';
import 'sportsBook/other_markets_screen.dart';
import 'sportsBook/sports_book_screen.dart';
import 'riskManagementWidgets/horse_and_greyhound_table.dart';
import 'riskManagementWidgets/risk_management_custom_widget.dart';
import 'riskManagementWidgets/top10_player_table.dart';

class RiskManagementScreen extends StatefulWidget {
  const RiskManagementScreen({super.key});

  @override
  State<RiskManagementScreen> createState() => _RiskManagementScreenState();
}

class _RiskManagementScreenState extends State<RiskManagementScreen> {
  TextEditingController userIdController = TextEditingController();
  // Data states
  List<OpenBMData> openBMData = [];
  List<OpenOddsData> openOddsData = [];
  List<OpenOddsData> otherMarkets = [];
  List<OpenFancyData> openFancyData = [];
  List<PremiumSportData> premiumSport = [];

  /// Clear all data lists (called on failure)
  void clearAllData() {
    setState(() {
      openBMData.clear();
      openOddsData.clear();
      otherMarkets.clear();
      openFancyData.clear();
      premiumSport.clear();
    });
  }

  /// Fetch all dependent data after top exposure success
  void fetchDependentData(String username) {
    context.read<FetchOpenBMBloc>().add(FetchOpenBM(userName: username));
    context.read<FetchOpenOddsBloc>().add(FetchOpenOdds(userName: username));
    context.read<FetchOpenFancyBloc>().add(FetchOpenFancy(userName: username));
    context.read<FetchOpenPremiumSportBloc>().add(FetchOpenPremiumSport(userName: username));
  }

  /// Main fetch function triggered by user
  void fetchAllData() {
    final username = userIdController.text.trim();
    if (username.isEmpty) {
      showSnackBar(context, "Please enter a userId", error: true);
      clearAllData(); // Clear data if username is empty
    } else {
      clearAllData(); // Clear old data before fetching new
      context.read<FetchTopExposurePlayerBloc>().add(FetchTopExposurePlayer(userName: username));
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);

    return MultiBlocListener(
      listeners: [
        // Listener for Top Exposure Player Bloc
        BlocListener<FetchTopExposurePlayerBloc, FetchTopExposurePlayerState>(
          listener: (context, state) {
            if (state is FetchTopExposurePlayerSuccess) {
              // Only fetch dependent data if both lists are non-empty
              if (state.topBalance.isNotEmpty && state.topExposure.isNotEmpty) {
                final username = userIdController.text.trim();
                fetchDependentData(username);
              } else {
                showSnackBar(context, "No data found for this user", error: true);
                clearAllData();
              }
            } else if (state is FetchTopExposurePlayerFailure) {
              // Clear all data on failure
              clearAllData();
            }
          },
        ),

        // Listener for Open BM Bloc
        BlocListener<FetchOpenBMBloc, FetchOpenBMState>(
          listener: (context, state) {
            if (state is FetchOpenBMSuccess) {
              setState(() => openBMData = state.openBMData);
            } else if (state is FetchOpenBMFailure) {
              setState(() => openBMData.clear());
            }
          },
        ),

        // Listener for Open Odds Bloc
        BlocListener<FetchOpenOddsBloc, FetchOpenOddsState>(
          listener: (context, state) {
            if (state is FetchOpenOddsSuccess) {
              setState(() {
                openOddsData = state.openOddsData;
                otherMarkets = state.otherMarkets;
              });
            } else if (state is FetchOpenOddsFailure) {
              setState(() {
                openOddsData.clear();
                otherMarkets.clear();
              });
            }
          },
        ),

        // Listener for Open Fancy Bloc
        BlocListener<FetchOpenFancyBloc, FetchOpenFancyState>(
          listener: (context, state) {
            if (state is FetchOpenFancySuccess) {
              setState(() => openFancyData = state.openFancyData);
            } else if (state is FetchOpenFancyFailure) {
              setState(() => openFancyData.clear());
            }
          },
        ),

        // Listener for Open Premium Sport Bloc
        BlocListener<FetchOpenPremiumSportBloc, FetchOpenPremiumSportState>(
          listener: (context, state) {
            if (state is FetchOpenPremiumSportSuccess) {
              setState(() => premiumSport = state.data);
            } else if (state is FetchOpenPremiumSportFailure) {
              setState(() => premiumSport.clear());
            }
          },
        ),
      ],
      child: BlocBuilder<FetchTopExposurePlayerBloc, FetchTopExposurePlayerState>(
        builder: (context, tepState) {
          // Extract data from states using when pattern
          List<TopPlayerExposureData> topBalance = [];
          List<TopPlayerExposureData> topExposure = [];

          if (tepState is FetchTopExposurePlayerSuccess) {
            topBalance = tepState.topBalance;
            topExposure = tepState.topExposure;
          }

          return BlocBuilder<FetchOpenOddsBloc, FetchOpenOddsState>(
            builder: (context, oddsState) {
              if (oddsState is FetchOpenOddsSuccess) {
                openOddsData = oddsState.openOddsData;
                otherMarkets = oddsState.otherMarkets;
              } else if (oddsState is FetchOpenOddsFailure) {
                openOddsData = [];
                otherMarkets = [];
              }

              return BlocBuilder<FetchOpenFancyBloc, FetchOpenFancyState>(
                builder: (context, fancyState) {
                  if (fancyState is FetchOpenFancySuccess) {
                    openFancyData = fancyState.openFancyData;
                  } else if (fancyState is FetchOpenFancyFailure) {
                    openFancyData = [];
                  }

                  return BlocBuilder<FetchOpenBMBloc, FetchOpenBMState>(
                    builder: (context, bmState) {
                      if (bmState is FetchOpenBMSuccess) {
                        openBMData = bmState.openBMData;
                      } else if (bmState is FetchOpenBMFailure) {
                        openBMData = [];
                      }

                      return BlocBuilder<FetchOpenPremiumSportBloc, FetchOpenPremiumSportState>(
                        builder: (context, sportState) {
                          if (sportState is FetchOpenPremiumSportSuccess) {
                            premiumSport = sportState.data;
                          } else if (sportState is FetchOpenPremiumSportFailure) {
                            premiumSport = [];
                          }

                          return Stack(
                            children: [
                              SizedBox(
                                width: size.width,
                                height: size.height,
                                child: SingleChildScrollView(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // User ID Input Field
                                        SizedBox(
                                          height: 30,
                                          width: 160,
                                          child: TextFormField(
                                            controller: userIdController,
                                            decoration: tfInputDecoration.copyWith(hintText: "enter agent userId...", contentPadding: const EdgeInsets.symmetric(horizontal: 10)),
                                            onFieldSubmitted: (_) => fetchAllData(),
                                          ),
                                        ),
                                        hb10,

                                        // Submit Button
                                        CustomECTAButton(title: 'Submit', action: fetchAllData),
                                        hb20,

                                        // Risk Management Header
                                        RiskHeader(type: 1, title: "Risk Management Summary", action: fetchAllData),
                                        hb16,

                                        // Top 10 & Racing Table Row
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Top10TabScreen(
                                                key: ValueKey("top10_${userIdController.text.trim()}_${topBalance.length}"),
                                                topBalance: topBalance,
                                                topExposure: topExposure,
                                              ),
                                            ),
                                            wb20,
                                            Expanded(child: HorseAndGreyhoundTable(key: const ValueKey("horse_greyhound_table"))),
                                          ],
                                        ),
                                        hb16,

                                        // Match Odds Screen
                                        MatchOddsScreen(
                                          key: ValueKey("match_odds_${userIdController.text.trim()}_${openOddsData.length}"),
                                          openOddsData: openOddsData.isEmpty ? [] : openOddsData,
                                          userName: userIdController.text.trim(),
                                        ),
                                        hb16,

                                        // Book Maker Screen
                                        BookMakerScreen(
                                          key: ValueKey("bookmaker_${userIdController.text.trim()}_${openBMData.length}"),
                                          openBMData: openBMData.isEmpty ? [] : openBMData,
                                          userName: userIdController.text.trim(),
                                        ),
                                        hb16,

                                        // Fancy Bet Screen
                                        FancyBetScreen(
                                          key: ValueKey("fancy_${userIdController.text.trim()}_${openFancyData.length}"),
                                          openFancyData: openFancyData.isEmpty ? [] : openFancyData,
                                          userName: userIdController.text.trim(),
                                        ),
                                        hb16,

                                        // Sports Book Screen
                                        SportsBookScreen(
                                          key: ValueKey("sportsbook_${userIdController.text.trim()}_${premiumSport.length}"),
                                          premiumSport: premiumSport.isEmpty ? [] : premiumSport,
                                          userName: userIdController.text.trim(),
                                        ),
                                        hb16,

                                        // Other Markets Screen
                                        OtherMarketsScreen(
                                          key: ValueKey("other_markets_${userIdController.text.trim()}_${otherMarkets.length}"),
                                          otherMarkets: otherMarkets.isEmpty ? [] : otherMarkets,
                                          userName: userIdController.text.trim(),
                                        ),
                                        hb16,
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              // Loading Overlay
                              if (tepState is FetchTopExposurePlayerProgress ||
                                  oddsState is FetchOpenOddsProgress ||
                                  fancyState is FetchOpenFancyProgress ||
                                  bmState is FetchOpenBMProgress ||
                                  sportState is FetchOpenPremiumSportProgress)
                                Positioned.fill(
                                  child: Center(child: LoaderContainerWithMessage(message: "Loading...")),
                                ),
                            ],
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    userIdController.dispose();
    super.dispose();
  }
}
