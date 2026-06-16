import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../reusable/highlighted_text_widget.dart';
import '../screens/actionLog/action_log_screen.dart';
import '../screens/auth/change_password_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/reset_password_screen.dart';
import '../screens/auth/unauthorized_screen.dart';
import '../screens/agency/agency_screen.dart';
import '../screens/logView/agencyLogHistory/agency_history_log_screen.dart';
import '../screens/logView/agencyLogHistory/balance_log_screen.dart';
import '../screens/logView/agencyLogHistory/op_action_log_screen.dart';
import '../screens/logView/userActivityLog/user_activity_log_view.dart';
import '../screens/reportsView/betList/bet_list_details_screen.dart';
import '../screens/reportsView/betList/bet_list_screen.dart';
import '../screens/reportsView/betListLive/bet_list_live_screen.dart';
import '../screens/reportsView/bettingHistory/betting_history_screen.dart';
import '../screens/reportsView/marketPl/market_pl_screen.dart';
import '../screens/reportsView/marketSettleStatus/market_settle_status_live_screen.dart';
import '../screens/reportsView/marketSettleStatus/market_settle_status_log_screen.dart';
import '../screens/reportsView/profitAndLoss/profit_and_loss_screen.dart';
import '../screens/riskView/riskManagement/sportWiseReport/sport_wise_report_view.dart';
import '../screens/riskView/riskManagement/sportsBook/sb_runner_wise_report_tile.dart';
import '../screens/riskView/riskManagement/sportsBook/sport_book_report_tile.dart';
import '../screens/riskView/riskManagement/user_report_screen.dart';
import '../screens/riskView/riskManagement/risk_management_screen.dart';
import '../screens/riskView/riskMonitoring/risk_monitoring_screen.dart';
import '../screens/riskView/riskManagement/eventPlBook/event_book_view.dart';
import '../screens/riskView/riskManagement/runnerWiseReport/runner_wise_report_view.dart';

/// Centralized route path definitions for the application
abstract class RoutePaths {
  // Private constructor to prevent instantiation
  RoutePaths._();

  // ==================== Authentication Routes ====================

  /// Login page route
  static const String login = '/login';

  /// Unauthorized access page route
  static const String unauthorized = '/unauthorized';

  /// Password reset page route with username parameter
  static const String resetPassword = '/reset-password/:username';

  // ==================== Dashboard Shell Route ====================

  /// Dashboard shell root route
  static const String manage = '/manage';

  // ==================== Risk Management Routes ====================

  /// Risk management dashboard
  static const String manageRiskManagement = '/manage/risk-management';

  /// Risk monitoring page
  static const String manageRiskMonitoring = '/manage/risk-monitoring';

  // ==================== Report Routes ====================

  /// Market profit/loss report
  static const String manageMarketProfitLoss = '/manage/market-profit-loss';

  /// Overall profit/loss report
  static const String manageProfitLoss = '/manage/profit-loss';

  /// Betting history report
  static const String manageBettingHistory = '/manage/betting-history';

  /// Combined user report with Bet History and Profit/Loss tabs
  static const String manageUserReport = '/manage/user-report';

  /// Bet list report
  static const String manageBetList = '/manage/betlist';

  /// Live bet list
  static const String manageBetListLive = '/manage/betlist-live';

  /// Bet list details
  static const String manageBetListDetail = '/manage/betlist-detail';

  /// Live market settle status
  static const String manageMarketSettleStatusLive = '/manage/market-settle-status-live';

  /// Market settle status log
  static const String manageMarketSettleStatusLog = '/manage/market-settle-status-log';

  /// Event book view route
  static const String manageEventBookView = '/manage/event-book-view';
  
  /// Runner wise report view route
  static const String manageRunnerWiseReport = '/manage/runner-wise-report';

  ///sport wise report view route
  static const String manageSportWiseReport = '/manage/sport-wise-report';

  /// Sport book report view route
  static const String manageSportBookReport = '/manage/sport-book-report';

  /// Sport book runner wise report view route
  static const String manageSportBookRunnerWiseReport = '/manage/sport-book-runner-wise-report';

  // ==================== Admin Routes ====================

  /// Agency management
  static const String manageAgency = '/manage/agency';

  // ==================== Log Routes ====================

  /// Balance transaction log
  static const String manageBalanceLog = '/manage/balance-log';

  /// Agency history log
  static const String manageAgencyHistory = '/manage/agency-history';

  /// Operator action log
  static const String manageOpActionLog = '/manage/op-action-log';

  /// User activity log
  static const String manageUserActivityLog = '/manage/user-activity-log';

  /// API action log
  static const String manageActionLog = '/manage/action-log';

  // ==================== Utility Routes ====================
  /// Change password page
  static const String manageChangePassword = '/manage/change-password';

