import 'package:chopper/chopper.dart';

import '../../../model/settle_history_model.dart';
import '../../apiHandlers/api_constants.dart';
import '../../apiHandlers/api_interceptors.dart';
import '../../apiHandlers/json_to_type_converter.dart';

part 'ms_api_services.chopper.dart';

final _msApiClient = ChopperClient(
  baseUrl: Uri.parse(ManageMarketResult.baseUrl),
  converter: JsonSerializableConverter({
    SettleHistoryResponse: (json) => SettleHistoryResponse.fromJson(json),
  }),
  interceptors: [ApiAuthInterceptor(), ApiResponseInterceptor(), ApiRequestInterceptor()],
  errorConverter: const JsonConverter(),
);

@ChopperApi(baseUrl: ManageMarketResult.baseUrl)
abstract class SettleApiServices extends ChopperService {
  ///Don't modify
  static SettleApiServices create() {
    return _$SettleApiServices(_msApiClient);
  }

  @GET(path: ManageMarketResult.getSettleHistory)
  Future<Response<SettleHistoryResponse>> getSettleHistory(
    @Query('from') String? from,
    @Query('to') String? to,
    @Query('marketId') String? marketId,
    @Query('eventId') String? eventId,
  );
}
