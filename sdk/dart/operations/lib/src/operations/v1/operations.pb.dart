// This is a generated file - do not edit.
//
// Generated from operations/v1/operations.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;
import 'package:protobuf/well_known_types/google/protobuf/struct.pb.dart' as $1;
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart'
    as $3;

import '../../common/v1/common.pb.dart' as $2;
import '../../common/v1/money.pb.dart' as $0;
import 'operations.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'operations.pbenum.dart';

class TransferOrderObject extends $pb.GeneratedMessage {
  factory TransferOrderObject({
    $core.String? id,
    $core.String? debitAccountRef,
    $core.String? creditAccountRef,
    $0.Money? amount,
    @$core.Deprecated('This field is deprecated.') $core.int? orderType,
    $core.String? reference,
    $core.String? description,
    $1.Struct? extraData,
    $2.STATE? state,
    TransferOrderType? transferType,
  }) {
    final result = TransferOrderObject._();
    if (id != null) result.id = id;
    if (debitAccountRef != null) result.debitAccountRef = debitAccountRef;
    if (creditAccountRef != null) result.creditAccountRef = creditAccountRef;
    if (amount != null) result.amount = amount;
    if (orderType != null) result.orderType = orderType;
    if (reference != null) result.reference = reference;
    if (description != null) result.description = description;
    if (extraData != null) result.extraData = extraData;
    if (state != null) result.state = state;
    if (transferType != null) result.transferType = transferType;
    return result;
  }

  TransferOrderObject._();

