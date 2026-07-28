import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_models.dart';

typedef ActivityLogWriter = void Function(ActivityLog log);
typedef NotificationWriter = void Function(AppNotification notification);
typedef CollectionRecordWriter = void Function(CollectionRecord record);
typedef PaymentRecordWriter = void Function(PaymentRecord payment);
typedef SubscriptionUsageWriter =
    void Function({required String customerId, required double kg});
typedef StaffProfilesReader = List<StaffProfile> Function();
typedef StaffStatusWriter = void Function(String staffId, String status);

enum OrderDispatchMode { targetedOffer, openQueue }

class OrderController extends StateNotifier<List<PickupOrder>> {
  OrderController({
    required List<PickupOrder> initialOrders,
    required List<StaffProfile> staff,
    required List<CustomerAddress> addresses,
    required ActivityLogWriter addActivityLog,
    required NotificationWriter addNotification,
    required CollectionRecordWriter saveCollectionRecord,
    PaymentRecordWriter? savePaymentRecord,
    SubscriptionUsageWriter? consumeSubscription,
    StaffProfilesReader? readStaffProfiles,
    StaffStatusWriter? updateStaffStatus,
    this.dispatchMode = OrderDispatchMode.targetedOffer,
  }) : _fallbackStaff = staff,
       _addresses = addresses,
       _addActivityLog = addActivityLog,
       _addNotification = addNotification,
       _saveCollectionRecord = saveCollectionRecord,
       _savePaymentRecord = savePaymentRecord,
       _consumeSubscription = consumeSubscription,
       _readStaffProfiles = readStaffProfiles,
       _updateStaffStatus = updateStaffStatus,
       super(_prepareInitialOrders(initialOrders, dispatchMode));

  static const offerValidity = Duration(minutes: 2);

  static const _allowedTransitions = <String, String>{
    'DA_NHAN': 'DANG_DEN',
    'DANG_DEN': 'DA_DEN',
    'DA_DEN': 'DANG_CAN_RAC',
  };

  static const _customerCancelableStatuses = <String>{
    'CHO_XU_LY',
    'CHO_NHAN',
    'DA_NHAN',
    'DANG_DEN',
  };

  static const _busyStatuses = <String>{'DANG_DEN', 'DA_DEN', 'DANG_CAN_RAC'};

  final List<StaffProfile> _fallbackStaff;
  final List<CustomerAddress> _addresses;
  final ActivityLogWriter _addActivityLog;
  final NotificationWriter _addNotification;
  final CollectionRecordWriter _saveCollectionRecord;
  final PaymentRecordWriter? _savePaymentRecord;
  final SubscriptionUsageWriter? _consumeSubscription;
  final StaffProfilesReader? _readStaffProfiles;
  final StaffStatusWriter? _updateStaffStatus;
  final OrderDispatchMode dispatchMode;
  int _eventSequence = 0;

