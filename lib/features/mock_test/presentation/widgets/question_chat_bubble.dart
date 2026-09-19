import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QuestionChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  final bool showOptions;
  final List<String>? options;
  final int? selectedIndex;
  final int? correctIndex;
  final VoidCallback? onOptionSelected;

  const QuestionChatBubble({
    super.key,
    required this.text,
    required this.isUser,
    this.showOptions = false,
    this.options,
    this.selectedIndex,
    this.correctIndex,
    this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = isUser;
    final bgColor = isDark ? const Color(0xFF024D87) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF191C1D);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20).copyWith(
            bottomRight: isDark ? const Radius.circular(4) : const Radius.circular(20),
            bottomLeft: isDark ? const Radius.circular(20) : const Radius.circular(4),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: textColor,
                height: 1.4,
              ),
            ),
            if (showOptions == true && options != null) ...[
              const SizedBox(height: 12),
              ...List.generate(options!.length, (index) {
                final isSelected = selectedIndex == index;
                final isCorrectOption = correctIndex == index;
                Color optionColor = Colors.white;
                if (selectedIndex != null && correctIndex != null) {
                  if (isSelected && !isCorrectOption) {
                    optionColor = Colors.redAccent;
                  } else if (isCorrectOption) {
                    optionColor = Colors.green;
                  }
                }

                return GestureDetector(
                  onTap: onOptionSelected != null && selectedIndex == null
                      ? () => onOptionSelected!()
                      : null,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? optionColor : (isDark ? Colors.white24 : const Color(0xFFF0F2F1)),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? optionColor
                            : (isDark ? Colors.white30 : const Color(0xFFE5E7E6)),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            options![index],
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: textColor,
                            ),
                          ),
                        ),
                        if (selectedIndex != null && correctIndex != null)
                          Icon(
                            isCorrectOption ? Icons.check_circle : Icons.cancel,
                            size: 18,
                            color: optionColor,
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}
