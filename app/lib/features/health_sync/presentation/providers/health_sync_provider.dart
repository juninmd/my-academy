import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../health_sync_service.dart';

final healthSyncServiceProvider = Provider<HealthSyncService>((ref) {
  return HealthSyncService();
});
