import 'package:antinvestor_api_loans/antinvestor_api_loans.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'loans_transport_provider.dart';

final repaymentScheduleDetailProvider =
    FutureProvider.family<RepaymentScheduleObject, String>((
      ref,
      loanAccountId,
    ) async {
      final client = ref.watch(loanManagementServiceClientProvider);
      final response = await client.repaymentScheduleGet(
        RepaymentScheduleGetRequest(loanAccountId: loanAccountId),
      );
      return response.data;
    });
