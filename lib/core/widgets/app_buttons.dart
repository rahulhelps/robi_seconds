import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pressable_scale.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isPrimary;
  final bool isLoading;
  final bool isDisabled;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double height;

  const AppButton({
    super.key,
    required this.label,
    this.onTap,
    this.isPrimary = true,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 54,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveOnTap = (isDisabled || isLoading) ? null : onTap;

    return PressableScale(
      onTap: effectiveOnTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: isPrimary && !isDisabled
              ? const LinearGradient(
                  colors: [Color(0xFF024D87), Color(0xFF0369B7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: !isPrimary && !isDisabled
              ? Colors.white
              : (isDisabled ? Colors.grey[200] : backgroundColor),
          border: !isPrimary && !isDisabled
              ? Border.all(color: const Color(0xFF024D87).withValues(alpha: 0.2), width: 1.5)
              : null,
          boxShadow: isPrimary && !isDisabled
              ? [
                  BoxShadow(
                    color: const Color(0xFF024D87).withValues(alpha: 0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isPrimary ? Colors.white : const Color(0xFF024D87),
                        ),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (icon != null) ...[
                          Icon(
                            icon,
                            size: 18,
                            color: isPrimary
                                ? Colors.white
                                : (textColor ?? const Color(0xFF024D87)),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Flexible(
                          child: Text(
                            label,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: isPrimary
                                  ? (isDisabled ? Colors.grey[500] : Colors.white)
                                  : (isDisabled ? Colors.grey[500] : (textColor ?? const Color(0xFF024D87))),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