  PickupOrder createOrder({
    required String khachHangId,
    required String diaChiId,
    required String loaiRacId,
    required double khoiLuongDuKien,
    required DateTime ngayThuGom,
    required String khungGio,
    required String hinhThucTinhPhi,
    required String ghiChu,
  }) {
    final suggestedStaffId = dispatchMode == OrderDispatchMode.openQueue
        ? null
        : _nextStaff(
            diaChiId: diaChiId,
            pickupDate: ngayThuGom,
            timeSlot: khungGio,
            rejectedStaffIds: const [],
          );
    final now = DateTime.now();
    final order = PickupOrder(
      maDon: _nextOrderId(),
      khachHangId: khachHangId,
      diaChiId: diaChiId,
      loaiRacId: loaiRacId,
      nhanVienDeXuatId: suggestedStaffId,
      offerExpiresAt: suggestedStaffId == null ? null : now.add(offerValidity),
      offerAttempt: suggestedStaffId == null ? 0 : 1,
      waitingForSupport:
          dispatchMode == OrderDispatchMode.targetedOffer &&
          suggestedStaffId == null,
      khoiLuongDuKien: khoiLuongDuKien,
      ngayThuGom: ngayThuGom,
      khungGio: khungGio,
      hinhThucTinhPhi: hinhThucTinhPhi,
      trangThai: 'CHO_XU_LY',
      ghiChu: ghiChu,
      ngayTao: now,
    );

    state = [order, ...state];
    _log(
      order: order,
      actorId: khachHangId,
      action: 'Tạo đơn thu gom',
      note: 'Khách hàng đã gửi yêu cầu thu gom.',
      time: now,
    );
    if (dispatchMode == OrderDispatchMode.openQueue) {
      for (final profile in _staffProfiles) {
        if (profile.trangThaiLamViec != 'SAN_SANG') continue;
        _notify(
          recipientId: profile.nhanVienId,
          order: order,
          title: 'Có đơn mới đang chờ nhận',
          content: '${order.maDon} cần thu gom trong khung ${order.khungGio}.',
          time: now,
        );
      }
    } else if (suggestedStaffId != null) {
      _notifyOffer(order, suggestedStaffId, time: now);
    } else {
      _notify(
        recipientId: khachHangId,
        order: order,
        title: 'Đơn đang chờ hỗ trợ',
        content:
            'Hiện chưa có nhân viên phù hợp. GreenTrash đã đưa đơn vào hàng chờ hỗ trợ.',
        time: now,
      );
    }
    return order;
  }

  void assignStaff({required String maDon, required String nhanVienId}) {
    final order = _findOrder(maDon);
    if (order == null || order.trangThai != 'CHO_XU_LY') return;

    final updated = order.copyWith(
      nhanVienHienTaiId: nhanVienId,
      clearNhanVienDeXuatId: true,
      clearOfferExpiresAt: true,
      waitingForSupport: false,
      trangThai: 'CHO_NHAN',
    );
    _replace(updated);
    _notify(
      recipientId: nhanVienId,
      order: updated,
      title: 'Đơn cần xác nhận',
      content: '${order.maDon} đã được chuyển cho bạn xử lý.',
    );
  }

  bool acceptOrder({
    required String maDon,
    required String nhanVienId,
    required DateTime gioChot,
  }) {
    final order = _findOrder(maDon);
    if (order == null ||
        order.trangThai != 'CHO_NHAN' ||
        order.nhanVienHienTaiId != nhanVienId ||
        !_canStaffTakeOrder(order, nhanVienId) ||
        !_isArrivalInsideSlot(order, gioChot)) {
      return false;
    }
    return _accept(order: order, staffId: nhanVienId, arrival: gioChot);
  }

  bool acceptOffer({
    required String maDon,
    required String nhanVienId,
    required DateTime gioChot,
  }) {
    final order = _findOrder(maDon);
    if (order == null || order.trangThai != 'CHO_XU_LY') {
      return false;
    }
    if (dispatchMode == OrderDispatchMode.openQueue) {
      if (order.nhanVienTuChoiIds.contains(nhanVienId) ||
          !_canStaffTakeOrder(order, nhanVienId) ||
          !_isArrivalInsideSlot(order, gioChot)) {
        return false;
      }
    } else if (order.nhanVienDeXuatId != nhanVienId ||
        _isOfferExpired(order, DateTime.now()) ||
        !_canStaffTakeOrder(order, nhanVienId) ||
        !_isArrivalInsideSlot(order, gioChot)) {
      return false;
    }
    return _accept(order: order, staffId: nhanVienId, arrival: gioChot);
  }

