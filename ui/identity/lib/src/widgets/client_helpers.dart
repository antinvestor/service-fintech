import 'package:antinvestor_api_common/antinvestor_api_common.dart' as common;
import 'package:antinvestor_api_field/antinvestor_api_field.dart' as field;
import 'package:antinvestor_api_identity/antinvestor_api_identity.dart'
    show DataVerificationStatus;
import 'package:flutter/material.dart';

/// Converts the field package's STATE to the common package's STATE so the
/// ui_core StateBadge can render a client.
common.STATE fieldStateToCommon(field.STATE state) =>
    common.STATE.valueOf(state.value) ?? common.STATE.CREATED;

String verificationStatusLabel(DataVerificationStatus status) =>
    switch (status) {
      DataVerificationStatus.DATA_VERIFICATION_STATUS_COLLECTED => 'Collected',
      DataVerificationStatus.DATA_VERIFICATION_STATUS_UNDER_REVIEW =>
        'Under review',
      DataVerificationStatus.DATA_VERIFICATION_STATUS_VERIFIED => 'Verified',
      DataVerificationStatus.DATA_VERIFICATION_STATUS_REJECTED => 'Rejected',
      DataVerificationStatus.DATA_VERIFICATION_STATUS_MORE_INFO_NEEDED =>
        'More info needed',
      DataVerificationStatus.DATA_VERIFICATION_STATUS_EXPIRED => 'Expired',
      _ => 'Unknown',
    };

Color verificationStatusColor(DataVerificationStatus status) =>
    switch (status) {
      DataVerificationStatus.DATA_VERIFICATION_STATUS_VERIFIED => Colors.green,
      DataVerificationStatus.DATA_VERIFICATION_STATUS_REJECTED => Colors.red,
      DataVerificationStatus.DATA_VERIFICATION_STATUS_EXPIRED => Colors.red,
      DataVerificationStatus.DATA_VERIFICATION_STATUS_MORE_INFO_NEEDED =>
        Colors.orange,
      DataVerificationStatus.DATA_VERIFICATION_STATUS_UNDER_REVIEW =>
        Colors.blue,
      _ => Colors.grey,
    };

/// Whether a reviewer can still act on an entry. Verified, rejected and
/// expired entries are final; a new revision is saved instead.
bool verificationIsOpen(DataVerificationStatus status) =>
    status == DataVerificationStatus.DATA_VERIFICATION_STATUS_COLLECTED ||
    status == DataVerificationStatus.DATA_VERIFICATION_STATUS_UNDER_REVIEW ||
    status == DataVerificationStatus.DATA_VERIFICATION_STATUS_MORE_INFO_NEEDED;

/// Whether an entry is waiting for a reviewer to take it: collected, or back
/// from the client with more information.
bool verificationAwaitsReviewer(DataVerificationStatus status) =>
    status == DataVerificationStatus.DATA_VERIFICATION_STATUS_COLLECTED ||
    status == DataVerificationStatus.DATA_VERIFICATION_STATUS_MORE_INFO_NEEDED;
