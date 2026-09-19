import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';

import '../../../../core/exceptions/failure.dart';

/// Runs a mutation and reports the outcome; returns true on success.
Future<bool> runGymAction<T>(
  BuildContext context,
  Future<Either<Failure, T>> action, {
  required String success,
  VoidCallback? onSuccess,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  final result = await action;
  return result.fold(
    (failure) {
      messenger.showSnackBar(SnackBar(content: Text(failure.message)));
      return false;
    },
    (_) {
      onSuccess?.call();
      messenger.showSnackBar(SnackBar(content: Text(success)));
      return true;
    },
  );
}
