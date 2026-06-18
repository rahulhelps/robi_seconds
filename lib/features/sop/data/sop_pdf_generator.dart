import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../domain/sop_model.dart';

// ignore_for_file: avoid_print

/// Generates professional PDF documents for each SOP template using package:pdf.
/// Each template has its own unique layout, color scheme, fonts, and section headers.
class SopPdfGenerator {
  // ── Public API ─────────────────────────────────────────────────────────────

  /// Entry point — dispatches to the correct template renderer.
  Future<Uint8List> generatePdf(SopModel sop, SopTemplate template, String generatedText) async {
    try {
      return await _buildGenericTemplate(template.id, sop, generatedText);
    } catch (e) {
      print('[SopPdfGenerator] Error generating PDF: $e');
      rethrow;
    }
  }

  // ── Helper to render the body paragraphs cleanly ───────────────────────────
  List<pw.Widget> _renderBody(String text, pw.TextStyle style) {
    final paragraphs = text.split('\n\n');
    return paragraphs.map((p) => pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 12),
      child: pw.Text(p.trim(), style: style, textAlign: pw.TextAlign.justify),
    )).toList();
  }

  // ── Generic Template Builder matching SopOutputScreen styles ───────────────
  Future<Uint8List> _buildGenericTemplate(String tplId, SopModel sop, String text) async {
    final pdf = pw.Document();

    pw.Font bodyFont = pw.Font.helvetica();
    pw.Font headerFont = pw.Font.helveticaBold();
    double bodyFontSize = 11;
    double headerFontSize = 18;
    PdfColor bodyColor = PdfColor.fromHex('#1A1A1A');
    PdfColor headerColor = PdfColor.fromHex('#1A1A1A');
    PdfColor footerColor = PdfColors.grey;
    PdfColor bgColor = PdfColors.white;
    pw.BoxBorder? border;
    pw.EdgeInsets margin = const pw.EdgeInsets.symmetric(horizontal: 54, vertical: 54);
    bool isItalicHeader = false;

    switch (tplId) {
      case 'classic_academic':
        bodyFont = pw.Font.times();
        headerFont = pw.Font.timesBold();
        break;
      case 'modern_professional':
        bodyFontSize = 12;
        headerFont = pw.Font.helveticaBold();
        headerFontSize = 20;
        headerColor = PdfColor.fromHex('#024D87');
        border = pw.Border(left: pw.BorderSide(color: PdfColor.fromHex('#024D87'), width: 4));
        break;
      case 'research_focused':
        bodyFont = pw.Font.courier();
        headerFont = pw.Font.courierBold();
        headerFontSize = 16;
        headerColor = PdfColor.fromHex('#1E3A8A');
        border = pw.Border.all(color: PdfColor.fromHex('#EEEEEE'));
        break;
      case 'career_change':
        bodyFontSize = 12;
        headerColor = PdfColor.fromHex('#7C3AED');
        bgColor = PdfColor.fromHex('#FAF5FF');
        break;
      case 'engineering_tech':
        bodyFont = pw.Font.courier();
        headerFont = pw.Font.courierBold();
        headerFontSize = 15;
        headerColor = PdfColor.fromHex('#10B981');
        bgColor = PdfColor.fromHex('#F9FAFB');
        border = pw.Border.all(color: PdfColor.fromHex('#E5E7EB'));
        break;
      case 'business_mba':
        bodyFont = pw.Font.times();
        headerFont = pw.Font.timesBold();
        headerFontSize = 20;
        headerColor = PdfColor.fromHex('#111827');
        margin = const pw.EdgeInsets.symmetric(horizontal: 54, vertical: 64);
        break;
      case 'medical_health':
        bodyFont = pw.Font.times();
        headerFont = pw.Font.timesBold();
        headerFontSize = 19;
        headerColor = PdfColor.fromHex('#0D9488');
        border = pw.Border(top: pw.BorderSide(color: PdfColor.fromHex('#0D9488'), width: 6));
        break;
      case 'arts_humanities':
        bodyFont = pw.Font.times();
        headerFont = pw.Font.timesBoldItalic();
        headerFontSize = 22;
        headerColor = PdfColor.fromHex('#78350F');
        isItalicHeader = true;
        break;
      case 'international_student':
        bodyFontSize = 12;
        headerFontSize = 18;
        headerColor = PdfColor.fromHex('#0369A1');
        bgColor = PdfColor.fromHex('#F0F9FF');
        break;
      case 'scholarship_application':
        bodyFont = pw.Font.times();
        headerFont = pw.Font.timesBold();
        headerFontSize = 19;
        headerColor = PdfColor.fromHex('#0F766E');
        border = pw.Border.all(color: PdfColor.fromHex('#0F766E'), width: 1.5);
        break;
      default:
        break;
    }

    final headerText = 'Statement of Purpose';
    final footerText = 'Sincerely,\n${sop.name}';

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: margin,
          buildBackground: (context) => pw.FullPage(
            ignoreMargins: true,
            child: pw.Container(
              margin: const pw.EdgeInsets.all(20), // Outer paper margin
              decoration: pw.BoxDecoration(
                color: bgColor,
                border: border,
              ),
            ),
          ),
        ),
        build: (context) => [
          pw.Text(
            headerText,
            style: pw.TextStyle(
              font: headerFont,
              fontSize: headerFontSize,
              color: headerColor,
              fontWeight: isItalicHeader ? null : pw.FontWeight.bold,
              fontStyle: isItalicHeader ? pw.FontStyle.italic : null,
            ),
          ),
          pw.SizedBox(height: 32),
          ..._renderBody(text, pw.TextStyle(font: bodyFont, fontSize: bodyFontSize, color: bodyColor, lineSpacing: 4)),
          pw.SizedBox(height: 32),
          pw.Text(
            footerText,
            style: pw.TextStyle(
              font: bodyFont,
              fontSize: bodyFontSize,
              color: footerColor,
              fontStyle: pw.FontStyle.italic,
            ),
          ),
        ],
      ),
    );

    return pdf.save();
  }
}