  // ==================== Route Configuration ====================
  static final List<RouteConfig> routeConfigs = [
    RouteConfig(login, 'login', 'OP System', (c, s) => const LoginScreen(), isPublic: true),
    RouteConfig(unauthorized, 'unauthorized', 'Unauthorized', (c, s) => const UnAuthorizedScreen(), isPublic: true),
    RouteConfig(
      resetPassword,
      'resetPassword',
      'Reset Password',
      (c, s) {
        final userName = s.pathParameters['username'] ?? '';
        return PasswordResetScreen(userName: userName);
      },
      isPublic: true,
      titleBuilder: (s) {
        final userName = s.pathParameters['username'] ?? '';
        return userName.isNotEmpty ? 'Reset Password - $userName' : 'Reset Password';
      },
    ),
    RouteConfig(manage, 'manage', 'OP System', (c, s) => const SizedBox()),
    RouteConfig(manageRiskManagement, 'riskManagement', 'Risk Management Summary', (c, s) => const RiskManagementScreen()),
    RouteConfig(manageRiskMonitoring, 'riskMonitoring', 'Risk Monitoring', (c, s) => const RiskMonitoringScreen()),
    RouteConfig(manageChangePassword, 'changePassword', 'Change Password', (c, s) => const ChangePasswordScreen()),
    RouteConfig(manageMarketProfitLoss, 'marketProfitLoss', 'Market Profit Loss', (c, s) => const MarketPlScreen()),
    RouteConfig(manageProfitLoss, 'profitLoss', 'Profit and Loss', (c, s) {
      final selectedUser = s.queryParameters['userName'] ?? '';
      return ProfitAndLossScreen(selectedUser: selectedUser);
    }),
    RouteConfig(manageBettingHistory, 'bettingHistory', 'Betting History', (c, s) {
      final selectedUser = s.queryParameters['userName'] ?? '';
      return BettingHistoryScreen(selectedUser: selectedUser);
    }),
    RouteConfig(manageEventBookView, 'eventBookView', 'Event Book', (c, s) {
      final eventName = s.queryParameters['eventName'] ?? '';
      final userName = s.queryParameters['userName'] ?? '';
      final eventType = s.queryParameters['eventType'] ?? '';
      final marketId = s.queryParameters['marketId'] ?? '';
      return EventBookView(
        eventName: eventName,
        eventType: eventType,
        marketId: marketId,
        userName: userName,
      );
    }),
    RouteConfig(manageRunnerWiseReport, 'runnerWiseReport', 'Runner Wise Report', (c, s) {
      final marketId = s.queryParameters['marketId'] ?? '';
      final userName = s.queryParameters['userName'] ?? '';
      final runnerId = s.queryParameters['runnerId'] ?? '';
      final eventType = s.queryParameters['eventType'] ?? '';
      return RunnerWiseReportView(
        marketId: marketId,
        runnerId: runnerId,
        eventType: eventType,
        userName: userName,
      );
    }),
    RouteConfig(manageSportWiseReport, 'sportWiseReport', 'Sport Wise Report', (c, s) {
      final sid = s.queryParameters['sid'] ?? '';
      final userName = s.queryParameters['userName'] ?? '';
      final screenType = s.queryParameters['screenType'] ?? '';
      final eventId = s.queryParameters['eventId'] ?? '';
      final bettingTypeStr = s.queryParameters['bettingType'] ?? '0';
      final bettingType = int.tryParse(bettingTypeStr) ?? 0;
      return SportWiseReportView(
        sid: sid,
        eventId: eventId,
        bettingType: bettingType,
        screenType: screenType,
        userName: userName,
      );
    }),
    RouteConfig(manageUserReport, 'userReport', 'User Report', (c, s) {
      final selectedUser = s.queryParameters['userName'] ?? '';
      return UserReportScreen(selectedUser: selectedUser);
    }),
    RouteConfig(manageSportBookReport, 'sportBookReport', 'Sport Book Report', (c, s) {
      final sportName = s.queryParameters['sportName'] ?? '';
      final userName = s.queryParameters['userName'] ?? '';
      return SportBookReportView(sportName: sportName, userName: userName);
    }),
    RouteConfig(manageSportBookRunnerWiseReport, 'sportBookRunnerWiseReport', 'Sport Book Runner Wise Report', (c, s) {
      final marketId = s.queryParameters['marketId'] ?? '';
      final runnerName = s.queryParameters['runnerName'] ?? '';
      final marketName = s.queryParameters['marketName'] ?? '';
      final userName = s.queryParameters['userName'] ?? '';
      return SbRunnerWiseReportView(
        marketId: marketId,
        runnerName: runnerName,
        marketName: marketName,
        userName: userName,
      );
    }),
    RouteConfig(manageBetList, 'betList', 'Bet List', (c, s) => const BetListScreen()),
    RouteConfig(manageBetListLive, 'betListLive', 'Bet List Live', (c, s) => const BetListLiveScreen()),
    RouteConfig(manageBetListDetail, 'betListDetail', 'Bet List Detail', (c, s) => const BetListDetailsScreen()),
    RouteConfig(manageMarketSettleStatusLive, 'marketSettleStatusLive', 'Market Settle Status Live', (c, s) => const MarketSettleStatusLiveScreen()),
    RouteConfig(manageMarketSettleStatusLog, 'marketSettleStatusLog', 'Market Settle Status Log', (c, s) => const MarketSettleStatusLogScreen()),
    RouteConfig(manageAgency, 'agency', 'Agency', (c, s) => const AgencyScreen()),
    RouteConfig(manageBalanceLog, 'balanceLog', 'Balance Log', (c, s) => const BalanceLogScreen()),
    RouteConfig(manageAgencyHistory, 'agencyHistory', 'Agency History', (c, s) => const AgencyHistoryLogScreen()),
    RouteConfig(manageOpActionLog, 'opActionLog', 'Op Action Log', (c, s) => const OpActionLogScreen()),
    RouteConfig(manageUserActivityLog, 'userActivityLog', 'User Activity Log', (c, s) => const UserActivityLogView()),
    RouteConfig(manageActionLog, 'actionLog', 'Action Log', (c, s) => const ActionLogScreen()),
  ];