  bool rejectOffer({
    required String maDon,
    required String nhanVienId,
    required String reason,
  }) {
    final order = _findOrder(maDon);
    final normalizedReason = reason.trim();
    if (order == null ||
        normalizedReason.isEmpty ||
        order.trangThai != 'CHO_XU_LY') {
      return false;
    }

    if (dispatchMode == OrderDispatchMode.openQueue) {
      if (order.nhanVienTuChoiIds.contains(nhanVienId)) return false;
      final updated = order.copyWith(
        nhanVienTuChoiIds: [...order.nhanVienTuChoiIds, nhanVienId],
      );
      _replace(updated);
      _log(
        order: updated,
        actorId: nhanVienId,
        action: 'Bỏ qua đơn',
        note: normalizedReason,
      );
      return true;
    }

    if (order.nhanVienDeXuatId != nhanVienId) return false;
    _log(
      order: order,
      actorId: nhanVienId,
      action: 'Từ chối đơn',
      note: normalizedReason,
    );
    _forwardOffer(order, currentStaffId: nhanVienId);
    return true;
  }

  bool expireOffer({
    required String maDon,
    required String nhanVienId,
    DateTime? now,
  }) {
    if (dispatchMode == OrderDispatchMode.openQueue) return false;
    final order = _findOrder(maDon);
    final currentTime = now ?? DateTime.now();
    if (order == null ||
        order.trangThai != 'CHO_XU_LY' ||
        order.nhanVienDeXuatId != nhanVienId ||
        !_isOfferExpired(order, currentTime)) {
      return false;
    }

    _log(
      order: order,
      actorId: nhanVienId,
      action: 'Offer đã hết hạn',
      note: 'Nhân viên không phản hồi trong thời gian quy định.',
      time: currentTime,
    );
    _forwardOffer(order, currentStaffId: nhanVienId, eventTime: currentTime);
    return true;
  }

  bool retryMatching({required String maDon, required String customerId}) {
    if (dispatchMode == OrderDispatchMode.openQueue) return false;
    final order = _findOrder(maDon);
    if (order == null ||
        order.khachHangId != customerId ||
        order.trangThai != 'CHO_XU_LY' ||
        !order.waitingForSupport) {
      return false;
    }

    final staffId = _nextStaff(
      diaChiId: order.diaChiId,
      pickupDate: order.ngayThuGom,
      timeSlot: order.khungGio,
      rejectedStaffIds: const [],
      orderIdToIgnore: order.maDon,
    );
    final now = DateTime.now();
    if (staffId == null) {
      _log(
        order: order,
        actorId: customerId,
        action: 'Yêu cầu hỗ trợ tìm nhân viên',
        note: 'Chưa có nhân viên phù hợp, đơn tiếp tục nằm trong hàng chờ.',
        time: now,
      );
      return false;
    }

    final updated = order.copyWith(
      nhanVienDeXuatId: staffId,
      nhanVienTuChoiIds: const [],
      offerExpiresAt: now.add(offerValidity),
      offerAttempt: order.offerAttempt + 1,
      waitingForSupport: false,
    );
    _replace(updated);
    _notifyOffer(updated, staffId, time: now);
    _log(
      order: updated,
      actorId: customerId,
      action: 'Tìm lại nhân viên',
      note: 'Đã gửi yêu cầu đến nhân viên phù hợp.',
      time: now,
    );
    return true;
  }

  void retryWaitingOrders() {
    if (dispatchMode == OrderDispatchMode.openQueue) return;
    final waitingOrders = state
        .where(
          (order) =>
              order.trangThai == 'CHO_XU_LY' &&
              order.waitingForSupport &&
              order.nhanVienDeXuatId == null,
        )
        .toList();
    for (final order in waitingOrders) {
      final staffId = _nextStaff(
        diaChiId: order.diaChiId,
        pickupDate: order.ngayThuGom,
        timeSlot: order.khungGio,
        rejectedStaffIds: const [],
        orderIdToIgnore: order.maDon,
      );
      if (staffId == null) continue;
      final now = DateTime.now();
      final updated = order.copyWith(
        nhanVienDeXuatId: staffId,
        nhanVienTuChoiIds: const [],
        offerExpiresAt: now.add(offerValidity),
        offerAttempt: order.offerAttempt + 1,
        waitingForSupport: false,
      );
      _replace(updated);
      _notifyOffer(updated, staffId, time: now);
      _notify(
        recipientId: order.khachHangId,
        order: updated,
        title: 'Đã tìm thấy nhân viên',
        content: '${order.maDon} đã được gửi lại cho nhân viên gần bạn.',
        time: now,
      );
      _log(
        order: updated,
        actorId: 'SYSTEM',
        action: 'Tìm lại nhân viên tự động',
        note: 'Hệ thống đã phát hiện nhân viên vừa sẵn sàng.',
        time: now,
      );
    }
  }

