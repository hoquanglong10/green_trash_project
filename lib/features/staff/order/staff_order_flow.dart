import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../evidence/application/evidence_providers.dart';
import '../../orders/application/order_workflow_providers.dart';
import '../../orders/domain/order_workflow_models.dart';
import '../../../models/app_models.dart';
import '../../../providers/app_providers.dart';
import '../../../shared/widgets/order_reason_sheet.dart';
import '../domain/staff_availability.dart';
import 'widgets/arrival_time_sheet.dart';
import 'widgets/collection_confirmation_sheet.dart';

Future<bool> acceptStaffOrder(
  BuildContext context,
  WidgetRef ref, {
  required PickupOrder order,
  required String staffId,
}) async {
  final profile = _findStaffProfile(ref, staffId);
  if (profile != null && !isStaffAvailable(profile.trangThaiLamViec)) {
    if (context.mounted) {
      _showMessage(
        context,
        'Hãy bật "Vị trí nhận đơn" trước khi nhận đơn mới.',
      );
    }
    return false;
  }

  final arrival = await showArrivalTimeSheet(context, order: order);
  if (arrival == null) return false;
  if (!context.mounted) return false;

  final firebaseEnabled = ref.read(firebaseEnabledProvider);
  final accepted = firebaseEnabled
      ? await _claimFirestoreOrder(
          context,
          ref,
          order: order,
          staffId: staffId,
          arrival: arrival,
        )
      : _acceptMockOrder(ref, order: order, staffId: staffId, arrival: arrival);
  if (context.mounted && !accepted && !firebaseEnabled) {
    _showMessage(context, 'Đơn đã thay đổi. Vui lòng tải lại danh sách.');
  }
  return accepted;
}

Future<bool> rejectStaffOffer(
  BuildContext context,
  WidgetRef ref, {
  required PickupOrder order,
  required String staffId,
}) async {
  final reason = await showOrderReasonSheet(
    context,
    title: 'Bỏ qua đơn ${order.maDon}',
    subtitle:
        'Đơn sẽ được ẩn khỏi danh sách của bạn và vẫn hiện cho nhân viên khác.',
    confirmLabel: 'Xác nhận bỏ qua',
    suggestions: const [
      'Không kịp khung giờ',
      'Ngoài khu vực phụ trách',
      'Phương tiện đang đầy',
    ],
  );
  if (reason == null) return false;
  if (!context.mounted) return false;
  final rejected = ref.read(firebaseEnabledProvider)
      ? await _dismissFirestoreOrder(
          context,
          ref,
          order: order,
          staffId: staffId,
          reason: reason,
        )
      : ref
            .read(orderControllerProvider.notifier)
            .rejectOffer(
              maDon: order.maDon,
              nhanVienId: staffId,
              reason: reason,
            );
  if (context.mounted) {
    _showMessage(
      context,
      rejected
          ? 'Đã ẩn đơn khỏi danh sách của bạn.'
          : 'Không thể bỏ qua vì đơn đã thay đổi.',
    );
  }
  return rejected;
}

Future<bool> cancelStaffOrder(
  BuildContext context,
  WidgetRef ref, {
  required PickupOrder order,
  required String staffId,
}) async {
  final reason = await showOrderReasonSheet(
    context,
    title: 'Hủy công việc ${order.maDon}',
    subtitle: 'Lý do sẽ được lưu vào lịch sử và gửi cho khách hàng.',
    confirmLabel: 'Xác nhận hủy',
    suggestions: const [
      'Rác không đúng quy định',
      'Không liên hệ được khách',
      'Không thể tiếp tục thu gom',
    ],
  );
  if (reason == null) return false;
  if (!context.mounted) return false;
  final canceled = ref.read(firebaseEnabledProvider)
      ? await _runFirestoreAction(
          context,
          () => ref
              .read(orderWorkflowRepositoryProvider)
              .cancelOrder(
                CancelPickupOrderCommand(
                  maDon: order.maDon,
                  actorId: staffId,
                  lyDo: reason,
                ),
              ),
        )
      : ref
            .read(orderControllerProvider.notifier)
            .cancelOrder(maDon: order.maDon, actorId: staffId, reason: reason);
  if (context.mounted) {
    _showMessage(
      context,
      canceled
          ? 'Đã hủy đơn và lưu lý do.'
          : 'Không thể hủy đơn ở trạng thái này.',
    );
  }
  return canceled;
}

