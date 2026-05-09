//
//  Generated code. Do not modify.
//  source: loans/v1/loans.proto
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
import 'loans.pbenum.dart';

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
    final $result = create();
    if (templateId != null) {
      $result.templateId = templateId;
    }
    if (stage != null) {
      $result.stage = stage;
    }
    if (required != null) {
      $result.required = required;
    }
    if (order != null) {
      $result.order = order;
    }
    if (description != null) {
      $result.description = description;
    }
    return $result;
  }
  ProductFormRequirement._() : super();
  factory ProductFormRequirement.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ProductFormRequirement.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ProductFormRequirement', package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'templateId')
    ..aOS(2, _omitFieldNames ? '' : 'stage')
    ..aOB(3, _omitFieldNames ? '' : 'required')
    ..a<$core.int>(4, _omitFieldNames ? '' : 'order', $pb.PbFieldType.O3)
    ..aOS(5, _omitFieldNames ? '' : 'description')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ProductFormRequirement clone() => ProductFormRequirement()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ProductFormRequirement copyWith(void Function(ProductFormRequirement) updates) => super.copyWith((message) => updates(message as ProductFormRequirement)) as ProductFormRequirement;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ProductFormRequirement create() => ProductFormRequirement._();
  ProductFormRequirement createEmptyInstance() => create();
  static $pb.PbList<ProductFormRequirement> createRepeated() => $pb.PbList<ProductFormRequirement>();
  @$core.pragma('dart2js:noInline')
  static ProductFormRequirement getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ProductFormRequirement>(create);
  static ProductFormRequirement? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get templateId => $_getSZ(0);
  @$pb.TagNumber(1)
  set templateId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTemplateId() => $_has(0);
  @$pb.TagNumber(1)
  void clearTemplateId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get stage => $_getSZ(1);
  @$pb.TagNumber(2)
  set stage($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasStage() => $_has(1);
  @$pb.TagNumber(2)
  void clearStage() => clearField(2);

  @$pb.TagNumber(3)
  $core.bool get required => $_getBF(2);
  @$pb.TagNumber(3)
  set required($core.bool v) { $_setBool(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasRequired() => $_has(2);
  @$pb.TagNumber(3)
  void clearRequired() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get order => $_getIZ(3);
  @$pb.TagNumber(4)
  set order($core.int v) { $_setSignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasOrder() => $_has(3);
  @$pb.TagNumber(4)
  void clearOrder() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get description => $_getSZ(4);
  @$pb.TagNumber(5)
  set description($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasDescription() => $_has(4);
  @$pb.TagNumber(5)
  void clearDescription() => clearField(5);
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
    $7.Money? minAmount,
    $7.Money? maxAmount,
    $core.int? minTermDays,
    $core.int? maxTermDays,
    $core.String? annualInterestRate,
    $core.String? processingFeePercent,
    $core.String? insuranceFeePercent,
    $core.String? latePenaltyRate,
    $core.int? gracePeriodDays,
    $6.Struct? feeStructure,
    $6.Struct? eligibilityCriteria,
    $8.STATE? state,
    $6.Struct? properties,
    $core.Iterable<ProductFormRequirement>? requiredForms,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (organizationId != null) {
      $result.organizationId = organizationId;
    }
    if (name != null) {
      $result.name = name;
    }
    if (code != null) {
      $result.code = code;
    }
    if (description != null) {
      $result.description = description;
    }
    if (productType != null) {
      $result.productType = productType;
    }
    if (currencyCode != null) {
      $result.currencyCode = currencyCode;
    }
    if (interestMethod != null) {
      $result.interestMethod = interestMethod;
    }
    if (repaymentFrequency != null) {
      $result.repaymentFrequency = repaymentFrequency;
    }
    if (minAmount != null) {
      $result.minAmount = minAmount;
    }
    if (maxAmount != null) {
      $result.maxAmount = maxAmount;
    }
    if (minTermDays != null) {
      $result.minTermDays = minTermDays;
    }
    if (maxTermDays != null) {
      $result.maxTermDays = maxTermDays;
    }
    if (annualInterestRate != null) {
      $result.annualInterestRate = annualInterestRate;
    }
    if (processingFeePercent != null) {
      $result.processingFeePercent = processingFeePercent;
    }
    if (insuranceFeePercent != null) {
      $result.insuranceFeePercent = insuranceFeePercent;
    }
    if (latePenaltyRate != null) {
      $result.latePenaltyRate = latePenaltyRate;
    }
    if (gracePeriodDays != null) {
      $result.gracePeriodDays = gracePeriodDays;
    }
    if (feeStructure != null) {
      $result.feeStructure = feeStructure;
    }
    if (eligibilityCriteria != null) {
      $result.eligibilityCriteria = eligibilityCriteria;
    }
    if (state != null) {
      $result.state = state;
    }
    if (properties != null) {
      $result.properties = properties;
    }
    if (requiredForms != null) {
      $result.requiredForms.addAll(requiredForms);
    }
    return $result;
  }
  LoanProductObject._() : super();
  factory LoanProductObject.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory LoanProductObject.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LoanProductObject', package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'organizationId')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..aOS(4, _omitFieldNames ? '' : 'code')
    ..aOS(5, _omitFieldNames ? '' : 'description')
    ..e<LoanProductType>(6, _omitFieldNames ? '' : 'productType', $pb.PbFieldType.OE, defaultOrMaker: LoanProductType.LOAN_PRODUCT_TYPE_UNSPECIFIED, valueOf: LoanProductType.valueOf, enumValues: LoanProductType.values)
    ..aOS(7, _omitFieldNames ? '' : 'currencyCode')
    ..e<InterestMethod>(8, _omitFieldNames ? '' : 'interestMethod', $pb.PbFieldType.OE, defaultOrMaker: InterestMethod.INTEREST_METHOD_UNSPECIFIED, valueOf: InterestMethod.valueOf, enumValues: InterestMethod.values)
    ..e<RepaymentFrequency>(9, _omitFieldNames ? '' : 'repaymentFrequency', $pb.PbFieldType.OE, defaultOrMaker: RepaymentFrequency.REPAYMENT_FREQUENCY_UNSPECIFIED, valueOf: RepaymentFrequency.valueOf, enumValues: RepaymentFrequency.values)
    ..aOM<$7.Money>(10, _omitFieldNames ? '' : 'minAmount', subBuilder: $7.Money.create)
    ..aOM<$7.Money>(11, _omitFieldNames ? '' : 'maxAmount', subBuilder: $7.Money.create)
    ..a<$core.int>(12, _omitFieldNames ? '' : 'minTermDays', $pb.PbFieldType.O3)
    ..a<$core.int>(13, _omitFieldNames ? '' : 'maxTermDays', $pb.PbFieldType.O3)
    ..aOS(14, _omitFieldNames ? '' : 'annualInterestRate')
    ..aOS(15, _omitFieldNames ? '' : 'processingFeePercent')
    ..aOS(16, _omitFieldNames ? '' : 'insuranceFeePercent')
    ..aOS(17, _omitFieldNames ? '' : 'latePenaltyRate')
    ..a<$core.int>(18, _omitFieldNames ? '' : 'gracePeriodDays', $pb.PbFieldType.O3)
    ..aOM<$6.Struct>(19, _omitFieldNames ? '' : 'feeStructure', subBuilder: $6.Struct.create)
    ..aOM<$6.Struct>(20, _omitFieldNames ? '' : 'eligibilityCriteria', subBuilder: $6.Struct.create)
    ..e<$8.STATE>(21, _omitFieldNames ? '' : 'state', $pb.PbFieldType.OE, defaultOrMaker: $8.STATE.CREATED, valueOf: $8.STATE.valueOf, enumValues: $8.STATE.values)
    ..aOM<$6.Struct>(22, _omitFieldNames ? '' : 'properties', subBuilder: $6.Struct.create)
    ..pc<ProductFormRequirement>(23, _omitFieldNames ? '' : 'requiredForms', $pb.PbFieldType.PM, subBuilder: ProductFormRequirement.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  LoanProductObject clone() => LoanProductObject()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  LoanProductObject copyWith(void Function(LoanProductObject) updates) => super.copyWith((message) => updates(message as LoanProductObject)) as LoanProductObject;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LoanProductObject create() => LoanProductObject._();
  LoanProductObject createEmptyInstance() => create();
  static $pb.PbList<LoanProductObject> createRepeated() => $pb.PbList<LoanProductObject>();
  @$core.pragma('dart2js:noInline')
  static LoanProductObject getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LoanProductObject>(create);
  static LoanProductObject? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get organizationId => $_getSZ(1);
  @$pb.TagNumber(2)
  set organizationId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasOrganizationId() => $_has(1);
  @$pb.TagNumber(2)
  void clearOrganizationId() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get name => $_getSZ(2);
  @$pb.TagNumber(3)
  set name($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasName() => $_has(2);
  @$pb.TagNumber(3)
  void clearName() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get code => $_getSZ(3);
  @$pb.TagNumber(4)
  set code($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasCode() => $_has(3);
  @$pb.TagNumber(4)
  void clearCode() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get description => $_getSZ(4);
  @$pb.TagNumber(5)
  set description($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasDescription() => $_has(4);
  @$pb.TagNumber(5)
  void clearDescription() => clearField(5);

  @$pb.TagNumber(6)
  LoanProductType get productType => $_getN(5);
  @$pb.TagNumber(6)
  set productType(LoanProductType v) { setField(6, v); }
  @$pb.TagNumber(6)
  $core.bool hasProductType() => $_has(5);
  @$pb.TagNumber(6)
  void clearProductType() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get currencyCode => $_getSZ(6);
  @$pb.TagNumber(7)
  set currencyCode($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasCurrencyCode() => $_has(6);
  @$pb.TagNumber(7)
  void clearCurrencyCode() => clearField(7);

  @$pb.TagNumber(8)
  InterestMethod get interestMethod => $_getN(7);
  @$pb.TagNumber(8)
  set interestMethod(InterestMethod v) { setField(8, v); }
  @$pb.TagNumber(8)
  $core.bool hasInterestMethod() => $_has(7);
  @$pb.TagNumber(8)
  void clearInterestMethod() => clearField(8);

  @$pb.TagNumber(9)
  RepaymentFrequency get repaymentFrequency => $_getN(8);
  @$pb.TagNumber(9)
  set repaymentFrequency(RepaymentFrequency v) { setField(9, v); }
  @$pb.TagNumber(9)
  $core.bool hasRepaymentFrequency() => $_has(8);
  @$pb.TagNumber(9)
  void clearRepaymentFrequency() => clearField(9);

  @$pb.TagNumber(10)
  $7.Money get minAmount => $_getN(9);
  @$pb.TagNumber(10)
  set minAmount($7.Money v) { setField(10, v); }
  @$pb.TagNumber(10)
  $core.bool hasMinAmount() => $_has(9);
  @$pb.TagNumber(10)
  void clearMinAmount() => clearField(10);
  @$pb.TagNumber(10)
  $7.Money ensureMinAmount() => $_ensure(9);

  @$pb.TagNumber(11)
  $7.Money get maxAmount => $_getN(10);
  @$pb.TagNumber(11)
  set maxAmount($7.Money v) { setField(11, v); }
  @$pb.TagNumber(11)
  $core.bool hasMaxAmount() => $_has(10);
  @$pb.TagNumber(11)
  void clearMaxAmount() => clearField(11);
  @$pb.TagNumber(11)
  $7.Money ensureMaxAmount() => $_ensure(10);

  @$pb.TagNumber(12)
  $core.int get minTermDays => $_getIZ(11);
  @$pb.TagNumber(12)
  set minTermDays($core.int v) { $_setSignedInt32(11, v); }
  @$pb.TagNumber(12)
  $core.bool hasMinTermDays() => $_has(11);
  @$pb.TagNumber(12)
  void clearMinTermDays() => clearField(12);

  @$pb.TagNumber(13)
  $core.int get maxTermDays => $_getIZ(12);
  @$pb.TagNumber(13)
  set maxTermDays($core.int v) { $_setSignedInt32(12, v); }
  @$pb.TagNumber(13)
  $core.bool hasMaxTermDays() => $_has(12);
  @$pb.TagNumber(13)
  void clearMaxTermDays() => clearField(13);

  @$pb.TagNumber(14)
  $core.String get annualInterestRate => $_getSZ(13);
  @$pb.TagNumber(14)
  set annualInterestRate($core.String v) { $_setString(13, v); }
  @$pb.TagNumber(14)
  $core.bool hasAnnualInterestRate() => $_has(13);
  @$pb.TagNumber(14)
  void clearAnnualInterestRate() => clearField(14);

  @$pb.TagNumber(15)
  $core.String get processingFeePercent => $_getSZ(14);
  @$pb.TagNumber(15)
  set processingFeePercent($core.String v) { $_setString(14, v); }
  @$pb.TagNumber(15)
  $core.bool hasProcessingFeePercent() => $_has(14);
  @$pb.TagNumber(15)
  void clearProcessingFeePercent() => clearField(15);

  @$pb.TagNumber(16)
  $core.String get insuranceFeePercent => $_getSZ(15);
  @$pb.TagNumber(16)
  set insuranceFeePercent($core.String v) { $_setString(15, v); }
  @$pb.TagNumber(16)
  $core.bool hasInsuranceFeePercent() => $_has(15);
  @$pb.TagNumber(16)
  void clearInsuranceFeePercent() => clearField(16);

  @$pb.TagNumber(17)
  $core.String get latePenaltyRate => $_getSZ(16);
  @$pb.TagNumber(17)
  set latePenaltyRate($core.String v) { $_setString(16, v); }
  @$pb.TagNumber(17)
  $core.bool hasLatePenaltyRate() => $_has(16);
  @$pb.TagNumber(17)
  void clearLatePenaltyRate() => clearField(17);

  @$pb.TagNumber(18)
  $core.int get gracePeriodDays => $_getIZ(17);
  @$pb.TagNumber(18)
  set gracePeriodDays($core.int v) { $_setSignedInt32(17, v); }
  @$pb.TagNumber(18)
  $core.bool hasGracePeriodDays() => $_has(17);
  @$pb.TagNumber(18)
  void clearGracePeriodDays() => clearField(18);

  @$pb.TagNumber(19)
  $6.Struct get feeStructure => $_getN(18);
  @$pb.TagNumber(19)
  set feeStructure($6.Struct v) { setField(19, v); }
  @$pb.TagNumber(19)
  $core.bool hasFeeStructure() => $_has(18);
  @$pb.TagNumber(19)
  void clearFeeStructure() => clearField(19);
  @$pb.TagNumber(19)
  $6.Struct ensureFeeStructure() => $_ensure(18);

  @$pb.TagNumber(20)
  $6.Struct get eligibilityCriteria => $_getN(19);
  @$pb.TagNumber(20)
  set eligibilityCriteria($6.Struct v) { setField(20, v); }
  @$pb.TagNumber(20)
  $core.bool hasEligibilityCriteria() => $_has(19);
  @$pb.TagNumber(20)
  void clearEligibilityCriteria() => clearField(20);
  @$pb.TagNumber(20)
  $6.Struct ensureEligibilityCriteria() => $_ensure(19);

  @$pb.TagNumber(21)
  $8.STATE get state => $_getN(20);
  @$pb.TagNumber(21)
  set state($8.STATE v) { setField(21, v); }
  @$pb.TagNumber(21)
  $core.bool hasState() => $_has(20);
  @$pb.TagNumber(21)
  void clearState() => clearField(21);

  @$pb.TagNumber(22)
  $6.Struct get properties => $_getN(21);
  @$pb.TagNumber(22)
  set properties($6.Struct v) { setField(22, v); }
  @$pb.TagNumber(22)
  $core.bool hasProperties() => $_has(21);
  @$pb.TagNumber(22)
  void clearProperties() => clearField(22);
  @$pb.TagNumber(22)
  $6.Struct ensureProperties() => $_ensure(21);

  @$pb.TagNumber(23)
  $core.List<ProductFormRequirement> get requiredForms => $_getList(22);
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
    $7.Money? requestedAmount,
    $7.Money? approvedAmount,
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
    $6.Struct? properties,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (productId != null) {
      $result.productId = productId;
    }
    if (clientId != null) {
      $result.clientId = clientId;
    }
    if (agentId != null) {
      $result.agentId = agentId;
    }
    if (branchId != null) {
      $result.branchId = branchId;
    }
    if (organizationId != null) {
      $result.organizationId = organizationId;
    }
    if (status != null) {
      $result.status = status;
    }
    if (requestedAmount != null) {
      $result.requestedAmount = requestedAmount;
    }
    if (approvedAmount != null) {
      $result.approvedAmount = approvedAmount;
    }
    if (requestedTermDays != null) {
      $result.requestedTermDays = requestedTermDays;
    }
    if (approvedTermDays != null) {
      $result.approvedTermDays = approvedTermDays;
    }
    if (interestRate != null) {
      $result.interestRate = interestRate;
    }
    if (currencyCode != null) {
      $result.currencyCode = currencyCode;
    }
    if (purpose != null) {
      $result.purpose = purpose;
    }
    if (rejectionReason != null) {
      $result.rejectionReason = rejectionReason;
    }
    if (offerExpiresAt != null) {
      $result.offerExpiresAt = offerExpiresAt;
    }
    if (submittedAt != null) {
      $result.submittedAt = submittedAt;
    }
    if (decidedAt != null) {
      $result.decidedAt = decidedAt;
    }
    if (loanAccountId != null) {
      $result.loanAccountId = loanAccountId;
    }
    if (sourceService != null) {
      $result.sourceService = sourceService;
    }
    if (sourceRequestId != null) {
      $result.sourceRequestId = sourceRequestId;
    }
    if (idempotencyKey != null) {
      $result.idempotencyKey = idempotencyKey;
    }
    if (properties != null) {
      $result.properties = properties;
    }
    return $result;
  }
  LoanRequestObject._() : super();
  factory LoanRequestObject.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory LoanRequestObject.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LoanRequestObject', package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'productId')
    ..aOS(3, _omitFieldNames ? '' : 'clientId')
    ..aOS(4, _omitFieldNames ? '' : 'agentId')
    ..aOS(5, _omitFieldNames ? '' : 'branchId')
    ..aOS(6, _omitFieldNames ? '' : 'organizationId')
    ..e<LoanRequestStatus>(7, _omitFieldNames ? '' : 'status', $pb.PbFieldType.OE, defaultOrMaker: LoanRequestStatus.LOAN_REQUEST_STATUS_UNSPECIFIED, valueOf: LoanRequestStatus.valueOf, enumValues: LoanRequestStatus.values)
    ..aOM<$7.Money>(8, _omitFieldNames ? '' : 'requestedAmount', subBuilder: $7.Money.create)
    ..aOM<$7.Money>(9, _omitFieldNames ? '' : 'approvedAmount', subBuilder: $7.Money.create)
    ..a<$core.int>(10, _omitFieldNames ? '' : 'requestedTermDays', $pb.PbFieldType.O3)
    ..a<$core.int>(11, _omitFieldNames ? '' : 'approvedTermDays', $pb.PbFieldType.O3)
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
    ..aOM<$6.Struct>(23, _omitFieldNames ? '' : 'properties', subBuilder: $6.Struct.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  LoanRequestObject clone() => LoanRequestObject()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  LoanRequestObject copyWith(void Function(LoanRequestObject) updates) => super.copyWith((message) => updates(message as LoanRequestObject)) as LoanRequestObject;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LoanRequestObject create() => LoanRequestObject._();
  LoanRequestObject createEmptyInstance() => create();
  static $pb.PbList<LoanRequestObject> createRepeated() => $pb.PbList<LoanRequestObject>();
  @$core.pragma('dart2js:noInline')
  static LoanRequestObject getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LoanRequestObject>(create);
  static LoanRequestObject? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get productId => $_getSZ(1);
  @$pb.TagNumber(2)
  set productId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasProductId() => $_has(1);
  @$pb.TagNumber(2)
  void clearProductId() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get clientId => $_getSZ(2);
  @$pb.TagNumber(3)
  set clientId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasClientId() => $_has(2);
  @$pb.TagNumber(3)
  void clearClientId() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get agentId => $_getSZ(3);
  @$pb.TagNumber(4)
  set agentId($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasAgentId() => $_has(3);
  @$pb.TagNumber(4)
  void clearAgentId() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get branchId => $_getSZ(4);
  @$pb.TagNumber(5)
  set branchId($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasBranchId() => $_has(4);
  @$pb.TagNumber(5)
  void clearBranchId() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get organizationId => $_getSZ(5);
  @$pb.TagNumber(6)
  set organizationId($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasOrganizationId() => $_has(5);
  @$pb.TagNumber(6)
  void clearOrganizationId() => clearField(6);

  @$pb.TagNumber(7)
  LoanRequestStatus get status => $_getN(6);
  @$pb.TagNumber(7)
  set status(LoanRequestStatus v) { setField(7, v); }
  @$pb.TagNumber(7)
  $core.bool hasStatus() => $_has(6);
  @$pb.TagNumber(7)
  void clearStatus() => clearField(7);

  @$pb.TagNumber(8)
  $7.Money get requestedAmount => $_getN(7);
  @$pb.TagNumber(8)
  set requestedAmount($7.Money v) { setField(8, v); }
  @$pb.TagNumber(8)
  $core.bool hasRequestedAmount() => $_has(7);
  @$pb.TagNumber(8)
  void clearRequestedAmount() => clearField(8);
  @$pb.TagNumber(8)
  $7.Money ensureRequestedAmount() => $_ensure(7);

  @$pb.TagNumber(9)
  $7.Money get approvedAmount => $_getN(8);
  @$pb.TagNumber(9)
  set approvedAmount($7.Money v) { setField(9, v); }
  @$pb.TagNumber(9)
  $core.bool hasApprovedAmount() => $_has(8);
  @$pb.TagNumber(9)
  void clearApprovedAmount() => clearField(9);
  @$pb.TagNumber(9)
  $7.Money ensureApprovedAmount() => $_ensure(8);

  @$pb.TagNumber(10)
  $core.int get requestedTermDays => $_getIZ(9);
  @$pb.TagNumber(10)
  set requestedTermDays($core.int v) { $_setSignedInt32(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasRequestedTermDays() => $_has(9);
  @$pb.TagNumber(10)
  void clearRequestedTermDays() => clearField(10);

  @$pb.TagNumber(11)
  $core.int get approvedTermDays => $_getIZ(10);
  @$pb.TagNumber(11)
  set approvedTermDays($core.int v) { $_setSignedInt32(10, v); }
  @$pb.TagNumber(11)
  $core.bool hasApprovedTermDays() => $_has(10);
  @$pb.TagNumber(11)
  void clearApprovedTermDays() => clearField(11);

  @$pb.TagNumber(12)
  $core.String get interestRate => $_getSZ(11);
  @$pb.TagNumber(12)
  set interestRate($core.String v) { $_setString(11, v); }
  @$pb.TagNumber(12)
  $core.bool hasInterestRate() => $_has(11);
  @$pb.TagNumber(12)
  void clearInterestRate() => clearField(12);

  @$pb.TagNumber(13)
  $core.String get currencyCode => $_getSZ(12);
  @$pb.TagNumber(13)
  set currencyCode($core.String v) { $_setString(12, v); }
  @$pb.TagNumber(13)
  $core.bool hasCurrencyCode() => $_has(12);
  @$pb.TagNumber(13)
  void clearCurrencyCode() => clearField(13);

  @$pb.TagNumber(14)
  $core.String get purpose => $_getSZ(13);
  @$pb.TagNumber(14)
  set purpose($core.String v) { $_setString(13, v); }
  @$pb.TagNumber(14)
  $core.bool hasPurpose() => $_has(13);
  @$pb.TagNumber(14)
  void clearPurpose() => clearField(14);

  @$pb.TagNumber(15)
  $core.String get rejectionReason => $_getSZ(14);
  @$pb.TagNumber(15)
  set rejectionReason($core.String v) { $_setString(14, v); }
  @$pb.TagNumber(15)
  $core.bool hasRejectionReason() => $_has(14);
  @$pb.TagNumber(15)
  void clearRejectionReason() => clearField(15);

  @$pb.TagNumber(16)
  $core.String get offerExpiresAt => $_getSZ(15);
  @$pb.TagNumber(16)
  set offerExpiresAt($core.String v) { $_setString(15, v); }
  @$pb.TagNumber(16)
  $core.bool hasOfferExpiresAt() => $_has(15);
  @$pb.TagNumber(16)
  void clearOfferExpiresAt() => clearField(16);

  @$pb.TagNumber(17)
  $core.String get submittedAt => $_getSZ(16);
  @$pb.TagNumber(17)
  set submittedAt($core.String v) { $_setString(16, v); }
  @$pb.TagNumber(17)
  $core.bool hasSubmittedAt() => $_has(16);
  @$pb.TagNumber(17)
  void clearSubmittedAt() => clearField(17);

  @$pb.TagNumber(18)
  $core.String get decidedAt => $_getSZ(17);
  @$pb.TagNumber(18)
  set decidedAt($core.String v) { $_setString(17, v); }
  @$pb.TagNumber(18)
  $core.bool hasDecidedAt() => $_has(17);
  @$pb.TagNumber(18)
  void clearDecidedAt() => clearField(18);

  @$pb.TagNumber(19)
  $core.String get loanAccountId => $_getSZ(18);
  @$pb.TagNumber(19)
  set loanAccountId($core.String v) { $_setString(18, v); }
  @$pb.TagNumber(19)
  $core.bool hasLoanAccountId() => $_has(18);
  @$pb.TagNumber(19)
  void clearLoanAccountId() => clearField(19);

  /// Source tracking: which product service created this request.
  @$pb.TagNumber(20)
  $core.String get sourceService => $_getSZ(19);
  @$pb.TagNumber(20)
  set sourceService($core.String v) { $_setString(19, v); }
  @$pb.TagNumber(20)
  $core.bool hasSourceService() => $_has(19);
  @$pb.TagNumber(20)
  void clearSourceService() => clearField(20);

  @$pb.TagNumber(21)
  $core.String get sourceRequestId => $_getSZ(20);
  @$pb.TagNumber(21)
  set sourceRequestId($core.String v) { $_setString(20, v); }
  @$pb.TagNumber(21)
  $core.bool hasSourceRequestId() => $_has(20);
  @$pb.TagNumber(21)
  void clearSourceRequestId() => clearField(21);

  @$pb.TagNumber(22)
  $core.String get idempotencyKey => $_getSZ(21);
  @$pb.TagNumber(22)
  set idempotencyKey($core.String v) { $_setString(21, v); }
  @$pb.TagNumber(22)
  $core.bool hasIdempotencyKey() => $_has(21);
  @$pb.TagNumber(22)
  void clearIdempotencyKey() => clearField(22);

  @$pb.TagNumber(23)
  $6.Struct get properties => $_getN(22);
  @$pb.TagNumber(23)
  set properties($6.Struct v) { setField(23, v); }
  @$pb.TagNumber(23)
  $core.bool hasProperties() => $_has(22);
  @$pb.TagNumber(23)
  void clearProperties() => clearField(23);
  @$pb.TagNumber(23)
  $6.Struct ensureProperties() => $_ensure(22);
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
    $8.STATE? state,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (clientId != null) {
      $result.clientId = clientId;
    }
    if (productId != null) {
      $result.productId = productId;
    }
    if (grantedBy != null) {
      $result.grantedBy = grantedBy;
    }
    if (state != null) {
      $result.state = state;
    }
    return $result;
  }
  ClientProductAccessObject._() : super();
  factory ClientProductAccessObject.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ClientProductAccessObject.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ClientProductAccessObject', package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'clientId')
    ..aOS(3, _omitFieldNames ? '' : 'productId')
    ..aOS(4, _omitFieldNames ? '' : 'grantedBy')
    ..e<$8.STATE>(5, _omitFieldNames ? '' : 'state', $pb.PbFieldType.OE, defaultOrMaker: $8.STATE.CREATED, valueOf: $8.STATE.valueOf, enumValues: $8.STATE.values)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ClientProductAccessObject clone() => ClientProductAccessObject()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ClientProductAccessObject copyWith(void Function(ClientProductAccessObject) updates) => super.copyWith((message) => updates(message as ClientProductAccessObject)) as ClientProductAccessObject;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ClientProductAccessObject create() => ClientProductAccessObject._();
  ClientProductAccessObject createEmptyInstance() => create();
  static $pb.PbList<ClientProductAccessObject> createRepeated() => $pb.PbList<ClientProductAccessObject>();
  @$core.pragma('dart2js:noInline')
  static ClientProductAccessObject getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ClientProductAccessObject>(create);
  static ClientProductAccessObject? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get clientId => $_getSZ(1);
  @$pb.TagNumber(2)
  set clientId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasClientId() => $_has(1);
  @$pb.TagNumber(2)
  void clearClientId() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get productId => $_getSZ(2);
  @$pb.TagNumber(3)
  set productId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasProductId() => $_has(2);
  @$pb.TagNumber(3)
  void clearProductId() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get grantedBy => $_getSZ(3);
  @$pb.TagNumber(4)
  set grantedBy($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasGrantedBy() => $_has(3);
  @$pb.TagNumber(4)
  void clearGrantedBy() => clearField(4);

  @$pb.TagNumber(5)
  $8.STATE get state => $_getN(4);
  @$pb.TagNumber(5)
  set state($8.STATE v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasState() => $_has(4);
  @$pb.TagNumber(5)
  void clearState() => clearField(5);
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
    $7.Money? principalAmount,
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
    $6.Struct? properties,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (loanRequestId != null) {
      $result.loanRequestId = loanRequestId;
    }
    if (productId != null) {
      $result.productId = productId;
    }
    if (clientId != null) {
      $result.clientId = clientId;
    }
    if (agentId != null) {
      $result.agentId = agentId;
    }
    if (branchId != null) {
      $result.branchId = branchId;
    }
    if (organizationId != null) {
      $result.organizationId = organizationId;
    }
    if (status != null) {
      $result.status = status;
    }
    if (principalAmount != null) {
      $result.principalAmount = principalAmount;
    }
    if (interestRate != null) {
      $result.interestRate = interestRate;
    }
    if (termDays != null) {
      $result.termDays = termDays;
    }
    if (interestMethod != null) {
      $result.interestMethod = interestMethod;
    }
    if (repaymentFrequency != null) {
      $result.repaymentFrequency = repaymentFrequency;
    }
    if (disbursedAt != null) {
      $result.disbursedAt = disbursedAt;
    }
    if (maturityDate != null) {
      $result.maturityDate = maturityDate;
    }
    if (firstRepaymentDate != null) {
      $result.firstRepaymentDate = firstRepaymentDate;
    }
    if (lastRepaymentDate != null) {
      $result.lastRepaymentDate = lastRepaymentDate;
    }
    if (daysPastDue != null) {
      $result.daysPastDue = daysPastDue;
    }
    if (ledgerAssetAccountId != null) {
      $result.ledgerAssetAccountId = ledgerAssetAccountId;
    }
    if (ledgerInterestIncomeAccountId != null) {
      $result.ledgerInterestIncomeAccountId = ledgerInterestIncomeAccountId;
    }
    if (ledgerFeeIncomeAccountId != null) {
      $result.ledgerFeeIncomeAccountId = ledgerFeeIncomeAccountId;
    }
    if (ledgerPenaltyIncomeAccountId != null) {
      $result.ledgerPenaltyIncomeAccountId = ledgerPenaltyIncomeAccountId;
    }
    if (paymentAccountRef != null) {
      $result.paymentAccountRef = paymentAccountRef;
    }
    if (properties != null) {
      $result.properties = properties;
    }
    return $result;
  }
  LoanAccountObject._() : super();
  factory LoanAccountObject.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory LoanAccountObject.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LoanAccountObject', package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'loanRequestId')
    ..aOS(3, _omitFieldNames ? '' : 'productId')
    ..aOS(4, _omitFieldNames ? '' : 'clientId')
    ..aOS(5, _omitFieldNames ? '' : 'agentId')
    ..aOS(6, _omitFieldNames ? '' : 'branchId')
    ..aOS(7, _omitFieldNames ? '' : 'organizationId')
    ..e<LoanStatus>(8, _omitFieldNames ? '' : 'status', $pb.PbFieldType.OE, defaultOrMaker: LoanStatus.LOAN_STATUS_UNSPECIFIED, valueOf: LoanStatus.valueOf, enumValues: LoanStatus.values)
    ..aOM<$7.Money>(10, _omitFieldNames ? '' : 'principalAmount', subBuilder: $7.Money.create)
    ..aOS(11, _omitFieldNames ? '' : 'interestRate')
    ..a<$core.int>(12, _omitFieldNames ? '' : 'termDays', $pb.PbFieldType.O3)
    ..e<InterestMethod>(13, _omitFieldNames ? '' : 'interestMethod', $pb.PbFieldType.OE, defaultOrMaker: InterestMethod.INTEREST_METHOD_UNSPECIFIED, valueOf: InterestMethod.valueOf, enumValues: InterestMethod.values)
    ..e<RepaymentFrequency>(14, _omitFieldNames ? '' : 'repaymentFrequency', $pb.PbFieldType.OE, defaultOrMaker: RepaymentFrequency.REPAYMENT_FREQUENCY_UNSPECIFIED, valueOf: RepaymentFrequency.valueOf, enumValues: RepaymentFrequency.values)
    ..aOS(15, _omitFieldNames ? '' : 'disbursedAt')
    ..aOS(16, _omitFieldNames ? '' : 'maturityDate')
    ..aOS(17, _omitFieldNames ? '' : 'firstRepaymentDate')
    ..aOS(18, _omitFieldNames ? '' : 'lastRepaymentDate')
    ..a<$core.int>(19, _omitFieldNames ? '' : 'daysPastDue', $pb.PbFieldType.O3)
    ..aOS(20, _omitFieldNames ? '' : 'ledgerAssetAccountId')
    ..aOS(21, _omitFieldNames ? '' : 'ledgerInterestIncomeAccountId')
    ..aOS(22, _omitFieldNames ? '' : 'ledgerFeeIncomeAccountId')
    ..aOS(23, _omitFieldNames ? '' : 'ledgerPenaltyIncomeAccountId')
    ..aOS(24, _omitFieldNames ? '' : 'paymentAccountRef')
    ..aOM<$6.Struct>(25, _omitFieldNames ? '' : 'properties', subBuilder: $6.Struct.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  LoanAccountObject clone() => LoanAccountObject()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  LoanAccountObject copyWith(void Function(LoanAccountObject) updates) => super.copyWith((message) => updates(message as LoanAccountObject)) as LoanAccountObject;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LoanAccountObject create() => LoanAccountObject._();
  LoanAccountObject createEmptyInstance() => create();
  static $pb.PbList<LoanAccountObject> createRepeated() => $pb.PbList<LoanAccountObject>();
  @$core.pragma('dart2js:noInline')
  static LoanAccountObject getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LoanAccountObject>(create);
  static LoanAccountObject? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get loanRequestId => $_getSZ(1);
  @$pb.TagNumber(2)
  set loanRequestId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasLoanRequestId() => $_has(1);
  @$pb.TagNumber(2)
  void clearLoanRequestId() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get productId => $_getSZ(2);
  @$pb.TagNumber(3)
  set productId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasProductId() => $_has(2);
  @$pb.TagNumber(3)
  void clearProductId() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get clientId => $_getSZ(3);
  @$pb.TagNumber(4)
  set clientId($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasClientId() => $_has(3);
  @$pb.TagNumber(4)
  void clearClientId() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get agentId => $_getSZ(4);
  @$pb.TagNumber(5)
  set agentId($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasAgentId() => $_has(4);
  @$pb.TagNumber(5)
  void clearAgentId() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get branchId => $_getSZ(5);
  @$pb.TagNumber(6)
  set branchId($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasBranchId() => $_has(5);
  @$pb.TagNumber(6)
  void clearBranchId() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get organizationId => $_getSZ(6);
  @$pb.TagNumber(7)
  set organizationId($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasOrganizationId() => $_has(6);
  @$pb.TagNumber(7)
  void clearOrganizationId() => clearField(7);

  @$pb.TagNumber(8)
  LoanStatus get status => $_getN(7);
  @$pb.TagNumber(8)
  set status(LoanStatus v) { setField(8, v); }
  @$pb.TagNumber(8)
  $core.bool hasStatus() => $_has(7);
  @$pb.TagNumber(8)
  void clearStatus() => clearField(8);

  /// Field 9 removed (currency_code now in Money).
  @$pb.TagNumber(10)
  $7.Money get principalAmount => $_getN(8);
  @$pb.TagNumber(10)
  set principalAmount($7.Money v) { setField(10, v); }
  @$pb.TagNumber(10)
  $core.bool hasPrincipalAmount() => $_has(8);
  @$pb.TagNumber(10)
  void clearPrincipalAmount() => clearField(10);
  @$pb.TagNumber(10)
  $7.Money ensurePrincipalAmount() => $_ensure(8);

  @$pb.TagNumber(11)
  $core.String get interestRate => $_getSZ(9);
  @$pb.TagNumber(11)
  set interestRate($core.String v) { $_setString(9, v); }
  @$pb.TagNumber(11)
  $core.bool hasInterestRate() => $_has(9);
  @$pb.TagNumber(11)
  void clearInterestRate() => clearField(11);

  @$pb.TagNumber(12)
  $core.int get termDays => $_getIZ(10);
  @$pb.TagNumber(12)
  set termDays($core.int v) { $_setSignedInt32(10, v); }
  @$pb.TagNumber(12)
  $core.bool hasTermDays() => $_has(10);
  @$pb.TagNumber(12)
  void clearTermDays() => clearField(12);

  @$pb.TagNumber(13)
  InterestMethod get interestMethod => $_getN(11);
  @$pb.TagNumber(13)
  set interestMethod(InterestMethod v) { setField(13, v); }
  @$pb.TagNumber(13)
  $core.bool hasInterestMethod() => $_has(11);
  @$pb.TagNumber(13)
  void clearInterestMethod() => clearField(13);

  @$pb.TagNumber(14)
  RepaymentFrequency get repaymentFrequency => $_getN(12);
  @$pb.TagNumber(14)
  set repaymentFrequency(RepaymentFrequency v) { setField(14, v); }
  @$pb.TagNumber(14)
  $core.bool hasRepaymentFrequency() => $_has(12);
  @$pb.TagNumber(14)
  void clearRepaymentFrequency() => clearField(14);

  @$pb.TagNumber(15)
  $core.String get disbursedAt => $_getSZ(13);
  @$pb.TagNumber(15)
  set disbursedAt($core.String v) { $_setString(13, v); }
  @$pb.TagNumber(15)
  $core.bool hasDisbursedAt() => $_has(13);
  @$pb.TagNumber(15)
  void clearDisbursedAt() => clearField(15);

  @$pb.TagNumber(16)
  $core.String get maturityDate => $_getSZ(14);
  @$pb.TagNumber(16)
  set maturityDate($core.String v) { $_setString(14, v); }
  @$pb.TagNumber(16)
  $core.bool hasMaturityDate() => $_has(14);
  @$pb.TagNumber(16)
  void clearMaturityDate() => clearField(16);

  @$pb.TagNumber(17)
  $core.String get firstRepaymentDate => $_getSZ(15);
  @$pb.TagNumber(17)
  set firstRepaymentDate($core.String v) { $_setString(15, v); }
  @$pb.TagNumber(17)
  $core.bool hasFirstRepaymentDate() => $_has(15);
  @$pb.TagNumber(17)
  void clearFirstRepaymentDate() => clearField(17);

  @$pb.TagNumber(18)
  $core.String get lastRepaymentDate => $_getSZ(16);
  @$pb.TagNumber(18)
  set lastRepaymentDate($core.String v) { $_setString(16, v); }
  @$pb.TagNumber(18)
  $core.bool hasLastRepaymentDate() => $_has(16);
  @$pb.TagNumber(18)
  void clearLastRepaymentDate() => clearField(18);

  @$pb.TagNumber(19)
  $core.int get daysPastDue => $_getIZ(17);
  @$pb.TagNumber(19)
  set daysPastDue($core.int v) { $_setSignedInt32(17, v); }
  @$pb.TagNumber(19)
  $core.bool hasDaysPastDue() => $_has(17);
  @$pb.TagNumber(19)
  void clearDaysPastDue() => clearField(19);

  @$pb.TagNumber(20)
  $core.String get ledgerAssetAccountId => $_getSZ(18);
  @$pb.TagNumber(20)
  set ledgerAssetAccountId($core.String v) { $_setString(18, v); }
  @$pb.TagNumber(20)
  $core.bool hasLedgerAssetAccountId() => $_has(18);
  @$pb.TagNumber(20)
  void clearLedgerAssetAccountId() => clearField(20);

  @$pb.TagNumber(21)
  $core.String get ledgerInterestIncomeAccountId => $_getSZ(19);
  @$pb.TagNumber(21)
  set ledgerInterestIncomeAccountId($core.String v) { $_setString(19, v); }
  @$pb.TagNumber(21)
  $core.bool hasLedgerInterestIncomeAccountId() => $_has(19);
  @$pb.TagNumber(21)
  void clearLedgerInterestIncomeAccountId() => clearField(21);

  @$pb.TagNumber(22)
  $core.String get ledgerFeeIncomeAccountId => $_getSZ(20);
  @$pb.TagNumber(22)
  set ledgerFeeIncomeAccountId($core.String v) { $_setString(20, v); }
  @$pb.TagNumber(22)
  $core.bool hasLedgerFeeIncomeAccountId() => $_has(20);
  @$pb.TagNumber(22)
  void clearLedgerFeeIncomeAccountId() => clearField(22);

  @$pb.TagNumber(23)
  $core.String get ledgerPenaltyIncomeAccountId => $_getSZ(21);
  @$pb.TagNumber(23)
  set ledgerPenaltyIncomeAccountId($core.String v) { $_setString(21, v); }
  @$pb.TagNumber(23)
  $core.bool hasLedgerPenaltyIncomeAccountId() => $_has(21);
  @$pb.TagNumber(23)
  void clearLedgerPenaltyIncomeAccountId() => clearField(23);

  @$pb.TagNumber(24)
  $core.String get paymentAccountRef => $_getSZ(22);
  @$pb.TagNumber(24)
  set paymentAccountRef($core.String v) { $_setString(22, v); }
  @$pb.TagNumber(24)
  $core.bool hasPaymentAccountRef() => $_has(22);
  @$pb.TagNumber(24)
  void clearPaymentAccountRef() => clearField(24);

  @$pb.TagNumber(25)
  $6.Struct get properties => $_getN(23);
  @$pb.TagNumber(25)
  set properties($6.Struct v) { setField(25, v); }
  @$pb.TagNumber(25)
  $core.bool hasProperties() => $_has(23);
  @$pb.TagNumber(25)
  void clearProperties() => clearField(25);
  @$pb.TagNumber(25)
  $6.Struct ensureProperties() => $_ensure(23);
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
    $6.Struct? properties,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (loanAccountId != null) {
      $result.loanAccountId = loanAccountId;
    }
    if (version != null) {
      $result.version = version;
    }
    if (isActive != null) {
      $result.isActive = isActive;
    }
    if (generatedAt != null) {
      $result.generatedAt = generatedAt;
    }
    if (entries != null) {
      $result.entries.addAll(entries);
    }
    if (properties != null) {
      $result.properties = properties;
    }
    return $result;
  }
  RepaymentScheduleObject._() : super();
  factory RepaymentScheduleObject.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory RepaymentScheduleObject.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RepaymentScheduleObject', package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'loanAccountId')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'version', $pb.PbFieldType.O3)
    ..aOB(4, _omitFieldNames ? '' : 'isActive')
    ..aOS(5, _omitFieldNames ? '' : 'generatedAt')
    ..pc<ScheduleEntryObject>(6, _omitFieldNames ? '' : 'entries', $pb.PbFieldType.PM, subBuilder: ScheduleEntryObject.create)
    ..aOM<$6.Struct>(7, _omitFieldNames ? '' : 'properties', subBuilder: $6.Struct.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  RepaymentScheduleObject clone() => RepaymentScheduleObject()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  RepaymentScheduleObject copyWith(void Function(RepaymentScheduleObject) updates) => super.copyWith((message) => updates(message as RepaymentScheduleObject)) as RepaymentScheduleObject;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RepaymentScheduleObject create() => RepaymentScheduleObject._();
  RepaymentScheduleObject createEmptyInstance() => create();
  static $pb.PbList<RepaymentScheduleObject> createRepeated() => $pb.PbList<RepaymentScheduleObject>();
  @$core.pragma('dart2js:noInline')
  static RepaymentScheduleObject getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RepaymentScheduleObject>(create);
  static RepaymentScheduleObject? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get loanAccountId => $_getSZ(1);
  @$pb.TagNumber(2)
  set loanAccountId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasLoanAccountId() => $_has(1);
  @$pb.TagNumber(2)
  void clearLoanAccountId() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get version => $_getIZ(2);
  @$pb.TagNumber(3)
  set version($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasVersion() => $_has(2);
  @$pb.TagNumber(3)
  void clearVersion() => clearField(3);

  @$pb.TagNumber(4)
  $core.bool get isActive => $_getBF(3);
  @$pb.TagNumber(4)
  set isActive($core.bool v) { $_setBool(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasIsActive() => $_has(3);
  @$pb.TagNumber(4)
  void clearIsActive() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get generatedAt => $_getSZ(4);
  @$pb.TagNumber(5)
  set generatedAt($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasGeneratedAt() => $_has(4);
  @$pb.TagNumber(5)
  void clearGeneratedAt() => clearField(5);

  @$pb.TagNumber(6)
  $core.List<ScheduleEntryObject> get entries => $_getList(5);

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

/// ScheduleEntryObject represents an individual installment in a repayment schedule.
class ScheduleEntryObject extends $pb.GeneratedMessage {
  factory ScheduleEntryObject({
    $core.String? id,
    $core.String? scheduleId,
    $core.int? installmentNumber,
    $core.String? dueDate,
    $7.Money? principalDue,
    $7.Money? interestDue,
    $7.Money? feesDue,
    $7.Money? totalDue,
    $7.Money? principalPaid,
    $7.Money? interestPaid,
    $7.Money? feesPaid,
    $7.Money? totalPaid,
    $7.Money? outstanding,
    ScheduleEntryStatus? status,
    $core.String? paidDate,
    $6.Struct? properties,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (scheduleId != null) {
      $result.scheduleId = scheduleId;
    }
    if (installmentNumber != null) {
      $result.installmentNumber = installmentNumber;
    }
    if (dueDate != null) {
      $result.dueDate = dueDate;
    }
    if (principalDue != null) {
      $result.principalDue = principalDue;
    }
    if (interestDue != null) {
      $result.interestDue = interestDue;
    }
    if (feesDue != null) {
      $result.feesDue = feesDue;
    }
    if (totalDue != null) {
      $result.totalDue = totalDue;
    }
    if (principalPaid != null) {
      $result.principalPaid = principalPaid;
    }
    if (interestPaid != null) {
      $result.interestPaid = interestPaid;
    }
    if (feesPaid != null) {
      $result.feesPaid = feesPaid;
    }
    if (totalPaid != null) {
      $result.totalPaid = totalPaid;
    }
    if (outstanding != null) {
      $result.outstanding = outstanding;
    }
    if (status != null) {
      $result.status = status;
    }
    if (paidDate != null) {
      $result.paidDate = paidDate;
    }
    if (properties != null) {
      $result.properties = properties;
    }
    return $result;
  }
  ScheduleEntryObject._() : super();
  factory ScheduleEntryObject.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ScheduleEntryObject.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ScheduleEntryObject', package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'scheduleId')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'installmentNumber', $pb.PbFieldType.O3)
    ..aOS(4, _omitFieldNames ? '' : 'dueDate')
    ..aOM<$7.Money>(5, _omitFieldNames ? '' : 'principalDue', subBuilder: $7.Money.create)
    ..aOM<$7.Money>(6, _omitFieldNames ? '' : 'interestDue', subBuilder: $7.Money.create)
    ..aOM<$7.Money>(7, _omitFieldNames ? '' : 'feesDue', subBuilder: $7.Money.create)
    ..aOM<$7.Money>(8, _omitFieldNames ? '' : 'totalDue', subBuilder: $7.Money.create)
    ..aOM<$7.Money>(9, _omitFieldNames ? '' : 'principalPaid', subBuilder: $7.Money.create)
    ..aOM<$7.Money>(10, _omitFieldNames ? '' : 'interestPaid', subBuilder: $7.Money.create)
    ..aOM<$7.Money>(11, _omitFieldNames ? '' : 'feesPaid', subBuilder: $7.Money.create)
    ..aOM<$7.Money>(12, _omitFieldNames ? '' : 'totalPaid', subBuilder: $7.Money.create)
    ..aOM<$7.Money>(13, _omitFieldNames ? '' : 'outstanding', subBuilder: $7.Money.create)
    ..e<ScheduleEntryStatus>(14, _omitFieldNames ? '' : 'status', $pb.PbFieldType.OE, defaultOrMaker: ScheduleEntryStatus.SCHEDULE_ENTRY_STATUS_UNSPECIFIED, valueOf: ScheduleEntryStatus.valueOf, enumValues: ScheduleEntryStatus.values)
    ..aOS(15, _omitFieldNames ? '' : 'paidDate')
    ..aOM<$6.Struct>(16, _omitFieldNames ? '' : 'properties', subBuilder: $6.Struct.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ScheduleEntryObject clone() => ScheduleEntryObject()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ScheduleEntryObject copyWith(void Function(ScheduleEntryObject) updates) => super.copyWith((message) => updates(message as ScheduleEntryObject)) as ScheduleEntryObject;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ScheduleEntryObject create() => ScheduleEntryObject._();
  ScheduleEntryObject createEmptyInstance() => create();
  static $pb.PbList<ScheduleEntryObject> createRepeated() => $pb.PbList<ScheduleEntryObject>();
  @$core.pragma('dart2js:noInline')
  static ScheduleEntryObject getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ScheduleEntryObject>(create);
  static ScheduleEntryObject? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get scheduleId => $_getSZ(1);
  @$pb.TagNumber(2)
  set scheduleId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasScheduleId() => $_has(1);
  @$pb.TagNumber(2)
  void clearScheduleId() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get installmentNumber => $_getIZ(2);
  @$pb.TagNumber(3)
  set installmentNumber($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasInstallmentNumber() => $_has(2);
  @$pb.TagNumber(3)
  void clearInstallmentNumber() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get dueDate => $_getSZ(3);
  @$pb.TagNumber(4)
  set dueDate($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasDueDate() => $_has(3);
  @$pb.TagNumber(4)
  void clearDueDate() => clearField(4);

  @$pb.TagNumber(5)
  $7.Money get principalDue => $_getN(4);
  @$pb.TagNumber(5)
  set principalDue($7.Money v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasPrincipalDue() => $_has(4);
  @$pb.TagNumber(5)
  void clearPrincipalDue() => clearField(5);
  @$pb.TagNumber(5)
  $7.Money ensurePrincipalDue() => $_ensure(4);

  @$pb.TagNumber(6)
  $7.Money get interestDue => $_getN(5);
  @$pb.TagNumber(6)
  set interestDue($7.Money v) { setField(6, v); }
  @$pb.TagNumber(6)
  $core.bool hasInterestDue() => $_has(5);
  @$pb.TagNumber(6)
  void clearInterestDue() => clearField(6);
  @$pb.TagNumber(6)
  $7.Money ensureInterestDue() => $_ensure(5);

  @$pb.TagNumber(7)
  $7.Money get feesDue => $_getN(6);
  @$pb.TagNumber(7)
  set feesDue($7.Money v) { setField(7, v); }
  @$pb.TagNumber(7)
  $core.bool hasFeesDue() => $_has(6);
  @$pb.TagNumber(7)
  void clearFeesDue() => clearField(7);
  @$pb.TagNumber(7)
  $7.Money ensureFeesDue() => $_ensure(6);

  @$pb.TagNumber(8)
  $7.Money get totalDue => $_getN(7);
  @$pb.TagNumber(8)
  set totalDue($7.Money v) { setField(8, v); }
  @$pb.TagNumber(8)
  $core.bool hasTotalDue() => $_has(7);
  @$pb.TagNumber(8)
  void clearTotalDue() => clearField(8);
  @$pb.TagNumber(8)
  $7.Money ensureTotalDue() => $_ensure(7);

  @$pb.TagNumber(9)
  $7.Money get principalPaid => $_getN(8);
  @$pb.TagNumber(9)
  set principalPaid($7.Money v) { setField(9, v); }
  @$pb.TagNumber(9)
  $core.bool hasPrincipalPaid() => $_has(8);
  @$pb.TagNumber(9)
  void clearPrincipalPaid() => clearField(9);
  @$pb.TagNumber(9)
  $7.Money ensurePrincipalPaid() => $_ensure(8);

  @$pb.TagNumber(10)
  $7.Money get interestPaid => $_getN(9);
  @$pb.TagNumber(10)
  set interestPaid($7.Money v) { setField(10, v); }
  @$pb.TagNumber(10)
  $core.bool hasInterestPaid() => $_has(9);
  @$pb.TagNumber(10)
  void clearInterestPaid() => clearField(10);
  @$pb.TagNumber(10)
  $7.Money ensureInterestPaid() => $_ensure(9);

  @$pb.TagNumber(11)
  $7.Money get feesPaid => $_getN(10);
  @$pb.TagNumber(11)
  set feesPaid($7.Money v) { setField(11, v); }
  @$pb.TagNumber(11)
  $core.bool hasFeesPaid() => $_has(10);
  @$pb.TagNumber(11)
  void clearFeesPaid() => clearField(11);
  @$pb.TagNumber(11)
  $7.Money ensureFeesPaid() => $_ensure(10);

  @$pb.TagNumber(12)
  $7.Money get totalPaid => $_getN(11);
  @$pb.TagNumber(12)
  set totalPaid($7.Money v) { setField(12, v); }
  @$pb.TagNumber(12)
  $core.bool hasTotalPaid() => $_has(11);
  @$pb.TagNumber(12)
  void clearTotalPaid() => clearField(12);
  @$pb.TagNumber(12)
  $7.Money ensureTotalPaid() => $_ensure(11);

  @$pb.TagNumber(13)
  $7.Money get outstanding => $_getN(12);
  @$pb.TagNumber(13)
  set outstanding($7.Money v) { setField(13, v); }
  @$pb.TagNumber(13)
  $core.bool hasOutstanding() => $_has(12);
  @$pb.TagNumber(13)
  void clearOutstanding() => clearField(13);
  @$pb.TagNumber(13)
  $7.Money ensureOutstanding() => $_ensure(12);

  @$pb.TagNumber(14)
  ScheduleEntryStatus get status => $_getN(13);
  @$pb.TagNumber(14)
  set status(ScheduleEntryStatus v) { setField(14, v); }
  @$pb.TagNumber(14)
  $core.bool hasStatus() => $_has(13);
  @$pb.TagNumber(14)
  void clearStatus() => clearField(14);

  @$pb.TagNumber(15)
  $core.String get paidDate => $_getSZ(14);
  @$pb.TagNumber(15)
  set paidDate($core.String v) { $_setString(14, v); }
  @$pb.TagNumber(15)
  $core.bool hasPaidDate() => $_has(14);
  @$pb.TagNumber(15)
  void clearPaidDate() => clearField(15);

  @$pb.TagNumber(16)
  $6.Struct get properties => $_getN(15);
  @$pb.TagNumber(16)
  set properties($6.Struct v) { setField(16, v); }
  @$pb.TagNumber(16)
  $core.bool hasProperties() => $_has(15);
  @$pb.TagNumber(16)
  void clearProperties() => clearField(16);
  @$pb.TagNumber(16)
  $6.Struct ensureProperties() => $_ensure(15);
}

/// LoanBalanceObject represents the current balance snapshot of a loan.
class LoanBalanceObject extends $pb.GeneratedMessage {
  factory LoanBalanceObject({
    $core.String? loanAccountId,
    $7.Money? principalOutstanding,
    $7.Money? interestAccrued,
    $7.Money? feesOutstanding,
    $7.Money? penaltiesOutstanding,
    $7.Money? totalOutstanding,
    $7.Money? totalPaid,
    $7.Money? totalDisbursed,
    $core.String? lastCalculatedAt,
  }) {
    final $result = create();
    if (loanAccountId != null) {
      $result.loanAccountId = loanAccountId;
    }
    if (principalOutstanding != null) {
      $result.principalOutstanding = principalOutstanding;
    }
    if (interestAccrued != null) {
      $result.interestAccrued = interestAccrued;
    }
    if (feesOutstanding != null) {
      $result.feesOutstanding = feesOutstanding;
    }
    if (penaltiesOutstanding != null) {
      $result.penaltiesOutstanding = penaltiesOutstanding;
    }
    if (totalOutstanding != null) {
      $result.totalOutstanding = totalOutstanding;
    }
    if (totalPaid != null) {
      $result.totalPaid = totalPaid;
    }
    if (totalDisbursed != null) {
      $result.totalDisbursed = totalDisbursed;
    }
    if (lastCalculatedAt != null) {
      $result.lastCalculatedAt = lastCalculatedAt;
    }
    return $result;
  }
  LoanBalanceObject._() : super();
  factory LoanBalanceObject.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory LoanBalanceObject.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LoanBalanceObject', package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'loanAccountId')
    ..aOM<$7.Money>(2, _omitFieldNames ? '' : 'principalOutstanding', subBuilder: $7.Money.create)
    ..aOM<$7.Money>(3, _omitFieldNames ? '' : 'interestAccrued', subBuilder: $7.Money.create)
    ..aOM<$7.Money>(4, _omitFieldNames ? '' : 'feesOutstanding', subBuilder: $7.Money.create)
    ..aOM<$7.Money>(5, _omitFieldNames ? '' : 'penaltiesOutstanding', subBuilder: $7.Money.create)
    ..aOM<$7.Money>(6, _omitFieldNames ? '' : 'totalOutstanding', subBuilder: $7.Money.create)
    ..aOM<$7.Money>(7, _omitFieldNames ? '' : 'totalPaid', subBuilder: $7.Money.create)
    ..aOM<$7.Money>(8, _omitFieldNames ? '' : 'totalDisbursed', subBuilder: $7.Money.create)
    ..aOS(9, _omitFieldNames ? '' : 'lastCalculatedAt')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  LoanBalanceObject clone() => LoanBalanceObject()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  LoanBalanceObject copyWith(void Function(LoanBalanceObject) updates) => super.copyWith((message) => updates(message as LoanBalanceObject)) as LoanBalanceObject;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LoanBalanceObject create() => LoanBalanceObject._();
  LoanBalanceObject createEmptyInstance() => create();
  static $pb.PbList<LoanBalanceObject> createRepeated() => $pb.PbList<LoanBalanceObject>();
  @$core.pragma('dart2js:noInline')
  static LoanBalanceObject getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LoanBalanceObject>(create);
  static LoanBalanceObject? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get loanAccountId => $_getSZ(0);
  @$pb.TagNumber(1)
  set loanAccountId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasLoanAccountId() => $_has(0);
  @$pb.TagNumber(1)
  void clearLoanAccountId() => clearField(1);

  @$pb.TagNumber(2)
  $7.Money get principalOutstanding => $_getN(1);
  @$pb.TagNumber(2)
  set principalOutstanding($7.Money v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasPrincipalOutstanding() => $_has(1);
  @$pb.TagNumber(2)
  void clearPrincipalOutstanding() => clearField(2);
  @$pb.TagNumber(2)
  $7.Money ensurePrincipalOutstanding() => $_ensure(1);

  @$pb.TagNumber(3)
  $7.Money get interestAccrued => $_getN(2);
  @$pb.TagNumber(3)
  set interestAccrued($7.Money v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasInterestAccrued() => $_has(2);
  @$pb.TagNumber(3)
  void clearInterestAccrued() => clearField(3);
  @$pb.TagNumber(3)
  $7.Money ensureInterestAccrued() => $_ensure(2);

  @$pb.TagNumber(4)
  $7.Money get feesOutstanding => $_getN(3);
  @$pb.TagNumber(4)
  set feesOutstanding($7.Money v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasFeesOutstanding() => $_has(3);
  @$pb.TagNumber(4)
  void clearFeesOutstanding() => clearField(4);
  @$pb.TagNumber(4)
  $7.Money ensureFeesOutstanding() => $_ensure(3);

  @$pb.TagNumber(5)
  $7.Money get penaltiesOutstanding => $_getN(4);
  @$pb.TagNumber(5)
  set penaltiesOutstanding($7.Money v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasPenaltiesOutstanding() => $_has(4);
  @$pb.TagNumber(5)
  void clearPenaltiesOutstanding() => clearField(5);
  @$pb.TagNumber(5)
  $7.Money ensurePenaltiesOutstanding() => $_ensure(4);

  @$pb.TagNumber(6)
  $7.Money get totalOutstanding => $_getN(5);
  @$pb.TagNumber(6)
  set totalOutstanding($7.Money v) { setField(6, v); }
  @$pb.TagNumber(6)
  $core.bool hasTotalOutstanding() => $_has(5);
  @$pb.TagNumber(6)
  void clearTotalOutstanding() => clearField(6);
  @$pb.TagNumber(6)
  $7.Money ensureTotalOutstanding() => $_ensure(5);

  @$pb.TagNumber(7)
  $7.Money get totalPaid => $_getN(6);
  @$pb.TagNumber(7)
  set totalPaid($7.Money v) { setField(7, v); }
  @$pb.TagNumber(7)
  $core.bool hasTotalPaid() => $_has(6);
  @$pb.TagNumber(7)
  void clearTotalPaid() => clearField(7);
  @$pb.TagNumber(7)
  $7.Money ensureTotalPaid() => $_ensure(6);

  @$pb.TagNumber(8)
  $7.Money get totalDisbursed => $_getN(7);
  @$pb.TagNumber(8)
  set totalDisbursed($7.Money v) { setField(8, v); }
  @$pb.TagNumber(8)
  $core.bool hasTotalDisbursed() => $_has(7);
  @$pb.TagNumber(8)
  void clearTotalDisbursed() => clearField(8);
  @$pb.TagNumber(8)
  $7.Money ensureTotalDisbursed() => $_ensure(7);

  @$pb.TagNumber(9)
  $core.String get lastCalculatedAt => $_getSZ(8);
  @$pb.TagNumber(9)
  set lastCalculatedAt($core.String v) { $_setString(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasLastCalculatedAt() => $_has(8);
  @$pb.TagNumber(9)
  void clearLastCalculatedAt() => clearField(9);
}

/// DisbursementObject represents a loan amount paid out to the client.
class DisbursementObject extends $pb.GeneratedMessage {
  factory DisbursementObject({
    $core.String? id,
    $core.String? loanAccountId,
    $7.Money? amount,
    DisbursementStatus? status,
    $core.String? paymentReference,
    $core.String? ledgerTransactionId,
    $core.String? disbursedAt,
    $core.String? channel,
    $core.String? recipientReference,
    $core.String? failureReason,
    $core.String? idempotencyKey,
    $6.Struct? properties,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (loanAccountId != null) {
      $result.loanAccountId = loanAccountId;
    }
    if (amount != null) {
      $result.amount = amount;
    }
    if (status != null) {
      $result.status = status;
    }
    if (paymentReference != null) {
      $result.paymentReference = paymentReference;
    }
    if (ledgerTransactionId != null) {
      $result.ledgerTransactionId = ledgerTransactionId;
    }
    if (disbursedAt != null) {
      $result.disbursedAt = disbursedAt;
    }
    if (channel != null) {
      $result.channel = channel;
    }
    if (recipientReference != null) {
      $result.recipientReference = recipientReference;
    }
    if (failureReason != null) {
      $result.failureReason = failureReason;
    }
    if (idempotencyKey != null) {
      $result.idempotencyKey = idempotencyKey;
    }
    if (properties != null) {
      $result.properties = properties;
    }
    return $result;
  }
  DisbursementObject._() : super();
  factory DisbursementObject.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DisbursementObject.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DisbursementObject', package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'loanAccountId')
    ..aOM<$7.Money>(3, _omitFieldNames ? '' : 'amount', subBuilder: $7.Money.create)
    ..e<DisbursementStatus>(5, _omitFieldNames ? '' : 'status', $pb.PbFieldType.OE, defaultOrMaker: DisbursementStatus.DISBURSEMENT_STATUS_UNSPECIFIED, valueOf: DisbursementStatus.valueOf, enumValues: DisbursementStatus.values)
    ..aOS(6, _omitFieldNames ? '' : 'paymentReference')
    ..aOS(7, _omitFieldNames ? '' : 'ledgerTransactionId')
    ..aOS(8, _omitFieldNames ? '' : 'disbursedAt')
    ..aOS(9, _omitFieldNames ? '' : 'channel')
    ..aOS(10, _omitFieldNames ? '' : 'recipientReference')
    ..aOS(11, _omitFieldNames ? '' : 'failureReason')
    ..aOS(12, _omitFieldNames ? '' : 'idempotencyKey')
    ..aOM<$6.Struct>(13, _omitFieldNames ? '' : 'properties', subBuilder: $6.Struct.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DisbursementObject clone() => DisbursementObject()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DisbursementObject copyWith(void Function(DisbursementObject) updates) => super.copyWith((message) => updates(message as DisbursementObject)) as DisbursementObject;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DisbursementObject create() => DisbursementObject._();
  DisbursementObject createEmptyInstance() => create();
  static $pb.PbList<DisbursementObject> createRepeated() => $pb.PbList<DisbursementObject>();
  @$core.pragma('dart2js:noInline')
  static DisbursementObject getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DisbursementObject>(create);
  static DisbursementObject? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get loanAccountId => $_getSZ(1);
  @$pb.TagNumber(2)
  set loanAccountId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasLoanAccountId() => $_has(1);
  @$pb.TagNumber(2)
  void clearLoanAccountId() => clearField(2);

  @$pb.TagNumber(3)
  $7.Money get amount => $_getN(2);
  @$pb.TagNumber(3)
  set amount($7.Money v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasAmount() => $_has(2);
  @$pb.TagNumber(3)
  void clearAmount() => clearField(3);
  @$pb.TagNumber(3)
  $7.Money ensureAmount() => $_ensure(2);

  /// Field 4 removed (currency_code now in Money).
  @$pb.TagNumber(5)
  DisbursementStatus get status => $_getN(3);
  @$pb.TagNumber(5)
  set status(DisbursementStatus v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasStatus() => $_has(3);
  @$pb.TagNumber(5)
  void clearStatus() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get paymentReference => $_getSZ(4);
  @$pb.TagNumber(6)
  set paymentReference($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(6)
  $core.bool hasPaymentReference() => $_has(4);
  @$pb.TagNumber(6)
  void clearPaymentReference() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get ledgerTransactionId => $_getSZ(5);
  @$pb.TagNumber(7)
  set ledgerTransactionId($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(7)
  $core.bool hasLedgerTransactionId() => $_has(5);
  @$pb.TagNumber(7)
  void clearLedgerTransactionId() => clearField(7);

  @$pb.TagNumber(8)
  $core.String get disbursedAt => $_getSZ(6);
  @$pb.TagNumber(8)
  set disbursedAt($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(8)
  $core.bool hasDisbursedAt() => $_has(6);
  @$pb.TagNumber(8)
  void clearDisbursedAt() => clearField(8);

  @$pb.TagNumber(9)
  $core.String get channel => $_getSZ(7);
  @$pb.TagNumber(9)
  set channel($core.String v) { $_setString(7, v); }
  @$pb.TagNumber(9)
  $core.bool hasChannel() => $_has(7);
  @$pb.TagNumber(9)
  void clearChannel() => clearField(9);

  @$pb.TagNumber(10)
  $core.String get recipientReference => $_getSZ(8);
  @$pb.TagNumber(10)
  set recipientReference($core.String v) { $_setString(8, v); }
  @$pb.TagNumber(10)
  $core.bool hasRecipientReference() => $_has(8);
  @$pb.TagNumber(10)
  void clearRecipientReference() => clearField(10);

  @$pb.TagNumber(11)
  $core.String get failureReason => $_getSZ(9);
  @$pb.TagNumber(11)
  set failureReason($core.String v) { $_setString(9, v); }
  @$pb.TagNumber(11)
  $core.bool hasFailureReason() => $_has(9);
  @$pb.TagNumber(11)
  void clearFailureReason() => clearField(11);

  @$pb.TagNumber(12)
  $core.String get idempotencyKey => $_getSZ(10);
  @$pb.TagNumber(12)
  set idempotencyKey($core.String v) { $_setString(10, v); }
  @$pb.TagNumber(12)
  $core.bool hasIdempotencyKey() => $_has(10);
  @$pb.TagNumber(12)
  void clearIdempotencyKey() => clearField(12);

  @$pb.TagNumber(13)
  $6.Struct get properties => $_getN(11);
  @$pb.TagNumber(13)
  set properties($6.Struct v) { setField(13, v); }
  @$pb.TagNumber(13)
  $core.bool hasProperties() => $_has(11);
  @$pb.TagNumber(13)
  void clearProperties() => clearField(13);
  @$pb.TagNumber(13)
  $6.Struct ensureProperties() => $_ensure(11);
}

/// RepaymentObject represents an incoming payment record for a loan.
class RepaymentObject extends $pb.GeneratedMessage {
  factory RepaymentObject({
    $core.String? id,
    $core.String? loanAccountId,
    $7.Money? amount,
    RepaymentStatus? status,
    $core.String? paymentReference,
    $core.String? ledgerTransactionId,
    $core.String? receivedAt,
    $core.String? channel,
    $core.String? payerReference,
    $7.Money? principalApplied,
    $7.Money? interestApplied,
    $7.Money? feesApplied,
    $7.Money? penaltiesApplied,
    $7.Money? excessAmount,
    $core.String? idempotencyKey,
    $6.Struct? properties,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (loanAccountId != null) {
      $result.loanAccountId = loanAccountId;
    }
    if (amount != null) {
      $result.amount = amount;
    }
    if (status != null) {
      $result.status = status;
    }
    if (paymentReference != null) {
      $result.paymentReference = paymentReference;
    }
    if (ledgerTransactionId != null) {
      $result.ledgerTransactionId = ledgerTransactionId;
    }
    if (receivedAt != null) {
      $result.receivedAt = receivedAt;
    }
    if (channel != null) {
      $result.channel = channel;
    }
    if (payerReference != null) {
      $result.payerReference = payerReference;
    }
    if (principalApplied != null) {
      $result.principalApplied = principalApplied;
    }
    if (interestApplied != null) {
      $result.interestApplied = interestApplied;
    }
    if (feesApplied != null) {
      $result.feesApplied = feesApplied;
    }
    if (penaltiesApplied != null) {
      $result.penaltiesApplied = penaltiesApplied;
    }
    if (excessAmount != null) {
      $result.excessAmount = excessAmount;
    }
    if (idempotencyKey != null) {
      $result.idempotencyKey = idempotencyKey;
    }
    if (properties != null) {
      $result.properties = properties;
    }
    return $result;
  }
  RepaymentObject._() : super();
  factory RepaymentObject.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory RepaymentObject.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RepaymentObject', package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'loanAccountId')
    ..aOM<$7.Money>(3, _omitFieldNames ? '' : 'amount', subBuilder: $7.Money.create)
    ..e<RepaymentStatus>(5, _omitFieldNames ? '' : 'status', $pb.PbFieldType.OE, defaultOrMaker: RepaymentStatus.REPAYMENT_STATUS_UNSPECIFIED, valueOf: RepaymentStatus.valueOf, enumValues: RepaymentStatus.values)
    ..aOS(6, _omitFieldNames ? '' : 'paymentReference')
    ..aOS(7, _omitFieldNames ? '' : 'ledgerTransactionId')
    ..aOS(8, _omitFieldNames ? '' : 'receivedAt')
    ..aOS(9, _omitFieldNames ? '' : 'channel')
    ..aOS(10, _omitFieldNames ? '' : 'payerReference')
    ..aOM<$7.Money>(11, _omitFieldNames ? '' : 'principalApplied', subBuilder: $7.Money.create)
    ..aOM<$7.Money>(12, _omitFieldNames ? '' : 'interestApplied', subBuilder: $7.Money.create)
    ..aOM<$7.Money>(13, _omitFieldNames ? '' : 'feesApplied', subBuilder: $7.Money.create)
    ..aOM<$7.Money>(14, _omitFieldNames ? '' : 'penaltiesApplied', subBuilder: $7.Money.create)
    ..aOM<$7.Money>(15, _omitFieldNames ? '' : 'excessAmount', subBuilder: $7.Money.create)
    ..aOS(16, _omitFieldNames ? '' : 'idempotencyKey')
    ..aOM<$6.Struct>(17, _omitFieldNames ? '' : 'properties', subBuilder: $6.Struct.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  RepaymentObject clone() => RepaymentObject()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  RepaymentObject copyWith(void Function(RepaymentObject) updates) => super.copyWith((message) => updates(message as RepaymentObject)) as RepaymentObject;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RepaymentObject create() => RepaymentObject._();
  RepaymentObject createEmptyInstance() => create();
  static $pb.PbList<RepaymentObject> createRepeated() => $pb.PbList<RepaymentObject>();
  @$core.pragma('dart2js:noInline')
  static RepaymentObject getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RepaymentObject>(create);
  static RepaymentObject? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get loanAccountId => $_getSZ(1);
  @$pb.TagNumber(2)
  set loanAccountId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasLoanAccountId() => $_has(1);
  @$pb.TagNumber(2)
  void clearLoanAccountId() => clearField(2);

  @$pb.TagNumber(3)
  $7.Money get amount => $_getN(2);
  @$pb.TagNumber(3)
  set amount($7.Money v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasAmount() => $_has(2);
  @$pb.TagNumber(3)
  void clearAmount() => clearField(3);
  @$pb.TagNumber(3)
  $7.Money ensureAmount() => $_ensure(2);

  /// Field 4 removed (currency_code now in Money).
  @$pb.TagNumber(5)
  RepaymentStatus get status => $_getN(3);
  @$pb.TagNumber(5)
  set status(RepaymentStatus v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasStatus() => $_has(3);
  @$pb.TagNumber(5)
  void clearStatus() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get paymentReference => $_getSZ(4);
  @$pb.TagNumber(6)
  set paymentReference($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(6)
  $core.bool hasPaymentReference() => $_has(4);
  @$pb.TagNumber(6)
  void clearPaymentReference() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get ledgerTransactionId => $_getSZ(5);
  @$pb.TagNumber(7)
  set ledgerTransactionId($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(7)
  $core.bool hasLedgerTransactionId() => $_has(5);
  @$pb.TagNumber(7)
  void clearLedgerTransactionId() => clearField(7);

  @$pb.TagNumber(8)
  $core.String get receivedAt => $_getSZ(6);
  @$pb.TagNumber(8)
  set receivedAt($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(8)
  $core.bool hasReceivedAt() => $_has(6);
  @$pb.TagNumber(8)
  void clearReceivedAt() => clearField(8);

  @$pb.TagNumber(9)
  $core.String get channel => $_getSZ(7);
  @$pb.TagNumber(9)
  set channel($core.String v) { $_setString(7, v); }
  @$pb.TagNumber(9)
  $core.bool hasChannel() => $_has(7);
  @$pb.TagNumber(9)
  void clearChannel() => clearField(9);

  @$pb.TagNumber(10)
  $core.String get payerReference => $_getSZ(8);
  @$pb.TagNumber(10)
  set payerReference($core.String v) { $_setString(8, v); }
  @$pb.TagNumber(10)
  $core.bool hasPayerReference() => $_has(8);
  @$pb.TagNumber(10)
  void clearPayerReference() => clearField(10);

  @$pb.TagNumber(11)
  $7.Money get principalApplied => $_getN(9);
  @$pb.TagNumber(11)
  set principalApplied($7.Money v) { setField(11, v); }
  @$pb.TagNumber(11)
  $core.bool hasPrincipalApplied() => $_has(9);
  @$pb.TagNumber(11)
  void clearPrincipalApplied() => clearField(11);
  @$pb.TagNumber(11)
  $7.Money ensurePrincipalApplied() => $_ensure(9);

  @$pb.TagNumber(12)
  $7.Money get interestApplied => $_getN(10);
  @$pb.TagNumber(12)
  set interestApplied($7.Money v) { setField(12, v); }
  @$pb.TagNumber(12)
  $core.bool hasInterestApplied() => $_has(10);
  @$pb.TagNumber(12)
  void clearInterestApplied() => clearField(12);
  @$pb.TagNumber(12)
  $7.Money ensureInterestApplied() => $_ensure(10);

  @$pb.TagNumber(13)
  $7.Money get feesApplied => $_getN(11);
  @$pb.TagNumber(13)
  set feesApplied($7.Money v) { setField(13, v); }
  @$pb.TagNumber(13)
  $core.bool hasFeesApplied() => $_has(11);
  @$pb.TagNumber(13)
  void clearFeesApplied() => clearField(13);
  @$pb.TagNumber(13)
  $7.Money ensureFeesApplied() => $_ensure(11);

  @$pb.TagNumber(14)
  $7.Money get penaltiesApplied => $_getN(12);
  @$pb.TagNumber(14)
  set penaltiesApplied($7.Money v) { setField(14, v); }
  @$pb.TagNumber(14)
  $core.bool hasPenaltiesApplied() => $_has(12);
  @$pb.TagNumber(14)
  void clearPenaltiesApplied() => clearField(14);
  @$pb.TagNumber(14)
  $7.Money ensurePenaltiesApplied() => $_ensure(12);

  @$pb.TagNumber(15)
  $7.Money get excessAmount => $_getN(13);
  @$pb.TagNumber(15)
  set excessAmount($7.Money v) { setField(15, v); }
  @$pb.TagNumber(15)
  $core.bool hasExcessAmount() => $_has(13);
  @$pb.TagNumber(15)
  void clearExcessAmount() => clearField(15);
  @$pb.TagNumber(15)
  $7.Money ensureExcessAmount() => $_ensure(13);

  @$pb.TagNumber(16)
  $core.String get idempotencyKey => $_getSZ(14);
  @$pb.TagNumber(16)
  set idempotencyKey($core.String v) { $_setString(14, v); }
  @$pb.TagNumber(16)
  $core.bool hasIdempotencyKey() => $_has(14);
  @$pb.TagNumber(16)
  void clearIdempotencyKey() => clearField(16);

  @$pb.TagNumber(17)
  $6.Struct get properties => $_getN(15);
  @$pb.TagNumber(17)
  set properties($6.Struct v) { setField(17, v); }
  @$pb.TagNumber(17)
  $core.bool hasProperties() => $_has(15);
  @$pb.TagNumber(17)
  void clearProperties() => clearField(17);
  @$pb.TagNumber(17)
  $6.Struct ensureProperties() => $_ensure(15);
}

/// PenaltyObject represents a penalty applied to a loan.
class PenaltyObject extends $pb.GeneratedMessage {
  factory PenaltyObject({
    $core.String? id,
    $core.String? loanAccountId,
    PenaltyType? penaltyType,
    $7.Money? amount,
    $core.String? reason,
    $core.bool? isWaived,
    $core.String? waivedBy,
    $core.String? waivedReason,
    $core.String? ledgerTransactionId,
    $core.String? appliedAt,
    $core.String? scheduleEntryId,
    $6.Struct? properties,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (loanAccountId != null) {
      $result.loanAccountId = loanAccountId;
    }
    if (penaltyType != null) {
      $result.penaltyType = penaltyType;
    }
    if (amount != null) {
      $result.amount = amount;
    }
    if (reason != null) {
      $result.reason = reason;
    }
    if (isWaived != null) {
      $result.isWaived = isWaived;
    }
    if (waivedBy != null) {
      $result.waivedBy = waivedBy;
    }
    if (waivedReason != null) {
      $result.waivedReason = waivedReason;
    }
    if (ledgerTransactionId != null) {
      $result.ledgerTransactionId = ledgerTransactionId;
    }
    if (appliedAt != null) {
      $result.appliedAt = appliedAt;
    }
    if (scheduleEntryId != null) {
      $result.scheduleEntryId = scheduleEntryId;
    }
    if (properties != null) {
      $result.properties = properties;
    }
    return $result;
  }
  PenaltyObject._() : super();
  factory PenaltyObject.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PenaltyObject.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PenaltyObject', package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'loanAccountId')
    ..e<PenaltyType>(3, _omitFieldNames ? '' : 'penaltyType', $pb.PbFieldType.OE, defaultOrMaker: PenaltyType.PENALTY_TYPE_UNSPECIFIED, valueOf: PenaltyType.valueOf, enumValues: PenaltyType.values)
    ..aOM<$7.Money>(4, _omitFieldNames ? '' : 'amount', subBuilder: $7.Money.create)
    ..aOS(5, _omitFieldNames ? '' : 'reason')
    ..aOB(6, _omitFieldNames ? '' : 'isWaived')
    ..aOS(7, _omitFieldNames ? '' : 'waivedBy')
    ..aOS(8, _omitFieldNames ? '' : 'waivedReason')
    ..aOS(9, _omitFieldNames ? '' : 'ledgerTransactionId')
    ..aOS(10, _omitFieldNames ? '' : 'appliedAt')
    ..aOS(11, _omitFieldNames ? '' : 'scheduleEntryId')
    ..aOM<$6.Struct>(12, _omitFieldNames ? '' : 'properties', subBuilder: $6.Struct.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PenaltyObject clone() => PenaltyObject()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PenaltyObject copyWith(void Function(PenaltyObject) updates) => super.copyWith((message) => updates(message as PenaltyObject)) as PenaltyObject;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PenaltyObject create() => PenaltyObject._();
  PenaltyObject createEmptyInstance() => create();
  static $pb.PbList<PenaltyObject> createRepeated() => $pb.PbList<PenaltyObject>();
  @$core.pragma('dart2js:noInline')
  static PenaltyObject getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PenaltyObject>(create);
  static PenaltyObject? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get loanAccountId => $_getSZ(1);
  @$pb.TagNumber(2)
  set loanAccountId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasLoanAccountId() => $_has(1);
  @$pb.TagNumber(2)
  void clearLoanAccountId() => clearField(2);

  @$pb.TagNumber(3)
  PenaltyType get penaltyType => $_getN(2);
  @$pb.TagNumber(3)
  set penaltyType(PenaltyType v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasPenaltyType() => $_has(2);
  @$pb.TagNumber(3)
  void clearPenaltyType() => clearField(3);

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

  @$pb.TagNumber(5)
  $core.String get reason => $_getSZ(4);
  @$pb.TagNumber(5)
  set reason($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasReason() => $_has(4);
  @$pb.TagNumber(5)
  void clearReason() => clearField(5);

  @$pb.TagNumber(6)
  $core.bool get isWaived => $_getBF(5);
  @$pb.TagNumber(6)
  set isWaived($core.bool v) { $_setBool(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasIsWaived() => $_has(5);
  @$pb.TagNumber(6)
  void clearIsWaived() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get waivedBy => $_getSZ(6);
  @$pb.TagNumber(7)
  set waivedBy($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasWaivedBy() => $_has(6);
  @$pb.TagNumber(7)
  void clearWaivedBy() => clearField(7);

  @$pb.TagNumber(8)
  $core.String get waivedReason => $_getSZ(7);
  @$pb.TagNumber(8)
  set waivedReason($core.String v) { $_setString(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasWaivedReason() => $_has(7);
  @$pb.TagNumber(8)
  void clearWaivedReason() => clearField(8);

  @$pb.TagNumber(9)
  $core.String get ledgerTransactionId => $_getSZ(8);
  @$pb.TagNumber(9)
  set ledgerTransactionId($core.String v) { $_setString(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasLedgerTransactionId() => $_has(8);
  @$pb.TagNumber(9)
  void clearLedgerTransactionId() => clearField(9);

  @$pb.TagNumber(10)
  $core.String get appliedAt => $_getSZ(9);
  @$pb.TagNumber(10)
  set appliedAt($core.String v) { $_setString(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasAppliedAt() => $_has(9);
  @$pb.TagNumber(10)
  void clearAppliedAt() => clearField(10);

  @$pb.TagNumber(11)
  $core.String get scheduleEntryId => $_getSZ(10);
  @$pb.TagNumber(11)
  set scheduleEntryId($core.String v) { $_setString(10, v); }
  @$pb.TagNumber(11)
  $core.bool hasScheduleEntryId() => $_has(10);
  @$pb.TagNumber(11)
  void clearScheduleEntryId() => clearField(11);

  @$pb.TagNumber(12)
  $6.Struct get properties => $_getN(11);
  @$pb.TagNumber(12)
  set properties($6.Struct v) { setField(12, v); }
  @$pb.TagNumber(12)
  $core.bool hasProperties() => $_has(11);
  @$pb.TagNumber(12)
  void clearProperties() => clearField(12);
  @$pb.TagNumber(12)
  $6.Struct ensureProperties() => $_ensure(11);
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
    $7.Money? waivedAmount,
    $core.String? oldScheduleId,
    $core.String? newScheduleId,
    $8.STATE? state,
    $6.Struct? properties,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (loanAccountId != null) {
      $result.loanAccountId = loanAccountId;
    }
    if (restructureType != null) {
      $result.restructureType = restructureType;
    }
    if (requestedBy != null) {
      $result.requestedBy = requestedBy;
    }
    if (approvedBy != null) {
      $result.approvedBy = approvedBy;
    }
    if (reason != null) {
      $result.reason = reason;
    }
    if (oldInterestRate != null) {
      $result.oldInterestRate = oldInterestRate;
    }
    if (newInterestRate != null) {
      $result.newInterestRate = newInterestRate;
    }
    if (oldTermDays != null) {
      $result.oldTermDays = oldTermDays;
    }
    if (newTermDays != null) {
      $result.newTermDays = newTermDays;
    }
    if (waivedAmount != null) {
      $result.waivedAmount = waivedAmount;
    }
    if (oldScheduleId != null) {
      $result.oldScheduleId = oldScheduleId;
    }
    if (newScheduleId != null) {
      $result.newScheduleId = newScheduleId;
    }
    if (state != null) {
      $result.state = state;
    }
    if (properties != null) {
      $result.properties = properties;
    }
    return $result;
  }
  LoanRestructureObject._() : super();
  factory LoanRestructureObject.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory LoanRestructureObject.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LoanRestructureObject', package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'loanAccountId')
    ..e<RestructureType>(3, _omitFieldNames ? '' : 'restructureType', $pb.PbFieldType.OE, defaultOrMaker: RestructureType.RESTRUCTURE_TYPE_UNSPECIFIED, valueOf: RestructureType.valueOf, enumValues: RestructureType.values)
    ..aOS(4, _omitFieldNames ? '' : 'requestedBy')
    ..aOS(5, _omitFieldNames ? '' : 'approvedBy')
    ..aOS(6, _omitFieldNames ? '' : 'reason')
    ..aOS(7, _omitFieldNames ? '' : 'oldInterestRate')
    ..aOS(8, _omitFieldNames ? '' : 'newInterestRate')
    ..a<$core.int>(9, _omitFieldNames ? '' : 'oldTermDays', $pb.PbFieldType.O3)
    ..a<$core.int>(10, _omitFieldNames ? '' : 'newTermDays', $pb.PbFieldType.O3)
    ..aOM<$7.Money>(11, _omitFieldNames ? '' : 'waivedAmount', subBuilder: $7.Money.create)
    ..aOS(12, _omitFieldNames ? '' : 'oldScheduleId')
    ..aOS(13, _omitFieldNames ? '' : 'newScheduleId')
    ..e<$8.STATE>(14, _omitFieldNames ? '' : 'state', $pb.PbFieldType.OE, defaultOrMaker: $8.STATE.CREATED, valueOf: $8.STATE.valueOf, enumValues: $8.STATE.values)
    ..aOM<$6.Struct>(15, _omitFieldNames ? '' : 'properties', subBuilder: $6.Struct.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  LoanRestructureObject clone() => LoanRestructureObject()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  LoanRestructureObject copyWith(void Function(LoanRestructureObject) updates) => super.copyWith((message) => updates(message as LoanRestructureObject)) as LoanRestructureObject;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LoanRestructureObject create() => LoanRestructureObject._();
  LoanRestructureObject createEmptyInstance() => create();
  static $pb.PbList<LoanRestructureObject> createRepeated() => $pb.PbList<LoanRestructureObject>();
  @$core.pragma('dart2js:noInline')
  static LoanRestructureObject getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LoanRestructureObject>(create);
  static LoanRestructureObject? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get loanAccountId => $_getSZ(1);
  @$pb.TagNumber(2)
  set loanAccountId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasLoanAccountId() => $_has(1);
  @$pb.TagNumber(2)
  void clearLoanAccountId() => clearField(2);

  @$pb.TagNumber(3)
  RestructureType get restructureType => $_getN(2);
  @$pb.TagNumber(3)
  set restructureType(RestructureType v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasRestructureType() => $_has(2);
  @$pb.TagNumber(3)
  void clearRestructureType() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get requestedBy => $_getSZ(3);
  @$pb.TagNumber(4)
  set requestedBy($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasRequestedBy() => $_has(3);
  @$pb.TagNumber(4)
  void clearRequestedBy() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get approvedBy => $_getSZ(4);
  @$pb.TagNumber(5)
  set approvedBy($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasApprovedBy() => $_has(4);
  @$pb.TagNumber(5)
  void clearApprovedBy() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get reason => $_getSZ(5);
  @$pb.TagNumber(6)
  set reason($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasReason() => $_has(5);
  @$pb.TagNumber(6)
  void clearReason() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get oldInterestRate => $_getSZ(6);
  @$pb.TagNumber(7)
  set oldInterestRate($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasOldInterestRate() => $_has(6);
  @$pb.TagNumber(7)
  void clearOldInterestRate() => clearField(7);

  @$pb.TagNumber(8)
  $core.String get newInterestRate => $_getSZ(7);
  @$pb.TagNumber(8)
  set newInterestRate($core.String v) { $_setString(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasNewInterestRate() => $_has(7);
  @$pb.TagNumber(8)
  void clearNewInterestRate() => clearField(8);

  @$pb.TagNumber(9)
  $core.int get oldTermDays => $_getIZ(8);
  @$pb.TagNumber(9)
  set oldTermDays($core.int v) { $_setSignedInt32(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasOldTermDays() => $_has(8);
  @$pb.TagNumber(9)
  void clearOldTermDays() => clearField(9);

  @$pb.TagNumber(10)
  $core.int get newTermDays => $_getIZ(9);
  @$pb.TagNumber(10)
  set newTermDays($core.int v) { $_setSignedInt32(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasNewTermDays() => $_has(9);
  @$pb.TagNumber(10)
  void clearNewTermDays() => clearField(10);

  @$pb.TagNumber(11)
  $7.Money get waivedAmount => $_getN(10);
  @$pb.TagNumber(11)
  set waivedAmount($7.Money v) { setField(11, v); }
  @$pb.TagNumber(11)
  $core.bool hasWaivedAmount() => $_has(10);
  @$pb.TagNumber(11)
  void clearWaivedAmount() => clearField(11);
  @$pb.TagNumber(11)
  $7.Money ensureWaivedAmount() => $_ensure(10);

  @$pb.TagNumber(12)
  $core.String get oldScheduleId => $_getSZ(11);
  @$pb.TagNumber(12)
  set oldScheduleId($core.String v) { $_setString(11, v); }
  @$pb.TagNumber(12)
  $core.bool hasOldScheduleId() => $_has(11);
  @$pb.TagNumber(12)
  void clearOldScheduleId() => clearField(12);

  @$pb.TagNumber(13)
  $core.String get newScheduleId => $_getSZ(12);
  @$pb.TagNumber(13)
  set newScheduleId($core.String v) { $_setString(12, v); }
  @$pb.TagNumber(13)
  $core.bool hasNewScheduleId() => $_has(12);
  @$pb.TagNumber(13)
  void clearNewScheduleId() => clearField(13);

  @$pb.TagNumber(14)
  $8.STATE get state => $_getN(13);
  @$pb.TagNumber(14)
  set state($8.STATE v) { setField(14, v); }
  @$pb.TagNumber(14)
  $core.bool hasState() => $_has(13);
  @$pb.TagNumber(14)
  void clearState() => clearField(14);

  @$pb.TagNumber(15)
  $6.Struct get properties => $_getN(14);
  @$pb.TagNumber(15)
  set properties($6.Struct v) { setField(15, v); }
  @$pb.TagNumber(15)
  $core.bool hasProperties() => $_has(14);
  @$pb.TagNumber(15)
  void clearProperties() => clearField(15);
  @$pb.TagNumber(15)
  $6.Struct ensureProperties() => $_ensure(14);
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
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (loanAccountId != null) {
      $result.loanAccountId = loanAccountId;
    }
    if (fromStatus != null) {
      $result.fromStatus = fromStatus;
    }
    if (toStatus != null) {
      $result.toStatus = toStatus;
    }
    if (changedBy != null) {
      $result.changedBy = changedBy;
    }
    if (reason != null) {
      $result.reason = reason;
    }
    if (changedAt != null) {
      $result.changedAt = changedAt;
    }
    return $result;
  }
  LoanStatusChangeObject._() : super();
  factory LoanStatusChangeObject.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory LoanStatusChangeObject.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LoanStatusChangeObject', package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'loanAccountId')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'fromStatus', $pb.PbFieldType.O3)
    ..a<$core.int>(4, _omitFieldNames ? '' : 'toStatus', $pb.PbFieldType.O3)
    ..aOS(5, _omitFieldNames ? '' : 'changedBy')
    ..aOS(6, _omitFieldNames ? '' : 'reason')
    ..aOS(7, _omitFieldNames ? '' : 'changedAt')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  LoanStatusChangeObject clone() => LoanStatusChangeObject()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  LoanStatusChangeObject copyWith(void Function(LoanStatusChangeObject) updates) => super.copyWith((message) => updates(message as LoanStatusChangeObject)) as LoanStatusChangeObject;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LoanStatusChangeObject create() => LoanStatusChangeObject._();
  LoanStatusChangeObject createEmptyInstance() => create();
  static $pb.PbList<LoanStatusChangeObject> createRepeated() => $pb.PbList<LoanStatusChangeObject>();
  @$core.pragma('dart2js:noInline')
  static LoanStatusChangeObject getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LoanStatusChangeObject>(create);
  static LoanStatusChangeObject? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get loanAccountId => $_getSZ(1);
  @$pb.TagNumber(2)
  set loanAccountId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasLoanAccountId() => $_has(1);
  @$pb.TagNumber(2)
  void clearLoanAccountId() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get fromStatus => $_getIZ(2);
  @$pb.TagNumber(3)
  set fromStatus($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasFromStatus() => $_has(2);
  @$pb.TagNumber(3)
  void clearFromStatus() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get toStatus => $_getIZ(3);
  @$pb.TagNumber(4)
  set toStatus($core.int v) { $_setSignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasToStatus() => $_has(3);
  @$pb.TagNumber(4)
  void clearToStatus() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get changedBy => $_getSZ(4);
  @$pb.TagNumber(5)
  set changedBy($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasChangedBy() => $_has(4);
  @$pb.TagNumber(5)
  void clearChangedBy() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get reason => $_getSZ(5);
  @$pb.TagNumber(6)
  set reason($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasReason() => $_has(5);
  @$pb.TagNumber(6)
  void clearReason() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get changedAt => $_getSZ(6);
  @$pb.TagNumber(7)
  set changedAt($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasChangedAt() => $_has(6);
  @$pb.TagNumber(7)
  void clearChangedAt() => clearField(7);
}

/// ReconciliationObject represents a payment reconciliation record.
class ReconciliationObject extends $pb.GeneratedMessage {
  factory ReconciliationObject({
    $core.String? id,
    $core.String? loanAccountId,
    $core.String? paymentReference,
    $core.String? externalReference,
    $7.Money? amount,
    ReconciliationStatus? status,
    $core.String? matchedRepaymentId,
    $core.String? notes,
    $core.String? reconciledAt,
    $core.String? reconciledBy,
    $6.Struct? properties,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (loanAccountId != null) {
      $result.loanAccountId = loanAccountId;
    }
    if (paymentReference != null) {
      $result.paymentReference = paymentReference;
    }
    if (externalReference != null) {
      $result.externalReference = externalReference;
    }
    if (amount != null) {
      $result.amount = amount;
    }
    if (status != null) {
      $result.status = status;
    }
    if (matchedRepaymentId != null) {
      $result.matchedRepaymentId = matchedRepaymentId;
    }
    if (notes != null) {
      $result.notes = notes;
    }
    if (reconciledAt != null) {
      $result.reconciledAt = reconciledAt;
    }
    if (reconciledBy != null) {
      $result.reconciledBy = reconciledBy;
    }
    if (properties != null) {
      $result.properties = properties;
    }
    return $result;
  }
  ReconciliationObject._() : super();
  factory ReconciliationObject.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ReconciliationObject.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ReconciliationObject', package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'loanAccountId')
    ..aOS(3, _omitFieldNames ? '' : 'paymentReference')
    ..aOS(4, _omitFieldNames ? '' : 'externalReference')
    ..aOM<$7.Money>(5, _omitFieldNames ? '' : 'amount', subBuilder: $7.Money.create)
    ..e<ReconciliationStatus>(7, _omitFieldNames ? '' : 'status', $pb.PbFieldType.OE, defaultOrMaker: ReconciliationStatus.RECONCILIATION_STATUS_UNSPECIFIED, valueOf: ReconciliationStatus.valueOf, enumValues: ReconciliationStatus.values)
    ..aOS(8, _omitFieldNames ? '' : 'matchedRepaymentId')
    ..aOS(9, _omitFieldNames ? '' : 'notes')
    ..aOS(10, _omitFieldNames ? '' : 'reconciledAt')
    ..aOS(11, _omitFieldNames ? '' : 'reconciledBy')
    ..aOM<$6.Struct>(12, _omitFieldNames ? '' : 'properties', subBuilder: $6.Struct.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ReconciliationObject clone() => ReconciliationObject()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ReconciliationObject copyWith(void Function(ReconciliationObject) updates) => super.copyWith((message) => updates(message as ReconciliationObject)) as ReconciliationObject;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ReconciliationObject create() => ReconciliationObject._();
  ReconciliationObject createEmptyInstance() => create();
  static $pb.PbList<ReconciliationObject> createRepeated() => $pb.PbList<ReconciliationObject>();
  @$core.pragma('dart2js:noInline')
  static ReconciliationObject getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ReconciliationObject>(create);
  static ReconciliationObject? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get loanAccountId => $_getSZ(1);
  @$pb.TagNumber(2)
  set loanAccountId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasLoanAccountId() => $_has(1);
  @$pb.TagNumber(2)
  void clearLoanAccountId() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get paymentReference => $_getSZ(2);
  @$pb.TagNumber(3)
  set paymentReference($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasPaymentReference() => $_has(2);
  @$pb.TagNumber(3)
  void clearPaymentReference() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get externalReference => $_getSZ(3);
  @$pb.TagNumber(4)
  set externalReference($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasExternalReference() => $_has(3);
  @$pb.TagNumber(4)
  void clearExternalReference() => clearField(4);

  @$pb.TagNumber(5)
  $7.Money get amount => $_getN(4);
  @$pb.TagNumber(5)
  set amount($7.Money v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasAmount() => $_has(4);
  @$pb.TagNumber(5)
  void clearAmount() => clearField(5);
  @$pb.TagNumber(5)
  $7.Money ensureAmount() => $_ensure(4);

  /// Field 6 removed (currency_code now in Money).
  @$pb.TagNumber(7)
  ReconciliationStatus get status => $_getN(5);
  @$pb.TagNumber(7)
  set status(ReconciliationStatus v) { setField(7, v); }
  @$pb.TagNumber(7)
  $core.bool hasStatus() => $_has(5);
  @$pb.TagNumber(7)
  void clearStatus() => clearField(7);

  @$pb.TagNumber(8)
  $core.String get matchedRepaymentId => $_getSZ(6);
  @$pb.TagNumber(8)
  set matchedRepaymentId($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(8)
  $core.bool hasMatchedRepaymentId() => $_has(6);
  @$pb.TagNumber(8)
  void clearMatchedRepaymentId() => clearField(8);

  @$pb.TagNumber(9)
  $core.String get notes => $_getSZ(7);
  @$pb.TagNumber(9)
  set notes($core.String v) { $_setString(7, v); }
  @$pb.TagNumber(9)
  $core.bool hasNotes() => $_has(7);
  @$pb.TagNumber(9)
  void clearNotes() => clearField(9);

  @$pb.TagNumber(10)
  $core.String get reconciledAt => $_getSZ(8);
  @$pb.TagNumber(10)
  set reconciledAt($core.String v) { $_setString(8, v); }
  @$pb.TagNumber(10)
  $core.bool hasReconciledAt() => $_has(8);
  @$pb.TagNumber(10)
  void clearReconciledAt() => clearField(10);

  @$pb.TagNumber(11)
  $core.String get reconciledBy => $_getSZ(9);
  @$pb.TagNumber(11)
  set reconciledBy($core.String v) { $_setString(9, v); }
  @$pb.TagNumber(11)
  $core.bool hasReconciledBy() => $_has(9);
  @$pb.TagNumber(11)
  void clearReconciledBy() => clearField(11);

  @$pb.TagNumber(12)
  $6.Struct get properties => $_getN(10);
  @$pb.TagNumber(12)
  set properties($6.Struct v) { setField(12, v); }
  @$pb.TagNumber(12)
  $core.bool hasProperties() => $_has(10);
  @$pb.TagNumber(12)
  void clearProperties() => clearField(12);
  @$pb.TagNumber(12)
  $6.Struct ensureProperties() => $_ensure(10);
}

/// LoanStatementEntry represents a single line in a loan statement.
class LoanStatementEntry extends $pb.GeneratedMessage {
  factory LoanStatementEntry({
    $core.String? date,
    $core.String? description,
    $7.Money? debit,
    $7.Money? credit,
    $7.Money? balance,
    $core.String? reference,
  }) {
    final $result = create();
    if (date != null) {
      $result.date = date;
    }
    if (description != null) {
      $result.description = description;
    }
    if (debit != null) {
      $result.debit = debit;
    }
    if (credit != null) {
      $result.credit = credit;
    }
    if (balance != null) {
      $result.balance = balance;
    }
    if (reference != null) {
      $result.reference = reference;
    }
    return $result;
  }
  LoanStatementEntry._() : super();
  factory LoanStatementEntry.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory LoanStatementEntry.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LoanStatementEntry', package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'date')
    ..aOS(2, _omitFieldNames ? '' : 'description')
    ..aOM<$7.Money>(3, _omitFieldNames ? '' : 'debit', subBuilder: $7.Money.create)
    ..aOM<$7.Money>(4, _omitFieldNames ? '' : 'credit', subBuilder: $7.Money.create)
    ..aOM<$7.Money>(5, _omitFieldNames ? '' : 'balance', subBuilder: $7.Money.create)
    ..aOS(6, _omitFieldNames ? '' : 'reference')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  LoanStatementEntry clone() => LoanStatementEntry()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  LoanStatementEntry copyWith(void Function(LoanStatementEntry) updates) => super.copyWith((message) => updates(message as LoanStatementEntry)) as LoanStatementEntry;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LoanStatementEntry create() => LoanStatementEntry._();
  LoanStatementEntry createEmptyInstance() => create();
  static $pb.PbList<LoanStatementEntry> createRepeated() => $pb.PbList<LoanStatementEntry>();
  @$core.pragma('dart2js:noInline')
  static LoanStatementEntry getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LoanStatementEntry>(create);
  static LoanStatementEntry? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get date => $_getSZ(0);
  @$pb.TagNumber(1)
  set date($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasDate() => $_has(0);
  @$pb.TagNumber(1)
  void clearDate() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get description => $_getSZ(1);
  @$pb.TagNumber(2)
  set description($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasDescription() => $_has(1);
  @$pb.TagNumber(2)
  void clearDescription() => clearField(2);

  @$pb.TagNumber(3)
  $7.Money get debit => $_getN(2);
  @$pb.TagNumber(3)
  set debit($7.Money v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasDebit() => $_has(2);
  @$pb.TagNumber(3)
  void clearDebit() => clearField(3);
  @$pb.TagNumber(3)
  $7.Money ensureDebit() => $_ensure(2);

  @$pb.TagNumber(4)
  $7.Money get credit => $_getN(3);
  @$pb.TagNumber(4)
  set credit($7.Money v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasCredit() => $_has(3);
  @$pb.TagNumber(4)
  void clearCredit() => clearField(4);
  @$pb.TagNumber(4)
  $7.Money ensureCredit() => $_ensure(3);

  @$pb.TagNumber(5)
  $7.Money get balance => $_getN(4);
  @$pb.TagNumber(5)
  set balance($7.Money v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasBalance() => $_has(4);
  @$pb.TagNumber(5)
  void clearBalance() => clearField(5);
  @$pb.TagNumber(5)
  $7.Money ensureBalance() => $_ensure(4);

  @$pb.TagNumber(6)
  $core.String get reference => $_getSZ(5);
  @$pb.TagNumber(6)
  set reference($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasReference() => $_has(5);
  @$pb.TagNumber(6)
  void clearReference() => clearField(6);
}

class LoanAccountCreateRequest extends $pb.GeneratedMessage {
  factory LoanAccountCreateRequest({
    $core.String? loanRequestId,
  }) {
    final $result = create();
    if (loanRequestId != null) {
      $result.loanRequestId = loanRequestId;
    }
    return $result;
  }
  LoanAccountCreateRequest._() : super();
  factory LoanAccountCreateRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory LoanAccountCreateRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LoanAccountCreateRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'loanRequestId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  LoanAccountCreateRequest clone() => LoanAccountCreateRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  LoanAccountCreateRequest copyWith(void Function(LoanAccountCreateRequest) updates) => super.copyWith((message) => updates(message as LoanAccountCreateRequest)) as LoanAccountCreateRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LoanAccountCreateRequest create() => LoanAccountCreateRequest._();
  LoanAccountCreateRequest createEmptyInstance() => create();
  static $pb.PbList<LoanAccountCreateRequest> createRepeated() => $pb.PbList<LoanAccountCreateRequest>();
  @$core.pragma('dart2js:noInline')
  static LoanAccountCreateRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LoanAccountCreateRequest>(create);
  static LoanAccountCreateRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get loanRequestId => $_getSZ(0);
  @$pb.TagNumber(1)
  set loanRequestId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasLoanRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearLoanRequestId() => clearField(1);
}

class LoanAccountCreateResponse extends $pb.GeneratedMessage {
  factory LoanAccountCreateResponse({
    LoanAccountObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  LoanAccountCreateResponse._() : super();
  factory LoanAccountCreateResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory LoanAccountCreateResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LoanAccountCreateResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'), createEmptyInstance: create)
    ..aOM<LoanAccountObject>(1, _omitFieldNames ? '' : 'data', subBuilder: LoanAccountObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  LoanAccountCreateResponse clone() => LoanAccountCreateResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  LoanAccountCreateResponse copyWith(void Function(LoanAccountCreateResponse) updates) => super.copyWith((message) => updates(message as LoanAccountCreateResponse)) as LoanAccountCreateResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LoanAccountCreateResponse create() => LoanAccountCreateResponse._();
  LoanAccountCreateResponse createEmptyInstance() => create();
  static $pb.PbList<LoanAccountCreateResponse> createRepeated() => $pb.PbList<LoanAccountCreateResponse>();
  @$core.pragma('dart2js:noInline')
  static LoanAccountCreateResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LoanAccountCreateResponse>(create);
  static LoanAccountCreateResponse? _defaultInstance;

  @$pb.TagNumber(1)
  LoanAccountObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(LoanAccountObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  LoanAccountObject ensureData() => $_ensure(0);
}

class LoanAccountGetRequest extends $pb.GeneratedMessage {
  factory LoanAccountGetRequest({
    $core.String? id,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    return $result;
  }
  LoanAccountGetRequest._() : super();
  factory LoanAccountGetRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory LoanAccountGetRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LoanAccountGetRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  LoanAccountGetRequest clone() => LoanAccountGetRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  LoanAccountGetRequest copyWith(void Function(LoanAccountGetRequest) updates) => super.copyWith((message) => updates(message as LoanAccountGetRequest)) as LoanAccountGetRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LoanAccountGetRequest create() => LoanAccountGetRequest._();
  LoanAccountGetRequest createEmptyInstance() => create();
  static $pb.PbList<LoanAccountGetRequest> createRepeated() => $pb.PbList<LoanAccountGetRequest>();
  @$core.pragma('dart2js:noInline')
  static LoanAccountGetRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LoanAccountGetRequest>(create);
  static LoanAccountGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);
}

class LoanAccountGetResponse extends $pb.GeneratedMessage {
  factory LoanAccountGetResponse({
    LoanAccountObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  LoanAccountGetResponse._() : super();
  factory LoanAccountGetResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory LoanAccountGetResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LoanAccountGetResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'), createEmptyInstance: create)
    ..aOM<LoanAccountObject>(1, _omitFieldNames ? '' : 'data', subBuilder: LoanAccountObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  LoanAccountGetResponse clone() => LoanAccountGetResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  LoanAccountGetResponse copyWith(void Function(LoanAccountGetResponse) updates) => super.copyWith((message) => updates(message as LoanAccountGetResponse)) as LoanAccountGetResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LoanAccountGetResponse create() => LoanAccountGetResponse._();
  LoanAccountGetResponse createEmptyInstance() => create();
  static $pb.PbList<LoanAccountGetResponse> createRepeated() => $pb.PbList<LoanAccountGetResponse>();
  @$core.pragma('dart2js:noInline')
  static LoanAccountGetResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LoanAccountGetResponse>(create);
  static LoanAccountGetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  LoanAccountObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(LoanAccountObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
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
    $8.PageCursor? cursor,
  }) {
    final $result = create();
    if (query != null) {
      $result.query = query;
    }
    if (clientId != null) {
      $result.clientId = clientId;
    }
    if (agentId != null) {
      $result.agentId = agentId;
    }
    if (branchId != null) {
      $result.branchId = branchId;
    }
    if (organizationId != null) {
      $result.organizationId = organizationId;
    }
    if (status != null) {
      $result.status = status;
    }
    if (cursor != null) {
      $result.cursor = cursor;
    }
    return $result;
  }
  LoanAccountSearchRequest._() : super();
  factory LoanAccountSearchRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory LoanAccountSearchRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LoanAccountSearchRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'query')
    ..aOS(2, _omitFieldNames ? '' : 'clientId')
    ..aOS(3, _omitFieldNames ? '' : 'agentId')
    ..aOS(4, _omitFieldNames ? '' : 'branchId')
    ..aOS(5, _omitFieldNames ? '' : 'organizationId')
    ..e<LoanStatus>(6, _omitFieldNames ? '' : 'status', $pb.PbFieldType.OE, defaultOrMaker: LoanStatus.LOAN_STATUS_UNSPECIFIED, valueOf: LoanStatus.valueOf, enumValues: LoanStatus.values)
    ..aOM<$8.PageCursor>(7, _omitFieldNames ? '' : 'cursor', subBuilder: $8.PageCursor.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  LoanAccountSearchRequest clone() => LoanAccountSearchRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  LoanAccountSearchRequest copyWith(void Function(LoanAccountSearchRequest) updates) => super.copyWith((message) => updates(message as LoanAccountSearchRequest)) as LoanAccountSearchRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LoanAccountSearchRequest create() => LoanAccountSearchRequest._();
  LoanAccountSearchRequest createEmptyInstance() => create();
  static $pb.PbList<LoanAccountSearchRequest> createRepeated() => $pb.PbList<LoanAccountSearchRequest>();
  @$core.pragma('dart2js:noInline')
  static LoanAccountSearchRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LoanAccountSearchRequest>(create);
  static LoanAccountSearchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get query => $_getSZ(0);
  @$pb.TagNumber(1)
  set query($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasQuery() => $_has(0);
  @$pb.TagNumber(1)
  void clearQuery() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get clientId => $_getSZ(1);
  @$pb.TagNumber(2)
  set clientId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasClientId() => $_has(1);
  @$pb.TagNumber(2)
  void clearClientId() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get agentId => $_getSZ(2);
  @$pb.TagNumber(3)
  set agentId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasAgentId() => $_has(2);
  @$pb.TagNumber(3)
  void clearAgentId() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get branchId => $_getSZ(3);
  @$pb.TagNumber(4)
  set branchId($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasBranchId() => $_has(3);
  @$pb.TagNumber(4)
  void clearBranchId() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get organizationId => $_getSZ(4);
  @$pb.TagNumber(5)
  set organizationId($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasOrganizationId() => $_has(4);
  @$pb.TagNumber(5)
  void clearOrganizationId() => clearField(5);

  @$pb.TagNumber(6)
  LoanStatus get status => $_getN(5);
  @$pb.TagNumber(6)
  set status(LoanStatus v) { setField(6, v); }
  @$pb.TagNumber(6)
  $core.bool hasStatus() => $_has(5);
  @$pb.TagNumber(6)
  void clearStatus() => clearField(6);

  @$pb.TagNumber(7)
  $8.PageCursor get cursor => $_getN(6);
  @$pb.TagNumber(7)
  set cursor($8.PageCursor v) { setField(7, v); }
  @$pb.TagNumber(7)
  $core.bool hasCursor() => $_has(6);
  @$pb.TagNumber(7)
  void clearCursor() => clearField(7);
  @$pb.TagNumber(7)
  $8.PageCursor ensureCursor() => $_ensure(6);
}

class LoanAccountSearchResponse extends $pb.GeneratedMessage {
  factory LoanAccountSearchResponse({
    $core.Iterable<LoanAccountObject>? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data.addAll(data);
    }
    return $result;
  }
  LoanAccountSearchResponse._() : super();
  factory LoanAccountSearchResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory LoanAccountSearchResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LoanAccountSearchResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'), createEmptyInstance: create)
    ..pc<LoanAccountObject>(1, _omitFieldNames ? '' : 'data', $pb.PbFieldType.PM, subBuilder: LoanAccountObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  LoanAccountSearchResponse clone() => LoanAccountSearchResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  LoanAccountSearchResponse copyWith(void Function(LoanAccountSearchResponse) updates) => super.copyWith((message) => updates(message as LoanAccountSearchResponse)) as LoanAccountSearchResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LoanAccountSearchResponse create() => LoanAccountSearchResponse._();
  LoanAccountSearchResponse createEmptyInstance() => create();
  static $pb.PbList<LoanAccountSearchResponse> createRepeated() => $pb.PbList<LoanAccountSearchResponse>();
  @$core.pragma('dart2js:noInline')
  static LoanAccountSearchResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LoanAccountSearchResponse>(create);
  static LoanAccountSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<LoanAccountObject> get data => $_getList(0);
}

class LoanBalanceGetRequest extends $pb.GeneratedMessage {
  factory LoanBalanceGetRequest({
    $core.String? loanAccountId,
  }) {
    final $result = create();
    if (loanAccountId != null) {
      $result.loanAccountId = loanAccountId;
    }
    return $result;
  }
  LoanBalanceGetRequest._() : super();
  factory LoanBalanceGetRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory LoanBalanceGetRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LoanBalanceGetRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'loanAccountId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  LoanBalanceGetRequest clone() => LoanBalanceGetRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  LoanBalanceGetRequest copyWith(void Function(LoanBalanceGetRequest) updates) => super.copyWith((message) => updates(message as LoanBalanceGetRequest)) as LoanBalanceGetRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LoanBalanceGetRequest create() => LoanBalanceGetRequest._();
  LoanBalanceGetRequest createEmptyInstance() => create();
  static $pb.PbList<LoanBalanceGetRequest> createRepeated() => $pb.PbList<LoanBalanceGetRequest>();
  @$core.pragma('dart2js:noInline')
  static LoanBalanceGetRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LoanBalanceGetRequest>(create);
  static LoanBalanceGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get loanAccountId => $_getSZ(0);
  @$pb.TagNumber(1)
  set loanAccountId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasLoanAccountId() => $_has(0);
  @$pb.TagNumber(1)
  void clearLoanAccountId() => clearField(1);
}

class LoanBalanceGetResponse extends $pb.GeneratedMessage {
  factory LoanBalanceGetResponse({
    LoanBalanceObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  LoanBalanceGetResponse._() : super();
  factory LoanBalanceGetResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory LoanBalanceGetResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LoanBalanceGetResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'), createEmptyInstance: create)
    ..aOM<LoanBalanceObject>(1, _omitFieldNames ? '' : 'data', subBuilder: LoanBalanceObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  LoanBalanceGetResponse clone() => LoanBalanceGetResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  LoanBalanceGetResponse copyWith(void Function(LoanBalanceGetResponse) updates) => super.copyWith((message) => updates(message as LoanBalanceGetResponse)) as LoanBalanceGetResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LoanBalanceGetResponse create() => LoanBalanceGetResponse._();
  LoanBalanceGetResponse createEmptyInstance() => create();
  static $pb.PbList<LoanBalanceGetResponse> createRepeated() => $pb.PbList<LoanBalanceGetResponse>();
  @$core.pragma('dart2js:noInline')
  static LoanBalanceGetResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LoanBalanceGetResponse>(create);
  static LoanBalanceGetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  LoanBalanceObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(LoanBalanceObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
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
    final $result = create();
    if (loanAccountId != null) {
      $result.loanAccountId = loanAccountId;
    }
    if (channel != null) {
      $result.channel = channel;
    }
    if (recipientReference != null) {
      $result.recipientReference = recipientReference;
    }
    if (idempotencyKey != null) {
      $result.idempotencyKey = idempotencyKey;
    }
    return $result;
  }
  DisbursementCreateRequest._() : super();
  factory DisbursementCreateRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DisbursementCreateRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DisbursementCreateRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'loanAccountId')
    ..aOS(2, _omitFieldNames ? '' : 'channel')
    ..aOS(3, _omitFieldNames ? '' : 'recipientReference')
    ..aOS(4, _omitFieldNames ? '' : 'idempotencyKey')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DisbursementCreateRequest clone() => DisbursementCreateRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DisbursementCreateRequest copyWith(void Function(DisbursementCreateRequest) updates) => super.copyWith((message) => updates(message as DisbursementCreateRequest)) as DisbursementCreateRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DisbursementCreateRequest create() => DisbursementCreateRequest._();
  DisbursementCreateRequest createEmptyInstance() => create();
  static $pb.PbList<DisbursementCreateRequest> createRepeated() => $pb.PbList<DisbursementCreateRequest>();
  @$core.pragma('dart2js:noInline')
  static DisbursementCreateRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DisbursementCreateRequest>(create);
  static DisbursementCreateRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get loanAccountId => $_getSZ(0);
  @$pb.TagNumber(1)
  set loanAccountId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasLoanAccountId() => $_has(0);
  @$pb.TagNumber(1)
  void clearLoanAccountId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get channel => $_getSZ(1);
  @$pb.TagNumber(2)
  set channel($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasChannel() => $_has(1);
  @$pb.TagNumber(2)
  void clearChannel() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get recipientReference => $_getSZ(2);
  @$pb.TagNumber(3)
  set recipientReference($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasRecipientReference() => $_has(2);
  @$pb.TagNumber(3)
  void clearRecipientReference() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get idempotencyKey => $_getSZ(3);
  @$pb.TagNumber(4)
  set idempotencyKey($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasIdempotencyKey() => $_has(3);
  @$pb.TagNumber(4)
  void clearIdempotencyKey() => clearField(4);
}

class DisbursementCreateResponse extends $pb.GeneratedMessage {
  factory DisbursementCreateResponse({
    DisbursementObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  DisbursementCreateResponse._() : super();
  factory DisbursementCreateResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DisbursementCreateResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DisbursementCreateResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'), createEmptyInstance: create)
    ..aOM<DisbursementObject>(1, _omitFieldNames ? '' : 'data', subBuilder: DisbursementObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DisbursementCreateResponse clone() => DisbursementCreateResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DisbursementCreateResponse copyWith(void Function(DisbursementCreateResponse) updates) => super.copyWith((message) => updates(message as DisbursementCreateResponse)) as DisbursementCreateResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DisbursementCreateResponse create() => DisbursementCreateResponse._();
  DisbursementCreateResponse createEmptyInstance() => create();
  static $pb.PbList<DisbursementCreateResponse> createRepeated() => $pb.PbList<DisbursementCreateResponse>();
  @$core.pragma('dart2js:noInline')
  static DisbursementCreateResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DisbursementCreateResponse>(create);
  static DisbursementCreateResponse? _defaultInstance;

  @$pb.TagNumber(1)
  DisbursementObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(DisbursementObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  DisbursementObject ensureData() => $_ensure(0);
}

class DisbursementGetRequest extends $pb.GeneratedMessage {
  factory DisbursementGetRequest({
    $core.String? id,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    return $result;
  }
  DisbursementGetRequest._() : super();
  factory DisbursementGetRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DisbursementGetRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DisbursementGetRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DisbursementGetRequest clone() => DisbursementGetRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DisbursementGetRequest copyWith(void Function(DisbursementGetRequest) updates) => super.copyWith((message) => updates(message as DisbursementGetRequest)) as DisbursementGetRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DisbursementGetRequest create() => DisbursementGetRequest._();
  DisbursementGetRequest createEmptyInstance() => create();
  static $pb.PbList<DisbursementGetRequest> createRepeated() => $pb.PbList<DisbursementGetRequest>();
  @$core.pragma('dart2js:noInline')
  static DisbursementGetRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DisbursementGetRequest>(create);
  static DisbursementGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);
}

class DisbursementGetResponse extends $pb.GeneratedMessage {
  factory DisbursementGetResponse({
    DisbursementObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  DisbursementGetResponse._() : super();
  factory DisbursementGetResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DisbursementGetResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DisbursementGetResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'), createEmptyInstance: create)
    ..aOM<DisbursementObject>(1, _omitFieldNames ? '' : 'data', subBuilder: DisbursementObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DisbursementGetResponse clone() => DisbursementGetResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DisbursementGetResponse copyWith(void Function(DisbursementGetResponse) updates) => super.copyWith((message) => updates(message as DisbursementGetResponse)) as DisbursementGetResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DisbursementGetResponse create() => DisbursementGetResponse._();
  DisbursementGetResponse createEmptyInstance() => create();
  static $pb.PbList<DisbursementGetResponse> createRepeated() => $pb.PbList<DisbursementGetResponse>();
  @$core.pragma('dart2js:noInline')
  static DisbursementGetResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DisbursementGetResponse>(create);
  static DisbursementGetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  DisbursementObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(DisbursementObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  DisbursementObject ensureData() => $_ensure(0);
}

class DisbursementSearchRequest extends $pb.GeneratedMessage {
  factory DisbursementSearchRequest({
    $core.String? loanAccountId,
    DisbursementStatus? status,
    $8.PageCursor? cursor,
  }) {
    final $result = create();
    if (loanAccountId != null) {
      $result.loanAccountId = loanAccountId;
    }
    if (status != null) {
      $result.status = status;
    }
    if (cursor != null) {
      $result.cursor = cursor;
    }
    return $result;
  }
  DisbursementSearchRequest._() : super();
  factory DisbursementSearchRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DisbursementSearchRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DisbursementSearchRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'loanAccountId')
    ..e<DisbursementStatus>(2, _omitFieldNames ? '' : 'status', $pb.PbFieldType.OE, defaultOrMaker: DisbursementStatus.DISBURSEMENT_STATUS_UNSPECIFIED, valueOf: DisbursementStatus.valueOf, enumValues: DisbursementStatus.values)
    ..aOM<$8.PageCursor>(3, _omitFieldNames ? '' : 'cursor', subBuilder: $8.PageCursor.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DisbursementSearchRequest clone() => DisbursementSearchRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DisbursementSearchRequest copyWith(void Function(DisbursementSearchRequest) updates) => super.copyWith((message) => updates(message as DisbursementSearchRequest)) as DisbursementSearchRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DisbursementSearchRequest create() => DisbursementSearchRequest._();
  DisbursementSearchRequest createEmptyInstance() => create();
  static $pb.PbList<DisbursementSearchRequest> createRepeated() => $pb.PbList<DisbursementSearchRequest>();
  @$core.pragma('dart2js:noInline')
  static DisbursementSearchRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DisbursementSearchRequest>(create);
  static DisbursementSearchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get loanAccountId => $_getSZ(0);
  @$pb.TagNumber(1)
  set loanAccountId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasLoanAccountId() => $_has(0);
  @$pb.TagNumber(1)
  void clearLoanAccountId() => clearField(1);

  @$pb.TagNumber(2)
  DisbursementStatus get status => $_getN(1);
  @$pb.TagNumber(2)
  set status(DisbursementStatus v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasStatus() => $_has(1);
  @$pb.TagNumber(2)
  void clearStatus() => clearField(2);

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

class DisbursementSearchResponse extends $pb.GeneratedMessage {
  factory DisbursementSearchResponse({
    $core.Iterable<DisbursementObject>? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data.addAll(data);
    }
    return $result;
  }
  DisbursementSearchResponse._() : super();
  factory DisbursementSearchResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DisbursementSearchResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DisbursementSearchResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'), createEmptyInstance: create)
    ..pc<DisbursementObject>(1, _omitFieldNames ? '' : 'data', $pb.PbFieldType.PM, subBuilder: DisbursementObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DisbursementSearchResponse clone() => DisbursementSearchResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DisbursementSearchResponse copyWith(void Function(DisbursementSearchResponse) updates) => super.copyWith((message) => updates(message as DisbursementSearchResponse)) as DisbursementSearchResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DisbursementSearchResponse create() => DisbursementSearchResponse._();
  DisbursementSearchResponse createEmptyInstance() => create();
  static $pb.PbList<DisbursementSearchResponse> createRepeated() => $pb.PbList<DisbursementSearchResponse>();
  @$core.pragma('dart2js:noInline')
  static DisbursementSearchResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DisbursementSearchResponse>(create);
  static DisbursementSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<DisbursementObject> get data => $_getList(0);
}

class RepaymentRecordRequest extends $pb.GeneratedMessage {
  factory RepaymentRecordRequest({
    $core.String? loanAccountId,
    $7.Money? amount,
    $core.String? paymentReference,
    $core.String? channel,
    $core.String? payerReference,
    $core.String? receivedAt,
    $core.String? idempotencyKey,
  }) {
    final $result = create();
    if (loanAccountId != null) {
      $result.loanAccountId = loanAccountId;
    }
    if (amount != null) {
      $result.amount = amount;
    }
    if (paymentReference != null) {
      $result.paymentReference = paymentReference;
    }
    if (channel != null) {
      $result.channel = channel;
    }
    if (payerReference != null) {
      $result.payerReference = payerReference;
    }
    if (receivedAt != null) {
      $result.receivedAt = receivedAt;
    }
    if (idempotencyKey != null) {
      $result.idempotencyKey = idempotencyKey;
    }
    return $result;
  }
  RepaymentRecordRequest._() : super();
  factory RepaymentRecordRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory RepaymentRecordRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RepaymentRecordRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'loanAccountId')
    ..aOM<$7.Money>(2, _omitFieldNames ? '' : 'amount', subBuilder: $7.Money.create)
    ..aOS(3, _omitFieldNames ? '' : 'paymentReference')
    ..aOS(4, _omitFieldNames ? '' : 'channel')
    ..aOS(5, _omitFieldNames ? '' : 'payerReference')
    ..aOS(6, _omitFieldNames ? '' : 'receivedAt')
    ..aOS(7, _omitFieldNames ? '' : 'idempotencyKey')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  RepaymentRecordRequest clone() => RepaymentRecordRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  RepaymentRecordRequest copyWith(void Function(RepaymentRecordRequest) updates) => super.copyWith((message) => updates(message as RepaymentRecordRequest)) as RepaymentRecordRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RepaymentRecordRequest create() => RepaymentRecordRequest._();
  RepaymentRecordRequest createEmptyInstance() => create();
  static $pb.PbList<RepaymentRecordRequest> createRepeated() => $pb.PbList<RepaymentRecordRequest>();
  @$core.pragma('dart2js:noInline')
  static RepaymentRecordRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RepaymentRecordRequest>(create);
  static RepaymentRecordRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get loanAccountId => $_getSZ(0);
  @$pb.TagNumber(1)
  set loanAccountId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasLoanAccountId() => $_has(0);
  @$pb.TagNumber(1)
  void clearLoanAccountId() => clearField(1);

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
  $core.String get paymentReference => $_getSZ(2);
  @$pb.TagNumber(3)
  set paymentReference($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasPaymentReference() => $_has(2);
  @$pb.TagNumber(3)
  void clearPaymentReference() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get channel => $_getSZ(3);
  @$pb.TagNumber(4)
  set channel($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasChannel() => $_has(3);
  @$pb.TagNumber(4)
  void clearChannel() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get payerReference => $_getSZ(4);
  @$pb.TagNumber(5)
  set payerReference($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasPayerReference() => $_has(4);
  @$pb.TagNumber(5)
  void clearPayerReference() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get receivedAt => $_getSZ(5);
  @$pb.TagNumber(6)
  set receivedAt($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasReceivedAt() => $_has(5);
  @$pb.TagNumber(6)
  void clearReceivedAt() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get idempotencyKey => $_getSZ(6);
  @$pb.TagNumber(7)
  set idempotencyKey($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasIdempotencyKey() => $_has(6);
  @$pb.TagNumber(7)
  void clearIdempotencyKey() => clearField(7);
}

class RepaymentRecordResponse extends $pb.GeneratedMessage {
  factory RepaymentRecordResponse({
    RepaymentObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  RepaymentRecordResponse._() : super();
  factory RepaymentRecordResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory RepaymentRecordResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RepaymentRecordResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'), createEmptyInstance: create)
    ..aOM<RepaymentObject>(1, _omitFieldNames ? '' : 'data', subBuilder: RepaymentObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  RepaymentRecordResponse clone() => RepaymentRecordResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  RepaymentRecordResponse copyWith(void Function(RepaymentRecordResponse) updates) => super.copyWith((message) => updates(message as RepaymentRecordResponse)) as RepaymentRecordResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RepaymentRecordResponse create() => RepaymentRecordResponse._();
  RepaymentRecordResponse createEmptyInstance() => create();
  static $pb.PbList<RepaymentRecordResponse> createRepeated() => $pb.PbList<RepaymentRecordResponse>();
  @$core.pragma('dart2js:noInline')
  static RepaymentRecordResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RepaymentRecordResponse>(create);
  static RepaymentRecordResponse? _defaultInstance;

  @$pb.TagNumber(1)
  RepaymentObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(RepaymentObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  RepaymentObject ensureData() => $_ensure(0);
}

class RepaymentGetRequest extends $pb.GeneratedMessage {
  factory RepaymentGetRequest({
    $core.String? id,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    return $result;
  }
  RepaymentGetRequest._() : super();
  factory RepaymentGetRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory RepaymentGetRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RepaymentGetRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  RepaymentGetRequest clone() => RepaymentGetRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  RepaymentGetRequest copyWith(void Function(RepaymentGetRequest) updates) => super.copyWith((message) => updates(message as RepaymentGetRequest)) as RepaymentGetRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RepaymentGetRequest create() => RepaymentGetRequest._();
  RepaymentGetRequest createEmptyInstance() => create();
  static $pb.PbList<RepaymentGetRequest> createRepeated() => $pb.PbList<RepaymentGetRequest>();
  @$core.pragma('dart2js:noInline')
  static RepaymentGetRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RepaymentGetRequest>(create);
  static RepaymentGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);
}

class RepaymentGetResponse extends $pb.GeneratedMessage {
  factory RepaymentGetResponse({
    RepaymentObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  RepaymentGetResponse._() : super();
  factory RepaymentGetResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory RepaymentGetResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RepaymentGetResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'), createEmptyInstance: create)
    ..aOM<RepaymentObject>(1, _omitFieldNames ? '' : 'data', subBuilder: RepaymentObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  RepaymentGetResponse clone() => RepaymentGetResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  RepaymentGetResponse copyWith(void Function(RepaymentGetResponse) updates) => super.copyWith((message) => updates(message as RepaymentGetResponse)) as RepaymentGetResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RepaymentGetResponse create() => RepaymentGetResponse._();
  RepaymentGetResponse createEmptyInstance() => create();
  static $pb.PbList<RepaymentGetResponse> createRepeated() => $pb.PbList<RepaymentGetResponse>();
  @$core.pragma('dart2js:noInline')
  static RepaymentGetResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RepaymentGetResponse>(create);
  static RepaymentGetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  RepaymentObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(RepaymentObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  RepaymentObject ensureData() => $_ensure(0);
}

class RepaymentSearchRequest extends $pb.GeneratedMessage {
  factory RepaymentSearchRequest({
    $core.String? loanAccountId,
    RepaymentStatus? status,
    $8.PageCursor? cursor,
  }) {
    final $result = create();
    if (loanAccountId != null) {
      $result.loanAccountId = loanAccountId;
    }
    if (status != null) {
      $result.status = status;
    }
    if (cursor != null) {
      $result.cursor = cursor;
    }
    return $result;
  }
  RepaymentSearchRequest._() : super();
  factory RepaymentSearchRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory RepaymentSearchRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RepaymentSearchRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'loanAccountId')
    ..e<RepaymentStatus>(2, _omitFieldNames ? '' : 'status', $pb.PbFieldType.OE, defaultOrMaker: RepaymentStatus.REPAYMENT_STATUS_UNSPECIFIED, valueOf: RepaymentStatus.valueOf, enumValues: RepaymentStatus.values)
    ..aOM<$8.PageCursor>(3, _omitFieldNames ? '' : 'cursor', subBuilder: $8.PageCursor.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  RepaymentSearchRequest clone() => RepaymentSearchRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  RepaymentSearchRequest copyWith(void Function(RepaymentSearchRequest) updates) => super.copyWith((message) => updates(message as RepaymentSearchRequest)) as RepaymentSearchRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RepaymentSearchRequest create() => RepaymentSearchRequest._();
  RepaymentSearchRequest createEmptyInstance() => create();
  static $pb.PbList<RepaymentSearchRequest> createRepeated() => $pb.PbList<RepaymentSearchRequest>();
  @$core.pragma('dart2js:noInline')
  static RepaymentSearchRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RepaymentSearchRequest>(create);
  static RepaymentSearchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get loanAccountId => $_getSZ(0);
  @$pb.TagNumber(1)
  set loanAccountId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasLoanAccountId() => $_has(0);
  @$pb.TagNumber(1)
  void clearLoanAccountId() => clearField(1);

  @$pb.TagNumber(2)
  RepaymentStatus get status => $_getN(1);
  @$pb.TagNumber(2)
  set status(RepaymentStatus v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasStatus() => $_has(1);
  @$pb.TagNumber(2)
  void clearStatus() => clearField(2);

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

class RepaymentSearchResponse extends $pb.GeneratedMessage {
  factory RepaymentSearchResponse({
    $core.Iterable<RepaymentObject>? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data.addAll(data);
    }
    return $result;
  }
  RepaymentSearchResponse._() : super();
  factory RepaymentSearchResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory RepaymentSearchResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RepaymentSearchResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'), createEmptyInstance: create)
    ..pc<RepaymentObject>(1, _omitFieldNames ? '' : 'data', $pb.PbFieldType.PM, subBuilder: RepaymentObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  RepaymentSearchResponse clone() => RepaymentSearchResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  RepaymentSearchResponse copyWith(void Function(RepaymentSearchResponse) updates) => super.copyWith((message) => updates(message as RepaymentSearchResponse)) as RepaymentSearchResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RepaymentSearchResponse create() => RepaymentSearchResponse._();
  RepaymentSearchResponse createEmptyInstance() => create();
  static $pb.PbList<RepaymentSearchResponse> createRepeated() => $pb.PbList<RepaymentSearchResponse>();
  @$core.pragma('dart2js:noInline')
  static RepaymentSearchResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RepaymentSearchResponse>(create);
  static RepaymentSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<RepaymentObject> get data => $_getList(0);
}

class RepaymentScheduleGetRequest extends $pb.GeneratedMessage {
  factory RepaymentScheduleGetRequest({
    $core.String? loanAccountId,
  }) {
    final $result = create();
    if (loanAccountId != null) {
      $result.loanAccountId = loanAccountId;
    }
    return $result;
  }
  RepaymentScheduleGetRequest._() : super();
  factory RepaymentScheduleGetRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory RepaymentScheduleGetRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RepaymentScheduleGetRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'loanAccountId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  RepaymentScheduleGetRequest clone() => RepaymentScheduleGetRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  RepaymentScheduleGetRequest copyWith(void Function(RepaymentScheduleGetRequest) updates) => super.copyWith((message) => updates(message as RepaymentScheduleGetRequest)) as RepaymentScheduleGetRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RepaymentScheduleGetRequest create() => RepaymentScheduleGetRequest._();
  RepaymentScheduleGetRequest createEmptyInstance() => create();
  static $pb.PbList<RepaymentScheduleGetRequest> createRepeated() => $pb.PbList<RepaymentScheduleGetRequest>();
  @$core.pragma('dart2js:noInline')
  static RepaymentScheduleGetRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RepaymentScheduleGetRequest>(create);
  static RepaymentScheduleGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get loanAccountId => $_getSZ(0);
  @$pb.TagNumber(1)
  set loanAccountId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasLoanAccountId() => $_has(0);
  @$pb.TagNumber(1)
  void clearLoanAccountId() => clearField(1);
}

class RepaymentScheduleGetResponse extends $pb.GeneratedMessage {
  factory RepaymentScheduleGetResponse({
    RepaymentScheduleObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  RepaymentScheduleGetResponse._() : super();
  factory RepaymentScheduleGetResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory RepaymentScheduleGetResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RepaymentScheduleGetResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'), createEmptyInstance: create)
    ..aOM<RepaymentScheduleObject>(1, _omitFieldNames ? '' : 'data', subBuilder: RepaymentScheduleObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  RepaymentScheduleGetResponse clone() => RepaymentScheduleGetResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  RepaymentScheduleGetResponse copyWith(void Function(RepaymentScheduleGetResponse) updates) => super.copyWith((message) => updates(message as RepaymentScheduleGetResponse)) as RepaymentScheduleGetResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RepaymentScheduleGetResponse create() => RepaymentScheduleGetResponse._();
  RepaymentScheduleGetResponse createEmptyInstance() => create();
  static $pb.PbList<RepaymentScheduleGetResponse> createRepeated() => $pb.PbList<RepaymentScheduleGetResponse>();
  @$core.pragma('dart2js:noInline')
  static RepaymentScheduleGetResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RepaymentScheduleGetResponse>(create);
  static RepaymentScheduleGetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  RepaymentScheduleObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(RepaymentScheduleObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  RepaymentScheduleObject ensureData() => $_ensure(0);
}

class PenaltySaveRequest extends $pb.GeneratedMessage {
  factory PenaltySaveRequest({
    PenaltyObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  PenaltySaveRequest._() : super();
  factory PenaltySaveRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PenaltySaveRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PenaltySaveRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'), createEmptyInstance: create)
    ..aOM<PenaltyObject>(1, _omitFieldNames ? '' : 'data', subBuilder: PenaltyObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PenaltySaveRequest clone() => PenaltySaveRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PenaltySaveRequest copyWith(void Function(PenaltySaveRequest) updates) => super.copyWith((message) => updates(message as PenaltySaveRequest)) as PenaltySaveRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PenaltySaveRequest create() => PenaltySaveRequest._();
  PenaltySaveRequest createEmptyInstance() => create();
  static $pb.PbList<PenaltySaveRequest> createRepeated() => $pb.PbList<PenaltySaveRequest>();
  @$core.pragma('dart2js:noInline')
  static PenaltySaveRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PenaltySaveRequest>(create);
  static PenaltySaveRequest? _defaultInstance;

  @$pb.TagNumber(1)
  PenaltyObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(PenaltyObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  PenaltyObject ensureData() => $_ensure(0);
}

class PenaltySaveResponse extends $pb.GeneratedMessage {
  factory PenaltySaveResponse({
    PenaltyObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  PenaltySaveResponse._() : super();
  factory PenaltySaveResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PenaltySaveResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PenaltySaveResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'), createEmptyInstance: create)
    ..aOM<PenaltyObject>(1, _omitFieldNames ? '' : 'data', subBuilder: PenaltyObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PenaltySaveResponse clone() => PenaltySaveResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PenaltySaveResponse copyWith(void Function(PenaltySaveResponse) updates) => super.copyWith((message) => updates(message as PenaltySaveResponse)) as PenaltySaveResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PenaltySaveResponse create() => PenaltySaveResponse._();
  PenaltySaveResponse createEmptyInstance() => create();
  static $pb.PbList<PenaltySaveResponse> createRepeated() => $pb.PbList<PenaltySaveResponse>();
  @$core.pragma('dart2js:noInline')
  static PenaltySaveResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PenaltySaveResponse>(create);
  static PenaltySaveResponse? _defaultInstance;

  @$pb.TagNumber(1)
  PenaltyObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(PenaltyObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  PenaltyObject ensureData() => $_ensure(0);
}

class PenaltyWaiveRequest extends $pb.GeneratedMessage {
  factory PenaltyWaiveRequest({
    $core.String? id,
    $core.String? reason,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (reason != null) {
      $result.reason = reason;
    }
    return $result;
  }
  PenaltyWaiveRequest._() : super();
  factory PenaltyWaiveRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PenaltyWaiveRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PenaltyWaiveRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'reason')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PenaltyWaiveRequest clone() => PenaltyWaiveRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PenaltyWaiveRequest copyWith(void Function(PenaltyWaiveRequest) updates) => super.copyWith((message) => updates(message as PenaltyWaiveRequest)) as PenaltyWaiveRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PenaltyWaiveRequest create() => PenaltyWaiveRequest._();
  PenaltyWaiveRequest createEmptyInstance() => create();
  static $pb.PbList<PenaltyWaiveRequest> createRepeated() => $pb.PbList<PenaltyWaiveRequest>();
  @$core.pragma('dart2js:noInline')
  static PenaltyWaiveRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PenaltyWaiveRequest>(create);
  static PenaltyWaiveRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get reason => $_getSZ(1);
  @$pb.TagNumber(2)
  set reason($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasReason() => $_has(1);
  @$pb.TagNumber(2)
  void clearReason() => clearField(2);
}

class PenaltyWaiveResponse extends $pb.GeneratedMessage {
  factory PenaltyWaiveResponse({
    PenaltyObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  PenaltyWaiveResponse._() : super();
  factory PenaltyWaiveResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PenaltyWaiveResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PenaltyWaiveResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'), createEmptyInstance: create)
    ..aOM<PenaltyObject>(1, _omitFieldNames ? '' : 'data', subBuilder: PenaltyObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PenaltyWaiveResponse clone() => PenaltyWaiveResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PenaltyWaiveResponse copyWith(void Function(PenaltyWaiveResponse) updates) => super.copyWith((message) => updates(message as PenaltyWaiveResponse)) as PenaltyWaiveResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PenaltyWaiveResponse create() => PenaltyWaiveResponse._();
  PenaltyWaiveResponse createEmptyInstance() => create();
  static $pb.PbList<PenaltyWaiveResponse> createRepeated() => $pb.PbList<PenaltyWaiveResponse>();
  @$core.pragma('dart2js:noInline')
  static PenaltyWaiveResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PenaltyWaiveResponse>(create);
  static PenaltyWaiveResponse? _defaultInstance;

  @$pb.TagNumber(1)
  PenaltyObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(PenaltyObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  PenaltyObject ensureData() => $_ensure(0);
}

class PenaltySearchRequest extends $pb.GeneratedMessage {
  factory PenaltySearchRequest({
    $core.String? loanAccountId,
    PenaltyType? penaltyType,
    $8.PageCursor? cursor,
  }) {
    final $result = create();
    if (loanAccountId != null) {
      $result.loanAccountId = loanAccountId;
    }
    if (penaltyType != null) {
      $result.penaltyType = penaltyType;
    }
    if (cursor != null) {
      $result.cursor = cursor;
    }
    return $result;
  }
  PenaltySearchRequest._() : super();
  factory PenaltySearchRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PenaltySearchRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PenaltySearchRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'loanAccountId')
    ..e<PenaltyType>(2, _omitFieldNames ? '' : 'penaltyType', $pb.PbFieldType.OE, defaultOrMaker: PenaltyType.PENALTY_TYPE_UNSPECIFIED, valueOf: PenaltyType.valueOf, enumValues: PenaltyType.values)
    ..aOM<$8.PageCursor>(3, _omitFieldNames ? '' : 'cursor', subBuilder: $8.PageCursor.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PenaltySearchRequest clone() => PenaltySearchRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PenaltySearchRequest copyWith(void Function(PenaltySearchRequest) updates) => super.copyWith((message) => updates(message as PenaltySearchRequest)) as PenaltySearchRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PenaltySearchRequest create() => PenaltySearchRequest._();
  PenaltySearchRequest createEmptyInstance() => create();
  static $pb.PbList<PenaltySearchRequest> createRepeated() => $pb.PbList<PenaltySearchRequest>();
  @$core.pragma('dart2js:noInline')
  static PenaltySearchRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PenaltySearchRequest>(create);
  static PenaltySearchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get loanAccountId => $_getSZ(0);
  @$pb.TagNumber(1)
  set loanAccountId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasLoanAccountId() => $_has(0);
  @$pb.TagNumber(1)
  void clearLoanAccountId() => clearField(1);

  @$pb.TagNumber(2)
  PenaltyType get penaltyType => $_getN(1);
  @$pb.TagNumber(2)
  set penaltyType(PenaltyType v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasPenaltyType() => $_has(1);
  @$pb.TagNumber(2)
  void clearPenaltyType() => clearField(2);

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

class PenaltySearchResponse extends $pb.GeneratedMessage {
  factory PenaltySearchResponse({
    $core.Iterable<PenaltyObject>? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data.addAll(data);
    }
    return $result;
  }
  PenaltySearchResponse._() : super();
  factory PenaltySearchResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PenaltySearchResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PenaltySearchResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'), createEmptyInstance: create)
    ..pc<PenaltyObject>(1, _omitFieldNames ? '' : 'data', $pb.PbFieldType.PM, subBuilder: PenaltyObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PenaltySearchResponse clone() => PenaltySearchResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PenaltySearchResponse copyWith(void Function(PenaltySearchResponse) updates) => super.copyWith((message) => updates(message as PenaltySearchResponse)) as PenaltySearchResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PenaltySearchResponse create() => PenaltySearchResponse._();
  PenaltySearchResponse createEmptyInstance() => create();
  static $pb.PbList<PenaltySearchResponse> createRepeated() => $pb.PbList<PenaltySearchResponse>();
  @$core.pragma('dart2js:noInline')
  static PenaltySearchResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PenaltySearchResponse>(create);
  static PenaltySearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<PenaltyObject> get data => $_getList(0);
}

class LoanRestructureCreateRequest extends $pb.GeneratedMessage {
  factory LoanRestructureCreateRequest({
    LoanRestructureObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  LoanRestructureCreateRequest._() : super();
  factory LoanRestructureCreateRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory LoanRestructureCreateRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LoanRestructureCreateRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'), createEmptyInstance: create)
    ..aOM<LoanRestructureObject>(1, _omitFieldNames ? '' : 'data', subBuilder: LoanRestructureObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  LoanRestructureCreateRequest clone() => LoanRestructureCreateRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  LoanRestructureCreateRequest copyWith(void Function(LoanRestructureCreateRequest) updates) => super.copyWith((message) => updates(message as LoanRestructureCreateRequest)) as LoanRestructureCreateRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LoanRestructureCreateRequest create() => LoanRestructureCreateRequest._();
  LoanRestructureCreateRequest createEmptyInstance() => create();
  static $pb.PbList<LoanRestructureCreateRequest> createRepeated() => $pb.PbList<LoanRestructureCreateRequest>();
  @$core.pragma('dart2js:noInline')
  static LoanRestructureCreateRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LoanRestructureCreateRequest>(create);
  static LoanRestructureCreateRequest? _defaultInstance;

  @$pb.TagNumber(1)
  LoanRestructureObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(LoanRestructureObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  LoanRestructureObject ensureData() => $_ensure(0);
}

class LoanRestructureCreateResponse extends $pb.GeneratedMessage {
  factory LoanRestructureCreateResponse({
    LoanRestructureObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  LoanRestructureCreateResponse._() : super();
  factory LoanRestructureCreateResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory LoanRestructureCreateResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LoanRestructureCreateResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'), createEmptyInstance: create)
    ..aOM<LoanRestructureObject>(1, _omitFieldNames ? '' : 'data', subBuilder: LoanRestructureObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  LoanRestructureCreateResponse clone() => LoanRestructureCreateResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  LoanRestructureCreateResponse copyWith(void Function(LoanRestructureCreateResponse) updates) => super.copyWith((message) => updates(message as LoanRestructureCreateResponse)) as LoanRestructureCreateResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LoanRestructureCreateResponse create() => LoanRestructureCreateResponse._();
  LoanRestructureCreateResponse createEmptyInstance() => create();
  static $pb.PbList<LoanRestructureCreateResponse> createRepeated() => $pb.PbList<LoanRestructureCreateResponse>();
  @$core.pragma('dart2js:noInline')
  static LoanRestructureCreateResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LoanRestructureCreateResponse>(create);
  static LoanRestructureCreateResponse? _defaultInstance;

  @$pb.TagNumber(1)
  LoanRestructureObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(LoanRestructureObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  LoanRestructureObject ensureData() => $_ensure(0);
}

class LoanRestructureApproveRequest extends $pb.GeneratedMessage {
  factory LoanRestructureApproveRequest({
    $core.String? id,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    return $result;
  }
  LoanRestructureApproveRequest._() : super();
  factory LoanRestructureApproveRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory LoanRestructureApproveRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LoanRestructureApproveRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  LoanRestructureApproveRequest clone() => LoanRestructureApproveRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  LoanRestructureApproveRequest copyWith(void Function(LoanRestructureApproveRequest) updates) => super.copyWith((message) => updates(message as LoanRestructureApproveRequest)) as LoanRestructureApproveRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LoanRestructureApproveRequest create() => LoanRestructureApproveRequest._();
  LoanRestructureApproveRequest createEmptyInstance() => create();
  static $pb.PbList<LoanRestructureApproveRequest> createRepeated() => $pb.PbList<LoanRestructureApproveRequest>();
  @$core.pragma('dart2js:noInline')
  static LoanRestructureApproveRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LoanRestructureApproveRequest>(create);
  static LoanRestructureApproveRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);
}

class LoanRestructureApproveResponse extends $pb.GeneratedMessage {
  factory LoanRestructureApproveResponse({
    LoanRestructureObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  LoanRestructureApproveResponse._() : super();
  factory LoanRestructureApproveResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory LoanRestructureApproveResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LoanRestructureApproveResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'), createEmptyInstance: create)
    ..aOM<LoanRestructureObject>(1, _omitFieldNames ? '' : 'data', subBuilder: LoanRestructureObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  LoanRestructureApproveResponse clone() => LoanRestructureApproveResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  LoanRestructureApproveResponse copyWith(void Function(LoanRestructureApproveResponse) updates) => super.copyWith((message) => updates(message as LoanRestructureApproveResponse)) as LoanRestructureApproveResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LoanRestructureApproveResponse create() => LoanRestructureApproveResponse._();
  LoanRestructureApproveResponse createEmptyInstance() => create();
  static $pb.PbList<LoanRestructureApproveResponse> createRepeated() => $pb.PbList<LoanRestructureApproveResponse>();
  @$core.pragma('dart2js:noInline')
  static LoanRestructureApproveResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LoanRestructureApproveResponse>(create);
  static LoanRestructureApproveResponse? _defaultInstance;

  @$pb.TagNumber(1)
  LoanRestructureObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(LoanRestructureObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  LoanRestructureObject ensureData() => $_ensure(0);
}

class LoanRestructureRejectRequest extends $pb.GeneratedMessage {
  factory LoanRestructureRejectRequest({
    $core.String? id,
    $core.String? reason,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (reason != null) {
      $result.reason = reason;
    }
    return $result;
  }
  LoanRestructureRejectRequest._() : super();
  factory LoanRestructureRejectRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory LoanRestructureRejectRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LoanRestructureRejectRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'reason')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  LoanRestructureRejectRequest clone() => LoanRestructureRejectRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  LoanRestructureRejectRequest copyWith(void Function(LoanRestructureRejectRequest) updates) => super.copyWith((message) => updates(message as LoanRestructureRejectRequest)) as LoanRestructureRejectRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LoanRestructureRejectRequest create() => LoanRestructureRejectRequest._();
  LoanRestructureRejectRequest createEmptyInstance() => create();
  static $pb.PbList<LoanRestructureRejectRequest> createRepeated() => $pb.PbList<LoanRestructureRejectRequest>();
  @$core.pragma('dart2js:noInline')
  static LoanRestructureRejectRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LoanRestructureRejectRequest>(create);
  static LoanRestructureRejectRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get reason => $_getSZ(1);
  @$pb.TagNumber(2)
  set reason($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasReason() => $_has(1);
  @$pb.TagNumber(2)
  void clearReason() => clearField(2);
}

class LoanRestructureRejectResponse extends $pb.GeneratedMessage {
  factory LoanRestructureRejectResponse({
    LoanRestructureObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  LoanRestructureRejectResponse._() : super();
  factory LoanRestructureRejectResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory LoanRestructureRejectResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LoanRestructureRejectResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'), createEmptyInstance: create)
    ..aOM<LoanRestructureObject>(1, _omitFieldNames ? '' : 'data', subBuilder: LoanRestructureObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  LoanRestructureRejectResponse clone() => LoanRestructureRejectResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  LoanRestructureRejectResponse copyWith(void Function(LoanRestructureRejectResponse) updates) => super.copyWith((message) => updates(message as LoanRestructureRejectResponse)) as LoanRestructureRejectResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LoanRestructureRejectResponse create() => LoanRestructureRejectResponse._();
  LoanRestructureRejectResponse createEmptyInstance() => create();
  static $pb.PbList<LoanRestructureRejectResponse> createRepeated() => $pb.PbList<LoanRestructureRejectResponse>();
  @$core.pragma('dart2js:noInline')
  static LoanRestructureRejectResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LoanRestructureRejectResponse>(create);
  static LoanRestructureRejectResponse? _defaultInstance;

  @$pb.TagNumber(1)
  LoanRestructureObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(LoanRestructureObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  LoanRestructureObject ensureData() => $_ensure(0);
}

class LoanRestructureSearchRequest extends $pb.GeneratedMessage {
  factory LoanRestructureSearchRequest({
    $core.String? loanAccountId,
    $8.PageCursor? cursor,
  }) {
    final $result = create();
    if (loanAccountId != null) {
      $result.loanAccountId = loanAccountId;
    }
    if (cursor != null) {
      $result.cursor = cursor;
    }
    return $result;
  }
  LoanRestructureSearchRequest._() : super();
  factory LoanRestructureSearchRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory LoanRestructureSearchRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LoanRestructureSearchRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'loanAccountId')
    ..aOM<$8.PageCursor>(2, _omitFieldNames ? '' : 'cursor', subBuilder: $8.PageCursor.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  LoanRestructureSearchRequest clone() => LoanRestructureSearchRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  LoanRestructureSearchRequest copyWith(void Function(LoanRestructureSearchRequest) updates) => super.copyWith((message) => updates(message as LoanRestructureSearchRequest)) as LoanRestructureSearchRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LoanRestructureSearchRequest create() => LoanRestructureSearchRequest._();
  LoanRestructureSearchRequest createEmptyInstance() => create();
  static $pb.PbList<LoanRestructureSearchRequest> createRepeated() => $pb.PbList<LoanRestructureSearchRequest>();
  @$core.pragma('dart2js:noInline')
  static LoanRestructureSearchRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LoanRestructureSearchRequest>(create);
  static LoanRestructureSearchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get loanAccountId => $_getSZ(0);
  @$pb.TagNumber(1)
  set loanAccountId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasLoanAccountId() => $_has(0);
  @$pb.TagNumber(1)
  void clearLoanAccountId() => clearField(1);

  @$pb.TagNumber(2)
  $8.PageCursor get cursor => $_getN(1);
  @$pb.TagNumber(2)
  set cursor($8.PageCursor v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasCursor() => $_has(1);
  @$pb.TagNumber(2)
  void clearCursor() => clearField(2);
  @$pb.TagNumber(2)
  $8.PageCursor ensureCursor() => $_ensure(1);
}

class LoanRestructureSearchResponse extends $pb.GeneratedMessage {
  factory LoanRestructureSearchResponse({
    $core.Iterable<LoanRestructureObject>? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data.addAll(data);
    }
    return $result;
  }
  LoanRestructureSearchResponse._() : super();
  factory LoanRestructureSearchResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory LoanRestructureSearchResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LoanRestructureSearchResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'), createEmptyInstance: create)
    ..pc<LoanRestructureObject>(1, _omitFieldNames ? '' : 'data', $pb.PbFieldType.PM, subBuilder: LoanRestructureObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  LoanRestructureSearchResponse clone() => LoanRestructureSearchResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  LoanRestructureSearchResponse copyWith(void Function(LoanRestructureSearchResponse) updates) => super.copyWith((message) => updates(message as LoanRestructureSearchResponse)) as LoanRestructureSearchResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LoanRestructureSearchResponse create() => LoanRestructureSearchResponse._();
  LoanRestructureSearchResponse createEmptyInstance() => create();
  static $pb.PbList<LoanRestructureSearchResponse> createRepeated() => $pb.PbList<LoanRestructureSearchResponse>();
  @$core.pragma('dart2js:noInline')
  static LoanRestructureSearchResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LoanRestructureSearchResponse>(create);
  static LoanRestructureSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<LoanRestructureObject> get data => $_getList(0);
}

class LoanStatementRequest extends $pb.GeneratedMessage {
  factory LoanStatementRequest({
    $core.String? loanAccountId,
    $core.String? fromDate,
    $core.String? toDate,
  }) {
    final $result = create();
    if (loanAccountId != null) {
      $result.loanAccountId = loanAccountId;
    }
    if (fromDate != null) {
      $result.fromDate = fromDate;
    }
    if (toDate != null) {
      $result.toDate = toDate;
    }
    return $result;
  }
  LoanStatementRequest._() : super();
  factory LoanStatementRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory LoanStatementRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LoanStatementRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'loanAccountId')
    ..aOS(2, _omitFieldNames ? '' : 'fromDate')
    ..aOS(3, _omitFieldNames ? '' : 'toDate')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  LoanStatementRequest clone() => LoanStatementRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  LoanStatementRequest copyWith(void Function(LoanStatementRequest) updates) => super.copyWith((message) => updates(message as LoanStatementRequest)) as LoanStatementRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LoanStatementRequest create() => LoanStatementRequest._();
  LoanStatementRequest createEmptyInstance() => create();
  static $pb.PbList<LoanStatementRequest> createRepeated() => $pb.PbList<LoanStatementRequest>();
  @$core.pragma('dart2js:noInline')
  static LoanStatementRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LoanStatementRequest>(create);
  static LoanStatementRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get loanAccountId => $_getSZ(0);
  @$pb.TagNumber(1)
  set loanAccountId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasLoanAccountId() => $_has(0);
  @$pb.TagNumber(1)
  void clearLoanAccountId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get fromDate => $_getSZ(1);
  @$pb.TagNumber(2)
  set fromDate($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasFromDate() => $_has(1);
  @$pb.TagNumber(2)
  void clearFromDate() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get toDate => $_getSZ(2);
  @$pb.TagNumber(3)
  set toDate($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasToDate() => $_has(2);
  @$pb.TagNumber(3)
  void clearToDate() => clearField(3);
}

class LoanStatementResponse extends $pb.GeneratedMessage {
  factory LoanStatementResponse({
    LoanAccountObject? loan,
    LoanBalanceObject? balance,
    $core.Iterable<LoanStatementEntry>? entries,
  }) {
    final $result = create();
    if (loan != null) {
      $result.loan = loan;
    }
    if (balance != null) {
      $result.balance = balance;
    }
    if (entries != null) {
      $result.entries.addAll(entries);
    }
    return $result;
  }
  LoanStatementResponse._() : super();
  factory LoanStatementResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory LoanStatementResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LoanStatementResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'), createEmptyInstance: create)
    ..aOM<LoanAccountObject>(1, _omitFieldNames ? '' : 'loan', subBuilder: LoanAccountObject.create)
    ..aOM<LoanBalanceObject>(2, _omitFieldNames ? '' : 'balance', subBuilder: LoanBalanceObject.create)
    ..pc<LoanStatementEntry>(3, _omitFieldNames ? '' : 'entries', $pb.PbFieldType.PM, subBuilder: LoanStatementEntry.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  LoanStatementResponse clone() => LoanStatementResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  LoanStatementResponse copyWith(void Function(LoanStatementResponse) updates) => super.copyWith((message) => updates(message as LoanStatementResponse)) as LoanStatementResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LoanStatementResponse create() => LoanStatementResponse._();
  LoanStatementResponse createEmptyInstance() => create();
  static $pb.PbList<LoanStatementResponse> createRepeated() => $pb.PbList<LoanStatementResponse>();
  @$core.pragma('dart2js:noInline')
  static LoanStatementResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LoanStatementResponse>(create);
  static LoanStatementResponse? _defaultInstance;

  @$pb.TagNumber(1)
  LoanAccountObject get loan => $_getN(0);
  @$pb.TagNumber(1)
  set loan(LoanAccountObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasLoan() => $_has(0);
  @$pb.TagNumber(1)
  void clearLoan() => clearField(1);
  @$pb.TagNumber(1)
  LoanAccountObject ensureLoan() => $_ensure(0);

  @$pb.TagNumber(2)
  LoanBalanceObject get balance => $_getN(1);
  @$pb.TagNumber(2)
  set balance(LoanBalanceObject v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasBalance() => $_has(1);
  @$pb.TagNumber(2)
  void clearBalance() => clearField(2);
  @$pb.TagNumber(2)
  LoanBalanceObject ensureBalance() => $_ensure(1);

  @$pb.TagNumber(3)
  $core.List<LoanStatementEntry> get entries => $_getList(2);
}

class ReconciliationSaveRequest extends $pb.GeneratedMessage {
  factory ReconciliationSaveRequest({
    ReconciliationObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  ReconciliationSaveRequest._() : super();
  factory ReconciliationSaveRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ReconciliationSaveRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ReconciliationSaveRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'), createEmptyInstance: create)
    ..aOM<ReconciliationObject>(1, _omitFieldNames ? '' : 'data', subBuilder: ReconciliationObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ReconciliationSaveRequest clone() => ReconciliationSaveRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ReconciliationSaveRequest copyWith(void Function(ReconciliationSaveRequest) updates) => super.copyWith((message) => updates(message as ReconciliationSaveRequest)) as ReconciliationSaveRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ReconciliationSaveRequest create() => ReconciliationSaveRequest._();
  ReconciliationSaveRequest createEmptyInstance() => create();
  static $pb.PbList<ReconciliationSaveRequest> createRepeated() => $pb.PbList<ReconciliationSaveRequest>();
  @$core.pragma('dart2js:noInline')
  static ReconciliationSaveRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ReconciliationSaveRequest>(create);
  static ReconciliationSaveRequest? _defaultInstance;

  @$pb.TagNumber(1)
  ReconciliationObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(ReconciliationObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  ReconciliationObject ensureData() => $_ensure(0);
}

class ReconciliationSaveResponse extends $pb.GeneratedMessage {
  factory ReconciliationSaveResponse({
    ReconciliationObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  ReconciliationSaveResponse._() : super();
  factory ReconciliationSaveResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ReconciliationSaveResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ReconciliationSaveResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'), createEmptyInstance: create)
    ..aOM<ReconciliationObject>(1, _omitFieldNames ? '' : 'data', subBuilder: ReconciliationObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ReconciliationSaveResponse clone() => ReconciliationSaveResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ReconciliationSaveResponse copyWith(void Function(ReconciliationSaveResponse) updates) => super.copyWith((message) => updates(message as ReconciliationSaveResponse)) as ReconciliationSaveResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ReconciliationSaveResponse create() => ReconciliationSaveResponse._();
  ReconciliationSaveResponse createEmptyInstance() => create();
  static $pb.PbList<ReconciliationSaveResponse> createRepeated() => $pb.PbList<ReconciliationSaveResponse>();
  @$core.pragma('dart2js:noInline')
  static ReconciliationSaveResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ReconciliationSaveResponse>(create);
  static ReconciliationSaveResponse? _defaultInstance;

  @$pb.TagNumber(1)
  ReconciliationObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(ReconciliationObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  ReconciliationObject ensureData() => $_ensure(0);
}

class ReconciliationSearchRequest extends $pb.GeneratedMessage {
  factory ReconciliationSearchRequest({
    $core.String? loanAccountId,
    ReconciliationStatus? status,
    $8.PageCursor? cursor,
  }) {
    final $result = create();
    if (loanAccountId != null) {
      $result.loanAccountId = loanAccountId;
    }
    if (status != null) {
      $result.status = status;
    }
    if (cursor != null) {
      $result.cursor = cursor;
    }
    return $result;
  }
  ReconciliationSearchRequest._() : super();
  factory ReconciliationSearchRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ReconciliationSearchRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ReconciliationSearchRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'loanAccountId')
    ..e<ReconciliationStatus>(2, _omitFieldNames ? '' : 'status', $pb.PbFieldType.OE, defaultOrMaker: ReconciliationStatus.RECONCILIATION_STATUS_UNSPECIFIED, valueOf: ReconciliationStatus.valueOf, enumValues: ReconciliationStatus.values)
    ..aOM<$8.PageCursor>(3, _omitFieldNames ? '' : 'cursor', subBuilder: $8.PageCursor.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ReconciliationSearchRequest clone() => ReconciliationSearchRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ReconciliationSearchRequest copyWith(void Function(ReconciliationSearchRequest) updates) => super.copyWith((message) => updates(message as ReconciliationSearchRequest)) as ReconciliationSearchRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ReconciliationSearchRequest create() => ReconciliationSearchRequest._();
  ReconciliationSearchRequest createEmptyInstance() => create();
  static $pb.PbList<ReconciliationSearchRequest> createRepeated() => $pb.PbList<ReconciliationSearchRequest>();
  @$core.pragma('dart2js:noInline')
  static ReconciliationSearchRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ReconciliationSearchRequest>(create);
  static ReconciliationSearchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get loanAccountId => $_getSZ(0);
  @$pb.TagNumber(1)
  set loanAccountId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasLoanAccountId() => $_has(0);
  @$pb.TagNumber(1)
  void clearLoanAccountId() => clearField(1);

  @$pb.TagNumber(2)
  ReconciliationStatus get status => $_getN(1);
  @$pb.TagNumber(2)
  set status(ReconciliationStatus v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasStatus() => $_has(1);
  @$pb.TagNumber(2)
  void clearStatus() => clearField(2);

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

class ReconciliationSearchResponse extends $pb.GeneratedMessage {
  factory ReconciliationSearchResponse({
    $core.Iterable<ReconciliationObject>? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data.addAll(data);
    }
    return $result;
  }
  ReconciliationSearchResponse._() : super();
  factory ReconciliationSearchResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ReconciliationSearchResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ReconciliationSearchResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'), createEmptyInstance: create)
    ..pc<ReconciliationObject>(1, _omitFieldNames ? '' : 'data', $pb.PbFieldType.PM, subBuilder: ReconciliationObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ReconciliationSearchResponse clone() => ReconciliationSearchResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ReconciliationSearchResponse copyWith(void Function(ReconciliationSearchResponse) updates) => super.copyWith((message) => updates(message as ReconciliationSearchResponse)) as ReconciliationSearchResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ReconciliationSearchResponse create() => ReconciliationSearchResponse._();
  ReconciliationSearchResponse createEmptyInstance() => create();
  static $pb.PbList<ReconciliationSearchResponse> createRepeated() => $pb.PbList<ReconciliationSearchResponse>();
  @$core.pragma('dart2js:noInline')
  static ReconciliationSearchResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ReconciliationSearchResponse>(create);
  static ReconciliationSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<ReconciliationObject> get data => $_getList(0);
}

class InitiateCollectionRequest extends $pb.GeneratedMessage {
  factory InitiateCollectionRequest({
    $core.String? loanAccountId,
    $core.String? amount,
    $core.String? phoneNumber,
    $core.String? idempotencyKey,
  }) {
    final $result = create();
    if (loanAccountId != null) {
      $result.loanAccountId = loanAccountId;
    }
    if (amount != null) {
      $result.amount = amount;
    }
    if (phoneNumber != null) {
      $result.phoneNumber = phoneNumber;
    }
    if (idempotencyKey != null) {
      $result.idempotencyKey = idempotencyKey;
    }
    return $result;
  }
  InitiateCollectionRequest._() : super();
  factory InitiateCollectionRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory InitiateCollectionRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'InitiateCollectionRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'loanAccountId')
    ..aOS(2, _omitFieldNames ? '' : 'amount')
    ..aOS(3, _omitFieldNames ? '' : 'phoneNumber')
    ..aOS(4, _omitFieldNames ? '' : 'idempotencyKey')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  InitiateCollectionRequest clone() => InitiateCollectionRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  InitiateCollectionRequest copyWith(void Function(InitiateCollectionRequest) updates) => super.copyWith((message) => updates(message as InitiateCollectionRequest)) as InitiateCollectionRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static InitiateCollectionRequest create() => InitiateCollectionRequest._();
  InitiateCollectionRequest createEmptyInstance() => create();
  static $pb.PbList<InitiateCollectionRequest> createRepeated() => $pb.PbList<InitiateCollectionRequest>();
  @$core.pragma('dart2js:noInline')
  static InitiateCollectionRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<InitiateCollectionRequest>(create);
  static InitiateCollectionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get loanAccountId => $_getSZ(0);
  @$pb.TagNumber(1)
  set loanAccountId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasLoanAccountId() => $_has(0);
  @$pb.TagNumber(1)
  void clearLoanAccountId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get amount => $_getSZ(1);
  @$pb.TagNumber(2)
  set amount($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasAmount() => $_has(1);
  @$pb.TagNumber(2)
  void clearAmount() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get phoneNumber => $_getSZ(2);
  @$pb.TagNumber(3)
  set phoneNumber($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasPhoneNumber() => $_has(2);
  @$pb.TagNumber(3)
  void clearPhoneNumber() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get idempotencyKey => $_getSZ(3);
  @$pb.TagNumber(4)
  set idempotencyKey($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasIdempotencyKey() => $_has(3);
  @$pb.TagNumber(4)
  void clearIdempotencyKey() => clearField(4);
}

class InitiateCollectionResponse extends $pb.GeneratedMessage {
  factory InitiateCollectionResponse({
    $core.String? paymentPromptId,
    $core.String? status,
  }) {
    final $result = create();
    if (paymentPromptId != null) {
      $result.paymentPromptId = paymentPromptId;
    }
    if (status != null) {
      $result.status = status;
    }
    return $result;
  }
  InitiateCollectionResponse._() : super();
  factory InitiateCollectionResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory InitiateCollectionResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'InitiateCollectionResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'paymentPromptId')
    ..aOS(2, _omitFieldNames ? '' : 'status')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  InitiateCollectionResponse clone() => InitiateCollectionResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  InitiateCollectionResponse copyWith(void Function(InitiateCollectionResponse) updates) => super.copyWith((message) => updates(message as InitiateCollectionResponse)) as InitiateCollectionResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static InitiateCollectionResponse create() => InitiateCollectionResponse._();
  InitiateCollectionResponse createEmptyInstance() => create();
  static $pb.PbList<InitiateCollectionResponse> createRepeated() => $pb.PbList<InitiateCollectionResponse>();
  @$core.pragma('dart2js:noInline')
  static InitiateCollectionResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<InitiateCollectionResponse>(create);
  static InitiateCollectionResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get paymentPromptId => $_getSZ(0);
  @$pb.TagNumber(1)
  set paymentPromptId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPaymentPromptId() => $_has(0);
  @$pb.TagNumber(1)
  void clearPaymentPromptId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get status => $_getSZ(1);
  @$pb.TagNumber(2)
  set status($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasStatus() => $_has(1);
  @$pb.TagNumber(2)
  void clearStatus() => clearField(2);
}

class LoanStatusChangeSearchRequest extends $pb.GeneratedMessage {
  factory LoanStatusChangeSearchRequest({
    $core.String? loanAccountId,
    $8.PageCursor? cursor,
  }) {
    final $result = create();
    if (loanAccountId != null) {
      $result.loanAccountId = loanAccountId;
    }
    if (cursor != null) {
      $result.cursor = cursor;
    }
    return $result;
  }
  LoanStatusChangeSearchRequest._() : super();
  factory LoanStatusChangeSearchRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory LoanStatusChangeSearchRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LoanStatusChangeSearchRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'loanAccountId')
    ..aOM<$8.PageCursor>(2, _omitFieldNames ? '' : 'cursor', subBuilder: $8.PageCursor.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  LoanStatusChangeSearchRequest clone() => LoanStatusChangeSearchRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  LoanStatusChangeSearchRequest copyWith(void Function(LoanStatusChangeSearchRequest) updates) => super.copyWith((message) => updates(message as LoanStatusChangeSearchRequest)) as LoanStatusChangeSearchRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LoanStatusChangeSearchRequest create() => LoanStatusChangeSearchRequest._();
  LoanStatusChangeSearchRequest createEmptyInstance() => create();
  static $pb.PbList<LoanStatusChangeSearchRequest> createRepeated() => $pb.PbList<LoanStatusChangeSearchRequest>();
  @$core.pragma('dart2js:noInline')
  static LoanStatusChangeSearchRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LoanStatusChangeSearchRequest>(create);
  static LoanStatusChangeSearchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get loanAccountId => $_getSZ(0);
  @$pb.TagNumber(1)
  set loanAccountId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasLoanAccountId() => $_has(0);
  @$pb.TagNumber(1)
  void clearLoanAccountId() => clearField(1);

  @$pb.TagNumber(2)
  $8.PageCursor get cursor => $_getN(1);
  @$pb.TagNumber(2)
  set cursor($8.PageCursor v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasCursor() => $_has(1);
  @$pb.TagNumber(2)
  void clearCursor() => clearField(2);
  @$pb.TagNumber(2)
  $8.PageCursor ensureCursor() => $_ensure(1);
}

class LoanStatusChangeSearchResponse extends $pb.GeneratedMessage {
  factory LoanStatusChangeSearchResponse({
    $core.Iterable<LoanStatusChangeObject>? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data.addAll(data);
    }
    return $result;
  }
  LoanStatusChangeSearchResponse._() : super();
  factory LoanStatusChangeSearchResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory LoanStatusChangeSearchResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LoanStatusChangeSearchResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'), createEmptyInstance: create)
    ..pc<LoanStatusChangeObject>(1, _omitFieldNames ? '' : 'data', $pb.PbFieldType.PM, subBuilder: LoanStatusChangeObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  LoanStatusChangeSearchResponse clone() => LoanStatusChangeSearchResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  LoanStatusChangeSearchResponse copyWith(void Function(LoanStatusChangeSearchResponse) updates) => super.copyWith((message) => updates(message as LoanStatusChangeSearchResponse)) as LoanStatusChangeSearchResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LoanStatusChangeSearchResponse create() => LoanStatusChangeSearchResponse._();
  LoanStatusChangeSearchResponse createEmptyInstance() => create();
  static $pb.PbList<LoanStatusChangeSearchResponse> createRepeated() => $pb.PbList<LoanStatusChangeSearchResponse>();
  @$core.pragma('dart2js:noInline')
  static LoanStatusChangeSearchResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LoanStatusChangeSearchResponse>(create);
  static LoanStatusChangeSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<LoanStatusChangeObject> get data => $_getList(0);
}

class LoanProductSaveRequest extends $pb.GeneratedMessage {
  factory LoanProductSaveRequest({
    LoanProductObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  LoanProductSaveRequest._() : super();
  factory LoanProductSaveRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory LoanProductSaveRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LoanProductSaveRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'), createEmptyInstance: create)
    ..aOM<LoanProductObject>(1, _omitFieldNames ? '' : 'data', subBuilder: LoanProductObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  LoanProductSaveRequest clone() => LoanProductSaveRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  LoanProductSaveRequest copyWith(void Function(LoanProductSaveRequest) updates) => super.copyWith((message) => updates(message as LoanProductSaveRequest)) as LoanProductSaveRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LoanProductSaveRequest create() => LoanProductSaveRequest._();
  LoanProductSaveRequest createEmptyInstance() => create();
  static $pb.PbList<LoanProductSaveRequest> createRepeated() => $pb.PbList<LoanProductSaveRequest>();
  @$core.pragma('dart2js:noInline')
  static LoanProductSaveRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LoanProductSaveRequest>(create);
  static LoanProductSaveRequest? _defaultInstance;

  @$pb.TagNumber(1)
  LoanProductObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(LoanProductObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  LoanProductObject ensureData() => $_ensure(0);
}

class LoanProductSaveResponse extends $pb.GeneratedMessage {
  factory LoanProductSaveResponse({
    LoanProductObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  LoanProductSaveResponse._() : super();
  factory LoanProductSaveResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory LoanProductSaveResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LoanProductSaveResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'), createEmptyInstance: create)
    ..aOM<LoanProductObject>(1, _omitFieldNames ? '' : 'data', subBuilder: LoanProductObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  LoanProductSaveResponse clone() => LoanProductSaveResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  LoanProductSaveResponse copyWith(void Function(LoanProductSaveResponse) updates) => super.copyWith((message) => updates(message as LoanProductSaveResponse)) as LoanProductSaveResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LoanProductSaveResponse create() => LoanProductSaveResponse._();
  LoanProductSaveResponse createEmptyInstance() => create();
  static $pb.PbList<LoanProductSaveResponse> createRepeated() => $pb.PbList<LoanProductSaveResponse>();
  @$core.pragma('dart2js:noInline')
  static LoanProductSaveResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LoanProductSaveResponse>(create);
  static LoanProductSaveResponse? _defaultInstance;

  @$pb.TagNumber(1)
  LoanProductObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(LoanProductObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  LoanProductObject ensureData() => $_ensure(0);
}

class LoanProductGetRequest extends $pb.GeneratedMessage {
  factory LoanProductGetRequest({
    $core.String? id,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    return $result;
  }
  LoanProductGetRequest._() : super();
  factory LoanProductGetRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory LoanProductGetRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LoanProductGetRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  LoanProductGetRequest clone() => LoanProductGetRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  LoanProductGetRequest copyWith(void Function(LoanProductGetRequest) updates) => super.copyWith((message) => updates(message as LoanProductGetRequest)) as LoanProductGetRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LoanProductGetRequest create() => LoanProductGetRequest._();
  LoanProductGetRequest createEmptyInstance() => create();
  static $pb.PbList<LoanProductGetRequest> createRepeated() => $pb.PbList<LoanProductGetRequest>();
  @$core.pragma('dart2js:noInline')
  static LoanProductGetRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LoanProductGetRequest>(create);
  static LoanProductGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);
}

class LoanProductGetResponse extends $pb.GeneratedMessage {
  factory LoanProductGetResponse({
    LoanProductObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  LoanProductGetResponse._() : super();
  factory LoanProductGetResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory LoanProductGetResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LoanProductGetResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'), createEmptyInstance: create)
    ..aOM<LoanProductObject>(1, _omitFieldNames ? '' : 'data', subBuilder: LoanProductObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  LoanProductGetResponse clone() => LoanProductGetResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  LoanProductGetResponse copyWith(void Function(LoanProductGetResponse) updates) => super.copyWith((message) => updates(message as LoanProductGetResponse)) as LoanProductGetResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LoanProductGetResponse create() => LoanProductGetResponse._();
  LoanProductGetResponse createEmptyInstance() => create();
  static $pb.PbList<LoanProductGetResponse> createRepeated() => $pb.PbList<LoanProductGetResponse>();
  @$core.pragma('dart2js:noInline')
  static LoanProductGetResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LoanProductGetResponse>(create);
  static LoanProductGetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  LoanProductObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(LoanProductObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  LoanProductObject ensureData() => $_ensure(0);
}

class LoanProductSearchRequest extends $pb.GeneratedMessage {
  factory LoanProductSearchRequest({
    $core.String? query,
    $core.String? organizationId,
    LoanProductType? productType,
    $8.PageCursor? cursor,
  }) {
    final $result = create();
    if (query != null) {
      $result.query = query;
    }
    if (organizationId != null) {
      $result.organizationId = organizationId;
    }
    if (productType != null) {
      $result.productType = productType;
    }
    if (cursor != null) {
      $result.cursor = cursor;
    }
    return $result;
  }
  LoanProductSearchRequest._() : super();
  factory LoanProductSearchRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory LoanProductSearchRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LoanProductSearchRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'query')
    ..aOS(2, _omitFieldNames ? '' : 'organizationId')
    ..e<LoanProductType>(3, _omitFieldNames ? '' : 'productType', $pb.PbFieldType.OE, defaultOrMaker: LoanProductType.LOAN_PRODUCT_TYPE_UNSPECIFIED, valueOf: LoanProductType.valueOf, enumValues: LoanProductType.values)
    ..aOM<$8.PageCursor>(4, _omitFieldNames ? '' : 'cursor', subBuilder: $8.PageCursor.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  LoanProductSearchRequest clone() => LoanProductSearchRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  LoanProductSearchRequest copyWith(void Function(LoanProductSearchRequest) updates) => super.copyWith((message) => updates(message as LoanProductSearchRequest)) as LoanProductSearchRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LoanProductSearchRequest create() => LoanProductSearchRequest._();
  LoanProductSearchRequest createEmptyInstance() => create();
  static $pb.PbList<LoanProductSearchRequest> createRepeated() => $pb.PbList<LoanProductSearchRequest>();
  @$core.pragma('dart2js:noInline')
  static LoanProductSearchRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LoanProductSearchRequest>(create);
  static LoanProductSearchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get query => $_getSZ(0);
  @$pb.TagNumber(1)
  set query($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasQuery() => $_has(0);
  @$pb.TagNumber(1)
  void clearQuery() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get organizationId => $_getSZ(1);
  @$pb.TagNumber(2)
  set organizationId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasOrganizationId() => $_has(1);
  @$pb.TagNumber(2)
  void clearOrganizationId() => clearField(2);

  @$pb.TagNumber(3)
  LoanProductType get productType => $_getN(2);
  @$pb.TagNumber(3)
  set productType(LoanProductType v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasProductType() => $_has(2);
  @$pb.TagNumber(3)
  void clearProductType() => clearField(3);

  @$pb.TagNumber(4)
  $8.PageCursor get cursor => $_getN(3);
  @$pb.TagNumber(4)
  set cursor($8.PageCursor v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasCursor() => $_has(3);
  @$pb.TagNumber(4)
  void clearCursor() => clearField(4);
  @$pb.TagNumber(4)
  $8.PageCursor ensureCursor() => $_ensure(3);
}

class LoanProductSearchResponse extends $pb.GeneratedMessage {
  factory LoanProductSearchResponse({
    $core.Iterable<LoanProductObject>? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data.addAll(data);
    }
    return $result;
  }
  LoanProductSearchResponse._() : super();
  factory LoanProductSearchResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory LoanProductSearchResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LoanProductSearchResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'), createEmptyInstance: create)
    ..pc<LoanProductObject>(1, _omitFieldNames ? '' : 'data', $pb.PbFieldType.PM, subBuilder: LoanProductObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  LoanProductSearchResponse clone() => LoanProductSearchResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  LoanProductSearchResponse copyWith(void Function(LoanProductSearchResponse) updates) => super.copyWith((message) => updates(message as LoanProductSearchResponse)) as LoanProductSearchResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LoanProductSearchResponse create() => LoanProductSearchResponse._();
  LoanProductSearchResponse createEmptyInstance() => create();
  static $pb.PbList<LoanProductSearchResponse> createRepeated() => $pb.PbList<LoanProductSearchResponse>();
  @$core.pragma('dart2js:noInline')
  static LoanProductSearchResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LoanProductSearchResponse>(create);
  static LoanProductSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<LoanProductObject> get data => $_getList(0);
}

class LoanRequestSaveRequest extends $pb.GeneratedMessage {
  factory LoanRequestSaveRequest({
    LoanRequestObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  LoanRequestSaveRequest._() : super();
  factory LoanRequestSaveRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory LoanRequestSaveRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LoanRequestSaveRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'), createEmptyInstance: create)
    ..aOM<LoanRequestObject>(1, _omitFieldNames ? '' : 'data', subBuilder: LoanRequestObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  LoanRequestSaveRequest clone() => LoanRequestSaveRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  LoanRequestSaveRequest copyWith(void Function(LoanRequestSaveRequest) updates) => super.copyWith((message) => updates(message as LoanRequestSaveRequest)) as LoanRequestSaveRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LoanRequestSaveRequest create() => LoanRequestSaveRequest._();
  LoanRequestSaveRequest createEmptyInstance() => create();
  static $pb.PbList<LoanRequestSaveRequest> createRepeated() => $pb.PbList<LoanRequestSaveRequest>();
  @$core.pragma('dart2js:noInline')
  static LoanRequestSaveRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LoanRequestSaveRequest>(create);
  static LoanRequestSaveRequest? _defaultInstance;

  @$pb.TagNumber(1)
  LoanRequestObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(LoanRequestObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  LoanRequestObject ensureData() => $_ensure(0);
}

class LoanRequestSaveResponse extends $pb.GeneratedMessage {
  factory LoanRequestSaveResponse({
    LoanRequestObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  LoanRequestSaveResponse._() : super();
  factory LoanRequestSaveResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory LoanRequestSaveResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LoanRequestSaveResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'), createEmptyInstance: create)
    ..aOM<LoanRequestObject>(1, _omitFieldNames ? '' : 'data', subBuilder: LoanRequestObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  LoanRequestSaveResponse clone() => LoanRequestSaveResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  LoanRequestSaveResponse copyWith(void Function(LoanRequestSaveResponse) updates) => super.copyWith((message) => updates(message as LoanRequestSaveResponse)) as LoanRequestSaveResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LoanRequestSaveResponse create() => LoanRequestSaveResponse._();
  LoanRequestSaveResponse createEmptyInstance() => create();
  static $pb.PbList<LoanRequestSaveResponse> createRepeated() => $pb.PbList<LoanRequestSaveResponse>();
  @$core.pragma('dart2js:noInline')
  static LoanRequestSaveResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LoanRequestSaveResponse>(create);
  static LoanRequestSaveResponse? _defaultInstance;

  @$pb.TagNumber(1)
  LoanRequestObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(LoanRequestObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  LoanRequestObject ensureData() => $_ensure(0);
}

class LoanRequestGetRequest extends $pb.GeneratedMessage {
  factory LoanRequestGetRequest({
    $core.String? id,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    return $result;
  }
  LoanRequestGetRequest._() : super();
  factory LoanRequestGetRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory LoanRequestGetRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LoanRequestGetRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  LoanRequestGetRequest clone() => LoanRequestGetRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  LoanRequestGetRequest copyWith(void Function(LoanRequestGetRequest) updates) => super.copyWith((message) => updates(message as LoanRequestGetRequest)) as LoanRequestGetRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LoanRequestGetRequest create() => LoanRequestGetRequest._();
  LoanRequestGetRequest createEmptyInstance() => create();
  static $pb.PbList<LoanRequestGetRequest> createRepeated() => $pb.PbList<LoanRequestGetRequest>();
  @$core.pragma('dart2js:noInline')
  static LoanRequestGetRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LoanRequestGetRequest>(create);
  static LoanRequestGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);
}

class LoanRequestGetResponse extends $pb.GeneratedMessage {
  factory LoanRequestGetResponse({
    LoanRequestObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  LoanRequestGetResponse._() : super();
  factory LoanRequestGetResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory LoanRequestGetResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LoanRequestGetResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'), createEmptyInstance: create)
    ..aOM<LoanRequestObject>(1, _omitFieldNames ? '' : 'data', subBuilder: LoanRequestObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  LoanRequestGetResponse clone() => LoanRequestGetResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  LoanRequestGetResponse copyWith(void Function(LoanRequestGetResponse) updates) => super.copyWith((message) => updates(message as LoanRequestGetResponse)) as LoanRequestGetResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LoanRequestGetResponse create() => LoanRequestGetResponse._();
  LoanRequestGetResponse createEmptyInstance() => create();
  static $pb.PbList<LoanRequestGetResponse> createRepeated() => $pb.PbList<LoanRequestGetResponse>();
  @$core.pragma('dart2js:noInline')
  static LoanRequestGetResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LoanRequestGetResponse>(create);
  static LoanRequestGetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  LoanRequestObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(LoanRequestObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
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
    $8.PageCursor? cursor,
  }) {
    final $result = create();
    if (query != null) {
      $result.query = query;
    }
    if (clientId != null) {
      $result.clientId = clientId;
    }
    if (agentId != null) {
      $result.agentId = agentId;
    }
    if (branchId != null) {
      $result.branchId = branchId;
    }
    if (organizationId != null) {
      $result.organizationId = organizationId;
    }
    if (status != null) {
      $result.status = status;
    }
    if (sourceService != null) {
      $result.sourceService = sourceService;
    }
    if (cursor != null) {
      $result.cursor = cursor;
    }
    return $result;
  }
  LoanRequestSearchRequest._() : super();
  factory LoanRequestSearchRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory LoanRequestSearchRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LoanRequestSearchRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'query')
    ..aOS(2, _omitFieldNames ? '' : 'clientId')
    ..aOS(3, _omitFieldNames ? '' : 'agentId')
    ..aOS(4, _omitFieldNames ? '' : 'branchId')
    ..aOS(5, _omitFieldNames ? '' : 'organizationId')
    ..e<LoanRequestStatus>(6, _omitFieldNames ? '' : 'status', $pb.PbFieldType.OE, defaultOrMaker: LoanRequestStatus.LOAN_REQUEST_STATUS_UNSPECIFIED, valueOf: LoanRequestStatus.valueOf, enumValues: LoanRequestStatus.values)
    ..aOS(7, _omitFieldNames ? '' : 'sourceService')
    ..aOM<$8.PageCursor>(8, _omitFieldNames ? '' : 'cursor', subBuilder: $8.PageCursor.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  LoanRequestSearchRequest clone() => LoanRequestSearchRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  LoanRequestSearchRequest copyWith(void Function(LoanRequestSearchRequest) updates) => super.copyWith((message) => updates(message as LoanRequestSearchRequest)) as LoanRequestSearchRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LoanRequestSearchRequest create() => LoanRequestSearchRequest._();
  LoanRequestSearchRequest createEmptyInstance() => create();
  static $pb.PbList<LoanRequestSearchRequest> createRepeated() => $pb.PbList<LoanRequestSearchRequest>();
  @$core.pragma('dart2js:noInline')
  static LoanRequestSearchRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LoanRequestSearchRequest>(create);
  static LoanRequestSearchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get query => $_getSZ(0);
  @$pb.TagNumber(1)
  set query($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasQuery() => $_has(0);
  @$pb.TagNumber(1)
  void clearQuery() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get clientId => $_getSZ(1);
  @$pb.TagNumber(2)
  set clientId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasClientId() => $_has(1);
  @$pb.TagNumber(2)
  void clearClientId() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get agentId => $_getSZ(2);
  @$pb.TagNumber(3)
  set agentId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasAgentId() => $_has(2);
  @$pb.TagNumber(3)
  void clearAgentId() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get branchId => $_getSZ(3);
  @$pb.TagNumber(4)
  set branchId($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasBranchId() => $_has(3);
  @$pb.TagNumber(4)
  void clearBranchId() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get organizationId => $_getSZ(4);
  @$pb.TagNumber(5)
  set organizationId($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasOrganizationId() => $_has(4);
  @$pb.TagNumber(5)
  void clearOrganizationId() => clearField(5);

  @$pb.TagNumber(6)
  LoanRequestStatus get status => $_getN(5);
  @$pb.TagNumber(6)
  set status(LoanRequestStatus v) { setField(6, v); }
  @$pb.TagNumber(6)
  $core.bool hasStatus() => $_has(5);
  @$pb.TagNumber(6)
  void clearStatus() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get sourceService => $_getSZ(6);
  @$pb.TagNumber(7)
  set sourceService($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasSourceService() => $_has(6);
  @$pb.TagNumber(7)
  void clearSourceService() => clearField(7);

  @$pb.TagNumber(8)
  $8.PageCursor get cursor => $_getN(7);
  @$pb.TagNumber(8)
  set cursor($8.PageCursor v) { setField(8, v); }
  @$pb.TagNumber(8)
  $core.bool hasCursor() => $_has(7);
  @$pb.TagNumber(8)
  void clearCursor() => clearField(8);
  @$pb.TagNumber(8)
  $8.PageCursor ensureCursor() => $_ensure(7);
}

class LoanRequestSearchResponse extends $pb.GeneratedMessage {
  factory LoanRequestSearchResponse({
    $core.Iterable<LoanRequestObject>? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data.addAll(data);
    }
    return $result;
  }
  LoanRequestSearchResponse._() : super();
  factory LoanRequestSearchResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory LoanRequestSearchResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LoanRequestSearchResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'), createEmptyInstance: create)
    ..pc<LoanRequestObject>(1, _omitFieldNames ? '' : 'data', $pb.PbFieldType.PM, subBuilder: LoanRequestObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  LoanRequestSearchResponse clone() => LoanRequestSearchResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  LoanRequestSearchResponse copyWith(void Function(LoanRequestSearchResponse) updates) => super.copyWith((message) => updates(message as LoanRequestSearchResponse)) as LoanRequestSearchResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LoanRequestSearchResponse create() => LoanRequestSearchResponse._();
  LoanRequestSearchResponse createEmptyInstance() => create();
  static $pb.PbList<LoanRequestSearchResponse> createRepeated() => $pb.PbList<LoanRequestSearchResponse>();
  @$core.pragma('dart2js:noInline')
  static LoanRequestSearchResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LoanRequestSearchResponse>(create);
  static LoanRequestSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<LoanRequestObject> get data => $_getList(0);
}

class LoanRequestApproveRequest extends $pb.GeneratedMessage {
  factory LoanRequestApproveRequest({
    $core.String? id,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    return $result;
  }
  LoanRequestApproveRequest._() : super();
  factory LoanRequestApproveRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory LoanRequestApproveRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LoanRequestApproveRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  LoanRequestApproveRequest clone() => LoanRequestApproveRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  LoanRequestApproveRequest copyWith(void Function(LoanRequestApproveRequest) updates) => super.copyWith((message) => updates(message as LoanRequestApproveRequest)) as LoanRequestApproveRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LoanRequestApproveRequest create() => LoanRequestApproveRequest._();
  LoanRequestApproveRequest createEmptyInstance() => create();
  static $pb.PbList<LoanRequestApproveRequest> createRepeated() => $pb.PbList<LoanRequestApproveRequest>();
  @$core.pragma('dart2js:noInline')
  static LoanRequestApproveRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LoanRequestApproveRequest>(create);
  static LoanRequestApproveRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);
}

class LoanRequestApproveResponse extends $pb.GeneratedMessage {
  factory LoanRequestApproveResponse({
    LoanRequestObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  LoanRequestApproveResponse._() : super();
  factory LoanRequestApproveResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory LoanRequestApproveResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LoanRequestApproveResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'), createEmptyInstance: create)
    ..aOM<LoanRequestObject>(1, _omitFieldNames ? '' : 'data', subBuilder: LoanRequestObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  LoanRequestApproveResponse clone() => LoanRequestApproveResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  LoanRequestApproveResponse copyWith(void Function(LoanRequestApproveResponse) updates) => super.copyWith((message) => updates(message as LoanRequestApproveResponse)) as LoanRequestApproveResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LoanRequestApproveResponse create() => LoanRequestApproveResponse._();
  LoanRequestApproveResponse createEmptyInstance() => create();
  static $pb.PbList<LoanRequestApproveResponse> createRepeated() => $pb.PbList<LoanRequestApproveResponse>();
  @$core.pragma('dart2js:noInline')
  static LoanRequestApproveResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LoanRequestApproveResponse>(create);
  static LoanRequestApproveResponse? _defaultInstance;

  @$pb.TagNumber(1)
  LoanRequestObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(LoanRequestObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  LoanRequestObject ensureData() => $_ensure(0);
}

class LoanRequestRejectRequest extends $pb.GeneratedMessage {
  factory LoanRequestRejectRequest({
    $core.String? id,
    $core.String? reason,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (reason != null) {
      $result.reason = reason;
    }
    return $result;
  }
  LoanRequestRejectRequest._() : super();
  factory LoanRequestRejectRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory LoanRequestRejectRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LoanRequestRejectRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'reason')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  LoanRequestRejectRequest clone() => LoanRequestRejectRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  LoanRequestRejectRequest copyWith(void Function(LoanRequestRejectRequest) updates) => super.copyWith((message) => updates(message as LoanRequestRejectRequest)) as LoanRequestRejectRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LoanRequestRejectRequest create() => LoanRequestRejectRequest._();
  LoanRequestRejectRequest createEmptyInstance() => create();
  static $pb.PbList<LoanRequestRejectRequest> createRepeated() => $pb.PbList<LoanRequestRejectRequest>();
  @$core.pragma('dart2js:noInline')
  static LoanRequestRejectRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LoanRequestRejectRequest>(create);
  static LoanRequestRejectRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get reason => $_getSZ(1);
  @$pb.TagNumber(2)
  set reason($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasReason() => $_has(1);
  @$pb.TagNumber(2)
  void clearReason() => clearField(2);
}

class LoanRequestRejectResponse extends $pb.GeneratedMessage {
  factory LoanRequestRejectResponse({
    LoanRequestObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  LoanRequestRejectResponse._() : super();
  factory LoanRequestRejectResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory LoanRequestRejectResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LoanRequestRejectResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'), createEmptyInstance: create)
    ..aOM<LoanRequestObject>(1, _omitFieldNames ? '' : 'data', subBuilder: LoanRequestObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  LoanRequestRejectResponse clone() => LoanRequestRejectResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  LoanRequestRejectResponse copyWith(void Function(LoanRequestRejectResponse) updates) => super.copyWith((message) => updates(message as LoanRequestRejectResponse)) as LoanRequestRejectResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LoanRequestRejectResponse create() => LoanRequestRejectResponse._();
  LoanRequestRejectResponse createEmptyInstance() => create();
  static $pb.PbList<LoanRequestRejectResponse> createRepeated() => $pb.PbList<LoanRequestRejectResponse>();
  @$core.pragma('dart2js:noInline')
  static LoanRequestRejectResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LoanRequestRejectResponse>(create);
  static LoanRequestRejectResponse? _defaultInstance;

  @$pb.TagNumber(1)
  LoanRequestObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(LoanRequestObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  LoanRequestObject ensureData() => $_ensure(0);
}

class LoanRequestCancelRequest extends $pb.GeneratedMessage {
  factory LoanRequestCancelRequest({
    $core.String? id,
    $core.String? reason,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (reason != null) {
      $result.reason = reason;
    }
    return $result;
  }
  LoanRequestCancelRequest._() : super();
  factory LoanRequestCancelRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory LoanRequestCancelRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LoanRequestCancelRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'reason')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  LoanRequestCancelRequest clone() => LoanRequestCancelRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  LoanRequestCancelRequest copyWith(void Function(LoanRequestCancelRequest) updates) => super.copyWith((message) => updates(message as LoanRequestCancelRequest)) as LoanRequestCancelRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LoanRequestCancelRequest create() => LoanRequestCancelRequest._();
  LoanRequestCancelRequest createEmptyInstance() => create();
  static $pb.PbList<LoanRequestCancelRequest> createRepeated() => $pb.PbList<LoanRequestCancelRequest>();
  @$core.pragma('dart2js:noInline')
  static LoanRequestCancelRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LoanRequestCancelRequest>(create);
  static LoanRequestCancelRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get reason => $_getSZ(1);
  @$pb.TagNumber(2)
  set reason($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasReason() => $_has(1);
  @$pb.TagNumber(2)
  void clearReason() => clearField(2);
}

class LoanRequestCancelResponse extends $pb.GeneratedMessage {
  factory LoanRequestCancelResponse({
    LoanRequestObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  LoanRequestCancelResponse._() : super();
  factory LoanRequestCancelResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory LoanRequestCancelResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LoanRequestCancelResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'), createEmptyInstance: create)
    ..aOM<LoanRequestObject>(1, _omitFieldNames ? '' : 'data', subBuilder: LoanRequestObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  LoanRequestCancelResponse clone() => LoanRequestCancelResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  LoanRequestCancelResponse copyWith(void Function(LoanRequestCancelResponse) updates) => super.copyWith((message) => updates(message as LoanRequestCancelResponse)) as LoanRequestCancelResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LoanRequestCancelResponse create() => LoanRequestCancelResponse._();
  LoanRequestCancelResponse createEmptyInstance() => create();
  static $pb.PbList<LoanRequestCancelResponse> createRepeated() => $pb.PbList<LoanRequestCancelResponse>();
  @$core.pragma('dart2js:noInline')
  static LoanRequestCancelResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LoanRequestCancelResponse>(create);
  static LoanRequestCancelResponse? _defaultInstance;

  @$pb.TagNumber(1)
  LoanRequestObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(LoanRequestObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  LoanRequestObject ensureData() => $_ensure(0);
}

class ClientProductAccessSaveRequest extends $pb.GeneratedMessage {
  factory ClientProductAccessSaveRequest({
    ClientProductAccessObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  ClientProductAccessSaveRequest._() : super();
  factory ClientProductAccessSaveRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ClientProductAccessSaveRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ClientProductAccessSaveRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'), createEmptyInstance: create)
    ..aOM<ClientProductAccessObject>(1, _omitFieldNames ? '' : 'data', subBuilder: ClientProductAccessObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ClientProductAccessSaveRequest clone() => ClientProductAccessSaveRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ClientProductAccessSaveRequest copyWith(void Function(ClientProductAccessSaveRequest) updates) => super.copyWith((message) => updates(message as ClientProductAccessSaveRequest)) as ClientProductAccessSaveRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ClientProductAccessSaveRequest create() => ClientProductAccessSaveRequest._();
  ClientProductAccessSaveRequest createEmptyInstance() => create();
  static $pb.PbList<ClientProductAccessSaveRequest> createRepeated() => $pb.PbList<ClientProductAccessSaveRequest>();
  @$core.pragma('dart2js:noInline')
  static ClientProductAccessSaveRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ClientProductAccessSaveRequest>(create);
  static ClientProductAccessSaveRequest? _defaultInstance;

  @$pb.TagNumber(1)
  ClientProductAccessObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(ClientProductAccessObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  ClientProductAccessObject ensureData() => $_ensure(0);
}

class ClientProductAccessSaveResponse extends $pb.GeneratedMessage {
  factory ClientProductAccessSaveResponse({
    ClientProductAccessObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  ClientProductAccessSaveResponse._() : super();
  factory ClientProductAccessSaveResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ClientProductAccessSaveResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ClientProductAccessSaveResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'), createEmptyInstance: create)
    ..aOM<ClientProductAccessObject>(1, _omitFieldNames ? '' : 'data', subBuilder: ClientProductAccessObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ClientProductAccessSaveResponse clone() => ClientProductAccessSaveResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ClientProductAccessSaveResponse copyWith(void Function(ClientProductAccessSaveResponse) updates) => super.copyWith((message) => updates(message as ClientProductAccessSaveResponse)) as ClientProductAccessSaveResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ClientProductAccessSaveResponse create() => ClientProductAccessSaveResponse._();
  ClientProductAccessSaveResponse createEmptyInstance() => create();
  static $pb.PbList<ClientProductAccessSaveResponse> createRepeated() => $pb.PbList<ClientProductAccessSaveResponse>();
  @$core.pragma('dart2js:noInline')
  static ClientProductAccessSaveResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ClientProductAccessSaveResponse>(create);
  static ClientProductAccessSaveResponse? _defaultInstance;

  @$pb.TagNumber(1)
  ClientProductAccessObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(ClientProductAccessObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  ClientProductAccessObject ensureData() => $_ensure(0);
}

class ClientProductAccessGetRequest extends $pb.GeneratedMessage {
  factory ClientProductAccessGetRequest({
    $core.String? id,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    return $result;
  }
  ClientProductAccessGetRequest._() : super();
  factory ClientProductAccessGetRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ClientProductAccessGetRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ClientProductAccessGetRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ClientProductAccessGetRequest clone() => ClientProductAccessGetRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ClientProductAccessGetRequest copyWith(void Function(ClientProductAccessGetRequest) updates) => super.copyWith((message) => updates(message as ClientProductAccessGetRequest)) as ClientProductAccessGetRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ClientProductAccessGetRequest create() => ClientProductAccessGetRequest._();
  ClientProductAccessGetRequest createEmptyInstance() => create();
  static $pb.PbList<ClientProductAccessGetRequest> createRepeated() => $pb.PbList<ClientProductAccessGetRequest>();
  @$core.pragma('dart2js:noInline')
  static ClientProductAccessGetRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ClientProductAccessGetRequest>(create);
  static ClientProductAccessGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);
}

class ClientProductAccessGetResponse extends $pb.GeneratedMessage {
  factory ClientProductAccessGetResponse({
    ClientProductAccessObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  ClientProductAccessGetResponse._() : super();
  factory ClientProductAccessGetResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ClientProductAccessGetResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ClientProductAccessGetResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'), createEmptyInstance: create)
    ..aOM<ClientProductAccessObject>(1, _omitFieldNames ? '' : 'data', subBuilder: ClientProductAccessObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ClientProductAccessGetResponse clone() => ClientProductAccessGetResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ClientProductAccessGetResponse copyWith(void Function(ClientProductAccessGetResponse) updates) => super.copyWith((message) => updates(message as ClientProductAccessGetResponse)) as ClientProductAccessGetResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ClientProductAccessGetResponse create() => ClientProductAccessGetResponse._();
  ClientProductAccessGetResponse createEmptyInstance() => create();
  static $pb.PbList<ClientProductAccessGetResponse> createRepeated() => $pb.PbList<ClientProductAccessGetResponse>();
  @$core.pragma('dart2js:noInline')
  static ClientProductAccessGetResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ClientProductAccessGetResponse>(create);
  static ClientProductAccessGetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  ClientProductAccessObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(ClientProductAccessObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  ClientProductAccessObject ensureData() => $_ensure(0);
}

class ClientProductAccessSearchRequest extends $pb.GeneratedMessage {
  factory ClientProductAccessSearchRequest({
    $core.String? clientId,
    $core.String? productId,
    $8.PageCursor? cursor,
  }) {
    final $result = create();
    if (clientId != null) {
      $result.clientId = clientId;
    }
    if (productId != null) {
      $result.productId = productId;
    }
    if (cursor != null) {
      $result.cursor = cursor;
    }
    return $result;
  }
  ClientProductAccessSearchRequest._() : super();
  factory ClientProductAccessSearchRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ClientProductAccessSearchRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ClientProductAccessSearchRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'clientId')
    ..aOS(2, _omitFieldNames ? '' : 'productId')
    ..aOM<$8.PageCursor>(3, _omitFieldNames ? '' : 'cursor', subBuilder: $8.PageCursor.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ClientProductAccessSearchRequest clone() => ClientProductAccessSearchRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ClientProductAccessSearchRequest copyWith(void Function(ClientProductAccessSearchRequest) updates) => super.copyWith((message) => updates(message as ClientProductAccessSearchRequest)) as ClientProductAccessSearchRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ClientProductAccessSearchRequest create() => ClientProductAccessSearchRequest._();
  ClientProductAccessSearchRequest createEmptyInstance() => create();
  static $pb.PbList<ClientProductAccessSearchRequest> createRepeated() => $pb.PbList<ClientProductAccessSearchRequest>();
  @$core.pragma('dart2js:noInline')
  static ClientProductAccessSearchRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ClientProductAccessSearchRequest>(create);
  static ClientProductAccessSearchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get clientId => $_getSZ(0);
  @$pb.TagNumber(1)
  set clientId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasClientId() => $_has(0);
  @$pb.TagNumber(1)
  void clearClientId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get productId => $_getSZ(1);
  @$pb.TagNumber(2)
  set productId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasProductId() => $_has(1);
  @$pb.TagNumber(2)
  void clearProductId() => clearField(2);

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

class ClientProductAccessSearchResponse extends $pb.GeneratedMessage {
  factory ClientProductAccessSearchResponse({
    $core.Iterable<ClientProductAccessObject>? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data.addAll(data);
    }
    return $result;
  }
  ClientProductAccessSearchResponse._() : super();
  factory ClientProductAccessSearchResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ClientProductAccessSearchResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ClientProductAccessSearchResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'), createEmptyInstance: create)
    ..pc<ClientProductAccessObject>(1, _omitFieldNames ? '' : 'data', $pb.PbFieldType.PM, subBuilder: ClientProductAccessObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ClientProductAccessSearchResponse clone() => ClientProductAccessSearchResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ClientProductAccessSearchResponse copyWith(void Function(ClientProductAccessSearchResponse) updates) => super.copyWith((message) => updates(message as ClientProductAccessSearchResponse)) as ClientProductAccessSearchResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ClientProductAccessSearchResponse create() => ClientProductAccessSearchResponse._();
  ClientProductAccessSearchResponse createEmptyInstance() => create();
  static $pb.PbList<ClientProductAccessSearchResponse> createRepeated() => $pb.PbList<ClientProductAccessSearchResponse>();
  @$core.pragma('dart2js:noInline')
  static ClientProductAccessSearchResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ClientProductAccessSearchResponse>(create);
  static ClientProductAccessSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<ClientProductAccessObject> get data => $_getList(0);
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
    $7.Money? totalDisbursed,
    $7.Money? totalOutstanding,
    $7.Money? totalCollected,
    $7.Money? principalOutstanding,
    $7.Money? interestOutstanding,
    $7.Money? feesOutstanding,
    $7.Money? penaltiesOutstanding,
    $core.String? currencyCode,
    $core.String? collectionRate,
    $core.String? par30,
  }) {
    final $result = create();
    if (totalLoans != null) {
      $result.totalLoans = totalLoans;
    }
    if (activeLoans != null) {
      $result.activeLoans = activeLoans;
    }
    if (delinquentLoans != null) {
      $result.delinquentLoans = delinquentLoans;
    }
    if (defaultLoans != null) {
      $result.defaultLoans = defaultLoans;
    }
    if (paidOffLoans != null) {
      $result.paidOffLoans = paidOffLoans;
    }
    if (writtenOffLoans != null) {
      $result.writtenOffLoans = writtenOffLoans;
    }
    if (totalDisbursed != null) {
      $result.totalDisbursed = totalDisbursed;
    }
    if (totalOutstanding != null) {
      $result.totalOutstanding = totalOutstanding;
    }
    if (totalCollected != null) {
      $result.totalCollected = totalCollected;
    }
    if (principalOutstanding != null) {
      $result.principalOutstanding = principalOutstanding;
    }
    if (interestOutstanding != null) {
      $result.interestOutstanding = interestOutstanding;
    }
    if (feesOutstanding != null) {
      $result.feesOutstanding = feesOutstanding;
    }
    if (penaltiesOutstanding != null) {
      $result.penaltiesOutstanding = penaltiesOutstanding;
    }
    if (currencyCode != null) {
      $result.currencyCode = currencyCode;
    }
    if (collectionRate != null) {
      $result.collectionRate = collectionRate;
    }
    if (par30 != null) {
      $result.par30 = par30;
    }
    return $result;
  }
  PortfolioSummary._() : super();
  factory PortfolioSummary.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PortfolioSummary.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PortfolioSummary', package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'totalLoans', $pb.PbFieldType.O3)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'activeLoans', $pb.PbFieldType.O3)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'delinquentLoans', $pb.PbFieldType.O3)
    ..a<$core.int>(4, _omitFieldNames ? '' : 'defaultLoans', $pb.PbFieldType.O3)
    ..a<$core.int>(5, _omitFieldNames ? '' : 'paidOffLoans', $pb.PbFieldType.O3)
    ..a<$core.int>(6, _omitFieldNames ? '' : 'writtenOffLoans', $pb.PbFieldType.O3)
    ..aOM<$7.Money>(7, _omitFieldNames ? '' : 'totalDisbursed', subBuilder: $7.Money.create)
    ..aOM<$7.Money>(8, _omitFieldNames ? '' : 'totalOutstanding', subBuilder: $7.Money.create)
    ..aOM<$7.Money>(9, _omitFieldNames ? '' : 'totalCollected', subBuilder: $7.Money.create)
    ..aOM<$7.Money>(10, _omitFieldNames ? '' : 'principalOutstanding', subBuilder: $7.Money.create)
    ..aOM<$7.Money>(11, _omitFieldNames ? '' : 'interestOutstanding', subBuilder: $7.Money.create)
    ..aOM<$7.Money>(12, _omitFieldNames ? '' : 'feesOutstanding', subBuilder: $7.Money.create)
    ..aOM<$7.Money>(13, _omitFieldNames ? '' : 'penaltiesOutstanding', subBuilder: $7.Money.create)
    ..aOS(14, _omitFieldNames ? '' : 'currencyCode')
    ..aOS(15, _omitFieldNames ? '' : 'collectionRate')
    ..aOS(16, _omitFieldNames ? '' : 'par30', protoName: 'par_30')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PortfolioSummary clone() => PortfolioSummary()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PortfolioSummary copyWith(void Function(PortfolioSummary) updates) => super.copyWith((message) => updates(message as PortfolioSummary)) as PortfolioSummary;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PortfolioSummary create() => PortfolioSummary._();
  PortfolioSummary createEmptyInstance() => create();
  static $pb.PbList<PortfolioSummary> createRepeated() => $pb.PbList<PortfolioSummary>();
  @$core.pragma('dart2js:noInline')
  static PortfolioSummary getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PortfolioSummary>(create);
  static PortfolioSummary? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get totalLoans => $_getIZ(0);
  @$pb.TagNumber(1)
  set totalLoans($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTotalLoans() => $_has(0);
  @$pb.TagNumber(1)
  void clearTotalLoans() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get activeLoans => $_getIZ(1);
  @$pb.TagNumber(2)
  set activeLoans($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasActiveLoans() => $_has(1);
  @$pb.TagNumber(2)
  void clearActiveLoans() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get delinquentLoans => $_getIZ(2);
  @$pb.TagNumber(3)
  set delinquentLoans($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasDelinquentLoans() => $_has(2);
  @$pb.TagNumber(3)
  void clearDelinquentLoans() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get defaultLoans => $_getIZ(3);
  @$pb.TagNumber(4)
  set defaultLoans($core.int v) { $_setSignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasDefaultLoans() => $_has(3);
  @$pb.TagNumber(4)
  void clearDefaultLoans() => clearField(4);

  @$pb.TagNumber(5)
  $core.int get paidOffLoans => $_getIZ(4);
  @$pb.TagNumber(5)
  set paidOffLoans($core.int v) { $_setSignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasPaidOffLoans() => $_has(4);
  @$pb.TagNumber(5)
  void clearPaidOffLoans() => clearField(5);

  @$pb.TagNumber(6)
  $core.int get writtenOffLoans => $_getIZ(5);
  @$pb.TagNumber(6)
  set writtenOffLoans($core.int v) { $_setSignedInt32(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasWrittenOffLoans() => $_has(5);
  @$pb.TagNumber(6)
  void clearWrittenOffLoans() => clearField(6);

  @$pb.TagNumber(7)
  $7.Money get totalDisbursed => $_getN(6);
  @$pb.TagNumber(7)
  set totalDisbursed($7.Money v) { setField(7, v); }
  @$pb.TagNumber(7)
  $core.bool hasTotalDisbursed() => $_has(6);
  @$pb.TagNumber(7)
  void clearTotalDisbursed() => clearField(7);
  @$pb.TagNumber(7)
  $7.Money ensureTotalDisbursed() => $_ensure(6);

  @$pb.TagNumber(8)
  $7.Money get totalOutstanding => $_getN(7);
  @$pb.TagNumber(8)
  set totalOutstanding($7.Money v) { setField(8, v); }
  @$pb.TagNumber(8)
  $core.bool hasTotalOutstanding() => $_has(7);
  @$pb.TagNumber(8)
  void clearTotalOutstanding() => clearField(8);
  @$pb.TagNumber(8)
  $7.Money ensureTotalOutstanding() => $_ensure(7);

  @$pb.TagNumber(9)
  $7.Money get totalCollected => $_getN(8);
  @$pb.TagNumber(9)
  set totalCollected($7.Money v) { setField(9, v); }
  @$pb.TagNumber(9)
  $core.bool hasTotalCollected() => $_has(8);
  @$pb.TagNumber(9)
  void clearTotalCollected() => clearField(9);
  @$pb.TagNumber(9)
  $7.Money ensureTotalCollected() => $_ensure(8);

  @$pb.TagNumber(10)
  $7.Money get principalOutstanding => $_getN(9);
  @$pb.TagNumber(10)
  set principalOutstanding($7.Money v) { setField(10, v); }
  @$pb.TagNumber(10)
  $core.bool hasPrincipalOutstanding() => $_has(9);
  @$pb.TagNumber(10)
  void clearPrincipalOutstanding() => clearField(10);
  @$pb.TagNumber(10)
  $7.Money ensurePrincipalOutstanding() => $_ensure(9);

  @$pb.TagNumber(11)
  $7.Money get interestOutstanding => $_getN(10);
  @$pb.TagNumber(11)
  set interestOutstanding($7.Money v) { setField(11, v); }
  @$pb.TagNumber(11)
  $core.bool hasInterestOutstanding() => $_has(10);
  @$pb.TagNumber(11)
  void clearInterestOutstanding() => clearField(11);
  @$pb.TagNumber(11)
  $7.Money ensureInterestOutstanding() => $_ensure(10);

  @$pb.TagNumber(12)
  $7.Money get feesOutstanding => $_getN(11);
  @$pb.TagNumber(12)
  set feesOutstanding($7.Money v) { setField(12, v); }
  @$pb.TagNumber(12)
  $core.bool hasFeesOutstanding() => $_has(11);
  @$pb.TagNumber(12)
  void clearFeesOutstanding() => clearField(12);
  @$pb.TagNumber(12)
  $7.Money ensureFeesOutstanding() => $_ensure(11);

  @$pb.TagNumber(13)
  $7.Money get penaltiesOutstanding => $_getN(12);
  @$pb.TagNumber(13)
  set penaltiesOutstanding($7.Money v) { setField(13, v); }
  @$pb.TagNumber(13)
  $core.bool hasPenaltiesOutstanding() => $_has(12);
  @$pb.TagNumber(13)
  void clearPenaltiesOutstanding() => clearField(13);
  @$pb.TagNumber(13)
  $7.Money ensurePenaltiesOutstanding() => $_ensure(12);

  @$pb.TagNumber(14)
  $core.String get currencyCode => $_getSZ(13);
  @$pb.TagNumber(14)
  set currencyCode($core.String v) { $_setString(13, v); }
  @$pb.TagNumber(14)
  $core.bool hasCurrencyCode() => $_has(13);
  @$pb.TagNumber(14)
  void clearCurrencyCode() => clearField(14);

  /// collection_rate is total_collected / total_disbursed as a percentage string (e.g. "85.50").
  @$pb.TagNumber(15)
  $core.String get collectionRate => $_getSZ(14);
  @$pb.TagNumber(15)
  set collectionRate($core.String v) { $_setString(14, v); }
  @$pb.TagNumber(15)
  $core.bool hasCollectionRate() => $_has(14);
  @$pb.TagNumber(15)
  void clearCollectionRate() => clearField(15);

  /// par_30 is portfolio-at-risk > 30 days as a percentage string (e.g. "12.30").
  @$pb.TagNumber(16)
  $core.String get par30 => $_getSZ(15);
  @$pb.TagNumber(16)
  set par30($core.String v) { $_setString(15, v); }
  @$pb.TagNumber(16)
  $core.bool hasPar30() => $_has(15);
  @$pb.TagNumber(16)
  void clearPar30() => clearField(16);
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
    final $result = create();
    if (organizationId != null) {
      $result.organizationId = organizationId;
    }
    if (branchId != null) {
      $result.branchId = branchId;
    }
    if (agentId != null) {
      $result.agentId = agentId;
    }
    if (productId != null) {
      $result.productId = productId;
    }
    if (clientId != null) {
      $result.clientId = clientId;
    }
    if (currencyCode != null) {
      $result.currencyCode = currencyCode;
    }
    return $result;
  }
  PortfolioSummaryRequest._() : super();
  factory PortfolioSummaryRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PortfolioSummaryRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PortfolioSummaryRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'organizationId')
    ..aOS(2, _omitFieldNames ? '' : 'branchId')
    ..aOS(3, _omitFieldNames ? '' : 'agentId')
    ..aOS(4, _omitFieldNames ? '' : 'productId')
    ..aOS(5, _omitFieldNames ? '' : 'clientId')
    ..aOS(6, _omitFieldNames ? '' : 'currencyCode')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PortfolioSummaryRequest clone() => PortfolioSummaryRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PortfolioSummaryRequest copyWith(void Function(PortfolioSummaryRequest) updates) => super.copyWith((message) => updates(message as PortfolioSummaryRequest)) as PortfolioSummaryRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PortfolioSummaryRequest create() => PortfolioSummaryRequest._();
  PortfolioSummaryRequest createEmptyInstance() => create();
  static $pb.PbList<PortfolioSummaryRequest> createRepeated() => $pb.PbList<PortfolioSummaryRequest>();
  @$core.pragma('dart2js:noInline')
  static PortfolioSummaryRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PortfolioSummaryRequest>(create);
  static PortfolioSummaryRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get organizationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set organizationId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasOrganizationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearOrganizationId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get branchId => $_getSZ(1);
  @$pb.TagNumber(2)
  set branchId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasBranchId() => $_has(1);
  @$pb.TagNumber(2)
  void clearBranchId() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get agentId => $_getSZ(2);
  @$pb.TagNumber(3)
  set agentId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasAgentId() => $_has(2);
  @$pb.TagNumber(3)
  void clearAgentId() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get productId => $_getSZ(3);
  @$pb.TagNumber(4)
  set productId($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasProductId() => $_has(3);
  @$pb.TagNumber(4)
  void clearProductId() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get clientId => $_getSZ(4);
  @$pb.TagNumber(5)
  set clientId($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasClientId() => $_has(4);
  @$pb.TagNumber(5)
  void clearClientId() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get currencyCode => $_getSZ(5);
  @$pb.TagNumber(6)
  set currencyCode($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasCurrencyCode() => $_has(5);
  @$pb.TagNumber(6)
  void clearCurrencyCode() => clearField(6);
}

class PortfolioSummaryResponse extends $pb.GeneratedMessage {
  factory PortfolioSummaryResponse({
    PortfolioSummary? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  PortfolioSummaryResponse._() : super();
  factory PortfolioSummaryResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PortfolioSummaryResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PortfolioSummaryResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'), createEmptyInstance: create)
    ..aOM<PortfolioSummary>(1, _omitFieldNames ? '' : 'data', subBuilder: PortfolioSummary.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PortfolioSummaryResponse clone() => PortfolioSummaryResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PortfolioSummaryResponse copyWith(void Function(PortfolioSummaryResponse) updates) => super.copyWith((message) => updates(message as PortfolioSummaryResponse)) as PortfolioSummaryResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PortfolioSummaryResponse create() => PortfolioSummaryResponse._();
  PortfolioSummaryResponse createEmptyInstance() => create();
  static $pb.PbList<PortfolioSummaryResponse> createRepeated() => $pb.PbList<PortfolioSummaryResponse>();
  @$core.pragma('dart2js:noInline')
  static PortfolioSummaryResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PortfolioSummaryResponse>(create);
  static PortfolioSummaryResponse? _defaultInstance;

  @$pb.TagNumber(1)
  PortfolioSummary get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(PortfolioSummary v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
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
    final $result = create();
    if (organizationId != null) {
      $result.organizationId = organizationId;
    }
    if (branchId != null) {
      $result.branchId = branchId;
    }
    if (agentId != null) {
      $result.agentId = agentId;
    }
    if (productId != null) {
      $result.productId = productId;
    }
    if (clientId != null) {
      $result.clientId = clientId;
    }
    if (currencyCode != null) {
      $result.currencyCode = currencyCode;
    }
    if (format != null) {
      $result.format = format;
    }
    return $result;
  }
  PortfolioExportRequest._() : super();
  factory PortfolioExportRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PortfolioExportRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PortfolioExportRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'organizationId')
    ..aOS(2, _omitFieldNames ? '' : 'branchId')
    ..aOS(3, _omitFieldNames ? '' : 'agentId')
    ..aOS(4, _omitFieldNames ? '' : 'productId')
    ..aOS(5, _omitFieldNames ? '' : 'clientId')
    ..aOS(6, _omitFieldNames ? '' : 'currencyCode')
    ..aOS(7, _omitFieldNames ? '' : 'format')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PortfolioExportRequest clone() => PortfolioExportRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PortfolioExportRequest copyWith(void Function(PortfolioExportRequest) updates) => super.copyWith((message) => updates(message as PortfolioExportRequest)) as PortfolioExportRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PortfolioExportRequest create() => PortfolioExportRequest._();
  PortfolioExportRequest createEmptyInstance() => create();
  static $pb.PbList<PortfolioExportRequest> createRepeated() => $pb.PbList<PortfolioExportRequest>();
  @$core.pragma('dart2js:noInline')
  static PortfolioExportRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PortfolioExportRequest>(create);
  static PortfolioExportRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get organizationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set organizationId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasOrganizationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearOrganizationId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get branchId => $_getSZ(1);
  @$pb.TagNumber(2)
  set branchId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasBranchId() => $_has(1);
  @$pb.TagNumber(2)
  void clearBranchId() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get agentId => $_getSZ(2);
  @$pb.TagNumber(3)
  set agentId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasAgentId() => $_has(2);
  @$pb.TagNumber(3)
  void clearAgentId() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get productId => $_getSZ(3);
  @$pb.TagNumber(4)
  set productId($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasProductId() => $_has(3);
  @$pb.TagNumber(4)
  void clearProductId() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get clientId => $_getSZ(4);
  @$pb.TagNumber(5)
  set clientId($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasClientId() => $_has(4);
  @$pb.TagNumber(5)
  void clearClientId() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get currencyCode => $_getSZ(5);
  @$pb.TagNumber(6)
  set currencyCode($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasCurrencyCode() => $_has(5);
  @$pb.TagNumber(6)
  void clearCurrencyCode() => clearField(6);

  /// format is the export format: "CSV" (default).
  @$pb.TagNumber(7)
  $core.String get format => $_getSZ(6);
  @$pb.TagNumber(7)
  set format($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasFormat() => $_has(6);
  @$pb.TagNumber(7)
  void clearFormat() => clearField(7);
}

class PortfolioExportResponse extends $pb.GeneratedMessage {
  factory PortfolioExportResponse({
    $core.List<$core.int>? data,
    $core.String? filename,
    $core.String? contentType,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    if (filename != null) {
      $result.filename = filename;
    }
    if (contentType != null) {
      $result.contentType = contentType;
    }
    return $result;
  }
  PortfolioExportResponse._() : super();
  factory PortfolioExportResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PortfolioExportResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PortfolioExportResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'loans.v1'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, _omitFieldNames ? '' : 'data', $pb.PbFieldType.OY)
    ..aOS(2, _omitFieldNames ? '' : 'filename')
    ..aOS(3, _omitFieldNames ? '' : 'contentType')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PortfolioExportResponse clone() => PortfolioExportResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PortfolioExportResponse copyWith(void Function(PortfolioExportResponse) updates) => super.copyWith((message) => updates(message as PortfolioExportResponse)) as PortfolioExportResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PortfolioExportResponse create() => PortfolioExportResponse._();
  PortfolioExportResponse createEmptyInstance() => create();
  static $pb.PbList<PortfolioExportResponse> createRepeated() => $pb.PbList<PortfolioExportResponse>();
  @$core.pragma('dart2js:noInline')
  static PortfolioExportResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PortfolioExportResponse>(create);
  static PortfolioExportResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get data => $_getN(0);
  @$pb.TagNumber(1)
  set data($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get filename => $_getSZ(1);
  @$pb.TagNumber(2)
  set filename($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasFilename() => $_has(1);
  @$pb.TagNumber(2)
  void clearFilename() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get contentType => $_getSZ(2);
  @$pb.TagNumber(3)
  set contentType($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasContentType() => $_has(2);
  @$pb.TagNumber(3)
  void clearContentType() => clearField(3);
}

class LoanManagementServiceApi {
  $pb.RpcClient _client;
  LoanManagementServiceApi(this._client);

  $async.Future<LoanProductSaveResponse> loanProductSave($pb.ClientContext? ctx, LoanProductSaveRequest request) =>
    _client.invoke<LoanProductSaveResponse>(ctx, 'LoanManagementService', 'LoanProductSave', request, LoanProductSaveResponse())
  ;
  $async.Future<LoanProductGetResponse> loanProductGet($pb.ClientContext? ctx, LoanProductGetRequest request) =>
    _client.invoke<LoanProductGetResponse>(ctx, 'LoanManagementService', 'LoanProductGet', request, LoanProductGetResponse())
  ;
  $async.Future<LoanProductSearchResponse> loanProductSearch($pb.ClientContext? ctx, LoanProductSearchRequest request) =>
    _client.invoke<LoanProductSearchResponse>(ctx, 'LoanManagementService', 'LoanProductSearch', request, LoanProductSearchResponse())
  ;
  $async.Future<LoanRequestSaveResponse> loanRequestSave($pb.ClientContext? ctx, LoanRequestSaveRequest request) =>
    _client.invoke<LoanRequestSaveResponse>(ctx, 'LoanManagementService', 'LoanRequestSave', request, LoanRequestSaveResponse())
  ;
  $async.Future<LoanRequestGetResponse> loanRequestGet($pb.ClientContext? ctx, LoanRequestGetRequest request) =>
    _client.invoke<LoanRequestGetResponse>(ctx, 'LoanManagementService', 'LoanRequestGet', request, LoanRequestGetResponse())
  ;
  $async.Future<LoanRequestSearchResponse> loanRequestSearch($pb.ClientContext? ctx, LoanRequestSearchRequest request) =>
    _client.invoke<LoanRequestSearchResponse>(ctx, 'LoanManagementService', 'LoanRequestSearch', request, LoanRequestSearchResponse())
  ;
  $async.Future<LoanRequestApproveResponse> loanRequestApprove($pb.ClientContext? ctx, LoanRequestApproveRequest request) =>
    _client.invoke<LoanRequestApproveResponse>(ctx, 'LoanManagementService', 'LoanRequestApprove', request, LoanRequestApproveResponse())
  ;
  $async.Future<LoanRequestRejectResponse> loanRequestReject($pb.ClientContext? ctx, LoanRequestRejectRequest request) =>
    _client.invoke<LoanRequestRejectResponse>(ctx, 'LoanManagementService', 'LoanRequestReject', request, LoanRequestRejectResponse())
  ;
  $async.Future<LoanRequestCancelResponse> loanRequestCancel($pb.ClientContext? ctx, LoanRequestCancelRequest request) =>
    _client.invoke<LoanRequestCancelResponse>(ctx, 'LoanManagementService', 'LoanRequestCancel', request, LoanRequestCancelResponse())
  ;
  $async.Future<ClientProductAccessSaveResponse> clientProductAccessSave($pb.ClientContext? ctx, ClientProductAccessSaveRequest request) =>
    _client.invoke<ClientProductAccessSaveResponse>(ctx, 'LoanManagementService', 'ClientProductAccessSave', request, ClientProductAccessSaveResponse())
  ;
  $async.Future<ClientProductAccessGetResponse> clientProductAccessGet($pb.ClientContext? ctx, ClientProductAccessGetRequest request) =>
    _client.invoke<ClientProductAccessGetResponse>(ctx, 'LoanManagementService', 'ClientProductAccessGet', request, ClientProductAccessGetResponse())
  ;
  $async.Future<ClientProductAccessSearchResponse> clientProductAccessSearch($pb.ClientContext? ctx, ClientProductAccessSearchRequest request) =>
    _client.invoke<ClientProductAccessSearchResponse>(ctx, 'LoanManagementService', 'ClientProductAccessSearch', request, ClientProductAccessSearchResponse())
  ;
  $async.Future<LoanAccountCreateResponse> loanAccountCreate($pb.ClientContext? ctx, LoanAccountCreateRequest request) =>
    _client.invoke<LoanAccountCreateResponse>(ctx, 'LoanManagementService', 'LoanAccountCreate', request, LoanAccountCreateResponse())
  ;
  $async.Future<LoanAccountGetResponse> loanAccountGet($pb.ClientContext? ctx, LoanAccountGetRequest request) =>
    _client.invoke<LoanAccountGetResponse>(ctx, 'LoanManagementService', 'LoanAccountGet', request, LoanAccountGetResponse())
  ;
  $async.Future<LoanAccountSearchResponse> loanAccountSearch($pb.ClientContext? ctx, LoanAccountSearchRequest request) =>
    _client.invoke<LoanAccountSearchResponse>(ctx, 'LoanManagementService', 'LoanAccountSearch', request, LoanAccountSearchResponse())
  ;
  $async.Future<LoanBalanceGetResponse> loanBalanceGet($pb.ClientContext? ctx, LoanBalanceGetRequest request) =>
    _client.invoke<LoanBalanceGetResponse>(ctx, 'LoanManagementService', 'LoanBalanceGet', request, LoanBalanceGetResponse())
  ;
  $async.Future<LoanStatementResponse> loanStatement($pb.ClientContext? ctx, LoanStatementRequest request) =>
    _client.invoke<LoanStatementResponse>(ctx, 'LoanManagementService', 'LoanStatement', request, LoanStatementResponse())
  ;
  $async.Future<DisbursementCreateResponse> disbursementCreate($pb.ClientContext? ctx, DisbursementCreateRequest request) =>
    _client.invoke<DisbursementCreateResponse>(ctx, 'LoanManagementService', 'DisbursementCreate', request, DisbursementCreateResponse())
  ;
  $async.Future<DisbursementGetResponse> disbursementGet($pb.ClientContext? ctx, DisbursementGetRequest request) =>
    _client.invoke<DisbursementGetResponse>(ctx, 'LoanManagementService', 'DisbursementGet', request, DisbursementGetResponse())
  ;
  $async.Future<DisbursementSearchResponse> disbursementSearch($pb.ClientContext? ctx, DisbursementSearchRequest request) =>
    _client.invoke<DisbursementSearchResponse>(ctx, 'LoanManagementService', 'DisbursementSearch', request, DisbursementSearchResponse())
  ;
  $async.Future<RepaymentRecordResponse> repaymentRecord($pb.ClientContext? ctx, RepaymentRecordRequest request) =>
    _client.invoke<RepaymentRecordResponse>(ctx, 'LoanManagementService', 'RepaymentRecord', request, RepaymentRecordResponse())
  ;
  $async.Future<RepaymentGetResponse> repaymentGet($pb.ClientContext? ctx, RepaymentGetRequest request) =>
    _client.invoke<RepaymentGetResponse>(ctx, 'LoanManagementService', 'RepaymentGet', request, RepaymentGetResponse())
  ;
  $async.Future<RepaymentSearchResponse> repaymentSearch($pb.ClientContext? ctx, RepaymentSearchRequest request) =>
    _client.invoke<RepaymentSearchResponse>(ctx, 'LoanManagementService', 'RepaymentSearch', request, RepaymentSearchResponse())
  ;
  $async.Future<RepaymentScheduleGetResponse> repaymentScheduleGet($pb.ClientContext? ctx, RepaymentScheduleGetRequest request) =>
    _client.invoke<RepaymentScheduleGetResponse>(ctx, 'LoanManagementService', 'RepaymentScheduleGet', request, RepaymentScheduleGetResponse())
  ;
  $async.Future<PenaltySaveResponse> penaltySave($pb.ClientContext? ctx, PenaltySaveRequest request) =>
    _client.invoke<PenaltySaveResponse>(ctx, 'LoanManagementService', 'PenaltySave', request, PenaltySaveResponse())
  ;
  $async.Future<PenaltyWaiveResponse> penaltyWaive($pb.ClientContext? ctx, PenaltyWaiveRequest request) =>
    _client.invoke<PenaltyWaiveResponse>(ctx, 'LoanManagementService', 'PenaltyWaive', request, PenaltyWaiveResponse())
  ;
  $async.Future<PenaltySearchResponse> penaltySearch($pb.ClientContext? ctx, PenaltySearchRequest request) =>
    _client.invoke<PenaltySearchResponse>(ctx, 'LoanManagementService', 'PenaltySearch', request, PenaltySearchResponse())
  ;
  $async.Future<LoanRestructureCreateResponse> loanRestructureCreate($pb.ClientContext? ctx, LoanRestructureCreateRequest request) =>
    _client.invoke<LoanRestructureCreateResponse>(ctx, 'LoanManagementService', 'LoanRestructureCreate', request, LoanRestructureCreateResponse())
  ;
  $async.Future<LoanRestructureApproveResponse> loanRestructureApprove($pb.ClientContext? ctx, LoanRestructureApproveRequest request) =>
    _client.invoke<LoanRestructureApproveResponse>(ctx, 'LoanManagementService', 'LoanRestructureApprove', request, LoanRestructureApproveResponse())
  ;
  $async.Future<LoanRestructureRejectResponse> loanRestructureReject($pb.ClientContext? ctx, LoanRestructureRejectRequest request) =>
    _client.invoke<LoanRestructureRejectResponse>(ctx, 'LoanManagementService', 'LoanRestructureReject', request, LoanRestructureRejectResponse())
  ;
  $async.Future<LoanRestructureSearchResponse> loanRestructureSearch($pb.ClientContext? ctx, LoanRestructureSearchRequest request) =>
    _client.invoke<LoanRestructureSearchResponse>(ctx, 'LoanManagementService', 'LoanRestructureSearch', request, LoanRestructureSearchResponse())
  ;
  $async.Future<ReconciliationSaveResponse> reconciliationSave($pb.ClientContext? ctx, ReconciliationSaveRequest request) =>
    _client.invoke<ReconciliationSaveResponse>(ctx, 'LoanManagementService', 'ReconciliationSave', request, ReconciliationSaveResponse())
  ;
  $async.Future<ReconciliationSearchResponse> reconciliationSearch($pb.ClientContext? ctx, ReconciliationSearchRequest request) =>
    _client.invoke<ReconciliationSearchResponse>(ctx, 'LoanManagementService', 'ReconciliationSearch', request, ReconciliationSearchResponse())
  ;
  $async.Future<InitiateCollectionResponse> initiateCollection($pb.ClientContext? ctx, InitiateCollectionRequest request) =>
    _client.invoke<InitiateCollectionResponse>(ctx, 'LoanManagementService', 'InitiateCollection', request, InitiateCollectionResponse())
  ;
  $async.Future<LoanStatusChangeSearchResponse> loanStatusChangeSearch($pb.ClientContext? ctx, LoanStatusChangeSearchRequest request) =>
    _client.invoke<LoanStatusChangeSearchResponse>(ctx, 'LoanManagementService', 'LoanStatusChangeSearch', request, LoanStatusChangeSearchResponse())
  ;
  $async.Future<PortfolioSummaryResponse> portfolioSummary($pb.ClientContext? ctx, PortfolioSummaryRequest request) =>
    _client.invoke<PortfolioSummaryResponse>(ctx, 'LoanManagementService', 'PortfolioSummary', request, PortfolioSummaryResponse())
  ;
  $async.Future<PortfolioExportResponse> portfolioExport($pb.ClientContext? ctx, PortfolioExportRequest request) =>
    _client.invoke<PortfolioExportResponse>(ctx, 'LoanManagementService', 'PortfolioExport', request, PortfolioExportResponse())
  ;
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
