import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Generates high-quality, professional A4 PDF documents for Cover Letters.
class CoverLetterPdfGenerator {
  /// Generate PDF from a CoverLetterModel or SavedCoverLetter
  Future<Uint8List> generatePdf({
    required String header,
    required String body,
    required String footer,
    String title = 'Cover Letter',
    int templateIndex = 0,
  }) async {
    final pdf = pw.Document();

    // Determine template theme accents based on templateIndex
    PdfColor primaryColor;
    PdfColor headerColor;
    pw.Font bodyFont = pw.Font.helvetica();
    pw.Font headerFont = pw.Font.helveticaBold();
    bool useLeftAccentBar = false;
    bool useTopBorder = false;

    switch (templateIndex % 6) {
      case 1: // Modern Corporate
        primaryColor = PdfColor.fromHex('#024D87');
        headerColor = PdfColor.fromHex('#012B4C');
        useLeftAccentBar = true;
        break;
      case 2: // Tech & Developer
        primaryColor = PdfColor.fromHex('#0284C7');
        headerColor = PdfColor.fromHex('#0F172A');
        bodyFont = pw.Font.courier();
        break;
      case 3: // Academic & Research
        primaryColor = PdfColor.fromHex('#4B5563');
        headerColor = PdfColor.fromHex('#1F2937');
        bodyFont = pw.Font.times();
        headerFont = pw.Font.timesBold();
        break;
      case 4: // Executive Leadership
        primaryColor = PdfColor.fromHex('#B45309');
        headerColor = PdfColor.fromHex('#78350F');
        useTopBorder = true;
        break;
      case 5: // Creative & Design
        primaryColor = PdfColor.fromHex('#7C3AED');
        headerColor = PdfColor.fromHex('#4C1D95');
        useLeftAccentBar = true;
        break;
      case 0: // Standard Professional
      default:
        primaryColor = PdfColor.fromHex('#1E293B');
        headerColor = PdfColor.fromHex('#0F172A');
        break;
    }

    final bodyParagraphs = body
        .split('\n\n')
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 48, vertical: 48),
        build: (pw.Context context) {
          return pw.Container(
            decoration: pw.BoxDecoration(
              border: useLeftAccentBar
                  ? pw.Border(left: pw.BorderSide(color: primaryColor, width: 4))
                  : (useTopBorder
                      ? pw.Border(top: pw.BorderSide(color: primaryColor, width: 4))
                      : null),
            ),
            padding: useLeftAccentBar
                ? const pw.EdgeInsets.only(left: 20)
                : (useTopBorder ? const pw.EdgeInsets.only(top: 20) : pw.EdgeInsets.zero),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // ── Document Header (Candidate / Recipient / Date) ───────────
                if (header.trim().isNotEmpty) ...[
                  pw.Text(
                    header.trim(),
                    style: pw.TextStyle(
                      font: headerFont,
                      fontSize: 12,
                      color: headerColor,
                      lineSpacing: 2.0,
                    ),
                  ),
                  pw.SizedBox(height: 16),
                  pw.Divider(color: primaryColor, thickness: 1),
                  pw.SizedBox(height: 18),
                ],

                // ── Cover Letter Body Paragraphs ──────────────────────────────
                ...bodyParagraphs.map((para) {
                  return pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 12),
                    child: pw.Text(
                      para,
                      textAlign: pw.TextAlign.justify,
                      style: pw.TextStyle(
                        font: bodyFont,
                        fontSize: 10.5,
                        color: PdfColor.fromHex('#1E293B'),
                        lineSpacing: 2.5,
                      ),
                    ),
                  );
                }),

                // ── Sign-off & Footer Block ──────────────────────────────────
                if (footer.trim().isNotEmpty) ...[
                  pw.SizedBox(height: 20),
                  pw.Text(
                    footer.trim(),
                    style: pw.TextStyle(
                      font: bodyFont,
                      fontSize: 11,
                      color: headerColor,
                      lineSpacing: 2.0,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }
}
