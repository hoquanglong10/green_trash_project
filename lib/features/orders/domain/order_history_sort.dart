import '../../../models/app_models.dart';

DateTime historyOrderTimestamp(PickupOrder order) {
  return order.ngayCapNhat ?? order.ngayTao;
}

List<PickupOrder> sortHistoryOrdersNewestFirst(Iterable<PickupOrder> orders) {
  final sorted = orders.toList(growable: false);
  sorted.sort(
    (first, second) =>
        historyOrderTimestamp(second).compareTo(historyOrderTimestamp(first)),
  );
  return sorted;
}
