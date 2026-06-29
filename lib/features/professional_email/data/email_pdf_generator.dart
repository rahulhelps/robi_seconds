import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../domain/email_model.dart';

// ignore_for_file: avoid_print

/// Generates professional PDF email documents for each of the 10 templates.
/// Each template has a unique color scheme, font styling, and layout.
class EmailPdfGenerator {
  // ── Public API ─────────────────────────────────────────────────────────────

  /// Entry point — dispatches to the correct template renderer.
  Future<Uint8List> generatePdf(EmailModel email, String generatedBody) async {
    try {
      return await _buildTemplate(email.templateId ?? 'corporate_formal', email, generatedBody);
    } catch (e) {
      print('[EmailPdfGenerator] Error generating PDF: $e');
      rethrow;
    }
  }

  // ── Body Paragraph Renderer ────────────────────────────────────────────────
  List<pw.Widget> _renderBody(String text, pw.TextStyle style) {
    final paragraphs = text.split('\n\n');
    return paragraphs.map((p) => pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 12),
      child: pw.Text(p.trim(), style: style, textAlign: pw.TextAlign.justify),
    )).toList();
  }

  // ── Helper: formatted today's date ────────────────────────────────────────
  String _formatDate() {
    final now = DateTime.now();
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[now.month - 1]} ${now.day}, ${now.year}';
  }

  // ── Generic Template Builder ───────────────────────────────────────────────
  Future<Uint8List> _buildTemplate(
    String tplId,
    EmailModel email,
    String body,
  ) async {
    final pdf = pw.Document();
    final dateStr = _formatDate();

    // ── Per-template style variables ────────────────────────────────────────
    pw.Font bodyFont = pw.Font.helvetica();
    pw.Font headerFont = pw.Font.helveticaBold();
    double bodyFontSize = 11;
    double headerFontSize = 16;
    PdfColor primaryColor = PdfColor.fromHex('#024D87');
    PdfColor headerBgColor = PdfColor.fromHex('#024D87');
    PdfColor headerTextColor = PdfColors.white;
    PdfColor bodyColor = PdfColor.fromHex('#1A1A1A');
    PdfColor bgColor = PdfColors.white;
    pw.EdgeInsets pageMargin = const pw.EdgeInsets.symmetric(horizontal: 54, vertical: 54);
    pw.BoxBorder? pageBorder;
    bool useSideBySideHeader = false;
    bool useGradientStyle = false;

    switch (tplId) {
      // ── Template 1: Corporate Formal — Navy header, serif font ──────────
      case 'corporate_formal':
        bodyFont = pw.Font.times();
        headerFont = pw.Font.timesBold();
        headerFontSize = 18;
        primaryColor = PdfColor.fromHex('#0D1B2A');
        headerBgColor = PdfColor.fromHex('#0D1B2A');
        break;

      // ── Template 2: Modern Minimal — Clean white, thin accent ───────────
      case 'modern_minimal':
        bodyFontSize = 12;
        headerFont = pw.Font.helveticaBold();
        headerFontSize = 20;
        primaryColor = PdfColor.fromHex('#2563EB');
        headerBgColor = PdfColors.white;
        headerTextColor = PdfColor.fromHex('#2563EB');
        pageBorder = pw.Border(
          top: pw.BorderSide(color: PdfColor.fromHex('#2563EB'), width: 3),
        );
        break;

      // ── Template 3: Executive — Dark charcoal header ─────────────────────
      case 'executive':
        bodyFont = pw.Font.times();
        headerFont = pw.Font.timesBold();
        headerFontSize = 22;
        primaryColor = PdfColor.fromHex('#1C1C1E');
        headerBgColor = PdfColor.fromHex('#1C1C1E');
        useSideBySideHeader = true;
        break;

      // ── Template 4: Creative Professional — Gradient header ──────────────
      case 'creative_professional':
        headerFontSize = 20;
        primaryColor = PdfColor.fromHex('#7C3AED');
        headerBgColor = PdfColor.fromHex('#7C3AED');
        bgColor = PdfColor.fromHex('#FAFAFF');
        useGradientStyle = true;
        break;

      // ── Template 5: Tech Industry — Clean grid, monospace ───────────────
      case 'tech_industry':
        bodyFont = pw.Font.courier();
        headerFont = pw.Font.courierBold();
        headerFontSize = 16;
        primaryColor = PdfColor.fromHex('#10B981');
        headerBgColor = PdfColor.fromHex('#F9FAFB');
        headerTextColor = PdfColor.fromHex('#10B981');
        bgColor = PdfColor.fromHex('#F9FAFB');
        pageBorder = pw.Border.all(color: PdfColor.fromHex('#E5E7EB'));
        break;

      // ── Template 6: Academic/Research — Traditional manuscript ──────────
      case 'academic_research':
        bodyFont = pw.Font.times();
        headerFont = pw.Font.timesBold();
        bodyFontSize = 12;
        headerFontSize = 18;
        primaryColor = PdfColor.fromHex('#1E3A8A');
        headerBgColor = PdfColors.white;
        headerTextColor = PdfColor.fromHex('#1E3A8A');
        pageBorder = pw.Border.all(color: PdfColor.fromHex('#EEEEEE'));
        break;

      // ── Template 7: Startup Friendly — Bold colorful header ──────────────
      case 'startup_friendly':
        headerFontSize = 22;
        primaryColor = PdfColor.fromHex('#F59E0B');
        headerBgColor = PdfColor.fromHex('#111827');
        bgColor = PdfColor.fromHex('#FFFBF0');
        break;

      // ── Template 8: Consulting Firm — Professional grid ──────────────────
      case 'consulting_firm':
        bodyFont = pw.Font.times();
        headerFont = pw.Font.timesBold();
        headerFontSize = 20;
        primaryColor = PdfColor.fromHex('#374151');
        headerBgColor = PdfColor.fromHex('#374151');
        pageBorder = pw.Border(
          left: pw.BorderSide(color: PdfColor.fromHex('#374151'), width: 4),
        );
        break;

      // ── Template 9: Healthcare/Medical — Clinical white, green accent ─────
      case 'healthcare_medical':
        bodyFont = pw.Font.times();
        headerFont = pw.Font.timesBold();
        headerFontSize = 18;
        primaryColor = PdfColor.fromHex('#0D9488');
        headerBgColor = PdfColor.fromHex('#0D9488');
        bgColor = PdfColors.white;
        pageBorder = pw.Border(
          top: pw.BorderSide(color: PdfColor.fromHex('#0D9488'), width: 6),
        );
        break;

      // ── Template 10: Finance/Banking — Premium dark gold ─────────────────
      case 'finance_banking':
        bodyFont = pw.Font.times();
        headerFont = pw.Font.timesBold();
        headerFontSize = 20;
        primaryColor = PdfColor.fromHex('#92400E');
        headerBgColor = PdfColor.fromHex('#1A0A00');
        bgColor = PdfColor.fromHex('#FFFBF5');
        break;

      default:
        break;
    }

    final bodyStyle = pw.TextStyle(
      font: bodyFont,
      fontSize: bodyFontSize,
      color: bodyColor,
      lineSpacing: 4,
    );

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: pageMargin,
          buildBackground: (context) => pw.FullPage(
            ignoreMargins: true,
            child: pw.Container(
              margin: const pw.EdgeInsets.all(20),
              decoration: pw.BoxDecoration(
                color: bgColor,
                border: pageBorder,
              ),
            ),
          ),
        ),
        build: (context) => [
          // ── Header block ──────────────────────────────────────────────────
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(20),
            color: headerBgColor,
            child: useSideBySideHeader
                ? pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            email.senderName,
                            style: pw.TextStyle(
                              font: headerFont,
                              fontSize: headerFontSize,
                              color: headerTextColor,
                            ),
                          ),
                          if (email.senderDesignation != null)
                            pw.Text(
                              email.senderDesignation!,
                              style: pw.TextStyle(
                                font: bodyFont,
                                fontSize: bodyFontSize,
                                color: headerTextColor,
                              ),
                            ),
                          if (email.senderCompany != null)
                            pw.Text(
                              email.senderCompany!,
                              style: pw.TextStyle(
                                font: bodyFont,
                                fontSize: bodyFontSize,
                                color: headerTextColor,
                              ),
                            ),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text(
                            dateStr,
                            style: pw.TextStyle(
                              font: bodyFont,
                              fontSize: bodyFontSize,
                              color: headerTextColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                : pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        email.senderName,
                        style: pw.TextStyle(
                          font: headerFont,
                          fontSize: headerFontSize,
                          color: headerTextColor,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      if (email.senderDesignation != null) ...[
                        pw.SizedBox(height: 4),
                        pw.Text(
                          email.senderDesignation!,
                          style: pw.TextStyle(
                            font: bodyFont,
                            fontSize: bodyFontSize,
                            color: headerTextColor,
                          ),
                        ),
                      ],
                      if (email.senderCompany != null) ...[
                        pw.Text(
                          email.senderCompany!,
                          style: pw.TextStyle(
                            font: bodyFont,
                            fontSize: bodyFontSize,
                            color: headerTextColor,
                          ),
                        ),
                      ],
                    ],
                  ),
          ),

          pw.SizedBox(height: 20),

          // ── Date ──────────────────────────────────────────────────────────
          if (!useSideBySideHeader)
            pw.Text(
              dateStr,
              style: pw.TextStyle(font: bodyFont, fontSize: bodyFontSize, color: bodyColor),
            ),
          pw.SizedBox(height: 16),

          // ── Recipient Info ─────────────────────────────────────────────────
          pw.Text(
            email.recipientName,
            style: pw.TextStyle(font: headerFont, fontSize: bodyFontSize + 1, color: bodyColor),
          ),
          pw.Text(
            email.recipientDesignation,
            style: pw.TextStyle(font: bodyFont, fontSize: bodyFontSize, color: bodyColor),
          ),
          pw.Text(
            email.companyName,
            style: pw.TextStyle(font: bodyFont, fontSize: bodyFontSize, color: bodyColor),
          ),
          pw.SizedBox(height: 20),

          // ── Subject Line ───────────────────────────────────────────────────
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: pw.BoxDecoration(
              color: useGradientStyle
                  ? PdfColor.fromHex('#F3F0FF')
                  : primaryColor.shade(0.9),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
            ),
            child: pw.Text(
              'Re: ${email.subject}',
              style: pw.TextStyle(
                font: headerFont,
                fontSize: bodyFontSize + 1,
                color: useGradientStyle ? primaryColor : PdfColors.white,
              ),
            ),
          ),
          pw.SizedBox(height: 20),

          // ── Salutation ─────────────────────────────────────────────────────
          pw.Text(
            'Dear ${email.recipientName},',
            style: pw.TextStyle(font: bodyFont, fontSize: bodyFontSize, color: bodyColor),
          ),
          pw.SizedBox(height: 12),

          // ── Body ───────────────────────────────────────────────────────────
          ..._renderBody(body, bodyStyle),

          pw.SizedBox(height: 24),

          // ── Closing ────────────────────────────────────────────────────────
          pw.Text(
            'Sincerely,',
            style: pw.TextStyle(font: bodyFont, fontSize: bodyFontSize, color: bodyColor),
          ),
          pw.SizedBox(height: 32),
          pw.Text(
            email.senderName,
            style: pw.TextStyle(
              font: headerFont,
              fontSize: bodyFontSize + 1,
              color: primaryColor,
            ),
          ),
          if (email.senderDesignation != null)
            pw.Text(
              email.senderDesignation!,
              style: pw.TextStyle(font: bodyFont, fontSize: bodyFontSize, color: bodyColor),
            ),
          if (email.senderCompany != null)
            pw.Text(
              email.senderCompany!,
              style: pw.TextStyle(font: bodyFont, fontSize: bodyFontSize, color: bodyColor),
            ),
        ],
      ),
    );

    return pdf.save();
  }
}