  void releaseOffersForStaff(String staffId) {
    if (dispatchMode == OrderDispatchMode.openQueue) return;
    final offers = state
        .where(
          (order) =>
              order.trangThai == 'CHO_XU_LY' &&
              order.nhanVienDeXuatId == staffId,
        )
        .toList();
    for (final order in offers) {
      _log(
        order: order,
        actorId: staffId,
        action: 'Tạm dừng nhận đơn',
        note: 'Nhân viên đã chuyển trạng thái sang ngừng nhận đơn.',
      );
      _forwardOffer(order, currentStaffId: staffId);
    }
  }

  bool updateArrivalTime({
    required String maDon,
    required String nhanVienId,
    required DateTime gioChot,
  }) {
    final order = _findOrder(maDon);
    if (order == null ||
        order.nhanVienHienTaiId != nhanVienId ||
        !{'DA_NHAN', 'DANG_DEN'}.contains(order.trangThai) ||
        !_isArrivalInsideSlot(order, gioChot)) {
      return false;
    }

    final updated = order.copyWith(gioChot: gioChot);
    _replace(updated);
    final arrivalLabel = _formatTime(gioChot);
    _log(
      order: updated,
      actorId: nhanVienId,
      action: 'Cập nhật giờ đến',
      note: 'Giờ đến dự kiến mới là $arrivalLabel.',
    );
    _notify(
      recipientId: order.khachHangId,
      order: updated,
      title: 'Giờ đến đã thay đổi',
      content: '${order.maDon} dự kiến đến lúc $arrivalLabel.',
    );
    return true;
  }

  bool updateStatus({
    required String maDon,
    required String nhanVienId,
    required String status,
  }) {
    final order = _findOrder(maDon);
    if (order == null ||
        order.nhanVienHienTaiId != nhanVienId ||
        _allowedTransitions[order.trangThai] != status) {
      return false;
    }

    final updated = order.copyWith(trangThai: status);
    _replace(updated);
    if (status == 'DANG_DEN') {
      _updateStaffStatus?.call(nhanVienId, 'DANG_THU_GOM');
    }
    final copy = _statusCopy(status);
    _log(
      order: updated,
      actorId: nhanVienId,
      action: copy.action,
      note: copy.note,
    );
    _notify(
      recipientId: order.khachHangId,
      order: updated,
      title: copy.action,
      content: copy.customerMessage,
    );
    return true;
  }

  bool completeOrder({
    required String maDon,
    required String nhanVienId,
    required CollectionRecord record,
    PaymentRecord? payment,
  }) {
    final order = _findOrder(maDon);
    if (order == null ||
        order.trangThai != 'DANG_CAN_RAC' ||
        order.nhanVienHienTaiId != nhanVienId ||
        record.maDon != maDon ||
        record.nhanVienId != nhanVienId ||
        record.khoiLuongThucTe <= 0 ||
        (payment != null &&
            (payment.maDon != maDon ||
                payment.khachHangId != order.khachHangId))) {
      return false;
    }

    _saveCollectionRecord(record);
    if (payment != null) _savePaymentRecord?.call(payment);
    if (order.hinhThucTinhPhi == 'GOI_THANG') {
      _consumeSubscription?.call(
        customerId: order.khachHangId,
        kg: record.khoiLuongThucTe,
      );
    }

    final updated = order.copyWith(trangThai: 'HOAN_THANH');
    _replace(updated);
    _resetStaffIfIdle(nhanVienId, excludingOrderId: maDon);
    _log(
      order: updated,
      actorId: nhanVienId,
      action: 'Hoàn thành thu gom',
      note:
          'Đã lưu biên bản ${record.bienBanId} và xác nhận thu gom thành công.',
      time: record.thoiGianLap,
    );
    _notify(
      recipientId: order.khachHangId,
      order: updated,
      title: 'Đơn đã hoàn thành',
      content:
          '${order.maDon} đã thu gom ${record.khoiLuongThucTe} kg rác. ${record.trangThaiThanhToan == 'DA_THANH_TOAN' ? 'Thanh toán đã hoàn tất.' : 'Vui lòng kiểm tra khoản cần thanh toán.'}',
      time: record.thoiGianLap,
    );
    return true;
  }

