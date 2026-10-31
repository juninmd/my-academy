import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_provider.dart';
import '../../data/repositories/data_transfer_repository_impl.dart';
import '../../domain/repositories/data_transfer_repository.dart';

// Written by hand, like the other providers, so build_runner is not needed.
final dataTransferRepositoryProvider = Provider<DataTransferRepository>((ref) {
  return DataTransferRepositoryImpl(ref.watch(apiClientProvider));
});
