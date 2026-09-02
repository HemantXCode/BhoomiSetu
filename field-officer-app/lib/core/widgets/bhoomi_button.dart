import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum ButtonType { primary, secondary, outline, danger }

class BhoomiButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final IconData? icon;
  final bool isLoading;
  final double? width;
  final double height;

  final double? fontSize;

  const BhoomiButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = ButtonType.primary,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height = 50,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    Widget child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(_getTextColor()),
            ),
          ),
          const SizedBox(width: 8),
        ] else if (icon != null) ...[
          Icon(icon, size: 18, color: _getTextColor()),
          const SizedBox(width: 6),
        ],
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              fontSize: fontSize ?? 13.5,
              fontWeight: FontWeight.w700,
              color: _getTextColor(),
              letterSpacing: 0.2,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );

    switch (type) {
      case ButtonType.primary:
        return SizedBox(
          width: width ?? double.infinity,
          height: height,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: child,
          ),
        );
      case ButtonType.secondary:
        return SizedBox(
          width: width ?? double.infinity,
          height: height,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: child,
          ),
        );
      case ButtonType.outline:
        return SizedBox(
          width: width ?? double.infinity,
          height: height,
          child: OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.secondary, width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: child,
          ),
        );
      case ButtonType.danger:
        return SizedBox(
          width: width ?? double.infinity,
          height: height,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: child,
          ),
        );
    }
  }

  Color _getTextColor() {
    switch (type) {
      case ButtonType.primary:
      case ButtonType.secondary:
      case ButtonType.danger:
        return Colors.white;
      case ButtonType.outline:
        return AppColors.secondary;
    }
  }
}
