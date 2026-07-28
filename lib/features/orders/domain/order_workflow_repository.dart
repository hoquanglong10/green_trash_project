import '../../../models/app_models.dart';
import 'order_workflow_models.dart';

abstract interface class OrderWorkflowRepository {
  Stream<List<PickupOrder>> watchCustomerOrders(String customerId);

  Stream<List<PickupOrder>> watchStaffOrders(String staffId);

  Stream<List<PickupOrder>> watchOpenOrders(String staffId);

  Stream<List<PickupAssignment>> watchPendingOffers(String staffId);

  Stream<PickupOrder?> watchOrder(String maDon);

  Stream<List<ActivityLog>> watchActivityLogs(String maDon);

  Stream<CollectionRecord?> watchCollectionRecord(String maDon);

  Stream<PaymentRecord?> watchPaymentRecord(String maDon);

  Future<PickupOrder> createOrder(CreatePickupOrderCommand command);

  Future<void> acceptOffer(AcceptPickupOfferCommand command);

  Future<void> claimOpenOrder(ClaimOpenPickupOrderCommand command);

  Future<void> dismissOpenOrder(DismissOpenPickupOrderCommand command);

  Future<void> rejectOffer(RejectPickupOfferCommand command);

  Future<void> updateArrivalTime(UpdateArrivalTimeCommand command);

  Future<void> transitionOrder(TransitionPickupOrderCommand command);

  Future<void> completeOrder(CompletePickupOrderCommand command);

  Future<void> cancelOrder(CancelPickupOrderCommand command);

  Future<void> confirmPayment(ConfirmPaymentCommand command);

  Future<void> updateStaffLocation(StaffLocationCommand command);
}
