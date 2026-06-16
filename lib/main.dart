import 'dart:async';

// ignore: depend_on_referenced_packages
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import 'apis/apiRepositories/accountsRepo/account_api_repository.dart';
import 'apis/apiRepositories/authRepo/auth_api_repository.dart';
import 'apis/apiRepositories/cgRepo/cg_api_repository.dart';
import 'apis/apiRepositories/ordersRepo/orders_api_repository.dart';
import 'apis/apiRepositories/settleManageRepo/ms_api_repository.dart';
import 'bloc/authBlocs/change_password_bloc.dart';
import 'bloc/authBlocs/reset_password_bloc.dart';
import 'bloc/authBlocs/update_user_access_bloc.dart';
import 'bloc/authBlocs/user_changed_bloc.dart';
import 'bloc/authBlocs/user_ip_bloc.dart';
import 'bloc/authBlocs/user_login_bloc.dart';
import 'bloc/authBlocs/user_logout_bloc.dart';
import 'bloc/fetchBlocs/fetch_agency_bloc.dart';
import 'bloc/fetchBlocs/fetch_all_wl_bloc.dart';
import 'bloc/fetchBlocs/fetch_balance_summary_log_bloc.dart';
import 'bloc/fetchBlocs/fetch_betlist_bloc.dart';
import 'bloc/fetchBlocs/fetch_betlist_live_bloc.dart';
import 'bloc/fetchBlocs/fetch_betlist_live_event_bloc.dart';
import 'bloc/fetchBlocs/fetch_bm_book_bloc.dart';
import 'bloc/fetchBlocs/fetch_cg_balance_history_bloc.dart';
import 'bloc/fetchBlocs/fetch_cg_history_bloc.dart';
import 'bloc/fetchBlocs/fetch_change_pass_logs_bloc.dart';
import 'bloc/fetchBlocs/fetch_credit_limit_logs_bloc.dart';
import 'bloc/fetchBlocs/fetch_current_user_info_bloc.dart';
import 'bloc/fetchBlocs/fetch_fancy_book_bloc.dart';
import 'bloc/fetchBlocs/fetch_lt_report_bloc.dart';
import 'bloc/fetchBlocs/fetch_market_pl_bloc.dart';
import 'bloc/fetchBlocs/fetch_open_bm_bloc.dart';
import 'bloc/fetchBlocs/fetch_open_fancy_bloc.dart';
import 'bloc/fetchBlocs/fetch_open_odds_bloc.dart';
import 'bloc/fetchBlocs/fetch_open_premium_sport_bloc.dart';
import 'bloc/fetchBlocs/fetch_order_event_bloc.dart';
import 'bloc/fetchBlocs/fetch_player_bet_history_bloc.dart';
import 'bloc/fetchBlocs/fetch_player_profit_and_loss_bloc.dart';
import 'bloc/fetchBlocs/fetch_premium_runner_wise_report_bloc.dart';
import 'bloc/fetchBlocs/fetch_risk_monitoring_bloc.dart';
import 'bloc/fetchBlocs/fetch_runner_wise_report_bloc.dart';
import 'bloc/fetchBlocs/fetch_sb_betlist_bloc.dart';
import 'bloc/fetchBlocs/fetch_settle_history_bloc.dart';
import 'bloc/fetchBlocs/fetch_sport_wise_report_bloc.dart';
import 'bloc/fetchBlocs/fetch_sports_book_bloc.dart';
import 'bloc/fetchBlocs/fetch_sports_book_pl_bloc.dart';
import 'bloc/fetchBlocs/fetch_top_exposure_player_bloc.dart';
import 'bloc/fetchBlocs/fetch_transferred_logs_bloc.dart';
import 'bloc/fetchBlocs/fetch_user_account_statement_logs_bloc.dart';
import 'bloc/fetchBlocs/fetch_user_activity_logs_bloc.dart';
import 'bloc/fetchBlocs/fetch_user_ispip_logs_bloc.dart';
import 'bloc/fetchBlocs/fetch_user_logs_bloc.dart';
import 'bloc/signalRBloc/signalRStreamers/fancy_signalr_streamer.dart';
import 'bloc/signalRBloc/signalRStreamers/odds_signalr_streamer.dart';
import 'bloc/signalRBloc/signalr_event_listener_bloc.dart';
import 'constants/app_constant.dart';
import 'localDb/hive_config.dart';
import 'reusable/theme_data.dart';
import 'router/app_router.dart';
import 'router/auth_notifier.dart';
import 'router/token_expiry_notifier.dart';

