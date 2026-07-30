import 'package:flutter_test/flutter_test.dart';
import 'package:green_trash_project/features/staff/domain/staff_availability.dart';

void main() {
  test('stale busy status can recover when there is no active order', () {
    expect(isAvailabilityLocked(activeOrderCount: 0), isFalse);
    expect(nextStaffAvailabilityStatus('DANG_THU_GOM'), 'SAN_SANG');
  });

  test('availability remains locked while an active order exists', () {
    expect(isAvailabilityLocked(activeOrderCount: 1), isTrue);
  });

  test('available staff can toggle to pause and legacy status is accepted', () {
    expect(isStaffAvailable('SAN_SANG'), isTrue);
    expect(isStaffAvailable('DANG_RANH'), isTrue);
    expect(nextStaffAvailabilityStatus('SAN_SANG'), 'TAM_NGHI');
  });
}