  bool cancelOrder({
    required String maDon,
    required String actorId,
    required String reason,
  }) {
    final order = _findOrder(maDon);
    final normalizedReason = reason.trim();
    if (order == null ||
        normalizedReason.isEmpty ||
        order.trangThai == 'HOAN_THANH' ||
        order.trangThai == 'HUY') {
      return false;
    }

    final isCustomer = actorId == order.khachHangId;
    final isStaff =
        actorId == order.nhanVienHienTaiId || actorId == order.nhanVienDeXuatId;
    if (!isCustomer && !isStaff) return false;
    if (isCustomer && !_customerCancelableStatuses.contains(order.trangThai)) {
      return false;
    }

    final updated = order.copyWith(
      trangThai: 'HUY',
      clearNhanVienDeXuatId: true,
      clearOfferExpiresAt: true,
      waitingForSupport: false,
    );
    _replace(updated);
    final staffId = order.nhanVienHienTaiId;
    if (staffId != null) {
      _resetStaffIfIdle(staffId, excludingOrderId: maDon);
    }
    _log(
      order: updated,
      actorId: actorId,
      action: 'Hủy đơn',
      note: normalizedReason,
    );
    final recipientId = isCustomer
        ? order.nhanVienHienTaiId ?? order.nhanVienDeXuatId
        : order.khachHangId;
    if (recipientId != null) {
      _notify(
        recipientId: recipientId,
        order: updated,
        title: 'Đơn đã hủy',
        content: '${order.maDon}: $normalizedReason',
      );
    }
    return true;
  }

  bool confirmPayment({required String maDon, required String customerId}) {
    final order = _findOrder(maDon);
    if (order == null ||
        order.khachHangId != customerId ||
        order.trangThai != 'HOAN_THANH') {
      return false;
    }
    final now = DateTime.now();
    _log(
      order: order,
      actorId: customerId,
      action: 'Xác nhận thanh toán',
      note: 'Khách hàng đã xác nhận hoàn tất thanh toán.',
      time: now,
    );
    final staffId = order.nhanVienHienTaiId;
    if (staffId != null) {
      _notify(
        recipientId: staffId,
        order: order,
        title: 'Thanh toán đã hoàn tất',
        content: 'Khách hàng đã xác nhận thanh toán cho ${order.maDon}.',
        time: now,
      );
    }
    return true;
  }

  bool hasScheduleConflict({
    required String staffId,
    required PickupOrder candidate,
  }) {
    return _hasScheduleConflict(
      staffId,
      candidate.ngayThuGom,
      candidate.khungGio,
      orderIdToIgnore: candidate.maDon,
    );
  }

  bool _accept({
    required PickupOrder order,
    required String staffId,
    required DateTime arrival,
  }) {
    final updated = order.copyWith(
      nhanVienHienTaiId: staffId,
      clearNhanVienDeXuatId: true,
      clearOfferExpiresAt: true,
      waitingForSupport: false,
      trangThai: 'DA_NHAN',
      gioChot: arrival,
    );
    _replace(updated);
    final arrivalLabel = _formatTime(arrival);
    _log(
      order: updated,
      actorId: staffId,
      action: 'Nhận đơn và chốt giờ',
      note: 'Nhân viên dự kiến đến lúc $arrivalLabel.',
    );
    _notify(
      recipientId: order.khachHangId,
      order: updated,
      title: 'Nhân viên đã nhận đơn',
      content: '${order.maDon} đã được nhận. Dự kiến đến lúc $arrivalLabel.',
    );
    return true;
  }

