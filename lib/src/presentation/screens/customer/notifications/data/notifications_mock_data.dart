import '../models/notif_item.dart';

List<NotifItem> seedNotifs() {
  final now = DateTime.now();
  return [
    NotifItem(
      id: 'n1',
      category: NotifCategory.booking,
      title: 'Booking confirmed',
      subtitle: 'Your Mercedes AMG GT for Jan 15 has been confirmed.',
      at: now.subtract(const Duration(minutes: 20)),
    ),
    NotifItem(
      id: 'n2',
      category: NotifCategory.promotion,
      title: 'Weekend flash sale • 20% off',
      subtitle: 'Tap to view exclusive weekend deals on premium cars.',
      at: now.subtract(const Duration(hours: 3)),
    ),
    NotifItem(
      id: 'n3',
      category: NotifCategory.system,
      title: 'New app version available',
      subtitle: 'Update to unlock faster search and improved maps.',
      at: now.subtract(const Duration(hours: 7)),
      isRead: true,
    ),
    NotifItem(
      id: 'n4',
      category: NotifCategory.booking,
      title: 'Driver on the way',
      subtitle: 'Ahmed will arrive at Muscat Airport in ~12 minutes.',
      at: now.subtract(const Duration(days: 1, hours: 2)),
    ),
    NotifItem(
      id: 'n5',
      category: NotifCategory.promotion,
      title: 'Your referral earned 5 OMR',
      subtitle: 'Omar just completed his first trip with your code.',
      at: now.subtract(const Duration(days: 1, hours: 6)),
      isRead: true,
    ),
    NotifItem(
      id: 'n6',
      category: NotifCategory.system,
      title: 'Security alert',
      subtitle: 'Sign-in from new device detected in Muscat.',
      at: now.subtract(const Duration(days: 3)),
      isRead: true,
    ),
    NotifItem(
      id: 'n7',
      category: NotifCategory.booking,
      title: 'Rate your last trip',
      subtitle: 'How was your experience with Yusuf? Leave a review.',
      at: now.subtract(const Duration(days: 5)),
      isRead: true,
    ),
  ];
}
