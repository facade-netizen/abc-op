import 'package:chopper/chopper.dart';

import '../../../model/settle_history_model.dart';
import 'ms_api_services.dart';

class SettleApiRepository {
  SettleApiRepository() : _msApiServices = SettleApiServices.create();
  final SettleApiServices _msApiServices;

  Future<Response<SettleHistoryResponse>> getSettleHistory(
    String? from,
    String? to,
    String? marketId,
    String? eventId,
  ) async {
    return await _msApiServices.getSettleHistory(from, to, marketId, eventId);
  }
}