  void _forwardOffer(
    PickupOrder order, {
    required String currentStaffId,
    DateTime? eventTime,
  }) {
    final now = eventTime ?? DateTime.now();
    final rejected = {...order.nhanVienTuChoiIds, currentStaffId}.toList();
    final nextStaffId = _nextStaff(
      diaChiId: order.diaChiId,
      pickupDate: order.ngayThuGom,
      timeSlot: order.khungGio,
      rejectedStaffIds: rejected,
      orderIdToIgnore: order.maDon,
    );
    final updated = order.copyWith(
      nhanVienDeXuatId: nextStaffId,
      clearNhanVienDeXuatId: nextStaffId == null,
      nhanVienTuChoiIds: rejected,
      offerExpiresAt: nextStaffId == null ? null : now.add(offerValidity),
      clearOfferExpiresAt: nextStaffId == null,
      offerAttempt: order.offerAttempt + (nextStaffId == null ? 0 : 1),
      waitingForSupport: nextStaffId == null,
    );
    _replace(updated);
    if (nextStaffId != null) {
      _notifyOffer(updated, nextStaffId, time: now);
      _notify(
        recipientId: order.khachHangId,
        order: updated,
        title: 'Đang tìm nhân viên khác',
        content:
            'GreenTrash đã chuyển ${order.maDon} đến nhân viên phù hợp tiếp theo.',
        time: now,
      );
      return;
    }

    _notify(
      recipientId: order.khachHangId,
      order: updated,
      title: 'Đơn đang chờ hỗ trợ',
      content:
          'Chưa còn nhân viên phù hợp cho ${order.maDon}. Bộ phận hỗ trợ sẽ tiếp tục xử lý.',
      time: now,
    );
  }

  PickupOrder? _findOrder(String maDon) {
    for (final order in state) {
      if (order.maDon == maDon) return order;
    }
    return null;
  }

  void _replace(PickupOrder updated) {
    state = [
      for (final order in state)
        if (order.maDon == updated.maDon) updated else order,
    ];
  }

  void _log({
    required PickupOrder order,
    required String actorId,
    required String action,
    required String note,
    DateTime? time,
  }) {
    final eventTime = time ?? DateTime.now();
    _addActivityLog(
      ActivityLog(
        logId: _eventId('LOG', eventTime),
        maDon: order.maDon,
        userId: actorId,
        hanhDong: action,
        thoiGian: eventTime,
        ghiChu: note,
      ),
    );
  }

  void _notifyOffer(PickupOrder order, String staffId, {DateTime? time}) {
    _notify(
      recipientId: staffId,
      order: order,
      title: 'Có đơn mới gần bạn',
      content:
          '${order.maDon} cần thu gom trong khung ${order.khungGio}. Vui lòng phản hồi trong 2 phút.',
      time: time,
    );
  }

  void _notify({
    required String recipientId,
    required PickupOrder order,
    required String title,
    required String content,
    DateTime? time,
  }) {
    final eventTime = time ?? DateTime.now();
    _addNotification(
      AppNotification(
        thongBaoId: _eventId('TB', eventTime),
        nguoiNhanId: recipientId,
        maDon: order.maDon,
        tieuDe: title,
        noiDung: content,
        trangThaiDoc: 'CHUA_DOC',
        thoiGian: eventTime,
      ),
    );
  }

  String _eventId(String prefix, DateTime time) {
    _eventSequence += 1;
    return '${prefix}_${time.microsecondsSinceEpoch}_$_eventSequence';
  }

  String _nextOrderId() {
    var maximum = 0;
    for (final order in state) {
      final number = int.tryParse(order.maDon.replaceFirst('DON_', ''));
      if (number != null && number > maximum) maximum = number;
    }
    return 'DON_${(maximum + 1).toString().padLeft(3, '0')}';
  }

