import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class OfflineBanner extends StatelessWidget {
  final bool isOffline;
  final int pendingCount;
  final VoidCallback? onSyncTap;

  const OfflineBanner({
    super.key,
    required this.isOffline,
    required this.pendingCount,
    this.onSyncTap,
  });

  @override
  Widget build(BuildContext context) {
    if (!isOffline && pendingCount == 0) {
      return const SizedBox.shrink();
    }

    final isOfflineAlert = isOffline;
    final bgColor = isOfflineAlert ? const Color(0xFF334155) : const Color(0xFF4338CA);
    final text = isOfflineAlert
        ? 'Offline Mode • $pendingCount changes saved locally'
        : '$pendingCount items pending synchronization';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            isOfflineAlert ? Icons.wifi_off : Icons.sync,
            size: 16,
            color: Colors.white,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          if (onSyncTap != null && !isOfflineAlert) ...[
            InkWell(
              onTap: onSyncTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'SYNC NOW',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4338CA),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
