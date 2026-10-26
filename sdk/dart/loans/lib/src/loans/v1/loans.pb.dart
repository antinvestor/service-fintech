// This is a generated file - do not edit.
//
// Generated from loans/v1/loans.proto.

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

import '../../common/v1/common.pb.dart' as $2;
import '../../common/v1/money.pb.dart' as $0;
import 'loans.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'loans.pbenum.dart';

/// ProductFormRequirement defines a form template required by a product.
class ProductFormRequirement extends $pb.GeneratedMessage {
  factory ProductFormRequirement({
    $core.String? templateId,
    $core.String? stage,
    $core.bool? required,
    $core.int? order,
    $core.String? description,
  }) {
    final result = ProductFormRequirement._();
    if (templateId != null) result.templateId = templateId;
    if (stage != null) result.stage = stage;
    if (required != null) result.required = required;
    if (order != null) result.order = order;
    if (description != null) result.description = description;
    return result;
  }

  ProductFormRequirement._();

  factory ProductFormRequirement.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ProductFormRequirement()..mergeFromBuffer(data, registry);
  factory ProductFormRequirement.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ProductFormRequirement()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ProductFormRequirement',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: ProductFormRequirement.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'templateId')
    ..aOS(2, _omitFieldNames ? '' : 'stage')
    ..aOB(3, _omitFieldNames ? '' : 'required')
    ..aI(4, _omitFieldNames ? '' : 'order')
    ..aOS(5, _omitFieldNames ? '' : 'description')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProductFormRequirement clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProductFormRequirement copyWith(
          void Function(ProductFormRequirement) updates) =>
      super.copyWith((message) => updates(message as ProductFormRequirement))
          as ProductFormRequirement;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ProductFormRequirement() / ProductFormRequirement.new instead')
  static ProductFormRequirement create() => ProductFormRequirement._();
  static $pb.GeneratedMessage $_createMessage() => ProductFormRequirement._();
  @$core.override
  ProductFormRequirement createEmptyInstance() => ProductFormRequirement._();
  @$core.pragma('dart2js:noInline')
  static ProductFormRequirement getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ProductFormRequirement>(
          ProductFormRequirement.$_createMessage);
  static ProductFormRequirement? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get templateId => $_getSZ(0);
  @$pb.TagNumber(1)
  set templateId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTemplateId() => $_has(0);
  @$pb.TagNumber(1)
  void clearTemplateId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get stage => $_getSZ(1);
  @$pb.TagNumber(2)
  set stage($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasStage() => $_has(1);
  @$pb.TagNumber(2)
  void clearStage() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get required => $_getBF(2);
  @$pb.TagNumber(3)
  set required($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRequired() => $_has(2);
  @$pb.TagNumber(3)
  void clearRequired() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get order => $_getIZ(3);
  @$pb.TagNumber(4)
  set order($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasOrder() => $_has(3);
  @$pb.TagNumber(4)
  void clearOrder() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get description => $_getSZ(4);
  @$pb.TagNumber(5)
  set description($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasDescription() => $_has(4);
  @$pb.TagNumber(5)
  void clearDescription() => $_clearField(5);
}

/// LoanProductObject defines loan terms, rates, fees, and limits for an organization.
class LoanProductObject extends $pb.GeneratedMessage {
  factory LoanProductObject({
    $core.String? id,
    $core.String? organizationId,
    $core.String? name,
    $core.String? code,
    $core.String? description,
    LoanProductType? productType,
    $core.String? currencyCode,
    InterestMethod? interestMethod,
    RepaymentFrequency? repaymentFrequency,
    $0.Money? minAmount,
    $0.Money? maxAmount,
    $core.int? minTermDays,
    $core.int? maxTermDays,
    $core.String? annualInterestRate,
    $core.String? processingFeePercent,
    $core.String? insuranceFeePercent,
    $core.String? latePenaltyRate,
    $core.int? gracePeriodDays,
    $1.Struct? feeStructure,
    $1.Struct? eligibilityCriteria,
    $2.STATE? state,
    $1.Struct? properties,
    $core.Iterable<ProductFormRequirement>? requiredForms,
    $core.String? agentCommissionPercent,
  }) {
    final result = LoanProductObject._();
    if (id != null) result.id = id;
    if (organizationId != null) result.organizationId = organizationId;
    if (name != null) result.name = name;
    if (code != null) result.code = code;
    if (description != null) result.description = description;
    if (productType != null) result.productType = productType;
    if (currencyCode != null) result.currencyCode = currencyCode;
    if (interestMethod != null) result.interestMethod = interestMethod;
    if (repaymentFrequency != null)
      result.repaymentFrequency = repaymentFrequency;
    if (minAmount != null) result.minAmount = minAmount;
    if (maxAmount != null) result.maxAmount = maxAmount;
    if (minTermDays != null) result.minTermDays = minTermDays;
    if (maxTermDays != null) result.maxTermDays = maxTermDays;
    if (annualInterestRate != null)
      result.annualInterestRate = annualInterestRate;
    if (processingFeePercent != null)
      result.processingFeePercent = processingFeePercent;
    if (insuranceFeePercent != null)
      result.insuranceFeePercent = insuranceFeePercent;
    if (latePenaltyRate != null) result.latePenaltyRate = latePenaltyRate;
    if (gracePeriodDays != null) result.gracePeriodDays = gracePeriodDays;
    if (feeStructure != null) result.feeStructure = feeStructure;
    if (eligibilityCriteria != null)
      result.eligibilityCriteria = eligibilityCriteria;
    if (state != null) result.state = state;
    if (properties != null) result.properties = properties;
    if (requiredForms != null) result.requiredForms.addAll(requiredForms);
    if (agentCommissionPercent != null)
      result.agentCommissionPercent = agentCommissionPercent;
    return result;
  }

  LoanProductObject._();

  factory LoanProductObject.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanProductObject()..mergeFromBuffer(data, registry);
  factory LoanProductObject.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanProductObject()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LoanProductObject',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: LoanProductObject.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'organizationId')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..aOS(4, _omitFieldNames ? '' : 'code')
    ..aOS(5, _omitFieldNames ? '' : 'description')
    ..aE<LoanProductType>(6, _omitFieldNames ? '' : 'productType',
        enumValues: LoanProductType.values)
    ..aOS(7, _omitFieldNames ? '' : 'currencyCode')
    ..aE<InterestMethod>(8, _omitFieldNames ? '' : 'interestMethod',
        enumValues: InterestMethod.values)
    ..aE<RepaymentFrequency>(9, _omitFieldNames ? '' : 'repaymentFrequency',
        enumValues: RepaymentFrequency.values)
    ..aOM<$0.Money>(10, _omitFieldNames ? '' : 'minAmount',
        subBuilder: $0.Money.$_createMessage)
    ..aOM<$0.Money>(11, _omitFieldNames ? '' : 'maxAmount',
        subBuilder: $0.Money.$_createMessage)
    ..aI(12, _omitFieldNames ? '' : 'minTermDays')
    ..aI(13, _omitFieldNames ? '' : 'maxTermDays')
    ..aOS(14, _omitFieldNames ? '' : 'annualInterestRate')
    ..aOS(15, _omitFieldNames ? '' : 'processingFeePercent')
    ..aOS(16, _omitFieldNames ? '' : 'insuranceFeePercent')
    ..aOS(17, _omitFieldNames ? '' : 'latePenaltyRate')
    ..aI(18, _omitFieldNames ? '' : 'gracePeriodDays')
    ..aOM<$1.Struct>(19, _omitFieldNames ? '' : 'feeStructure',
        subBuilder: $1.Struct.$_createMessage)
    ..aOM<$1.Struct>(20, _omitFieldNames ? '' : 'eligibilityCriteria',
        subBuilder: $1.Struct.$_createMessage)
    ..aE<$2.STATE>(21, _omitFieldNames ? '' : 'state',
        enumValues: $2.STATE.values)
    ..aOM<$1.Struct>(22, _omitFieldNames ? '' : 'properties',
        subBuilder: $1.Struct.$_createMessage)
    ..pPM<ProductFormRequirement>(23, _omitFieldNames ? '' : 'requiredForms',
        subBuilder: ProductFormRequirement.$_createMessage)
    ..aOS(24, _omitFieldNames ? '' : 'agentCommissionPercent')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanProductObject clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanProductObject copyWith(void Function(LoanProductObject) updates) =>
      super.copyWith((message) => updates(message as LoanProductObject))
          as LoanProductObject;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use LoanProductObject() / LoanProductObject.new instead')
  static LoanProductObject create() => LoanProductObject._();
  static $pb.GeneratedMessage $_createMessage() => LoanProductObject._();
  @$core.override
  LoanProductObject createEmptyInstance() => LoanProductObject._();
  @$core.pragma('dart2js:noInline')
  static LoanProductObject getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LoanProductObject>(
          LoanProductObject.$_createMessage);
  static LoanProductObject? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get organizationId => $_getSZ(1);
  @$pb.TagNumber(2)
  set organizationId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasOrganizationId() => $_has(1);
  @$pb.TagNumber(2)
  void clearOrganizationId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get name => $_getSZ(2);
  @$pb.TagNumber(3)
  set name($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasName() => $_has(2);
  @$pb.TagNumber(3)
  void clearName() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get code => $_getSZ(3);
  @$pb.TagNumber(4)
  set code($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCode() => $_has(3);
  @$pb.TagNumber(4)
  void clearCode() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get description => $_getSZ(4);
  @$pb.TagNumber(5)
  set description($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasDescription() => $_has(4);
  @$pb.TagNumber(5)
  void clearDescription() => $_clearField(5);

  @$pb.TagNumber(6)
  LoanProductType get productType => $_getN(5);
  @$pb.TagNumber(6)
  set productType(LoanProductType value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasProductType() => $_has(5);
  @$pb.TagNumber(6)
  void clearProductType() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get currencyCode => $_getSZ(6);
  @$pb.TagNumber(7)
  set currencyCode($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasCurrencyCode() => $_has(6);
  @$pb.TagNumber(7)
  void clearCurrencyCode() => $_clearField(7);

  @$pb.TagNumber(8)
  InterestMethod get interestMethod => $_getN(7);
  @$pb.TagNumber(8)
  set interestMethod(InterestMethod value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasInterestMethod() => $_has(7);
  @$pb.TagNumber(8)
  void clearInterestMethod() => $_clearField(8);

  @$pb.TagNumber(9)
  RepaymentFrequency get repaymentFrequency => $_getN(8);
  @$pb.TagNumber(9)
  set repaymentFrequency(RepaymentFrequency value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasRepaymentFrequency() => $_has(8);
  @$pb.TagNumber(9)
  void clearRepaymentFrequency() => $_clearField(9);

  @$pb.TagNumber(10)
  $0.Money get minAmount => $_getN(9);
  @$pb.TagNumber(10)
  set minAmount($0.Money value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasMinAmount() => $_has(9);
  @$pb.TagNumber(10)
  void clearMinAmount() => $_clearField(10);
  @$pb.TagNumber(10)
  $0.Money ensureMinAmount() => $_ensure(9);

  @$pb.TagNumber(11)
  $0.Money get maxAmount => $_getN(10);
  @$pb.TagNumber(11)
  set maxAmount($0.Money value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasMaxAmount() => $_has(10);
  @$pb.TagNumber(11)
  void clearMaxAmount() => $_clearField(11);
  @$pb.TagNumber(11)
  $0.Money ensureMaxAmount() => $_ensure(10);

  @$pb.TagNumber(12)
  $core.int get minTermDays => $_getIZ(11);
  @$pb.TagNumber(12)
  set minTermDays($core.int value) => $_setSignedInt32(11, value);
  @$pb.TagNumber(12)
  $core.bool hasMinTermDays() => $_has(11);
  @$pb.TagNumber(12)
  void clearMinTermDays() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.int get maxTermDays => $_getIZ(12);
  @$pb.TagNumber(13)
  set maxTermDays($core.int value) => $_setSignedInt32(12, value);
  @$pb.TagNumber(13)
  $core.bool hasMaxTermDays() => $_has(12);
  @$pb.TagNumber(13)
  void clearMaxTermDays() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.String get annualInterestRate => $_getSZ(13);
  @$pb.TagNumber(14)
  set annualInterestRate($core.String value) => $_setString(13, value);
  @$pb.TagNumber(14)
  $core.bool hasAnnualInterestRate() => $_has(13);
  @$pb.TagNumber(14)
  void clearAnnualInterestRate() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.String get processingFeePercent => $_getSZ(14);
  @$pb.TagNumber(15)
  set processingFeePercent($core.String value) => $_setString(14, value);
  @$pb.TagNumber(15)
  $core.bool hasProcessingFeePercent() => $_has(14);
  @$pb.TagNumber(15)
  void clearProcessingFeePercent() => $_clearField(15);

  @$pb.TagNumber(16)
  $core.String get insuranceFeePercent => $_getSZ(15);
  @$pb.TagNumber(16)
  set insuranceFeePercent($core.String value) => $_setString(15, value);
  @$pb.TagNumber(16)
  $core.bool hasInsuranceFeePercent() => $_has(15);
  @$pb.TagNumber(16)
  void clearInsuranceFeePercent() => $_clearField(16);

  @$pb.TagNumber(17)
  $core.String get latePenaltyRate => $_getSZ(16);
  @$pb.TagNumber(17)
  set latePenaltyRate($core.String value) => $_setString(16, value);
  @$pb.TagNumber(17)
  $core.bool hasLatePenaltyRate() => $_has(16);
  @$pb.TagNumber(17)
  void clearLatePenaltyRate() => $_clearField(17);

  @$pb.TagNumber(18)
  $core.int get gracePeriodDays => $_getIZ(17);
  @$pb.TagNumber(18)
  set gracePeriodDays($core.int value) => $_setSignedInt32(17, value);
  @$pb.TagNumber(18)
  $core.bool hasGracePeriodDays() => $_has(17);
  @$pb.TagNumber(18)
  void clearGracePeriodDays() => $_clearField(18);

  @$pb.TagNumber(19)
  $1.Struct get feeStructure => $_getN(18);
  @$pb.TagNumber(19)
  set feeStructure($1.Struct value) => $_setField(19, value);
  @$pb.TagNumber(19)
  $core.bool hasFeeStructure() => $_has(18);
  @$pb.TagNumber(19)
  void clearFeeStructure() => $_clearField(19);
  @$pb.TagNumber(19)
  $1.Struct ensureFeeStructure() => $_ensure(18);

  @$pb.TagNumber(20)
  $1.Struct get eligibilityCriteria => $_getN(19);
  @$pb.TagNumber(20)
  set eligibilityCriteria($1.Struct value) => $_setField(20, value);
  @$pb.TagNumber(20)
  $core.bool hasEligibilityCriteria() => $_has(19);
  @$pb.TagNumber(20)
  void clearEligibilityCriteria() => $_clearField(20);
  @$pb.TagNumber(20)
  $1.Struct ensureEligibilityCriteria() => $_ensure(19);

  @$pb.TagNumber(21)
  $2.STATE get state => $_getN(20);
  @$pb.TagNumber(21)
  set state($2.STATE value) => $_setField(21, value);
  @$pb.TagNumber(21)
  $core.bool hasState() => $_has(20);
  @$pb.TagNumber(21)
  void clearState() => $_clearField(21);

  @$pb.TagNumber(22)
  $1.Struct get properties => $_getN(21);
  @$pb.TagNumber(22)
  set properties($1.Struct value) => $_setField(22, value);
  @$pb.TagNumber(22)
  $core.bool hasProperties() => $_has(21);
  @$pb.TagNumber(22)
  void clearProperties() => $_clearField(22);
  @$pb.TagNumber(22)
  $1.Struct ensureProperties() => $_ensure(21);

  @$pb.TagNumber(23)
  $pb.PbList<ProductFormRequirement> get requiredForms => $_getList(22);

  /// Share of interest repaid that the serving agent's team earns, as a
  /// decimal percentage e.g. "10". Empty or zero pays no commission.
  @$pb.TagNumber(24)
  $core.String get agentCommissionPercent => $_getSZ(23);
  @$pb.TagNumber(24)
  set agentCommissionPercent($core.String value) => $_setString(23, value);
  @$pb.TagNumber(24)
  $core.bool hasAgentCommissionPercent() => $_has(23);
  @$pb.TagNumber(24)
  void clearAgentCommissionPercent() => $_clearField(24);
}

/// LoanRequestObject represents a loan request created by a product service.
/// Product services (seed, stawi, etc.) create loan requests after completing
/// their own acquisition and verification workflows. A loan account is created
/// only when the request is approved and all product-required data is verified.
class LoanRequestObject extends $pb.GeneratedMessage {
  factory LoanRequestObject({
    $core.String? id,
    $core.String? productId,
    $core.String? clientId,
    $core.String? agentId,
    $core.String? branchId,
    $core.String? organizationId,
    LoanRequestStatus? status,
    $0.Money? requestedAmount,
    $0.Money? approvedAmount,
    $core.int? requestedTermDays,
    $core.int? approvedTermDays,
    $core.String? interestRate,
    $core.String? currencyCode,
    $core.String? purpose,
    $core.String? rejectionReason,
    $core.String? offerExpiresAt,
    $core.String? submittedAt,
    $core.String? decidedAt,
    $core.String? loanAccountId,
    $core.String? sourceService,
    $core.String? sourceRequestId,
    $core.String? idempotencyKey,
    $1.Struct? properties,
    $core.String? submittedBy,
    $core.String? decidedBy,
  }) {
    final result = LoanRequestObject._();
    if (id != null) result.id = id;
    if (productId != null) result.productId = productId;
    if (clientId != null) result.clientId = clientId;
    if (agentId != null) result.agentId = agentId;
    if (branchId != null) result.branchId = branchId;
    if (organizationId != null) result.organizationId = organizationId;
    if (status != null) result.status = status;
    if (requestedAmount != null) result.requestedAmount = requestedAmount;
    if (approvedAmount != null) result.approvedAmount = approvedAmount;
    if (requestedTermDays != null) result.requestedTermDays = requestedTermDays;
    if (approvedTermDays != null) result.approvedTermDays = approvedTermDays;
    if (interestRate != null) result.interestRate = interestRate;
    if (currencyCode != null) result.currencyCode = currencyCode;
    if (purpose != null) result.purpose = purpose;
    if (rejectionReason != null) result.rejectionReason = rejectionReason;
    if (offerExpiresAt != null) result.offerExpiresAt = offerExpiresAt;
    if (submittedAt != null) result.submittedAt = submittedAt;
    if (decidedAt != null) result.decidedAt = decidedAt;
    if (loanAccountId != null) result.loanAccountId = loanAccountId;
    if (sourceService != null) result.sourceService = sourceService;
    if (sourceRequestId != null) result.sourceRequestId = sourceRequestId;
    if (idempotencyKey != null) result.idempotencyKey = idempotencyKey;
    if (properties != null) result.properties = properties;
    if (submittedBy != null) result.submittedBy = submittedBy;
    if (decidedBy != null) result.decidedBy = decidedBy;
    return result;
  }

  LoanRequestObject._();

  factory LoanRequestObject.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanRequestObject()..mergeFromBuffer(data, registry);
  factory LoanRequestObject.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanRequestObject()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LoanRequestObject',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: LoanRequestObject.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'productId')
    ..aOS(3, _omitFieldNames ? '' : 'clientId')
    ..aOS(4, _omitFieldNames ? '' : 'agentId')
    ..aOS(5, _omitFieldNames ? '' : 'branchId')
    ..aOS(6, _omitFieldNames ? '' : 'organizationId')
    ..aE<LoanRequestStatus>(7, _omitFieldNames ? '' : 'status',
        enumValues: LoanRequestStatus.values)
    ..aOM<$0.Money>(8, _omitFieldNames ? '' : 'requestedAmount',
        subBuilder: $0.Money.$_createMessage)
    ..aOM<$0.Money>(9, _omitFieldNames ? '' : 'approvedAmount',
        subBuilder: $0.Money.$_createMessage)
    ..aI(10, _omitFieldNames ? '' : 'requestedTermDays')
    ..aI(11, _omitFieldNames ? '' : 'approvedTermDays')
    ..aOS(12, _omitFieldNames ? '' : 'interestRate')
    ..aOS(13, _omitFieldNames ? '' : 'currencyCode')
    ..aOS(14, _omitFieldNames ? '' : 'purpose')
    ..aOS(15, _omitFieldNames ? '' : 'rejectionReason')
    ..aOS(16, _omitFieldNames ? '' : 'offerExpiresAt')
    ..aOS(17, _omitFieldNames ? '' : 'submittedAt')
    ..aOS(18, _omitFieldNames ? '' : 'decidedAt')
    ..aOS(19, _omitFieldNames ? '' : 'loanAccountId')
    ..aOS(20, _omitFieldNames ? '' : 'sourceService')
    ..aOS(21, _omitFieldNames ? '' : 'sourceRequestId')
    ..aOS(22, _omitFieldNames ? '' : 'idempotencyKey')
    ..aOM<$1.Struct>(23, _omitFieldNames ? '' : 'properties',
        subBuilder: $1.Struct.$_createMessage)
    ..aOS(24, _omitFieldNames ? '' : 'submittedBy')
    ..aOS(25, _omitFieldNames ? '' : 'decidedBy')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanRequestObject clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanRequestObject copyWith(void Function(LoanRequestObject) updates) =>
      super.copyWith((message) => updates(message as LoanRequestObject))
          as LoanRequestObject;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use LoanRequestObject() / LoanRequestObject.new instead')
  static LoanRequestObject create() => LoanRequestObject._();
  static $pb.GeneratedMessage $_createMessage() => LoanRequestObject._();
  @$core.override
  LoanRequestObject createEmptyInstance() => LoanRequestObject._();
  @$core.pragma('dart2js:noInline')
  static LoanRequestObject getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LoanRequestObject>(
          LoanRequestObject.$_createMessage);
  static LoanRequestObject? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get productId => $_getSZ(1);
  @$pb.TagNumber(2)
  set productId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasProductId() => $_has(1);
  @$pb.TagNumber(2)
  void clearProductId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get clientId => $_getSZ(2);
  @$pb.TagNumber(3)
  set clientId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasClientId() => $_has(2);
  @$pb.TagNumber(3)
  void clearClientId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get agentId => $_getSZ(3);
  @$pb.TagNumber(4)
  set agentId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAgentId() => $_has(3);
  @$pb.TagNumber(4)
  void clearAgentId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get branchId => $_getSZ(4);
  @$pb.TagNumber(5)
  set branchId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasBranchId() => $_has(4);
  @$pb.TagNumber(5)
  void clearBranchId() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get organizationId => $_getSZ(5);
  @$pb.TagNumber(6)
  set organizationId($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasOrganizationId() => $_has(5);
  @$pb.TagNumber(6)
  void clearOrganizationId() => $_clearField(6);

  /// status is owned by the server. It is set by the approval workflow
  /// (Save accepts only DRAFT/SUBMITTED for new requests; Approve, Reject and
  /// Cancel move it from there) and any client-supplied value on Save is
  /// rejected by the business layer. Validation is skipped so the field can
  /// be echoed back in responses without being constrained on input.
  @$pb.TagNumber(7)
  LoanRequestStatus get status => $_getN(6);
  @$pb.TagNumber(7)
  set status(LoanRequestStatus value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasStatus() => $_has(6);
  @$pb.TagNumber(7)
  void clearStatus() => $_clearField(7);

  @$pb.TagNumber(8)
  $0.Money get requestedAmount => $_getN(7);
  @$pb.TagNumber(8)
  set requestedAmount($0.Money value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasRequestedAmount() => $_has(7);
  @$pb.TagNumber(8)
  void clearRequestedAmount() => $_clearField(8);
  @$pb.TagNumber(8)
  $0.Money ensureRequestedAmount() => $_ensure(7);

  @$pb.TagNumber(9)
  $0.Money get approvedAmount => $_getN(8);
  @$pb.TagNumber(9)
  set approvedAmount($0.Money value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasApprovedAmount() => $_has(8);
  @$pb.TagNumber(9)
  void clearApprovedAmount() => $_clearField(9);
  @$pb.TagNumber(9)
  $0.Money ensureApprovedAmount() => $_ensure(8);

  @$pb.TagNumber(10)
  $core.int get requestedTermDays => $_getIZ(9);
  @$pb.TagNumber(10)
  set requestedTermDays($core.int value) => $_setSignedInt32(9, value);
  @$pb.TagNumber(10)
  $core.bool hasRequestedTermDays() => $_has(9);
  @$pb.TagNumber(10)
  void clearRequestedTermDays() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.int get approvedTermDays => $_getIZ(10);
  @$pb.TagNumber(11)
  set approvedTermDays($core.int value) => $_setSignedInt32(10, value);
  @$pb.TagNumber(11)
  $core.bool hasApprovedTermDays() => $_has(10);
  @$pb.TagNumber(11)
  void clearApprovedTermDays() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.String get interestRate => $_getSZ(11);
  @$pb.TagNumber(12)
  set interestRate($core.String value) => $_setString(11, value);
  @$pb.TagNumber(12)
  $core.bool hasInterestRate() => $_has(11);
  @$pb.TagNumber(12)
  void clearInterestRate() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.String get currencyCode => $_getSZ(12);
  @$pb.TagNumber(13)
  set currencyCode($core.String value) => $_setString(12, value);
  @$pb.TagNumber(13)
  $core.bool hasCurrencyCode() => $_has(12);
  @$pb.TagNumber(13)
  void clearCurrencyCode() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.String get purpose => $_getSZ(13);
  @$pb.TagNumber(14)
  set purpose($core.String value) => $_setString(13, value);
  @$pb.TagNumber(14)
  $core.bool hasPurpose() => $_has(13);
  @$pb.TagNumber(14)
  void clearPurpose() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.String get rejectionReason => $_getSZ(14);
  @$pb.TagNumber(15)
  set rejectionReason($core.String value) => $_setString(14, value);
  @$pb.TagNumber(15)
  $core.bool hasRejectionReason() => $_has(14);
  @$pb.TagNumber(15)
  void clearRejectionReason() => $_clearField(15);

  @$pb.TagNumber(16)
  $core.String get offerExpiresAt => $_getSZ(15);
  @$pb.TagNumber(16)
  set offerExpiresAt($core.String value) => $_setString(15, value);
  @$pb.TagNumber(16)
  $core.bool hasOfferExpiresAt() => $_has(15);
  @$pb.TagNumber(16)
  void clearOfferExpiresAt() => $_clearField(16);

  @$pb.TagNumber(17)
  $core.String get submittedAt => $_getSZ(16);
  @$pb.TagNumber(17)
  set submittedAt($core.String value) => $_setString(16, value);
  @$pb.TagNumber(17)
  $core.bool hasSubmittedAt() => $_has(16);
  @$pb.TagNumber(17)
  void clearSubmittedAt() => $_clearField(17);

  @$pb.TagNumber(18)
  $core.String get decidedAt => $_getSZ(17);
  @$pb.TagNumber(18)
  set decidedAt($core.String value) => $_setString(17, value);
  @$pb.TagNumber(18)
  $core.bool hasDecidedAt() => $_has(17);
  @$pb.TagNumber(18)
  void clearDecidedAt() => $_clearField(18);

  @$pb.TagNumber(19)
  $core.String get loanAccountId => $_getSZ(18);
  @$pb.TagNumber(19)
  set loanAccountId($core.String value) => $_setString(18, value);
  @$pb.TagNumber(19)
  $core.bool hasLoanAccountId() => $_has(18);
  @$pb.TagNumber(19)
  void clearLoanAccountId() => $_clearField(19);

  /// Source tracking: which product service created this request.
  ///
  /// The pair (source_service, source_request_id) identifies one request in
  /// the originating service and is unique within a partition: a product
  /// service that retries LoanRequestSave with the same pair gets the same
  /// loan request back rather than a duplicate. Either may be empty for
  /// requests captured manually, in which case no uniqueness is implied.
  @$pb.TagNumber(20)
  $core.String get sourceService => $_getSZ(19);
  @$pb.TagNumber(20)
  set sourceService($core.String value) => $_setString(19, value);
  @$pb.TagNumber(20)
  $core.bool hasSourceService() => $_has(19);
  @$pb.TagNumber(20)
  void clearSourceService() => $_clearField(20);

  @$pb.TagNumber(21)
  $core.String get sourceRequestId => $_getSZ(20);
  @$pb.TagNumber(21)
  set sourceRequestId($core.String value) => $_setString(20, value);
  @$pb.TagNumber(21)
  $core.bool hasSourceRequestId() => $_has(20);
  @$pb.TagNumber(21)
  void clearSourceRequestId() => $_clearField(21);

  @$pb.TagNumber(22)
  $core.String get idempotencyKey => $_getSZ(21);
  @$pb.TagNumber(22)
  set idempotencyKey($core.String value) => $_setString(21, value);
  @$pb.TagNumber(22)
  $core.bool hasIdempotencyKey() => $_has(21);
  @$pb.TagNumber(22)
  void clearIdempotencyKey() => $_clearField(22);

  @$pb.TagNumber(23)
  $1.Struct get properties => $_getN(22);
  @$pb.TagNumber(23)
  set properties($1.Struct value) => $_setField(23, value);
  @$pb.TagNumber(23)
  $core.bool hasProperties() => $_has(22);
  @$pb.TagNumber(23)
  void clearProperties() => $_clearField(23);
  @$pb.TagNumber(23)
  $1.Struct ensureProperties() => $_ensure(22);

  /// submitted_by and decided_by are the profiles that submitted the request
  /// and approved or rejected it. Set by the server.
  @$pb.TagNumber(24)
  $core.String get submittedBy => $_getSZ(23);
  @$pb.TagNumber(24)
  set submittedBy($core.String value) => $_setString(23, value);
  @$pb.TagNumber(24)
  $core.bool hasSubmittedBy() => $_has(23);
  @$pb.TagNumber(24)
  void clearSubmittedBy() => $_clearField(24);

  @$pb.TagNumber(25)
  $core.String get decidedBy => $_getSZ(24);
  @$pb.TagNumber(25)
  set decidedBy($core.String value) => $_setString(24, value);
  @$pb.TagNumber(25)
  $core.bool hasDecidedBy() => $_has(24);
  @$pb.TagNumber(25)
  void clearDecidedBy() => $_clearField(25);
}

/// ClientProductAccessObject controls which loan products a client can access.
/// When no rows exist for a product, all clients have access (open product).
/// When rows exist, only listed clients can apply.
class ClientProductAccessObject extends $pb.GeneratedMessage {
  factory ClientProductAccessObject({
    $core.String? id,
    $core.String? clientId,
    $core.String? productId,
    $core.String? grantedBy,
    $2.STATE? state,
  }) {
    final result = ClientProductAccessObject._();
    if (id != null) result.id = id;
    if (clientId != null) result.clientId = clientId;
    if (productId != null) result.productId = productId;
    if (grantedBy != null) result.grantedBy = grantedBy;
    if (state != null) result.state = state;
    return result;
  }

  ClientProductAccessObject._();

  factory ClientProductAccessObject.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientProductAccessObject()..mergeFromBuffer(data, registry);
  factory ClientProductAccessObject.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientProductAccessObject()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClientProductAccessObject',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: ClientProductAccessObject.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'clientId')
    ..aOS(3, _omitFieldNames ? '' : 'productId')
    ..aOS(4, _omitFieldNames ? '' : 'grantedBy')
    ..aE<$2.STATE>(5, _omitFieldNames ? '' : 'state',
        enumValues: $2.STATE.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientProductAccessObject clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientProductAccessObject copyWith(
          void Function(ClientProductAccessObject) updates) =>
      super.copyWith((message) => updates(message as ClientProductAccessObject))
          as ClientProductAccessObject;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ClientProductAccessObject() / ClientProductAccessObject.new instead')
  static ClientProductAccessObject create() => ClientProductAccessObject._();
  static $pb.GeneratedMessage $_createMessage() =>
      ClientProductAccessObject._();
  @$core.override
  ClientProductAccessObject createEmptyInstance() =>
      ClientProductAccessObject._();
  @$core.pragma('dart2js:noInline')
  static ClientProductAccessObject getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ClientProductAccessObject>(
          ClientProductAccessObject.$_createMessage);
  static ClientProductAccessObject? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get clientId => $_getSZ(1);
  @$pb.TagNumber(2)
  set clientId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasClientId() => $_has(1);
  @$pb.TagNumber(2)
  void clearClientId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get productId => $_getSZ(2);
  @$pb.TagNumber(3)
  set productId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasProductId() => $_has(2);
  @$pb.TagNumber(3)
  void clearProductId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get grantedBy => $_getSZ(3);
  @$pb.TagNumber(4)
  set grantedBy($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasGrantedBy() => $_has(3);
  @$pb.TagNumber(4)
  void clearGrantedBy() => $_clearField(4);

  @$pb.TagNumber(5)
  $2.STATE get state => $_getN(4);
  @$pb.TagNumber(5)
  set state($2.STATE value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasState() => $_has(4);
  @$pb.TagNumber(5)
  void clearState() => $_clearField(5);
}

/// LoanAccountObject represents an active loan linked to a client and loan request.
class LoanAccountObject extends $pb.GeneratedMessage {
  factory LoanAccountObject({
    $core.String? id,
    $core.String? loanRequestId,
    $core.String? productId,
    $core.String? clientId,
    $core.String? agentId,
    $core.String? branchId,
    $core.String? organizationId,
    LoanStatus? status,
    $0.Money? principalAmount,
    $core.String? interestRate,
    $core.int? termDays,
    InterestMethod? interestMethod,
    RepaymentFrequency? repaymentFrequency,
    $core.String? disbursedAt,
    $core.String? maturityDate,
    $core.String? firstRepaymentDate,
    $core.String? lastRepaymentDate,
    $core.int? daysPastDue,
    $core.String? ledgerAssetAccountId,
    $core.String? ledgerInterestIncomeAccountId,
    $core.String? ledgerFeeIncomeAccountId,
    $core.String? ledgerPenaltyIncomeAccountId,
    $core.String? paymentAccountRef,
    $1.Struct? properties,
  }) {
    final result = LoanAccountObject._();
    if (id != null) result.id = id;
    if (loanRequestId != null) result.loanRequestId = loanRequestId;
    if (productId != null) result.productId = productId;
    if (clientId != null) result.clientId = clientId;
    if (agentId != null) result.agentId = agentId;
    if (branchId != null) result.branchId = branchId;
    if (organizationId != null) result.organizationId = organizationId;
    if (status != null) result.status = status;
    if (principalAmount != null) result.principalAmount = principalAmount;
    if (interestRate != null) result.interestRate = interestRate;
    if (termDays != null) result.termDays = termDays;
    if (interestMethod != null) result.interestMethod = interestMethod;
    if (repaymentFrequency != null)
      result.repaymentFrequency = repaymentFrequency;
    if (disbursedAt != null) result.disbursedAt = disbursedAt;
    if (maturityDate != null) result.maturityDate = maturityDate;
    if (firstRepaymentDate != null)
      result.firstRepaymentDate = firstRepaymentDate;
    if (lastRepaymentDate != null) result.lastRepaymentDate = lastRepaymentDate;
    if (daysPastDue != null) result.daysPastDue = daysPastDue;
    if (ledgerAssetAccountId != null)
      result.ledgerAssetAccountId = ledgerAssetAccountId;
    if (ledgerInterestIncomeAccountId != null)
      result.ledgerInterestIncomeAccountId = ledgerInterestIncomeAccountId;
    if (ledgerFeeIncomeAccountId != null)
      result.ledgerFeeIncomeAccountId = ledgerFeeIncomeAccountId;
    if (ledgerPenaltyIncomeAccountId != null)
      result.ledgerPenaltyIncomeAccountId = ledgerPenaltyIncomeAccountId;
    if (paymentAccountRef != null) result.paymentAccountRef = paymentAccountRef;
    if (properties != null) result.properties = properties;
    return result;
  }

  LoanAccountObject._();

  factory LoanAccountObject.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanAccountObject()..mergeFromBuffer(data, registry);
  factory LoanAccountObject.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanAccountObject()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LoanAccountObject',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: LoanAccountObject.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'loanRequestId')
    ..aOS(3, _omitFieldNames ? '' : 'productId')
    ..aOS(4, _omitFieldNames ? '' : 'clientId')
    ..aOS(5, _omitFieldNames ? '' : 'agentId')
    ..aOS(6, _omitFieldNames ? '' : 'branchId')
    ..aOS(7, _omitFieldNames ? '' : 'organizationId')
    ..aE<LoanStatus>(8, _omitFieldNames ? '' : 'status',
        enumValues: LoanStatus.values)
    ..aOM<$0.Money>(10, _omitFieldNames ? '' : 'principalAmount',
        subBuilder: $0.Money.$_createMessage)
    ..aOS(11, _omitFieldNames ? '' : 'interestRate')
    ..aI(12, _omitFieldNames ? '' : 'termDays')
    ..aE<InterestMethod>(13, _omitFieldNames ? '' : 'interestMethod',
        enumValues: InterestMethod.values)
    ..aE<RepaymentFrequency>(14, _omitFieldNames ? '' : 'repaymentFrequency',
        enumValues: RepaymentFrequency.values)
    ..aOS(15, _omitFieldNames ? '' : 'disbursedAt')
    ..aOS(16, _omitFieldNames ? '' : 'maturityDate')
    ..aOS(17, _omitFieldNames ? '' : 'firstRepaymentDate')
    ..aOS(18, _omitFieldNames ? '' : 'lastRepaymentDate')
    ..aI(19, _omitFieldNames ? '' : 'daysPastDue')
    ..aOS(20, _omitFieldNames ? '' : 'ledgerAssetAccountId')
    ..aOS(21, _omitFieldNames ? '' : 'ledgerInterestIncomeAccountId')
    ..aOS(22, _omitFieldNames ? '' : 'ledgerFeeIncomeAccountId')
    ..aOS(23, _omitFieldNames ? '' : 'ledgerPenaltyIncomeAccountId')
    ..aOS(24, _omitFieldNames ? '' : 'paymentAccountRef')
    ..aOM<$1.Struct>(25, _omitFieldNames ? '' : 'properties',
        subBuilder: $1.Struct.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanAccountObject clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanAccountObject copyWith(void Function(LoanAccountObject) updates) =>
      super.copyWith((message) => updates(message as LoanAccountObject))
          as LoanAccountObject;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use LoanAccountObject() / LoanAccountObject.new instead')
  static LoanAccountObject create() => LoanAccountObject._();
  static $pb.GeneratedMessage $_createMessage() => LoanAccountObject._();
  @$core.override
  LoanAccountObject createEmptyInstance() => LoanAccountObject._();
  @$core.pragma('dart2js:noInline')
  static LoanAccountObject getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LoanAccountObject>(
          LoanAccountObject.$_createMessage);
  static LoanAccountObject? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get loanRequestId => $_getSZ(1);
  @$pb.TagNumber(2)
  set loanRequestId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLoanRequestId() => $_has(1);
  @$pb.TagNumber(2)
  void clearLoanRequestId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get productId => $_getSZ(2);
  @$pb.TagNumber(3)
  set productId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasProductId() => $_has(2);
  @$pb.TagNumber(3)
  void clearProductId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get clientId => $_getSZ(3);
  @$pb.TagNumber(4)
  set clientId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasClientId() => $_has(3);
  @$pb.TagNumber(4)
  void clearClientId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get agentId => $_getSZ(4);
  @$pb.TagNumber(5)
  set agentId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasAgentId() => $_has(4);
  @$pb.TagNumber(5)
  void clearAgentId() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get branchId => $_getSZ(5);
  @$pb.TagNumber(6)
  set branchId($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasBranchId() => $_has(5);
  @$pb.TagNumber(6)
  void clearBranchId() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get organizationId => $_getSZ(6);
  @$pb.TagNumber(7)
  set organizationId($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasOrganizationId() => $_has(6);
  @$pb.TagNumber(7)
  void clearOrganizationId() => $_clearField(7);

  @$pb.TagNumber(8)
  LoanStatus get status => $_getN(7);
  @$pb.TagNumber(8)
  set status(LoanStatus value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasStatus() => $_has(7);
  @$pb.TagNumber(8)
  void clearStatus() => $_clearField(8);

  /// Field 9 removed (currency_code now in Money).
  @$pb.TagNumber(10)
  $0.Money get principalAmount => $_getN(8);
  @$pb.TagNumber(10)
  set principalAmount($0.Money value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasPrincipalAmount() => $_has(8);
  @$pb.TagNumber(10)
  void clearPrincipalAmount() => $_clearField(10);
  @$pb.TagNumber(10)
  $0.Money ensurePrincipalAmount() => $_ensure(8);

  @$pb.TagNumber(11)
  $core.String get interestRate => $_getSZ(9);
  @$pb.TagNumber(11)
  set interestRate($core.String value) => $_setString(9, value);
  @$pb.TagNumber(11)
  $core.bool hasInterestRate() => $_has(9);
  @$pb.TagNumber(11)
  void clearInterestRate() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.int get termDays => $_getIZ(10);
  @$pb.TagNumber(12)
  set termDays($core.int value) => $_setSignedInt32(10, value);
  @$pb.TagNumber(12)
  $core.bool hasTermDays() => $_has(10);
  @$pb.TagNumber(12)
  void clearTermDays() => $_clearField(12);

  @$pb.TagNumber(13)
  InterestMethod get interestMethod => $_getN(11);
  @$pb.TagNumber(13)
  set interestMethod(InterestMethod value) => $_setField(13, value);
  @$pb.TagNumber(13)
  $core.bool hasInterestMethod() => $_has(11);
  @$pb.TagNumber(13)
  void clearInterestMethod() => $_clearField(13);

  @$pb.TagNumber(14)
  RepaymentFrequency get repaymentFrequency => $_getN(12);
  @$pb.TagNumber(14)
  set repaymentFrequency(RepaymentFrequency value) => $_setField(14, value);
  @$pb.TagNumber(14)
  $core.bool hasRepaymentFrequency() => $_has(12);
  @$pb.TagNumber(14)
  void clearRepaymentFrequency() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.String get disbursedAt => $_getSZ(13);
  @$pb.TagNumber(15)
  set disbursedAt($core.String value) => $_setString(13, value);
  @$pb.TagNumber(15)
  $core.bool hasDisbursedAt() => $_has(13);
  @$pb.TagNumber(15)
  void clearDisbursedAt() => $_clearField(15);

  @$pb.TagNumber(16)
  $core.String get maturityDate => $_getSZ(14);
  @$pb.TagNumber(16)
  set maturityDate($core.String value) => $_setString(14, value);
  @$pb.TagNumber(16)
  $core.bool hasMaturityDate() => $_has(14);
  @$pb.TagNumber(16)
  void clearMaturityDate() => $_clearField(16);

  @$pb.TagNumber(17)
  $core.String get firstRepaymentDate => $_getSZ(15);
  @$pb.TagNumber(17)
  set firstRepaymentDate($core.String value) => $_setString(15, value);
  @$pb.TagNumber(17)
  $core.bool hasFirstRepaymentDate() => $_has(15);
  @$pb.TagNumber(17)
  void clearFirstRepaymentDate() => $_clearField(17);

  @$pb.TagNumber(18)
  $core.String get lastRepaymentDate => $_getSZ(16);
  @$pb.TagNumber(18)
  set lastRepaymentDate($core.String value) => $_setString(16, value);
  @$pb.TagNumber(18)
  $core.bool hasLastRepaymentDate() => $_has(16);
  @$pb.TagNumber(18)
  void clearLastRepaymentDate() => $_clearField(18);

  @$pb.TagNumber(19)
  $core.int get daysPastDue => $_getIZ(17);
  @$pb.TagNumber(19)
  set daysPastDue($core.int value) => $_setSignedInt32(17, value);
  @$pb.TagNumber(19)
  $core.bool hasDaysPastDue() => $_has(17);
  @$pb.TagNumber(19)
  void clearDaysPastDue() => $_clearField(19);

  @$pb.TagNumber(20)
  $core.String get ledgerAssetAccountId => $_getSZ(18);
  @$pb.TagNumber(20)
  set ledgerAssetAccountId($core.String value) => $_setString(18, value);
  @$pb.TagNumber(20)
  $core.bool hasLedgerAssetAccountId() => $_has(18);
  @$pb.TagNumber(20)
  void clearLedgerAssetAccountId() => $_clearField(20);

  @$pb.TagNumber(21)
  $core.String get ledgerInterestIncomeAccountId => $_getSZ(19);
  @$pb.TagNumber(21)
  set ledgerInterestIncomeAccountId($core.String value) =>
      $_setString(19, value);
  @$pb.TagNumber(21)
  $core.bool hasLedgerInterestIncomeAccountId() => $_has(19);
  @$pb.TagNumber(21)
  void clearLedgerInterestIncomeAccountId() => $_clearField(21);

  @$pb.TagNumber(22)
  $core.String get ledgerFeeIncomeAccountId => $_getSZ(20);
  @$pb.TagNumber(22)
  set ledgerFeeIncomeAccountId($core.String value) => $_setString(20, value);
  @$pb.TagNumber(22)
  $core.bool hasLedgerFeeIncomeAccountId() => $_has(20);
  @$pb.TagNumber(22)
  void clearLedgerFeeIncomeAccountId() => $_clearField(22);

  @$pb.TagNumber(23)
  $core.String get ledgerPenaltyIncomeAccountId => $_getSZ(21);
  @$pb.TagNumber(23)
  set ledgerPenaltyIncomeAccountId($core.String value) =>
      $_setString(21, value);
  @$pb.TagNumber(23)
  $core.bool hasLedgerPenaltyIncomeAccountId() => $_has(21);
  @$pb.TagNumber(23)
  void clearLedgerPenaltyIncomeAccountId() => $_clearField(23);

  /// payment_account_ref is the contact id of the borrower's verified mobile
  /// contact the loan is paid out to; never a number.
  @$pb.TagNumber(24)
  $core.String get paymentAccountRef => $_getSZ(22);
  @$pb.TagNumber(24)
  set paymentAccountRef($core.String value) => $_setString(22, value);
  @$pb.TagNumber(24)
  $core.bool hasPaymentAccountRef() => $_has(22);
  @$pb.TagNumber(24)
  void clearPaymentAccountRef() => $_clearField(24);

  @$pb.TagNumber(25)
  $1.Struct get properties => $_getN(23);
  @$pb.TagNumber(25)
  set properties($1.Struct value) => $_setField(25, value);
  @$pb.TagNumber(25)
  $core.bool hasProperties() => $_has(23);
  @$pb.TagNumber(25)
  void clearProperties() => $_clearField(25);
  @$pb.TagNumber(25)
  $1.Struct ensureProperties() => $_ensure(23);
}

/// RepaymentScheduleObject represents an amortization schedule for a loan.
class RepaymentScheduleObject extends $pb.GeneratedMessage {
  factory RepaymentScheduleObject({
    $core.String? id,
    $core.String? loanAccountId,
    $core.int? version,
    $core.bool? isActive,
    $core.String? generatedAt,
    $core.Iterable<ScheduleEntryObject>? entries,
    $1.Struct? properties,
  }) {
    final result = RepaymentScheduleObject._();
    if (id != null) result.id = id;
    if (loanAccountId != null) result.loanAccountId = loanAccountId;
    if (version != null) result.version = version;
    if (isActive != null) result.isActive = isActive;
    if (generatedAt != null) result.generatedAt = generatedAt;
    if (entries != null) result.entries.addAll(entries);
    if (properties != null) result.properties = properties;
    return result;
  }

  RepaymentScheduleObject._();

  factory RepaymentScheduleObject.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RepaymentScheduleObject()..mergeFromBuffer(data, registry);
  factory RepaymentScheduleObject.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RepaymentScheduleObject()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RepaymentScheduleObject',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: RepaymentScheduleObject.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'loanAccountId')
    ..aI(3, _omitFieldNames ? '' : 'version')
    ..aOB(4, _omitFieldNames ? '' : 'isActive')
    ..aOS(5, _omitFieldNames ? '' : 'generatedAt')
    ..pPM<ScheduleEntryObject>(6, _omitFieldNames ? '' : 'entries',
        subBuilder: ScheduleEntryObject.$_createMessage)
    ..aOM<$1.Struct>(7, _omitFieldNames ? '' : 'properties',
        subBuilder: $1.Struct.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RepaymentScheduleObject clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RepaymentScheduleObject copyWith(
          void Function(RepaymentScheduleObject) updates) =>
      super.copyWith((message) => updates(message as RepaymentScheduleObject))
          as RepaymentScheduleObject;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use RepaymentScheduleObject() / RepaymentScheduleObject.new instead')
  static RepaymentScheduleObject create() => RepaymentScheduleObject._();
  static $pb.GeneratedMessage $_createMessage() => RepaymentScheduleObject._();
  @$core.override
  RepaymentScheduleObject createEmptyInstance() => RepaymentScheduleObject._();
  @$core.pragma('dart2js:noInline')
  static RepaymentScheduleObject getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RepaymentScheduleObject>(
          RepaymentScheduleObject.$_createMessage);
  static RepaymentScheduleObject? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get loanAccountId => $_getSZ(1);
  @$pb.TagNumber(2)
  set loanAccountId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLoanAccountId() => $_has(1);
  @$pb.TagNumber(2)
  void clearLoanAccountId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get version => $_getIZ(2);
  @$pb.TagNumber(3)
  set version($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasVersion() => $_has(2);
  @$pb.TagNumber(3)
  void clearVersion() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get isActive => $_getBF(3);
  @$pb.TagNumber(4)
  set isActive($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasIsActive() => $_has(3);
  @$pb.TagNumber(4)
  void clearIsActive() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get generatedAt => $_getSZ(4);
  @$pb.TagNumber(5)
  set generatedAt($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasGeneratedAt() => $_has(4);
  @$pb.TagNumber(5)
  void clearGeneratedAt() => $_clearField(5);

  @$pb.TagNumber(6)
  $pb.PbList<ScheduleEntryObject> get entries => $_getList(5);

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

/// ScheduleEntryObject represents an individual installment in a repayment schedule.
class ScheduleEntryObject extends $pb.GeneratedMessage {
  factory ScheduleEntryObject({
    $core.String? id,
    $core.String? scheduleId,
    $core.int? installmentNumber,
    $core.String? dueDate,
    $0.Money? principalDue,
    $0.Money? interestDue,
    $0.Money? feesDue,
    $0.Money? totalDue,
    $0.Money? principalPaid,
    $0.Money? interestPaid,
    $0.Money? feesPaid,
    $0.Money? totalPaid,
    $0.Money? outstanding,
    ScheduleEntryStatus? status,
    $core.String? paidDate,
    $1.Struct? properties,
  }) {
    final result = ScheduleEntryObject._();
    if (id != null) result.id = id;
    if (scheduleId != null) result.scheduleId = scheduleId;
    if (installmentNumber != null) result.installmentNumber = installmentNumber;
    if (dueDate != null) result.dueDate = dueDate;
    if (principalDue != null) result.principalDue = principalDue;
    if (interestDue != null) result.interestDue = interestDue;
    if (feesDue != null) result.feesDue = feesDue;
    if (totalDue != null) result.totalDue = totalDue;
    if (principalPaid != null) result.principalPaid = principalPaid;
    if (interestPaid != null) result.interestPaid = interestPaid;
    if (feesPaid != null) result.feesPaid = feesPaid;
    if (totalPaid != null) result.totalPaid = totalPaid;
    if (outstanding != null) result.outstanding = outstanding;
    if (status != null) result.status = status;
    if (paidDate != null) result.paidDate = paidDate;
    if (properties != null) result.properties = properties;
    return result;
  }

  ScheduleEntryObject._();

  factory ScheduleEntryObject.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ScheduleEntryObject()..mergeFromBuffer(data, registry);
  factory ScheduleEntryObject.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ScheduleEntryObject()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ScheduleEntryObject',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: ScheduleEntryObject.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'scheduleId')
    ..aI(3, _omitFieldNames ? '' : 'installmentNumber')
    ..aOS(4, _omitFieldNames ? '' : 'dueDate')
    ..aOM<$0.Money>(5, _omitFieldNames ? '' : 'principalDue',
        subBuilder: $0.Money.$_createMessage)
    ..aOM<$0.Money>(6, _omitFieldNames ? '' : 'interestDue',
        subBuilder: $0.Money.$_createMessage)
    ..aOM<$0.Money>(7, _omitFieldNames ? '' : 'feesDue',
        subBuilder: $0.Money.$_createMessage)
    ..aOM<$0.Money>(8, _omitFieldNames ? '' : 'totalDue',
        subBuilder: $0.Money.$_createMessage)
    ..aOM<$0.Money>(9, _omitFieldNames ? '' : 'principalPaid',
        subBuilder: $0.Money.$_createMessage)
    ..aOM<$0.Money>(10, _omitFieldNames ? '' : 'interestPaid',
        subBuilder: $0.Money.$_createMessage)
    ..aOM<$0.Money>(11, _omitFieldNames ? '' : 'feesPaid',
        subBuilder: $0.Money.$_createMessage)
    ..aOM<$0.Money>(12, _omitFieldNames ? '' : 'totalPaid',
        subBuilder: $0.Money.$_createMessage)
    ..aOM<$0.Money>(13, _omitFieldNames ? '' : 'outstanding',
        subBuilder: $0.Money.$_createMessage)
    ..aE<ScheduleEntryStatus>(14, _omitFieldNames ? '' : 'status',
        enumValues: ScheduleEntryStatus.values)
    ..aOS(15, _omitFieldNames ? '' : 'paidDate')
    ..aOM<$1.Struct>(16, _omitFieldNames ? '' : 'properties',
        subBuilder: $1.Struct.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ScheduleEntryObject clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ScheduleEntryObject copyWith(void Function(ScheduleEntryObject) updates) =>
      super.copyWith((message) => updates(message as ScheduleEntryObject))
          as ScheduleEntryObject;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core
      .Deprecated('Use ScheduleEntryObject() / ScheduleEntryObject.new instead')
  static ScheduleEntryObject create() => ScheduleEntryObject._();
  static $pb.GeneratedMessage $_createMessage() => ScheduleEntryObject._();
  @$core.override
  ScheduleEntryObject createEmptyInstance() => ScheduleEntryObject._();
  @$core.pragma('dart2js:noInline')
  static ScheduleEntryObject getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ScheduleEntryObject>(
          ScheduleEntryObject.$_createMessage);
  static ScheduleEntryObject? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get scheduleId => $_getSZ(1);
  @$pb.TagNumber(2)
  set scheduleId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasScheduleId() => $_has(1);
  @$pb.TagNumber(2)
  void clearScheduleId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get installmentNumber => $_getIZ(2);
  @$pb.TagNumber(3)
  set installmentNumber($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasInstallmentNumber() => $_has(2);
  @$pb.TagNumber(3)
  void clearInstallmentNumber() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get dueDate => $_getSZ(3);
  @$pb.TagNumber(4)
  set dueDate($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDueDate() => $_has(3);
  @$pb.TagNumber(4)
  void clearDueDate() => $_clearField(4);

  @$pb.TagNumber(5)
  $0.Money get principalDue => $_getN(4);
  @$pb.TagNumber(5)
  set principalDue($0.Money value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasPrincipalDue() => $_has(4);
  @$pb.TagNumber(5)
  void clearPrincipalDue() => $_clearField(5);
  @$pb.TagNumber(5)
  $0.Money ensurePrincipalDue() => $_ensure(4);

  @$pb.TagNumber(6)
  $0.Money get interestDue => $_getN(5);
  @$pb.TagNumber(6)
  set interestDue($0.Money value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasInterestDue() => $_has(5);
  @$pb.TagNumber(6)
  void clearInterestDue() => $_clearField(6);
  @$pb.TagNumber(6)
  $0.Money ensureInterestDue() => $_ensure(5);

  @$pb.TagNumber(7)
  $0.Money get feesDue => $_getN(6);
  @$pb.TagNumber(7)
  set feesDue($0.Money value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasFeesDue() => $_has(6);
  @$pb.TagNumber(7)
  void clearFeesDue() => $_clearField(7);
  @$pb.TagNumber(7)
  $0.Money ensureFeesDue() => $_ensure(6);

  @$pb.TagNumber(8)
  $0.Money get totalDue => $_getN(7);
  @$pb.TagNumber(8)
  set totalDue($0.Money value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasTotalDue() => $_has(7);
  @$pb.TagNumber(8)
  void clearTotalDue() => $_clearField(8);
  @$pb.TagNumber(8)
  $0.Money ensureTotalDue() => $_ensure(7);

  @$pb.TagNumber(9)
  $0.Money get principalPaid => $_getN(8);
  @$pb.TagNumber(9)
  set principalPaid($0.Money value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasPrincipalPaid() => $_has(8);
  @$pb.TagNumber(9)
  void clearPrincipalPaid() => $_clearField(9);
  @$pb.TagNumber(9)
  $0.Money ensurePrincipalPaid() => $_ensure(8);

  @$pb.TagNumber(10)
  $0.Money get interestPaid => $_getN(9);
  @$pb.TagNumber(10)
  set interestPaid($0.Money value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasInterestPaid() => $_has(9);
  @$pb.TagNumber(10)
  void clearInterestPaid() => $_clearField(10);
  @$pb.TagNumber(10)
  $0.Money ensureInterestPaid() => $_ensure(9);

  @$pb.TagNumber(11)
  $0.Money get feesPaid => $_getN(10);
  @$pb.TagNumber(11)
  set feesPaid($0.Money value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasFeesPaid() => $_has(10);
  @$pb.TagNumber(11)
  void clearFeesPaid() => $_clearField(11);
  @$pb.TagNumber(11)
  $0.Money ensureFeesPaid() => $_ensure(10);

  @$pb.TagNumber(12)
  $0.Money get totalPaid => $_getN(11);
  @$pb.TagNumber(12)
  set totalPaid($0.Money value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasTotalPaid() => $_has(11);
  @$pb.TagNumber(12)
  void clearTotalPaid() => $_clearField(12);
  @$pb.TagNumber(12)
  $0.Money ensureTotalPaid() => $_ensure(11);

  @$pb.TagNumber(13)
  $0.Money get outstanding => $_getN(12);
  @$pb.TagNumber(13)
  set outstanding($0.Money value) => $_setField(13, value);
  @$pb.TagNumber(13)
  $core.bool hasOutstanding() => $_has(12);
  @$pb.TagNumber(13)
  void clearOutstanding() => $_clearField(13);
  @$pb.TagNumber(13)
  $0.Money ensureOutstanding() => $_ensure(12);

  @$pb.TagNumber(14)
  ScheduleEntryStatus get status => $_getN(13);
  @$pb.TagNumber(14)
  set status(ScheduleEntryStatus value) => $_setField(14, value);
  @$pb.TagNumber(14)
  $core.bool hasStatus() => $_has(13);
  @$pb.TagNumber(14)
  void clearStatus() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.String get paidDate => $_getSZ(14);
  @$pb.TagNumber(15)
  set paidDate($core.String value) => $_setString(14, value);
  @$pb.TagNumber(15)
  $core.bool hasPaidDate() => $_has(14);
  @$pb.TagNumber(15)
  void clearPaidDate() => $_clearField(15);

  @$pb.TagNumber(16)
  $1.Struct get properties => $_getN(15);
  @$pb.TagNumber(16)
  set properties($1.Struct value) => $_setField(16, value);
  @$pb.TagNumber(16)
  $core.bool hasProperties() => $_has(15);
  @$pb.TagNumber(16)
  void clearProperties() => $_clearField(16);
  @$pb.TagNumber(16)
  $1.Struct ensureProperties() => $_ensure(15);
}

/// LoanBalanceObject represents the current balance snapshot of a loan.
class LoanBalanceObject extends $pb.GeneratedMessage {
  factory LoanBalanceObject({
    $core.String? loanAccountId,
    $0.Money? principalOutstanding,
    $0.Money? interestAccrued,
    $0.Money? feesOutstanding,
    $0.Money? penaltiesOutstanding,
    $0.Money? totalOutstanding,
    $0.Money? totalPaid,
    $0.Money? totalDisbursed,
    $core.String? lastCalculatedAt,
  }) {
    final result = LoanBalanceObject._();
    if (loanAccountId != null) result.loanAccountId = loanAccountId;
    if (principalOutstanding != null)
      result.principalOutstanding = principalOutstanding;
    if (interestAccrued != null) result.interestAccrued = interestAccrued;
    if (feesOutstanding != null) result.feesOutstanding = feesOutstanding;
    if (penaltiesOutstanding != null)
      result.penaltiesOutstanding = penaltiesOutstanding;
    if (totalOutstanding != null) result.totalOutstanding = totalOutstanding;
    if (totalPaid != null) result.totalPaid = totalPaid;
    if (totalDisbursed != null) result.totalDisbursed = totalDisbursed;
    if (lastCalculatedAt != null) result.lastCalculatedAt = lastCalculatedAt;
    return result;
  }

  LoanBalanceObject._();

  factory LoanBalanceObject.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanBalanceObject()..mergeFromBuffer(data, registry);
  factory LoanBalanceObject.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanBalanceObject()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LoanBalanceObject',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: LoanBalanceObject.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'loanAccountId')
    ..aOM<$0.Money>(2, _omitFieldNames ? '' : 'principalOutstanding',
        subBuilder: $0.Money.$_createMessage)
    ..aOM<$0.Money>(3, _omitFieldNames ? '' : 'interestAccrued',
        subBuilder: $0.Money.$_createMessage)
    ..aOM<$0.Money>(4, _omitFieldNames ? '' : 'feesOutstanding',
        subBuilder: $0.Money.$_createMessage)
    ..aOM<$0.Money>(5, _omitFieldNames ? '' : 'penaltiesOutstanding',
        subBuilder: $0.Money.$_createMessage)
    ..aOM<$0.Money>(6, _omitFieldNames ? '' : 'totalOutstanding',
        subBuilder: $0.Money.$_createMessage)
    ..aOM<$0.Money>(7, _omitFieldNames ? '' : 'totalPaid',
        subBuilder: $0.Money.$_createMessage)
    ..aOM<$0.Money>(8, _omitFieldNames ? '' : 'totalDisbursed',
        subBuilder: $0.Money.$_createMessage)
    ..aOS(9, _omitFieldNames ? '' : 'lastCalculatedAt')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanBalanceObject clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanBalanceObject copyWith(void Function(LoanBalanceObject) updates) =>
      super.copyWith((message) => updates(message as LoanBalanceObject))
          as LoanBalanceObject;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use LoanBalanceObject() / LoanBalanceObject.new instead')
  static LoanBalanceObject create() => LoanBalanceObject._();
  static $pb.GeneratedMessage $_createMessage() => LoanBalanceObject._();
  @$core.override
  LoanBalanceObject createEmptyInstance() => LoanBalanceObject._();
  @$core.pragma('dart2js:noInline')
  static LoanBalanceObject getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LoanBalanceObject>(
          LoanBalanceObject.$_createMessage);
  static LoanBalanceObject? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get loanAccountId => $_getSZ(0);
  @$pb.TagNumber(1)
  set loanAccountId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLoanAccountId() => $_has(0);
  @$pb.TagNumber(1)
  void clearLoanAccountId() => $_clearField(1);

  @$pb.TagNumber(2)
  $0.Money get principalOutstanding => $_getN(1);
  @$pb.TagNumber(2)
  set principalOutstanding($0.Money value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasPrincipalOutstanding() => $_has(1);
  @$pb.TagNumber(2)
  void clearPrincipalOutstanding() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.Money ensurePrincipalOutstanding() => $_ensure(1);

  @$pb.TagNumber(3)
  $0.Money get interestAccrued => $_getN(2);
  @$pb.TagNumber(3)
  set interestAccrued($0.Money value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasInterestAccrued() => $_has(2);
  @$pb.TagNumber(3)
  void clearInterestAccrued() => $_clearField(3);
  @$pb.TagNumber(3)
  $0.Money ensureInterestAccrued() => $_ensure(2);

  @$pb.TagNumber(4)
  $0.Money get feesOutstanding => $_getN(3);
  @$pb.TagNumber(4)
  set feesOutstanding($0.Money value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasFeesOutstanding() => $_has(3);
  @$pb.TagNumber(4)
  void clearFeesOutstanding() => $_clearField(4);
  @$pb.TagNumber(4)
  $0.Money ensureFeesOutstanding() => $_ensure(3);

  @$pb.TagNumber(5)
  $0.Money get penaltiesOutstanding => $_getN(4);
  @$pb.TagNumber(5)
  set penaltiesOutstanding($0.Money value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasPenaltiesOutstanding() => $_has(4);
  @$pb.TagNumber(5)
  void clearPenaltiesOutstanding() => $_clearField(5);
  @$pb.TagNumber(5)
  $0.Money ensurePenaltiesOutstanding() => $_ensure(4);

  @$pb.TagNumber(6)
  $0.Money get totalOutstanding => $_getN(5);
  @$pb.TagNumber(6)
  set totalOutstanding($0.Money value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasTotalOutstanding() => $_has(5);
  @$pb.TagNumber(6)
  void clearTotalOutstanding() => $_clearField(6);
  @$pb.TagNumber(6)
  $0.Money ensureTotalOutstanding() => $_ensure(5);

  @$pb.TagNumber(7)
  $0.Money get totalPaid => $_getN(6);
  @$pb.TagNumber(7)
  set totalPaid($0.Money value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasTotalPaid() => $_has(6);
  @$pb.TagNumber(7)
  void clearTotalPaid() => $_clearField(7);
  @$pb.TagNumber(7)
  $0.Money ensureTotalPaid() => $_ensure(6);

  @$pb.TagNumber(8)
  $0.Money get totalDisbursed => $_getN(7);
  @$pb.TagNumber(8)
  set totalDisbursed($0.Money value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasTotalDisbursed() => $_has(7);
  @$pb.TagNumber(8)
  void clearTotalDisbursed() => $_clearField(8);
  @$pb.TagNumber(8)
  $0.Money ensureTotalDisbursed() => $_ensure(7);

  @$pb.TagNumber(9)
  $core.String get lastCalculatedAt => $_getSZ(8);
  @$pb.TagNumber(9)
  set lastCalculatedAt($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasLastCalculatedAt() => $_has(8);
  @$pb.TagNumber(9)
  void clearLastCalculatedAt() => $_clearField(9);
}

/// DisbursementObject represents a loan amount paid out to the client.
class DisbursementObject extends $pb.GeneratedMessage {
  factory DisbursementObject({
    $core.String? id,
    $core.String? loanAccountId,
    $0.Money? amount,
    DisbursementStatus? status,
    $core.String? paymentReference,
    $core.String? ledgerTransactionId,
    $core.String? disbursedAt,
    $core.String? channel,
    $core.String? recipientReference,
    $core.String? failureReason,
    $core.String? idempotencyKey,
    $1.Struct? properties,
  }) {
    final result = DisbursementObject._();
    if (id != null) result.id = id;
    if (loanAccountId != null) result.loanAccountId = loanAccountId;
    if (amount != null) result.amount = amount;
    if (status != null) result.status = status;
    if (paymentReference != null) result.paymentReference = paymentReference;
    if (ledgerTransactionId != null)
      result.ledgerTransactionId = ledgerTransactionId;
    if (disbursedAt != null) result.disbursedAt = disbursedAt;
    if (channel != null) result.channel = channel;
    if (recipientReference != null)
      result.recipientReference = recipientReference;
    if (failureReason != null) result.failureReason = failureReason;
    if (idempotencyKey != null) result.idempotencyKey = idempotencyKey;
    if (properties != null) result.properties = properties;
    return result;
  }

  DisbursementObject._();

  factory DisbursementObject.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DisbursementObject()..mergeFromBuffer(data, registry);
  factory DisbursementObject.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DisbursementObject()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DisbursementObject',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: DisbursementObject.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'loanAccountId')
    ..aOM<$0.Money>(3, _omitFieldNames ? '' : 'amount',
        subBuilder: $0.Money.$_createMessage)
    ..aE<DisbursementStatus>(5, _omitFieldNames ? '' : 'status',
        enumValues: DisbursementStatus.values)
    ..aOS(6, _omitFieldNames ? '' : 'paymentReference')
    ..aOS(7, _omitFieldNames ? '' : 'ledgerTransactionId')
    ..aOS(8, _omitFieldNames ? '' : 'disbursedAt')
    ..aOS(9, _omitFieldNames ? '' : 'channel')
    ..aOS(10, _omitFieldNames ? '' : 'recipientReference')
    ..aOS(11, _omitFieldNames ? '' : 'failureReason')
    ..aOS(12, _omitFieldNames ? '' : 'idempotencyKey')
    ..aOM<$1.Struct>(13, _omitFieldNames ? '' : 'properties',
        subBuilder: $1.Struct.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DisbursementObject clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DisbursementObject copyWith(void Function(DisbursementObject) updates) =>
      super.copyWith((message) => updates(message as DisbursementObject))
          as DisbursementObject;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DisbursementObject() / DisbursementObject.new instead')
  static DisbursementObject create() => DisbursementObject._();
  static $pb.GeneratedMessage $_createMessage() => DisbursementObject._();
  @$core.override
  DisbursementObject createEmptyInstance() => DisbursementObject._();
  @$core.pragma('dart2js:noInline')
  static DisbursementObject getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DisbursementObject>(
          DisbursementObject.$_createMessage);
  static DisbursementObject? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get loanAccountId => $_getSZ(1);
  @$pb.TagNumber(2)
  set loanAccountId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLoanAccountId() => $_has(1);
  @$pb.TagNumber(2)
  void clearLoanAccountId() => $_clearField(2);

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

  /// Field 4 removed (currency_code now in Money).
  @$pb.TagNumber(5)
  DisbursementStatus get status => $_getN(3);
  @$pb.TagNumber(5)
  set status(DisbursementStatus value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasStatus() => $_has(3);
  @$pb.TagNumber(5)
  void clearStatus() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get paymentReference => $_getSZ(4);
  @$pb.TagNumber(6)
  set paymentReference($core.String value) => $_setString(4, value);
  @$pb.TagNumber(6)
  $core.bool hasPaymentReference() => $_has(4);
  @$pb.TagNumber(6)
  void clearPaymentReference() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get ledgerTransactionId => $_getSZ(5);
  @$pb.TagNumber(7)
  set ledgerTransactionId($core.String value) => $_setString(5, value);
  @$pb.TagNumber(7)
  $core.bool hasLedgerTransactionId() => $_has(5);
  @$pb.TagNumber(7)
  void clearLedgerTransactionId() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get disbursedAt => $_getSZ(6);
  @$pb.TagNumber(8)
  set disbursedAt($core.String value) => $_setString(6, value);
  @$pb.TagNumber(8)
  $core.bool hasDisbursedAt() => $_has(6);
  @$pb.TagNumber(8)
  void clearDisbursedAt() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get channel => $_getSZ(7);
  @$pb.TagNumber(9)
  set channel($core.String value) => $_setString(7, value);
  @$pb.TagNumber(9)
  $core.bool hasChannel() => $_has(7);
  @$pb.TagNumber(9)
  void clearChannel() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get recipientReference => $_getSZ(8);
  @$pb.TagNumber(10)
  set recipientReference($core.String value) => $_setString(8, value);
  @$pb.TagNumber(10)
  $core.bool hasRecipientReference() => $_has(8);
  @$pb.TagNumber(10)
  void clearRecipientReference() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get failureReason => $_getSZ(9);
  @$pb.TagNumber(11)
  set failureReason($core.String value) => $_setString(9, value);
  @$pb.TagNumber(11)
  $core.bool hasFailureReason() => $_has(9);
  @$pb.TagNumber(11)
  void clearFailureReason() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.String get idempotencyKey => $_getSZ(10);
  @$pb.TagNumber(12)
  set idempotencyKey($core.String value) => $_setString(10, value);
  @$pb.TagNumber(12)
  $core.bool hasIdempotencyKey() => $_has(10);
  @$pb.TagNumber(12)
  void clearIdempotencyKey() => $_clearField(12);

  @$pb.TagNumber(13)
  $1.Struct get properties => $_getN(11);
  @$pb.TagNumber(13)
  set properties($1.Struct value) => $_setField(13, value);
  @$pb.TagNumber(13)
  $core.bool hasProperties() => $_has(11);
  @$pb.TagNumber(13)
  void clearProperties() => $_clearField(13);
  @$pb.TagNumber(13)
  $1.Struct ensureProperties() => $_ensure(11);
}

/// RepaymentObject represents an incoming payment record for a loan.
class RepaymentObject extends $pb.GeneratedMessage {
  factory RepaymentObject({
    $core.String? id,
    $core.String? loanAccountId,
    $0.Money? amount,
    RepaymentStatus? status,
    $core.String? paymentReference,
    $core.String? ledgerTransactionId,
    $core.String? receivedAt,
    $core.String? channel,
    $core.String? payerReference,
    $0.Money? principalApplied,
    $0.Money? interestApplied,
    $0.Money? feesApplied,
    $0.Money? penaltiesApplied,
    $0.Money? excessAmount,
    $core.String? idempotencyKey,
    $1.Struct? properties,
    @$core.Deprecated('This field is deprecated.') $core.String? collectedBy,
  }) {
    final result = RepaymentObject._();
    if (id != null) result.id = id;
    if (loanAccountId != null) result.loanAccountId = loanAccountId;
    if (amount != null) result.amount = amount;
    if (status != null) result.status = status;
    if (paymentReference != null) result.paymentReference = paymentReference;
    if (ledgerTransactionId != null)
      result.ledgerTransactionId = ledgerTransactionId;
    if (receivedAt != null) result.receivedAt = receivedAt;
    if (channel != null) result.channel = channel;
    if (payerReference != null) result.payerReference = payerReference;
    if (principalApplied != null) result.principalApplied = principalApplied;
    if (interestApplied != null) result.interestApplied = interestApplied;
    if (feesApplied != null) result.feesApplied = feesApplied;
    if (penaltiesApplied != null) result.penaltiesApplied = penaltiesApplied;
    if (excessAmount != null) result.excessAmount = excessAmount;
    if (idempotencyKey != null) result.idempotencyKey = idempotencyKey;
    if (properties != null) result.properties = properties;
    if (collectedBy != null) result.collectedBy = collectedBy;
    return result;
  }

  RepaymentObject._();

  factory RepaymentObject.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RepaymentObject()..mergeFromBuffer(data, registry);
  factory RepaymentObject.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RepaymentObject()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RepaymentObject',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: RepaymentObject.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'loanAccountId')
    ..aOM<$0.Money>(3, _omitFieldNames ? '' : 'amount',
        subBuilder: $0.Money.$_createMessage)
    ..aE<RepaymentStatus>(5, _omitFieldNames ? '' : 'status',
        enumValues: RepaymentStatus.values)
    ..aOS(6, _omitFieldNames ? '' : 'paymentReference')
    ..aOS(7, _omitFieldNames ? '' : 'ledgerTransactionId')
    ..aOS(8, _omitFieldNames ? '' : 'receivedAt')
    ..aOS(9, _omitFieldNames ? '' : 'channel')
    ..aOS(10, _omitFieldNames ? '' : 'payerReference')
    ..aOM<$0.Money>(11, _omitFieldNames ? '' : 'principalApplied',
        subBuilder: $0.Money.$_createMessage)
    ..aOM<$0.Money>(12, _omitFieldNames ? '' : 'interestApplied',
        subBuilder: $0.Money.$_createMessage)
    ..aOM<$0.Money>(13, _omitFieldNames ? '' : 'feesApplied',
        subBuilder: $0.Money.$_createMessage)
    ..aOM<$0.Money>(14, _omitFieldNames ? '' : 'penaltiesApplied',
        subBuilder: $0.Money.$_createMessage)
    ..aOM<$0.Money>(15, _omitFieldNames ? '' : 'excessAmount',
        subBuilder: $0.Money.$_createMessage)
    ..aOS(16, _omitFieldNames ? '' : 'idempotencyKey')
    ..aOM<$1.Struct>(17, _omitFieldNames ? '' : 'properties',
        subBuilder: $1.Struct.$_createMessage)
    ..aOS(18, _omitFieldNames ? '' : 'collectedBy')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RepaymentObject clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RepaymentObject copyWith(void Function(RepaymentObject) updates) =>
      super.copyWith((message) => updates(message as RepaymentObject))
          as RepaymentObject;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use RepaymentObject() / RepaymentObject.new instead')
  static RepaymentObject create() => RepaymentObject._();
  static $pb.GeneratedMessage $_createMessage() => RepaymentObject._();
  @$core.override
  RepaymentObject createEmptyInstance() => RepaymentObject._();
  @$core.pragma('dart2js:noInline')
  static RepaymentObject getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RepaymentObject>(
          RepaymentObject.$_createMessage);
  static RepaymentObject? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get loanAccountId => $_getSZ(1);
  @$pb.TagNumber(2)
  set loanAccountId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLoanAccountId() => $_has(1);
  @$pb.TagNumber(2)
  void clearLoanAccountId() => $_clearField(2);

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

  /// Field 4 removed (currency_code now in Money).
  @$pb.TagNumber(5)
  RepaymentStatus get status => $_getN(3);
  @$pb.TagNumber(5)
  set status(RepaymentStatus value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasStatus() => $_has(3);
  @$pb.TagNumber(5)
  void clearStatus() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get paymentReference => $_getSZ(4);
  @$pb.TagNumber(6)
  set paymentReference($core.String value) => $_setString(4, value);
  @$pb.TagNumber(6)
  $core.bool hasPaymentReference() => $_has(4);
  @$pb.TagNumber(6)
  void clearPaymentReference() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get ledgerTransactionId => $_getSZ(5);
  @$pb.TagNumber(7)
  set ledgerTransactionId($core.String value) => $_setString(5, value);
  @$pb.TagNumber(7)
  $core.bool hasLedgerTransactionId() => $_has(5);
  @$pb.TagNumber(7)
  void clearLedgerTransactionId() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get receivedAt => $_getSZ(6);
  @$pb.TagNumber(8)
  set receivedAt($core.String value) => $_setString(6, value);
  @$pb.TagNumber(8)
  $core.bool hasReceivedAt() => $_has(6);
  @$pb.TagNumber(8)
  void clearReceivedAt() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get channel => $_getSZ(7);
  @$pb.TagNumber(9)
  set channel($core.String value) => $_setString(7, value);
  @$pb.TagNumber(9)
  $core.bool hasChannel() => $_has(7);
  @$pb.TagNumber(9)
  void clearChannel() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get payerReference => $_getSZ(8);
  @$pb.TagNumber(10)
  set payerReference($core.String value) => $_setString(8, value);
  @$pb.TagNumber(10)
  $core.bool hasPayerReference() => $_has(8);
  @$pb.TagNumber(10)
  void clearPayerReference() => $_clearField(10);

  @$pb.TagNumber(11)
  $0.Money get principalApplied => $_getN(9);
  @$pb.TagNumber(11)
  set principalApplied($0.Money value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasPrincipalApplied() => $_has(9);
  @$pb.TagNumber(11)
  void clearPrincipalApplied() => $_clearField(11);
  @$pb.TagNumber(11)
  $0.Money ensurePrincipalApplied() => $_ensure(9);

  @$pb.TagNumber(12)
  $0.Money get interestApplied => $_getN(10);
  @$pb.TagNumber(12)
  set interestApplied($0.Money value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasInterestApplied() => $_has(10);
  @$pb.TagNumber(12)
  void clearInterestApplied() => $_clearField(12);
  @$pb.TagNumber(12)
  $0.Money ensureInterestApplied() => $_ensure(10);

  @$pb.TagNumber(13)
  $0.Money get feesApplied => $_getN(11);
  @$pb.TagNumber(13)
  set feesApplied($0.Money value) => $_setField(13, value);
  @$pb.TagNumber(13)
  $core.bool hasFeesApplied() => $_has(11);
  @$pb.TagNumber(13)
  void clearFeesApplied() => $_clearField(13);
  @$pb.TagNumber(13)
  $0.Money ensureFeesApplied() => $_ensure(11);

  @$pb.TagNumber(14)
  $0.Money get penaltiesApplied => $_getN(12);
  @$pb.TagNumber(14)
  set penaltiesApplied($0.Money value) => $_setField(14, value);
  @$pb.TagNumber(14)
  $core.bool hasPenaltiesApplied() => $_has(12);
  @$pb.TagNumber(14)
  void clearPenaltiesApplied() => $_clearField(14);
  @$pb.TagNumber(14)
  $0.Money ensurePenaltiesApplied() => $_ensure(12);

  @$pb.TagNumber(15)
  $0.Money get excessAmount => $_getN(13);
  @$pb.TagNumber(15)
  set excessAmount($0.Money value) => $_setField(15, value);
  @$pb.TagNumber(15)
  $core.bool hasExcessAmount() => $_has(13);
  @$pb.TagNumber(15)
  void clearExcessAmount() => $_clearField(15);
  @$pb.TagNumber(15)
  $0.Money ensureExcessAmount() => $_ensure(13);

  @$pb.TagNumber(16)
  $core.String get idempotencyKey => $_getSZ(14);
  @$pb.TagNumber(16)
  set idempotencyKey($core.String value) => $_setString(14, value);
  @$pb.TagNumber(16)
  $core.bool hasIdempotencyKey() => $_has(14);
  @$pb.TagNumber(16)
  void clearIdempotencyKey() => $_clearField(16);

  @$pb.TagNumber(17)
  $1.Struct get properties => $_getN(15);
  @$pb.TagNumber(17)
  set properties($1.Struct value) => $_setField(17, value);
  @$pb.TagNumber(17)
  $core.bool hasProperties() => $_has(15);
  @$pb.TagNumber(17)
  void clearProperties() => $_clearField(17);
  @$pb.TagNumber(17)
  $1.Struct ensureProperties() => $_ensure(15);

  /// Deprecated and always empty: field agents and staff never handle a
  /// borrower's money. Every repayment is a payment the borrower made from
  /// their own contact.
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(18)
  $core.String get collectedBy => $_getSZ(16);
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(18)
  set collectedBy($core.String value) => $_setString(16, value);
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(18)
  $core.bool hasCollectedBy() => $_has(16);
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(18)
  void clearCollectedBy() => $_clearField(18);
}

/// PenaltyObject represents a penalty applied to a loan.
class PenaltyObject extends $pb.GeneratedMessage {
  factory PenaltyObject({
    $core.String? id,
    $core.String? loanAccountId,
    PenaltyType? penaltyType,
    $0.Money? amount,
    $core.String? reason,
    $core.bool? isWaived,
    $core.String? waivedBy,
    $core.String? waivedReason,
    $core.String? ledgerTransactionId,
    $core.String? appliedAt,
    $core.String? scheduleEntryId,
    $1.Struct? properties,
  }) {
    final result = PenaltyObject._();
    if (id != null) result.id = id;
    if (loanAccountId != null) result.loanAccountId = loanAccountId;
    if (penaltyType != null) result.penaltyType = penaltyType;
    if (amount != null) result.amount = amount;
    if (reason != null) result.reason = reason;
    if (isWaived != null) result.isWaived = isWaived;
    if (waivedBy != null) result.waivedBy = waivedBy;
    if (waivedReason != null) result.waivedReason = waivedReason;
    if (ledgerTransactionId != null)
      result.ledgerTransactionId = ledgerTransactionId;
    if (appliedAt != null) result.appliedAt = appliedAt;
    if (scheduleEntryId != null) result.scheduleEntryId = scheduleEntryId;
    if (properties != null) result.properties = properties;
    return result;
  }

  PenaltyObject._();

  factory PenaltyObject.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PenaltyObject()..mergeFromBuffer(data, registry);
  factory PenaltyObject.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PenaltyObject()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PenaltyObject',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: PenaltyObject.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'loanAccountId')
    ..aE<PenaltyType>(3, _omitFieldNames ? '' : 'penaltyType',
        enumValues: PenaltyType.values)
    ..aOM<$0.Money>(4, _omitFieldNames ? '' : 'amount',
        subBuilder: $0.Money.$_createMessage)
    ..aOS(5, _omitFieldNames ? '' : 'reason')
    ..aOB(6, _omitFieldNames ? '' : 'isWaived')
    ..aOS(7, _omitFieldNames ? '' : 'waivedBy')
    ..aOS(8, _omitFieldNames ? '' : 'waivedReason')
    ..aOS(9, _omitFieldNames ? '' : 'ledgerTransactionId')
    ..aOS(10, _omitFieldNames ? '' : 'appliedAt')
    ..aOS(11, _omitFieldNames ? '' : 'scheduleEntryId')
    ..aOM<$1.Struct>(12, _omitFieldNames ? '' : 'properties',
        subBuilder: $1.Struct.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PenaltyObject clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PenaltyObject copyWith(void Function(PenaltyObject) updates) =>
      super.copyWith((message) => updates(message as PenaltyObject))
          as PenaltyObject;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use PenaltyObject() / PenaltyObject.new instead')
  static PenaltyObject create() => PenaltyObject._();
  static $pb.GeneratedMessage $_createMessage() => PenaltyObject._();
  @$core.override
  PenaltyObject createEmptyInstance() => PenaltyObject._();
  @$core.pragma('dart2js:noInline')
  static PenaltyObject getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PenaltyObject>(
          PenaltyObject.$_createMessage);
  static PenaltyObject? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get loanAccountId => $_getSZ(1);
  @$pb.TagNumber(2)
  set loanAccountId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLoanAccountId() => $_has(1);
  @$pb.TagNumber(2)
  void clearLoanAccountId() => $_clearField(2);

  @$pb.TagNumber(3)
  PenaltyType get penaltyType => $_getN(2);
  @$pb.TagNumber(3)
  set penaltyType(PenaltyType value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasPenaltyType() => $_has(2);
  @$pb.TagNumber(3)
  void clearPenaltyType() => $_clearField(3);

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

  @$pb.TagNumber(5)
  $core.String get reason => $_getSZ(4);
  @$pb.TagNumber(5)
  set reason($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasReason() => $_has(4);
  @$pb.TagNumber(5)
  void clearReason() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get isWaived => $_getBF(5);
  @$pb.TagNumber(6)
  set isWaived($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasIsWaived() => $_has(5);
  @$pb.TagNumber(6)
  void clearIsWaived() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get waivedBy => $_getSZ(6);
  @$pb.TagNumber(7)
  set waivedBy($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasWaivedBy() => $_has(6);
  @$pb.TagNumber(7)
  void clearWaivedBy() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get waivedReason => $_getSZ(7);
  @$pb.TagNumber(8)
  set waivedReason($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasWaivedReason() => $_has(7);
  @$pb.TagNumber(8)
  void clearWaivedReason() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get ledgerTransactionId => $_getSZ(8);
  @$pb.TagNumber(9)
  set ledgerTransactionId($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasLedgerTransactionId() => $_has(8);
  @$pb.TagNumber(9)
  void clearLedgerTransactionId() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get appliedAt => $_getSZ(9);
  @$pb.TagNumber(10)
  set appliedAt($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasAppliedAt() => $_has(9);
  @$pb.TagNumber(10)
  void clearAppliedAt() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get scheduleEntryId => $_getSZ(10);
  @$pb.TagNumber(11)
  set scheduleEntryId($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasScheduleEntryId() => $_has(10);
  @$pb.TagNumber(11)
  void clearScheduleEntryId() => $_clearField(11);

  @$pb.TagNumber(12)
  $1.Struct get properties => $_getN(11);
  @$pb.TagNumber(12)
  set properties($1.Struct value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasProperties() => $_has(11);
  @$pb.TagNumber(12)
  void clearProperties() => $_clearField(12);
  @$pb.TagNumber(12)
  $1.Struct ensureProperties() => $_ensure(11);
}

/// LoanRestructureObject represents a loan terms modification.
class LoanRestructureObject extends $pb.GeneratedMessage {
  factory LoanRestructureObject({
    $core.String? id,
    $core.String? loanAccountId,
    RestructureType? restructureType,
    $core.String? requestedBy,
    $core.String? approvedBy,
    $core.String? reason,
    $core.String? oldInterestRate,
    $core.String? newInterestRate,
    $core.int? oldTermDays,
    $core.int? newTermDays,
    $0.Money? waivedAmount,
    $core.String? oldScheduleId,
    $core.String? newScheduleId,
    $2.STATE? state,
    $1.Struct? properties,
  }) {
    final result = LoanRestructureObject._();
    if (id != null) result.id = id;
    if (loanAccountId != null) result.loanAccountId = loanAccountId;
    if (restructureType != null) result.restructureType = restructureType;
    if (requestedBy != null) result.requestedBy = requestedBy;
    if (approvedBy != null) result.approvedBy = approvedBy;
    if (reason != null) result.reason = reason;
    if (oldInterestRate != null) result.oldInterestRate = oldInterestRate;
    if (newInterestRate != null) result.newInterestRate = newInterestRate;
    if (oldTermDays != null) result.oldTermDays = oldTermDays;
    if (newTermDays != null) result.newTermDays = newTermDays;
    if (waivedAmount != null) result.waivedAmount = waivedAmount;
    if (oldScheduleId != null) result.oldScheduleId = oldScheduleId;
    if (newScheduleId != null) result.newScheduleId = newScheduleId;
    if (state != null) result.state = state;
    if (properties != null) result.properties = properties;
    return result;
  }

  LoanRestructureObject._();

  factory LoanRestructureObject.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanRestructureObject()..mergeFromBuffer(data, registry);
  factory LoanRestructureObject.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanRestructureObject()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LoanRestructureObject',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: LoanRestructureObject.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'loanAccountId')
    ..aE<RestructureType>(3, _omitFieldNames ? '' : 'restructureType',
        enumValues: RestructureType.values)
    ..aOS(4, _omitFieldNames ? '' : 'requestedBy')
    ..aOS(5, _omitFieldNames ? '' : 'approvedBy')
    ..aOS(6, _omitFieldNames ? '' : 'reason')
    ..aOS(7, _omitFieldNames ? '' : 'oldInterestRate')
    ..aOS(8, _omitFieldNames ? '' : 'newInterestRate')
    ..aI(9, _omitFieldNames ? '' : 'oldTermDays')
    ..aI(10, _omitFieldNames ? '' : 'newTermDays')
    ..aOM<$0.Money>(11, _omitFieldNames ? '' : 'waivedAmount',
        subBuilder: $0.Money.$_createMessage)
    ..aOS(12, _omitFieldNames ? '' : 'oldScheduleId')
    ..aOS(13, _omitFieldNames ? '' : 'newScheduleId')
    ..aE<$2.STATE>(14, _omitFieldNames ? '' : 'state',
        enumValues: $2.STATE.values)
    ..aOM<$1.Struct>(15, _omitFieldNames ? '' : 'properties',
        subBuilder: $1.Struct.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanRestructureObject clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanRestructureObject copyWith(
          void Function(LoanRestructureObject) updates) =>
      super.copyWith((message) => updates(message as LoanRestructureObject))
          as LoanRestructureObject;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use LoanRestructureObject() / LoanRestructureObject.new instead')
  static LoanRestructureObject create() => LoanRestructureObject._();
  static $pb.GeneratedMessage $_createMessage() => LoanRestructureObject._();
  @$core.override
  LoanRestructureObject createEmptyInstance() => LoanRestructureObject._();
  @$core.pragma('dart2js:noInline')
  static LoanRestructureObject getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LoanRestructureObject>(
          LoanRestructureObject.$_createMessage);
  static LoanRestructureObject? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get loanAccountId => $_getSZ(1);
  @$pb.TagNumber(2)
  set loanAccountId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLoanAccountId() => $_has(1);
  @$pb.TagNumber(2)
  void clearLoanAccountId() => $_clearField(2);

  @$pb.TagNumber(3)
  RestructureType get restructureType => $_getN(2);
  @$pb.TagNumber(3)
  set restructureType(RestructureType value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasRestructureType() => $_has(2);
  @$pb.TagNumber(3)
  void clearRestructureType() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get requestedBy => $_getSZ(3);
  @$pb.TagNumber(4)
  set requestedBy($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasRequestedBy() => $_has(3);
  @$pb.TagNumber(4)
  void clearRequestedBy() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get approvedBy => $_getSZ(4);
  @$pb.TagNumber(5)
  set approvedBy($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasApprovedBy() => $_has(4);
  @$pb.TagNumber(5)
  void clearApprovedBy() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get reason => $_getSZ(5);
  @$pb.TagNumber(6)
  set reason($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasReason() => $_has(5);
  @$pb.TagNumber(6)
  void clearReason() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get oldInterestRate => $_getSZ(6);
  @$pb.TagNumber(7)
  set oldInterestRate($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasOldInterestRate() => $_has(6);
  @$pb.TagNumber(7)
  void clearOldInterestRate() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get newInterestRate => $_getSZ(7);
  @$pb.TagNumber(8)
  set newInterestRate($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasNewInterestRate() => $_has(7);
  @$pb.TagNumber(8)
  void clearNewInterestRate() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.int get oldTermDays => $_getIZ(8);
  @$pb.TagNumber(9)
  set oldTermDays($core.int value) => $_setSignedInt32(8, value);
  @$pb.TagNumber(9)
  $core.bool hasOldTermDays() => $_has(8);
  @$pb.TagNumber(9)
  void clearOldTermDays() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.int get newTermDays => $_getIZ(9);
  @$pb.TagNumber(10)
  set newTermDays($core.int value) => $_setSignedInt32(9, value);
  @$pb.TagNumber(10)
  $core.bool hasNewTermDays() => $_has(9);
  @$pb.TagNumber(10)
  void clearNewTermDays() => $_clearField(10);

  @$pb.TagNumber(11)
  $0.Money get waivedAmount => $_getN(10);
  @$pb.TagNumber(11)
  set waivedAmount($0.Money value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasWaivedAmount() => $_has(10);
  @$pb.TagNumber(11)
  void clearWaivedAmount() => $_clearField(11);
  @$pb.TagNumber(11)
  $0.Money ensureWaivedAmount() => $_ensure(10);

  @$pb.TagNumber(12)
  $core.String get oldScheduleId => $_getSZ(11);
  @$pb.TagNumber(12)
  set oldScheduleId($core.String value) => $_setString(11, value);
  @$pb.TagNumber(12)
  $core.bool hasOldScheduleId() => $_has(11);
  @$pb.TagNumber(12)
  void clearOldScheduleId() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.String get newScheduleId => $_getSZ(12);
  @$pb.TagNumber(13)
  set newScheduleId($core.String value) => $_setString(12, value);
  @$pb.TagNumber(13)
  $core.bool hasNewScheduleId() => $_has(12);
  @$pb.TagNumber(13)
  void clearNewScheduleId() => $_clearField(13);

  @$pb.TagNumber(14)
  $2.STATE get state => $_getN(13);
  @$pb.TagNumber(14)
  set state($2.STATE value) => $_setField(14, value);
  @$pb.TagNumber(14)
  $core.bool hasState() => $_has(13);
  @$pb.TagNumber(14)
  void clearState() => $_clearField(14);

  @$pb.TagNumber(15)
  $1.Struct get properties => $_getN(14);
  @$pb.TagNumber(15)
  set properties($1.Struct value) => $_setField(15, value);
  @$pb.TagNumber(15)
  $core.bool hasProperties() => $_has(14);
  @$pb.TagNumber(15)
  void clearProperties() => $_clearField(15);
  @$pb.TagNumber(15)
  $1.Struct ensureProperties() => $_ensure(14);
}

/// LoanStatusChangeObject records a loan status transition for audit.
class LoanStatusChangeObject extends $pb.GeneratedMessage {
  factory LoanStatusChangeObject({
    $core.String? id,
    $core.String? loanAccountId,
    $core.int? fromStatus,
    $core.int? toStatus,
    $core.String? changedBy,
    $core.String? reason,
    $core.String? changedAt,
  }) {
    final result = LoanStatusChangeObject._();
    if (id != null) result.id = id;
    if (loanAccountId != null) result.loanAccountId = loanAccountId;
    if (fromStatus != null) result.fromStatus = fromStatus;
    if (toStatus != null) result.toStatus = toStatus;
    if (changedBy != null) result.changedBy = changedBy;
    if (reason != null) result.reason = reason;
    if (changedAt != null) result.changedAt = changedAt;
    return result;
  }

  LoanStatusChangeObject._();

  factory LoanStatusChangeObject.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanStatusChangeObject()..mergeFromBuffer(data, registry);
  factory LoanStatusChangeObject.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanStatusChangeObject()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LoanStatusChangeObject',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: LoanStatusChangeObject.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'loanAccountId')
    ..aI(3, _omitFieldNames ? '' : 'fromStatus')
    ..aI(4, _omitFieldNames ? '' : 'toStatus')
    ..aOS(5, _omitFieldNames ? '' : 'changedBy')
    ..aOS(6, _omitFieldNames ? '' : 'reason')
    ..aOS(7, _omitFieldNames ? '' : 'changedAt')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanStatusChangeObject clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanStatusChangeObject copyWith(
          void Function(LoanStatusChangeObject) updates) =>
      super.copyWith((message) => updates(message as LoanStatusChangeObject))
          as LoanStatusChangeObject;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use LoanStatusChangeObject() / LoanStatusChangeObject.new instead')
  static LoanStatusChangeObject create() => LoanStatusChangeObject._();
  static $pb.GeneratedMessage $_createMessage() => LoanStatusChangeObject._();
  @$core.override
  LoanStatusChangeObject createEmptyInstance() => LoanStatusChangeObject._();
  @$core.pragma('dart2js:noInline')
  static LoanStatusChangeObject getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LoanStatusChangeObject>(
          LoanStatusChangeObject.$_createMessage);
  static LoanStatusChangeObject? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get loanAccountId => $_getSZ(1);
  @$pb.TagNumber(2)
  set loanAccountId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLoanAccountId() => $_has(1);
  @$pb.TagNumber(2)
  void clearLoanAccountId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get fromStatus => $_getIZ(2);
  @$pb.TagNumber(3)
  set fromStatus($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFromStatus() => $_has(2);
  @$pb.TagNumber(3)
  void clearFromStatus() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get toStatus => $_getIZ(3);
  @$pb.TagNumber(4)
  set toStatus($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasToStatus() => $_has(3);
  @$pb.TagNumber(4)
  void clearToStatus() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get changedBy => $_getSZ(4);
  @$pb.TagNumber(5)
  set changedBy($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasChangedBy() => $_has(4);
  @$pb.TagNumber(5)
  void clearChangedBy() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get reason => $_getSZ(5);
  @$pb.TagNumber(6)
  set reason($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasReason() => $_has(5);
  @$pb.TagNumber(6)
  void clearReason() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get changedAt => $_getSZ(6);
  @$pb.TagNumber(7)
  set changedAt($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasChangedAt() => $_has(6);
  @$pb.TagNumber(7)
  void clearChangedAt() => $_clearField(7);
}

/// ReconciliationObject represents a payment reconciliation record.
class ReconciliationObject extends $pb.GeneratedMessage {
  factory ReconciliationObject({
    $core.String? id,
    $core.String? loanAccountId,
    $core.String? paymentReference,
    $core.String? externalReference,
    $0.Money? amount,
    ReconciliationStatus? status,
    $core.String? matchedRepaymentId,
    $core.String? notes,
    $core.String? reconciledAt,
    $core.String? reconciledBy,
    $1.Struct? properties,
  }) {
    final result = ReconciliationObject._();
    if (id != null) result.id = id;
    if (loanAccountId != null) result.loanAccountId = loanAccountId;
    if (paymentReference != null) result.paymentReference = paymentReference;
    if (externalReference != null) result.externalReference = externalReference;
    if (amount != null) result.amount = amount;
    if (status != null) result.status = status;
    if (matchedRepaymentId != null)
      result.matchedRepaymentId = matchedRepaymentId;
    if (notes != null) result.notes = notes;
    if (reconciledAt != null) result.reconciledAt = reconciledAt;
    if (reconciledBy != null) result.reconciledBy = reconciledBy;
    if (properties != null) result.properties = properties;
    return result;
  }

  ReconciliationObject._();

  factory ReconciliationObject.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ReconciliationObject()..mergeFromBuffer(data, registry);
  factory ReconciliationObject.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ReconciliationObject()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ReconciliationObject',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: ReconciliationObject.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'loanAccountId')
    ..aOS(3, _omitFieldNames ? '' : 'paymentReference')
    ..aOS(4, _omitFieldNames ? '' : 'externalReference')
    ..aOM<$0.Money>(5, _omitFieldNames ? '' : 'amount',
        subBuilder: $0.Money.$_createMessage)
    ..aE<ReconciliationStatus>(7, _omitFieldNames ? '' : 'status',
        enumValues: ReconciliationStatus.values)
    ..aOS(8, _omitFieldNames ? '' : 'matchedRepaymentId')
    ..aOS(9, _omitFieldNames ? '' : 'notes')
    ..aOS(10, _omitFieldNames ? '' : 'reconciledAt')
    ..aOS(11, _omitFieldNames ? '' : 'reconciledBy')
    ..aOM<$1.Struct>(12, _omitFieldNames ? '' : 'properties',
        subBuilder: $1.Struct.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReconciliationObject clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReconciliationObject copyWith(void Function(ReconciliationObject) updates) =>
      super.copyWith((message) => updates(message as ReconciliationObject))
          as ReconciliationObject;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ReconciliationObject() / ReconciliationObject.new instead')
  static ReconciliationObject create() => ReconciliationObject._();
  static $pb.GeneratedMessage $_createMessage() => ReconciliationObject._();
  @$core.override
  ReconciliationObject createEmptyInstance() => ReconciliationObject._();
  @$core.pragma('dart2js:noInline')
  static ReconciliationObject getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ReconciliationObject>(
          ReconciliationObject.$_createMessage);
  static ReconciliationObject? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get loanAccountId => $_getSZ(1);
  @$pb.TagNumber(2)
  set loanAccountId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLoanAccountId() => $_has(1);
  @$pb.TagNumber(2)
  void clearLoanAccountId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get paymentReference => $_getSZ(2);
  @$pb.TagNumber(3)
  set paymentReference($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPaymentReference() => $_has(2);
  @$pb.TagNumber(3)
  void clearPaymentReference() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get externalReference => $_getSZ(3);
  @$pb.TagNumber(4)
  set externalReference($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasExternalReference() => $_has(3);
  @$pb.TagNumber(4)
  void clearExternalReference() => $_clearField(4);

  @$pb.TagNumber(5)
  $0.Money get amount => $_getN(4);
  @$pb.TagNumber(5)
  set amount($0.Money value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasAmount() => $_has(4);
  @$pb.TagNumber(5)
  void clearAmount() => $_clearField(5);
  @$pb.TagNumber(5)
  $0.Money ensureAmount() => $_ensure(4);

  /// Field 6 removed (currency_code now in Money).
  @$pb.TagNumber(7)
  ReconciliationStatus get status => $_getN(5);
  @$pb.TagNumber(7)
  set status(ReconciliationStatus value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasStatus() => $_has(5);
  @$pb.TagNumber(7)
  void clearStatus() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get matchedRepaymentId => $_getSZ(6);
  @$pb.TagNumber(8)
  set matchedRepaymentId($core.String value) => $_setString(6, value);
  @$pb.TagNumber(8)
  $core.bool hasMatchedRepaymentId() => $_has(6);
  @$pb.TagNumber(8)
  void clearMatchedRepaymentId() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get notes => $_getSZ(7);
  @$pb.TagNumber(9)
  set notes($core.String value) => $_setString(7, value);
  @$pb.TagNumber(9)
  $core.bool hasNotes() => $_has(7);
  @$pb.TagNumber(9)
  void clearNotes() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get reconciledAt => $_getSZ(8);
  @$pb.TagNumber(10)
  set reconciledAt($core.String value) => $_setString(8, value);
  @$pb.TagNumber(10)
  $core.bool hasReconciledAt() => $_has(8);
  @$pb.TagNumber(10)
  void clearReconciledAt() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get reconciledBy => $_getSZ(9);
  @$pb.TagNumber(11)
  set reconciledBy($core.String value) => $_setString(9, value);
  @$pb.TagNumber(11)
  $core.bool hasReconciledBy() => $_has(9);
  @$pb.TagNumber(11)
  void clearReconciledBy() => $_clearField(11);

  @$pb.TagNumber(12)
  $1.Struct get properties => $_getN(10);
  @$pb.TagNumber(12)
  set properties($1.Struct value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasProperties() => $_has(10);
  @$pb.TagNumber(12)
  void clearProperties() => $_clearField(12);
  @$pb.TagNumber(12)
  $1.Struct ensureProperties() => $_ensure(10);
}

/// LoanStatementEntry represents a single line in a loan statement.
class LoanStatementEntry extends $pb.GeneratedMessage {
  factory LoanStatementEntry({
    $core.String? date,
    $core.String? description,
    $0.Money? debit,
    $0.Money? credit,
    $0.Money? balance,
    $core.String? reference,
  }) {
    final result = LoanStatementEntry._();
    if (date != null) result.date = date;
    if (description != null) result.description = description;
    if (debit != null) result.debit = debit;
    if (credit != null) result.credit = credit;
    if (balance != null) result.balance = balance;
    if (reference != null) result.reference = reference;
    return result;
  }

  LoanStatementEntry._();

  factory LoanStatementEntry.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanStatementEntry()..mergeFromBuffer(data, registry);
  factory LoanStatementEntry.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanStatementEntry()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LoanStatementEntry',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: LoanStatementEntry.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'date')
    ..aOS(2, _omitFieldNames ? '' : 'description')
    ..aOM<$0.Money>(3, _omitFieldNames ? '' : 'debit',
        subBuilder: $0.Money.$_createMessage)
    ..aOM<$0.Money>(4, _omitFieldNames ? '' : 'credit',
        subBuilder: $0.Money.$_createMessage)
    ..aOM<$0.Money>(5, _omitFieldNames ? '' : 'balance',
        subBuilder: $0.Money.$_createMessage)
    ..aOS(6, _omitFieldNames ? '' : 'reference')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanStatementEntry clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanStatementEntry copyWith(void Function(LoanStatementEntry) updates) =>
      super.copyWith((message) => updates(message as LoanStatementEntry))
          as LoanStatementEntry;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use LoanStatementEntry() / LoanStatementEntry.new instead')
  static LoanStatementEntry create() => LoanStatementEntry._();
  static $pb.GeneratedMessage $_createMessage() => LoanStatementEntry._();
  @$core.override
  LoanStatementEntry createEmptyInstance() => LoanStatementEntry._();
  @$core.pragma('dart2js:noInline')
  static LoanStatementEntry getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LoanStatementEntry>(
          LoanStatementEntry.$_createMessage);
  static LoanStatementEntry? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get date => $_getSZ(0);
  @$pb.TagNumber(1)
  set date($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDate() => $_has(0);
  @$pb.TagNumber(1)
  void clearDate() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get description => $_getSZ(1);
  @$pb.TagNumber(2)
  set description($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDescription() => $_has(1);
  @$pb.TagNumber(2)
  void clearDescription() => $_clearField(2);

  @$pb.TagNumber(3)
  $0.Money get debit => $_getN(2);
  @$pb.TagNumber(3)
  set debit($0.Money value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasDebit() => $_has(2);
  @$pb.TagNumber(3)
  void clearDebit() => $_clearField(3);
  @$pb.TagNumber(3)
  $0.Money ensureDebit() => $_ensure(2);

  @$pb.TagNumber(4)
  $0.Money get credit => $_getN(3);
  @$pb.TagNumber(4)
  set credit($0.Money value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasCredit() => $_has(3);
  @$pb.TagNumber(4)
  void clearCredit() => $_clearField(4);
  @$pb.TagNumber(4)
  $0.Money ensureCredit() => $_ensure(3);

  @$pb.TagNumber(5)
  $0.Money get balance => $_getN(4);
  @$pb.TagNumber(5)
  set balance($0.Money value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasBalance() => $_has(4);
  @$pb.TagNumber(5)
  void clearBalance() => $_clearField(5);
  @$pb.TagNumber(5)
  $0.Money ensureBalance() => $_ensure(4);

  @$pb.TagNumber(6)
  $core.String get reference => $_getSZ(5);
  @$pb.TagNumber(6)
  set reference($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasReference() => $_has(5);
  @$pb.TagNumber(6)
  void clearReference() => $_clearField(6);
}

class LoanAccountCreateRequest extends $pb.GeneratedMessage {
  factory LoanAccountCreateRequest({
    $core.String? loanRequestId,
  }) {
    final result = LoanAccountCreateRequest._();
    if (loanRequestId != null) result.loanRequestId = loanRequestId;
    return result;
  }

  LoanAccountCreateRequest._();

  factory LoanAccountCreateRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanAccountCreateRequest()..mergeFromBuffer(data, registry);
  factory LoanAccountCreateRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanAccountCreateRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LoanAccountCreateRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: LoanAccountCreateRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'loanRequestId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanAccountCreateRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanAccountCreateRequest copyWith(
          void Function(LoanAccountCreateRequest) updates) =>
      super.copyWith((message) => updates(message as LoanAccountCreateRequest))
          as LoanAccountCreateRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use LoanAccountCreateRequest() / LoanAccountCreateRequest.new instead')
  static LoanAccountCreateRequest create() => LoanAccountCreateRequest._();
  static $pb.GeneratedMessage $_createMessage() => LoanAccountCreateRequest._();
  @$core.override
  LoanAccountCreateRequest createEmptyInstance() =>
      LoanAccountCreateRequest._();
  @$core.pragma('dart2js:noInline')
  static LoanAccountCreateRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LoanAccountCreateRequest>(
          LoanAccountCreateRequest.$_createMessage);
  static LoanAccountCreateRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get loanRequestId => $_getSZ(0);
  @$pb.TagNumber(1)
  set loanRequestId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLoanRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearLoanRequestId() => $_clearField(1);
}

class LoanAccountCreateResponse extends $pb.GeneratedMessage {
  factory LoanAccountCreateResponse({
    LoanAccountObject? data,
  }) {
    final result = LoanAccountCreateResponse._();
    if (data != null) result.data = data;
    return result;
  }

  LoanAccountCreateResponse._();

  factory LoanAccountCreateResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanAccountCreateResponse()..mergeFromBuffer(data, registry);
  factory LoanAccountCreateResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanAccountCreateResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LoanAccountCreateResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: LoanAccountCreateResponse.$_createMessage)
    ..aOM<LoanAccountObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: LoanAccountObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanAccountCreateResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanAccountCreateResponse copyWith(
          void Function(LoanAccountCreateResponse) updates) =>
      super.copyWith((message) => updates(message as LoanAccountCreateResponse))
          as LoanAccountCreateResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use LoanAccountCreateResponse() / LoanAccountCreateResponse.new instead')
  static LoanAccountCreateResponse create() => LoanAccountCreateResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      LoanAccountCreateResponse._();
  @$core.override
  LoanAccountCreateResponse createEmptyInstance() =>
      LoanAccountCreateResponse._();
  @$core.pragma('dart2js:noInline')
  static LoanAccountCreateResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LoanAccountCreateResponse>(
          LoanAccountCreateResponse.$_createMessage);
  static LoanAccountCreateResponse? _defaultInstance;

  @$pb.TagNumber(1)
  LoanAccountObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(LoanAccountObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  LoanAccountObject ensureData() => $_ensure(0);
}

/// LoanAccountCancelRequest cancels a loan that was opened but never
/// disbursed.
class LoanAccountCancelRequest extends $pb.GeneratedMessage {
  factory LoanAccountCancelRequest({
    $core.String? id,
    $core.String? reason,
  }) {
    final result = LoanAccountCancelRequest._();
    if (id != null) result.id = id;
    if (reason != null) result.reason = reason;
    return result;
  }

  LoanAccountCancelRequest._();

  factory LoanAccountCancelRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanAccountCancelRequest()..mergeFromBuffer(data, registry);
  factory LoanAccountCancelRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanAccountCancelRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LoanAccountCancelRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: LoanAccountCancelRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'reason')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanAccountCancelRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanAccountCancelRequest copyWith(
          void Function(LoanAccountCancelRequest) updates) =>
      super.copyWith((message) => updates(message as LoanAccountCancelRequest))
          as LoanAccountCancelRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use LoanAccountCancelRequest() / LoanAccountCancelRequest.new instead')
  static LoanAccountCancelRequest create() => LoanAccountCancelRequest._();
  static $pb.GeneratedMessage $_createMessage() => LoanAccountCancelRequest._();
  @$core.override
  LoanAccountCancelRequest createEmptyInstance() =>
      LoanAccountCancelRequest._();
  @$core.pragma('dart2js:noInline')
  static LoanAccountCancelRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LoanAccountCancelRequest>(
          LoanAccountCancelRequest.$_createMessage);
  static LoanAccountCancelRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get reason => $_getSZ(1);
  @$pb.TagNumber(2)
  set reason($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasReason() => $_has(1);
  @$pb.TagNumber(2)
  void clearReason() => $_clearField(2);
}

class LoanAccountCancelResponse extends $pb.GeneratedMessage {
  factory LoanAccountCancelResponse({
    LoanAccountObject? data,
  }) {
    final result = LoanAccountCancelResponse._();
    if (data != null) result.data = data;
    return result;
  }

  LoanAccountCancelResponse._();

  factory LoanAccountCancelResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanAccountCancelResponse()..mergeFromBuffer(data, registry);
  factory LoanAccountCancelResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanAccountCancelResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LoanAccountCancelResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: LoanAccountCancelResponse.$_createMessage)
    ..aOM<LoanAccountObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: LoanAccountObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanAccountCancelResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanAccountCancelResponse copyWith(
          void Function(LoanAccountCancelResponse) updates) =>
      super.copyWith((message) => updates(message as LoanAccountCancelResponse))
          as LoanAccountCancelResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use LoanAccountCancelResponse() / LoanAccountCancelResponse.new instead')
  static LoanAccountCancelResponse create() => LoanAccountCancelResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      LoanAccountCancelResponse._();
  @$core.override
  LoanAccountCancelResponse createEmptyInstance() =>
      LoanAccountCancelResponse._();
  @$core.pragma('dart2js:noInline')
  static LoanAccountCancelResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LoanAccountCancelResponse>(
          LoanAccountCancelResponse.$_createMessage);
  static LoanAccountCancelResponse? _defaultInstance;

  @$pb.TagNumber(1)
  LoanAccountObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(LoanAccountObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  LoanAccountObject ensureData() => $_ensure(0);
}

class LoanAccountGetRequest extends $pb.GeneratedMessage {
  factory LoanAccountGetRequest({
    $core.String? id,
  }) {
    final result = LoanAccountGetRequest._();
    if (id != null) result.id = id;
    return result;
  }

  LoanAccountGetRequest._();

  factory LoanAccountGetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanAccountGetRequest()..mergeFromBuffer(data, registry);
  factory LoanAccountGetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanAccountGetRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LoanAccountGetRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: LoanAccountGetRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanAccountGetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanAccountGetRequest copyWith(
          void Function(LoanAccountGetRequest) updates) =>
      super.copyWith((message) => updates(message as LoanAccountGetRequest))
          as LoanAccountGetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use LoanAccountGetRequest() / LoanAccountGetRequest.new instead')
  static LoanAccountGetRequest create() => LoanAccountGetRequest._();
  static $pb.GeneratedMessage $_createMessage() => LoanAccountGetRequest._();
  @$core.override
  LoanAccountGetRequest createEmptyInstance() => LoanAccountGetRequest._();
  @$core.pragma('dart2js:noInline')
  static LoanAccountGetRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LoanAccountGetRequest>(
          LoanAccountGetRequest.$_createMessage);
  static LoanAccountGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class LoanAccountGetResponse extends $pb.GeneratedMessage {
  factory LoanAccountGetResponse({
    LoanAccountObject? data,
  }) {
    final result = LoanAccountGetResponse._();
    if (data != null) result.data = data;
    return result;
  }

  LoanAccountGetResponse._();

  factory LoanAccountGetResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanAccountGetResponse()..mergeFromBuffer(data, registry);
  factory LoanAccountGetResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanAccountGetResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LoanAccountGetResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: LoanAccountGetResponse.$_createMessage)
    ..aOM<LoanAccountObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: LoanAccountObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanAccountGetResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanAccountGetResponse copyWith(
          void Function(LoanAccountGetResponse) updates) =>
      super.copyWith((message) => updates(message as LoanAccountGetResponse))
          as LoanAccountGetResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use LoanAccountGetResponse() / LoanAccountGetResponse.new instead')
  static LoanAccountGetResponse create() => LoanAccountGetResponse._();
  static $pb.GeneratedMessage $_createMessage() => LoanAccountGetResponse._();
  @$core.override
  LoanAccountGetResponse createEmptyInstance() => LoanAccountGetResponse._();
  @$core.pragma('dart2js:noInline')
  static LoanAccountGetResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LoanAccountGetResponse>(
          LoanAccountGetResponse.$_createMessage);
  static LoanAccountGetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  LoanAccountObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(LoanAccountObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  LoanAccountObject ensureData() => $_ensure(0);
}

class LoanAccountSearchRequest extends $pb.GeneratedMessage {
  factory LoanAccountSearchRequest({
    $core.String? query,
    $core.String? clientId,
    $core.String? agentId,
    $core.String? branchId,
    $core.String? organizationId,
    LoanStatus? status,
    $2.PageCursor? cursor,
  }) {
    final result = LoanAccountSearchRequest._();
    if (query != null) result.query = query;
    if (clientId != null) result.clientId = clientId;
    if (agentId != null) result.agentId = agentId;
    if (branchId != null) result.branchId = branchId;
    if (organizationId != null) result.organizationId = organizationId;
    if (status != null) result.status = status;
    if (cursor != null) result.cursor = cursor;
    return result;
  }

  LoanAccountSearchRequest._();

  factory LoanAccountSearchRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanAccountSearchRequest()..mergeFromBuffer(data, registry);
  factory LoanAccountSearchRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanAccountSearchRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LoanAccountSearchRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: LoanAccountSearchRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'query')
    ..aOS(2, _omitFieldNames ? '' : 'clientId')
    ..aOS(3, _omitFieldNames ? '' : 'agentId')
    ..aOS(4, _omitFieldNames ? '' : 'branchId')
    ..aOS(5, _omitFieldNames ? '' : 'organizationId')
    ..aE<LoanStatus>(6, _omitFieldNames ? '' : 'status',
        enumValues: LoanStatus.values)
    ..aOM<$2.PageCursor>(7, _omitFieldNames ? '' : 'cursor',
        subBuilder: $2.PageCursor.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanAccountSearchRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanAccountSearchRequest copyWith(
          void Function(LoanAccountSearchRequest) updates) =>
      super.copyWith((message) => updates(message as LoanAccountSearchRequest))
          as LoanAccountSearchRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use LoanAccountSearchRequest() / LoanAccountSearchRequest.new instead')
  static LoanAccountSearchRequest create() => LoanAccountSearchRequest._();
  static $pb.GeneratedMessage $_createMessage() => LoanAccountSearchRequest._();
  @$core.override
  LoanAccountSearchRequest createEmptyInstance() =>
      LoanAccountSearchRequest._();
  @$core.pragma('dart2js:noInline')
  static LoanAccountSearchRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LoanAccountSearchRequest>(
          LoanAccountSearchRequest.$_createMessage);
  static LoanAccountSearchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get query => $_getSZ(0);
  @$pb.TagNumber(1)
  set query($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasQuery() => $_has(0);
  @$pb.TagNumber(1)
  void clearQuery() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get clientId => $_getSZ(1);
  @$pb.TagNumber(2)
  set clientId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasClientId() => $_has(1);
  @$pb.TagNumber(2)
  void clearClientId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get agentId => $_getSZ(2);
  @$pb.TagNumber(3)
  set agentId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAgentId() => $_has(2);
  @$pb.TagNumber(3)
  void clearAgentId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get branchId => $_getSZ(3);
  @$pb.TagNumber(4)
  set branchId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasBranchId() => $_has(3);
  @$pb.TagNumber(4)
  void clearBranchId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get organizationId => $_getSZ(4);
  @$pb.TagNumber(5)
  set organizationId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasOrganizationId() => $_has(4);
  @$pb.TagNumber(5)
  void clearOrganizationId() => $_clearField(5);

  @$pb.TagNumber(6)
  LoanStatus get status => $_getN(5);
  @$pb.TagNumber(6)
  set status(LoanStatus value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasStatus() => $_has(5);
  @$pb.TagNumber(6)
  void clearStatus() => $_clearField(6);

  @$pb.TagNumber(7)
  $2.PageCursor get cursor => $_getN(6);
  @$pb.TagNumber(7)
  set cursor($2.PageCursor value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasCursor() => $_has(6);
  @$pb.TagNumber(7)
  void clearCursor() => $_clearField(7);
  @$pb.TagNumber(7)
  $2.PageCursor ensureCursor() => $_ensure(6);
}

class LoanAccountSearchResponse extends $pb.GeneratedMessage {
  factory LoanAccountSearchResponse({
    $core.Iterable<LoanAccountObject>? data,
  }) {
    final result = LoanAccountSearchResponse._();
    if (data != null) result.data.addAll(data);
    return result;
  }

  LoanAccountSearchResponse._();

  factory LoanAccountSearchResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanAccountSearchResponse()..mergeFromBuffer(data, registry);
  factory LoanAccountSearchResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanAccountSearchResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LoanAccountSearchResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: LoanAccountSearchResponse.$_createMessage)
    ..pPM<LoanAccountObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: LoanAccountObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanAccountSearchResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanAccountSearchResponse copyWith(
          void Function(LoanAccountSearchResponse) updates) =>
      super.copyWith((message) => updates(message as LoanAccountSearchResponse))
          as LoanAccountSearchResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use LoanAccountSearchResponse() / LoanAccountSearchResponse.new instead')
  static LoanAccountSearchResponse create() => LoanAccountSearchResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      LoanAccountSearchResponse._();
  @$core.override
  LoanAccountSearchResponse createEmptyInstance() =>
      LoanAccountSearchResponse._();
  @$core.pragma('dart2js:noInline')
  static LoanAccountSearchResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LoanAccountSearchResponse>(
          LoanAccountSearchResponse.$_createMessage);
  static LoanAccountSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<LoanAccountObject> get data => $_getList(0);
}

class LoanBalanceGetRequest extends $pb.GeneratedMessage {
  factory LoanBalanceGetRequest({
    $core.String? loanAccountId,
  }) {
    final result = LoanBalanceGetRequest._();
    if (loanAccountId != null) result.loanAccountId = loanAccountId;
    return result;
  }

  LoanBalanceGetRequest._();

  factory LoanBalanceGetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanBalanceGetRequest()..mergeFromBuffer(data, registry);
  factory LoanBalanceGetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanBalanceGetRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LoanBalanceGetRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: LoanBalanceGetRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'loanAccountId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanBalanceGetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanBalanceGetRequest copyWith(
          void Function(LoanBalanceGetRequest) updates) =>
      super.copyWith((message) => updates(message as LoanBalanceGetRequest))
          as LoanBalanceGetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use LoanBalanceGetRequest() / LoanBalanceGetRequest.new instead')
  static LoanBalanceGetRequest create() => LoanBalanceGetRequest._();
  static $pb.GeneratedMessage $_createMessage() => LoanBalanceGetRequest._();
  @$core.override
  LoanBalanceGetRequest createEmptyInstance() => LoanBalanceGetRequest._();
  @$core.pragma('dart2js:noInline')
  static LoanBalanceGetRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LoanBalanceGetRequest>(
          LoanBalanceGetRequest.$_createMessage);
  static LoanBalanceGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get loanAccountId => $_getSZ(0);
  @$pb.TagNumber(1)
  set loanAccountId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLoanAccountId() => $_has(0);
  @$pb.TagNumber(1)
  void clearLoanAccountId() => $_clearField(1);
}

class LoanBalanceGetResponse extends $pb.GeneratedMessage {
  factory LoanBalanceGetResponse({
    LoanBalanceObject? data,
  }) {
    final result = LoanBalanceGetResponse._();
    if (data != null) result.data = data;
    return result;
  }

  LoanBalanceGetResponse._();

  factory LoanBalanceGetResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanBalanceGetResponse()..mergeFromBuffer(data, registry);
  factory LoanBalanceGetResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanBalanceGetResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LoanBalanceGetResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: LoanBalanceGetResponse.$_createMessage)
    ..aOM<LoanBalanceObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: LoanBalanceObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanBalanceGetResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanBalanceGetResponse copyWith(
          void Function(LoanBalanceGetResponse) updates) =>
      super.copyWith((message) => updates(message as LoanBalanceGetResponse))
          as LoanBalanceGetResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use LoanBalanceGetResponse() / LoanBalanceGetResponse.new instead')
  static LoanBalanceGetResponse create() => LoanBalanceGetResponse._();
  static $pb.GeneratedMessage $_createMessage() => LoanBalanceGetResponse._();
  @$core.override
  LoanBalanceGetResponse createEmptyInstance() => LoanBalanceGetResponse._();
  @$core.pragma('dart2js:noInline')
  static LoanBalanceGetResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LoanBalanceGetResponse>(
          LoanBalanceGetResponse.$_createMessage);
  static LoanBalanceGetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  LoanBalanceObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(LoanBalanceObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  LoanBalanceObject ensureData() => $_ensure(0);
}

class DisbursementCreateRequest extends $pb.GeneratedMessage {
  factory DisbursementCreateRequest({
    $core.String? loanAccountId,
    $core.String? channel,
    $core.String? recipientReference,
    $core.String? idempotencyKey,
  }) {
    final result = DisbursementCreateRequest._();
    if (loanAccountId != null) result.loanAccountId = loanAccountId;
    if (channel != null) result.channel = channel;
    if (recipientReference != null)
      result.recipientReference = recipientReference;
    if (idempotencyKey != null) result.idempotencyKey = idempotencyKey;
    return result;
  }

  DisbursementCreateRequest._();

  factory DisbursementCreateRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DisbursementCreateRequest()..mergeFromBuffer(data, registry);
  factory DisbursementCreateRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DisbursementCreateRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DisbursementCreateRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: DisbursementCreateRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'loanAccountId')
    ..aOS(2, _omitFieldNames ? '' : 'channel')
    ..aOS(3, _omitFieldNames ? '' : 'recipientReference')
    ..aOS(4, _omitFieldNames ? '' : 'idempotencyKey')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DisbursementCreateRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DisbursementCreateRequest copyWith(
          void Function(DisbursementCreateRequest) updates) =>
      super.copyWith((message) => updates(message as DisbursementCreateRequest))
          as DisbursementCreateRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use DisbursementCreateRequest() / DisbursementCreateRequest.new instead')
  static DisbursementCreateRequest create() => DisbursementCreateRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      DisbursementCreateRequest._();
  @$core.override
  DisbursementCreateRequest createEmptyInstance() =>
      DisbursementCreateRequest._();
  @$core.pragma('dart2js:noInline')
  static DisbursementCreateRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DisbursementCreateRequest>(
          DisbursementCreateRequest.$_createMessage);
  static DisbursementCreateRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get loanAccountId => $_getSZ(0);
  @$pb.TagNumber(1)
  set loanAccountId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLoanAccountId() => $_has(0);
  @$pb.TagNumber(1)
  void clearLoanAccountId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get channel => $_getSZ(1);
  @$pb.TagNumber(2)
  set channel($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasChannel() => $_has(1);
  @$pb.TagNumber(2)
  void clearChannel() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get recipientReference => $_getSZ(2);
  @$pb.TagNumber(3)
  set recipientReference($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRecipientReference() => $_has(2);
  @$pb.TagNumber(3)
  void clearRecipientReference() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get idempotencyKey => $_getSZ(3);
  @$pb.TagNumber(4)
  set idempotencyKey($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasIdempotencyKey() => $_has(3);
  @$pb.TagNumber(4)
  void clearIdempotencyKey() => $_clearField(4);
}

class DisbursementCreateResponse extends $pb.GeneratedMessage {
  factory DisbursementCreateResponse({
    DisbursementObject? data,
  }) {
    final result = DisbursementCreateResponse._();
    if (data != null) result.data = data;
    return result;
  }

  DisbursementCreateResponse._();

  factory DisbursementCreateResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DisbursementCreateResponse()..mergeFromBuffer(data, registry);
  factory DisbursementCreateResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DisbursementCreateResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DisbursementCreateResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: DisbursementCreateResponse.$_createMessage)
    ..aOM<DisbursementObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: DisbursementObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DisbursementCreateResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DisbursementCreateResponse copyWith(
          void Function(DisbursementCreateResponse) updates) =>
      super.copyWith(
              (message) => updates(message as DisbursementCreateResponse))
          as DisbursementCreateResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use DisbursementCreateResponse() / DisbursementCreateResponse.new instead')
  static DisbursementCreateResponse create() => DisbursementCreateResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      DisbursementCreateResponse._();
  @$core.override
  DisbursementCreateResponse createEmptyInstance() =>
      DisbursementCreateResponse._();
  @$core.pragma('dart2js:noInline')
  static DisbursementCreateResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DisbursementCreateResponse>(
          DisbursementCreateResponse.$_createMessage);
  static DisbursementCreateResponse? _defaultInstance;

  @$pb.TagNumber(1)
  DisbursementObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(DisbursementObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  DisbursementObject ensureData() => $_ensure(0);
}

class DisbursementGetRequest extends $pb.GeneratedMessage {
  factory DisbursementGetRequest({
    $core.String? id,
  }) {
    final result = DisbursementGetRequest._();
    if (id != null) result.id = id;
    return result;
  }

  DisbursementGetRequest._();

  factory DisbursementGetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DisbursementGetRequest()..mergeFromBuffer(data, registry);
  factory DisbursementGetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DisbursementGetRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DisbursementGetRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: DisbursementGetRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DisbursementGetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DisbursementGetRequest copyWith(
          void Function(DisbursementGetRequest) updates) =>
      super.copyWith((message) => updates(message as DisbursementGetRequest))
          as DisbursementGetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use DisbursementGetRequest() / DisbursementGetRequest.new instead')
  static DisbursementGetRequest create() => DisbursementGetRequest._();
  static $pb.GeneratedMessage $_createMessage() => DisbursementGetRequest._();
  @$core.override
  DisbursementGetRequest createEmptyInstance() => DisbursementGetRequest._();
  @$core.pragma('dart2js:noInline')
  static DisbursementGetRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DisbursementGetRequest>(
          DisbursementGetRequest.$_createMessage);
  static DisbursementGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class DisbursementGetResponse extends $pb.GeneratedMessage {
  factory DisbursementGetResponse({
    DisbursementObject? data,
  }) {
    final result = DisbursementGetResponse._();
    if (data != null) result.data = data;
    return result;
  }

  DisbursementGetResponse._();

  factory DisbursementGetResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DisbursementGetResponse()..mergeFromBuffer(data, registry);
  factory DisbursementGetResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DisbursementGetResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DisbursementGetResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: DisbursementGetResponse.$_createMessage)
    ..aOM<DisbursementObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: DisbursementObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DisbursementGetResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DisbursementGetResponse copyWith(
          void Function(DisbursementGetResponse) updates) =>
      super.copyWith((message) => updates(message as DisbursementGetResponse))
          as DisbursementGetResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use DisbursementGetResponse() / DisbursementGetResponse.new instead')
  static DisbursementGetResponse create() => DisbursementGetResponse._();
  static $pb.GeneratedMessage $_createMessage() => DisbursementGetResponse._();
  @$core.override
  DisbursementGetResponse createEmptyInstance() => DisbursementGetResponse._();
  @$core.pragma('dart2js:noInline')
  static DisbursementGetResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DisbursementGetResponse>(
          DisbursementGetResponse.$_createMessage);
  static DisbursementGetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  DisbursementObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(DisbursementObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  DisbursementObject ensureData() => $_ensure(0);
}

class DisbursementSearchRequest extends $pb.GeneratedMessage {
  factory DisbursementSearchRequest({
    $core.String? loanAccountId,
    DisbursementStatus? status,
    $2.PageCursor? cursor,
  }) {
    final result = DisbursementSearchRequest._();
    if (loanAccountId != null) result.loanAccountId = loanAccountId;
    if (status != null) result.status = status;
    if (cursor != null) result.cursor = cursor;
    return result;
  }

  DisbursementSearchRequest._();

  factory DisbursementSearchRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DisbursementSearchRequest()..mergeFromBuffer(data, registry);
  factory DisbursementSearchRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DisbursementSearchRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DisbursementSearchRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: DisbursementSearchRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'loanAccountId')
    ..aE<DisbursementStatus>(2, _omitFieldNames ? '' : 'status',
        enumValues: DisbursementStatus.values)
    ..aOM<$2.PageCursor>(3, _omitFieldNames ? '' : 'cursor',
        subBuilder: $2.PageCursor.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DisbursementSearchRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DisbursementSearchRequest copyWith(
          void Function(DisbursementSearchRequest) updates) =>
      super.copyWith((message) => updates(message as DisbursementSearchRequest))
          as DisbursementSearchRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use DisbursementSearchRequest() / DisbursementSearchRequest.new instead')
  static DisbursementSearchRequest create() => DisbursementSearchRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      DisbursementSearchRequest._();
  @$core.override
  DisbursementSearchRequest createEmptyInstance() =>
      DisbursementSearchRequest._();
  @$core.pragma('dart2js:noInline')
  static DisbursementSearchRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DisbursementSearchRequest>(
          DisbursementSearchRequest.$_createMessage);
  static DisbursementSearchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get loanAccountId => $_getSZ(0);
  @$pb.TagNumber(1)
  set loanAccountId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLoanAccountId() => $_has(0);
  @$pb.TagNumber(1)
  void clearLoanAccountId() => $_clearField(1);

  @$pb.TagNumber(2)
  DisbursementStatus get status => $_getN(1);
  @$pb.TagNumber(2)
  set status(DisbursementStatus value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasStatus() => $_has(1);
  @$pb.TagNumber(2)
  void clearStatus() => $_clearField(2);

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
}

class DisbursementSearchResponse extends $pb.GeneratedMessage {
  factory DisbursementSearchResponse({
    $core.Iterable<DisbursementObject>? data,
  }) {
    final result = DisbursementSearchResponse._();
    if (data != null) result.data.addAll(data);
    return result;
  }

  DisbursementSearchResponse._();

  factory DisbursementSearchResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DisbursementSearchResponse()..mergeFromBuffer(data, registry);
  factory DisbursementSearchResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DisbursementSearchResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DisbursementSearchResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: DisbursementSearchResponse.$_createMessage)
    ..pPM<DisbursementObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: DisbursementObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DisbursementSearchResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DisbursementSearchResponse copyWith(
          void Function(DisbursementSearchResponse) updates) =>
      super.copyWith(
              (message) => updates(message as DisbursementSearchResponse))
          as DisbursementSearchResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use DisbursementSearchResponse() / DisbursementSearchResponse.new instead')
  static DisbursementSearchResponse create() => DisbursementSearchResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      DisbursementSearchResponse._();
  @$core.override
  DisbursementSearchResponse createEmptyInstance() =>
      DisbursementSearchResponse._();
  @$core.pragma('dart2js:noInline')
  static DisbursementSearchResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DisbursementSearchResponse>(
          DisbursementSearchResponse.$_createMessage);
  static DisbursementSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<DisbursementObject> get data => $_getList(0);
}

class RepaymentRecordRequest extends $pb.GeneratedMessage {
  factory RepaymentRecordRequest({
    $core.String? loanAccountId,
    $0.Money? amount,
    $core.String? paymentReference,
    $core.String? channel,
    $core.String? payerReference,
    $core.String? receivedAt,
    $core.String? idempotencyKey,
  }) {
    final result = RepaymentRecordRequest._();
    if (loanAccountId != null) result.loanAccountId = loanAccountId;
    if (amount != null) result.amount = amount;
    if (paymentReference != null) result.paymentReference = paymentReference;
    if (channel != null) result.channel = channel;
    if (payerReference != null) result.payerReference = payerReference;
    if (receivedAt != null) result.receivedAt = receivedAt;
    if (idempotencyKey != null) result.idempotencyKey = idempotencyKey;
    return result;
  }

  RepaymentRecordRequest._();

  factory RepaymentRecordRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RepaymentRecordRequest()..mergeFromBuffer(data, registry);
  factory RepaymentRecordRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RepaymentRecordRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RepaymentRecordRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: RepaymentRecordRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'loanAccountId')
    ..aOM<$0.Money>(2, _omitFieldNames ? '' : 'amount',
        subBuilder: $0.Money.$_createMessage)
    ..aOS(3, _omitFieldNames ? '' : 'paymentReference')
    ..aOS(4, _omitFieldNames ? '' : 'channel')
    ..aOS(5, _omitFieldNames ? '' : 'payerReference')
    ..aOS(6, _omitFieldNames ? '' : 'receivedAt')
    ..aOS(7, _omitFieldNames ? '' : 'idempotencyKey')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RepaymentRecordRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RepaymentRecordRequest copyWith(
          void Function(RepaymentRecordRequest) updates) =>
      super.copyWith((message) => updates(message as RepaymentRecordRequest))
          as RepaymentRecordRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use RepaymentRecordRequest() / RepaymentRecordRequest.new instead')
  static RepaymentRecordRequest create() => RepaymentRecordRequest._();
  static $pb.GeneratedMessage $_createMessage() => RepaymentRecordRequest._();
  @$core.override
  RepaymentRecordRequest createEmptyInstance() => RepaymentRecordRequest._();
  @$core.pragma('dart2js:noInline')
  static RepaymentRecordRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RepaymentRecordRequest>(
          RepaymentRecordRequest.$_createMessage);
  static RepaymentRecordRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get loanAccountId => $_getSZ(0);
  @$pb.TagNumber(1)
  set loanAccountId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLoanAccountId() => $_has(0);
  @$pb.TagNumber(1)
  void clearLoanAccountId() => $_clearField(1);

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
  $core.String get paymentReference => $_getSZ(2);
  @$pb.TagNumber(3)
  set paymentReference($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPaymentReference() => $_has(2);
  @$pb.TagNumber(3)
  void clearPaymentReference() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get channel => $_getSZ(3);
  @$pb.TagNumber(4)
  set channel($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasChannel() => $_has(3);
  @$pb.TagNumber(4)
  void clearChannel() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get payerReference => $_getSZ(4);
  @$pb.TagNumber(5)
  set payerReference($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasPayerReference() => $_has(4);
  @$pb.TagNumber(5)
  void clearPayerReference() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get receivedAt => $_getSZ(5);
  @$pb.TagNumber(6)
  set receivedAt($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasReceivedAt() => $_has(5);
  @$pb.TagNumber(6)
  void clearReceivedAt() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get idempotencyKey => $_getSZ(6);
  @$pb.TagNumber(7)
  set idempotencyKey($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasIdempotencyKey() => $_has(6);
  @$pb.TagNumber(7)
  void clearIdempotencyKey() => $_clearField(7);
}

class RepaymentRecordResponse extends $pb.GeneratedMessage {
  factory RepaymentRecordResponse({
    RepaymentObject? data,
  }) {
    final result = RepaymentRecordResponse._();
    if (data != null) result.data = data;
    return result;
  }

  RepaymentRecordResponse._();

  factory RepaymentRecordResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RepaymentRecordResponse()..mergeFromBuffer(data, registry);
  factory RepaymentRecordResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RepaymentRecordResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RepaymentRecordResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: RepaymentRecordResponse.$_createMessage)
    ..aOM<RepaymentObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: RepaymentObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RepaymentRecordResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RepaymentRecordResponse copyWith(
          void Function(RepaymentRecordResponse) updates) =>
      super.copyWith((message) => updates(message as RepaymentRecordResponse))
          as RepaymentRecordResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use RepaymentRecordResponse() / RepaymentRecordResponse.new instead')
  static RepaymentRecordResponse create() => RepaymentRecordResponse._();
  static $pb.GeneratedMessage $_createMessage() => RepaymentRecordResponse._();
  @$core.override
  RepaymentRecordResponse createEmptyInstance() => RepaymentRecordResponse._();
  @$core.pragma('dart2js:noInline')
  static RepaymentRecordResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RepaymentRecordResponse>(
          RepaymentRecordResponse.$_createMessage);
  static RepaymentRecordResponse? _defaultInstance;

  @$pb.TagNumber(1)
  RepaymentObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(RepaymentObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  RepaymentObject ensureData() => $_ensure(0);
}

class RepaymentGetRequest extends $pb.GeneratedMessage {
  factory RepaymentGetRequest({
    $core.String? id,
  }) {
    final result = RepaymentGetRequest._();
    if (id != null) result.id = id;
    return result;
  }

  RepaymentGetRequest._();

  factory RepaymentGetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RepaymentGetRequest()..mergeFromBuffer(data, registry);
  factory RepaymentGetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RepaymentGetRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RepaymentGetRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: RepaymentGetRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RepaymentGetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RepaymentGetRequest copyWith(void Function(RepaymentGetRequest) updates) =>
      super.copyWith((message) => updates(message as RepaymentGetRequest))
          as RepaymentGetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core
      .Deprecated('Use RepaymentGetRequest() / RepaymentGetRequest.new instead')
  static RepaymentGetRequest create() => RepaymentGetRequest._();
  static $pb.GeneratedMessage $_createMessage() => RepaymentGetRequest._();
  @$core.override
  RepaymentGetRequest createEmptyInstance() => RepaymentGetRequest._();
  @$core.pragma('dart2js:noInline')
  static RepaymentGetRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RepaymentGetRequest>(
          RepaymentGetRequest.$_createMessage);
  static RepaymentGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class RepaymentGetResponse extends $pb.GeneratedMessage {
  factory RepaymentGetResponse({
    RepaymentObject? data,
  }) {
    final result = RepaymentGetResponse._();
    if (data != null) result.data = data;
    return result;
  }

  RepaymentGetResponse._();

  factory RepaymentGetResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RepaymentGetResponse()..mergeFromBuffer(data, registry);
  factory RepaymentGetResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RepaymentGetResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RepaymentGetResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: RepaymentGetResponse.$_createMessage)
    ..aOM<RepaymentObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: RepaymentObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RepaymentGetResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RepaymentGetResponse copyWith(void Function(RepaymentGetResponse) updates) =>
      super.copyWith((message) => updates(message as RepaymentGetResponse))
          as RepaymentGetResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use RepaymentGetResponse() / RepaymentGetResponse.new instead')
  static RepaymentGetResponse create() => RepaymentGetResponse._();
  static $pb.GeneratedMessage $_createMessage() => RepaymentGetResponse._();
  @$core.override
  RepaymentGetResponse createEmptyInstance() => RepaymentGetResponse._();
  @$core.pragma('dart2js:noInline')
  static RepaymentGetResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RepaymentGetResponse>(
          RepaymentGetResponse.$_createMessage);
  static RepaymentGetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  RepaymentObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(RepaymentObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  RepaymentObject ensureData() => $_ensure(0);
}

class RepaymentSearchRequest extends $pb.GeneratedMessage {
  factory RepaymentSearchRequest({
    $core.String? loanAccountId,
    RepaymentStatus? status,
    $2.PageCursor? cursor,
    @$core.Deprecated('This field is deprecated.') $core.String? collectedBy,
    $core.String? receivedAfter,
    $core.String? receivedBefore,
  }) {
    final result = RepaymentSearchRequest._();
    if (loanAccountId != null) result.loanAccountId = loanAccountId;
    if (status != null) result.status = status;
    if (cursor != null) result.cursor = cursor;
    if (collectedBy != null) result.collectedBy = collectedBy;
    if (receivedAfter != null) result.receivedAfter = receivedAfter;
    if (receivedBefore != null) result.receivedBefore = receivedBefore;
    return result;
  }

  RepaymentSearchRequest._();

  factory RepaymentSearchRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RepaymentSearchRequest()..mergeFromBuffer(data, registry);
  factory RepaymentSearchRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RepaymentSearchRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RepaymentSearchRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: RepaymentSearchRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'loanAccountId')
    ..aE<RepaymentStatus>(2, _omitFieldNames ? '' : 'status',
        enumValues: RepaymentStatus.values)
    ..aOM<$2.PageCursor>(3, _omitFieldNames ? '' : 'cursor',
        subBuilder: $2.PageCursor.$_createMessage)
    ..aOS(4, _omitFieldNames ? '' : 'collectedBy')
    ..aOS(5, _omitFieldNames ? '' : 'receivedAfter')
    ..aOS(6, _omitFieldNames ? '' : 'receivedBefore')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RepaymentSearchRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RepaymentSearchRequest copyWith(
          void Function(RepaymentSearchRequest) updates) =>
      super.copyWith((message) => updates(message as RepaymentSearchRequest))
          as RepaymentSearchRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use RepaymentSearchRequest() / RepaymentSearchRequest.new instead')
  static RepaymentSearchRequest create() => RepaymentSearchRequest._();
  static $pb.GeneratedMessage $_createMessage() => RepaymentSearchRequest._();
  @$core.override
  RepaymentSearchRequest createEmptyInstance() => RepaymentSearchRequest._();
  @$core.pragma('dart2js:noInline')
  static RepaymentSearchRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RepaymentSearchRequest>(
          RepaymentSearchRequest.$_createMessage);
  static RepaymentSearchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get loanAccountId => $_getSZ(0);
  @$pb.TagNumber(1)
  set loanAccountId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLoanAccountId() => $_has(0);
  @$pb.TagNumber(1)
  void clearLoanAccountId() => $_clearField(1);

  @$pb.TagNumber(2)
  RepaymentStatus get status => $_getN(1);
  @$pb.TagNumber(2)
  set status(RepaymentStatus value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasStatus() => $_has(1);
  @$pb.TagNumber(2)
  void clearStatus() => $_clearField(2);

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

  /// Deprecated and ignored: nobody collects repayments on a borrower's
  /// behalf. A search without a loan is open to staff only.
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(4)
  $core.String get collectedBy => $_getSZ(3);
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(4)
  set collectedBy($core.String value) => $_setString(3, value);
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(4)
  $core.bool hasCollectedBy() => $_has(3);
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(4)
  void clearCollectedBy() => $_clearField(4);

  /// received_after and received_before bound the receipt time (RFC3339).
  @$pb.TagNumber(5)
  $core.String get receivedAfter => $_getSZ(4);
  @$pb.TagNumber(5)
  set receivedAfter($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasReceivedAfter() => $_has(4);
  @$pb.TagNumber(5)
  void clearReceivedAfter() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get receivedBefore => $_getSZ(5);
  @$pb.TagNumber(6)
  set receivedBefore($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasReceivedBefore() => $_has(5);
  @$pb.TagNumber(6)
  void clearReceivedBefore() => $_clearField(6);
}

class RepaymentSearchResponse extends $pb.GeneratedMessage {
  factory RepaymentSearchResponse({
    $core.Iterable<RepaymentObject>? data,
  }) {
    final result = RepaymentSearchResponse._();
    if (data != null) result.data.addAll(data);
    return result;
  }

  RepaymentSearchResponse._();

  factory RepaymentSearchResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RepaymentSearchResponse()..mergeFromBuffer(data, registry);
  factory RepaymentSearchResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RepaymentSearchResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RepaymentSearchResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: RepaymentSearchResponse.$_createMessage)
    ..pPM<RepaymentObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: RepaymentObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RepaymentSearchResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RepaymentSearchResponse copyWith(
          void Function(RepaymentSearchResponse) updates) =>
      super.copyWith((message) => updates(message as RepaymentSearchResponse))
          as RepaymentSearchResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use RepaymentSearchResponse() / RepaymentSearchResponse.new instead')
  static RepaymentSearchResponse create() => RepaymentSearchResponse._();
  static $pb.GeneratedMessage $_createMessage() => RepaymentSearchResponse._();
  @$core.override
  RepaymentSearchResponse createEmptyInstance() => RepaymentSearchResponse._();
  @$core.pragma('dart2js:noInline')
  static RepaymentSearchResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RepaymentSearchResponse>(
          RepaymentSearchResponse.$_createMessage);
  static RepaymentSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<RepaymentObject> get data => $_getList(0);
}

class RepaymentScheduleGetRequest extends $pb.GeneratedMessage {
  factory RepaymentScheduleGetRequest({
    $core.String? loanAccountId,
  }) {
    final result = RepaymentScheduleGetRequest._();
    if (loanAccountId != null) result.loanAccountId = loanAccountId;
    return result;
  }

  RepaymentScheduleGetRequest._();

  factory RepaymentScheduleGetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RepaymentScheduleGetRequest()..mergeFromBuffer(data, registry);
  factory RepaymentScheduleGetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RepaymentScheduleGetRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RepaymentScheduleGetRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: RepaymentScheduleGetRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'loanAccountId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RepaymentScheduleGetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RepaymentScheduleGetRequest copyWith(
          void Function(RepaymentScheduleGetRequest) updates) =>
      super.copyWith(
              (message) => updates(message as RepaymentScheduleGetRequest))
          as RepaymentScheduleGetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use RepaymentScheduleGetRequest() / RepaymentScheduleGetRequest.new instead')
  static RepaymentScheduleGetRequest create() =>
      RepaymentScheduleGetRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      RepaymentScheduleGetRequest._();
  @$core.override
  RepaymentScheduleGetRequest createEmptyInstance() =>
      RepaymentScheduleGetRequest._();
  @$core.pragma('dart2js:noInline')
  static RepaymentScheduleGetRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RepaymentScheduleGetRequest>(
          RepaymentScheduleGetRequest.$_createMessage);
  static RepaymentScheduleGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get loanAccountId => $_getSZ(0);
  @$pb.TagNumber(1)
  set loanAccountId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLoanAccountId() => $_has(0);
  @$pb.TagNumber(1)
  void clearLoanAccountId() => $_clearField(1);
}

class RepaymentScheduleGetResponse extends $pb.GeneratedMessage {
  factory RepaymentScheduleGetResponse({
    RepaymentScheduleObject? data,
  }) {
    final result = RepaymentScheduleGetResponse._();
    if (data != null) result.data = data;
    return result;
  }

  RepaymentScheduleGetResponse._();

  factory RepaymentScheduleGetResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RepaymentScheduleGetResponse()..mergeFromBuffer(data, registry);
  factory RepaymentScheduleGetResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RepaymentScheduleGetResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RepaymentScheduleGetResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: RepaymentScheduleGetResponse.$_createMessage)
    ..aOM<RepaymentScheduleObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: RepaymentScheduleObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RepaymentScheduleGetResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RepaymentScheduleGetResponse copyWith(
          void Function(RepaymentScheduleGetResponse) updates) =>
      super.copyWith(
              (message) => updates(message as RepaymentScheduleGetResponse))
          as RepaymentScheduleGetResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use RepaymentScheduleGetResponse() / RepaymentScheduleGetResponse.new instead')
  static RepaymentScheduleGetResponse create() =>
      RepaymentScheduleGetResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      RepaymentScheduleGetResponse._();
  @$core.override
  RepaymentScheduleGetResponse createEmptyInstance() =>
      RepaymentScheduleGetResponse._();
  @$core.pragma('dart2js:noInline')
  static RepaymentScheduleGetResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RepaymentScheduleGetResponse>(
          RepaymentScheduleGetResponse.$_createMessage);
  static RepaymentScheduleGetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  RepaymentScheduleObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(RepaymentScheduleObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  RepaymentScheduleObject ensureData() => $_ensure(0);
}

class PenaltySaveRequest extends $pb.GeneratedMessage {
  factory PenaltySaveRequest({
    PenaltyObject? data,
  }) {
    final result = PenaltySaveRequest._();
    if (data != null) result.data = data;
    return result;
  }

  PenaltySaveRequest._();

  factory PenaltySaveRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PenaltySaveRequest()..mergeFromBuffer(data, registry);
  factory PenaltySaveRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PenaltySaveRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PenaltySaveRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: PenaltySaveRequest.$_createMessage)
    ..aOM<PenaltyObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: PenaltyObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PenaltySaveRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PenaltySaveRequest copyWith(void Function(PenaltySaveRequest) updates) =>
      super.copyWith((message) => updates(message as PenaltySaveRequest))
          as PenaltySaveRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use PenaltySaveRequest() / PenaltySaveRequest.new instead')
  static PenaltySaveRequest create() => PenaltySaveRequest._();
  static $pb.GeneratedMessage $_createMessage() => PenaltySaveRequest._();
  @$core.override
  PenaltySaveRequest createEmptyInstance() => PenaltySaveRequest._();
  @$core.pragma('dart2js:noInline')
  static PenaltySaveRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PenaltySaveRequest>(
          PenaltySaveRequest.$_createMessage);
  static PenaltySaveRequest? _defaultInstance;

  @$pb.TagNumber(1)
  PenaltyObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(PenaltyObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  PenaltyObject ensureData() => $_ensure(0);
}

class PenaltySaveResponse extends $pb.GeneratedMessage {
  factory PenaltySaveResponse({
    PenaltyObject? data,
  }) {
    final result = PenaltySaveResponse._();
    if (data != null) result.data = data;
    return result;
  }

  PenaltySaveResponse._();

  factory PenaltySaveResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PenaltySaveResponse()..mergeFromBuffer(data, registry);
  factory PenaltySaveResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PenaltySaveResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PenaltySaveResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: PenaltySaveResponse.$_createMessage)
    ..aOM<PenaltyObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: PenaltyObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PenaltySaveResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PenaltySaveResponse copyWith(void Function(PenaltySaveResponse) updates) =>
      super.copyWith((message) => updates(message as PenaltySaveResponse))
          as PenaltySaveResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core
      .Deprecated('Use PenaltySaveResponse() / PenaltySaveResponse.new instead')
  static PenaltySaveResponse create() => PenaltySaveResponse._();
  static $pb.GeneratedMessage $_createMessage() => PenaltySaveResponse._();
  @$core.override
  PenaltySaveResponse createEmptyInstance() => PenaltySaveResponse._();
  @$core.pragma('dart2js:noInline')
  static PenaltySaveResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PenaltySaveResponse>(
          PenaltySaveResponse.$_createMessage);
  static PenaltySaveResponse? _defaultInstance;

  @$pb.TagNumber(1)
  PenaltyObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(PenaltyObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  PenaltyObject ensureData() => $_ensure(0);
}

class PenaltyWaiveRequest extends $pb.GeneratedMessage {
  factory PenaltyWaiveRequest({
    $core.String? id,
    $core.String? reason,
  }) {
    final result = PenaltyWaiveRequest._();
    if (id != null) result.id = id;
    if (reason != null) result.reason = reason;
    return result;
  }

  PenaltyWaiveRequest._();

  factory PenaltyWaiveRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PenaltyWaiveRequest()..mergeFromBuffer(data, registry);
  factory PenaltyWaiveRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PenaltyWaiveRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PenaltyWaiveRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: PenaltyWaiveRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'reason')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PenaltyWaiveRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PenaltyWaiveRequest copyWith(void Function(PenaltyWaiveRequest) updates) =>
      super.copyWith((message) => updates(message as PenaltyWaiveRequest))
          as PenaltyWaiveRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core
      .Deprecated('Use PenaltyWaiveRequest() / PenaltyWaiveRequest.new instead')
  static PenaltyWaiveRequest create() => PenaltyWaiveRequest._();
  static $pb.GeneratedMessage $_createMessage() => PenaltyWaiveRequest._();
  @$core.override
  PenaltyWaiveRequest createEmptyInstance() => PenaltyWaiveRequest._();
  @$core.pragma('dart2js:noInline')
  static PenaltyWaiveRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PenaltyWaiveRequest>(
          PenaltyWaiveRequest.$_createMessage);
  static PenaltyWaiveRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get reason => $_getSZ(1);
  @$pb.TagNumber(2)
  set reason($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasReason() => $_has(1);
  @$pb.TagNumber(2)
  void clearReason() => $_clearField(2);
}

class PenaltyWaiveResponse extends $pb.GeneratedMessage {
  factory PenaltyWaiveResponse({
    PenaltyObject? data,
  }) {
    final result = PenaltyWaiveResponse._();
    if (data != null) result.data = data;
    return result;
  }

  PenaltyWaiveResponse._();

  factory PenaltyWaiveResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PenaltyWaiveResponse()..mergeFromBuffer(data, registry);
  factory PenaltyWaiveResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PenaltyWaiveResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PenaltyWaiveResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: PenaltyWaiveResponse.$_createMessage)
    ..aOM<PenaltyObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: PenaltyObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PenaltyWaiveResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PenaltyWaiveResponse copyWith(void Function(PenaltyWaiveResponse) updates) =>
      super.copyWith((message) => updates(message as PenaltyWaiveResponse))
          as PenaltyWaiveResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use PenaltyWaiveResponse() / PenaltyWaiveResponse.new instead')
  static PenaltyWaiveResponse create() => PenaltyWaiveResponse._();
  static $pb.GeneratedMessage $_createMessage() => PenaltyWaiveResponse._();
  @$core.override
  PenaltyWaiveResponse createEmptyInstance() => PenaltyWaiveResponse._();
  @$core.pragma('dart2js:noInline')
  static PenaltyWaiveResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PenaltyWaiveResponse>(
          PenaltyWaiveResponse.$_createMessage);
  static PenaltyWaiveResponse? _defaultInstance;

  @$pb.TagNumber(1)
  PenaltyObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(PenaltyObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  PenaltyObject ensureData() => $_ensure(0);
}

class PenaltySearchRequest extends $pb.GeneratedMessage {
  factory PenaltySearchRequest({
    $core.String? loanAccountId,
    PenaltyType? penaltyType,
    $2.PageCursor? cursor,
  }) {
    final result = PenaltySearchRequest._();
    if (loanAccountId != null) result.loanAccountId = loanAccountId;
    if (penaltyType != null) result.penaltyType = penaltyType;
    if (cursor != null) result.cursor = cursor;
    return result;
  }

  PenaltySearchRequest._();

  factory PenaltySearchRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PenaltySearchRequest()..mergeFromBuffer(data, registry);
  factory PenaltySearchRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PenaltySearchRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PenaltySearchRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: PenaltySearchRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'loanAccountId')
    ..aE<PenaltyType>(2, _omitFieldNames ? '' : 'penaltyType',
        enumValues: PenaltyType.values)
    ..aOM<$2.PageCursor>(3, _omitFieldNames ? '' : 'cursor',
        subBuilder: $2.PageCursor.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PenaltySearchRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PenaltySearchRequest copyWith(void Function(PenaltySearchRequest) updates) =>
      super.copyWith((message) => updates(message as PenaltySearchRequest))
          as PenaltySearchRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use PenaltySearchRequest() / PenaltySearchRequest.new instead')
  static PenaltySearchRequest create() => PenaltySearchRequest._();
  static $pb.GeneratedMessage $_createMessage() => PenaltySearchRequest._();
  @$core.override
  PenaltySearchRequest createEmptyInstance() => PenaltySearchRequest._();
  @$core.pragma('dart2js:noInline')
  static PenaltySearchRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PenaltySearchRequest>(
          PenaltySearchRequest.$_createMessage);
  static PenaltySearchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get loanAccountId => $_getSZ(0);
  @$pb.TagNumber(1)
  set loanAccountId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLoanAccountId() => $_has(0);
  @$pb.TagNumber(1)
  void clearLoanAccountId() => $_clearField(1);

  @$pb.TagNumber(2)
  PenaltyType get penaltyType => $_getN(1);
  @$pb.TagNumber(2)
  set penaltyType(PenaltyType value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasPenaltyType() => $_has(1);
  @$pb.TagNumber(2)
  void clearPenaltyType() => $_clearField(2);

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
}

class PenaltySearchResponse extends $pb.GeneratedMessage {
  factory PenaltySearchResponse({
    $core.Iterable<PenaltyObject>? data,
  }) {
    final result = PenaltySearchResponse._();
    if (data != null) result.data.addAll(data);
    return result;
  }

  PenaltySearchResponse._();

  factory PenaltySearchResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PenaltySearchResponse()..mergeFromBuffer(data, registry);
  factory PenaltySearchResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PenaltySearchResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PenaltySearchResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: PenaltySearchResponse.$_createMessage)
    ..pPM<PenaltyObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: PenaltyObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PenaltySearchResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PenaltySearchResponse copyWith(
          void Function(PenaltySearchResponse) updates) =>
      super.copyWith((message) => updates(message as PenaltySearchResponse))
          as PenaltySearchResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use PenaltySearchResponse() / PenaltySearchResponse.new instead')
  static PenaltySearchResponse create() => PenaltySearchResponse._();
  static $pb.GeneratedMessage $_createMessage() => PenaltySearchResponse._();
  @$core.override
  PenaltySearchResponse createEmptyInstance() => PenaltySearchResponse._();
  @$core.pragma('dart2js:noInline')
  static PenaltySearchResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PenaltySearchResponse>(
          PenaltySearchResponse.$_createMessage);
  static PenaltySearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<PenaltyObject> get data => $_getList(0);
}

class LoanRestructureCreateRequest extends $pb.GeneratedMessage {
  factory LoanRestructureCreateRequest({
    LoanRestructureObject? data,
  }) {
    final result = LoanRestructureCreateRequest._();
    if (data != null) result.data = data;
    return result;
  }

  LoanRestructureCreateRequest._();

  factory LoanRestructureCreateRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanRestructureCreateRequest()..mergeFromBuffer(data, registry);
  factory LoanRestructureCreateRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanRestructureCreateRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LoanRestructureCreateRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: LoanRestructureCreateRequest.$_createMessage)
    ..aOM<LoanRestructureObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: LoanRestructureObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanRestructureCreateRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanRestructureCreateRequest copyWith(
          void Function(LoanRestructureCreateRequest) updates) =>
      super.copyWith(
              (message) => updates(message as LoanRestructureCreateRequest))
          as LoanRestructureCreateRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use LoanRestructureCreateRequest() / LoanRestructureCreateRequest.new instead')
  static LoanRestructureCreateRequest create() =>
      LoanRestructureCreateRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      LoanRestructureCreateRequest._();
  @$core.override
  LoanRestructureCreateRequest createEmptyInstance() =>
      LoanRestructureCreateRequest._();
  @$core.pragma('dart2js:noInline')
  static LoanRestructureCreateRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LoanRestructureCreateRequest>(
          LoanRestructureCreateRequest.$_createMessage);
  static LoanRestructureCreateRequest? _defaultInstance;

  @$pb.TagNumber(1)
  LoanRestructureObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(LoanRestructureObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  LoanRestructureObject ensureData() => $_ensure(0);
}

class LoanRestructureCreateResponse extends $pb.GeneratedMessage {
  factory LoanRestructureCreateResponse({
    LoanRestructureObject? data,
  }) {
    final result = LoanRestructureCreateResponse._();
    if (data != null) result.data = data;
    return result;
  }

  LoanRestructureCreateResponse._();

  factory LoanRestructureCreateResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanRestructureCreateResponse()..mergeFromBuffer(data, registry);
  factory LoanRestructureCreateResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanRestructureCreateResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LoanRestructureCreateResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: LoanRestructureCreateResponse.$_createMessage)
    ..aOM<LoanRestructureObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: LoanRestructureObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanRestructureCreateResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanRestructureCreateResponse copyWith(
          void Function(LoanRestructureCreateResponse) updates) =>
      super.copyWith(
              (message) => updates(message as LoanRestructureCreateResponse))
          as LoanRestructureCreateResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use LoanRestructureCreateResponse() / LoanRestructureCreateResponse.new instead')
  static LoanRestructureCreateResponse create() =>
      LoanRestructureCreateResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      LoanRestructureCreateResponse._();
  @$core.override
  LoanRestructureCreateResponse createEmptyInstance() =>
      LoanRestructureCreateResponse._();
  @$core.pragma('dart2js:noInline')
  static LoanRestructureCreateResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LoanRestructureCreateResponse>(
          LoanRestructureCreateResponse.$_createMessage);
  static LoanRestructureCreateResponse? _defaultInstance;

  @$pb.TagNumber(1)
  LoanRestructureObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(LoanRestructureObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  LoanRestructureObject ensureData() => $_ensure(0);
}

class LoanRestructureApproveRequest extends $pb.GeneratedMessage {
  factory LoanRestructureApproveRequest({
    $core.String? id,
  }) {
    final result = LoanRestructureApproveRequest._();
    if (id != null) result.id = id;
    return result;
  }

  LoanRestructureApproveRequest._();

  factory LoanRestructureApproveRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanRestructureApproveRequest()..mergeFromBuffer(data, registry);
  factory LoanRestructureApproveRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanRestructureApproveRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LoanRestructureApproveRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: LoanRestructureApproveRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanRestructureApproveRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanRestructureApproveRequest copyWith(
          void Function(LoanRestructureApproveRequest) updates) =>
      super.copyWith(
              (message) => updates(message as LoanRestructureApproveRequest))
          as LoanRestructureApproveRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use LoanRestructureApproveRequest() / LoanRestructureApproveRequest.new instead')
  static LoanRestructureApproveRequest create() =>
      LoanRestructureApproveRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      LoanRestructureApproveRequest._();
  @$core.override
  LoanRestructureApproveRequest createEmptyInstance() =>
      LoanRestructureApproveRequest._();
  @$core.pragma('dart2js:noInline')
  static LoanRestructureApproveRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LoanRestructureApproveRequest>(
          LoanRestructureApproveRequest.$_createMessage);
  static LoanRestructureApproveRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class LoanRestructureApproveResponse extends $pb.GeneratedMessage {
  factory LoanRestructureApproveResponse({
    LoanRestructureObject? data,
  }) {
    final result = LoanRestructureApproveResponse._();
    if (data != null) result.data = data;
    return result;
  }

  LoanRestructureApproveResponse._();

  factory LoanRestructureApproveResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanRestructureApproveResponse()..mergeFromBuffer(data, registry);
  factory LoanRestructureApproveResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanRestructureApproveResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LoanRestructureApproveResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: LoanRestructureApproveResponse.$_createMessage)
    ..aOM<LoanRestructureObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: LoanRestructureObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanRestructureApproveResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanRestructureApproveResponse copyWith(
          void Function(LoanRestructureApproveResponse) updates) =>
      super.copyWith(
              (message) => updates(message as LoanRestructureApproveResponse))
          as LoanRestructureApproveResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use LoanRestructureApproveResponse() / LoanRestructureApproveResponse.new instead')
  static LoanRestructureApproveResponse create() =>
      LoanRestructureApproveResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      LoanRestructureApproveResponse._();
  @$core.override
  LoanRestructureApproveResponse createEmptyInstance() =>
      LoanRestructureApproveResponse._();
  @$core.pragma('dart2js:noInline')
  static LoanRestructureApproveResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LoanRestructureApproveResponse>(
          LoanRestructureApproveResponse.$_createMessage);
  static LoanRestructureApproveResponse? _defaultInstance;

  @$pb.TagNumber(1)
  LoanRestructureObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(LoanRestructureObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  LoanRestructureObject ensureData() => $_ensure(0);
}

class LoanRestructureRejectRequest extends $pb.GeneratedMessage {
  factory LoanRestructureRejectRequest({
    $core.String? id,
    $core.String? reason,
  }) {
    final result = LoanRestructureRejectRequest._();
    if (id != null) result.id = id;
    if (reason != null) result.reason = reason;
    return result;
  }

  LoanRestructureRejectRequest._();

  factory LoanRestructureRejectRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanRestructureRejectRequest()..mergeFromBuffer(data, registry);
  factory LoanRestructureRejectRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanRestructureRejectRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LoanRestructureRejectRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: LoanRestructureRejectRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'reason')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanRestructureRejectRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanRestructureRejectRequest copyWith(
          void Function(LoanRestructureRejectRequest) updates) =>
      super.copyWith(
              (message) => updates(message as LoanRestructureRejectRequest))
          as LoanRestructureRejectRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use LoanRestructureRejectRequest() / LoanRestructureRejectRequest.new instead')
  static LoanRestructureRejectRequest create() =>
      LoanRestructureRejectRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      LoanRestructureRejectRequest._();
  @$core.override
  LoanRestructureRejectRequest createEmptyInstance() =>
      LoanRestructureRejectRequest._();
  @$core.pragma('dart2js:noInline')
  static LoanRestructureRejectRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LoanRestructureRejectRequest>(
          LoanRestructureRejectRequest.$_createMessage);
  static LoanRestructureRejectRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get reason => $_getSZ(1);
  @$pb.TagNumber(2)
  set reason($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasReason() => $_has(1);
  @$pb.TagNumber(2)
  void clearReason() => $_clearField(2);
}

class LoanRestructureRejectResponse extends $pb.GeneratedMessage {
  factory LoanRestructureRejectResponse({
    LoanRestructureObject? data,
  }) {
    final result = LoanRestructureRejectResponse._();
    if (data != null) result.data = data;
    return result;
  }

  LoanRestructureRejectResponse._();

  factory LoanRestructureRejectResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanRestructureRejectResponse()..mergeFromBuffer(data, registry);
  factory LoanRestructureRejectResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanRestructureRejectResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LoanRestructureRejectResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: LoanRestructureRejectResponse.$_createMessage)
    ..aOM<LoanRestructureObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: LoanRestructureObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanRestructureRejectResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanRestructureRejectResponse copyWith(
          void Function(LoanRestructureRejectResponse) updates) =>
      super.copyWith(
              (message) => updates(message as LoanRestructureRejectResponse))
          as LoanRestructureRejectResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use LoanRestructureRejectResponse() / LoanRestructureRejectResponse.new instead')
  static LoanRestructureRejectResponse create() =>
      LoanRestructureRejectResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      LoanRestructureRejectResponse._();
  @$core.override
  LoanRestructureRejectResponse createEmptyInstance() =>
      LoanRestructureRejectResponse._();
  @$core.pragma('dart2js:noInline')
  static LoanRestructureRejectResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LoanRestructureRejectResponse>(
          LoanRestructureRejectResponse.$_createMessage);
  static LoanRestructureRejectResponse? _defaultInstance;

  @$pb.TagNumber(1)
  LoanRestructureObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(LoanRestructureObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  LoanRestructureObject ensureData() => $_ensure(0);
}

class LoanRestructureSearchRequest extends $pb.GeneratedMessage {
  factory LoanRestructureSearchRequest({
    $core.String? loanAccountId,
    $2.PageCursor? cursor,
  }) {
    final result = LoanRestructureSearchRequest._();
    if (loanAccountId != null) result.loanAccountId = loanAccountId;
    if (cursor != null) result.cursor = cursor;
    return result;
  }

  LoanRestructureSearchRequest._();

  factory LoanRestructureSearchRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanRestructureSearchRequest()..mergeFromBuffer(data, registry);
  factory LoanRestructureSearchRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanRestructureSearchRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LoanRestructureSearchRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: LoanRestructureSearchRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'loanAccountId')
    ..aOM<$2.PageCursor>(2, _omitFieldNames ? '' : 'cursor',
        subBuilder: $2.PageCursor.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanRestructureSearchRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanRestructureSearchRequest copyWith(
          void Function(LoanRestructureSearchRequest) updates) =>
      super.copyWith(
              (message) => updates(message as LoanRestructureSearchRequest))
          as LoanRestructureSearchRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use LoanRestructureSearchRequest() / LoanRestructureSearchRequest.new instead')
  static LoanRestructureSearchRequest create() =>
      LoanRestructureSearchRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      LoanRestructureSearchRequest._();
  @$core.override
  LoanRestructureSearchRequest createEmptyInstance() =>
      LoanRestructureSearchRequest._();
  @$core.pragma('dart2js:noInline')
  static LoanRestructureSearchRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LoanRestructureSearchRequest>(
          LoanRestructureSearchRequest.$_createMessage);
  static LoanRestructureSearchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get loanAccountId => $_getSZ(0);
  @$pb.TagNumber(1)
  set loanAccountId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLoanAccountId() => $_has(0);
  @$pb.TagNumber(1)
  void clearLoanAccountId() => $_clearField(1);

  @$pb.TagNumber(2)
  $2.PageCursor get cursor => $_getN(1);
  @$pb.TagNumber(2)
  set cursor($2.PageCursor value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasCursor() => $_has(1);
  @$pb.TagNumber(2)
  void clearCursor() => $_clearField(2);
  @$pb.TagNumber(2)
  $2.PageCursor ensureCursor() => $_ensure(1);
}

class LoanRestructureSearchResponse extends $pb.GeneratedMessage {
  factory LoanRestructureSearchResponse({
    $core.Iterable<LoanRestructureObject>? data,
  }) {
    final result = LoanRestructureSearchResponse._();
    if (data != null) result.data.addAll(data);
    return result;
  }

  LoanRestructureSearchResponse._();

  factory LoanRestructureSearchResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanRestructureSearchResponse()..mergeFromBuffer(data, registry);
  factory LoanRestructureSearchResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanRestructureSearchResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LoanRestructureSearchResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: LoanRestructureSearchResponse.$_createMessage)
    ..pPM<LoanRestructureObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: LoanRestructureObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanRestructureSearchResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanRestructureSearchResponse copyWith(
          void Function(LoanRestructureSearchResponse) updates) =>
      super.copyWith(
              (message) => updates(message as LoanRestructureSearchResponse))
          as LoanRestructureSearchResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use LoanRestructureSearchResponse() / LoanRestructureSearchResponse.new instead')
  static LoanRestructureSearchResponse create() =>
      LoanRestructureSearchResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      LoanRestructureSearchResponse._();
  @$core.override
  LoanRestructureSearchResponse createEmptyInstance() =>
      LoanRestructureSearchResponse._();
  @$core.pragma('dart2js:noInline')
  static LoanRestructureSearchResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LoanRestructureSearchResponse>(
          LoanRestructureSearchResponse.$_createMessage);
  static LoanRestructureSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<LoanRestructureObject> get data => $_getList(0);
}

class LoanStatementRequest extends $pb.GeneratedMessage {
  factory LoanStatementRequest({
    $core.String? loanAccountId,
    $core.String? fromDate,
    $core.String? toDate,
  }) {
    final result = LoanStatementRequest._();
    if (loanAccountId != null) result.loanAccountId = loanAccountId;
    if (fromDate != null) result.fromDate = fromDate;
    if (toDate != null) result.toDate = toDate;
    return result;
  }

  LoanStatementRequest._();

  factory LoanStatementRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanStatementRequest()..mergeFromBuffer(data, registry);
  factory LoanStatementRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanStatementRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LoanStatementRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: LoanStatementRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'loanAccountId')
    ..aOS(2, _omitFieldNames ? '' : 'fromDate')
    ..aOS(3, _omitFieldNames ? '' : 'toDate')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanStatementRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanStatementRequest copyWith(void Function(LoanStatementRequest) updates) =>
      super.copyWith((message) => updates(message as LoanStatementRequest))
          as LoanStatementRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use LoanStatementRequest() / LoanStatementRequest.new instead')
  static LoanStatementRequest create() => LoanStatementRequest._();
  static $pb.GeneratedMessage $_createMessage() => LoanStatementRequest._();
  @$core.override
  LoanStatementRequest createEmptyInstance() => LoanStatementRequest._();
  @$core.pragma('dart2js:noInline')
  static LoanStatementRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LoanStatementRequest>(
          LoanStatementRequest.$_createMessage);
  static LoanStatementRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get loanAccountId => $_getSZ(0);
  @$pb.TagNumber(1)
  set loanAccountId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLoanAccountId() => $_has(0);
  @$pb.TagNumber(1)
  void clearLoanAccountId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get fromDate => $_getSZ(1);
  @$pb.TagNumber(2)
  set fromDate($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFromDate() => $_has(1);
  @$pb.TagNumber(2)
  void clearFromDate() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get toDate => $_getSZ(2);
  @$pb.TagNumber(3)
  set toDate($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasToDate() => $_has(2);
  @$pb.TagNumber(3)
  void clearToDate() => $_clearField(3);
}

class LoanStatementResponse extends $pb.GeneratedMessage {
  factory LoanStatementResponse({
    LoanAccountObject? loan,
    LoanBalanceObject? balance,
    $core.Iterable<LoanStatementEntry>? entries,
  }) {
    final result = LoanStatementResponse._();
    if (loan != null) result.loan = loan;
    if (balance != null) result.balance = balance;
    if (entries != null) result.entries.addAll(entries);
    return result;
  }

  LoanStatementResponse._();

  factory LoanStatementResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanStatementResponse()..mergeFromBuffer(data, registry);
  factory LoanStatementResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanStatementResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LoanStatementResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: LoanStatementResponse.$_createMessage)
    ..aOM<LoanAccountObject>(1, _omitFieldNames ? '' : 'loan',
        subBuilder: LoanAccountObject.$_createMessage)
    ..aOM<LoanBalanceObject>(2, _omitFieldNames ? '' : 'balance',
        subBuilder: LoanBalanceObject.$_createMessage)
    ..pPM<LoanStatementEntry>(3, _omitFieldNames ? '' : 'entries',
        subBuilder: LoanStatementEntry.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanStatementResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanStatementResponse copyWith(
          void Function(LoanStatementResponse) updates) =>
      super.copyWith((message) => updates(message as LoanStatementResponse))
          as LoanStatementResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use LoanStatementResponse() / LoanStatementResponse.new instead')
  static LoanStatementResponse create() => LoanStatementResponse._();
  static $pb.GeneratedMessage $_createMessage() => LoanStatementResponse._();
  @$core.override
  LoanStatementResponse createEmptyInstance() => LoanStatementResponse._();
  @$core.pragma('dart2js:noInline')
  static LoanStatementResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LoanStatementResponse>(
          LoanStatementResponse.$_createMessage);
  static LoanStatementResponse? _defaultInstance;

  @$pb.TagNumber(1)
  LoanAccountObject get loan => $_getN(0);
  @$pb.TagNumber(1)
  set loan(LoanAccountObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasLoan() => $_has(0);
  @$pb.TagNumber(1)
  void clearLoan() => $_clearField(1);
  @$pb.TagNumber(1)
  LoanAccountObject ensureLoan() => $_ensure(0);

  @$pb.TagNumber(2)
  LoanBalanceObject get balance => $_getN(1);
  @$pb.TagNumber(2)
  set balance(LoanBalanceObject value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasBalance() => $_has(1);
  @$pb.TagNumber(2)
  void clearBalance() => $_clearField(2);
  @$pb.TagNumber(2)
  LoanBalanceObject ensureBalance() => $_ensure(1);

  @$pb.TagNumber(3)
  $pb.PbList<LoanStatementEntry> get entries => $_getList(2);
}

class ReconciliationSaveRequest extends $pb.GeneratedMessage {
  factory ReconciliationSaveRequest({
    ReconciliationObject? data,
  }) {
    final result = ReconciliationSaveRequest._();
    if (data != null) result.data = data;
    return result;
  }

  ReconciliationSaveRequest._();

  factory ReconciliationSaveRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ReconciliationSaveRequest()..mergeFromBuffer(data, registry);
  factory ReconciliationSaveRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ReconciliationSaveRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ReconciliationSaveRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: ReconciliationSaveRequest.$_createMessage)
    ..aOM<ReconciliationObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: ReconciliationObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReconciliationSaveRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReconciliationSaveRequest copyWith(
          void Function(ReconciliationSaveRequest) updates) =>
      super.copyWith((message) => updates(message as ReconciliationSaveRequest))
          as ReconciliationSaveRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ReconciliationSaveRequest() / ReconciliationSaveRequest.new instead')
  static ReconciliationSaveRequest create() => ReconciliationSaveRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      ReconciliationSaveRequest._();
  @$core.override
  ReconciliationSaveRequest createEmptyInstance() =>
      ReconciliationSaveRequest._();
  @$core.pragma('dart2js:noInline')
  static ReconciliationSaveRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ReconciliationSaveRequest>(
          ReconciliationSaveRequest.$_createMessage);
  static ReconciliationSaveRequest? _defaultInstance;

  @$pb.TagNumber(1)
  ReconciliationObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(ReconciliationObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  ReconciliationObject ensureData() => $_ensure(0);
}

class ReconciliationSaveResponse extends $pb.GeneratedMessage {
  factory ReconciliationSaveResponse({
    ReconciliationObject? data,
  }) {
    final result = ReconciliationSaveResponse._();
    if (data != null) result.data = data;
    return result;
  }

  ReconciliationSaveResponse._();

  factory ReconciliationSaveResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ReconciliationSaveResponse()..mergeFromBuffer(data, registry);
  factory ReconciliationSaveResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ReconciliationSaveResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ReconciliationSaveResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: ReconciliationSaveResponse.$_createMessage)
    ..aOM<ReconciliationObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: ReconciliationObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReconciliationSaveResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReconciliationSaveResponse copyWith(
          void Function(ReconciliationSaveResponse) updates) =>
      super.copyWith(
              (message) => updates(message as ReconciliationSaveResponse))
          as ReconciliationSaveResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ReconciliationSaveResponse() / ReconciliationSaveResponse.new instead')
  static ReconciliationSaveResponse create() => ReconciliationSaveResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      ReconciliationSaveResponse._();
  @$core.override
  ReconciliationSaveResponse createEmptyInstance() =>
      ReconciliationSaveResponse._();
  @$core.pragma('dart2js:noInline')
  static ReconciliationSaveResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ReconciliationSaveResponse>(
          ReconciliationSaveResponse.$_createMessage);
  static ReconciliationSaveResponse? _defaultInstance;

  @$pb.TagNumber(1)
  ReconciliationObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(ReconciliationObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  ReconciliationObject ensureData() => $_ensure(0);
}

class ReconciliationSearchRequest extends $pb.GeneratedMessage {
  factory ReconciliationSearchRequest({
    $core.String? loanAccountId,
    ReconciliationStatus? status,
    $2.PageCursor? cursor,
  }) {
    final result = ReconciliationSearchRequest._();
    if (loanAccountId != null) result.loanAccountId = loanAccountId;
    if (status != null) result.status = status;
    if (cursor != null) result.cursor = cursor;
    return result;
  }

  ReconciliationSearchRequest._();

  factory ReconciliationSearchRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ReconciliationSearchRequest()..mergeFromBuffer(data, registry);
  factory ReconciliationSearchRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ReconciliationSearchRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ReconciliationSearchRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: ReconciliationSearchRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'loanAccountId')
    ..aE<ReconciliationStatus>(2, _omitFieldNames ? '' : 'status',
        enumValues: ReconciliationStatus.values)
    ..aOM<$2.PageCursor>(3, _omitFieldNames ? '' : 'cursor',
        subBuilder: $2.PageCursor.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReconciliationSearchRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReconciliationSearchRequest copyWith(
          void Function(ReconciliationSearchRequest) updates) =>
      super.copyWith(
              (message) => updates(message as ReconciliationSearchRequest))
          as ReconciliationSearchRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ReconciliationSearchRequest() / ReconciliationSearchRequest.new instead')
  static ReconciliationSearchRequest create() =>
      ReconciliationSearchRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      ReconciliationSearchRequest._();
  @$core.override
  ReconciliationSearchRequest createEmptyInstance() =>
      ReconciliationSearchRequest._();
  @$core.pragma('dart2js:noInline')
  static ReconciliationSearchRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ReconciliationSearchRequest>(
          ReconciliationSearchRequest.$_createMessage);
  static ReconciliationSearchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get loanAccountId => $_getSZ(0);
  @$pb.TagNumber(1)
  set loanAccountId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLoanAccountId() => $_has(0);
  @$pb.TagNumber(1)
  void clearLoanAccountId() => $_clearField(1);

  @$pb.TagNumber(2)
  ReconciliationStatus get status => $_getN(1);
  @$pb.TagNumber(2)
  set status(ReconciliationStatus value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasStatus() => $_has(1);
  @$pb.TagNumber(2)
  void clearStatus() => $_clearField(2);

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
}

class ReconciliationSearchResponse extends $pb.GeneratedMessage {
  factory ReconciliationSearchResponse({
    $core.Iterable<ReconciliationObject>? data,
  }) {
    final result = ReconciliationSearchResponse._();
    if (data != null) result.data.addAll(data);
    return result;
  }

  ReconciliationSearchResponse._();

  factory ReconciliationSearchResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ReconciliationSearchResponse()..mergeFromBuffer(data, registry);
  factory ReconciliationSearchResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ReconciliationSearchResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ReconciliationSearchResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: ReconciliationSearchResponse.$_createMessage)
    ..pPM<ReconciliationObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: ReconciliationObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReconciliationSearchResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReconciliationSearchResponse copyWith(
          void Function(ReconciliationSearchResponse) updates) =>
      super.copyWith(
              (message) => updates(message as ReconciliationSearchResponse))
          as ReconciliationSearchResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ReconciliationSearchResponse() / ReconciliationSearchResponse.new instead')
  static ReconciliationSearchResponse create() =>
      ReconciliationSearchResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      ReconciliationSearchResponse._();
  @$core.override
  ReconciliationSearchResponse createEmptyInstance() =>
      ReconciliationSearchResponse._();
  @$core.pragma('dart2js:noInline')
  static ReconciliationSearchResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ReconciliationSearchResponse>(
          ReconciliationSearchResponse.$_createMessage);
  static ReconciliationSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<ReconciliationObject> get data => $_getList(0);
}

class InitiateCollectionRequest extends $pb.GeneratedMessage {
  factory InitiateCollectionRequest({
    $core.String? loanAccountId,
    @$core.Deprecated('This field is deprecated.') $core.String? amount,
    @$core.Deprecated('This field is deprecated.') $core.String? phoneNumber,
    $core.String? idempotencyKey,
    $0.Money? collectionAmount,
    $core.String? contactId,
  }) {
    final result = InitiateCollectionRequest._();
    if (loanAccountId != null) result.loanAccountId = loanAccountId;
    if (amount != null) result.amount = amount;
    if (phoneNumber != null) result.phoneNumber = phoneNumber;
    if (idempotencyKey != null) result.idempotencyKey = idempotencyKey;
    if (collectionAmount != null) result.collectionAmount = collectionAmount;
    if (contactId != null) result.contactId = contactId;
    return result;
  }

  InitiateCollectionRequest._();

  factory InitiateCollectionRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InitiateCollectionRequest()..mergeFromBuffer(data, registry);
  factory InitiateCollectionRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InitiateCollectionRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InitiateCollectionRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: InitiateCollectionRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'loanAccountId')
    ..aOS(2, _omitFieldNames ? '' : 'amount')
    ..aOS(3, _omitFieldNames ? '' : 'phoneNumber')
    ..aOS(4, _omitFieldNames ? '' : 'idempotencyKey')
    ..aOM<$0.Money>(5, _omitFieldNames ? '' : 'collectionAmount',
        subBuilder: $0.Money.$_createMessage)
    ..aOS(6, _omitFieldNames ? '' : 'contactId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InitiateCollectionRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InitiateCollectionRequest copyWith(
          void Function(InitiateCollectionRequest) updates) =>
      super.copyWith((message) => updates(message as InitiateCollectionRequest))
          as InitiateCollectionRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use InitiateCollectionRequest() / InitiateCollectionRequest.new instead')
  static InitiateCollectionRequest create() => InitiateCollectionRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      InitiateCollectionRequest._();
  @$core.override
  InitiateCollectionRequest createEmptyInstance() =>
      InitiateCollectionRequest._();
  @$core.pragma('dart2js:noInline')
  static InitiateCollectionRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<InitiateCollectionRequest>(
          InitiateCollectionRequest.$_createMessage);
  static InitiateCollectionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get loanAccountId => $_getSZ(0);
  @$pb.TagNumber(1)
  set loanAccountId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLoanAccountId() => $_has(0);
  @$pb.TagNumber(1)
  void clearLoanAccountId() => $_clearField(1);

  /// Deprecated: a bare decimal string carries no currency. Use
  /// collection_amount; when both are set collection_amount wins.
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(2)
  $core.String get amount => $_getSZ(1);
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(2)
  set amount($core.String value) => $_setString(1, value);
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(2)
  $core.bool hasAmount() => $_has(1);
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(2)
  void clearAmount() => $_clearField(2);

  /// Deprecated and refused: fintech never takes a raw phone number. Use
  /// contact_id.
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(3)
  $core.String get phoneNumber => $_getSZ(2);
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(3)
  set phoneNumber($core.String value) => $_setString(2, value);
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(3)
  $core.bool hasPhoneNumber() => $_has(2);
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(3)
  void clearPhoneNumber() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get idempotencyKey => $_getSZ(3);
  @$pb.TagNumber(4)
  set idempotencyKey($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasIdempotencyKey() => $_has(3);
  @$pb.TagNumber(4)
  void clearIdempotencyKey() => $_clearField(4);

  /// collection_amount is the amount to collect, in the loan's currency.
  /// When unset the outstanding balance is collected.
  @$pb.TagNumber(5)
  $0.Money get collectionAmount => $_getN(4);
  @$pb.TagNumber(5)
  set collectionAmount($0.Money value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasCollectionAmount() => $_has(4);
  @$pb.TagNumber(5)
  void clearCollectionAmount() => $_clearField(5);
  @$pb.TagNumber(5)
  $0.Money ensureCollectionAmount() => $_ensure(4);

  /// contact_id is the id of one of the borrower profile's contacts to prompt.
  /// When unset the borrower's profile is addressed and the notification
  /// service picks the contact.
  @$pb.TagNumber(6)
  $core.String get contactId => $_getSZ(5);
  @$pb.TagNumber(6)
  set contactId($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasContactId() => $_has(5);
  @$pb.TagNumber(6)
  void clearContactId() => $_clearField(6);
}

class InitiateCollectionResponse extends $pb.GeneratedMessage {
  factory InitiateCollectionResponse({
    $core.String? paymentPromptId,
    $core.String? status,
  }) {
    final result = InitiateCollectionResponse._();
    if (paymentPromptId != null) result.paymentPromptId = paymentPromptId;
    if (status != null) result.status = status;
    return result;
  }

  InitiateCollectionResponse._();

  factory InitiateCollectionResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InitiateCollectionResponse()..mergeFromBuffer(data, registry);
  factory InitiateCollectionResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InitiateCollectionResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InitiateCollectionResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: InitiateCollectionResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'paymentPromptId')
    ..aOS(2, _omitFieldNames ? '' : 'status')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InitiateCollectionResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InitiateCollectionResponse copyWith(
          void Function(InitiateCollectionResponse) updates) =>
      super.copyWith(
              (message) => updates(message as InitiateCollectionResponse))
          as InitiateCollectionResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use InitiateCollectionResponse() / InitiateCollectionResponse.new instead')
  static InitiateCollectionResponse create() => InitiateCollectionResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      InitiateCollectionResponse._();
  @$core.override
  InitiateCollectionResponse createEmptyInstance() =>
      InitiateCollectionResponse._();
  @$core.pragma('dart2js:noInline')
  static InitiateCollectionResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<InitiateCollectionResponse>(
          InitiateCollectionResponse.$_createMessage);
  static InitiateCollectionResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get paymentPromptId => $_getSZ(0);
  @$pb.TagNumber(1)
  set paymentPromptId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPaymentPromptId() => $_has(0);
  @$pb.TagNumber(1)
  void clearPaymentPromptId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get status => $_getSZ(1);
  @$pb.TagNumber(2)
  set status($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasStatus() => $_has(1);
  @$pb.TagNumber(2)
  void clearStatus() => $_clearField(2);
}

class LoanJobRunRequest extends $pb.GeneratedMessage {
  factory LoanJobRunRequest({
    LoanJob? job,
    $core.int? batchSize,
  }) {
    final result = LoanJobRunRequest._();
    if (job != null) result.job = job;
    if (batchSize != null) result.batchSize = batchSize;
    return result;
  }

  LoanJobRunRequest._();

  factory LoanJobRunRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanJobRunRequest()..mergeFromBuffer(data, registry);
  factory LoanJobRunRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanJobRunRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LoanJobRunRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: LoanJobRunRequest.$_createMessage)
    ..aE<LoanJob>(1, _omitFieldNames ? '' : 'job', enumValues: LoanJob.values)
    ..aI(2, _omitFieldNames ? '' : 'batchSize')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanJobRunRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanJobRunRequest copyWith(void Function(LoanJobRunRequest) updates) =>
      super.copyWith((message) => updates(message as LoanJobRunRequest))
          as LoanJobRunRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use LoanJobRunRequest() / LoanJobRunRequest.new instead')
  static LoanJobRunRequest create() => LoanJobRunRequest._();
  static $pb.GeneratedMessage $_createMessage() => LoanJobRunRequest._();
  @$core.override
  LoanJobRunRequest createEmptyInstance() => LoanJobRunRequest._();
  @$core.pragma('dart2js:noInline')
  static LoanJobRunRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LoanJobRunRequest>(
          LoanJobRunRequest.$_createMessage);
  static LoanJobRunRequest? _defaultInstance;

  @$pb.TagNumber(1)
  LoanJob get job => $_getN(0);
  @$pb.TagNumber(1)
  set job(LoanJob value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasJob() => $_has(0);
  @$pb.TagNumber(1)
  void clearJob() => $_clearField(1);

  /// Most items to process in this run. 0 uses the service default.
  @$pb.TagNumber(2)
  $core.int get batchSize => $_getIZ(1);
  @$pb.TagNumber(2)
  set batchSize($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasBatchSize() => $_has(1);
  @$pb.TagNumber(2)
  void clearBatchSize() => $_clearField(2);
}

class LoanJobRunResponse extends $pb.GeneratedMessage {
  factory LoanJobRunResponse({
    $core.int? processed,
    $core.bool? more,
  }) {
    final result = LoanJobRunResponse._();
    if (processed != null) result.processed = processed;
    if (more != null) result.more = more;
    return result;
  }

  LoanJobRunResponse._();

  factory LoanJobRunResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanJobRunResponse()..mergeFromBuffer(data, registry);
  factory LoanJobRunResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanJobRunResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LoanJobRunResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: LoanJobRunResponse.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'processed')
    ..aOB(2, _omitFieldNames ? '' : 'more')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanJobRunResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanJobRunResponse copyWith(void Function(LoanJobRunResponse) updates) =>
      super.copyWith((message) => updates(message as LoanJobRunResponse))
          as LoanJobRunResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use LoanJobRunResponse() / LoanJobRunResponse.new instead')
  static LoanJobRunResponse create() => LoanJobRunResponse._();
  static $pb.GeneratedMessage $_createMessage() => LoanJobRunResponse._();
  @$core.override
  LoanJobRunResponse createEmptyInstance() => LoanJobRunResponse._();
  @$core.pragma('dart2js:noInline')
  static LoanJobRunResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LoanJobRunResponse>(
          LoanJobRunResponse.$_createMessage);
  static LoanJobRunResponse? _defaultInstance;

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

class LoanStatusChangeSearchRequest extends $pb.GeneratedMessage {
  factory LoanStatusChangeSearchRequest({
    $core.String? loanAccountId,
    $2.PageCursor? cursor,
  }) {
    final result = LoanStatusChangeSearchRequest._();
    if (loanAccountId != null) result.loanAccountId = loanAccountId;
    if (cursor != null) result.cursor = cursor;
    return result;
  }

  LoanStatusChangeSearchRequest._();

  factory LoanStatusChangeSearchRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanStatusChangeSearchRequest()..mergeFromBuffer(data, registry);
  factory LoanStatusChangeSearchRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanStatusChangeSearchRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LoanStatusChangeSearchRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: LoanStatusChangeSearchRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'loanAccountId')
    ..aOM<$2.PageCursor>(2, _omitFieldNames ? '' : 'cursor',
        subBuilder: $2.PageCursor.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanStatusChangeSearchRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanStatusChangeSearchRequest copyWith(
          void Function(LoanStatusChangeSearchRequest) updates) =>
      super.copyWith(
              (message) => updates(message as LoanStatusChangeSearchRequest))
          as LoanStatusChangeSearchRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use LoanStatusChangeSearchRequest() / LoanStatusChangeSearchRequest.new instead')
  static LoanStatusChangeSearchRequest create() =>
      LoanStatusChangeSearchRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      LoanStatusChangeSearchRequest._();
  @$core.override
  LoanStatusChangeSearchRequest createEmptyInstance() =>
      LoanStatusChangeSearchRequest._();
  @$core.pragma('dart2js:noInline')
  static LoanStatusChangeSearchRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LoanStatusChangeSearchRequest>(
          LoanStatusChangeSearchRequest.$_createMessage);
  static LoanStatusChangeSearchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get loanAccountId => $_getSZ(0);
  @$pb.TagNumber(1)
  set loanAccountId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLoanAccountId() => $_has(0);
  @$pb.TagNumber(1)
  void clearLoanAccountId() => $_clearField(1);

  @$pb.TagNumber(2)
  $2.PageCursor get cursor => $_getN(1);
  @$pb.TagNumber(2)
  set cursor($2.PageCursor value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasCursor() => $_has(1);
  @$pb.TagNumber(2)
  void clearCursor() => $_clearField(2);
  @$pb.TagNumber(2)
  $2.PageCursor ensureCursor() => $_ensure(1);
}

class LoanStatusChangeSearchResponse extends $pb.GeneratedMessage {
  factory LoanStatusChangeSearchResponse({
    $core.Iterable<LoanStatusChangeObject>? data,
  }) {
    final result = LoanStatusChangeSearchResponse._();
    if (data != null) result.data.addAll(data);
    return result;
  }

  LoanStatusChangeSearchResponse._();

  factory LoanStatusChangeSearchResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanStatusChangeSearchResponse()..mergeFromBuffer(data, registry);
  factory LoanStatusChangeSearchResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanStatusChangeSearchResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LoanStatusChangeSearchResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: LoanStatusChangeSearchResponse.$_createMessage)
    ..pPM<LoanStatusChangeObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: LoanStatusChangeObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanStatusChangeSearchResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanStatusChangeSearchResponse copyWith(
          void Function(LoanStatusChangeSearchResponse) updates) =>
      super.copyWith(
              (message) => updates(message as LoanStatusChangeSearchResponse))
          as LoanStatusChangeSearchResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use LoanStatusChangeSearchResponse() / LoanStatusChangeSearchResponse.new instead')
  static LoanStatusChangeSearchResponse create() =>
      LoanStatusChangeSearchResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      LoanStatusChangeSearchResponse._();
  @$core.override
  LoanStatusChangeSearchResponse createEmptyInstance() =>
      LoanStatusChangeSearchResponse._();
  @$core.pragma('dart2js:noInline')
  static LoanStatusChangeSearchResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LoanStatusChangeSearchResponse>(
          LoanStatusChangeSearchResponse.$_createMessage);
  static LoanStatusChangeSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<LoanStatusChangeObject> get data => $_getList(0);
}

/// TeamCommissionObject is a team's commission in one currency: what it has
/// earned on interest its borrowers repaid, what has been paid out, and what
/// is left to pay.
class TeamCommissionObject extends $pb.GeneratedMessage {
  factory TeamCommissionObject({
    $core.String? teamId,
    $0.Money? accrued,
    $0.Money? paidOut,
    $0.Money? available,
  }) {
    final result = TeamCommissionObject._();
    if (teamId != null) result.teamId = teamId;
    if (accrued != null) result.accrued = accrued;
    if (paidOut != null) result.paidOut = paidOut;
    if (available != null) result.available = available;
    return result;
  }

  TeamCommissionObject._();

  factory TeamCommissionObject.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TeamCommissionObject()..mergeFromBuffer(data, registry);
  factory TeamCommissionObject.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TeamCommissionObject()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TeamCommissionObject',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: TeamCommissionObject.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'teamId')
    ..aOM<$0.Money>(2, _omitFieldNames ? '' : 'accrued',
        subBuilder: $0.Money.$_createMessage)
    ..aOM<$0.Money>(3, _omitFieldNames ? '' : 'paidOut',
        subBuilder: $0.Money.$_createMessage)
    ..aOM<$0.Money>(4, _omitFieldNames ? '' : 'available',
        subBuilder: $0.Money.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TeamCommissionObject clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TeamCommissionObject copyWith(void Function(TeamCommissionObject) updates) =>
      super.copyWith((message) => updates(message as TeamCommissionObject))
          as TeamCommissionObject;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use TeamCommissionObject() / TeamCommissionObject.new instead')
  static TeamCommissionObject create() => TeamCommissionObject._();
  static $pb.GeneratedMessage $_createMessage() => TeamCommissionObject._();
  @$core.override
  TeamCommissionObject createEmptyInstance() => TeamCommissionObject._();
  @$core.pragma('dart2js:noInline')
  static TeamCommissionObject getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TeamCommissionObject>(
          TeamCommissionObject.$_createMessage);
  static TeamCommissionObject? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get teamId => $_getSZ(0);
  @$pb.TagNumber(1)
  set teamId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTeamId() => $_has(0);
  @$pb.TagNumber(1)
  void clearTeamId() => $_clearField(1);

  @$pb.TagNumber(2)
  $0.Money get accrued => $_getN(1);
  @$pb.TagNumber(2)
  set accrued($0.Money value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasAccrued() => $_has(1);
  @$pb.TagNumber(2)
  void clearAccrued() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.Money ensureAccrued() => $_ensure(1);

  @$pb.TagNumber(3)
  $0.Money get paidOut => $_getN(2);
  @$pb.TagNumber(3)
  set paidOut($0.Money value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasPaidOut() => $_has(2);
  @$pb.TagNumber(3)
  void clearPaidOut() => $_clearField(3);
  @$pb.TagNumber(3)
  $0.Money ensurePaidOut() => $_ensure(2);

  @$pb.TagNumber(4)
  $0.Money get available => $_getN(3);
  @$pb.TagNumber(4)
  set available($0.Money value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasAvailable() => $_has(3);
  @$pb.TagNumber(4)
  void clearAvailable() => $_clearField(4);
  @$pb.TagNumber(4)
  $0.Money ensureAvailable() => $_ensure(3);
}

class TeamCommissionSearchRequest extends $pb.GeneratedMessage {
  factory TeamCommissionSearchRequest({
    $core.String? teamId,
    $2.PageCursor? cursor,
  }) {
    final result = TeamCommissionSearchRequest._();
    if (teamId != null) result.teamId = teamId;
    if (cursor != null) result.cursor = cursor;
    return result;
  }

  TeamCommissionSearchRequest._();

  factory TeamCommissionSearchRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TeamCommissionSearchRequest()..mergeFromBuffer(data, registry);
  factory TeamCommissionSearchRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TeamCommissionSearchRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TeamCommissionSearchRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: TeamCommissionSearchRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'teamId')
    ..aOM<$2.PageCursor>(2, _omitFieldNames ? '' : 'cursor',
        subBuilder: $2.PageCursor.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TeamCommissionSearchRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TeamCommissionSearchRequest copyWith(
          void Function(TeamCommissionSearchRequest) updates) =>
      super.copyWith(
              (message) => updates(message as TeamCommissionSearchRequest))
          as TeamCommissionSearchRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use TeamCommissionSearchRequest() / TeamCommissionSearchRequest.new instead')
  static TeamCommissionSearchRequest create() =>
      TeamCommissionSearchRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      TeamCommissionSearchRequest._();
  @$core.override
  TeamCommissionSearchRequest createEmptyInstance() =>
      TeamCommissionSearchRequest._();
  @$core.pragma('dart2js:noInline')
  static TeamCommissionSearchRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TeamCommissionSearchRequest>(
          TeamCommissionSearchRequest.$_createMessage);
  static TeamCommissionSearchRequest? _defaultInstance;

  /// Empty lists every team with commission in the caller's partition.
  @$pb.TagNumber(1)
  $core.String get teamId => $_getSZ(0);
  @$pb.TagNumber(1)
  set teamId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTeamId() => $_has(0);
  @$pb.TagNumber(1)
  void clearTeamId() => $_clearField(1);

  @$pb.TagNumber(2)
  $2.PageCursor get cursor => $_getN(1);
  @$pb.TagNumber(2)
  set cursor($2.PageCursor value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasCursor() => $_has(1);
  @$pb.TagNumber(2)
  void clearCursor() => $_clearField(2);
  @$pb.TagNumber(2)
  $2.PageCursor ensureCursor() => $_ensure(1);
}

class TeamCommissionSearchResponse extends $pb.GeneratedMessage {
  factory TeamCommissionSearchResponse({
    $core.Iterable<TeamCommissionObject>? data,
  }) {
    final result = TeamCommissionSearchResponse._();
    if (data != null) result.data.addAll(data);
    return result;
  }

  TeamCommissionSearchResponse._();

  factory TeamCommissionSearchResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TeamCommissionSearchResponse()..mergeFromBuffer(data, registry);
  factory TeamCommissionSearchResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TeamCommissionSearchResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TeamCommissionSearchResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: TeamCommissionSearchResponse.$_createMessage)
    ..pPM<TeamCommissionObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: TeamCommissionObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TeamCommissionSearchResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TeamCommissionSearchResponse copyWith(
          void Function(TeamCommissionSearchResponse) updates) =>
      super.copyWith(
              (message) => updates(message as TeamCommissionSearchResponse))
          as TeamCommissionSearchResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use TeamCommissionSearchResponse() / TeamCommissionSearchResponse.new instead')
  static TeamCommissionSearchResponse create() =>
      TeamCommissionSearchResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      TeamCommissionSearchResponse._();
  @$core.override
  TeamCommissionSearchResponse createEmptyInstance() =>
      TeamCommissionSearchResponse._();
  @$core.pragma('dart2js:noInline')
  static TeamCommissionSearchResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TeamCommissionSearchResponse>(
          TeamCommissionSearchResponse.$_createMessage);
  static TeamCommissionSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<TeamCommissionObject> get data => $_getList(0);
}

/// TeamCommissionPayoutObject is one payout of a team's commission to one of
/// its members.
class TeamCommissionPayoutObject extends $pb.GeneratedMessage {
  factory TeamCommissionPayoutObject({
    $core.String? id,
    $core.String? teamId,
    $core.String? memberId,
    $0.Money? amount,
    TeamCommissionPayoutStatus? status,
    $core.String? failureReason,
    $core.String? reason,
    $core.String? createdBy,
    $core.String? createdAt,
  }) {
    final result = TeamCommissionPayoutObject._();
    if (id != null) result.id = id;
    if (teamId != null) result.teamId = teamId;
    if (memberId != null) result.memberId = memberId;
    if (amount != null) result.amount = amount;
    if (status != null) result.status = status;
    if (failureReason != null) result.failureReason = failureReason;
    if (reason != null) result.reason = reason;
    if (createdBy != null) result.createdBy = createdBy;
    if (createdAt != null) result.createdAt = createdAt;
    return result;
  }

  TeamCommissionPayoutObject._();

  factory TeamCommissionPayoutObject.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TeamCommissionPayoutObject()..mergeFromBuffer(data, registry);
  factory TeamCommissionPayoutObject.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TeamCommissionPayoutObject()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TeamCommissionPayoutObject',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: TeamCommissionPayoutObject.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'teamId')
    ..aOS(3, _omitFieldNames ? '' : 'memberId')
    ..aOM<$0.Money>(4, _omitFieldNames ? '' : 'amount',
        subBuilder: $0.Money.$_createMessage)
    ..aE<TeamCommissionPayoutStatus>(5, _omitFieldNames ? '' : 'status',
        enumValues: TeamCommissionPayoutStatus.values)
    ..aOS(6, _omitFieldNames ? '' : 'failureReason')
    ..aOS(7, _omitFieldNames ? '' : 'reason')
    ..aOS(8, _omitFieldNames ? '' : 'createdBy')
    ..aOS(9, _omitFieldNames ? '' : 'createdAt')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TeamCommissionPayoutObject clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TeamCommissionPayoutObject copyWith(
          void Function(TeamCommissionPayoutObject) updates) =>
      super.copyWith(
              (message) => updates(message as TeamCommissionPayoutObject))
          as TeamCommissionPayoutObject;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use TeamCommissionPayoutObject() / TeamCommissionPayoutObject.new instead')
  static TeamCommissionPayoutObject create() => TeamCommissionPayoutObject._();
  static $pb.GeneratedMessage $_createMessage() =>
      TeamCommissionPayoutObject._();
  @$core.override
  TeamCommissionPayoutObject createEmptyInstance() =>
      TeamCommissionPayoutObject._();
  @$core.pragma('dart2js:noInline')
  static TeamCommissionPayoutObject getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TeamCommissionPayoutObject>(
          TeamCommissionPayoutObject.$_createMessage);
  static TeamCommissionPayoutObject? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get teamId => $_getSZ(1);
  @$pb.TagNumber(2)
  set teamId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTeamId() => $_has(1);
  @$pb.TagNumber(2)
  void clearTeamId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get memberId => $_getSZ(2);
  @$pb.TagNumber(3)
  set memberId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMemberId() => $_has(2);
  @$pb.TagNumber(3)
  void clearMemberId() => $_clearField(3);

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

  @$pb.TagNumber(5)
  TeamCommissionPayoutStatus get status => $_getN(4);
  @$pb.TagNumber(5)
  set status(TeamCommissionPayoutStatus value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasStatus() => $_has(4);
  @$pb.TagNumber(5)
  void clearStatus() => $_clearField(5);

  /// Why the last attempt was refused, if it was. A refused payout went back
  /// to the balance and returns to PENDING.
  @$pb.TagNumber(6)
  $core.String get failureReason => $_getSZ(5);
  @$pb.TagNumber(6)
  set failureReason($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasFailureReason() => $_has(5);
  @$pb.TagNumber(6)
  void clearFailureReason() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get reason => $_getSZ(6);
  @$pb.TagNumber(7)
  set reason($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasReason() => $_has(6);
  @$pb.TagNumber(7)
  void clearReason() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get createdBy => $_getSZ(7);
  @$pb.TagNumber(8)
  set createdBy($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasCreatedBy() => $_has(7);
  @$pb.TagNumber(8)
  void clearCreatedBy() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get createdAt => $_getSZ(8);
  @$pb.TagNumber(9)
  set createdAt($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasCreatedAt() => $_has(8);
  @$pb.TagNumber(9)
  void clearCreatedAt() => $_clearField(9);
}

class TeamCommissionPayoutRequest extends $pb.GeneratedMessage {
  factory TeamCommissionPayoutRequest({
    $core.String? teamId,
    $core.String? memberId,
    $0.Money? amount,
    $core.String? idempotencyKey,
    $core.String? reason,
  }) {
    final result = TeamCommissionPayoutRequest._();
    if (teamId != null) result.teamId = teamId;
    if (memberId != null) result.memberId = memberId;
    if (amount != null) result.amount = amount;
    if (idempotencyKey != null) result.idempotencyKey = idempotencyKey;
    if (reason != null) result.reason = reason;
    return result;
  }

  TeamCommissionPayoutRequest._();

  factory TeamCommissionPayoutRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TeamCommissionPayoutRequest()..mergeFromBuffer(data, registry);
  factory TeamCommissionPayoutRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TeamCommissionPayoutRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TeamCommissionPayoutRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: TeamCommissionPayoutRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'teamId')
    ..aOS(2, _omitFieldNames ? '' : 'memberId')
    ..aOM<$0.Money>(3, _omitFieldNames ? '' : 'amount',
        subBuilder: $0.Money.$_createMessage)
    ..aOS(4, _omitFieldNames ? '' : 'idempotencyKey')
    ..aOS(5, _omitFieldNames ? '' : 'reason')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TeamCommissionPayoutRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TeamCommissionPayoutRequest copyWith(
          void Function(TeamCommissionPayoutRequest) updates) =>
      super.copyWith(
              (message) => updates(message as TeamCommissionPayoutRequest))
          as TeamCommissionPayoutRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use TeamCommissionPayoutRequest() / TeamCommissionPayoutRequest.new instead')
  static TeamCommissionPayoutRequest create() =>
      TeamCommissionPayoutRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      TeamCommissionPayoutRequest._();
  @$core.override
  TeamCommissionPayoutRequest createEmptyInstance() =>
      TeamCommissionPayoutRequest._();
  @$core.pragma('dart2js:noInline')
  static TeamCommissionPayoutRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TeamCommissionPayoutRequest>(
          TeamCommissionPayoutRequest.$_createMessage);
  static TeamCommissionPayoutRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get teamId => $_getSZ(0);
  @$pb.TagNumber(1)
  set teamId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTeamId() => $_has(0);
  @$pb.TagNumber(1)
  void clearTeamId() => $_clearField(1);

  /// An active member of the team. The money goes to that member's own
  /// verified mobile money; nobody names where it goes.
  @$pb.TagNumber(2)
  $core.String get memberId => $_getSZ(1);
  @$pb.TagNumber(2)
  set memberId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMemberId() => $_has(1);
  @$pb.TagNumber(2)
  void clearMemberId() => $_clearField(2);

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

  /// Retrying with the same key resumes the same payout and never pays twice.
  @$pb.TagNumber(4)
  $core.String get idempotencyKey => $_getSZ(3);
  @$pb.TagNumber(4)
  set idempotencyKey($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasIdempotencyKey() => $_has(3);
  @$pb.TagNumber(4)
  void clearIdempotencyKey() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get reason => $_getSZ(4);
  @$pb.TagNumber(5)
  set reason($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasReason() => $_has(4);
  @$pb.TagNumber(5)
  void clearReason() => $_clearField(5);
}

class TeamCommissionPayoutResponse extends $pb.GeneratedMessage {
  factory TeamCommissionPayoutResponse({
    TeamCommissionPayoutObject? data,
  }) {
    final result = TeamCommissionPayoutResponse._();
    if (data != null) result.data = data;
    return result;
  }

  TeamCommissionPayoutResponse._();

  factory TeamCommissionPayoutResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TeamCommissionPayoutResponse()..mergeFromBuffer(data, registry);
  factory TeamCommissionPayoutResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TeamCommissionPayoutResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TeamCommissionPayoutResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: TeamCommissionPayoutResponse.$_createMessage)
    ..aOM<TeamCommissionPayoutObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: TeamCommissionPayoutObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TeamCommissionPayoutResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TeamCommissionPayoutResponse copyWith(
          void Function(TeamCommissionPayoutResponse) updates) =>
      super.copyWith(
              (message) => updates(message as TeamCommissionPayoutResponse))
          as TeamCommissionPayoutResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use TeamCommissionPayoutResponse() / TeamCommissionPayoutResponse.new instead')
  static TeamCommissionPayoutResponse create() =>
      TeamCommissionPayoutResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      TeamCommissionPayoutResponse._();
  @$core.override
  TeamCommissionPayoutResponse createEmptyInstance() =>
      TeamCommissionPayoutResponse._();
  @$core.pragma('dart2js:noInline')
  static TeamCommissionPayoutResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TeamCommissionPayoutResponse>(
          TeamCommissionPayoutResponse.$_createMessage);
  static TeamCommissionPayoutResponse? _defaultInstance;

  @$pb.TagNumber(1)
  TeamCommissionPayoutObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(TeamCommissionPayoutObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  TeamCommissionPayoutObject ensureData() => $_ensure(0);
}

class TeamCommissionPayoutSearchRequest extends $pb.GeneratedMessage {
  factory TeamCommissionPayoutSearchRequest({
    $core.String? teamId,
    $2.PageCursor? cursor,
  }) {
    final result = TeamCommissionPayoutSearchRequest._();
    if (teamId != null) result.teamId = teamId;
    if (cursor != null) result.cursor = cursor;
    return result;
  }

  TeamCommissionPayoutSearchRequest._();

  factory TeamCommissionPayoutSearchRequest.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TeamCommissionPayoutSearchRequest()..mergeFromBuffer(data, registry);
  factory TeamCommissionPayoutSearchRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TeamCommissionPayoutSearchRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TeamCommissionPayoutSearchRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: TeamCommissionPayoutSearchRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'teamId')
    ..aOM<$2.PageCursor>(2, _omitFieldNames ? '' : 'cursor',
        subBuilder: $2.PageCursor.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TeamCommissionPayoutSearchRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TeamCommissionPayoutSearchRequest copyWith(
          void Function(TeamCommissionPayoutSearchRequest) updates) =>
      super.copyWith((message) =>
              updates(message as TeamCommissionPayoutSearchRequest))
          as TeamCommissionPayoutSearchRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use TeamCommissionPayoutSearchRequest() / TeamCommissionPayoutSearchRequest.new instead')
  static TeamCommissionPayoutSearchRequest create() =>
      TeamCommissionPayoutSearchRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      TeamCommissionPayoutSearchRequest._();
  @$core.override
  TeamCommissionPayoutSearchRequest createEmptyInstance() =>
      TeamCommissionPayoutSearchRequest._();
  @$core.pragma('dart2js:noInline')
  static TeamCommissionPayoutSearchRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TeamCommissionPayoutSearchRequest>(
          TeamCommissionPayoutSearchRequest.$_createMessage);
  static TeamCommissionPayoutSearchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get teamId => $_getSZ(0);
  @$pb.TagNumber(1)
  set teamId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTeamId() => $_has(0);
  @$pb.TagNumber(1)
  void clearTeamId() => $_clearField(1);

  @$pb.TagNumber(2)
  $2.PageCursor get cursor => $_getN(1);
  @$pb.TagNumber(2)
  set cursor($2.PageCursor value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasCursor() => $_has(1);
  @$pb.TagNumber(2)
  void clearCursor() => $_clearField(2);
  @$pb.TagNumber(2)
  $2.PageCursor ensureCursor() => $_ensure(1);
}

class TeamCommissionPayoutSearchResponse extends $pb.GeneratedMessage {
  factory TeamCommissionPayoutSearchResponse({
    $core.Iterable<TeamCommissionPayoutObject>? data,
  }) {
    final result = TeamCommissionPayoutSearchResponse._();
    if (data != null) result.data.addAll(data);
    return result;
  }

  TeamCommissionPayoutSearchResponse._();

  factory TeamCommissionPayoutSearchResponse.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TeamCommissionPayoutSearchResponse()..mergeFromBuffer(data, registry);
  factory TeamCommissionPayoutSearchResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TeamCommissionPayoutSearchResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TeamCommissionPayoutSearchResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: TeamCommissionPayoutSearchResponse.$_createMessage)
    ..pPM<TeamCommissionPayoutObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: TeamCommissionPayoutObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TeamCommissionPayoutSearchResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TeamCommissionPayoutSearchResponse copyWith(
          void Function(TeamCommissionPayoutSearchResponse) updates) =>
      super.copyWith((message) =>
              updates(message as TeamCommissionPayoutSearchResponse))
          as TeamCommissionPayoutSearchResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use TeamCommissionPayoutSearchResponse() / TeamCommissionPayoutSearchResponse.new instead')
  static TeamCommissionPayoutSearchResponse create() =>
      TeamCommissionPayoutSearchResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      TeamCommissionPayoutSearchResponse._();
  @$core.override
  TeamCommissionPayoutSearchResponse createEmptyInstance() =>
      TeamCommissionPayoutSearchResponse._();
  @$core.pragma('dart2js:noInline')
  static TeamCommissionPayoutSearchResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TeamCommissionPayoutSearchResponse>(
          TeamCommissionPayoutSearchResponse.$_createMessage);
  static TeamCommissionPayoutSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<TeamCommissionPayoutObject> get data => $_getList(0);
}

class LoanProductSaveRequest extends $pb.GeneratedMessage {
  factory LoanProductSaveRequest({
    LoanProductObject? data,
  }) {
    final result = LoanProductSaveRequest._();
    if (data != null) result.data = data;
    return result;
  }

  LoanProductSaveRequest._();

  factory LoanProductSaveRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanProductSaveRequest()..mergeFromBuffer(data, registry);
  factory LoanProductSaveRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanProductSaveRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LoanProductSaveRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: LoanProductSaveRequest.$_createMessage)
    ..aOM<LoanProductObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: LoanProductObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanProductSaveRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanProductSaveRequest copyWith(
          void Function(LoanProductSaveRequest) updates) =>
      super.copyWith((message) => updates(message as LoanProductSaveRequest))
          as LoanProductSaveRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use LoanProductSaveRequest() / LoanProductSaveRequest.new instead')
  static LoanProductSaveRequest create() => LoanProductSaveRequest._();
  static $pb.GeneratedMessage $_createMessage() => LoanProductSaveRequest._();
  @$core.override
  LoanProductSaveRequest createEmptyInstance() => LoanProductSaveRequest._();
  @$core.pragma('dart2js:noInline')
  static LoanProductSaveRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LoanProductSaveRequest>(
          LoanProductSaveRequest.$_createMessage);
  static LoanProductSaveRequest? _defaultInstance;

  @$pb.TagNumber(1)
  LoanProductObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(LoanProductObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  LoanProductObject ensureData() => $_ensure(0);
}

class LoanProductSaveResponse extends $pb.GeneratedMessage {
  factory LoanProductSaveResponse({
    LoanProductObject? data,
  }) {
    final result = LoanProductSaveResponse._();
    if (data != null) result.data = data;
    return result;
  }

  LoanProductSaveResponse._();

  factory LoanProductSaveResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanProductSaveResponse()..mergeFromBuffer(data, registry);
  factory LoanProductSaveResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanProductSaveResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LoanProductSaveResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: LoanProductSaveResponse.$_createMessage)
    ..aOM<LoanProductObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: LoanProductObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanProductSaveResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanProductSaveResponse copyWith(
          void Function(LoanProductSaveResponse) updates) =>
      super.copyWith((message) => updates(message as LoanProductSaveResponse))
          as LoanProductSaveResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use LoanProductSaveResponse() / LoanProductSaveResponse.new instead')
  static LoanProductSaveResponse create() => LoanProductSaveResponse._();
  static $pb.GeneratedMessage $_createMessage() => LoanProductSaveResponse._();
  @$core.override
  LoanProductSaveResponse createEmptyInstance() => LoanProductSaveResponse._();
  @$core.pragma('dart2js:noInline')
  static LoanProductSaveResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LoanProductSaveResponse>(
          LoanProductSaveResponse.$_createMessage);
  static LoanProductSaveResponse? _defaultInstance;

  @$pb.TagNumber(1)
  LoanProductObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(LoanProductObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  LoanProductObject ensureData() => $_ensure(0);
}

class LoanProductGetRequest extends $pb.GeneratedMessage {
  factory LoanProductGetRequest({
    $core.String? id,
  }) {
    final result = LoanProductGetRequest._();
    if (id != null) result.id = id;
    return result;
  }

  LoanProductGetRequest._();

  factory LoanProductGetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanProductGetRequest()..mergeFromBuffer(data, registry);
  factory LoanProductGetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanProductGetRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LoanProductGetRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: LoanProductGetRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanProductGetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanProductGetRequest copyWith(
          void Function(LoanProductGetRequest) updates) =>
      super.copyWith((message) => updates(message as LoanProductGetRequest))
          as LoanProductGetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use LoanProductGetRequest() / LoanProductGetRequest.new instead')
  static LoanProductGetRequest create() => LoanProductGetRequest._();
  static $pb.GeneratedMessage $_createMessage() => LoanProductGetRequest._();
  @$core.override
  LoanProductGetRequest createEmptyInstance() => LoanProductGetRequest._();
  @$core.pragma('dart2js:noInline')
  static LoanProductGetRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LoanProductGetRequest>(
          LoanProductGetRequest.$_createMessage);
  static LoanProductGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class LoanProductGetResponse extends $pb.GeneratedMessage {
  factory LoanProductGetResponse({
    LoanProductObject? data,
  }) {
    final result = LoanProductGetResponse._();
    if (data != null) result.data = data;
    return result;
  }

  LoanProductGetResponse._();

  factory LoanProductGetResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanProductGetResponse()..mergeFromBuffer(data, registry);
  factory LoanProductGetResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanProductGetResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LoanProductGetResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: LoanProductGetResponse.$_createMessage)
    ..aOM<LoanProductObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: LoanProductObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanProductGetResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanProductGetResponse copyWith(
          void Function(LoanProductGetResponse) updates) =>
      super.copyWith((message) => updates(message as LoanProductGetResponse))
          as LoanProductGetResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use LoanProductGetResponse() / LoanProductGetResponse.new instead')
  static LoanProductGetResponse create() => LoanProductGetResponse._();
  static $pb.GeneratedMessage $_createMessage() => LoanProductGetResponse._();
  @$core.override
  LoanProductGetResponse createEmptyInstance() => LoanProductGetResponse._();
  @$core.pragma('dart2js:noInline')
  static LoanProductGetResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LoanProductGetResponse>(
          LoanProductGetResponse.$_createMessage);
  static LoanProductGetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  LoanProductObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(LoanProductObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  LoanProductObject ensureData() => $_ensure(0);
}

class LoanProductSearchRequest extends $pb.GeneratedMessage {
  factory LoanProductSearchRequest({
    $core.String? query,
    $core.String? organizationId,
    LoanProductType? productType,
    $2.PageCursor? cursor,
  }) {
    final result = LoanProductSearchRequest._();
    if (query != null) result.query = query;
    if (organizationId != null) result.organizationId = organizationId;
    if (productType != null) result.productType = productType;
    if (cursor != null) result.cursor = cursor;
    return result;
  }

  LoanProductSearchRequest._();

  factory LoanProductSearchRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanProductSearchRequest()..mergeFromBuffer(data, registry);
  factory LoanProductSearchRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanProductSearchRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LoanProductSearchRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: LoanProductSearchRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'query')
    ..aOS(2, _omitFieldNames ? '' : 'organizationId')
    ..aE<LoanProductType>(3, _omitFieldNames ? '' : 'productType',
        enumValues: LoanProductType.values)
    ..aOM<$2.PageCursor>(4, _omitFieldNames ? '' : 'cursor',
        subBuilder: $2.PageCursor.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanProductSearchRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanProductSearchRequest copyWith(
          void Function(LoanProductSearchRequest) updates) =>
      super.copyWith((message) => updates(message as LoanProductSearchRequest))
          as LoanProductSearchRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use LoanProductSearchRequest() / LoanProductSearchRequest.new instead')
  static LoanProductSearchRequest create() => LoanProductSearchRequest._();
  static $pb.GeneratedMessage $_createMessage() => LoanProductSearchRequest._();
  @$core.override
  LoanProductSearchRequest createEmptyInstance() =>
      LoanProductSearchRequest._();
  @$core.pragma('dart2js:noInline')
  static LoanProductSearchRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LoanProductSearchRequest>(
          LoanProductSearchRequest.$_createMessage);
  static LoanProductSearchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get query => $_getSZ(0);
  @$pb.TagNumber(1)
  set query($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasQuery() => $_has(0);
  @$pb.TagNumber(1)
  void clearQuery() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get organizationId => $_getSZ(1);
  @$pb.TagNumber(2)
  set organizationId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasOrganizationId() => $_has(1);
  @$pb.TagNumber(2)
  void clearOrganizationId() => $_clearField(2);

  @$pb.TagNumber(3)
  LoanProductType get productType => $_getN(2);
  @$pb.TagNumber(3)
  set productType(LoanProductType value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasProductType() => $_has(2);
  @$pb.TagNumber(3)
  void clearProductType() => $_clearField(3);

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

class LoanProductSearchResponse extends $pb.GeneratedMessage {
  factory LoanProductSearchResponse({
    $core.Iterable<LoanProductObject>? data,
  }) {
    final result = LoanProductSearchResponse._();
    if (data != null) result.data.addAll(data);
    return result;
  }

  LoanProductSearchResponse._();

  factory LoanProductSearchResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanProductSearchResponse()..mergeFromBuffer(data, registry);
  factory LoanProductSearchResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanProductSearchResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LoanProductSearchResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: LoanProductSearchResponse.$_createMessage)
    ..pPM<LoanProductObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: LoanProductObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanProductSearchResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanProductSearchResponse copyWith(
          void Function(LoanProductSearchResponse) updates) =>
      super.copyWith((message) => updates(message as LoanProductSearchResponse))
          as LoanProductSearchResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use LoanProductSearchResponse() / LoanProductSearchResponse.new instead')
  static LoanProductSearchResponse create() => LoanProductSearchResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      LoanProductSearchResponse._();
  @$core.override
  LoanProductSearchResponse createEmptyInstance() =>
      LoanProductSearchResponse._();
  @$core.pragma('dart2js:noInline')
  static LoanProductSearchResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LoanProductSearchResponse>(
          LoanProductSearchResponse.$_createMessage);
  static LoanProductSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<LoanProductObject> get data => $_getList(0);
}

class LoanRequestSaveRequest extends $pb.GeneratedMessage {
  factory LoanRequestSaveRequest({
    LoanRequestObject? data,
  }) {
    final result = LoanRequestSaveRequest._();
    if (data != null) result.data = data;
    return result;
  }

  LoanRequestSaveRequest._();

  factory LoanRequestSaveRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanRequestSaveRequest()..mergeFromBuffer(data, registry);
  factory LoanRequestSaveRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanRequestSaveRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LoanRequestSaveRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: LoanRequestSaveRequest.$_createMessage)
    ..aOM<LoanRequestObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: LoanRequestObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanRequestSaveRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanRequestSaveRequest copyWith(
          void Function(LoanRequestSaveRequest) updates) =>
      super.copyWith((message) => updates(message as LoanRequestSaveRequest))
          as LoanRequestSaveRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use LoanRequestSaveRequest() / LoanRequestSaveRequest.new instead')
  static LoanRequestSaveRequest create() => LoanRequestSaveRequest._();
  static $pb.GeneratedMessage $_createMessage() => LoanRequestSaveRequest._();
  @$core.override
  LoanRequestSaveRequest createEmptyInstance() => LoanRequestSaveRequest._();
  @$core.pragma('dart2js:noInline')
  static LoanRequestSaveRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LoanRequestSaveRequest>(
          LoanRequestSaveRequest.$_createMessage);
  static LoanRequestSaveRequest? _defaultInstance;

  @$pb.TagNumber(1)
  LoanRequestObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(LoanRequestObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  LoanRequestObject ensureData() => $_ensure(0);
}

class LoanRequestSaveResponse extends $pb.GeneratedMessage {
  factory LoanRequestSaveResponse({
    LoanRequestObject? data,
  }) {
    final result = LoanRequestSaveResponse._();
    if (data != null) result.data = data;
    return result;
  }

  LoanRequestSaveResponse._();

  factory LoanRequestSaveResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanRequestSaveResponse()..mergeFromBuffer(data, registry);
  factory LoanRequestSaveResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanRequestSaveResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LoanRequestSaveResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: LoanRequestSaveResponse.$_createMessage)
    ..aOM<LoanRequestObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: LoanRequestObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanRequestSaveResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanRequestSaveResponse copyWith(
          void Function(LoanRequestSaveResponse) updates) =>
      super.copyWith((message) => updates(message as LoanRequestSaveResponse))
          as LoanRequestSaveResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use LoanRequestSaveResponse() / LoanRequestSaveResponse.new instead')
  static LoanRequestSaveResponse create() => LoanRequestSaveResponse._();
  static $pb.GeneratedMessage $_createMessage() => LoanRequestSaveResponse._();
  @$core.override
  LoanRequestSaveResponse createEmptyInstance() => LoanRequestSaveResponse._();
  @$core.pragma('dart2js:noInline')
  static LoanRequestSaveResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LoanRequestSaveResponse>(
          LoanRequestSaveResponse.$_createMessage);
  static LoanRequestSaveResponse? _defaultInstance;

  @$pb.TagNumber(1)
  LoanRequestObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(LoanRequestObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  LoanRequestObject ensureData() => $_ensure(0);
}

class LoanRequestGetRequest extends $pb.GeneratedMessage {
  factory LoanRequestGetRequest({
    $core.String? id,
  }) {
    final result = LoanRequestGetRequest._();
    if (id != null) result.id = id;
    return result;
  }

  LoanRequestGetRequest._();

  factory LoanRequestGetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanRequestGetRequest()..mergeFromBuffer(data, registry);
  factory LoanRequestGetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanRequestGetRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LoanRequestGetRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: LoanRequestGetRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanRequestGetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanRequestGetRequest copyWith(
          void Function(LoanRequestGetRequest) updates) =>
      super.copyWith((message) => updates(message as LoanRequestGetRequest))
          as LoanRequestGetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use LoanRequestGetRequest() / LoanRequestGetRequest.new instead')
  static LoanRequestGetRequest create() => LoanRequestGetRequest._();
  static $pb.GeneratedMessage $_createMessage() => LoanRequestGetRequest._();
  @$core.override
  LoanRequestGetRequest createEmptyInstance() => LoanRequestGetRequest._();
  @$core.pragma('dart2js:noInline')
  static LoanRequestGetRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LoanRequestGetRequest>(
          LoanRequestGetRequest.$_createMessage);
  static LoanRequestGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class LoanRequestGetResponse extends $pb.GeneratedMessage {
  factory LoanRequestGetResponse({
    LoanRequestObject? data,
  }) {
    final result = LoanRequestGetResponse._();
    if (data != null) result.data = data;
    return result;
  }

  LoanRequestGetResponse._();

  factory LoanRequestGetResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanRequestGetResponse()..mergeFromBuffer(data, registry);
  factory LoanRequestGetResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanRequestGetResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LoanRequestGetResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: LoanRequestGetResponse.$_createMessage)
    ..aOM<LoanRequestObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: LoanRequestObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanRequestGetResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanRequestGetResponse copyWith(
          void Function(LoanRequestGetResponse) updates) =>
      super.copyWith((message) => updates(message as LoanRequestGetResponse))
          as LoanRequestGetResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use LoanRequestGetResponse() / LoanRequestGetResponse.new instead')
  static LoanRequestGetResponse create() => LoanRequestGetResponse._();
  static $pb.GeneratedMessage $_createMessage() => LoanRequestGetResponse._();
  @$core.override
  LoanRequestGetResponse createEmptyInstance() => LoanRequestGetResponse._();
  @$core.pragma('dart2js:noInline')
  static LoanRequestGetResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LoanRequestGetResponse>(
          LoanRequestGetResponse.$_createMessage);
  static LoanRequestGetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  LoanRequestObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(LoanRequestObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  LoanRequestObject ensureData() => $_ensure(0);
}

class LoanRequestSearchRequest extends $pb.GeneratedMessage {
  factory LoanRequestSearchRequest({
    $core.String? query,
    $core.String? clientId,
    $core.String? agentId,
    $core.String? branchId,
    $core.String? organizationId,
    LoanRequestStatus? status,
    $core.String? sourceService,
    $2.PageCursor? cursor,
  }) {
    final result = LoanRequestSearchRequest._();
    if (query != null) result.query = query;
    if (clientId != null) result.clientId = clientId;
    if (agentId != null) result.agentId = agentId;
    if (branchId != null) result.branchId = branchId;
    if (organizationId != null) result.organizationId = organizationId;
    if (status != null) result.status = status;
    if (sourceService != null) result.sourceService = sourceService;
    if (cursor != null) result.cursor = cursor;
    return result;
  }

  LoanRequestSearchRequest._();

  factory LoanRequestSearchRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanRequestSearchRequest()..mergeFromBuffer(data, registry);
  factory LoanRequestSearchRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanRequestSearchRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LoanRequestSearchRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: LoanRequestSearchRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'query')
    ..aOS(2, _omitFieldNames ? '' : 'clientId')
    ..aOS(3, _omitFieldNames ? '' : 'agentId')
    ..aOS(4, _omitFieldNames ? '' : 'branchId')
    ..aOS(5, _omitFieldNames ? '' : 'organizationId')
    ..aE<LoanRequestStatus>(6, _omitFieldNames ? '' : 'status',
        enumValues: LoanRequestStatus.values)
    ..aOS(7, _omitFieldNames ? '' : 'sourceService')
    ..aOM<$2.PageCursor>(8, _omitFieldNames ? '' : 'cursor',
        subBuilder: $2.PageCursor.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanRequestSearchRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanRequestSearchRequest copyWith(
          void Function(LoanRequestSearchRequest) updates) =>
      super.copyWith((message) => updates(message as LoanRequestSearchRequest))
          as LoanRequestSearchRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use LoanRequestSearchRequest() / LoanRequestSearchRequest.new instead')
  static LoanRequestSearchRequest create() => LoanRequestSearchRequest._();
  static $pb.GeneratedMessage $_createMessage() => LoanRequestSearchRequest._();
  @$core.override
  LoanRequestSearchRequest createEmptyInstance() =>
      LoanRequestSearchRequest._();
  @$core.pragma('dart2js:noInline')
  static LoanRequestSearchRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LoanRequestSearchRequest>(
          LoanRequestSearchRequest.$_createMessage);
  static LoanRequestSearchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get query => $_getSZ(0);
  @$pb.TagNumber(1)
  set query($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasQuery() => $_has(0);
  @$pb.TagNumber(1)
  void clearQuery() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get clientId => $_getSZ(1);
  @$pb.TagNumber(2)
  set clientId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasClientId() => $_has(1);
  @$pb.TagNumber(2)
  void clearClientId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get agentId => $_getSZ(2);
  @$pb.TagNumber(3)
  set agentId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAgentId() => $_has(2);
  @$pb.TagNumber(3)
  void clearAgentId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get branchId => $_getSZ(3);
  @$pb.TagNumber(4)
  set branchId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasBranchId() => $_has(3);
  @$pb.TagNumber(4)
  void clearBranchId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get organizationId => $_getSZ(4);
  @$pb.TagNumber(5)
  set organizationId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasOrganizationId() => $_has(4);
  @$pb.TagNumber(5)
  void clearOrganizationId() => $_clearField(5);

  @$pb.TagNumber(6)
  LoanRequestStatus get status => $_getN(5);
  @$pb.TagNumber(6)
  set status(LoanRequestStatus value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasStatus() => $_has(5);
  @$pb.TagNumber(6)
  void clearStatus() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get sourceService => $_getSZ(6);
  @$pb.TagNumber(7)
  set sourceService($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasSourceService() => $_has(6);
  @$pb.TagNumber(7)
  void clearSourceService() => $_clearField(7);

  @$pb.TagNumber(8)
  $2.PageCursor get cursor => $_getN(7);
  @$pb.TagNumber(8)
  set cursor($2.PageCursor value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasCursor() => $_has(7);
  @$pb.TagNumber(8)
  void clearCursor() => $_clearField(8);
  @$pb.TagNumber(8)
  $2.PageCursor ensureCursor() => $_ensure(7);
}

class LoanRequestSearchResponse extends $pb.GeneratedMessage {
  factory LoanRequestSearchResponse({
    $core.Iterable<LoanRequestObject>? data,
  }) {
    final result = LoanRequestSearchResponse._();
    if (data != null) result.data.addAll(data);
    return result;
  }

  LoanRequestSearchResponse._();

  factory LoanRequestSearchResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanRequestSearchResponse()..mergeFromBuffer(data, registry);
  factory LoanRequestSearchResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanRequestSearchResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LoanRequestSearchResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: LoanRequestSearchResponse.$_createMessage)
    ..pPM<LoanRequestObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: LoanRequestObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanRequestSearchResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanRequestSearchResponse copyWith(
          void Function(LoanRequestSearchResponse) updates) =>
      super.copyWith((message) => updates(message as LoanRequestSearchResponse))
          as LoanRequestSearchResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use LoanRequestSearchResponse() / LoanRequestSearchResponse.new instead')
  static LoanRequestSearchResponse create() => LoanRequestSearchResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      LoanRequestSearchResponse._();
  @$core.override
  LoanRequestSearchResponse createEmptyInstance() =>
      LoanRequestSearchResponse._();
  @$core.pragma('dart2js:noInline')
  static LoanRequestSearchResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LoanRequestSearchResponse>(
          LoanRequestSearchResponse.$_createMessage);
  static LoanRequestSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<LoanRequestObject> get data => $_getList(0);
}

class LoanRequestApproveRequest extends $pb.GeneratedMessage {
  factory LoanRequestApproveRequest({
    $core.String? id,
  }) {
    final result = LoanRequestApproveRequest._();
    if (id != null) result.id = id;
    return result;
  }

  LoanRequestApproveRequest._();

  factory LoanRequestApproveRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanRequestApproveRequest()..mergeFromBuffer(data, registry);
  factory LoanRequestApproveRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanRequestApproveRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LoanRequestApproveRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: LoanRequestApproveRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanRequestApproveRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanRequestApproveRequest copyWith(
          void Function(LoanRequestApproveRequest) updates) =>
      super.copyWith((message) => updates(message as LoanRequestApproveRequest))
          as LoanRequestApproveRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use LoanRequestApproveRequest() / LoanRequestApproveRequest.new instead')
  static LoanRequestApproveRequest create() => LoanRequestApproveRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      LoanRequestApproveRequest._();
  @$core.override
  LoanRequestApproveRequest createEmptyInstance() =>
      LoanRequestApproveRequest._();
  @$core.pragma('dart2js:noInline')
  static LoanRequestApproveRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LoanRequestApproveRequest>(
          LoanRequestApproveRequest.$_createMessage);
  static LoanRequestApproveRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class LoanRequestApproveResponse extends $pb.GeneratedMessage {
  factory LoanRequestApproveResponse({
    LoanRequestObject? data,
  }) {
    final result = LoanRequestApproveResponse._();
    if (data != null) result.data = data;
    return result;
  }

  LoanRequestApproveResponse._();

  factory LoanRequestApproveResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanRequestApproveResponse()..mergeFromBuffer(data, registry);
  factory LoanRequestApproveResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanRequestApproveResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LoanRequestApproveResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: LoanRequestApproveResponse.$_createMessage)
    ..aOM<LoanRequestObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: LoanRequestObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanRequestApproveResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanRequestApproveResponse copyWith(
          void Function(LoanRequestApproveResponse) updates) =>
      super.copyWith(
              (message) => updates(message as LoanRequestApproveResponse))
          as LoanRequestApproveResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use LoanRequestApproveResponse() / LoanRequestApproveResponse.new instead')
  static LoanRequestApproveResponse create() => LoanRequestApproveResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      LoanRequestApproveResponse._();
  @$core.override
  LoanRequestApproveResponse createEmptyInstance() =>
      LoanRequestApproveResponse._();
  @$core.pragma('dart2js:noInline')
  static LoanRequestApproveResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LoanRequestApproveResponse>(
          LoanRequestApproveResponse.$_createMessage);
  static LoanRequestApproveResponse? _defaultInstance;

  @$pb.TagNumber(1)
  LoanRequestObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(LoanRequestObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  LoanRequestObject ensureData() => $_ensure(0);
}

class LoanRequestRejectRequest extends $pb.GeneratedMessage {
  factory LoanRequestRejectRequest({
    $core.String? id,
    $core.String? reason,
  }) {
    final result = LoanRequestRejectRequest._();
    if (id != null) result.id = id;
    if (reason != null) result.reason = reason;
    return result;
  }

  LoanRequestRejectRequest._();

  factory LoanRequestRejectRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanRequestRejectRequest()..mergeFromBuffer(data, registry);
  factory LoanRequestRejectRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanRequestRejectRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LoanRequestRejectRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: LoanRequestRejectRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'reason')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanRequestRejectRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanRequestRejectRequest copyWith(
          void Function(LoanRequestRejectRequest) updates) =>
      super.copyWith((message) => updates(message as LoanRequestRejectRequest))
          as LoanRequestRejectRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use LoanRequestRejectRequest() / LoanRequestRejectRequest.new instead')
  static LoanRequestRejectRequest create() => LoanRequestRejectRequest._();
  static $pb.GeneratedMessage $_createMessage() => LoanRequestRejectRequest._();
  @$core.override
  LoanRequestRejectRequest createEmptyInstance() =>
      LoanRequestRejectRequest._();
  @$core.pragma('dart2js:noInline')
  static LoanRequestRejectRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LoanRequestRejectRequest>(
          LoanRequestRejectRequest.$_createMessage);
  static LoanRequestRejectRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get reason => $_getSZ(1);
  @$pb.TagNumber(2)
  set reason($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasReason() => $_has(1);
  @$pb.TagNumber(2)
  void clearReason() => $_clearField(2);
}

class LoanRequestRejectResponse extends $pb.GeneratedMessage {
  factory LoanRequestRejectResponse({
    LoanRequestObject? data,
  }) {
    final result = LoanRequestRejectResponse._();
    if (data != null) result.data = data;
    return result;
  }

  LoanRequestRejectResponse._();

  factory LoanRequestRejectResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanRequestRejectResponse()..mergeFromBuffer(data, registry);
  factory LoanRequestRejectResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanRequestRejectResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LoanRequestRejectResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: LoanRequestRejectResponse.$_createMessage)
    ..aOM<LoanRequestObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: LoanRequestObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanRequestRejectResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanRequestRejectResponse copyWith(
          void Function(LoanRequestRejectResponse) updates) =>
      super.copyWith((message) => updates(message as LoanRequestRejectResponse))
          as LoanRequestRejectResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use LoanRequestRejectResponse() / LoanRequestRejectResponse.new instead')
  static LoanRequestRejectResponse create() => LoanRequestRejectResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      LoanRequestRejectResponse._();
  @$core.override
  LoanRequestRejectResponse createEmptyInstance() =>
      LoanRequestRejectResponse._();
  @$core.pragma('dart2js:noInline')
  static LoanRequestRejectResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LoanRequestRejectResponse>(
          LoanRequestRejectResponse.$_createMessage);
  static LoanRequestRejectResponse? _defaultInstance;

  @$pb.TagNumber(1)
  LoanRequestObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(LoanRequestObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  LoanRequestObject ensureData() => $_ensure(0);
}

class LoanRequestCancelRequest extends $pb.GeneratedMessage {
  factory LoanRequestCancelRequest({
    $core.String? id,
    $core.String? reason,
  }) {
    final result = LoanRequestCancelRequest._();
    if (id != null) result.id = id;
    if (reason != null) result.reason = reason;
    return result;
  }

  LoanRequestCancelRequest._();

  factory LoanRequestCancelRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanRequestCancelRequest()..mergeFromBuffer(data, registry);
  factory LoanRequestCancelRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanRequestCancelRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LoanRequestCancelRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: LoanRequestCancelRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'reason')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanRequestCancelRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanRequestCancelRequest copyWith(
          void Function(LoanRequestCancelRequest) updates) =>
      super.copyWith((message) => updates(message as LoanRequestCancelRequest))
          as LoanRequestCancelRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use LoanRequestCancelRequest() / LoanRequestCancelRequest.new instead')
  static LoanRequestCancelRequest create() => LoanRequestCancelRequest._();
  static $pb.GeneratedMessage $_createMessage() => LoanRequestCancelRequest._();
  @$core.override
  LoanRequestCancelRequest createEmptyInstance() =>
      LoanRequestCancelRequest._();
  @$core.pragma('dart2js:noInline')
  static LoanRequestCancelRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LoanRequestCancelRequest>(
          LoanRequestCancelRequest.$_createMessage);
  static LoanRequestCancelRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get reason => $_getSZ(1);
  @$pb.TagNumber(2)
  set reason($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasReason() => $_has(1);
  @$pb.TagNumber(2)
  void clearReason() => $_clearField(2);
}

class LoanRequestCancelResponse extends $pb.GeneratedMessage {
  factory LoanRequestCancelResponse({
    LoanRequestObject? data,
  }) {
    final result = LoanRequestCancelResponse._();
    if (data != null) result.data = data;
    return result;
  }

  LoanRequestCancelResponse._();

  factory LoanRequestCancelResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanRequestCancelResponse()..mergeFromBuffer(data, registry);
  factory LoanRequestCancelResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoanRequestCancelResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LoanRequestCancelResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: LoanRequestCancelResponse.$_createMessage)
    ..aOM<LoanRequestObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: LoanRequestObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanRequestCancelResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoanRequestCancelResponse copyWith(
          void Function(LoanRequestCancelResponse) updates) =>
      super.copyWith((message) => updates(message as LoanRequestCancelResponse))
          as LoanRequestCancelResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use LoanRequestCancelResponse() / LoanRequestCancelResponse.new instead')
  static LoanRequestCancelResponse create() => LoanRequestCancelResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      LoanRequestCancelResponse._();
  @$core.override
  LoanRequestCancelResponse createEmptyInstance() =>
      LoanRequestCancelResponse._();
  @$core.pragma('dart2js:noInline')
  static LoanRequestCancelResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LoanRequestCancelResponse>(
          LoanRequestCancelResponse.$_createMessage);
  static LoanRequestCancelResponse? _defaultInstance;

  @$pb.TagNumber(1)
  LoanRequestObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(LoanRequestObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  LoanRequestObject ensureData() => $_ensure(0);
}

class ClientProductAccessSaveRequest extends $pb.GeneratedMessage {
  factory ClientProductAccessSaveRequest({
    ClientProductAccessObject? data,
  }) {
    final result = ClientProductAccessSaveRequest._();
    if (data != null) result.data = data;
    return result;
  }

  ClientProductAccessSaveRequest._();

  factory ClientProductAccessSaveRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientProductAccessSaveRequest()..mergeFromBuffer(data, registry);
  factory ClientProductAccessSaveRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientProductAccessSaveRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClientProductAccessSaveRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: ClientProductAccessSaveRequest.$_createMessage)
    ..aOM<ClientProductAccessObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: ClientProductAccessObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientProductAccessSaveRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientProductAccessSaveRequest copyWith(
          void Function(ClientProductAccessSaveRequest) updates) =>
      super.copyWith(
              (message) => updates(message as ClientProductAccessSaveRequest))
          as ClientProductAccessSaveRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ClientProductAccessSaveRequest() / ClientProductAccessSaveRequest.new instead')
  static ClientProductAccessSaveRequest create() =>
      ClientProductAccessSaveRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      ClientProductAccessSaveRequest._();
  @$core.override
  ClientProductAccessSaveRequest createEmptyInstance() =>
      ClientProductAccessSaveRequest._();
  @$core.pragma('dart2js:noInline')
  static ClientProductAccessSaveRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ClientProductAccessSaveRequest>(
          ClientProductAccessSaveRequest.$_createMessage);
  static ClientProductAccessSaveRequest? _defaultInstance;

  @$pb.TagNumber(1)
  ClientProductAccessObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(ClientProductAccessObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  ClientProductAccessObject ensureData() => $_ensure(0);
}

class ClientProductAccessSaveResponse extends $pb.GeneratedMessage {
  factory ClientProductAccessSaveResponse({
    ClientProductAccessObject? data,
  }) {
    final result = ClientProductAccessSaveResponse._();
    if (data != null) result.data = data;
    return result;
  }

  ClientProductAccessSaveResponse._();

  factory ClientProductAccessSaveResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientProductAccessSaveResponse()..mergeFromBuffer(data, registry);
  factory ClientProductAccessSaveResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientProductAccessSaveResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClientProductAccessSaveResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: ClientProductAccessSaveResponse.$_createMessage)
    ..aOM<ClientProductAccessObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: ClientProductAccessObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientProductAccessSaveResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientProductAccessSaveResponse copyWith(
          void Function(ClientProductAccessSaveResponse) updates) =>
      super.copyWith(
              (message) => updates(message as ClientProductAccessSaveResponse))
          as ClientProductAccessSaveResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ClientProductAccessSaveResponse() / ClientProductAccessSaveResponse.new instead')
  static ClientProductAccessSaveResponse create() =>
      ClientProductAccessSaveResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      ClientProductAccessSaveResponse._();
  @$core.override
  ClientProductAccessSaveResponse createEmptyInstance() =>
      ClientProductAccessSaveResponse._();
  @$core.pragma('dart2js:noInline')
  static ClientProductAccessSaveResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ClientProductAccessSaveResponse>(
          ClientProductAccessSaveResponse.$_createMessage);
  static ClientProductAccessSaveResponse? _defaultInstance;

  @$pb.TagNumber(1)
  ClientProductAccessObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(ClientProductAccessObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  ClientProductAccessObject ensureData() => $_ensure(0);
}

class ClientProductAccessGetRequest extends $pb.GeneratedMessage {
  factory ClientProductAccessGetRequest({
    $core.String? id,
  }) {
    final result = ClientProductAccessGetRequest._();
    if (id != null) result.id = id;
    return result;
  }

  ClientProductAccessGetRequest._();

  factory ClientProductAccessGetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientProductAccessGetRequest()..mergeFromBuffer(data, registry);
  factory ClientProductAccessGetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientProductAccessGetRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClientProductAccessGetRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: ClientProductAccessGetRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientProductAccessGetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientProductAccessGetRequest copyWith(
          void Function(ClientProductAccessGetRequest) updates) =>
      super.copyWith(
              (message) => updates(message as ClientProductAccessGetRequest))
          as ClientProductAccessGetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ClientProductAccessGetRequest() / ClientProductAccessGetRequest.new instead')
  static ClientProductAccessGetRequest create() =>
      ClientProductAccessGetRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      ClientProductAccessGetRequest._();
  @$core.override
  ClientProductAccessGetRequest createEmptyInstance() =>
      ClientProductAccessGetRequest._();
  @$core.pragma('dart2js:noInline')
  static ClientProductAccessGetRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ClientProductAccessGetRequest>(
          ClientProductAccessGetRequest.$_createMessage);
  static ClientProductAccessGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class ClientProductAccessGetResponse extends $pb.GeneratedMessage {
  factory ClientProductAccessGetResponse({
    ClientProductAccessObject? data,
  }) {
    final result = ClientProductAccessGetResponse._();
    if (data != null) result.data = data;
    return result;
  }

  ClientProductAccessGetResponse._();

  factory ClientProductAccessGetResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientProductAccessGetResponse()..mergeFromBuffer(data, registry);
  factory ClientProductAccessGetResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientProductAccessGetResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClientProductAccessGetResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: ClientProductAccessGetResponse.$_createMessage)
    ..aOM<ClientProductAccessObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: ClientProductAccessObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientProductAccessGetResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientProductAccessGetResponse copyWith(
          void Function(ClientProductAccessGetResponse) updates) =>
      super.copyWith(
              (message) => updates(message as ClientProductAccessGetResponse))
          as ClientProductAccessGetResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ClientProductAccessGetResponse() / ClientProductAccessGetResponse.new instead')
  static ClientProductAccessGetResponse create() =>
      ClientProductAccessGetResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      ClientProductAccessGetResponse._();
  @$core.override
  ClientProductAccessGetResponse createEmptyInstance() =>
      ClientProductAccessGetResponse._();
  @$core.pragma('dart2js:noInline')
  static ClientProductAccessGetResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ClientProductAccessGetResponse>(
          ClientProductAccessGetResponse.$_createMessage);
  static ClientProductAccessGetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  ClientProductAccessObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(ClientProductAccessObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  ClientProductAccessObject ensureData() => $_ensure(0);
}

class ClientProductAccessSearchRequest extends $pb.GeneratedMessage {
  factory ClientProductAccessSearchRequest({
    $core.String? clientId,
    $core.String? productId,
    $2.PageCursor? cursor,
  }) {
    final result = ClientProductAccessSearchRequest._();
    if (clientId != null) result.clientId = clientId;
    if (productId != null) result.productId = productId;
    if (cursor != null) result.cursor = cursor;
    return result;
  }

  ClientProductAccessSearchRequest._();

  factory ClientProductAccessSearchRequest.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientProductAccessSearchRequest()..mergeFromBuffer(data, registry);
  factory ClientProductAccessSearchRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientProductAccessSearchRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClientProductAccessSearchRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: ClientProductAccessSearchRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'clientId')
    ..aOS(2, _omitFieldNames ? '' : 'productId')
    ..aOM<$2.PageCursor>(3, _omitFieldNames ? '' : 'cursor',
        subBuilder: $2.PageCursor.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientProductAccessSearchRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientProductAccessSearchRequest copyWith(
          void Function(ClientProductAccessSearchRequest) updates) =>
      super.copyWith(
              (message) => updates(message as ClientProductAccessSearchRequest))
          as ClientProductAccessSearchRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ClientProductAccessSearchRequest() / ClientProductAccessSearchRequest.new instead')
  static ClientProductAccessSearchRequest create() =>
      ClientProductAccessSearchRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      ClientProductAccessSearchRequest._();
  @$core.override
  ClientProductAccessSearchRequest createEmptyInstance() =>
      ClientProductAccessSearchRequest._();
  @$core.pragma('dart2js:noInline')
  static ClientProductAccessSearchRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ClientProductAccessSearchRequest>(
          ClientProductAccessSearchRequest.$_createMessage);
  static ClientProductAccessSearchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get clientId => $_getSZ(0);
  @$pb.TagNumber(1)
  set clientId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasClientId() => $_has(0);
  @$pb.TagNumber(1)
  void clearClientId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get productId => $_getSZ(1);
  @$pb.TagNumber(2)
  set productId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasProductId() => $_has(1);
  @$pb.TagNumber(2)
  void clearProductId() => $_clearField(2);

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
}

class ClientProductAccessSearchResponse extends $pb.GeneratedMessage {
  factory ClientProductAccessSearchResponse({
    $core.Iterable<ClientProductAccessObject>? data,
  }) {
    final result = ClientProductAccessSearchResponse._();
    if (data != null) result.data.addAll(data);
    return result;
  }

  ClientProductAccessSearchResponse._();

  factory ClientProductAccessSearchResponse.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientProductAccessSearchResponse()..mergeFromBuffer(data, registry);
  factory ClientProductAccessSearchResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientProductAccessSearchResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClientProductAccessSearchResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: ClientProductAccessSearchResponse.$_createMessage)
    ..pPM<ClientProductAccessObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: ClientProductAccessObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientProductAccessSearchResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientProductAccessSearchResponse copyWith(
          void Function(ClientProductAccessSearchResponse) updates) =>
      super.copyWith((message) =>
              updates(message as ClientProductAccessSearchResponse))
          as ClientProductAccessSearchResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ClientProductAccessSearchResponse() / ClientProductAccessSearchResponse.new instead')
  static ClientProductAccessSearchResponse create() =>
      ClientProductAccessSearchResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      ClientProductAccessSearchResponse._();
  @$core.override
  ClientProductAccessSearchResponse createEmptyInstance() =>
      ClientProductAccessSearchResponse._();
  @$core.pragma('dart2js:noInline')
  static ClientProductAccessSearchResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ClientProductAccessSearchResponse>(
          ClientProductAccessSearchResponse.$_createMessage);
  static ClientProductAccessSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<ClientProductAccessObject> get data => $_getList(0);
}

/// PortfolioSummary provides aggregate financial metrics across a filtered set of loans.
class PortfolioSummary extends $pb.GeneratedMessage {
  factory PortfolioSummary({
    $core.int? totalLoans,
    $core.int? activeLoans,
    $core.int? delinquentLoans,
    $core.int? defaultLoans,
    $core.int? paidOffLoans,
    $core.int? writtenOffLoans,
    $0.Money? totalDisbursed,
    $0.Money? totalOutstanding,
    $0.Money? totalCollected,
    $0.Money? principalOutstanding,
    $0.Money? interestOutstanding,
    $0.Money? feesOutstanding,
    $0.Money? penaltiesOutstanding,
    $core.String? currencyCode,
    $core.String? collectionRate,
    $core.String? par30,
    $core.int? pendingDisbursementLoans,
  }) {
    final result = PortfolioSummary._();
    if (totalLoans != null) result.totalLoans = totalLoans;
    if (activeLoans != null) result.activeLoans = activeLoans;
    if (delinquentLoans != null) result.delinquentLoans = delinquentLoans;
    if (defaultLoans != null) result.defaultLoans = defaultLoans;
    if (paidOffLoans != null) result.paidOffLoans = paidOffLoans;
    if (writtenOffLoans != null) result.writtenOffLoans = writtenOffLoans;
    if (totalDisbursed != null) result.totalDisbursed = totalDisbursed;
    if (totalOutstanding != null) result.totalOutstanding = totalOutstanding;
    if (totalCollected != null) result.totalCollected = totalCollected;
    if (principalOutstanding != null)
      result.principalOutstanding = principalOutstanding;
    if (interestOutstanding != null)
      result.interestOutstanding = interestOutstanding;
    if (feesOutstanding != null) result.feesOutstanding = feesOutstanding;
    if (penaltiesOutstanding != null)
      result.penaltiesOutstanding = penaltiesOutstanding;
    if (currencyCode != null) result.currencyCode = currencyCode;
    if (collectionRate != null) result.collectionRate = collectionRate;
    if (par30 != null) result.par30 = par30;
    if (pendingDisbursementLoans != null)
      result.pendingDisbursementLoans = pendingDisbursementLoans;
    return result;
  }

  PortfolioSummary._();

  factory PortfolioSummary.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PortfolioSummary()..mergeFromBuffer(data, registry);
  factory PortfolioSummary.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PortfolioSummary()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PortfolioSummary',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: PortfolioSummary.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'totalLoans')
    ..aI(2, _omitFieldNames ? '' : 'activeLoans')
    ..aI(3, _omitFieldNames ? '' : 'delinquentLoans')
    ..aI(4, _omitFieldNames ? '' : 'defaultLoans')
    ..aI(5, _omitFieldNames ? '' : 'paidOffLoans')
    ..aI(6, _omitFieldNames ? '' : 'writtenOffLoans')
    ..aOM<$0.Money>(7, _omitFieldNames ? '' : 'totalDisbursed',
        subBuilder: $0.Money.$_createMessage)
    ..aOM<$0.Money>(8, _omitFieldNames ? '' : 'totalOutstanding',
        subBuilder: $0.Money.$_createMessage)
    ..aOM<$0.Money>(9, _omitFieldNames ? '' : 'totalCollected',
        subBuilder: $0.Money.$_createMessage)
    ..aOM<$0.Money>(10, _omitFieldNames ? '' : 'principalOutstanding',
        subBuilder: $0.Money.$_createMessage)
    ..aOM<$0.Money>(11, _omitFieldNames ? '' : 'interestOutstanding',
        subBuilder: $0.Money.$_createMessage)
    ..aOM<$0.Money>(12, _omitFieldNames ? '' : 'feesOutstanding',
        subBuilder: $0.Money.$_createMessage)
    ..aOM<$0.Money>(13, _omitFieldNames ? '' : 'penaltiesOutstanding',
        subBuilder: $0.Money.$_createMessage)
    ..aOS(14, _omitFieldNames ? '' : 'currencyCode')
    ..aOS(15, _omitFieldNames ? '' : 'collectionRate')
    ..aOS(16, _omitFieldNames ? '' : 'par30', protoName: 'par_30')
    ..aI(17, _omitFieldNames ? '' : 'pendingDisbursementLoans')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PortfolioSummary clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PortfolioSummary copyWith(void Function(PortfolioSummary) updates) =>
      super.copyWith((message) => updates(message as PortfolioSummary))
          as PortfolioSummary;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use PortfolioSummary() / PortfolioSummary.new instead')
  static PortfolioSummary create() => PortfolioSummary._();
  static $pb.GeneratedMessage $_createMessage() => PortfolioSummary._();
  @$core.override
  PortfolioSummary createEmptyInstance() => PortfolioSummary._();
  @$core.pragma('dart2js:noInline')
  static PortfolioSummary getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PortfolioSummary>(
          PortfolioSummary.$_createMessage);
  static PortfolioSummary? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get totalLoans => $_getIZ(0);
  @$pb.TagNumber(1)
  set totalLoans($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTotalLoans() => $_has(0);
  @$pb.TagNumber(1)
  void clearTotalLoans() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get activeLoans => $_getIZ(1);
  @$pb.TagNumber(2)
  set activeLoans($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasActiveLoans() => $_has(1);
  @$pb.TagNumber(2)
  void clearActiveLoans() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get delinquentLoans => $_getIZ(2);
  @$pb.TagNumber(3)
  set delinquentLoans($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDelinquentLoans() => $_has(2);
  @$pb.TagNumber(3)
  void clearDelinquentLoans() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get defaultLoans => $_getIZ(3);
  @$pb.TagNumber(4)
  set defaultLoans($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDefaultLoans() => $_has(3);
  @$pb.TagNumber(4)
  void clearDefaultLoans() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get paidOffLoans => $_getIZ(4);
  @$pb.TagNumber(5)
  set paidOffLoans($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasPaidOffLoans() => $_has(4);
  @$pb.TagNumber(5)
  void clearPaidOffLoans() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get writtenOffLoans => $_getIZ(5);
  @$pb.TagNumber(6)
  set writtenOffLoans($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasWrittenOffLoans() => $_has(5);
  @$pb.TagNumber(6)
  void clearWrittenOffLoans() => $_clearField(6);

  @$pb.TagNumber(7)
  $0.Money get totalDisbursed => $_getN(6);
  @$pb.TagNumber(7)
  set totalDisbursed($0.Money value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasTotalDisbursed() => $_has(6);
  @$pb.TagNumber(7)
  void clearTotalDisbursed() => $_clearField(7);
  @$pb.TagNumber(7)
  $0.Money ensureTotalDisbursed() => $_ensure(6);

  @$pb.TagNumber(8)
  $0.Money get totalOutstanding => $_getN(7);
  @$pb.TagNumber(8)
  set totalOutstanding($0.Money value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasTotalOutstanding() => $_has(7);
  @$pb.TagNumber(8)
  void clearTotalOutstanding() => $_clearField(8);
  @$pb.TagNumber(8)
  $0.Money ensureTotalOutstanding() => $_ensure(7);

  @$pb.TagNumber(9)
  $0.Money get totalCollected => $_getN(8);
  @$pb.TagNumber(9)
  set totalCollected($0.Money value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasTotalCollected() => $_has(8);
  @$pb.TagNumber(9)
  void clearTotalCollected() => $_clearField(9);
  @$pb.TagNumber(9)
  $0.Money ensureTotalCollected() => $_ensure(8);

  @$pb.TagNumber(10)
  $0.Money get principalOutstanding => $_getN(9);
  @$pb.TagNumber(10)
  set principalOutstanding($0.Money value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasPrincipalOutstanding() => $_has(9);
  @$pb.TagNumber(10)
  void clearPrincipalOutstanding() => $_clearField(10);
  @$pb.TagNumber(10)
  $0.Money ensurePrincipalOutstanding() => $_ensure(9);

  @$pb.TagNumber(11)
  $0.Money get interestOutstanding => $_getN(10);
  @$pb.TagNumber(11)
  set interestOutstanding($0.Money value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasInterestOutstanding() => $_has(10);
  @$pb.TagNumber(11)
  void clearInterestOutstanding() => $_clearField(11);
  @$pb.TagNumber(11)
  $0.Money ensureInterestOutstanding() => $_ensure(10);

  @$pb.TagNumber(12)
  $0.Money get feesOutstanding => $_getN(11);
  @$pb.TagNumber(12)
  set feesOutstanding($0.Money value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasFeesOutstanding() => $_has(11);
  @$pb.TagNumber(12)
  void clearFeesOutstanding() => $_clearField(12);
  @$pb.TagNumber(12)
  $0.Money ensureFeesOutstanding() => $_ensure(11);

  @$pb.TagNumber(13)
  $0.Money get penaltiesOutstanding => $_getN(12);
  @$pb.TagNumber(13)
  set penaltiesOutstanding($0.Money value) => $_setField(13, value);
  @$pb.TagNumber(13)
  $core.bool hasPenaltiesOutstanding() => $_has(12);
  @$pb.TagNumber(13)
  void clearPenaltiesOutstanding() => $_clearField(13);
  @$pb.TagNumber(13)
  $0.Money ensurePenaltiesOutstanding() => $_ensure(12);

  @$pb.TagNumber(14)
  $core.String get currencyCode => $_getSZ(13);
  @$pb.TagNumber(14)
  set currencyCode($core.String value) => $_setString(13, value);
  @$pb.TagNumber(14)
  $core.bool hasCurrencyCode() => $_has(13);
  @$pb.TagNumber(14)
  void clearCurrencyCode() => $_clearField(14);

  /// collection_rate is total_collected / total_disbursed as a percentage string (e.g. "85.50").
  @$pb.TagNumber(15)
  $core.String get collectionRate => $_getSZ(14);
  @$pb.TagNumber(15)
  set collectionRate($core.String value) => $_setString(14, value);
  @$pb.TagNumber(15)
  $core.bool hasCollectionRate() => $_has(14);
  @$pb.TagNumber(15)
  void clearCollectionRate() => $_clearField(15);

  /// par_30 is portfolio-at-risk > 30 days as a percentage string (e.g. "12.30").
  @$pb.TagNumber(16)
  $core.String get par30 => $_getSZ(15);
  @$pb.TagNumber(16)
  set par30($core.String value) => $_setString(15, value);
  @$pb.TagNumber(16)
  $core.bool hasPar30() => $_has(15);
  @$pb.TagNumber(16)
  void clearPar30() => $_clearField(16);

  /// pending_disbursement_loans counts loans created but not yet disbursed
  /// (LOAN_STATUS_PENDING_DISBURSEMENT). They are part of total_loans but of
  /// none of the other status counts.
  @$pb.TagNumber(17)
  $core.int get pendingDisbursementLoans => $_getIZ(16);
  @$pb.TagNumber(17)
  set pendingDisbursementLoans($core.int value) => $_setSignedInt32(16, value);
  @$pb.TagNumber(17)
  $core.bool hasPendingDisbursementLoans() => $_has(16);
  @$pb.TagNumber(17)
  void clearPendingDisbursementLoans() => $_clearField(17);
}

class PortfolioSummaryRequest extends $pb.GeneratedMessage {
  factory PortfolioSummaryRequest({
    $core.String? organizationId,
    $core.String? branchId,
    $core.String? agentId,
    $core.String? productId,
    $core.String? clientId,
    $core.String? currencyCode,
  }) {
    final result = PortfolioSummaryRequest._();
    if (organizationId != null) result.organizationId = organizationId;
    if (branchId != null) result.branchId = branchId;
    if (agentId != null) result.agentId = agentId;
    if (productId != null) result.productId = productId;
    if (clientId != null) result.clientId = clientId;
    if (currencyCode != null) result.currencyCode = currencyCode;
    return result;
  }

  PortfolioSummaryRequest._();

  factory PortfolioSummaryRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PortfolioSummaryRequest()..mergeFromBuffer(data, registry);
  factory PortfolioSummaryRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PortfolioSummaryRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PortfolioSummaryRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: PortfolioSummaryRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'organizationId')
    ..aOS(2, _omitFieldNames ? '' : 'branchId')
    ..aOS(3, _omitFieldNames ? '' : 'agentId')
    ..aOS(4, _omitFieldNames ? '' : 'productId')
    ..aOS(5, _omitFieldNames ? '' : 'clientId')
    ..aOS(6, _omitFieldNames ? '' : 'currencyCode')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PortfolioSummaryRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PortfolioSummaryRequest copyWith(
          void Function(PortfolioSummaryRequest) updates) =>
      super.copyWith((message) => updates(message as PortfolioSummaryRequest))
          as PortfolioSummaryRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use PortfolioSummaryRequest() / PortfolioSummaryRequest.new instead')
  static PortfolioSummaryRequest create() => PortfolioSummaryRequest._();
  static $pb.GeneratedMessage $_createMessage() => PortfolioSummaryRequest._();
  @$core.override
  PortfolioSummaryRequest createEmptyInstance() => PortfolioSummaryRequest._();
  @$core.pragma('dart2js:noInline')
  static PortfolioSummaryRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PortfolioSummaryRequest>(
          PortfolioSummaryRequest.$_createMessage);
  static PortfolioSummaryRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get organizationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set organizationId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasOrganizationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearOrganizationId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get branchId => $_getSZ(1);
  @$pb.TagNumber(2)
  set branchId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasBranchId() => $_has(1);
  @$pb.TagNumber(2)
  void clearBranchId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get agentId => $_getSZ(2);
  @$pb.TagNumber(3)
  set agentId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAgentId() => $_has(2);
  @$pb.TagNumber(3)
  void clearAgentId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get productId => $_getSZ(3);
  @$pb.TagNumber(4)
  set productId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasProductId() => $_has(3);
  @$pb.TagNumber(4)
  void clearProductId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get clientId => $_getSZ(4);
  @$pb.TagNumber(5)
  set clientId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasClientId() => $_has(4);
  @$pb.TagNumber(5)
  void clearClientId() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get currencyCode => $_getSZ(5);
  @$pb.TagNumber(6)
  set currencyCode($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasCurrencyCode() => $_has(5);
  @$pb.TagNumber(6)
  void clearCurrencyCode() => $_clearField(6);
}

class PortfolioSummaryResponse extends $pb.GeneratedMessage {
  factory PortfolioSummaryResponse({
    PortfolioSummary? data,
  }) {
    final result = PortfolioSummaryResponse._();
    if (data != null) result.data = data;
    return result;
  }

  PortfolioSummaryResponse._();

  factory PortfolioSummaryResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PortfolioSummaryResponse()..mergeFromBuffer(data, registry);
  factory PortfolioSummaryResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PortfolioSummaryResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PortfolioSummaryResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: PortfolioSummaryResponse.$_createMessage)
    ..aOM<PortfolioSummary>(1, _omitFieldNames ? '' : 'data',
        subBuilder: PortfolioSummary.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PortfolioSummaryResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PortfolioSummaryResponse copyWith(
          void Function(PortfolioSummaryResponse) updates) =>
      super.copyWith((message) => updates(message as PortfolioSummaryResponse))
          as PortfolioSummaryResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use PortfolioSummaryResponse() / PortfolioSummaryResponse.new instead')
  static PortfolioSummaryResponse create() => PortfolioSummaryResponse._();
  static $pb.GeneratedMessage $_createMessage() => PortfolioSummaryResponse._();
  @$core.override
  PortfolioSummaryResponse createEmptyInstance() =>
      PortfolioSummaryResponse._();
  @$core.pragma('dart2js:noInline')
  static PortfolioSummaryResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PortfolioSummaryResponse>(
          PortfolioSummaryResponse.$_createMessage);
  static PortfolioSummaryResponse? _defaultInstance;

  @$pb.TagNumber(1)
  PortfolioSummary get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(PortfolioSummary value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  PortfolioSummary ensureData() => $_ensure(0);
}

class PortfolioExportRequest extends $pb.GeneratedMessage {
  factory PortfolioExportRequest({
    $core.String? organizationId,
    $core.String? branchId,
    $core.String? agentId,
    $core.String? productId,
    $core.String? clientId,
    $core.String? currencyCode,
    $core.String? format,
  }) {
    final result = PortfolioExportRequest._();
    if (organizationId != null) result.organizationId = organizationId;
    if (branchId != null) result.branchId = branchId;
    if (agentId != null) result.agentId = agentId;
    if (productId != null) result.productId = productId;
    if (clientId != null) result.clientId = clientId;
    if (currencyCode != null) result.currencyCode = currencyCode;
    if (format != null) result.format = format;
    return result;
  }

  PortfolioExportRequest._();

  factory PortfolioExportRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PortfolioExportRequest()..mergeFromBuffer(data, registry);
  factory PortfolioExportRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PortfolioExportRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PortfolioExportRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: PortfolioExportRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'organizationId')
    ..aOS(2, _omitFieldNames ? '' : 'branchId')
    ..aOS(3, _omitFieldNames ? '' : 'agentId')
    ..aOS(4, _omitFieldNames ? '' : 'productId')
    ..aOS(5, _omitFieldNames ? '' : 'clientId')
    ..aOS(6, _omitFieldNames ? '' : 'currencyCode')
    ..aOS(7, _omitFieldNames ? '' : 'format')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PortfolioExportRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PortfolioExportRequest copyWith(
          void Function(PortfolioExportRequest) updates) =>
      super.copyWith((message) => updates(message as PortfolioExportRequest))
          as PortfolioExportRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use PortfolioExportRequest() / PortfolioExportRequest.new instead')
  static PortfolioExportRequest create() => PortfolioExportRequest._();
  static $pb.GeneratedMessage $_createMessage() => PortfolioExportRequest._();
  @$core.override
  PortfolioExportRequest createEmptyInstance() => PortfolioExportRequest._();
  @$core.pragma('dart2js:noInline')
  static PortfolioExportRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PortfolioExportRequest>(
          PortfolioExportRequest.$_createMessage);
  static PortfolioExportRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get organizationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set organizationId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasOrganizationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearOrganizationId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get branchId => $_getSZ(1);
  @$pb.TagNumber(2)
  set branchId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasBranchId() => $_has(1);
  @$pb.TagNumber(2)
  void clearBranchId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get agentId => $_getSZ(2);
  @$pb.TagNumber(3)
  set agentId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAgentId() => $_has(2);
  @$pb.TagNumber(3)
  void clearAgentId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get productId => $_getSZ(3);
  @$pb.TagNumber(4)
  set productId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasProductId() => $_has(3);
  @$pb.TagNumber(4)
  void clearProductId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get clientId => $_getSZ(4);
  @$pb.TagNumber(5)
  set clientId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasClientId() => $_has(4);
  @$pb.TagNumber(5)
  void clearClientId() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get currencyCode => $_getSZ(5);
  @$pb.TagNumber(6)
  set currencyCode($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasCurrencyCode() => $_has(5);
  @$pb.TagNumber(6)
  void clearCurrencyCode() => $_clearField(6);

  /// format is the export format: "CSV" (default).
  @$pb.TagNumber(7)
  $core.String get format => $_getSZ(6);
  @$pb.TagNumber(7)
  set format($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasFormat() => $_has(6);
  @$pb.TagNumber(7)
  void clearFormat() => $_clearField(7);
}

class PortfolioExportResponse extends $pb.GeneratedMessage {
  factory PortfolioExportResponse({
    $core.List<$core.int>? data,
    $core.String? filename,
    $core.String? contentType,
  }) {
    final result = PortfolioExportResponse._();
    if (data != null) result.data = data;
    if (filename != null) result.filename = filename;
    if (contentType != null) result.contentType = contentType;
    return result;
  }

  PortfolioExportResponse._();

  factory PortfolioExportResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PortfolioExportResponse()..mergeFromBuffer(data, registry);
  factory PortfolioExportResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PortfolioExportResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PortfolioExportResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'),
      createEmptyInstance: PortfolioExportResponse.$_createMessage)
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'data', $pb.PbFieldType.OY)
    ..aOS(2, _omitFieldNames ? '' : 'filename')
    ..aOS(3, _omitFieldNames ? '' : 'contentType')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PortfolioExportResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PortfolioExportResponse copyWith(
          void Function(PortfolioExportResponse) updates) =>
      super.copyWith((message) => updates(message as PortfolioExportResponse))
          as PortfolioExportResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use PortfolioExportResponse() / PortfolioExportResponse.new instead')
  static PortfolioExportResponse create() => PortfolioExportResponse._();
  static $pb.GeneratedMessage $_createMessage() => PortfolioExportResponse._();
  @$core.override
  PortfolioExportResponse createEmptyInstance() => PortfolioExportResponse._();
  @$core.pragma('dart2js:noInline')
  static PortfolioExportResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PortfolioExportResponse>(
          PortfolioExportResponse.$_createMessage);
  static PortfolioExportResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get data => $_getN(0);
  @$pb.TagNumber(1)
  set data($core.List<$core.int> value) => $_setBytes(0, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get filename => $_getSZ(1);
  @$pb.TagNumber(2)
  set filename($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFilename() => $_has(1);
  @$pb.TagNumber(2)
  void clearFilename() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get contentType => $_getSZ(2);
  @$pb.TagNumber(3)
  set contentType($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasContentType() => $_has(2);
  @$pb.TagNumber(3)
  void clearContentType() => $_clearField(3);
}

/// LoanManagementService manages active loans, disbursements, repayments,
/// schedules, penalties, restructures, and reconciliation.
/// All RPCs require authentication via Bearer token.
class LoanManagementServiceApi {
  final $pb.RpcClient _client;

  LoanManagementServiceApi(this._client);

  /// LoanProductSave creates or updates a loan product.
  $async.Future<LoanProductSaveResponse> loanProductSave(
          $pb.ClientContext? ctx, LoanProductSaveRequest request) =>
      _client.invoke<LoanProductSaveResponse>(ctx, 'LoanManagementService',
          'LoanProductSave', request, LoanProductSaveResponse());

  /// LoanProductGet retrieves a loan product by its ID.
  $async.Future<LoanProductGetResponse> loanProductGet(
          $pb.ClientContext? ctx, LoanProductGetRequest request) =>
      _client.invoke<LoanProductGetResponse>(ctx, 'LoanManagementService',
          'LoanProductGet', request, LoanProductGetResponse());

  /// LoanProductSearch finds loan products matching search criteria.
  $async.Future<LoanProductSearchResponse> loanProductSearch(
          $pb.ClientContext? ctx, LoanProductSearchRequest request) =>
      _client.invoke<LoanProductSearchResponse>(ctx, 'LoanManagementService',
          'LoanProductSearch', request, LoanProductSearchResponse());

  /// LoanRequestSave creates or updates a loan request. Called by product services
  /// (seed, stawi, etc.) after completing their own acquisition workflows.
  $async.Future<LoanRequestSaveResponse> loanRequestSave(
          $pb.ClientContext? ctx, LoanRequestSaveRequest request) =>
      _client.invoke<LoanRequestSaveResponse>(ctx, 'LoanManagementService',
          'LoanRequestSave', request, LoanRequestSaveResponse());

  /// LoanRequestGet retrieves a loan request by its ID.
  $async.Future<LoanRequestGetResponse> loanRequestGet(
          $pb.ClientContext? ctx, LoanRequestGetRequest request) =>
      _client.invoke<LoanRequestGetResponse>(ctx, 'LoanManagementService',
          'LoanRequestGet', request, LoanRequestGetResponse());

  /// LoanRequestSearch finds loan requests matching search criteria.
  $async.Future<LoanRequestSearchResponse> loanRequestSearch(
          $pb.ClientContext? ctx, LoanRequestSearchRequest request) =>
      _client.invoke<LoanRequestSearchResponse>(ctx, 'LoanManagementService',
          'LoanRequestSearch', request, LoanRequestSearchResponse());

  /// LoanRequestApprove approves a loan request and creates the loan account.
  $async.Future<LoanRequestApproveResponse> loanRequestApprove(
          $pb.ClientContext? ctx, LoanRequestApproveRequest request) =>
      _client.invoke<LoanRequestApproveResponse>(ctx, 'LoanManagementService',
          'LoanRequestApprove', request, LoanRequestApproveResponse());

  /// LoanRequestReject rejects a loan request with a reason.
  $async.Future<LoanRequestRejectResponse> loanRequestReject(
          $pb.ClientContext? ctx, LoanRequestRejectRequest request) =>
      _client.invoke<LoanRequestRejectResponse>(ctx, 'LoanManagementService',
          'LoanRequestReject', request, LoanRequestRejectResponse());

  /// LoanRequestCancel cancels a loan request.
  $async.Future<LoanRequestCancelResponse> loanRequestCancel(
          $pb.ClientContext? ctx, LoanRequestCancelRequest request) =>
      _client.invoke<LoanRequestCancelResponse>(ctx, 'LoanManagementService',
          'LoanRequestCancel', request, LoanRequestCancelResponse());

  /// ClientProductAccessSave creates or updates a client product access record.
  $async.Future<ClientProductAccessSaveResponse> clientProductAccessSave(
          $pb.ClientContext? ctx, ClientProductAccessSaveRequest request) =>
      _client.invoke<ClientProductAccessSaveResponse>(
          ctx,
          'LoanManagementService',
          'ClientProductAccessSave',
          request,
          ClientProductAccessSaveResponse());

  /// ClientProductAccessGet retrieves a client product access record.
  $async.Future<ClientProductAccessGetResponse> clientProductAccessGet(
          $pb.ClientContext? ctx, ClientProductAccessGetRequest request) =>
      _client.invoke<ClientProductAccessGetResponse>(
          ctx,
          'LoanManagementService',
          'ClientProductAccessGet',
          request,
          ClientProductAccessGetResponse());

  /// ClientProductAccessSearch finds client product access records.
  $async.Future<ClientProductAccessSearchResponse> clientProductAccessSearch(
          $pb.ClientContext? ctx, ClientProductAccessSearchRequest request) =>
      _client.invoke<ClientProductAccessSearchResponse>(
          ctx,
          'LoanManagementService',
          'ClientProductAccessSearch',
          request,
          ClientProductAccessSearchResponse());

  /// LoanAccountCreate creates a new loan account from an approved loan request.
  $async.Future<LoanAccountCreateResponse> loanAccountCreate(
          $pb.ClientContext? ctx, LoanAccountCreateRequest request) =>
      _client.invoke<LoanAccountCreateResponse>(ctx, 'LoanManagementService',
          'LoanAccountCreate', request, LoanAccountCreateResponse());

  /// LoanAccountCancel closes a loan that was opened but never disbursed and
  /// gives its funders back the capital reserved for it.
  $async.Future<LoanAccountCancelResponse> loanAccountCancel(
          $pb.ClientContext? ctx, LoanAccountCancelRequest request) =>
      _client.invoke<LoanAccountCancelResponse>(ctx, 'LoanManagementService',
          'LoanAccountCancel', request, LoanAccountCancelResponse());

  /// LoanAccountGet retrieves a loan account by its ID.
  $async.Future<LoanAccountGetResponse> loanAccountGet(
          $pb.ClientContext? ctx, LoanAccountGetRequest request) =>
      _client.invoke<LoanAccountGetResponse>(ctx, 'LoanManagementService',
          'LoanAccountGet', request, LoanAccountGetResponse());

  /// LoanAccountSearch finds loan accounts matching search criteria.
  $async.Future<LoanAccountSearchResponse> loanAccountSearch(
          $pb.ClientContext? ctx, LoanAccountSearchRequest request) =>
      _client.invoke<LoanAccountSearchResponse>(ctx, 'LoanManagementService',
          'LoanAccountSearch', request, LoanAccountSearchResponse());

  /// LoanBalanceGet retrieves the current balance of a loan.
  $async.Future<LoanBalanceGetResponse> loanBalanceGet(
          $pb.ClientContext? ctx, LoanBalanceGetRequest request) =>
      _client.invoke<LoanBalanceGetResponse>(ctx, 'LoanManagementService',
          'LoanBalanceGet', request, LoanBalanceGetResponse());

  /// LoanStatement generates a loan statement for a date range.
  $async.Future<LoanStatementResponse> loanStatement(
          $pb.ClientContext? ctx, LoanStatementRequest request) =>
      _client.invoke<LoanStatementResponse>(ctx, 'LoanManagementService',
          'LoanStatement', request, LoanStatementResponse());

  /// DisbursementCreate initiates a loan disbursement.
  $async.Future<DisbursementCreateResponse> disbursementCreate(
          $pb.ClientContext? ctx, DisbursementCreateRequest request) =>
      _client.invoke<DisbursementCreateResponse>(ctx, 'LoanManagementService',
          'DisbursementCreate', request, DisbursementCreateResponse());

  /// DisbursementGet retrieves a disbursement by its ID.
  $async.Future<DisbursementGetResponse> disbursementGet(
          $pb.ClientContext? ctx, DisbursementGetRequest request) =>
      _client.invoke<DisbursementGetResponse>(ctx, 'LoanManagementService',
          'DisbursementGet', request, DisbursementGetResponse());

  /// DisbursementSearch finds disbursements for a loan.
  $async.Future<DisbursementSearchResponse> disbursementSearch(
          $pb.ClientContext? ctx, DisbursementSearchRequest request) =>
      _client.invoke<DisbursementSearchResponse>(ctx, 'LoanManagementService',
          'DisbursementSearch', request, DisbursementSearchResponse());

  /// RepaymentRecord applies a payment the borrower made from their own
  /// contact to their loan. Only the payment rail calls it, once it has
  /// matched the inbound payment; no person records a repayment.
  $async.Future<RepaymentRecordResponse> repaymentRecord(
          $pb.ClientContext? ctx, RepaymentRecordRequest request) =>
      _client.invoke<RepaymentRecordResponse>(ctx, 'LoanManagementService',
          'RepaymentRecord', request, RepaymentRecordResponse());

  /// RepaymentGet retrieves a repayment by its ID.
  $async.Future<RepaymentGetResponse> repaymentGet(
          $pb.ClientContext? ctx, RepaymentGetRequest request) =>
      _client.invoke<RepaymentGetResponse>(ctx, 'LoanManagementService',
          'RepaymentGet', request, RepaymentGetResponse());

  /// RepaymentSearch finds repayments for a loan.
  $async.Future<RepaymentSearchResponse> repaymentSearch(
          $pb.ClientContext? ctx, RepaymentSearchRequest request) =>
      _client.invoke<RepaymentSearchResponse>(ctx, 'LoanManagementService',
          'RepaymentSearch', request, RepaymentSearchResponse());

  /// RepaymentScheduleGet retrieves the active repayment schedule for a loan.
  $async.Future<RepaymentScheduleGetResponse> repaymentScheduleGet(
          $pb.ClientContext? ctx, RepaymentScheduleGetRequest request) =>
      _client.invoke<RepaymentScheduleGetResponse>(ctx, 'LoanManagementService',
          'RepaymentScheduleGet', request, RepaymentScheduleGetResponse());

  /// PenaltySave creates or updates a penalty on a loan.
  $async.Future<PenaltySaveResponse> penaltySave(
          $pb.ClientContext? ctx, PenaltySaveRequest request) =>
      _client.invoke<PenaltySaveResponse>(ctx, 'LoanManagementService',
          'PenaltySave', request, PenaltySaveResponse());

  /// PenaltyWaive waives a penalty on a loan.
  $async.Future<PenaltyWaiveResponse> penaltyWaive(
          $pb.ClientContext? ctx, PenaltyWaiveRequest request) =>
      _client.invoke<PenaltyWaiveResponse>(ctx, 'LoanManagementService',
          'PenaltyWaive', request, PenaltyWaiveResponse());

  /// PenaltySearch finds penalties for a loan.
  $async.Future<PenaltySearchResponse> penaltySearch(
          $pb.ClientContext? ctx, PenaltySearchRequest request) =>
      _client.invoke<PenaltySearchResponse>(ctx, 'LoanManagementService',
          'PenaltySearch', request, PenaltySearchResponse());

  /// LoanRestructureCreate requests a loan restructure.
  $async.Future<LoanRestructureCreateResponse> loanRestructureCreate(
          $pb.ClientContext? ctx, LoanRestructureCreateRequest request) =>
      _client.invoke<LoanRestructureCreateResponse>(
          ctx,
          'LoanManagementService',
          'LoanRestructureCreate',
          request,
          LoanRestructureCreateResponse());

  /// LoanRestructureApprove approves a loan restructure.
  $async.Future<LoanRestructureApproveResponse> loanRestructureApprove(
          $pb.ClientContext? ctx, LoanRestructureApproveRequest request) =>
      _client.invoke<LoanRestructureApproveResponse>(
          ctx,
          'LoanManagementService',
          'LoanRestructureApprove',
          request,
          LoanRestructureApproveResponse());

  /// LoanRestructureReject rejects a loan restructure.
  $async.Future<LoanRestructureRejectResponse> loanRestructureReject(
          $pb.ClientContext? ctx, LoanRestructureRejectRequest request) =>
      _client.invoke<LoanRestructureRejectResponse>(
          ctx,
          'LoanManagementService',
          'LoanRestructureReject',
          request,
          LoanRestructureRejectResponse());

  /// LoanRestructureSearch finds restructures for a loan.
  $async.Future<LoanRestructureSearchResponse> loanRestructureSearch(
          $pb.ClientContext? ctx, LoanRestructureSearchRequest request) =>
      _client.invoke<LoanRestructureSearchResponse>(
          ctx,
          'LoanManagementService',
          'LoanRestructureSearch',
          request,
          LoanRestructureSearchResponse());

  /// ReconciliationSave creates or updates a reconciliation record.
  $async.Future<ReconciliationSaveResponse> reconciliationSave(
          $pb.ClientContext? ctx, ReconciliationSaveRequest request) =>
      _client.invoke<ReconciliationSaveResponse>(ctx, 'LoanManagementService',
          'ReconciliationSave', request, ReconciliationSaveResponse());

  /// ReconciliationSearch finds reconciliation records.
  $async.Future<ReconciliationSearchResponse> reconciliationSearch(
          $pb.ClientContext? ctx, ReconciliationSearchRequest request) =>
      _client.invoke<ReconciliationSearchResponse>(ctx, 'LoanManagementService',
          'ReconciliationSearch', request, ReconciliationSearchResponse());

  /// InitiateCollection sends a payment collection prompt to the client.
  $async.Future<InitiateCollectionResponse> initiateCollection(
          $pb.ClientContext? ctx, InitiateCollectionRequest request) =>
      _client.invoke<InitiateCollectionResponse>(ctx, 'LoanManagementService',
          'InitiateCollection', request, InitiateCollectionResponse());

  /// TeamCommissionSearch lists teams' commission balances.
  $async.Future<TeamCommissionSearchResponse> teamCommissionSearch(
          $pb.ClientContext? ctx, TeamCommissionSearchRequest request) =>
      _client.invoke<TeamCommissionSearchResponse>(ctx, 'LoanManagementService',
          'TeamCommissionSearch', request, TeamCommissionSearchResponse());

  /// TeamCommissionPayout pays a team's accrued commission to one of its
  /// members' own verified mobile money.
  $async.Future<TeamCommissionPayoutResponse> teamCommissionPayout(
          $pb.ClientContext? ctx, TeamCommissionPayoutRequest request) =>
      _client.invoke<TeamCommissionPayoutResponse>(ctx, 'LoanManagementService',
          'TeamCommissionPayout', request, TeamCommissionPayoutResponse());

  /// TeamCommissionPayoutSearch lists a team's commission payouts.
  $async.Future<TeamCommissionPayoutSearchResponse> teamCommissionPayoutSearch(
          $pb.ClientContext? ctx, TeamCommissionPayoutSearchRequest request) =>
      _client.invoke<TeamCommissionPayoutSearchResponse>(
          ctx,
          'LoanManagementService',
          'TeamCommissionPayoutSearch',
          request,
          TeamCommissionPayoutSearchResponse());

  /// LoanJobRun runs one batch of a periodic job. Called by the platform
  /// scheduler (trustage); only service accounts hold the permission.
  $async.Future<LoanJobRunResponse> loanJobRun(
          $pb.ClientContext? ctx, LoanJobRunRequest request) =>
      _client.invoke<LoanJobRunResponse>(ctx, 'LoanManagementService',
          'LoanJobRun', request, LoanJobRunResponse());

  /// LoanStatusChangeSearch retrieves status change audit trail for a loan.
  $async.Future<LoanStatusChangeSearchResponse> loanStatusChangeSearch(
          $pb.ClientContext? ctx, LoanStatusChangeSearchRequest request) =>
      _client.invoke<LoanStatusChangeSearchResponse>(
          ctx,
          'LoanManagementService',
          'LoanStatusChangeSearch',
          request,
          LoanStatusChangeSearchResponse());

  /// PortfolioSummary returns aggregated financial metrics across a filtered
  /// set of loans. Supports filtering by organization, branch, agent, product, and client.
  $async.Future<PortfolioSummaryResponse> portfolioSummary(
          $pb.ClientContext? ctx, PortfolioSummaryRequest request) =>
      _client.invoke<PortfolioSummaryResponse>(ctx, 'LoanManagementService',
          'PortfolioSummary', request, PortfolioSummaryResponse());

  /// PortfolioExport exports the loan book as CSV for a filtered set of loans.
  $async.Future<PortfolioExportResponse> portfolioExport(
          $pb.ClientContext? ctx, PortfolioExportRequest request) =>
      _client.invoke<PortfolioExportResponse>(ctx, 'LoanManagementService',
          'PortfolioExport', request, PortfolioExportResponse());
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