  String? _nextStaff({
    required String diaChiId,
    required DateTime pickupDate,
    required String timeSlot,
    required List<String> rejectedStaffIds,
    String? orderIdToIgnore,
  }) {
    final address = _findAddress(diaChiId);
    final availableStaff = _staffProfiles
        .where(
          (profile) =>
              profile.trangThaiLamViec == 'SAN_SANG' &&
              !rejectedStaffIds.contains(profile.nhanVienId) &&
              _isWithinWorkingHours(profile, timeSlot) &&
              !_hasPendingOffer(
                profile.nhanVienId,
                orderIdToIgnore: orderIdToIgnore,
              ) &&
              !_hasScheduleConflict(
                profile.nhanVienId,
                pickupDate,
                timeSlot,
                orderIdToIgnore: orderIdToIgnore,
              ),
        )
        .toList();

    if (availableStaff.isEmpty) return null;
    availableStaff.sort((a, b) {
      final aSameArea = _sameArea(address, a) ? 0 : 1;
      final bSameArea = _sameArea(address, b) ? 0 : 1;
      final areaCompare = aSameArea.compareTo(bSameArea);
      if (areaCompare != 0) return areaCompare;
      return a.doanhThuHienTai.compareTo(b.doanhThuHienTai);
    });
    return availableStaff.first.nhanVienId;
  }

  bool _canStaffTakeOrder(PickupOrder order, String staffId) {
    StaffProfile? profile;
    for (final item in _staffProfiles) {
      if (item.nhanVienId == staffId) {
        profile = item;
        break;
      }
    }
    return profile != null &&
        profile.trangThaiLamViec == 'SAN_SANG' &&
        _isWithinWorkingHours(profile, order.khungGio) &&
        !_hasScheduleConflict(
          staffId,
          order.ngayThuGom,
          order.khungGio,
          orderIdToIgnore: order.maDon,
        );
  }

  bool _hasScheduleConflict(
    String staffId,
    DateTime pickupDate,
    String timeSlot, {
    String? orderIdToIgnore,
  }) {
    final candidateRange = _slotRange(timeSlot);
    if (candidateRange == null) return true;

    for (final order in state) {
      if (order.maDon == orderIdToIgnore ||
          order.nhanVienHienTaiId != staffId ||
          order.trangThai == 'HOAN_THANH' ||
          order.trangThai == 'HUY' ||
          !_isSameDay(order.ngayThuGom, pickupDate)) {
        continue;
      }
      final existingRange = _slotRange(order.khungGio);
      if (existingRange != null &&
          candidateRange.start < existingRange.end &&
          existingRange.start < candidateRange.end) {
        return true;
      }
    }
    return false;
  }

  bool _hasPendingOffer(String staffId, {String? orderIdToIgnore}) {
    return state.any(
      (order) =>
          order.maDon != orderIdToIgnore &&
          order.trangThai == 'CHO_XU_LY' &&
          order.nhanVienDeXuatId == staffId,
    );
  }

  List<StaffProfile> get _staffProfiles =>
      _readStaffProfiles?.call() ?? _fallbackStaff;

  CustomerAddress? _findAddress(String diaChiId) {
    for (final address in _addresses) {
      if (address.diaChiId == diaChiId) return address;
    }
    return null;
  }

  bool _sameArea(CustomerAddress? address, StaffProfile staff) {
    if (address == null) return false;
    return staff.viTriHienTai.toLowerCase().contains(
      address.quanHuyen.toLowerCase(),
    );
  }

  bool _isWithinWorkingHours(StaffProfile staff, String timeSlot) {
    final slot = _slotRange(timeSlot);
    final start = _minutes(staff.gioBatDau);
    final end = _minutes(staff.gioKetThuc);
    if (slot == null || start == null || end == null) return false;
    return slot.start >= start && slot.end <= end;
  }

