const staffAvailableStatuses = {'SAN_SANG', 'DANG_RANH'};

bool isStaffAvailable(String? status) {
  return staffAvailableStatuses.contains(status);
}

bool isAvailabilityLocked({required int activeOrderCount}) {
  return activeOrderCount > 0;
}

String nextStaffAvailabilityStatus(String? currentStatus) {
  return isStaffAvailable(currentStatus) ? 'TAM_NGHI' : 'SAN_SANG';
}