void main() async {
  // Run the app inside a Zone that intercepts all print() calls.
  // ensureInitialized + runApp must be in the same zone to avoid zone mismatch.
  runZonedGuarded(
    () async {
      // PathUrlStrategy: clean URLs without # (requires server to serve index.html for all paths)
      setUrlStrategy(PathUrlStrategy());

      WidgetsFlutterBinding.ensureInitialized();
      await AppHiveConfig.init();

      runApp(ChangeNotifierProvider(create: (_) => TokenExpiryNotifier()..initFromStorage(), child: const MyApp()));
    },
    (error, stack) {
      if (kDebugMode) {
        debugPrint("[App Zone Error ]>>  $error \n[App Zone Stacktrace]: $stack");
      }
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => CGApiRepository()),
        RepositoryProvider(create: (_) => AuthApiRepository()),
        RepositoryProvider(create: (_) => OrdersApiRepository()),
        RepositoryProvider(create: (_) => SettleApiRepository()),
        RepositoryProvider(create: (_) => AccountApiRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => UserIPBloc()),
          BlocProvider(create: (context) => UserLoginBloc()),
          BlocProvider(create: (context) => UserLogoutBloc()),
          BlocProvider(create: (context) => FetchAllWlBloc()),
          BlocProvider(create: (context) => ResetPasswordBloc()),
          BlocProvider(create: (context) => UserAuthChangesBloc()),
          BlocProvider(create: (context) => OddsSignalRStreamerBloc()),
          BlocProvider(create: (context) => FancySignalRStreamerBloc()),
          BlocProvider(create: (context) => SignalREventListenerBloc()),
          BlocProvider(create: (context) => FetchCGHistoryBloc(context.read<CGApiRepository>())),
          BlocProvider(create: (context) => FetchSbBetListBloc(context.read<CGApiRepository>())),
          BlocProvider(create: (context) => FetchSportsBookBloc(context.read<CGApiRepository>())),
          BlocProvider(create: (context) => FetchSportBookPlBloc(context.read<CGApiRepository>())),
          BlocProvider(create: (context) => FetchOpenBMBloc(context.read<OrdersApiRepository>())),
          BlocProvider(create: (context) => FetchBMBookBloc(context.read<OrdersApiRepository>())),
          BlocProvider(create: (context) => ChangePasswordBloc(context.read<AuthApiRepository>())),
          BlocProvider(create: (context) => FetchAgencyBloc(context.read<AccountApiRepository>())),
          BlocProvider(create: (context) => FetchLtReportBloc(context.read<OrdersApiRepository>())),
          BlocProvider(create: (context) => FetchMarketPlBloc(context.read<OrdersApiRepository>())),
          BlocProvider(create: (context) => FetchOpenOddsBloc(context.read<OrdersApiRepository>())),
          BlocProvider(create: (context) => UpdateUserAccessBloc(context.read<AuthApiRepository>())),
          BlocProvider(create: (context) => FetchUserLogsBloc(context.read<AccountApiRepository>())),
          BlocProvider(create: (context) => FetchFancyBookBloc(context.read<OrdersApiRepository>())),
          BlocProvider(create: (context) => FetchOpenFancyBloc(context.read<OrdersApiRepository>())),
          BlocProvider(create: (context) => FetchOpenPremiumSportBloc(context.read<CGApiRepository>())),
          BlocProvider(create: (context) => FetchRiskMonitoringBloc(context.read<OrdersApiRepository>())),
          BlocProvider(create: (context) => FetchCGBalanceHistoryBloc(context.read<CGApiRepository>())),
          BlocProvider(create: (context) => FetchSettleHistoryBloc(context.read<SettleApiRepository>())),
          BlocProvider(create: (context) => FetchUserIspIpLogsBloc(context.read<AccountApiRepository>())),
          BlocProvider(create: (context) => FetchRunnerWiseReportBloc(context.read<OrdersApiRepository>())),
          BlocProvider(create: (context) => FetchSportWiseReportBloc(context.read<OrdersApiRepository>())),
          BlocProvider(create: (context) => FetchTransferredLogsBloc(context.read<AccountApiRepository>())),
          BlocProvider(create: (context) => FetchChangePassLogsBloc(context.read<AccountApiRepository>())),
          BlocProvider(create: (context) => FetchCreditLimitLogsBloc(context.read<AccountApiRepository>())),
          BlocProvider(create: (context) => FetchPlayerBetHistoryBloc(context.read<OrdersApiRepository>())),
          BlocProvider(create: (context) => FetchBalanceSummaryLogBloc(context.read<OrdersApiRepository>())),
          BlocProvider(create: (context) => FetchUserActivityLogsBloc(context.read<AccountApiRepository>())),
          BlocProvider(create: (context) => FetchTopExposurePlayerBloc(context.read<OrdersApiRepository>())),
          BlocProvider(create: (context) => FetchPremiumRunnerWiseReportBloc(context.read<CGApiRepository>())),
          BlocProvider(create: (context) => FetchPlayerProfitAndLossBloc(context.read<OrdersApiRepository>())),
          BlocProvider(create: (context) => FetchCurrentUserDetailsBloc(context.read<AccountApiRepository>())),
          BlocProvider(create: (context) => FetchUserAccountStatementLogsBloc(context.read<AccountApiRepository>())),
          BlocProvider(create: (context) => FetchBetListBloc(context.read<OrdersApiRepository>(), context.read<CGApiRepository>())),
          BlocProvider(create: (context) => FetchBetListLiveBloc(context.read<OrdersApiRepository>(), context.read<CGApiRepository>())),
          BlocProvider(create: (context) => FetchOrderEventsBloc(context.read<OrdersApiRepository>(), context.read<CGApiRepository>())),
          BlocProvider(create: (context) => FetchBetListLiveEventsBloc(context.read<OrdersApiRepository>(), context.read<CGApiRepository>())),
        ],
        child: Builder(
          builder: (context) {
            // Fire initial auth check & IP detection
            context.read<UserIPBloc>().add(UserIP());
            context.read<UserAuthChangesBloc>().add(StartUserChangeListener());

            final router = createAppRouter(context.read<UserAuthChangesBloc>());

            return TokenExpiryListener(
              child: WebAuthSync(
                child: MaterialApp.router(
                  debugShowCheckedModeBanner: false,
                  title: AppConstants.appTitle,
                  theme: themeData,
                  routerConfig: router,
                  supportedLocales: const [Locale('en')],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
