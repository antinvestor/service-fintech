import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The caller's own agent id in the loans service, when the host app knows
/// it. A loan's `agent_id` is the workforce member id of the agent who
/// originated it, so a host that can resolve the signed-in user's workforce
/// member id overrides this to let agents filter the book down to their own
/// portfolio. The default of null leaves the "My portfolio" toggle disabled.
final currentAgentIdProvider = Provider<String?>((ref) => null);

/// The signed-in user's profile id, when the host app knows it. The loans
/// service refuses a credit decision by whoever submitted the request, so
/// with this set the decision screen says so instead of offering buttons
/// that would be refused. The default of null hides nothing.
final currentProfileIdProvider = Provider<String?>((ref) => null);
