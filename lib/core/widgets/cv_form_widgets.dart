import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Step header ───────────────────────────────────────────────────────────────

class CvStepHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const CvStepHeader({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.manrope(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF191C1D),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style:
              GoogleFonts.inter(fontSize: 15, color: const Color(0xFF3E4A3C)),
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

  const CvTextField({
    super.key,
    required this.label,
    this.hint,
    this.maxLines = 1,
    required this.onChanged,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
            color: const Color(0xFF3E4A3C),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          maxLines: maxLines,
          style: GoogleFonts.inter(color: const Color(0xFF191C1D)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(color: Colors.grey),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFBDCAB9)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF024D87), width: 2),
            ),
            contentPadding: const EdgeInsets.all(14),
            errorText: errorText,
          ),
          onChanged: onChanged,
        ),
        const SizedBox(height: 14),
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

  const CvEntryCard({
    super.key,
    required this.index,
    required this.title,
    required this.onRemove,
    required this.fields,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE1E3E4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF191C1D),
                ),
              ),
              InkWell(
                onTap: onRemove,
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.delete_outline,
                      color: Color(0xFFBA1A1A), size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...fields,
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
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.add, color: Color(0xFF024D87)),
      label: Text(
        label,
        style: GoogleFonts.inter(
          color: const Color(0xFF024D87),
          fontWeight: FontWeight.w600,
        ),
      ),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Color(0xFF024D87)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// ── Continue button ───────────────────────────────────────────────────────────

class CvNextButton extends StatelessWidget {
  final VoidCallback onNext;

  const CvNextButton({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onNext,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF024D87),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: Text(
          'Continue',
          style:
              GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

// ── Dropdown field (enum-constrained) ─────────────────────────────────────────

/// Use this instead of [CvTextField] whenever the backend enforces an enum.
/// [options] must match the exact strings the server accepts.
class CvDropdownField extends StatelessWidget {
  final String label;
  final String value;
  final List<String> options;
  final void Function(String?) onChanged;

  const CvDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
            color: const Color(0xFF3E4A3C),
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: value,
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFBDCAB9)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF024D87), width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFBDCAB9)),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          ),
          style: GoogleFonts.inter(
            color: const Color(0xFF191C1D),
            fontSize: 14,
          ),
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF3E4A3C)),
          dropdownColor: Colors.white,
          items: options
              .map(
                (opt) => DropdownMenuItem(
                  value: opt,
                  child: Text(opt,
                      style: GoogleFonts.inter(
                        color: const Color(0xFF191C1D),
                        fontSize: 14,
                      )),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 14),
      ],
    );
  }
}

