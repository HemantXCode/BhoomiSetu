import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/notification_model.dart';
import '../../core/providers/app_providers.dart';

class NotificationsState {
  final bool isLoading;
  final List<NotificationModel> notifications;
  final int unreadCount;

  NotificationsState({
    this.isLoading = false,
    this.notifications = const [],
    this.unreadCount = 0,
  });

  NotificationsState copyWith({
    bool? isLoading,
    List<NotificationModel>? notifications,
    int? unreadCount,
  }) {
    return NotificationsState(
      isLoading: isLoading ?? this.isLoading,
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

class NotificationsController extends StateNotifier<NotificationsState> {
  final Ref _ref;

  NotificationsController(this._ref) : super(NotificationsState(isLoading: true)) {
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    state = state.copyWith(isLoading: true);
    final repo = _ref.read(notificationRepositoryProvider);
    final list = await repo.getNotifications();
    final count = await repo.getUnreadCount();
    state = state.copyWith(isLoading: false, notifications: list, unreadCount: count);
  }

  Future<void> markAsRead(String id) async {
    final repo = _ref.read(notificationRepositoryProvider);
    await repo.markAsRead(id);
    await loadNotifications();
  }

  Future<void> markAllAsRead() async {
    final repo = _ref.read(notificationRepositoryProvider);
    await repo.markAllAsRead();
    await loadNotifications();
  }
}

final notificationsControllerProvider =
    StateNotifierProvider<NotificationsController, NotificationsState>((ref) {
  return NotificationsController(ref);
});
