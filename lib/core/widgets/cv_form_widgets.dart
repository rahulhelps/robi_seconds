import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Step header ───────────────────────────────────────────────────────────────

class CvStepHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData? icon;

  const CvStepHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF024D87).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xFF024D87), size: 26),
              ),
              const SizedBox(width: 14),
            ],
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.manrope(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF191C1D),
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: const Color(0xFF4A5568),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

// ── Reusable text field ───────────────────────────────────────────────────────

class CvTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final int maxLines;
  final void Function(String) onChanged;
  final String? errorText;
  final void Function(String)? onFieldSubmitted;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? suffix;
  final IconData? prefixIcon;
  final bool isRequired;
  final TextInputType? keyboardType;

  const CvTextField({
    super.key,
    required this.label,
    this.hint,
    this.maxLines = 1,
    required this.onChanged,
    this.errorText,
    this.onFieldSubmitted,
    this.controller,
    this.focusNode,
    this.suffix,
    this.prefixIcon,
    this.isRequired = false,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2D3748),
                letterSpacing: 0.2,
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFE53E3E),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          maxLines: maxLines,
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          style: GoogleFonts.inter(
            color: const Color(0xFF1A202C),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
              color: const Color(0xFFA0AEC0),
              fontSize: 14,
            ),
            filled: true,
            fillColor: hasError
                ? const Color(0xFFFFF5F5)
                : const Color(0xFFF7FAFC),
            prefixIcon: prefixIcon != null
                ? Icon(
                    prefixIcon,
                    size: 20,
                    color: hasError
                        ? const Color(0xFFE53E3E)
                        : const Color(0xFF718096),
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: hasError
                    ? const Color(0xFFFEB2B2)
                    : const Color(0xFFE2E8F0),
                width: 1.2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: hasError
                    ? const Color(0xFFE53E3E)
                    : const Color(0xFF024D87),
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE53E3E), width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE53E3E), width: 2),
            ),
            errorText: errorText,
            errorStyle: GoogleFonts.inter(
              fontSize: 12,
              color: const Color(0xFFE53E3E),
              fontWeight: FontWeight.w500,
            ),
            suffixText: suffix,
            suffixStyle: GoogleFonts.inter(
              color: const Color(0xFF024D87),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          onChanged: onChanged,
          onFieldSubmitted: onFieldSubmitted,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

// ── Dropdown field (Material 3 Cute) ──────────────────────────────────────────

class CvDropdownField extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> options;
  final void Function(String?) onChanged;
  final String? errorText;
  final String? hint;
  final IconData? prefixIcon;
  final bool isRequired;

  const CvDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.errorText,
    this.hint,
    this.prefixIcon,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;
    final currentValue = (value != null && options.contains(value))
        ? value
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2D3748),
                letterSpacing: 0.2,
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFE53E3E),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: currentValue,
          onChanged: onChanged,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF024D87),
            size: 22,
          ),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(16),
          style: GoogleFonts.inter(
            color: const Color(0xFF1A202C),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint ?? 'Select $label',
            hintStyle: GoogleFonts.inter(
              color: const Color(0xFFA0AEC0),
              fontSize: 14,
            ),
            filled: true,
            fillColor: hasError
                ? const Color(0xFFFFF5F5)
                : const Color(0xFFF7FAFC),
            prefixIcon: prefixIcon != null
                ? Icon(
                    prefixIcon,
                    size: 20,
                    color: hasError
                        ? const Color(0xFFE53E3E)
                        : const Color(0xFF718096),
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: hasError
                    ? const Color(0xFFFEB2B2)
                    : const Color(0xFFE2E8F0),
                width: 1.2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: hasError
                    ? const Color(0xFFE53E3E)
                    : const Color(0xFF024D87),
                width: 2,
              ),
            ),
            errorText: errorText,
            errorStyle: GoogleFonts.inter(
              fontSize: 12,
              color: const Color(0xFFE53E3E),
              fontWeight: FontWeight.w500,
            ),
          ),
          items: options
              .map(
                (opt) => DropdownMenuItem(
                  value: opt,
                  child: Text(
                    opt,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF1A202C),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

// ── DatePicker field (Material 3 Cute) ────────────────────────────────────────

class CvDatePickerField extends StatelessWidget {
  final String label;
  final String value;
  final void Function(String) onDateSelected;
  final String? errorText;
  final String? hint;
  final bool isRequired;

  const CvDatePickerField({
    super.key,
    required this.label,
    required this.value,
    required this.onDateSelected,
    this.errorText,
    this.hint,
    this.isRequired = false,
  });

  DateTime? _parseInitialDate(String dateStr) {
    if (dateStr.trim().isEmpty) return null;
    final text = dateStr.trim();

    // Standard formats: YYYY-MM-DD or DD/MM/YYYY
    try {
      if (text.contains('-')) {
        final parts = text.split('-');
        if (parts.length == 3) {
          if (parts[0].length == 4) {
            return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
          } else {
            return DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
          }
        }
      } else if (text.contains('/')) {
        final parts = text.split('/');
        if (parts.length == 3) {
          return DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
        }
      }
    } catch (_) {}
    return null;
  }

  int? _calculateAge(String dateStr) {
    final parsed = _parseInitialDate(dateStr);
    if (parsed == null) return null;
    final today = DateTime.now();
    int age = today.year - parsed.year;
    if (today.month < parsed.month || (today.month == parsed.month && today.day < parsed.day)) {
      age--;
    }
    return age > 0 ? age : null;
  }

  String _formatDisplayDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final day = dt.day.toString().padLeft(2, '0');
    final month = months[dt.month - 1];
    return '$day $month ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;
    final hasValue = value.trim().isNotEmpty;
    final age = hasValue ? _calculateAge(value) : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2D3748),
                letterSpacing: 0.2,
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFE53E3E),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final now = DateTime.now();
            final initial = _parseInitialDate(value) ?? DateTime(now.year - 22, 1, 1);
            final picked = await showDatePicker(
              context: context,
              initialDate: initial.isAfter(now) ? now : initial,
              firstDate: DateTime(1940),
              lastDate: now,
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: Color(0xFF024D87),
                      onPrimary: Colors.white,
                      surface: Colors.white,
                      onSurface: Color(0xFF1A202C),
                    ),
                    datePickerTheme: DatePickerThemeData(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      headerBackgroundColor: const Color(0xFF024D87),
                      headerForegroundColor: Colors.white,
                    ),
                  ),
                  child: child!,
                );
              },
            );

            if (picked != null) {
              final formatted = _formatDisplayDate(picked);
              onDateSelected(formatted);
            }
          },
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: hasError ? const Color(0xFFFFF5F5) : const Color(0xFFF7FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: hasError
                    ? const Color(0xFFE53E3E)
                    : hasValue
                        ? const Color(0xFF024D87).withValues(alpha: 0.4)
                        : const Color(0xFFE2E8F0),
                width: hasError ? 1.5 : 1.2,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF024D87).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.cake_outlined,
                    size: 18,
                    color: Color(0xFF024D87),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    hasValue ? value : (hint ?? 'Select birth date'),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: hasValue ? FontWeight.w600 : FontWeight.w400,
                      color: hasValue
                          ? const Color(0xFF1A202C)
                          : const Color(0xFFA0AEC0),
                    ),
                  ),
                ),
                if (age != null)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF024D87).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$age yrs',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF024D87),
                      ),
                    ),
                  ),
                const Icon(
                  Icons.calendar_month_rounded,
                  size: 20,
                  color: Color(0xFF024D87),
                ),
              ],
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              errorText!,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: const Color(0xFFE53E3E),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }
}

