//
//  Generated code. Do not modify.
//  source: operations/v1/operations.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import '../../common/v1/common.pb.dart' as $8;
import '../../common/v1/common.pbenum.dart' as $8;
import '../../common/v1/money.pb.dart' as $7;
import '../../google/protobuf/struct.pb.dart' as $6;

class TransferOrderObject extends $pb.GeneratedMessage {
  factory TransferOrderObject({
    $core.String? id,
    $core.String? debitAccountRef,
    $core.String? creditAccountRef,
    $7.Money? amount,
    $core.int? orderType,
    $core.String? reference,
    $core.String? description,
    $6.Struct? extraData,
    $8.STATE? state,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (debitAccountRef != null) {
      $result.debitAccountRef = debitAccountRef;
    }
    if (creditAccountRef != null) {
      $result.creditAccountRef = creditAccountRef;
    }
    if (amount != null) {
      $result.amount = amount;
    }
    if (orderType != null) {
      $result.orderType = orderType;
    }
    if (reference != null) {
      $result.reference = reference;
    }
    if (description != null) {
      $result.description = description;
    }
    if (extraData != null) {
      $result.extraData = extraData;
    }
    if (state != null) {
      $result.state = state;
    }
    return $result;
  }
  TransferOrderObject._() : super();
  factory TransferOrderObject.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TransferOrderObject.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TransferOrderObject', package: const $pb.PackageName(_omitMessageNames ? '' : 'operations.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'debitAccountRef')
    ..aOS(3, _omitFieldNames ? '' : 'creditAccountRef')
    ..aOM<$7.Money>(4, _omitFieldNames ? '' : 'amount', subBuilder: $7.Money.create)
    ..a<$core.int>(6, _omitFieldNames ? '' : 'orderType', $pb.PbFieldType.O3)
    ..aOS(7, _omitFieldNames ? '' : 'reference')
    ..aOS(8, _omitFieldNames ? '' : 'description')
    ..aOM<$6.Struct>(9, _omitFieldNames ? '' : 'extraData', subBuilder: $6.Struct.create)
    ..e<$8.STATE>(10, _omitFieldNames ? '' : 'state', $pb.PbFieldType.OE, defaultOrMaker: $8.STATE.CREATED, valueOf: $8.STATE.valueOf, enumValues: $8.STATE.values)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TransferOrderObject clone() => TransferOrderObject()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TransferOrderObject copyWith(void Function(TransferOrderObject) updates) => super.copyWith((message) => updates(message as TransferOrderObject)) as TransferOrderObject;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TransferOrderObject create() => TransferOrderObject._();
  TransferOrderObject createEmptyInstance() => create();
  static $pb.PbList<TransferOrderObject> createRepeated() => $pb.PbList<TransferOrderObject>();
  @$core.pragma('dart2js:noInline')
  static TransferOrderObject getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TransferOrderObject>(create);
  static TransferOrderObject? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get debitAccountRef => $_getSZ(1);
  @$pb.TagNumber(2)
  set debitAccountRef($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasDebitAccountRef() => $_has(1);
  @$pb.TagNumber(2)
  void clearDebitAccountRef() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get creditAccountRef => $_getSZ(2);
  @$pb.TagNumber(3)
  set creditAccountRef($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasCreditAccountRef() => $_has(2);
  @$pb.TagNumber(3)
  void clearCreditAccountRef() => clearField(3);

  @$pb.TagNumber(4)
  $7.Money get amount => $_getN(3);
  @$pb.TagNumber(4)
  set amount($7.Money v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasAmount() => $_has(3);
  @$pb.TagNumber(4)
  void clearAmount() => clearField(4);
  @$pb.TagNumber(4)
  $7.Money ensureAmount() => $_ensure(3);

  @$pb.TagNumber(6)
  $core.int get orderType => $_getIZ(4);
  @$pb.TagNumber(6)
  set orderType($core.int v) { $_setSignedInt32(4, v); }
  @$pb.TagNumber(6)
  $core.bool hasOrderType() => $_has(4);
  @$pb.TagNumber(6)
  void clearOrderType() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get reference => $_getSZ(5);
  @$pb.TagNumber(7)
  set reference($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(7)
  $core.bool hasReference() => $_has(5);
  @$pb.TagNumber(7)
  void clearReference() => clearField(7);

  @$pb.TagNumber(8)
  $core.String get description => $_getSZ(6);
  @$pb.TagNumber(8)
  set description($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(8)
  $core.bool hasDescription() => $_has(6);
  @$pb.TagNumber(8)
  void clearDescription() => clearField(8);

  @$pb.TagNumber(9)
  $6.Struct get extraData => $_getN(7);
  @$pb.TagNumber(9)
  set extraData($6.Struct v) { setField(9, v); }
  @$pb.TagNumber(9)
  $core.bool hasExtraData() => $_has(7);
  @$pb.TagNumber(9)
  void clearExtraData() => clearField(9);
  @$pb.TagNumber(9)
  $6.Struct ensureExtraData() => $_ensure(7);

  @$pb.TagNumber(10)
  $8.STATE get state => $_getN(8);
  @$pb.TagNumber(10)
  set state($8.STATE v) { setField(10, v); }
  @$pb.TagNumber(10)
  $core.bool hasState() => $_has(8);
  @$pb.TagNumber(10)
  void clearState() => clearField(10);
}

class TransferOrderExecuteRequest extends $pb.GeneratedMessage {
  factory TransferOrderExecuteRequest({
    TransferOrderObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  TransferOrderExecuteRequest._() : super();
  factory TransferOrderExecuteRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TransferOrderExecuteRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TransferOrderExecuteRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'operations.v1'), createEmptyInstance: create)
    ..aOM<TransferOrderObject>(1, _omitFieldNames ? '' : 'data', subBuilder: TransferOrderObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TransferOrderExecuteRequest clone() => TransferOrderExecuteRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TransferOrderExecuteRequest copyWith(void Function(TransferOrderExecuteRequest) updates) => super.copyWith((message) => updates(message as TransferOrderExecuteRequest)) as TransferOrderExecuteRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TransferOrderExecuteRequest create() => TransferOrderExecuteRequest._();
  TransferOrderExecuteRequest createEmptyInstance() => create();
  static $pb.PbList<TransferOrderExecuteRequest> createRepeated() => $pb.PbList<TransferOrderExecuteRequest>();
  @$core.pragma('dart2js:noInline')
  static TransferOrderExecuteRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TransferOrderExecuteRequest>(create);
  static TransferOrderExecuteRequest? _defaultInstance;

  @$pb.TagNumber(1)
  TransferOrderObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(TransferOrderObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  TransferOrderObject ensureData() => $_ensure(0);
}

class TransferOrderExecuteResponse extends $pb.GeneratedMessage {
  factory TransferOrderExecuteResponse({
    TransferOrderObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  TransferOrderExecuteResponse._() : super();
  factory TransferOrderExecuteResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TransferOrderExecuteResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TransferOrderExecuteResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'operations.v1'), createEmptyInstance: create)
    ..aOM<TransferOrderObject>(1, _omitFieldNames ? '' : 'data', subBuilder: TransferOrderObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TransferOrderExecuteResponse clone() => TransferOrderExecuteResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TransferOrderExecuteResponse copyWith(void Function(TransferOrderExecuteResponse) updates) => super.copyWith((message) => updates(message as TransferOrderExecuteResponse)) as TransferOrderExecuteResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TransferOrderExecuteResponse create() => TransferOrderExecuteResponse._();
  TransferOrderExecuteResponse createEmptyInstance() => create();
  static $pb.PbList<TransferOrderExecuteResponse> createRepeated() => $pb.PbList<TransferOrderExecuteResponse>();
  @$core.pragma('dart2js:noInline')
  static TransferOrderExecuteResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TransferOrderExecuteResponse>(create);
  static TransferOrderExecuteResponse? _defaultInstance;

  @$pb.TagNumber(1)
  TransferOrderObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(TransferOrderObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  TransferOrderObject ensureData() => $_ensure(0);
}

class TransferOrderSearchRequest extends $pb.GeneratedMessage {
  factory TransferOrderSearchRequest({
    $core.String? query,
    $core.int? orderType,
    $8.PageCursor? cursor,
  }) {
    final $result = create();
    if (query != null) {
      $result.query = query;
    }
    if (orderType != null) {
      $result.orderType = orderType;
    }
    if (cursor != null) {
      $result.cursor = cursor;
    }
    return $result;
  }
  TransferOrderSearchRequest._() : super();
  factory TransferOrderSearchRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TransferOrderSearchRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TransferOrderSearchRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'operations.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'query')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'orderType', $pb.PbFieldType.O3)
    ..aOM<$8.PageCursor>(3, _omitFieldNames ? '' : 'cursor', subBuilder: $8.PageCursor.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TransferOrderSearchRequest clone() => TransferOrderSearchRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TransferOrderSearchRequest copyWith(void Function(TransferOrderSearchRequest) updates) => super.copyWith((message) => updates(message as TransferOrderSearchRequest)) as TransferOrderSearchRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TransferOrderSearchRequest create() => TransferOrderSearchRequest._();
  TransferOrderSearchRequest createEmptyInstance() => create();
  static $pb.PbList<TransferOrderSearchRequest> createRepeated() => $pb.PbList<TransferOrderSearchRequest>();
  @$core.pragma('dart2js:noInline')
  static TransferOrderSearchRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TransferOrderSearchRequest>(create);
  static TransferOrderSearchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get query => $_getSZ(0);
  @$pb.TagNumber(1)
  set query($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasQuery() => $_has(0);
  @$pb.TagNumber(1)
  void clearQuery() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get orderType => $_getIZ(1);
  @$pb.TagNumber(2)
  set orderType($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasOrderType() => $_has(1);
  @$pb.TagNumber(2)
  void clearOrderType() => clearField(2);

  @$pb.TagNumber(3)
  $8.PageCursor get cursor => $_getN(2);
  @$pb.TagNumber(3)
  set cursor($8.PageCursor v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasCursor() => $_has(2);
  @$pb.TagNumber(3)
  void clearCursor() => clearField(3);
  @$pb.TagNumber(3)
  $8.PageCursor ensureCursor() => $_ensure(2);
}

class TransferOrderSearchResponse extends $pb.GeneratedMessage {
  factory TransferOrderSearchResponse({
    $core.Iterable<TransferOrderObject>? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data.addAll(data);
    }
    return $result;
  }
  TransferOrderSearchResponse._() : super();
  factory TransferOrderSearchResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TransferOrderSearchResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TransferOrderSearchResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'operations.v1'), createEmptyInstance: create)
    ..pc<TransferOrderObject>(1, _omitFieldNames ? '' : 'data', $pb.PbFieldType.PM, subBuilder: TransferOrderObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TransferOrderSearchResponse clone() => TransferOrderSearchResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TransferOrderSearchResponse copyWith(void Function(TransferOrderSearchResponse) updates) => super.copyWith((message) => updates(message as TransferOrderSearchResponse)) as TransferOrderSearchResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TransferOrderSearchResponse create() => TransferOrderSearchResponse._();
  TransferOrderSearchResponse createEmptyInstance() => create();
  static $pb.PbList<TransferOrderSearchResponse> createRepeated() => $pb.PbList<TransferOrderSearchResponse>();
  @$core.pragma('dart2js:noInline')
  static TransferOrderSearchResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TransferOrderSearchResponse>(create);
  static TransferOrderSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<TransferOrderObject> get data => $_getList(0);
}

/// IncomingPaymentNotifyRequest notifies the system of a new payment received.
class IncomingPaymentNotifyRequest extends $pb.GeneratedMessage {
  factory IncomingPaymentNotifyRequest({
    $core.String? transactionId,
    $7.Money? amount,
    $core.String? payerReference,
    $core.String? payerName,
    $core.String? productId,
    $core.String? groupId,
    $6.Struct? properties,
  }) {
    final $result = create();
    if (transactionId != null) {
      $result.transactionId = transactionId;
    }
    if (amount != null) {
      $result.amount = amount;
    }
    if (payerReference != null) {
      $result.payerReference = payerReference;
    }
    if (payerName != null) {
      $result.payerName = payerName;
    }
    if (productId != null) {
      $result.productId = productId;
    }
    if (groupId != null) {
      $result.groupId = groupId;
    }
    if (properties != null) {
      $result.properties = properties;
    }
    return $result;
  }
  IncomingPaymentNotifyRequest._() : super();
  factory IncomingPaymentNotifyRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory IncomingPaymentNotifyRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'IncomingPaymentNotifyRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'operations.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'transactionId')
    ..aOM<$7.Money>(2, _omitFieldNames ? '' : 'amount', subBuilder: $7.Money.create)
    ..aOS(3, _omitFieldNames ? '' : 'payerReference')
    ..aOS(4, _omitFieldNames ? '' : 'payerName')
    ..aOS(5, _omitFieldNames ? '' : 'productId')
    ..aOS(6, _omitFieldNames ? '' : 'groupId')
    ..aOM<$6.Struct>(7, _omitFieldNames ? '' : 'properties', subBuilder: $6.Struct.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  IncomingPaymentNotifyRequest clone() => IncomingPaymentNotifyRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  IncomingPaymentNotifyRequest copyWith(void Function(IncomingPaymentNotifyRequest) updates) => super.copyWith((message) => updates(message as IncomingPaymentNotifyRequest)) as IncomingPaymentNotifyRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static IncomingPaymentNotifyRequest create() => IncomingPaymentNotifyRequest._();
  IncomingPaymentNotifyRequest createEmptyInstance() => create();
  static $pb.PbList<IncomingPaymentNotifyRequest> createRepeated() => $pb.PbList<IncomingPaymentNotifyRequest>();
  @$core.pragma('dart2js:noInline')
  static IncomingPaymentNotifyRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<IncomingPaymentNotifyRequest>(create);
  static IncomingPaymentNotifyRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get transactionId => $_getSZ(0);
  @$pb.TagNumber(1)
  set transactionId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTransactionId() => $_has(0);
  @$pb.TagNumber(1)
  void clearTransactionId() => clearField(1);

  @$pb.TagNumber(2)
  $7.Money get amount => $_getN(1);
  @$pb.TagNumber(2)
  set amount($7.Money v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasAmount() => $_has(1);
  @$pb.TagNumber(2)
  void clearAmount() => clearField(2);
  @$pb.TagNumber(2)
  $7.Money ensureAmount() => $_ensure(1);

  @$pb.TagNumber(3)
  $core.String get payerReference => $_getSZ(2);
  @$pb.TagNumber(3)
  set payerReference($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasPayerReference() => $_has(2);
  @$pb.TagNumber(3)
  void clearPayerReference() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get payerName => $_getSZ(3);
  @$pb.TagNumber(4)
  set payerName($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasPayerName() => $_has(3);
  @$pb.TagNumber(4)
  void clearPayerName() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get productId => $_getSZ(4);
  @$pb.TagNumber(5)
  set productId($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasProductId() => $_has(4);
  @$pb.TagNumber(5)
  void clearProductId() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get groupId => $_getSZ(5);
  @$pb.TagNumber(6)
  set groupId($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasGroupId() => $_has(5);
  @$pb.TagNumber(6)
  void clearGroupId() => clearField(6);

  @$pb.TagNumber(7)
  $6.Struct get properties => $_getN(6);
  @$pb.TagNumber(7)
  set properties($6.Struct v) { setField(7, v); }
  @$pb.TagNumber(7)
  $core.bool hasProperties() => $_has(6);
  @$pb.TagNumber(7)
  void clearProperties() => clearField(7);
  @$pb.TagNumber(7)
  $6.Struct ensureProperties() => $_ensure(6);
}

class IncomingPaymentNotifyResponse extends $pb.GeneratedMessage {
  factory IncomingPaymentNotifyResponse({
    $core.String? paymentId,
    $core.String? status,
    $6.Struct? result,
  }) {
    final $result = create();
    if (paymentId != null) {
      $result.paymentId = paymentId;
    }
    if (status != null) {
      $result.status = status;
    }
    if (result != null) {
      $result.result = result;
    }
    return $result;
  }
  IncomingPaymentNotifyResponse._() : super();
  factory IncomingPaymentNotifyResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory IncomingPaymentNotifyResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'IncomingPaymentNotifyResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'operations.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'paymentId')
    ..aOS(2, _omitFieldNames ? '' : 'status')
    ..aOM<$6.Struct>(3, _omitFieldNames ? '' : 'result', subBuilder: $6.Struct.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  IncomingPaymentNotifyResponse clone() => IncomingPaymentNotifyResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  IncomingPaymentNotifyResponse copyWith(void Function(IncomingPaymentNotifyResponse) updates) => super.copyWith((message) => updates(message as IncomingPaymentNotifyResponse)) as IncomingPaymentNotifyResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static IncomingPaymentNotifyResponse create() => IncomingPaymentNotifyResponse._();
  IncomingPaymentNotifyResponse createEmptyInstance() => create();
  static $pb.PbList<IncomingPaymentNotifyResponse> createRepeated() => $pb.PbList<IncomingPaymentNotifyResponse>();
  @$core.pragma('dart2js:noInline')
  static IncomingPaymentNotifyResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<IncomingPaymentNotifyResponse>(create);
  static IncomingPaymentNotifyResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get paymentId => $_getSZ(0);
  @$pb.TagNumber(1)
  set paymentId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPaymentId() => $_has(0);
  @$pb.TagNumber(1)
  void clearPaymentId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get status => $_getSZ(1);
  @$pb.TagNumber(2)
  set status($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasStatus() => $_has(1);
  @$pb.TagNumber(2)
  void clearStatus() => clearField(2);

  @$pb.TagNumber(3)
  $6.Struct get result => $_getN(2);
  @$pb.TagNumber(3)
  set result($6.Struct v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasResult() => $_has(2);
  @$pb.TagNumber(3)
  void clearResult() => clearField(3);
  @$pb.TagNumber(3)
  $6.Struct ensureResult() => $_ensure(2);
}

/// PaymentAllocateRequest triggers allocation of an identified payment to obligations.
class PaymentAllocateRequest extends $pb.GeneratedMessage {
  factory PaymentAllocateRequest({
    $core.String? paymentId,
  }) {
    final $result = create();
    if (paymentId != null) {
      $result.paymentId = paymentId;
    }
    return $result;
  }
  PaymentAllocateRequest._() : super();
  factory PaymentAllocateRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PaymentAllocateRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PaymentAllocateRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'operations.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'paymentId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PaymentAllocateRequest clone() => PaymentAllocateRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PaymentAllocateRequest copyWith(void Function(PaymentAllocateRequest) updates) => super.copyWith((message) => updates(message as PaymentAllocateRequest)) as PaymentAllocateRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PaymentAllocateRequest create() => PaymentAllocateRequest._();
  PaymentAllocateRequest createEmptyInstance() => create();
  static $pb.PbList<PaymentAllocateRequest> createRepeated() => $pb.PbList<PaymentAllocateRequest>();
  @$core.pragma('dart2js:noInline')
  static PaymentAllocateRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PaymentAllocateRequest>(create);
  static PaymentAllocateRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get paymentId => $_getSZ(0);
  @$pb.TagNumber(1)
  set paymentId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPaymentId() => $_has(0);
  @$pb.TagNumber(1)
  void clearPaymentId() => clearField(1);
}

class PaymentAllocateResponse extends $pb.GeneratedMessage {
  factory PaymentAllocateResponse({
    $6.Struct? result,
  }) {
    final $result = create();
    if (result != null) {
      $result.result = result;
    }
    return $result;
  }
  PaymentAllocateResponse._() : super();
  factory PaymentAllocateResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PaymentAllocateResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PaymentAllocateResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'operations.v1'), createEmptyInstance: create)
    ..aOM<$6.Struct>(1, _omitFieldNames ? '' : 'result', subBuilder: $6.Struct.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PaymentAllocateResponse clone() => PaymentAllocateResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PaymentAllocateResponse copyWith(void Function(PaymentAllocateResponse) updates) => super.copyWith((message) => updates(message as PaymentAllocateResponse)) as PaymentAllocateResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PaymentAllocateResponse create() => PaymentAllocateResponse._();
  PaymentAllocateResponse createEmptyInstance() => create();
  static $pb.PbList<PaymentAllocateResponse> createRepeated() => $pb.PbList<PaymentAllocateResponse>();
  @$core.pragma('dart2js:noInline')
  static PaymentAllocateResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PaymentAllocateResponse>(create);
  static PaymentAllocateResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $6.Struct get result => $_getN(0);
  @$pb.TagNumber(1)
  set result($6.Struct v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasResult() => $_has(0);
  @$pb.TagNumber(1)
  void clearResult() => clearField(1);
  @$pb.TagNumber(1)
  $6.Struct ensureResult() => $_ensure(0);
}

class OperationsServiceApi {
  $pb.RpcClient _client;
  OperationsServiceApi(this._client);

  $async.Future<TransferOrderExecuteResponse> transferOrderExecute($pb.ClientContext? ctx, TransferOrderExecuteRequest request) =>
    _client.invoke<TransferOrderExecuteResponse>(ctx, 'OperationsService', 'TransferOrderExecute', request, TransferOrderExecuteResponse())
  ;
  $async.Future<TransferOrderSearchResponse> transferOrderSearch($pb.ClientContext? ctx, TransferOrderSearchRequest request) =>
    _client.invoke<TransferOrderSearchResponse>(ctx, 'OperationsService', 'TransferOrderSearch', request, TransferOrderSearchResponse())
  ;
  $async.Future<IncomingPaymentNotifyResponse> incomingPaymentNotify($pb.ClientContext? ctx, IncomingPaymentNotifyRequest request) =>
    _client.invoke<IncomingPaymentNotifyResponse>(ctx, 'OperationsService', 'IncomingPaymentNotify', request, IncomingPaymentNotifyResponse())
  ;
  $async.Future<PaymentAllocateResponse> paymentAllocate($pb.ClientContext? ctx, PaymentAllocateRequest request) =>
    _client.invoke<PaymentAllocateResponse>(ctx, 'OperationsService', 'PaymentAllocate', request, PaymentAllocateResponse())
  ;
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
