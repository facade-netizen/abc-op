import 'package:chopper/chopper.dart';

import '../../../model/activity_log_model.dart';
import '../../../model/agency_model.dart';
import '../../../model/change_pass_log_model.dart';
import '../../../model/ispip_log_model.dart';
import '../../../model/user_details_model.dart';
import '../../../model/user_log_model.dart';
import '../../apiHandlers/api_constants.dart';
import '../../apiHandlers/api_interceptors.dart';
import '../../apiHandlers/json_to_type_converter.dart';

part 'account_api_services.chopper.dart';

final _accountApiClient = ChopperClient(
  baseUrl: Uri.parse(AuthApiConstants.baseUrl),
  converter: JsonSerializableConverter({
    UserResponse: (json) => UserResponse.fromJson(json),
    AgencyResponse: (json) => AgencyResponse.fromJson(json),
    UserLogResponse: (json) => UserLogResponse.fromJson(json),
    IspIpLogsResponse: (json) => IspIpLogsResponse.fromJson(json),
    CreditLimitResponse: (json) => CreditLimitResponse.fromJson(json),
    TransferredResponse: (json) => TransferredResponse.fromJson(json),
    ActivityLogsResponse: (json) => ActivityLogsResponse.fromJson(json),
    ChangePassLogsResponse: (json) => ChangePassLogsResponse.fromJson(json),
    AccountStatementResponse: (json) => AccountStatementResponse.fromJson(json),
  }),
  interceptors: [ApiAuthInterceptor(), ApiResponseInterceptor(), ApiRequestInterceptor()],
  errorConverter: const JsonConverter(),
);

@ChopperApi(baseUrl: AccountApiConstants.baseUrl)
abstract class AccountApiServices extends ChopperService {
  ///Don't modify
  static AccountApiServices create() {
    return _$AccountApiServices(_accountApiClient);
  }

  @GET(path: AccountApiConstants.account)
  Future<Response<UserResponse>> getUserDetails();

  @POST(path: AccountApiConstants.activityLog)
  Future<ActivityLogsResponse> getUserActivityLogs({@Body() required Map<String, dynamic> body});

  @POST(path: AccountApiConstants.orderActivityLog)
  Future<ActivityLogsResponse> getOrderActivityLogs({@Body() required Map<String, dynamic> body});

  @POST(path: AccountApiConstants.agency)
  Future<AgencyResponse> getAgencyData({@Body() required Map<String, dynamic> body});

  @GET(path: AccountApiConstants.userLogs)
  Future<UserLogResponse> getUserLog(
    @Query("logType") int? logType,
    @Query("from") String? from,
    @Query("to") String? to,
    @Query("updater") String? updater,
    @Query("username") String? username,
  );

  @POST(path: AccountApiConstants.userAccountStatement)
  Future<AccountStatementResponse> getUserAccountStatement({@Body() required Map<String, dynamic> body});

  @POST(path: AccountApiConstants.userISP)
  Future<IspIpLogsResponse> getUserISPData({@Body() required Map<String, dynamic> body});

  @GET(path: AccountApiConstants.userChangePass)
  Future<ChangePassLogsResponse> getUserChangePassLogs(
    @Query("userName") String? userName,
    @Query("from") String? from,
    @Query("to") String? to,
    @Query("page") int? page,
    @Query("limit") int? limit,
  );

  @GET(path: AccountApiConstants.userTransferredLogs)
  Future<TransferredResponse> getUserTransferredLogs(
    @Query("userName") String? userName,
    @Query("from") String? from,
    @Query("to") String? to,
    @Query("page") int? page,
    @Query("limit") int? limit,
  );

  @GET(path: AccountApiConstants.userCreditLimit)
  Future<CreditLimitResponse> getUserCreditLimitLogs(
    @Query("userName") String? userName,
    @Query("from") String? from,
    @Query("to") String? to,
    @Query("page") int? page,
    @Query("limit") int? limit,
  );
}