  static final Map<String, String> pageNameToRoute = {for (final config in routeConfigs) config.title: config.path};

  static final Map<String, String> routeToPageName = {for (final config in routeConfigs) config.path: config.title};

  // Mapping of page names to their routes
  static const Map<String, String> pageLabelAliases = {
    "Risk Management": RoutePaths.manageRiskManagement,
    "Risk Monitoring": RoutePaths.manageRiskMonitoring,
    "Change Password": RoutePaths.manageChangePassword,
    "Market Profit/Loss": RoutePaths.manageMarketProfitLoss,
    "Profit/Loss": RoutePaths.manageProfitLoss,
    "Betting History": RoutePaths.manageBettingHistory,
    "BetList": RoutePaths.manageBetList,
    "BetListLive": RoutePaths.manageBetListLive,
    "BetListDetail": RoutePaths.manageBetListDetail,
    "Market Settle Status Live": RoutePaths.manageMarketSettleStatusLive,
    "Market Settle Status Log": RoutePaths.manageMarketSettleStatusLog,
    "Agency": RoutePaths.manageAgency,
    "Balance Log": RoutePaths.manageBalanceLog,
    "Agency History": RoutePaths.manageAgencyHistory,
    "OP Action Log": RoutePaths.manageOpActionLog,
    "User Activity Log": RoutePaths.manageUserActivityLog,
    "Action Log": RoutePaths.manageActionLog,
  };

  // ==================== Helper Methods ====================

  /// Gets the display page label for a given route location
  static String getPageLabelForLocation(String location) {
    // Handle root manage route
    if (location == manage || location == '$manage/') {
      return 'Risk Management Summary';
    }

    // Remove trailing slash if present
    final normalizedLocation = location.endsWith('/') ? location.substring(0, location.length - 1) : location;

    // Return mapped page name or default
    return routeToPageName[normalizedLocation] ?? 'Risk Management Summary';
  }

  /// Backward-compatible alias for page label lookups
  static String pageLabelForLocation(String location) {
    return getPageLabelForLocation(location);
  }

  /// Builds the route path for a given page name or custom menu label
  static String getRouteForPageName(String pageName) {
    return pageNameToRoute[pageName] ?? pageLabelAliases[pageName] ?? manageRiskManagement;
  }

  /// Builds the under development placeholder page
  static Widget buildUnderDevelopmentPage({required String featureName}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.deepOrange.shade400, Colors.orange.shade200], begin: Alignment.topLeft, end: Alignment.bottomRight),
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.deepOrange.withOpacity(0.18), blurRadius: 18, offset: const Offset(0, 10))],
          ),
          child: const Icon(Icons.construction_rounded, size: 72, color: Colors.white),
        ),
        const SizedBox(height: 28),
        HighlightText(
          featureName,
          style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w800, letterSpacing: 0.2, color: Colors.black87),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 14),
        HighlightText(
          'This feature is under development and will be ready soon!',
          style: const TextStyle(fontSize: 17, color: Colors.black54, height: 1.6),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// Route metadata used to build GoRouter routes.
class RouteConfig {
  final String path;
  final String name;
  final String title;
  final bool isPublic;
  final Widget Function(BuildContext, GoRouterState) builder;
  final String Function(GoRouterState)? titleBuilder;

  const RouteConfig(this.path, this.name, this.title, this.builder, {this.isPublic = false, this.titleBuilder});

  String getTitle(GoRouterState state) => titleBuilder?.call(state) ?? title;
}

/// Utility function to encode query parameters consistently across the app
String eqc(String val) => Uri.encodeQueryComponent(val);