  bool _isArrivalInsideSlot(PickupOrder order, DateTime arrival) {
    if (!_isSameDay(arrival, order.ngayThuGom)) return false;
    final slot = _slotRange(order.khungGio);
    if (slot == null) return false;
    final selected = arrival.hour * 60 + arrival.minute;
    return selected >= slot.start && selected < slot.end;
  }

  _MinuteRange? _slotRange(String input) {
    final limits = input.split('-');
    if (limits.length != 2) return null;
    final start = _minutes(limits.first);
    final end = _minutes(limits.last);
    if (start == null || end == null || start >= end) return null;
    return _MinuteRange(start, end);
  }

  int? _minutes(String input) {
    final parts = input.trim().split(':');
    if (parts.length == 1) {
      final hour = int.tryParse(parts.first);
      return hour == null ? null : hour * 60;
    }
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null ||
        minute == null ||
        hour < 0 ||
        hour > 23 ||
        minute < 0 ||
        minute > 59) {
      return null;
    }
    return hour * 60 + minute;
  }

  bool _isOfferExpired(PickupOrder order, DateTime now) {
    final expiresAt = order.offerExpiresAt;
    return expiresAt != null && !now.isBefore(expiresAt);
  }

  void _resetStaffIfIdle(String staffId, {required String excludingOrderId}) {
    final stillBusy = state.any(
      (order) =>
          order.maDon != excludingOrderId &&
          order.nhanVienHienTaiId == staffId &&
          _busyStatuses.contains(order.trangThai),
    );
    if (!stillBusy) {
      _updateStaffStatus?.call(staffId, 'SAN_SANG');
    }
  }

  String _formatTime(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  _StatusCopy _statusCopy(String status) {
    return switch (status) {
      'DANG_DEN' => const _StatusCopy(
        action: 'Bắt đầu di chuyển',
        note: 'Nhân viên đang trên đường đến điểm thu gom.',
        customerMessage: 'Nhân viên đang di chuyển đến địa chỉ của bạn.',
      ),
      'DA_DEN' => const _StatusCopy(
        action: 'Đã đến điểm lấy',
        note: 'Nhân viên đã có mặt tại địa chỉ thu gom.',
        customerMessage: 'Nhân viên đã đến. Vui lòng chuẩn bị bàn giao rác.',
      ),
      'DANG_CAN_RAC' => const _StatusCopy(
        action: 'Bắt đầu cân rác',
        note: 'Nhân viên đang kiểm tra loại rác và khối lượng thực tế.',
        customerMessage: 'Rác đang được kiểm tra và cân thực tế.',
      ),
      _ => const _StatusCopy(
        action: 'Cập nhật đơn',
        note: 'Trạng thái đơn đã được cập nhật.',
        customerMessage: 'Đơn thu gom vừa có cập nhật mới.',
      ),
    };
  }

  static List<PickupOrder> _prepareInitialOrders(
    List<PickupOrder> initialOrders,
    OrderDispatchMode dispatchMode,
  ) {
    final now = DateTime.now();
    return [
      for (final order in initialOrders)
        if (dispatchMode == OrderDispatchMode.openQueue &&
            order.trangThai == 'CHO_XU_LY')
          order.copyWith(
            clearNhanVienDeXuatId: true,
            clearOfferExpiresAt: true,
            offerAttempt: 0,
            waitingForSupport: false,
          )
        else if (order.trangThai == 'CHO_XU_LY' &&
            order.nhanVienDeXuatId != null &&
            order.offerExpiresAt == null)
          order.copyWith(
            offerExpiresAt: now.add(offerValidity),
            offerAttempt: order.offerAttempt == 0 ? 1 : order.offerAttempt,
          )
        else
          order,
    ];
  }

  static bool _isSameDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }
}

class _StatusCopy {
  const _StatusCopy({
    required this.action,
    required this.note,
    required this.customerMessage,
  });

  final String action;
  final String note;
  final String customerMessage;
}

class _MinuteRange {
  const _MinuteRange(this.start, this.end);

  final int start;
  final int end;
}