// ── Dynamic entry card (Education / Experience / etc.) ────────────────────────

class CvEntryCard extends StatelessWidget {
  final int index;
  final String title;
  final VoidCallback onRemove;
  final List<Widget> fields;
  final IconData? icon;

  const CvEntryCard({
    super.key,
    required this.index,
    required this.title,
    required this.onRemove,
    required this.fields,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              border: const Border(
                bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF024D87).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        icon ?? Icons.school_outlined,
                        size: 16,
                        color: const Color(0xFF024D87),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      title,
                      style: GoogleFonts.manrope(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A202C),
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: onRemove,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF5F5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFEB2B2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.delete_outline_rounded,
                          color: Color(0xFFE53E3E),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Remove',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFE53E3E),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: fields,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Add button ────────────────────────────────────────────────────────────────

class CvAddButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const CvAddButton({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFF024D87).withValues(alpha: 0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF024D87).withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Color(0xFF024D87),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.inter(
                color: const Color(0xFF024D87),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Continue button ───────────────────────────────────────────────────────────

class CvNextButton extends StatelessWidget {
  final VoidCallback onNext;
  final String label;

  const CvNextButton({super.key, required this.onNext, this.label = 'Continue'});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onNext,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF024D87),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 2,
          shadowColor: const Color(0xFF024D87).withValues(alpha: 0.35),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_rounded, size: 20),
          ],
        ),
      ),
    );
  }
}