Future<bool> changeStaffArrivalTime(
  BuildContext context,
  WidgetRef ref, {
  required PickupOrder order,
  required String staffId,
}) async {
  final arrival = await showArrivalTimeSheet(context, order: order);
  if (arrival == null) return false;
  if (!context.mounted) return false;
  final updated = ref.read(firebaseEnabledProvider)
      ? await _runFirestoreAction(
          context,
          () => ref
              .read(orderWorkflowRepositoryProvider)
              .updateArrivalTime(
                UpdateArrivalTimeCommand(
                  maDon: order.maDon,
                  nhanVienId: staffId,
                  gioChot: arrival,
                ),
              ),
        )
      : ref
            .read(orderControllerProvider.notifier)
            .updateArrivalTime(
              maDon: order.maDon,
              nhanVienId: staffId,
              gioChot: arrival,
            );
  if (context.mounted) {
    _showMessage(
      context,
      updated
          ? 'Đã cập nhật giờ đến cho khách hàng.'
          : 'Không thể đổi giờ đến ở trạng thái hiện tại.',
    );
  }
  return updated;
}

Future<bool> advanceStaffOrder(
  BuildContext context,
  WidgetRef ref, {
  required PickupOrder order,
  required String staffId,
  required String nextStatus,
}) async {
  final updated = ref.read(firebaseEnabledProvider)
      ? await _runFirestoreAction(
          context,
          () => ref
              .read(orderWorkflowRepositoryProvider)
              .transitionOrder(
                TransitionPickupOrderCommand(
                  maDon: order.maDon,
                  nhanVienId: staffId,
                  trangThaiMoi: nextStatus,
                ),
              ),
        )
      : ref
            .read(orderControllerProvider.notifier)
            .updateStatus(
              maDon: order.maDon,
              nhanVienId: staffId,
              status: nextStatus,
            );
  if (!context.mounted) return false;
  if (!updated) {
    _showMessage(context, 'Không thể bỏ qua thứ tự xử lý của đơn.');
  }
  return updated;
}

Future<bool> completeStaffOrder(
  BuildContext context,
  WidgetRef ref, {
  required PickupOrder order,
  required String staffId,
}) async {
  final firebaseEnabled = ref.read(firebaseEnabledProvider);
  final draft = await showCollectionConfirmationSheet(
    context,
    order: order,
    staffId: staffId,
    wasteTypes: ref.read(wasteTypesProvider),
    prices: ref.read(pricesProvider),
    subscriptions: ref.read(subscriptionsProvider),
    packages: ref.read(packagesProvider),
    requiresCameraEvidence: firebaseEnabled,
    captureEvidence: firebaseEnabled
        ? ref.read(cameraEvidencePickerProvider).capture
        : null,
  );
  if (draft == null) return false;
  if (!context.mounted) return false;

  var completion = draft.completion;
  if (firebaseEnabled) {
    final evidenceBytes = draft.evidenceBytes;
    if (evidenceBytes == null || evidenceBytes.isEmpty) {
      _showMessage(context, 'Vui lòng chụp ảnh xác nhận trước khi hoàn thành.');
      return false;
    }
    if (evidenceBytes.lengthInBytes > 650 * 1024) {
      _showMessage(
        context,
        'Ảnh còn quá lớn. Hãy chụp lại ở khoảng cách gần hơn.',
      );
      return false;
    }
    completion = CollectionCompletion(
      record: completion.record.copyWith(anhXacNhanBytes: evidenceBytes),
      payment: completion.payment,
    );
  }
  if (!context.mounted) return false;

  final completed = firebaseEnabled
      ? await _runFirestoreAction(
          context,
          () => ref
              .read(orderWorkflowRepositoryProvider)
              .completeOrder(
                CompletePickupOrderCommand(
                  maDon: order.maDon,
                  nhanVienId: staffId,
                  record: completion.record,
                  payment: completion.payment,
                ),
              ),
        )
      : ref
            .read(orderControllerProvider.notifier)
            .completeOrder(
              maDon: order.maDon,
              nhanVienId: staffId,
              record: completion.record,
              payment: completion.payment,
            );
  if (!context.mounted) return completed;
  if (!completed) {
    _showMessage(
      context,
      'Không thể hoàn thành vì trạng thái đơn đã thay đổi.',
    );
    return false;
  }
  await _showCompletionSuccess(context, completion.record);
  return true;
}

