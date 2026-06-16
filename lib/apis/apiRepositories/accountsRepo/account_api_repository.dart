import 'package:chopper/chopper.dart';

import '../../../model/activity_log_model.dart';
import '../../../model/agency_model.dart';
import '../../../model/change_pass_log_model.dart';
import '../../../model/ispip_log_model.dart';
import '../../../model/user_details_model.dart';
import '../../../model/user_log_model.dart';
import 'account_api_services.dart';

class AccountApiRepository {
  AccountApiRepository() : _accountApiServices = AccountApiServices.create();
  final AccountApiServices _accountApiServices;

  Future<Response<UserResponse>> getUserDetails() async {
    try {
      return _accountApiServices.getUserDetails();
    } catch (e) {
      rethrow;
    }
  }

  Future<ActivityLogsResponse> getUserActivityLogs({required Map<String, dynamic> body}) async {
    return await _accountApiServices.getUserActivityLogs(body: body);
  }

  Future<ActivityLogsResponse> getOrderActivityLogs({required Map<String, dynamic> body}) async {
    return await _accountApiServices.getOrderActivityLogs(body: body);
  }

  Future<AgencyResponse> getAgency({required Map<String, dynamic> body}) async {
    try {
      return _accountApiServices.getAgencyData(body: body);
    } catch (e) {
      rethrow;
    }
  }

  Future<UserLogResponse> getUserLogs({
    String? from,
    String? to,
    int? logType,
    String? updater,
    String? username,
  }) async {
    try {
      return _accountApiServices.getUserLog(
        logType,
        from,
        to,
        updater,
        username,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<AccountStatementResponse> getUserAccountStatementLogs({required Map<String, dynamic> body}) async {
    return await _accountApiServices.getUserAccountStatement(body: body);
  }

  Future<IspIpLogsResponse> getUserISPData({required Map<String, dynamic> body}) async {
    return await _accountApiServices.getUserISPData(body: body);
  }

  Future<ChangePassLogsResponse> getUserChangePassLogs({
    String? userName,
    String? from,
    String? to,
    int? page,
    int? limit,
  }) async {
    return await _accountApiServices.getUserChangePassLogs(
      userName,
      from,
      to,
      page,
      limit,
    );
  }

  Future<TransferredResponse> getUserTransferredLogs({
    String? userName,
    String? from,
    String? to,
    int? page,
    int? limit,
  }) async {
    return await _accountApiServices.getUserTransferredLogs(
      userName,
      from,
      to,
      page,
      limit,
    );
  }

  Future<CreditLimitResponse> getUserCreditLimitLogs({
    String? userName,
    String? from,
    String? to,
    int? page,
    int? limit,
  }) async {
    return await _accountApiServices.getUserCreditLimitLogs(
      userName,
      from,
      to,
      page,
      limit,
    );
  }
}
