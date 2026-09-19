import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/exceptions/failure.dart';
import '../../../../core/widgets/common_empty_state.dart';

/// Loading / error-with-retry / empty / list states for gym tabs.
class AsyncList<T> extends StatelessWidget {
  const AsyncList({
    required this.value,
    required this.itemBuilder,
    required this.emptyTitle,
    required this.emptyMessage,
    required this.onRetry,
    this.header,
    super.key,
  });

  final AsyncValue<List<T>> value;
  final Widget Function(BuildContext, T) itemBuilder;
  final String emptyTitle;
  final String emptyMessage;
  final VoidCallback onRetry;
  final Widget? header;

  @override
  Widget build(BuildContext context) {
    return value.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (e, _) => CommonEmptyState(
            icon: Icons.cloud_off,
            title: 'Não foi possível carregar',
            message: e is Failure ? e.message : '$e',
            actionLabel: 'Tentar novamente',
            onAction: onRetry,
          ),
      data:
          (items) => RefreshIndicator(
            onRefresh: () async => onRetry(),
            child: ListView.separated(
              padding: const EdgeInsets.only(bottom: 24),
              itemCount: items.length + 1,
              separatorBuilder:
                  (_, i) =>
                      i == 0
                          ? const SizedBox.shrink()
                          : const Divider(height: 1),
              itemBuilder: (context, i) {
                if (i > 0) return itemBuilder(context, items[i - 1]);
                return Column(
                  children: [
                    if (header != null) header!,
                    if (items.isEmpty)
                      CommonEmptyState(
                        title: emptyTitle,
                        message: emptyMessage,
                      ),
                  ],
                );
              },
            ),
          ),
    );
  }
}
