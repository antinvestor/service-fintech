import 'dart:convert';

import 'package:antinvestor_ui_core/api/api_base.dart'
    show authTokenProviderProvider;
import 'package:antinvestor_ui_core/auth/auth_token_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../core/config/app_config.dart';

/// A client's Seed credit profile in one currency.
class CreditProfile {
  const CreditProfile({
    required this.tier,
    required this.maxLoanAmountMinor,
    required this.status,
    required this.successfulRepayments,
    required this.outstandingLoanCount,
    this.effectiveLimitMinor,
    this.tempCapMinor = 0,
    this.tempCapExpiresAt,
    this.tempCapReason = '',
  });

  factory CreditProfile.fromJson(Map<String, dynamic> json) => CreditProfile(
    tier: (json['tier'] as num?)?.toInt() ?? 0,
    maxLoanAmountMinor: (json['max_loan_amount'] as num?)?.toInt() ?? 0,
    effectiveLimitMinor: (json['effective_limit'] as num?)?.toInt(),
    tempCapMinor: (json['temp_cap_amount'] as num?)?.toInt() ?? 0,
    tempCapExpiresAt: DateTime.tryParse(
      json['temp_cap_expires_at'] as String? ?? '',
    ),
    tempCapReason: json['temp_cap_reason'] as String? ?? '',
    status: CreditProfileStatus.fromCode(
      (json['status'] as num?)?.toInt() ?? 0,
    ),
    successfulRepayments: (json['successful_repayments'] as num?)?.toInt() ?? 0,
    outstandingLoanCount:
        (json['outstanding_loan_count'] as num?)?.toInt() ?? 0,
  );

  final int tier;
  final int maxLoanAmountMinor;
  final CreditProfileStatus status;
  final int successfulRepayments;
  final int outstandingLoanCount;

  /// What the client may borrow now: the tier limit, lowered by a
  /// temporary cap while it lasts.
  final int? effectiveLimitMinor;
  final int tempCapMinor;
  final DateTime? tempCapExpiresAt;
  final String tempCapReason;

  int get borrowLimitMinor => effectiveLimitMinor ?? maxLoanAmountMinor;

  /// Whether a temporary cap applies now.
  bool get capActive =>
      tempCapMinor > 0 &&
      tempCapExpiresAt != null &&
      tempCapExpiresAt!.isAfter(DateTime.now());
}

/// Mirrors models.CreditProfileStatus in the seed service.
enum CreditProfileStatus {
  unspecified(0, 'Unknown'),
  active(1, 'Active'),
  suspended(2, 'Suspended'),
  blocked(3, 'Blocked');

  const CreditProfileStatus(this.code, this.label);
  final int code;
  final String label;

  static CreditProfileStatus fromCode(int code) => values.firstWhere(
    (s) => s.code == code,
    orElse: () => CreditProfileStatus.unspecified,
  );
}

/// What staff may do to a credit profile; each needs a reason.
enum CreditProfileAction { suspend, block, reinstate }

/// Raised when the seed service refuses or fails a call.
class SeedApiException implements Exception {
  const SeedApiException(this.status, this.message);
  final int status;
  final String message;

  bool get notFound => status == 404;

  @override
  String toString() => message;
}

/// The seed service's credit-profile endpoints.
class SeedApi {
  SeedApi(this._client, this._tokens, this._baseUrl);

  final http.Client _client;
  final AuthTokenProvider _tokens;
  final String _baseUrl;

  Future<Map<String, String>> _headers() async {
    final token = await _tokens.ensureValidAccessToken();
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  /// The client's profile, or null when they have none yet (they get one
  /// on their first request).
  Future<CreditProfile?> creditProfile(String clientId, String currency) async {
    final resp = await _client.get(
      Uri.parse('$_baseUrl/api/v1/seed/credit-profiles/$clientId/$currency'),
      headers: await _headers(),
    );
    if (resp.statusCode == 404) return null;
    return CreditProfile.fromJson(_decode(resp));
  }

  Future<CreditProfile> setStatus(
    String clientId,
    String currency,
    CreditProfileAction action,
    String reason,
  ) async {
    final resp = await _client.post(
      Uri.parse(
        '$_baseUrl/api/v1/seed/credit-profiles/$clientId/$currency/${action.name}',
      ),
      headers: await _headers(),
      body: jsonEncode({'reason': reason}),
    );
    return CreditProfile.fromJson(_decode(resp));
  }

  /// Sets a temporary cap below the tier limit until [expiresAt].
  Future<CreditProfile> setCap(
    String clientId,
    String currency, {
    required int amountMinor,
    required DateTime expiresAt,
    required String reason,
  }) async {
    final resp = await _client.post(
      Uri.parse(
        '$_baseUrl/api/v1/seed/credit-profiles/$clientId/$currency/cap',
      ),
      headers: await _headers(),
      body: jsonEncode({
        'amount': amountMinor,
        'expires_at': expiresAt.toUtc().toIso8601String(),
        'reason': reason,
      }),
    );
    return CreditProfile.fromJson(_decode(resp));
  }

  /// Lifts a temporary cap before it lapses.
  Future<CreditProfile> clearCap(
    String clientId,
    String currency,
    String reason,
  ) async {
    final resp = await _client.post(
      Uri.parse(
        '$_baseUrl/api/v1/seed/credit-profiles/$clientId/$currency/cap/clear',
      ),
      headers: await _headers(),
      body: jsonEncode({'reason': reason}),
    );
    return CreditProfile.fromJson(_decode(resp));
  }

  Map<String, dynamic> _decode(http.Response resp) {
    Map<String, dynamic> body;
    try {
      body = jsonDecode(resp.body) as Map<String, dynamic>;
    } on FormatException {
      body = const {};
    }
    if (resp.statusCode >= 400) {
      throw SeedApiException(
        resp.statusCode,
        body['error'] as String? ?? 'Seed service error ${resp.statusCode}',
      );
    }
    return body;
  }
}

final seedApiProvider = Provider<SeedApi>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return SeedApi(
    client,
    ref.watch(authTokenProviderProvider),
    AppConfig.seedBaseUrl,
  );
});

/// The currency seed lends in for this deployment.
const seedCurrency = String.fromEnvironment(
  'SEED_CURRENCY',
  defaultValue: 'KES',
);

final creditProfileProvider = FutureProvider.family<CreditProfile?, String>(
  (ref, clientId) =>
      ref.watch(seedApiProvider).creditProfile(clientId, seedCurrency),
);
