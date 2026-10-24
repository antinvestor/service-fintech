import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The caller's own agent id in the loans service, when the host app knows
/// it. A loan's `agent_id` is the workforce member id of the agent who
/// originated it, so a host that can resolve the signed-in user's workforce
/// member id overrides this to let agents filter the book down to their own
/// portfolio. The default of null leaves the "My portfolio" toggle disabled.
final currentAgentIdProvider = Provider<String?>((ref) => null);
