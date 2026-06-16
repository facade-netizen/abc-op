import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/authBlocs/update_user_access_bloc.dart';
import '../bloc/fetchBlocs/fetch_agency_bloc.dart';
import '../bloc/fetchBlocs/fetch_balance_summary_log_bloc.dart';
import '../bloc/fetchBlocs/fetch_betlist_bloc.dart';
import '../bloc/fetchBlocs/fetch_cg_balance_history_bloc.dart';
import '../bloc/fetchBlocs/fetch_cg_history_bloc.dart';
import '../bloc/fetchBlocs/fetch_change_pass_logs_bloc.dart';
import '../bloc/fetchBlocs/fetch_credit_limit_logs_bloc.dart';
import '../bloc/fetchBlocs/fetch_market_pl_bloc.dart';
import '../bloc/fetchBlocs/fetch_player_bet_history_bloc.dart';
import '../bloc/fetchBlocs/fetch_player_profit_and_loss_bloc.dart';
import '../bloc/fetchBlocs/fetch_risk_monitoring_bloc.dart';
import '../bloc/fetchBlocs/fetch_sb_betlist_bloc.dart';
import '../bloc/fetchBlocs/fetch_settle_history_bloc.dart';
import '../bloc/fetchBlocs/fetch_sports_book_bloc.dart';
import '../bloc/fetchBlocs/fetch_sports_book_pl_bloc.dart';
import '../bloc/fetchBlocs/fetch_top_exposure_player_bloc.dart';
import '../bloc/fetchBlocs/fetch_transferred_logs_bloc.dart';
import '../bloc/fetchBlocs/fetch_user_account_statement_logs_bloc.dart';
import '../bloc/fetchBlocs/fetch_user_activity_logs_bloc.dart';
import '../bloc/fetchBlocs/fetch_user_ispip_logs_bloc.dart';
import '../bloc/fetchBlocs/fetch_user_logs_bloc.dart';
import '../reusable/snack_bar.dart';

