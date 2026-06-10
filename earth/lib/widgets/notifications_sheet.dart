import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_theme.dart';
import '../models/earthquake_model.dart';

class EarthquakeNotification {
  final String id;
  final String title;
  final String message;
  final EarthquakeModel earthquake;
  final DateTime time;
  final NotificationType type;
  final bool isUnread;

  const EarthquakeNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.earthquake,
    required this.time,
    this.type = NotificationType.alert,
    this.isUnread = true,
  });
}

enum NotificationType { alert, aftershock, resolved, info }

class NotificationsSheet extends StatelessWidget {
  final List<EarthquakeNotification> notifications;
  final ValueChanged<String>? onMarkAsRead;
  final VoidCallback? onClearAll;

  const NotificationsSheet({
    super.key,
    required this.notifications,
    this.onMarkAsRead,
    this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    final unreadCount = notifications.where((n) => n.isUnread).length;

    return Container(
      constraints: BoxConstraints(maxHeight: 0.85.sh),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: EdgeInsets.only(top: 10.h, bottom: 6.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          // Header
          _buildHeader(unreadCount),
          Divider(color: AppColors.divider, height: 1.h),
          // List
          Flexible(
            child: notifications.isEmpty
                ? _buildEmpty()
                : ListView.separated(
                    padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
                    itemCount: notifications.length,
                    separatorBuilder: (_, __) => SizedBox(height: 10.h),
                    itemBuilder: (context, index) {
                      final n = notifications[index];
                      return _NotificationCard(
                        notification: n,
                        onTap: () {
                          if (onMarkAsRead != null) onMarkAsRead!(n.id);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(int unreadCount) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 10.h, 12.w, 14.h),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.notifications_active_rounded,
              color: AppColors.primary,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notifications',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  unreadCount > 0
                      ? '$unreadCount new alert${unreadCount == 1 ? '' : 's'}'
                      : 'You\'re all caught up',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
          if (onClearAll != null && notifications.isNotEmpty)
            TextButton(
              onPressed: onClearAll,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Mark all read',
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 60.h),
      child: Column(
        children: [
          Icon(
            Icons.notifications_off_rounded,
            color: AppColors.textHint,
            size: 48.sp,
          ),
          SizedBox(height: 12.h),
          Text(
            'No notifications yet',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final EarthquakeNotification notification;
  final VoidCallback onTap;

  const _NotificationCard({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final n = notification;
    final color = _typeColor(n.type);
    final icon = _typeIcon(n.type);
    final eq = n.earthquake;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: n.isUnread
                ? AppColors.card
                : AppColors.cardLight.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: n.isUnread
                  ? color.withValues(alpha: 0.35)
                  : AppColors.divider,
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Magnitude badge / type icon
              Column(
                children: [
                  Container(
                    width: 48.w,
                    height: 48.w,
                    decoration: BoxDecoration(
                      color: eq.severityColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: eq.severityColor.withValues(alpha: 0.4),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'M${eq.magnitude}',
                        style: TextStyle(
                          color: eq.severityColor,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Container(
                    width: 22.w,
                    height: 22.w,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 12.sp),
                  ),
                ],
              ),
              SizedBox(width: 12.w),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            n.title,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14.sp,
                              fontWeight: n.isUnread
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          _shortTimeAgo(n.time),
                          style: TextStyle(
                            color: AppColors.textHint,
                            fontSize: 11.sp,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      n.message,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12.sp,
                        height: 1.35,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          color: AppColors.textHint,
                          size: 11.sp,
                        ),
                        SizedBox(width: 3.w),
                        Text(
                          '${eq.location}, ${eq.country}',
                          style: TextStyle(
                            color: AppColors.textHint,
                            fontSize: 11.sp,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: eq.severityColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            eq.severityLabel,
                            style: TextStyle(
                              color: eq.severityColor,
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (n.isUnread)
                          Container(
                            width: 8.w,
                            height: 8.w,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _typeColor(NotificationType t) {
    switch (t) {
      case NotificationType.alert:
        return AppColors.primary;
      case NotificationType.aftershock:
        return AppColors.warning;
      case NotificationType.resolved:
        return AppColors.accent;
      case NotificationType.info:
        return AppColors.secondary;
    }
  }

  IconData _typeIcon(NotificationType t) {
    switch (t) {
      case NotificationType.alert:
        return Icons.warning_amber_rounded;
      case NotificationType.aftershock:
        return Icons.waves_rounded;
      case NotificationType.resolved:
        return Icons.check_circle_rounded;
      case NotificationType.info:
        return Icons.info_outline_rounded;
    }
  }

  String _shortTimeAgo(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 1) return 'now';
    if (d.inMinutes < 60) return '${d.inMinutes}m';
    if (d.inHours < 24) return '${d.inHours}h';
    return '${d.inDays}d';
  }
}
