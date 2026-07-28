import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/app_models.dart';
import '../data/firestore_order_workflow_repository.dart';
import '../domain/order_workflow_models.dart';
import '../domain/order_workflow_repository.dart';

final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final orderWorkflowRepositoryProvider = Provider<OrderWorkflowRepository>((
  ref,
) {
  return FirestoreOrderWorkflowRepository(ref.watch(firebaseFirestoreProvider));
});

final firestoreCustomerOrdersProvider =
    StreamProvider.family<List<PickupOrder>, String>((ref, customerId) {
      return ref
          .watch(orderWorkflowRepositoryProvider)
          .watchCustomerOrders(customerId);
    });

final firestoreStaffOrdersProvider =
    StreamProvider.family<List<PickupOrder>, String>((ref, staffId) {
      return ref
          .watch(orderWorkflowRepositoryProvider)
          .watchStaffOrders(staffId);
    });

final firestoreOpenOrdersProvider =
    StreamProvider.family<List<PickupOrder>, String>((ref, staffId) {
      return ref
          .watch(orderWorkflowRepositoryProvider)
          .watchOpenOrders(staffId);
    });

final firestorePendingOffersProvider =
    StreamProvider.family<List<PickupAssignment>, String>((ref, staffId) {
      return ref
          .watch(orderWorkflowRepositoryProvider)
          .watchPendingOffers(staffId);
    });

final firestoreOrderActivityLogsProvider =
    StreamProvider.family<List<ActivityLog>, String>((ref, maDon) {
      return ref
          .watch(orderWorkflowRepositoryProvider)
          .watchActivityLogs(maDon);
    });

final firestoreCollectionRecordProvider =
    StreamProvider.family<CollectionRecord?, String>((ref, maDon) {
      return ref
          .watch(orderWorkflowRepositoryProvider)
          .watchCollectionRecord(maDon);
    });

final firestorePaymentRecordProvider =
    StreamProvider.family<PaymentRecord?, String>((ref, maDon) {
      return ref
          .watch(orderWorkflowRepositoryProvider)
          .watchPaymentRecord(maDon);
    });