class ShowAllErrorMsgScreen extends StatelessWidget {
  const ShowAllErrorMsgScreen({super.key, this.child});
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<FetchBetListBloc, FetchBetListState>(
          listener: (context, state) {
            if (state is FetchBetListFailure) {
              showSnackBar(context, state.error, error: true);
            }
          },
        ),
        BlocListener<FetchTopExposurePlayerBloc, FetchTopExposurePlayerState>(
          listener: (context, state) {
            if (state is FetchTopExposurePlayerFailure) {
              showSnackBar(context, state.error, error: true);
            }
          },
        ),
        BlocListener<FetchMarketPlBloc, FetchMarketPlState>(
          listener: (context, state) {
            if (state is FetchMarketPlFailure) {
              showSnackBar(context, state.error, error: true);
            }
          },
        ),
        BlocListener<FetchPlayerProfitAndLossBloc, FetchPlayerProfitAndLossState>(
          listener: (context, state) {
            if (state is FetchPlayerProfitAndLossFailure) {
              showSnackBar(context, state.error, error: true);
            }
          },
        ),
        BlocListener<FetchCGHistoryBloc, FetchCGHistoryState>(
          listener: (context, state) {
            if (state is FetchCGHistoryFailure) {
              showSnackBar(context, state.error, error: true);
            }
          },
        ),
        BlocListener<FetchPlayerBetHistoryBloc, FetchPlayerBetHistoryState>(
          listener: (context, state) {
            if (state is FetchPlayerBetHistoryFailure) {
              showSnackBar(context, state.error, error: true);
            }
          },
        ),
        BlocListener<FetchSettleHistoryBloc, FetchSettleHistoryState>(
          listener: (context, state) {
            if (state is FetchSettleHistoryFailure) {
              showSnackBar(context, state.error, error: true);
            }
          },
        ),
        BlocListener<FetchUserLogsBloc, FetchUserLogsState>(
          listener: (context, uls) {
            if (uls is FetchUserLogsFailure) {
              showSnackBar(context, uls.error, error: true);
            }
          },
        ),
        BlocListener<FetchUserActivityLogsBloc, FetchUserActivityLogsState>(
          listener: (context, als) {
            if (als is FetchUserActivityLogsFailure) {
              showSnackBar(context, als.error.toString(), error: true);
            }
          },
        ),
        BlocListener<FetchCGBalanceHistoryBloc, FetchCGBalanceHistoryState>(
          listener: (context, chl) {
            if (chl is FetchCGBalanceHistoryFailure) {
              showSnackBar(context, chl.error.toString(), error: true);
            }
          },
        ),
        BlocListener<FetchUserAccountStatementLogsBloc, FetchUserAccountStatementLogsState>(
          listener: (context, chl) {
            if (chl is FetchUserAccountStatementLogsFailure) {
              showSnackBar(context, chl.error.toString(), error: true);
            }
          },
        ),
        BlocListener<FetchAgencyBloc, FetchAgencyState>(
          listener: (context, fas) {
            if (fas is FetchAgencyFailure) {
              showSnackBar(context, fas.error.toString(), error: true);
            }
          },
        ),
        BlocListener<FetchSportsBookBloc, FetchSportsBookState>(
          listener: (context, fas) {
            if (fas is FetchSportsBookFailure) {
              showSnackBar(context, fas.error.toString(), error: true);
            }
          },
        ),
        BlocListener<FetchUserIspIpLogsBloc, FetchUserIspIpLogsState>(
          listener: (context, fas) {
            if (fas is FetchUserIspIpLogsFailure) {
              showSnackBar(context, fas.error.toString(), error: true);
            }
          },
        ),
        BlocListener<FetchBalanceSummaryLogBloc, FetchBalanceSummaryLogState>(
          listener: (context, fas) {
            if (fas is FetchBalanceSummaryLogFailure) {
              showSnackBar(context, fas.error.toString(), error: true);
            }
          },
        ),
        BlocListener<FetchChangePassLogsBloc, FetchChangePassLogsState>(
          listener: (context, fas) {
            if (fas is FetchChangePassLogsFailure) {
              showSnackBar(context, fas.error.toString(), error: true);
            }
          },
        ),
        BlocListener<FetchCreditLimitLogsBloc, FetchCreditLimitLogsState>(
          listener: (context, fas) {
            if (fas is FetchCreditLimitLogsFailure) {
              showSnackBar(context, fas.error.toString(), error: true);
            }
          },
        ),
        BlocListener<FetchTransferredLogsBloc, FetchTransferredLogsState>(
          listener: (context, fas) {
            if (fas is FetchTransferredLogsFailure) {
              showSnackBar(context, fas.error.toString(), error: true);
            }
          },
        ),
        BlocListener<FetchSportBookPlBloc, FetchSportBookPlState>(
          listener: (context, fas) {
            if (fas is FetchSportBookPlFailure) {
              showSnackBar(context, fas.error.toString(), error: true);
            }
          },
        ),
        BlocListener<FetchSbBetListBloc, FetchSbBetListState>(
          listener: (context, fas) {
            if (fas is FetchSbBetListFailure) {
              showSnackBar(context, fas.error.toString(), error: true);
            }
          },
        ),
        BlocListener<FetchRiskMonitoringBloc, FetchRiskMonitoringState>(
          listener: (context, fas) {
            if (fas is FetchRiskMonitoringFailure) {
              showSnackBar(context, fas.error.toString(), error: true);
            }
          },
        ),
        BlocListener<UpdateUserAccessBloc, UpdateUserAccessState>(
          listener: (context, fas) {
            if (fas is UpdateUserAccessSuccess) {
              final errors = fas.results.where((result) => !result.isSuccess).toList();
              final successes = fas.results.where((result) => result.isSuccess).toList();
              if (successes.isNotEmpty) {
                showSnackBar(context, 'User access updated successfully.');
              }
              if (errors.isNotEmpty) {
                for (int i = 0; i < errors.length; i++) {
                  final result = errors[i];
                  Future.delayed(Duration(milliseconds: i * 2500), () {
                    if (context.mounted) {
                      showSnackBar(context, result.message, error: !result.isSuccess);
                    }
                  });
                }
              }
            }
            if (fas is UpdateUserAccessFailure) {
              showSnackBar(context, fas.error.toString(), error: true);
            }
          },
        ),
      ],
      child: child ?? const SizedBox.shrink(),
    );
  }
}
