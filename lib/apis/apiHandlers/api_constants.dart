const String baseDomain = "dmxchge.com";

class AuthApiConstants {
  static const String baseUrl = 'https://abcuser.$baseDomain/api/Auth/';
  static const String login = '${baseUrl}login';
  static const String verifyToken = '${baseUrl}varifyToken/';
  static const String changePassword = 'change-password';
  static const String updateUserAccess = 'updateUserAcccess-OP';
  static const String resetPassword = '${baseUrl}change-password-1';
  static const String ip = 'https://api.ipify.org?format=json';
  static const String isp = 'https://ipapi.co/json/';
}

class AccountApiConstants {
  static const String baseUrl = 'https://abcuser.$baseDomain/api/';
  static const String account = 'Account';
  static const String activityLog = '$account/activityLog';
  static const String agency = '$account/agencyOP';
  static const String userLogs = '$account/userLogs';
  static const String userAccountStatement = '$account/balancelog-op';
  static const String userISP = '$account/activityLog-ISP';
  static const String orderActivityLog = '$account/orderActivityLog';
  static const String userChangePass = 'changePasswordLogs';
  static const String userCreditLimit = 'creditLogs';
  static const String userTransferredLogs = 'casinoTransferLogs';
}

class OrdersApiConstants {
  static const String baseUrl = 'https://abcorder.$baseDomain/';
  static const String betlist = 'betlist';
  static const String riskMonitoring = 'riskMonitoring';
  static const String userBook = 'userBook-OP';
  static const String runnerWiseReport = 'runnerWiseReport';
  static const String sportWiseReport = 'sportWiseReport';
  static const String matchBook = 'matchBook';
  static const String profitLoss = 'profitLoss-void';
  static const String orderReport = 'orderReport';
  static const String topExposures = 'topExposures';
  static const String riskManagement = 'riskManagement';
  static const String groupProfitLoss = 'groupProfitLoss';
  static const String orderLogSummary = 'orderLogSummary';
  static const String lifeTimeReport = 'lifeTimeReport';
  static const String orderEvents = 'orderEvents';
  static const String negativeOrderLogSummary = 'negative-OrderLogSummary';
}

class ManageMarketResult {
  static const String baseUrl = 'https://abcmanager.$baseDomain/';
  static const String getSettleHistory = 'getSettleHistory';
  static const String bmSignalRUrl = 'https://abcdata.$baseDomain/broadcast';
}

class CGApiConstants {
  static const String baseUrl = 'https://rgc.$baseDomain/api/Casino/';
  static const String history = 'history-OP';
  static const String betDetail = 'betDetail';
  static const String casinoHistory = 'casinoHistory';
  static const String sportsBook = 'sportHistory';
  static const String sportsBookDetail = 'sportHistoryDetail';
  static const String premiumSport = 'premiumSportWiseReport';
  static const String premiumRunnerReport = 'premiumRunnerWiseReport';
  static const String sportBookBetList = 'premiumsportBetList';
  static const String sportBookBetEventsList = 'premiumsportBetEventsList';
}

class WLApiConstants {
  static const String baseUrl = 'https://abcuser.$baseDomain/api/WL/';
  static const String getAll = '${baseUrl}getAll';
}
