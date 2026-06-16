// This is a generated file - do not edit.
//
// Generated from receive.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'receive.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'receive.pbenum.dart';

/// Main model
class ABCModel extends $pb.GeneratedMessage {
  factory ABCModel({
    $core.String? eventId,
    $core.String? marketId,
    $core.bool? inPlay,
    $core.Iterable<AbcRunner>? runner,
    BettingType? bettingType,
    $core.bool? sportingEvent,
    $core.String? marketType,
    $core.String? marketName,
    StatusType? status,
    $core.String? marketTime,
    MarketCondition? marketCondition,
  }) {
    final result = create();
    if (eventId != null) result.eventId = eventId;
    if (marketId != null) result.marketId = marketId;
    if (inPlay != null) result.inPlay = inPlay;
    if (runner != null) result.runner.addAll(runner);
    if (bettingType != null) result.bettingType = bettingType;
    if (sportingEvent != null) result.sportingEvent = sportingEvent;
    if (marketType != null) result.marketType = marketType;
    if (marketName != null) result.marketName = marketName;
    if (status != null) result.status = status;
    if (marketTime != null) result.marketTime = marketTime;
    if (marketCondition != null) result.marketCondition = marketCondition;
    return result;
  }

  ABCModel._();

  factory ABCModel.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory ABCModel.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ABCModel', package: const $pb.PackageName(_omitMessageNames ? '' : 'abc'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'eventId', protoName: 'eventId')
    ..aOS(2, _omitFieldNames ? '' : 'marketId', protoName: 'marketId')
    ..aOB(3, _omitFieldNames ? '' : 'inPlay', protoName: 'inPlay')
    ..pc<AbcRunner>(4, _omitFieldNames ? '' : 'runner', $pb.PbFieldType.PM, subBuilder: AbcRunner.create)
    ..e<BettingType>(5, _omitFieldNames ? '' : 'bettingType', $pb.PbFieldType.OE, protoName: 'bettingType', defaultOrMaker: BettingType.ODDS, valueOf: BettingType.valueOf, enumValues: BettingType.values)
    ..aOB(6, _omitFieldNames ? '' : 'sportingEvent', protoName: 'sportingEvent')
    ..aOS(7, _omitFieldNames ? '' : 'marketType', protoName: 'marketType')
    ..aOS(8, _omitFieldNames ? '' : 'marketName', protoName: 'marketName')
    ..e<StatusType>(9, _omitFieldNames ? '' : 'status', $pb.PbFieldType.OE, defaultOrMaker: StatusType.ACTIVE, valueOf: StatusType.valueOf, enumValues: StatusType.values)
    ..aOS(10, _omitFieldNames ? '' : 'marketTime', protoName: 'marketTime')
    ..aOM<MarketCondition>(11, _omitFieldNames ? '' : 'marketCondition', protoName: 'marketCondition', subBuilder: MarketCondition.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ABCModel clone() => ABCModel()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ABCModel copyWith(void Function(ABCModel) updates) => super.copyWith((message) => updates(message as ABCModel)) as ABCModel;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ABCModel create() => ABCModel._();
  @$core.override
  ABCModel createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ABCModel getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ABCModel>(create);
  static ABCModel? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get eventId => $_getSZ(0);
  @$pb.TagNumber(1)
  set eventId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasEventId() => $_has(0);
  @$pb.TagNumber(1)
  void clearEventId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get marketId => $_getSZ(1);
  @$pb.TagNumber(2)
  set marketId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMarketId() => $_has(1);
  @$pb.TagNumber(2)
  void clearMarketId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get inPlay => $_getBF(2);
  @$pb.TagNumber(3)
  set inPlay($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasInPlay() => $_has(2);
  @$pb.TagNumber(3)
  void clearInPlay() => $_clearField(3);

  @$pb.TagNumber(4)
  $pb.PbList<AbcRunner> get runner => $_getList(3);

  @$pb.TagNumber(5)
  BettingType get bettingType => $_getN(4);
  @$pb.TagNumber(5)
  set bettingType(BettingType value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasBettingType() => $_has(4);
  @$pb.TagNumber(5)
  void clearBettingType() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get sportingEvent => $_getBF(5);
  @$pb.TagNumber(6)
  set sportingEvent($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasSportingEvent() => $_has(5);
  @$pb.TagNumber(6)
  void clearSportingEvent() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get marketType => $_getSZ(6);
  @$pb.TagNumber(7)
  set marketType($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasMarketType() => $_has(6);
  @$pb.TagNumber(7)
  void clearMarketType() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get marketName => $_getSZ(7);
  @$pb.TagNumber(8)
  set marketName($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasMarketName() => $_has(7);
  @$pb.TagNumber(8)
  void clearMarketName() => $_clearField(8);

  @$pb.TagNumber(9)
  StatusType get status => $_getN(8);
  @$pb.TagNumber(9)
  set status(StatusType value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasStatus() => $_has(8);
  @$pb.TagNumber(9)
  void clearStatus() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get marketTime => $_getSZ(9);
  @$pb.TagNumber(10)
  set marketTime($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasMarketTime() => $_has(9);
  @$pb.TagNumber(10)
  void clearMarketTime() => $_clearField(10);

  @$pb.TagNumber(11)
  MarketCondition get marketCondition => $_getN(10);
  @$pb.TagNumber(11)
  set marketCondition(MarketCondition value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasMarketCondition() => $_has(10);
  @$pb.TagNumber(11)
  void clearMarketCondition() => $_clearField(11);
  @$pb.TagNumber(11)
  MarketCondition ensureMarketCondition() => $_ensure(10);
}

/// Market condition
class MarketCondition extends $pb.GeneratedMessage {
  factory MarketCondition({
    $core.bool? betLock,
    $core.int? minBet,
    $core.int? maxBet,
    $core.int? maxProfit,
    $core.int? betDelay,
    $core.int? mtp,
    $core.bool? allowUnmatchBet,
    $core.int? potLimit,
    $core.int? volume,
  }) {
    final result = create();
    if (betLock != null) result.betLock = betLock;
    if (minBet != null) result.minBet = minBet;
    if (maxBet != null) result.maxBet = maxBet;
    if (maxProfit != null) result.maxProfit = maxProfit;
    if (betDelay != null) result.betDelay = betDelay;
    if (mtp != null) result.mtp = mtp;
    if (allowUnmatchBet != null) result.allowUnmatchBet = allowUnmatchBet;
    if (potLimit != null) result.potLimit = potLimit;
    if (volume != null) result.volume = volume;
    return result;
  }

  MarketCondition._();

  factory MarketCondition.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory MarketCondition.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MarketCondition', package: const $pb.PackageName(_omitMessageNames ? '' : 'abc'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'betLock', protoName: 'betLock')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'minBet', $pb.PbFieldType.O3, protoName: 'minBet')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'maxBet', $pb.PbFieldType.O3, protoName: 'maxBet')
    ..a<$core.int>(4, _omitFieldNames ? '' : 'maxProfit', $pb.PbFieldType.O3, protoName: 'maxProfit')
    ..a<$core.int>(5, _omitFieldNames ? '' : 'betDelay', $pb.PbFieldType.O3, protoName: 'betDelay')
    ..a<$core.int>(6, _omitFieldNames ? '' : 'mtp', $pb.PbFieldType.O3)
    ..aOB(7, _omitFieldNames ? '' : 'allowUnmatchBet', protoName: 'allowUnmatchBet')
    ..a<$core.int>(8, _omitFieldNames ? '' : 'potLimit', $pb.PbFieldType.O3, protoName: 'potLimit')
    ..a<$core.int>(9, _omitFieldNames ? '' : 'volume', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MarketCondition clone() => MarketCondition()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MarketCondition copyWith(void Function(MarketCondition) updates) => super.copyWith((message) => updates(message as MarketCondition)) as MarketCondition;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MarketCondition create() => MarketCondition._();
  @$core.override
  MarketCondition createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MarketCondition getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MarketCondition>(create);
  static MarketCondition? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get betLock => $_getBF(0);
  @$pb.TagNumber(1)
  set betLock($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasBetLock() => $_has(0);
  @$pb.TagNumber(1)
  void clearBetLock() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get minBet => $_getIZ(1);
  @$pb.TagNumber(2)
  set minBet($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMinBet() => $_has(1);
  @$pb.TagNumber(2)
  void clearMinBet() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get maxBet => $_getIZ(2);
  @$pb.TagNumber(3)
  set maxBet($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMaxBet() => $_has(2);
  @$pb.TagNumber(3)
  void clearMaxBet() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get maxProfit => $_getIZ(3);
  @$pb.TagNumber(4)
  set maxProfit($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasMaxProfit() => $_has(3);
  @$pb.TagNumber(4)
  void clearMaxProfit() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get betDelay => $_getIZ(4);
  @$pb.TagNumber(5)
  set betDelay($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasBetDelay() => $_has(4);
  @$pb.TagNumber(5)
  void clearBetDelay() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get mtp => $_getIZ(5);
  @$pb.TagNumber(6)
  set mtp($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasMtp() => $_has(5);
  @$pb.TagNumber(6)
  void clearMtp() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.bool get allowUnmatchBet => $_getBF(6);
  @$pb.TagNumber(7)
  set allowUnmatchBet($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(7)
  $core.bool hasAllowUnmatchBet() => $_has(6);
  @$pb.TagNumber(7)
  void clearAllowUnmatchBet() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get potLimit => $_getIZ(7);
  @$pb.TagNumber(8)
  set potLimit($core.int value) => $_setSignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasPotLimit() => $_has(7);
  @$pb.TagNumber(8)
  void clearPotLimit() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.int get volume => $_getIZ(8);
  @$pb.TagNumber(9)
  set volume($core.int value) => $_setSignedInt32(8, value);
  @$pb.TagNumber(9)
  $core.bool hasVolume() => $_has(8);
  @$pb.TagNumber(9)
  void clearVolume() => $_clearField(9);
}

class AbcRunner extends $pb.GeneratedMessage {
  factory AbcRunner({
    $core.String? name,
    $core.Iterable<ABCPrice>? backs,
    $core.Iterable<ABCPrice>? lays,
    StatusType? status,
    $core.String? runnerId,
  }) {
    final result = create();
    if (name != null) result.name = name;
    if (backs != null) result.backs.addAll(backs);
    if (lays != null) result.lays.addAll(lays);
    if (status != null) result.status = status;
    if (runnerId != null) result.runnerId = runnerId;
    return result;
  }

  AbcRunner._();

  factory AbcRunner.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory AbcRunner.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AbcRunner', package: const $pb.PackageName(_omitMessageNames ? '' : 'abc'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..pc<ABCPrice>(2, _omitFieldNames ? '' : 'backs', $pb.PbFieldType.PM, subBuilder: ABCPrice.create)
    ..pc<ABCPrice>(3, _omitFieldNames ? '' : 'lays', $pb.PbFieldType.PM, subBuilder: ABCPrice.create)
    ..e<StatusType>(4, _omitFieldNames ? '' : 'status', $pb.PbFieldType.OE, defaultOrMaker: StatusType.ACTIVE, valueOf: StatusType.valueOf, enumValues: StatusType.values)
    ..aOS(5, _omitFieldNames ? '' : 'runnerId', protoName: 'runnerId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AbcRunner clone() => AbcRunner()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AbcRunner copyWith(void Function(AbcRunner) updates) => super.copyWith((message) => updates(message as AbcRunner)) as AbcRunner;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AbcRunner create() => AbcRunner._();
  @$core.override
  AbcRunner createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AbcRunner getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AbcRunner>(create);
  static AbcRunner? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<ABCPrice> get backs => $_getList(1);

  @$pb.TagNumber(3)
  $pb.PbList<ABCPrice> get lays => $_getList(2);

  @$pb.TagNumber(4)
  StatusType get status => $_getN(3);
  @$pb.TagNumber(4)
  set status(StatusType value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasStatus() => $_has(3);
  @$pb.TagNumber(4)
  void clearStatus() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get runnerId => $_getSZ(4);
  @$pb.TagNumber(5)
  set runnerId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasRunnerId() => $_has(4);
  @$pb.TagNumber(5)
  void clearRunnerId() => $_clearField(5);
}

class ABCPrice extends $pb.GeneratedMessage {
  factory ABCPrice({
    $core.double? price,
    $core.double? size,
    $core.String? line,
  }) {
    final result = create();
    if (price != null) result.price = price;
    if (size != null) result.size = size;
    if (line != null) result.line = line;
    return result;
  }

  ABCPrice._();

  factory ABCPrice.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory ABCPrice.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ABCPrice', package: const $pb.PackageName(_omitMessageNames ? '' : 'abc'), createEmptyInstance: create)
    ..a<$core.double>(1, _omitFieldNames ? '' : 'price', $pb.PbFieldType.OD)
    ..a<$core.double>(2, _omitFieldNames ? '' : 'size', $pb.PbFieldType.OD)
    ..aOS(3, _omitFieldNames ? '' : 'line')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ABCPrice clone() => ABCPrice()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ABCPrice copyWith(void Function(ABCPrice) updates) => super.copyWith((message) => updates(message as ABCPrice)) as ABCPrice;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ABCPrice create() => ABCPrice._();
  @$core.override
  ABCPrice createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ABCPrice getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ABCPrice>(create);
  static ABCPrice? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get price => $_getN(0);
  @$pb.TagNumber(1)
  set price($core.double value) => $_setDouble(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPrice() => $_has(0);
  @$pb.TagNumber(1)
  void clearPrice() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get size => $_getN(1);
  @$pb.TagNumber(2)
  set size($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSize() => $_has(1);
  @$pb.TagNumber(2)
  void clearSize() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get line => $_getSZ(2);
  @$pb.TagNumber(3)
  set line($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasLine() => $_has(2);
  @$pb.TagNumber(3)
  void clearLine() => $_clearField(3);
}


const $core.bool _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
