import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../models/app_models.dart';
import '../../../../providers/app_providers.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../application/address_book_actions.dart';
import 'address_form_screen.dart';
import 'widgets/address_book_card.dart';

class AddressBookScreen extends ConsumerWidget {
  const AddressBookScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addresses = ref.watch(customerAddressesProvider);
    return AppPage(
      maxWidth: 900,
      title: 'Sổ địa chỉ',
      subtitle: '${addresses.length} địa chỉ đã lưu',
      appBarBackgroundColor: AppColors.surface,
      appBarTitleColor: AppColors.text,
      appBarSubtitleColor: AppColors.textMuted,
      scaffoldBackgroundColor: AppColors.screenBackground,
      actions: [
        IconButton(
          tooltip: 'Thêm địa chỉ',
          onPressed: () => _openForm(context),
          icon: const Icon(Icons.add_location_alt_outlined),
        ),
        const SizedBox(width: AppSpacing.sm),
      ],
      child: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding = constraints.maxWidth >= 720
              ? AppSpacing.xl
              : AppSpacing.screenHorizontal;
          final list = ListView(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              AppSpacing.xl,
              horizontalPadding,
              AppSpacing.xxxl,
            ),
            children: [
              SectionHeader(
                title: 'Điểm thu gom của bạn',
                subtitle: addresses.isEmpty
                    ? 'Thêm địa chỉ đầu tiên để bắt đầu đặt lịch'
                    : 'Địa chỉ mặc định luôn được chọn trước khi đặt lịch',
              ),
              const SizedBox(height: AppSpacing.lg),
              if (addresses.isEmpty) ...[
                const EmptyState(
                  icon: Icons.add_location_alt_outlined,
                  title: 'Chưa có địa chỉ',
                  message:
                      'Lưu địa chỉ nhà hoặc nơi làm việc để tạo đơn thu gom.',
                ),
                const SizedBox(height: AppSpacing.lg),
                PrimaryActionButton(
                  label: 'Thêm địa chỉ đầu tiên',
                  icon: Icons.add_rounded,
                  onPressed: () => _openForm(context),
                ),
              ] else ...[
                for (final address in addresses)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: AddressBookCard(
                      address: address,
                      onEdit: () => _openForm(context, address: address),
                      onDelete: () => _confirmDelete(context, ref, address),
                      onSetDefault: () => _setDefault(context, ref, address),
                    ),
                  ),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton.icon(
                  onPressed: () => _openForm(context),
                  icon: const Icon(Icons.add_location_alt_outlined),
                  label: const Text('Thêm địa chỉ khác'),
                ),
              ],
            ],
          );
          return kIsWeb ? Scrollbar(child: list) : list;
        },
      ),
    );
  }

  Future<void> _openForm(
    BuildContext context, {
    CustomerAddress? address,
  }) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AddressFormScreen(address: address)),
    );
  }

  Future<void> _setDefault(
    BuildContext context,
    WidgetRef ref,
    CustomerAddress address,
  ) async {
    try {
      await ref.read(addressBookActionsProvider).setDefault(address.diaChiId);
      if (context.mounted) _showMessage(context, 'Đã đổi địa chỉ mặc định.');
    } catch (error) {
      if (context.mounted) _showMessage(context, _messageFor(error));
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    CustomerAddress address,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xóa địa chỉ?'),
        content: Text(
          address.macDinh
              ? 'Địa chỉ này đang là mặc định. Nếu còn địa chỉ khác, hệ thống sẽ tự chọn địa chỉ mặc định mới.'
              : 'Địa chỉ này sẽ bị xóa khỏi sổ địa chỉ.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Giữ lại'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(addressBookActionsProvider).delete(address.diaChiId);
      if (context.mounted) _showMessage(context, 'Đã xóa địa chỉ.');
    } catch (error) {
      if (context.mounted) _showMessage(context, _messageFor(error));
    }
  }

  String _messageFor(Object error) {
    if (error is FirebaseException) {
      return switch (error.code) {
        'permission-denied' =>
          'Firestore chưa cho phép thay đổi địa chỉ của tài khoản này.',
        'unavailable' => 'Không kết nối được Firestore. Vui lòng thử lại.',
        _ => error.message ?? 'Không thể cập nhật địa chỉ (${error.code}).',
      };
    }
    return error.toString().replaceFirst('Bad state: ', '');
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