bool _acceptMockOrder(
  WidgetRef ref, {
  required PickupOrder order,
  required String staffId,
  required DateTime arrival,
}) {
  final controller = ref.read(orderControllerProvider.notifier);
  return order.trangThai == 'CHO_NHAN'
      ? controller.acceptOrder(
          maDon: order.maDon,
          nhanVienId: staffId,
          gioChot: arrival,
        )
      : controller.acceptOffer(
          maDon: order.maDon,
          nhanVienId: staffId,
          gioChot: arrival,
        );
}

Future<bool> _claimFirestoreOrder(
  BuildContext context,
  WidgetRef ref, {
  required PickupOrder order,
  required String staffId,
  required DateTime arrival,
}) {
  final repository = ref.read(orderWorkflowRepositoryProvider);
  if (order.trangThai == 'CHO_XU_LY') {
    return _runFirestoreAction(
      context,
      () => repository.claimOpenOrder(
        ClaimOpenPickupOrderCommand(
          maDon: order.maDon,
          nhanVienId: staffId,
          gioChot: arrival,
        ),
      ),
    );
  }
  if (order.trangThai == 'CHO_NHAN' && order.phanCongHienTaiId != null) {
    return _runFirestoreAction(
      context,
      () => repository.acceptOffer(
        AcceptPickupOfferCommand(
          phanCongId: order.phanCongHienTaiId!,
          nhanVienId: staffId,
          gioChot: arrival,
        ),
      ),
    );
  }
  return Future<bool>.value(false);
}

Future<bool> _dismissFirestoreOrder(
  BuildContext context,
  WidgetRef ref, {
  required PickupOrder order,
  required String staffId,
  required String reason,
}) {
  final repository = ref.read(orderWorkflowRepositoryProvider);
  if (order.trangThai == 'CHO_XU_LY') {
    return _runFirestoreAction(
      context,
      () => repository.dismissOpenOrder(
        DismissOpenPickupOrderCommand(
          maDon: order.maDon,
          nhanVienId: staffId,
          lyDo: reason,
        ),
      ),
    );
  }
  if (order.trangThai == 'CHO_NHAN' && order.phanCongHienTaiId != null) {
    return _runFirestoreAction(
      context,
      () => repository.rejectOffer(
        RejectPickupOfferCommand(
          phanCongId: order.phanCongHienTaiId!,
          nhanVienId: staffId,
          lyDo: reason,
        ),
      ),
    );
  }
  return Future<bool>.value(false);
}

Future<bool> _runFirestoreAction(
  BuildContext context,
  Future<void> Function() action,
) async {
  try {
    await action();
    return true;
  } on OrderWorkflowException catch (error) {
    if (context.mounted) _showMessage(context, error.message);
    return false;
  } on FirebaseException catch (error) {
    if (context.mounted) {
      _showMessage(context, _firebaseActionMessage(error.code));
    }
    return false;
  } catch (_) {
    if (context.mounted) {
      _showMessage(context, 'Không thể cập nhật dữ liệu. Vui lòng thử lại.');
    }
    return false;
  }
}

StaffProfile? _findStaffProfile(WidgetRef ref, String staffId) {
  for (final profile in ref.read(staffProfilesProvider)) {
    if (profile.nhanVienId == staffId) return profile;
  }
  return null;
}

String _firebaseActionMessage(String code) {
  return switch (code) {
    'permission-denied' =>
      'Firestore từ chối thao tác. Kiểm tra trạng thái nhận đơn và quyền nhân viên.',
    'aborted' =>
      'Đơn vừa được cập nhật ở thiết bị khác. Vui lòng tải lại danh sách.',
    'unavailable' => 'Mất kết nối Firestore. Vui lòng thử lại.',
    _ => 'Không thể cập nhật dữ liệu Firestore ($code).',
  };
}

Future<void> _showCompletionSuccess(
  BuildContext context,
  CollectionRecord record,
) {
  return showDialog<void>(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 420),
                tween: Tween(begin: 0.5, end: 1),
                curve: Curves.easeOutBack,
                builder: (context, value, child) =>
                    Transform.scale(scale: value, child: child),
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.verified,
                    color: AppColors.primary,
                    size: 36,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Thu gom thành công',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Đã lưu ${formatKg(record.khoiLuongThucTe)} vào biên bản ${record.bienBanId}. Khách hàng đã nhận cập nhật.',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Đóng'),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

void _showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
