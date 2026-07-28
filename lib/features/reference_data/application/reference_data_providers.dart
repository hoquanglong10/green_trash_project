import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/app_models.dart';
import '../../orders/application/order_workflow_providers.dart';
import '../data/firestore_reference_data_repository.dart';

final referenceDataRepositoryProvider =
    Provider<FirestoreReferenceDataRepository>(
      (ref) => FirestoreReferenceDataRepository(
        ref.watch(firebaseFirestoreProvider),
      ),
    );

final firestoreCustomerAddressesProvider =
    StreamProvider.family<List<CustomerAddress>, String>((ref, customerId) {
      return ref
          .watch(referenceDataRepositoryProvider)
          .watchCustomerAddresses(customerId);
    });

final firestoreAllAddressesProvider = StreamProvider<List<CustomerAddress>>((
  ref,
) {
  return ref.watch(referenceDataRepositoryProvider).watchAllAddresses();
});

final firestoreWasteTypesProvider = StreamProvider<List<WasteType>>((ref) {
  return ref.watch(referenceDataRepositoryProvider).watchWasteTypes();
});

final firestorePriceItemsProvider = StreamProvider<List<PriceItem>>((ref) {
  return ref.watch(referenceDataRepositoryProvider).watchPriceItems();
});

final firestorePackagesProvider = StreamProvider<List<PickupPackage>>((ref) {
  return ref.watch(referenceDataRepositoryProvider).watchPackages();
});

final firestoreCustomerSubscriptionsProvider =
    StreamProvider.family<List<PackageSubscription>, String>((ref, customerId) {
      return ref
          .watch(referenceDataRepositoryProvider)
          .watchCustomerSubscriptions(customerId);
    });

final firestoreStaffProfilesProvider = StreamProvider<List<StaffProfile>>((
  ref,
) {
  return ref.watch(referenceDataRepositoryProvider).watchStaffProfiles();
});

final firestoreNotificationsProvider =
    StreamProvider.family<List<AppNotification>, String>((ref, recipientId) {
      return ref
          .watch(referenceDataRepositoryProvider)
          .watchNotifications(recipientId);
    });