  factory TransferOrderObject.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TransferOrderObject()..mergeFromBuffer(data, registry);
  factory TransferOrderObject.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TransferOrderObject()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TransferOrderObject',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'operations.v1'),
      createEmptyInstance: TransferOrderObject.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'debitAccountRef')
    ..aOS(3, _omitFieldNames ? '' : 'creditAccountRef')
    ..aOM<$0.Money>(4, _omitFieldNames ? '' : 'amount',
        subBuilder: $0.Money.$_createMessage)
    ..aI(6, _omitFieldNames ? '' : 'orderType')
    ..aOS(7, _omitFieldNames ? '' : 'reference')
    ..aOS(8, _omitFieldNames ? '' : 'description')
    ..aOM<$1.Struct>(9, _omitFieldNames ? '' : 'extraData',
        subBuilder: $1.Struct.$_createMessage)
    ..aE<$2.STATE>(10, _omitFieldNames ? '' : 'state',
        enumValues: $2.STATE.values)
    ..aE<TransferOrderType>(11, _omitFieldNames ? '' : 'transferType',
        enumValues: TransferOrderType.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TransferOrderObject clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TransferOrderObject copyWith(void Function(TransferOrderObject) updates) =>
      super.copyWith((message) => updates(message as TransferOrderObject))
          as TransferOrderObject;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core
      .Deprecated('Use TransferOrderObject() / TransferOrderObject.new instead')
  static TransferOrderObject create() => TransferOrderObject._();
  static $pb.GeneratedMessage $_createMessage() => TransferOrderObject._();
  @$core.override
  TransferOrderObject createEmptyInstance() => TransferOrderObject._();
  @$core.pragma('dart2js:noInline')
  static TransferOrderObject getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TransferOrderObject>(
          TransferOrderObject.$_createMessage);
  static TransferOrderObject? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get debitAccountRef => $_getSZ(1);
  @$pb.TagNumber(2)
  set debitAccountRef($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDebitAccountRef() => $_has(1);
  @$pb.TagNumber(2)
  void clearDebitAccountRef() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get creditAccountRef => $_getSZ(2);
  @$pb.TagNumber(3)
  set creditAccountRef($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCreditAccountRef() => $_has(2);
  @$pb.TagNumber(3)
  void clearCreditAccountRef() => $_clearField(3);

  @$pb.TagNumber(4)
  $0.Money get amount => $_getN(3);
  @$pb.TagNumber(4)
  set amount($0.Money value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasAmount() => $_has(3);
  @$pb.TagNumber(4)
  void clearAmount() => $_clearField(4);
  @$pb.TagNumber(4)
  $0.Money ensureAmount() => $_ensure(3);

  /// Deprecated: use transfer_type. Kept for existing clients; both fields
  /// carry the same value.
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(6)
  $core.int get orderType => $_getIZ(4);
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(6)
  set orderType($core.int value) => $_setSignedInt32(4, value);
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(6)
  $core.bool hasOrderType() => $_has(4);
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(6)
  void clearOrderType() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get reference => $_getSZ(5);
  @$pb.TagNumber(7)
  set reference($core.String value) => $_setString(5, value);
  @$pb.TagNumber(7)
  $core.bool hasReference() => $_has(5);
  @$pb.TagNumber(7)
  void clearReference() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get description => $_getSZ(6);
  @$pb.TagNumber(8)
  set description($core.String value) => $_setString(6, value);
  @$pb.TagNumber(8)
  $core.bool hasDescription() => $_has(6);
  @$pb.TagNumber(8)
  void clearDescription() => $_clearField(8);

  @$pb.TagNumber(9)
  $1.Struct get extraData => $_getN(7);
  @$pb.TagNumber(9)
  set extraData($1.Struct value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasExtraData() => $_has(7);
  @$pb.TagNumber(9)
  void clearExtraData() => $_clearField(9);
  @$pb.TagNumber(9)
  $1.Struct ensureExtraData() => $_ensure(7);

  @$pb.TagNumber(10)
  $2.STATE get state => $_getN(8);
  @$pb.TagNumber(10)
  set state($2.STATE value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasState() => $_has(8);
  @$pb.TagNumber(10)
  void clearState() => $_clearField(10);

  @$pb.TagNumber(11)
  TransferOrderType get transferType => $_getN(9);
  @$pb.TagNumber(11)
  set transferType(TransferOrderType value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasTransferType() => $_has(9);
  @$pb.TagNumber(11)
  void clearTransferType() => $_clearField(11);
}

class TransferOrderExecuteRequest extends $pb.GeneratedMessage {
  factory TransferOrderExecuteRequest({
    TransferOrderObject? data,
  }) {
    final result = TransferOrderExecuteRequest._();
    if (data != null) result.data = data;
    return result;
  }

  TransferOrderExecuteRequest._();

  factory TransferOrderExecuteRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TransferOrderExecuteRequest()..mergeFromBuffer(data, registry);
  factory TransferOrderExecuteRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TransferOrderExecuteRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TransferOrderExecuteRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'operations.v1'),
      createEmptyInstance: TransferOrderExecuteRequest.$_createMessage)
    ..aOM<TransferOrderObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: TransferOrderObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TransferOrderExecuteRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TransferOrderExecuteRequest copyWith(
          void Function(TransferOrderExecuteRequest) updates) =>
      super.copyWith(
              (message) => updates(message as TransferOrderExecuteRequest))
          as TransferOrderExecuteRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use TransferOrderExecuteRequest() / TransferOrderExecuteRequest.new instead')
  static TransferOrderExecuteRequest create() =>
      TransferOrderExecuteRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      TransferOrderExecuteRequest._();
  @$core.override
  TransferOrderExecuteRequest createEmptyInstance() =>
      TransferOrderExecuteRequest._();
  @$core.pragma('dart2js:noInline')
  static TransferOrderExecuteRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TransferOrderExecuteRequest>(
          TransferOrderExecuteRequest.$_createMessage);
  static TransferOrderExecuteRequest? _defaultInstance;

  @$pb.TagNumber(1)
  TransferOrderObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(TransferOrderObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  TransferOrderObject ensureData() => $_ensure(0);
}

class TransferOrderExecuteResponse extends $pb.GeneratedMessage {
  factory TransferOrderExecuteResponse({
    TransferOrderObject? data,
  }) {
    final result = TransferOrderExecuteResponse._();
    if (data != null) result.data = data;
    return result;
  }

  TransferOrderExecuteResponse._();

  factory TransferOrderExecuteResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TransferOrderExecuteResponse()..mergeFromBuffer(data, registry);
  factory TransferOrderExecuteResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TransferOrderExecuteResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TransferOrderExecuteResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'operations.v1'),
      createEmptyInstance: TransferOrderExecuteResponse.$_createMessage)
    ..aOM<TransferOrderObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: TransferOrderObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TransferOrderExecuteResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TransferOrderExecuteResponse copyWith(
          void Function(TransferOrderExecuteResponse) updates) =>
      super.copyWith(
              (message) => updates(message as TransferOrderExecuteResponse))
          as TransferOrderExecuteResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use TransferOrderExecuteResponse() / TransferOrderExecuteResponse.new instead')
  static TransferOrderExecuteResponse create() =>
      TransferOrderExecuteResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      TransferOrderExecuteResponse._();
  @$core.override
  TransferOrderExecuteResponse createEmptyInstance() =>
      TransferOrderExecuteResponse._();
  @$core.pragma('dart2js:noInline')
  static TransferOrderExecuteResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TransferOrderExecuteResponse>(
          TransferOrderExecuteResponse.$_createMessage);
  static TransferOrderExecuteResponse? _defaultInstance;

  @$pb.TagNumber(1)
  TransferOrderObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(TransferOrderObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  TransferOrderObject ensureData() => $_ensure(0);
}

class TransferOrderSearchRequest extends $pb.GeneratedMessage {
  factory TransferOrderSearchRequest({
    $core.String? query,
    @$core.Deprecated('This field is deprecated.') $core.int? orderType,
    $2.PageCursor? cursor,
    TransferOrderType? transferType,
  }) {
    final result = TransferOrderSearchRequest._();
    if (query != null) result.query = query;
    if (orderType != null) result.orderType = orderType;
    if (cursor != null) result.cursor = cursor;
    if (transferType != null) result.transferType = transferType;
    return result;
  }

  TransferOrderSearchRequest._();

  factory TransferOrderSearchRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TransferOrderSearchRequest()..mergeFromBuffer(data, registry);
  factory TransferOrderSearchRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TransferOrderSearchRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TransferOrderSearchRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'operations.v1'),
      createEmptyInstance: TransferOrderSearchRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'query')
    ..aI(2, _omitFieldNames ? '' : 'orderType')
    ..aOM<$2.PageCursor>(3, _omitFieldNames ? '' : 'cursor',
        subBuilder: $2.PageCursor.$_createMessage)
    ..aE<TransferOrderType>(4, _omitFieldNames ? '' : 'transferType',
        enumValues: TransferOrderType.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TransferOrderSearchRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TransferOrderSearchRequest copyWith(
          void Function(TransferOrderSearchRequest) updates) =>
      super.copyWith(
              (message) => updates(message as TransferOrderSearchRequest))
          as TransferOrderSearchRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use TransferOrderSearchRequest() / TransferOrderSearchRequest.new instead')
  static TransferOrderSearchRequest create() => TransferOrderSearchRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      TransferOrderSearchRequest._();
  @$core.override
  TransferOrderSearchRequest createEmptyInstance() =>
      TransferOrderSearchRequest._();
  @$core.pragma('dart2js:noInline')
  static TransferOrderSearchRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TransferOrderSearchRequest>(
          TransferOrderSearchRequest.$_createMessage);
  static TransferOrderSearchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get query => $_getSZ(0);
  @$pb.TagNumber(1)
  set query($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasQuery() => $_has(0);
  @$pb.TagNumber(1)
  void clearQuery() => $_clearField(1);

  /// Deprecated: use transfer_type. When both are set transfer_type wins.
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(2)
  $core.int get orderType => $_getIZ(1);
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(2)
  set orderType($core.int value) => $_setSignedInt32(1, value);
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(2)
  $core.bool hasOrderType() => $_has(1);
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(2)
  void clearOrderType() => $_clearField(2);

  @$pb.TagNumber(3)
  $2.PageCursor get cursor => $_getN(2);
  @$pb.TagNumber(3)
  set cursor($2.PageCursor value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasCursor() => $_has(2);
  @$pb.TagNumber(3)
  void clearCursor() => $_clearField(3);
  @$pb.TagNumber(3)
  $2.PageCursor ensureCursor() => $_ensure(2);

  @$pb.TagNumber(4)
  TransferOrderType get transferType => $_getN(3);
  @$pb.TagNumber(4)
  set transferType(TransferOrderType value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasTransferType() => $_has(3);
  @$pb.TagNumber(4)
  void clearTransferType() => $_clearField(4);
}

class TransferOrderSearchResponse extends $pb.GeneratedMessage {
  factory TransferOrderSearchResponse({
    $core.Iterable<TransferOrderObject>? data,
    $core.String? nextCursor,
  }) {
    final result = TransferOrderSearchResponse._();
    if (data != null) result.data.addAll(data);
    if (nextCursor != null) result.nextCursor = nextCursor;
    return result;
  }

  TransferOrderSearchResponse._();

  factory TransferOrderSearchResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TransferOrderSearchResponse()..mergeFromBuffer(data, registry);
  factory TransferOrderSearchResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TransferOrderSearchResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TransferOrderSearchResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'operations.v1'),
      createEmptyInstance: TransferOrderSearchResponse.$_createMessage)
    ..pPM<TransferOrderObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: TransferOrderObject.$_createMessage)
    ..aOS(2, _omitFieldNames ? '' : 'nextCursor')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TransferOrderSearchResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TransferOrderSearchResponse copyWith(
          void Function(TransferOrderSearchResponse) updates) =>
      super.copyWith(
              (message) => updates(message as TransferOrderSearchResponse))
          as TransferOrderSearchResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use TransferOrderSearchResponse() / TransferOrderSearchResponse.new instead')
  static TransferOrderSearchResponse create() =>
      TransferOrderSearchResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      TransferOrderSearchResponse._();
  @$core.override
  TransferOrderSearchResponse createEmptyInstance() =>
      TransferOrderSearchResponse._();
  @$core.pragma('dart2js:noInline')
  static TransferOrderSearchResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TransferOrderSearchResponse>(
          TransferOrderSearchResponse.$_createMessage);
  static TransferOrderSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<TransferOrderObject> get data => $_getList(0);

  /// next_cursor is the opaque cursor for the page after this one; empty on
  /// the last page.
  @$pb.TagNumber(2)
  $core.String get nextCursor => $_getSZ(1);
  @$pb.TagNumber(2)
  set nextCursor($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNextCursor() => $_has(1);
  @$pb.TagNumber(2)
  void clearNextCursor() => $_clearField(2);
}

/// IncomingPaymentNotifyRequest notifies the system of a new payment received.
class IncomingPaymentNotifyRequest extends $pb.GeneratedMessage {
  factory IncomingPaymentNotifyRequest({
    $core.String? transactionId,
    $0.Money? amount,
    $core.String? payerReference,
    $core.String? payerName,
    $core.String? productId,
    $core.String? groupId,
    $1.Struct? properties,
  }) {
    final result = IncomingPaymentNotifyRequest._();
    if (transactionId != null) result.transactionId = transactionId;
    if (amount != null) result.amount = amount;
    if (payerReference != null) result.payerReference = payerReference;
    if (payerName != null) result.payerName = payerName;
    if (productId != null) result.productId = productId;
    if (groupId != null) result.groupId = groupId;
    if (properties != null) result.properties = properties;
    return result;
  }

  IncomingPaymentNotifyRequest._();

  factory IncomingPaymentNotifyRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      IncomingPaymentNotifyRequest()..mergeFromBuffer(data, registry);
  factory IncomingPaymentNotifyRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      IncomingPaymentNotifyRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'IncomingPaymentNotifyRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'operations.v1'),
      createEmptyInstance: IncomingPaymentNotifyRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'transactionId')
    ..aOM<$0.Money>(2, _omitFieldNames ? '' : 'amount',
        subBuilder: $0.Money.$_createMessage)
    ..aOS(3, _omitFieldNames ? '' : 'payerReference')
    ..aOS(4, _omitFieldNames ? '' : 'payerName')
    ..aOS(5, _omitFieldNames ? '' : 'productId')
    ..aOS(6, _omitFieldNames ? '' : 'groupId')
    ..aOM<$1.Struct>(7, _omitFieldNames ? '' : 'properties',
        subBuilder: $1.Struct.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  IncomingPaymentNotifyRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  IncomingPaymentNotifyRequest copyWith(
          void Function(IncomingPaymentNotifyRequest) updates) =>
      super.copyWith(
              (message) => updates(message as IncomingPaymentNotifyRequest))
          as IncomingPaymentNotifyRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use IncomingPaymentNotifyRequest() / IncomingPaymentNotifyRequest.new instead')
  static IncomingPaymentNotifyRequest create() =>
      IncomingPaymentNotifyRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      IncomingPaymentNotifyRequest._();
  @$core.override
  IncomingPaymentNotifyRequest createEmptyInstance() =>
      IncomingPaymentNotifyRequest._();
  @$core.pragma('dart2js:noInline')
  static IncomingPaymentNotifyRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<IncomingPaymentNotifyRequest>(
          IncomingPaymentNotifyRequest.$_createMessage);
  static IncomingPaymentNotifyRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get transactionId => $_getSZ(0);
  @$pb.TagNumber(1)
  set transactionId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTransactionId() => $_has(0);
  @$pb.TagNumber(1)
  void clearTransactionId() => $_clearField(1);

  @$pb.TagNumber(2)
  $0.Money get amount => $_getN(1);
  @$pb.TagNumber(2)
  set amount($0.Money value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasAmount() => $_has(1);
  @$pb.TagNumber(2)
  void clearAmount() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.Money ensureAmount() => $_ensure(1);

  @$pb.TagNumber(3)
  $core.String get payerReference => $_getSZ(2);
  @$pb.TagNumber(3)
  set payerReference($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPayerReference() => $_has(2);
  @$pb.TagNumber(3)
  void clearPayerReference() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get payerName => $_getSZ(3);
  @$pb.TagNumber(4)
  set payerName($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPayerName() => $_has(3);
  @$pb.TagNumber(4)
  void clearPayerName() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get productId => $_getSZ(4);
  @$pb.TagNumber(5)
  set productId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasProductId() => $_has(4);
  @$pb.TagNumber(5)
  void clearProductId() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get groupId => $_getSZ(5);
  @$pb.TagNumber(6)
  set groupId($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasGroupId() => $_has(5);
  @$pb.TagNumber(6)
  void clearGroupId() => $_clearField(6);

  @$pb.TagNumber(7)
  $1.Struct get properties => $_getN(6);
  @$pb.TagNumber(7)
  set properties($1.Struct value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasProperties() => $_has(6);
  @$pb.TagNumber(7)
  void clearProperties() => $_clearField(7);
  @$pb.TagNumber(7)
  $1.Struct ensureProperties() => $_ensure(6);
}

class IncomingPaymentNotifyResponse extends $pb.GeneratedMessage {
  factory IncomingPaymentNotifyResponse({
    $core.String? paymentId,
    $core.String? status,
    $1.Struct? result,
  }) {
    final result$ = IncomingPaymentNotifyResponse._();
    if (paymentId != null) result$.paymentId = paymentId;
    if (status != null) result$.status = status;
    if (result != null) result$.result = result;
    return result$;
  }

  IncomingPaymentNotifyResponse._();

  factory IncomingPaymentNotifyResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      IncomingPaymentNotifyResponse()..mergeFromBuffer(data, registry);
  factory IncomingPaymentNotifyResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      IncomingPaymentNotifyResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'IncomingPaymentNotifyResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'operations.v1'),
      createEmptyInstance: IncomingPaymentNotifyResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'paymentId')
    ..aOS(2, _omitFieldNames ? '' : 'status')
    ..aOM<$1.Struct>(3, _omitFieldNames ? '' : 'result',
        subBuilder: $1.Struct.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  IncomingPaymentNotifyResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  IncomingPaymentNotifyResponse copyWith(
          void Function(IncomingPaymentNotifyResponse) updates) =>
      super.copyWith(
              (message) => updates(message as IncomingPaymentNotifyResponse))
          as IncomingPaymentNotifyResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use IncomingPaymentNotifyResponse() / IncomingPaymentNotifyResponse.new instead')
  static IncomingPaymentNotifyResponse create() =>
      IncomingPaymentNotifyResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      IncomingPaymentNotifyResponse._();
  @$core.override
  IncomingPaymentNotifyResponse createEmptyInstance() =>
      IncomingPaymentNotifyResponse._();
  @$core.pragma('dart2js:noInline')
  static IncomingPaymentNotifyResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<IncomingPaymentNotifyResponse>(
          IncomingPaymentNotifyResponse.$_createMessage);
  static IncomingPaymentNotifyResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get paymentId => $_getSZ(0);
  @$pb.TagNumber(1)
  set paymentId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPaymentId() => $_has(0);
  @$pb.TagNumber(1)
  void clearPaymentId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get status => $_getSZ(1);
  @$pb.TagNumber(2)
  set status($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasStatus() => $_has(1);
  @$pb.TagNumber(2)
  void clearStatus() => $_clearField(2);

  @$pb.TagNumber(3)
  $1.Struct get result => $_getN(2);
  @$pb.TagNumber(3)
  set result($1.Struct value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasResult() => $_has(2);
  @$pb.TagNumber(3)
  void clearResult() => $_clearField(3);
  @$pb.TagNumber(3)
  $1.Struct ensureResult() => $_ensure(2);
}

/// PaymentAllocateRequest triggers allocation of an identified payment to obligations.
class PaymentAllocateRequest extends $pb.GeneratedMessage {
  factory PaymentAllocateRequest({
    $core.String? paymentId,
  }) {
    final result = PaymentAllocateRequest._();
    if (paymentId != null) result.paymentId = paymentId;
    return result;
  }

  PaymentAllocateRequest._();

  factory PaymentAllocateRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PaymentAllocateRequest()..mergeFromBuffer(data, registry);
  factory PaymentAllocateRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PaymentAllocateRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PaymentAllocateRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'operations.v1'),
      createEmptyInstance: PaymentAllocateRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'paymentId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PaymentAllocateRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PaymentAllocateRequest copyWith(
          void Function(PaymentAllocateRequest) updates) =>
      super.copyWith((message) => updates(message as PaymentAllocateRequest))
          as PaymentAllocateRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use PaymentAllocateRequest() / PaymentAllocateRequest.new instead')
  static PaymentAllocateRequest create() => PaymentAllocateRequest._();
  static $pb.GeneratedMessage $_createMessage() => PaymentAllocateRequest._();
  @$core.override
  PaymentAllocateRequest createEmptyInstance() => PaymentAllocateRequest._();
  @$core.pragma('dart2js:noInline')
  static PaymentAllocateRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PaymentAllocateRequest>(
          PaymentAllocateRequest.$_createMessage);
  static PaymentAllocateRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get paymentId => $_getSZ(0);
  @$pb.TagNumber(1)
  set paymentId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPaymentId() => $_has(0);
  @$pb.TagNumber(1)
  void clearPaymentId() => $_clearField(1);
}

class PaymentAllocateResponse extends $pb.GeneratedMessage {
  factory PaymentAllocateResponse({
    $1.Struct? result,
  }) {
    final result$ = PaymentAllocateResponse._();
    if (result != null) result$.result = result;
    return result$;
  }

  PaymentAllocateResponse._();

  factory PaymentAllocateResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PaymentAllocateResponse()..mergeFromBuffer(data, registry);
  factory PaymentAllocateResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PaymentAllocateResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PaymentAllocateResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'operations.v1'),
      createEmptyInstance: PaymentAllocateResponse.$_createMessage)
    ..aOM<$1.Struct>(1, _omitFieldNames ? '' : 'result',
        subBuilder: $1.Struct.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PaymentAllocateResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PaymentAllocateResponse copyWith(
          void Function(PaymentAllocateResponse) updates) =>
      super.copyWith((message) => updates(message as PaymentAllocateResponse))
          as PaymentAllocateResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use PaymentAllocateResponse() / PaymentAllocateResponse.new instead')
  static PaymentAllocateResponse create() => PaymentAllocateResponse._();
  static $pb.GeneratedMessage $_createMessage() => PaymentAllocateResponse._();
  @$core.override
  PaymentAllocateResponse createEmptyInstance() => PaymentAllocateResponse._();
  @$core.pragma('dart2js:noInline')
  static PaymentAllocateResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PaymentAllocateResponse>(
          PaymentAllocateResponse.$_createMessage);
  static PaymentAllocateResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $1.Struct get result => $_getN(0);
  @$pb.TagNumber(1)
  set result($1.Struct value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasResult() => $_has(0);
  @$pb.TagNumber(1)
  void clearResult() => $_clearField(1);
  @$pb.TagNumber(1)
  $1.Struct ensureResult() => $_ensure(0);
}

/// IncomingPaymentObject is a payment the payment rail received. It carries
/// what the payer quoted and who it was matched to, never the payer's phone
/// or account: the rail's payer reference stays inside operations.
class IncomingPaymentObject extends $pb.GeneratedMessage {
  factory IncomingPaymentObject({
    $core.String? id,
    $core.String? transactionId,
    $0.Money? amount,
    $core.String? payerName,
    $core.String? reference,
    $core.String? productId,
    $core.bool? matched,
    $core.String? clientId,
    $core.String? loanAccountId,
    $core.String? identificationStrategy,
    $0.Money? unallocated,
    $2.STATE? state,
    $3.Timestamp? receivedAt,
    $core.String? assignedBy,
    $core.String? assignmentNote,
    $core.String? savingsAccountId,
  }) {
    final result = IncomingPaymentObject._();
    if (id != null) result.id = id;
    if (transactionId != null) result.transactionId = transactionId;
    if (amount != null) result.amount = amount;
    if (payerName != null) result.payerName = payerName;
    if (reference != null) result.reference = reference;
    if (productId != null) result.productId = productId;
    if (matched != null) result.matched = matched;
    if (clientId != null) result.clientId = clientId;
    if (loanAccountId != null) result.loanAccountId = loanAccountId;
    if (identificationStrategy != null)
      result.identificationStrategy = identificationStrategy;
    if (unallocated != null) result.unallocated = unallocated;
    if (state != null) result.state = state;
    if (receivedAt != null) result.receivedAt = receivedAt;
    if (assignedBy != null) result.assignedBy = assignedBy;
    if (assignmentNote != null) result.assignmentNote = assignmentNote;
    if (savingsAccountId != null) result.savingsAccountId = savingsAccountId;
    return result;
  }

  IncomingPaymentObject._();

  factory IncomingPaymentObject.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      IncomingPaymentObject()..mergeFromBuffer(data, registry);
  factory IncomingPaymentObject.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      IncomingPaymentObject()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'IncomingPaymentObject',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'operations.v1'),
      createEmptyInstance: IncomingPaymentObject.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'transactionId')
    ..aOM<$0.Money>(3, _omitFieldNames ? '' : 'amount',
        subBuilder: $0.Money.$_createMessage)
    ..aOS(4, _omitFieldNames ? '' : 'payerName')
    ..aOS(5, _omitFieldNames ? '' : 'reference')
    ..aOS(6, _omitFieldNames ? '' : 'productId')
    ..aOB(7, _omitFieldNames ? '' : 'matched')
    ..aOS(8, _omitFieldNames ? '' : 'clientId')
    ..aOS(9, _omitFieldNames ? '' : 'loanAccountId')
    ..aOS(10, _omitFieldNames ? '' : 'identificationStrategy')
    ..aOM<$0.Money>(11, _omitFieldNames ? '' : 'unallocated',
        subBuilder: $0.Money.$_createMessage)
    ..aE<$2.STATE>(12, _omitFieldNames ? '' : 'state',
        enumValues: $2.STATE.values)
    ..aOM<$3.Timestamp>(13, _omitFieldNames ? '' : 'receivedAt',
        subBuilder: $3.Timestamp.$_createMessage)
    ..aOS(14, _omitFieldNames ? '' : 'assignedBy')
    ..aOS(15, _omitFieldNames ? '' : 'assignmentNote')
    ..aOS(16, _omitFieldNames ? '' : 'savingsAccountId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  IncomingPaymentObject clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  IncomingPaymentObject copyWith(
          void Function(IncomingPaymentObject) updates) =>
      super.copyWith((message) => updates(message as IncomingPaymentObject))
          as IncomingPaymentObject;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use IncomingPaymentObject() / IncomingPaymentObject.new instead')
  static IncomingPaymentObject create() => IncomingPaymentObject._();
  static $pb.GeneratedMessage $_createMessage() => IncomingPaymentObject._();
  @$core.override
  IncomingPaymentObject createEmptyInstance() => IncomingPaymentObject._();
  @$core.pragma('dart2js:noInline')
  static IncomingPaymentObject getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<IncomingPaymentObject>(
          IncomingPaymentObject.$_createMessage);
  static IncomingPaymentObject? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  /// transaction_id is the rail's own id for the payment.
  @$pb.TagNumber(2)
  $core.String get transactionId => $_getSZ(1);
  @$pb.TagNumber(2)
  set transactionId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTransactionId() => $_has(1);
  @$pb.TagNumber(2)
  void clearTransactionId() => $_clearField(2);

  @$pb.TagNumber(3)
  $0.Money get amount => $_getN(2);
  @$pb.TagNumber(3)
  set amount($0.Money value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasAmount() => $_has(2);
  @$pb.TagNumber(3)
  void clearAmount() => $_clearField(3);
  @$pb.TagNumber(3)
  $0.Money ensureAmount() => $_ensure(2);

  @$pb.TagNumber(4)
  $core.String get payerName => $_getSZ(3);
  @$pb.TagNumber(4)
  set payerName($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPayerName() => $_has(3);
  @$pb.TagNumber(4)
  void clearPayerName() => $_clearField(4);

  /// reference is what the payer quoted, typically a loan account id.
  @$pb.TagNumber(5)
  $core.String get reference => $_getSZ(4);
  @$pb.TagNumber(5)
  set reference($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasReference() => $_has(4);
  @$pb.TagNumber(5)
  void clearReference() => $_clearField(5);

  /// product_id is the product whose collection account the rail credited.
  @$pb.TagNumber(6)
  $core.String get productId => $_getSZ(5);
  @$pb.TagNumber(6)
  set productId($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasProductId() => $_has(5);
  @$pb.TagNumber(6)
  void clearProductId() => $_clearField(6);

  /// matched is true once the payment is tied to a borrower's loan or a
  /// group member.
  @$pb.TagNumber(7)
  $core.bool get matched => $_getBF(6);
  @$pb.TagNumber(7)
  set matched($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(7)
  $core.bool hasMatched() => $_has(6);
  @$pb.TagNumber(7)
  void clearMatched() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get clientId => $_getSZ(7);
  @$pb.TagNumber(8)
  set clientId($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasClientId() => $_has(7);
  @$pb.TagNumber(8)
  void clearClientId() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get loanAccountId => $_getSZ(8);
  @$pb.TagNumber(9)
  set loanAccountId($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasLoanAccountId() => $_has(8);
  @$pb.TagNumber(9)
  void clearLoanAccountId() => $_clearField(9);

  /// identification_strategy says how it was matched; "staff_assigned" when
  /// a person tied an unmatched payment to its loan.
  @$pb.TagNumber(10)
  $core.String get identificationStrategy => $_getSZ(9);
  @$pb.TagNumber(10)
  set identificationStrategy($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasIdentificationStrategy() => $_has(9);
  @$pb.TagNumber(10)
  void clearIdentificationStrategy() => $_clearField(10);

  /// unallocated is what is still to be applied; zero once fully allocated.
  @$pb.TagNumber(11)
  $0.Money get unallocated => $_getN(10);
  @$pb.TagNumber(11)
  set unallocated($0.Money value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasUnallocated() => $_has(10);
  @$pb.TagNumber(11)
  void clearUnallocated() => $_clearField(11);
  @$pb.TagNumber(11)
  $0.Money ensureUnallocated() => $_ensure(10);

  @$pb.TagNumber(12)
  $2.STATE get state => $_getN(11);
  @$pb.TagNumber(12)
  set state($2.STATE value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasState() => $_has(11);
  @$pb.TagNumber(12)
  void clearState() => $_clearField(12);

  @$pb.TagNumber(13)
  $3.Timestamp get receivedAt => $_getN(12);
  @$pb.TagNumber(13)
  set receivedAt($3.Timestamp value) => $_setField(13, value);
  @$pb.TagNumber(13)
  $core.bool hasReceivedAt() => $_has(12);
  @$pb.TagNumber(13)
  void clearReceivedAt() => $_clearField(13);
  @$pb.TagNumber(13)
  $3.Timestamp ensureReceivedAt() => $_ensure(12);

  /// assigned_by is the profile that tied the payment to its loan, when a
  /// person did.
  @$pb.TagNumber(14)
  $core.String get assignedBy => $_getSZ(13);
  @$pb.TagNumber(14)
  set assignedBy($core.String value) => $_setString(13, value);
  @$pb.TagNumber(14)
  $core.bool hasAssignedBy() => $_has(13);
  @$pb.TagNumber(14)
  void clearAssignedBy() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.String get assignmentNote => $_getSZ(14);
  @$pb.TagNumber(15)
  set assignmentNote($core.String value) => $_setString(14, value);
  @$pb.TagNumber(15)
  $core.bool hasAssignmentNote() => $_has(14);
  @$pb.TagNumber(15)
  void clearAssignmentNote() => $_clearField(15);

  /// savings_account_id is set when the payment was a deposit to the payer's
  /// own savings account.
  @$pb.TagNumber(16)
  $core.String get savingsAccountId => $_getSZ(15);
  @$pb.TagNumber(16)
  set savingsAccountId($core.String value) => $_setString(15, value);
  @$pb.TagNumber(16)
  $core.bool hasSavingsAccountId() => $_has(15);
  @$pb.TagNumber(16)
  void clearSavingsAccountId() => $_clearField(16);
}

/// IncomingPaymentSearchRequest lists received payments, newest first.
class IncomingPaymentSearchRequest extends $pb.GeneratedMessage {
  factory IncomingPaymentSearchRequest({
    $core.String? query,
    $core.bool? unmatchedOnly,
    $core.String? productId,
    $2.PageCursor? cursor,
  }) {
    final result = IncomingPaymentSearchRequest._();
    if (query != null) result.query = query;
    if (unmatchedOnly != null) result.unmatchedOnly = unmatchedOnly;
    if (productId != null) result.productId = productId;
    if (cursor != null) result.cursor = cursor;
    return result;
  }

  IncomingPaymentSearchRequest._();

  factory IncomingPaymentSearchRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      IncomingPaymentSearchRequest()..mergeFromBuffer(data, registry);
  factory IncomingPaymentSearchRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      IncomingPaymentSearchRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'IncomingPaymentSearchRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'operations.v1'),
      createEmptyInstance: IncomingPaymentSearchRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'query')
    ..aOB(2, _omitFieldNames ? '' : 'unmatchedOnly')
    ..aOS(3, _omitFieldNames ? '' : 'productId')
    ..aOM<$2.PageCursor>(4, _omitFieldNames ? '' : 'cursor',
        subBuilder: $2.PageCursor.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  IncomingPaymentSearchRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  IncomingPaymentSearchRequest copyWith(
          void Function(IncomingPaymentSearchRequest) updates) =>
      super.copyWith(
              (message) => updates(message as IncomingPaymentSearchRequest))
          as IncomingPaymentSearchRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use IncomingPaymentSearchRequest() / IncomingPaymentSearchRequest.new instead')
  static IncomingPaymentSearchRequest create() =>
      IncomingPaymentSearchRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      IncomingPaymentSearchRequest._();
  @$core.override
  IncomingPaymentSearchRequest createEmptyInstance() =>
      IncomingPaymentSearchRequest._();
  @$core.pragma('dart2js:noInline')
  static IncomingPaymentSearchRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<IncomingPaymentSearchRequest>(
          IncomingPaymentSearchRequest.$_createMessage);
  static IncomingPaymentSearchRequest? _defaultInstance;

  /// query matches the transaction id, the quoted reference or the payer's
  /// name.
  @$pb.TagNumber(1)
  $core.String get query => $_getSZ(0);
  @$pb.TagNumber(1)
  set query($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasQuery() => $_has(0);
  @$pb.TagNumber(1)
  void clearQuery() => $_clearField(1);

  /// unmatched_only keeps the payments no borrower or member was found for.
  @$pb.TagNumber(2)
  $core.bool get unmatchedOnly => $_getBF(1);
  @$pb.TagNumber(2)
  set unmatchedOnly($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUnmatchedOnly() => $_has(1);
  @$pb.TagNumber(2)
  void clearUnmatchedOnly() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get productId => $_getSZ(2);
  @$pb.TagNumber(3)
  set productId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasProductId() => $_has(2);
  @$pb.TagNumber(3)
  void clearProductId() => $_clearField(3);

  @$pb.TagNumber(4)
  $2.PageCursor get cursor => $_getN(3);
  @$pb.TagNumber(4)
  set cursor($2.PageCursor value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasCursor() => $_has(3);
  @$pb.TagNumber(4)
  void clearCursor() => $_clearField(4);
  @$pb.TagNumber(4)
  $2.PageCursor ensureCursor() => $_ensure(3);
}

class IncomingPaymentSearchResponse extends $pb.GeneratedMessage {
  factory IncomingPaymentSearchResponse({
    $core.Iterable<IncomingPaymentObject>? data,
  }) {
    final result = IncomingPaymentSearchResponse._();
    if (data != null) result.data.addAll(data);
    return result;
  }

  IncomingPaymentSearchResponse._();

  factory IncomingPaymentSearchResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      IncomingPaymentSearchResponse()..mergeFromBuffer(data, registry);
  factory IncomingPaymentSearchResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      IncomingPaymentSearchResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'IncomingPaymentSearchResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'operations.v1'),
      createEmptyInstance: IncomingPaymentSearchResponse.$_createMessage)
    ..pPM<IncomingPaymentObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: IncomingPaymentObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  IncomingPaymentSearchResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  IncomingPaymentSearchResponse copyWith(
          void Function(IncomingPaymentSearchResponse) updates) =>
      super.copyWith(
              (message) => updates(message as IncomingPaymentSearchResponse))
          as IncomingPaymentSearchResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use IncomingPaymentSearchResponse() / IncomingPaymentSearchResponse.new instead')
  static IncomingPaymentSearchResponse create() =>
      IncomingPaymentSearchResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      IncomingPaymentSearchResponse._();
  @$core.override
  IncomingPaymentSearchResponse createEmptyInstance() =>
      IncomingPaymentSearchResponse._();
  @$core.pragma('dart2js:noInline')
  static IncomingPaymentSearchResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<IncomingPaymentSearchResponse>(
          IncomingPaymentSearchResponse.$_createMessage);
  static IncomingPaymentSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<IncomingPaymentObject> get data => $_getList(0);
}

/// IncomingPaymentAssignRequest ties an unmatched payment to the loan or the
/// savings account it was meant for, and allocates it. The amount is the
/// rail's; nobody types one. Name exactly one target: the loan must take
/// repayments, the savings account must be open and individually owned, and
/// either must belong to the product the rail credited.
class IncomingPaymentAssignRequest extends $pb.GeneratedMessage {
  factory IncomingPaymentAssignRequest({
    $core.String? paymentId,
    $core.String? loanAccountId,
    $core.String? note,
    $core.String? savingsAccountId,
  }) {
    final result = IncomingPaymentAssignRequest._();
    if (paymentId != null) result.paymentId = paymentId;
    if (loanAccountId != null) result.loanAccountId = loanAccountId;
    if (note != null) result.note = note;
    if (savingsAccountId != null) result.savingsAccountId = savingsAccountId;
    return result;
  }

  IncomingPaymentAssignRequest._();

  factory IncomingPaymentAssignRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      IncomingPaymentAssignRequest()..mergeFromBuffer(data, registry);
  factory IncomingPaymentAssignRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      IncomingPaymentAssignRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'IncomingPaymentAssignRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'operations.v1'),
      createEmptyInstance: IncomingPaymentAssignRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'paymentId')
    ..aOS(2, _omitFieldNames ? '' : 'loanAccountId')
    ..aOS(3, _omitFieldNames ? '' : 'note')
    ..aOS(4, _omitFieldNames ? '' : 'savingsAccountId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  IncomingPaymentAssignRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  IncomingPaymentAssignRequest copyWith(
          void Function(IncomingPaymentAssignRequest) updates) =>
      super.copyWith(
              (message) => updates(message as IncomingPaymentAssignRequest))
          as IncomingPaymentAssignRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use IncomingPaymentAssignRequest() / IncomingPaymentAssignRequest.new instead')
  static IncomingPaymentAssignRequest create() =>
      IncomingPaymentAssignRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      IncomingPaymentAssignRequest._();
  @$core.override
  IncomingPaymentAssignRequest createEmptyInstance() =>
      IncomingPaymentAssignRequest._();
  @$core.pragma('dart2js:noInline')
  static IncomingPaymentAssignRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<IncomingPaymentAssignRequest>(
          IncomingPaymentAssignRequest.$_createMessage);
  static IncomingPaymentAssignRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get paymentId => $_getSZ(0);
  @$pb.TagNumber(1)
  set paymentId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPaymentId() => $_has(0);
  @$pb.TagNumber(1)
  void clearPaymentId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get loanAccountId => $_getSZ(1);
  @$pb.TagNumber(2)
  set loanAccountId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLoanAccountId() => $_has(1);
  @$pb.TagNumber(2)
  void clearLoanAccountId() => $_clearField(2);

  /// note says why the payment belongs to this loan; it is kept on the
  /// payment for audit.
  @$pb.TagNumber(3)
  $core.String get note => $_getSZ(2);
  @$pb.TagNumber(3)
  set note($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasNote() => $_has(2);
  @$pb.TagNumber(3)
  void clearNote() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get savingsAccountId => $_getSZ(3);
  @$pb.TagNumber(4)
  set savingsAccountId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSavingsAccountId() => $_has(3);
  @$pb.TagNumber(4)
  void clearSavingsAccountId() => $_clearField(4);
}

class IncomingPaymentAssignResponse extends $pb.GeneratedMessage {
  factory IncomingPaymentAssignResponse({
    IncomingPaymentObject? data,
    $1.Struct? allocation,
  }) {
    final result = IncomingPaymentAssignResponse._();
    if (data != null) result.data = data;
    if (allocation != null) result.allocation = allocation;
    return result;
  }

  IncomingPaymentAssignResponse._();

  factory IncomingPaymentAssignResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      IncomingPaymentAssignResponse()..mergeFromBuffer(data, registry);
  factory IncomingPaymentAssignResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      IncomingPaymentAssignResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'IncomingPaymentAssignResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'operations.v1'),
      createEmptyInstance: IncomingPaymentAssignResponse.$_createMessage)
    ..aOM<IncomingPaymentObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: IncomingPaymentObject.$_createMessage)
    ..aOM<$1.Struct>(2, _omitFieldNames ? '' : 'allocation',
        subBuilder: $1.Struct.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  IncomingPaymentAssignResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  IncomingPaymentAssignResponse copyWith(
          void Function(IncomingPaymentAssignResponse) updates) =>
      super.copyWith(
              (message) => updates(message as IncomingPaymentAssignResponse))
          as IncomingPaymentAssignResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use IncomingPaymentAssignResponse() / IncomingPaymentAssignResponse.new instead')
  static IncomingPaymentAssignResponse create() =>
      IncomingPaymentAssignResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      IncomingPaymentAssignResponse._();
  @$core.override
  IncomingPaymentAssignResponse createEmptyInstance() =>
      IncomingPaymentAssignResponse._();
  @$core.pragma('dart2js:noInline')
  static IncomingPaymentAssignResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<IncomingPaymentAssignResponse>(
          IncomingPaymentAssignResponse.$_createMessage);
  static IncomingPaymentAssignResponse? _defaultInstance;

  @$pb.TagNumber(1)
  IncomingPaymentObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(IncomingPaymentObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  IncomingPaymentObject ensureData() => $_ensure(0);

  @$pb.TagNumber(2)
  $1.Struct get allocation => $_getN(1);
  @$pb.TagNumber(2)
  set allocation($1.Struct value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasAllocation() => $_has(1);
  @$pb.TagNumber(2)
  void clearAllocation() => $_clearField(2);
  @$pb.TagNumber(2)
  $1.Struct ensureAllocation() => $_ensure(1);
}

class OperationsJobRunRequest extends $pb.GeneratedMessage {
  factory OperationsJobRunRequest({
    OperationsJob? job,
    $core.int? batchSize,
  }) {
    final result = OperationsJobRunRequest._();
    if (job != null) result.job = job;
    if (batchSize != null) result.batchSize = batchSize;
    return result;
  }

  OperationsJobRunRequest._();

  factory OperationsJobRunRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      OperationsJobRunRequest()..mergeFromBuffer(data, registry);
  factory OperationsJobRunRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      OperationsJobRunRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'OperationsJobRunRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'operations.v1'),
      createEmptyInstance: OperationsJobRunRequest.$_createMessage)
    ..aE<OperationsJob>(1, _omitFieldNames ? '' : 'job',
        enumValues: OperationsJob.values)
    ..aI(2, _omitFieldNames ? '' : 'batchSize')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OperationsJobRunRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OperationsJobRunRequest copyWith(
          void Function(OperationsJobRunRequest) updates) =>
      super.copyWith((message) => updates(message as OperationsJobRunRequest))
          as OperationsJobRunRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use OperationsJobRunRequest() / OperationsJobRunRequest.new instead')
  static OperationsJobRunRequest create() => OperationsJobRunRequest._();
  static $pb.GeneratedMessage $_createMessage() => OperationsJobRunRequest._();
  @$core.override
  OperationsJobRunRequest createEmptyInstance() => OperationsJobRunRequest._();
  @$core.pragma('dart2js:noInline')
  static OperationsJobRunRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<OperationsJobRunRequest>(
          OperationsJobRunRequest.$_createMessage);
  static OperationsJobRunRequest? _defaultInstance;

  @$pb.TagNumber(1)
  OperationsJob get job => $_getN(0);
  @$pb.TagNumber(1)
  set job(OperationsJob value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasJob() => $_has(0);
  @$pb.TagNumber(1)
  void clearJob() => $_clearField(1);

  /// Most items to process in this run, at most 5000. 0 uses the service
  /// default.
  @$pb.TagNumber(2)
  $core.int get batchSize => $_getIZ(1);
  @$pb.TagNumber(2)
  set batchSize($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasBatchSize() => $_has(1);
  @$pb.TagNumber(2)
  void clearBatchSize() => $_clearField(2);
}

class OperationsJobRunResponse extends $pb.GeneratedMessage {
  factory OperationsJobRunResponse({
    $core.int? processed,
    $core.bool? more,
  }) {
    final result = OperationsJobRunResponse._();
    if (processed != null) result.processed = processed;
    if (more != null) result.more = more;
    return result;
  }

  OperationsJobRunResponse._();

  factory OperationsJobRunResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      OperationsJobRunResponse()..mergeFromBuffer(data, registry);
  factory OperationsJobRunResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      OperationsJobRunResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'OperationsJobRunResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'operations.v1'),
      createEmptyInstance: OperationsJobRunResponse.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'processed')
    ..aOB(2, _omitFieldNames ? '' : 'more')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OperationsJobRunResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OperationsJobRunResponse copyWith(
          void Function(OperationsJobRunResponse) updates) =>
      super.copyWith((message) => updates(message as OperationsJobRunResponse))
          as OperationsJobRunResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use OperationsJobRunResponse() / OperationsJobRunResponse.new instead')
  static OperationsJobRunResponse create() => OperationsJobRunResponse._();
  static $pb.GeneratedMessage $_createMessage() => OperationsJobRunResponse._();
  @$core.override
  OperationsJobRunResponse createEmptyInstance() =>
      OperationsJobRunResponse._();
  @$core.pragma('dart2js:noInline')
  static OperationsJobRunResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<OperationsJobRunResponse>(
          OperationsJobRunResponse.$_createMessage);
  static OperationsJobRunResponse? _defaultInstance;

  /// Items this run worked through.
  @$pb.TagNumber(1)
  $core.int get processed => $_getIZ(0);
  @$pb.TagNumber(1)
  set processed($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasProcessed() => $_has(0);
  @$pb.TagNumber(1)
  void clearProcessed() => $_clearField(1);

  /// True when the batch was full and more work may be waiting.
  @$pb.TagNumber(2)
  $core.bool get more => $_getBF(1);
  @$pb.TagNumber(2)
  set more($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMore() => $_has(1);
  @$pb.TagNumber(2)
  void clearMore() => $_clearField(2);
}

class OperationsServiceApi {
  final $pb.RpcClient _client;

  OperationsServiceApi(this._client);

  $async.Future<TransferOrderExecuteResponse> transferOrderExecute(
          $pb.ClientContext? ctx, TransferOrderExecuteRequest request) =>
      _client.invoke<TransferOrderExecuteResponse>(ctx, 'OperationsService',
          'TransferOrderExecute', request, TransferOrderExecuteResponse());
  $async.Future<TransferOrderSearchResponse> transferOrderSearch(
          $pb.ClientContext? ctx, TransferOrderSearchRequest request) =>
      _client.invoke<TransferOrderSearchResponse>(ctx, 'OperationsService',
          'TransferOrderSearch', request, TransferOrderSearchResponse());
  $async.Future<IncomingPaymentNotifyResponse> incomingPaymentNotify(
          $pb.ClientContext? ctx, IncomingPaymentNotifyRequest request) =>
      _client.invoke<IncomingPaymentNotifyResponse>(ctx, 'OperationsService',
          'IncomingPaymentNotify', request, IncomingPaymentNotifyResponse());
  $async.Future<PaymentAllocateResponse> paymentAllocate(
          $pb.ClientContext? ctx, PaymentAllocateRequest request) =>
      _client.invoke<PaymentAllocateResponse>(ctx, 'OperationsService',
          'PaymentAllocate', request, PaymentAllocateResponse());

  /// IncomingPaymentSearch lists received payments, for staff to find the
  /// ones that matched nobody.
  $async.Future<IncomingPaymentSearchResponse> incomingPaymentSearch(
          $pb.ClientContext? ctx, IncomingPaymentSearchRequest request) =>
      _client.invoke<IncomingPaymentSearchResponse>(ctx, 'OperationsService',
          'IncomingPaymentSearch', request, IncomingPaymentSearchResponse());

  /// IncomingPaymentAssign ties an unmatched payment to its loan and
  /// allocates it.
  $async.Future<IncomingPaymentAssignResponse> incomingPaymentAssign(
          $pb.ClientContext? ctx, IncomingPaymentAssignRequest request) =>
      _client.invoke<IncomingPaymentAssignResponse>(ctx, 'OperationsService',
          'IncomingPaymentAssign', request, IncomingPaymentAssignResponse());

  /// OperationsJobRun runs one batch of a periodic job. Called by the
  /// platform scheduler (trustage); only service accounts hold the permission.
  $async.Future<OperationsJobRunResponse> operationsJobRun(
          $pb.ClientContext? ctx, OperationsJobRunRequest request) =>
      _client.invoke<OperationsJobRunResponse>(ctx, 'OperationsService',
          'OperationsJobRun', request, OperationsJobRunResponse());
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
