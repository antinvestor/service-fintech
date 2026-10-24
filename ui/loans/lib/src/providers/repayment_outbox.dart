import 'dart:convert';

import 'package:antinvestor_api_loans/antinvestor_api_loans.dart';
import 'package:antinvestor_ui_core/widgets/money_helpers.dart';
import 'package:connectrpc/connect.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'loans_transport_provider.dart';

/// A repayment recorded while the service could not be reached. It keeps
/// the idempotency key it was first submitted with, so however many times
/// it is replayed the loans service records it once.
class PendingRepayment {
  const PendingRepayment({
    required this.loanAccountId,
    required this.amount,
    required this.currencyCode,
    required this.paymentReference,
    required this.channel,
    required this.payerReference,
    required this.idempotencyKey,
    required this.queuedAt,
    this.rejection = '',
  });

  factory PendingRepayment.fromJson(Map<String, dynamic> json) =>
      PendingRepayment(
        loanAccountId: json['loan_account_id'] as String,
        amount: json['amount'] as String,
        currencyCode: json['currency_code'] as String,
        paymentReference: json['payment_reference'] as String? ?? '',
        channel: json['channel'] as String,
        payerReference: json['payer_reference'] as String? ?? '',
        idempotencyKey: json['idempotency_key'] as String,
        queuedAt: DateTime.parse(json['queued_at'] as String),
        rejection: json['rejection'] as String? ?? '',
      );

  final String loanAccountId;
  final String amount;
  final String currencyCode;
  final String paymentReference;
  final String channel;
  final String payerReference;
  final String idempotencyKey;
  final DateTime queuedAt;

  /// Why the service refused it on replay; empty while it is still pending.
  final String rejection;

  bool get rejected => rejection.isNotEmpty;

  PendingRepayment rejectedWith(String reason) => PendingRepayment(
    loanAccountId: loanAccountId,
    amount: amount,
    currencyCode: currencyCode,
    paymentReference: paymentReference,
    channel: channel,
    payerReference: payerReference,
    idempotencyKey: idempotencyKey,
    queuedAt: queuedAt,
    rejection: reason,
  );

  RepaymentRecordRequest toRequest() {
    final req = RepaymentRecordRequest(
      loanAccountId: loanAccountId,
      paymentReference: paymentReference,
      channel: channel,
      payerReference: payerReference,
      idempotencyKey: idempotencyKey,
    );
    setMoneyFields(req.ensureAmount(), amount, currencyCode);
    return req;
  }

  Map<String, dynamic> toJson() => {
    'loan_account_id': loanAccountId,
    'amount': amount,
    'currency_code': currencyCode,
    'payment_reference': paymentReference,
    'channel': channel,
    'payer_reference': payerReference,
    'idempotency_key': idempotencyKey,
    'queued_at': queuedAt.toUtc().toIso8601String(),
    'rejection': rejection,
  };
}

/// Where the outbox is kept. The default lives in memory; a host app
/// overrides [outboxStoreProvider] with persistent storage so queued
/// repayments survive a restart.
abstract class OutboxStore {
  Future<String?> read();
  Future<void> write(String value);
}

class InMemoryOutboxStore implements OutboxStore {
  String? _value;

  @override
  Future<String?> read() async => _value;

  @override
  Future<void> write(String value) async => _value = value;
}

final outboxStoreProvider = Provider<OutboxStore>(
  (ref) => InMemoryOutboxStore(),
);

/// Whether [error] means the request may not have been heard: the network,
/// a timeout or an unavailable service. Only those are queued; a refusal
/// is shown to the agent at once.
bool isTransientFailure(Object error) {
  if (error is ConnectException) {
    return switch (error.code) {
      Code.unavailable ||
      Code.deadlineExceeded ||
      Code.unknown ||
      Code.aborted ||
      Code.canceled => true,
      _ => false,
    };
  }
  // Socket and HTTP client failures never reached the service.
  return true;
}

/// Repayments waiting to reach the loans service.
class RepaymentOutbox extends AsyncNotifier<List<PendingRepayment>> {
  @override
  Future<List<PendingRepayment>> build() async {
    final raw = await ref.read(outboxStoreProvider).read();
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return [
      for (final item in decoded)
        PendingRepayment.fromJson(item as Map<String, dynamic>),
    ];
  }

  Future<void> _store(List<PendingRepayment> items) async {
    await ref
        .read(outboxStoreProvider)
        .write(jsonEncode([for (final i in items) i.toJson()]));
    state = AsyncData(items);
  }

  /// Queues [item]; a second enqueue of the same key is ignored.
  Future<void> enqueue(PendingRepayment item) async {
    final items = [...await future];
    if (items.any((i) => i.idempotencyKey == item.idempotencyKey)) return;
    await _store([...items, item]);
  }

  /// Replays every pending repayment. Accepted ones leave the outbox,
  /// refused ones stay marked with the reason, and the rest wait for the
  /// next attempt. Returns how many were accepted.
  Future<int> flush() async {
    final client = ref.read(loanManagementServiceClientProvider);
    final remaining = <PendingRepayment>[];
    var accepted = 0;
    for (final item in await future) {
      if (item.rejected) {
        remaining.add(item);
        continue;
      }
      try {
        await client.repaymentRecord(item.toRequest());
        accepted++;
      } catch (e) {
        remaining.add(
          isTransientFailure(e)
              ? item
              : item.rejectedWith(e is ConnectException ? e.message : '$e'),
        );
      }
    }
    await _store(remaining);
    return accepted;
  }

  /// Drops a refused repayment once the agent has dealt with it.
  Future<void> dismiss(String idempotencyKey) async {
    await _store([
      for (final i in await future)
        if (i.idempotencyKey != idempotencyKey) i,
    ]);
  }
}

final repaymentOutboxProvider =
    AsyncNotifierProvider<RepaymentOutbox, List<PendingRepayment>>(
      RepaymentOutbox.new,
    );
