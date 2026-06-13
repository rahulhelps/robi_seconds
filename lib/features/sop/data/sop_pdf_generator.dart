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
      return switch (template.id) {
        'classic_academic'        => await _buildClassicHarvard(sop, generatedText),
        'modern_professional'     => await _buildModernMinimal(sop, generatedText),
        'research_focused'        => await _buildResearchScholar(sop, generatedText),
        'career_change'           => await _buildCreativeModern(sop, generatedText),
        'engineering_tech'        => await _buildTechEngineering(sop, generatedText),
        'business_mba'            => await _buildExecutiveProfessional(sop, generatedText),
        'medical_health'          => await _buildMedicalProfessional(sop, generatedText),
        'arts_humanities'         => await _buildElegantClassic(sop, generatedText),
        'international_student'   => await _buildInternationalGlobal(sop, generatedText),
        'scholarship_application' => await _buildPremiumScholarship(sop, generatedText),
        _                         => await _buildClassicHarvard(sop, generatedText),
      };
    } catch (e) {
      print('[SopPdfGenerator] Error generating PDF: $e');
      rethrow;
    }
  }

  // ── Helper to render the body paragraphs cleanly ───────────────────────────
  List<pw.Widget> _renderBody(String text, pw.TextStyle style) {
    // Splits by double newline to form paragraphs
    final paragraphs = text.split('\n\n');
    return paragraphs.map((p) => pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 12),
      child: pw.Text(p.trim(), style: style, textAlign: pw.TextAlign.justify),
    )).toList();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Template 1 — Classic Harvard Style
  // ═══════════════════════════════════════════════════════════════════════════
  Future<Uint8List> _buildClassicHarvard(SopModel sop, String text) async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(0),
        header: (context) => pw.Column(
          children: [
            pw.Container(
              width: double.infinity,
              color: PdfColor.fromHex('#0D1B2A'),
              padding: const pw.EdgeInsets.symmetric(vertical: 24, horizontal: 40),
              child: pw.Column(
                children: [
                  pw.Text(
                    'STATEMENT OF PURPOSE',
                    style: pw.TextStyle(
                      font: pw.Font.timesBold(),
                      color: PdfColors.white,
                      fontSize: 22,
                      letterSpacing: 2,
                    ),
                  ),
                  pw.SizedBox(height: 6),
                  pw.Text(
                    sop.name.toUpperCase(),
                    style: pw.TextStyle(
                      font: pw.Font.times(),
                      color: PdfColors.white,
                      fontSize: 14,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
            pw.Container(
              width: double.infinity,
              height: 3,
              color: PdfColor.fromHex('#D4A017'),
            ),
          ],
        ),
        build: (context) => [
          pw.Padding(
            padding: const pw.EdgeInsets.all(40),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: _renderBody(
                text,
                pw.TextStyle(font: pw.Font.times(), fontSize: 11, lineSpacing: 4),
              ),
            ),
          ),
        ],
      ),
    );
    return pdf.save();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Template 2 — Modern Minimal
  // ═══════════════════════════════════════════════════════════════════════════
  Future<Uint8List> _buildModernMinimal(SopModel sop, String text) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(0),
        build: (context) => [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Left blue bar
              pw.Container(
                width: 12,
                height: 842, // Approx A4 height
                color: PdfColor.fromHex('#024D87'),
              ),
              pw.Expanded(
                child: pw.Padding(
                  padding: const pw.EdgeInsets.fromLTRB(30, 40, 40, 40),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.only(bottom: 10),
                        decoration: pw.BoxDecoration(
                          border: pw.Border(bottom: pw.BorderSide(color: PdfColor.fromHex('#024D87'), width: 2)),
                        ),
                        child: pw.Text(
                          'STATEMENT OF PURPOSE',
                          style: pw.TextStyle(font: pw.Font.helveticaBold(), fontSize: 24, color: PdfColor.fromHex('#024D87')),
                        ),
                      ),
                      pw.SizedBox(height: 20),
                      ..._renderBody(text, pw.TextStyle(font: pw.Font.helvetica(), fontSize: 11, color: PdfColor.fromHex('#333333'), lineSpacing: 3)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
    return pdf.save();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Template 3 — Research Scholar
  // ═══════════════════════════════════════════════════════════════════════════
  Future<Uint8List> _buildResearchScholar(SopModel sop, String text) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => pw.Column(
          children: [
            pw.Center(
              child: pw.Text(
                'STATEMENT OF PURPOSE',
                style: pw.TextStyle(font: pw.Font.timesBold(), fontSize: 18, color: PdfColor.fromHex('#1E3A8A')),
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Divider(color: PdfColor.fromHex('#1E3A8A'), thickness: 1.5),
            pw.Divider(color: PdfColor.fromHex('#1E3A8A'), thickness: 0.5),
            pw.SizedBox(height: 20),
          ],
        ),
        build: (context) => [
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#E8EDF5'),
              border: pw.Border.all(color: PdfColor.fromHex('#B0BFDB')),
            ),
            child: pw.Text(
              'Prepared by: ${sop.name} | Program: ${sop.programName}',
              style: pw.TextStyle(font: pw.Font.timesItalic(), fontSize: 10),
            ),
          ),
          pw.SizedBox(height: 24),
          ..._renderBody(text, pw.TextStyle(font: pw.Font.times(), fontSize: 11, lineSpacing: 2)),
        ],
      ),
    );
    return pdf.save();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Template 4 — Creative Modern (Career Change)
  // ═══════════════════════════════════════════════════════════════════════════
  Future<Uint8List> _buildCreativeModern(SopModel sop, String text) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(0),
        header: (context) => pw.Column(
          children: [
            pw.Container(
              color: PdfColor.fromHex('#013A65'),
              padding: const pw.EdgeInsets.all(30),
              width: double.infinity,
              child: pw.Text(
                'Statement of Purpose',
                style: pw.TextStyle(font: pw.Font.helveticaBold(), fontSize: 26, color: PdfColors.white),
              ),
            ),
            pw.Container(height: 4, color: PdfColor.fromHex('#51B1E1')),
          ],
        ),
        build: (context) => [
          pw.Padding(
            padding: const pw.EdgeInsets.all(40),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: _renderBody(text, pw.TextStyle(font: pw.Font.helvetica(), fontSize: 11, color: PdfColor.fromHex('#2D3748'), lineSpacing: 4)),
            ),
          ),
        ],
      ),
    );
    return pdf.save();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Template 5 — Tech / Engineering
  // ═══════════════════════════════════════════════════════════════════════════
  Future<Uint8List> _buildTechEngineering(SopModel sop, String text) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(0),
        header: (context) => pw.Container(
          color: PdfColor.fromHex('#F3F4F6'),
          padding: const pw.EdgeInsets.all(30),
          width: double.infinity,
          child: pw.Row(
            children: [
              pw.Container(width: 4, height: 30, color: PdfColor.fromHex('#10B981')),
              pw.SizedBox(width: 12),
              pw.Text(
                'STATEMENT OF PURPOSE',
                style: pw.TextStyle(font: pw.Font.courierBold(), fontSize: 20, color: PdfColor.fromHex('#111827')),
              ),
            ],
          ),
        ),
        build: (context) => [
          pw.Padding(
            padding: const pw.EdgeInsets.all(40),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: _renderBody(text, pw.TextStyle(font: pw.Font.courier(), fontSize: 10, lineSpacing: 4)),
            ),
          ),
        ],
      ),
    );
    return pdf.save();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Template 6 — Executive Professional (Business/MBA)
  // ═══════════════════════════════════════════════════════════════════════════
  Future<Uint8List> _buildExecutiveProfessional(SopModel sop, String text) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(0),
        header: (context) => pw.Container(
          color: PdfColor.fromHex('#2C2C2C'),
          padding: const pw.EdgeInsets.symmetric(vertical: 24, horizontal: 40),
          width: double.infinity,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'STATEMENT OF PURPOSE',
                style: pw.TextStyle(font: pw.Font.timesBold(), fontSize: 22, color: PdfColors.white, letterSpacing: 1.5),
              ),
              pw.SizedBox(height: 12),
              pw.Row(
                children: [
                  pw.Expanded(child: pw.Container(height: 1, color: PdfColors.white)),
                ],
              ),
            ],
          ),
        ),
        build: (context) => [
          pw.Padding(
            padding: const pw.EdgeInsets.all(40),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: _renderBody(text, pw.TextStyle(font: pw.Font.times(), fontSize: 12, lineSpacing: 4)),
            ),
          ),
        ],
      ),
    );
    return pdf.save();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Template 7 — Elegant Classic (Arts)
  // ═══════════════════════════════════════════════════════════════════════════
  Future<Uint8List> _buildElegantClassic(SopModel sop, String text) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => pw.Column(
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Container(width: 40, height: 1.5, color: PdfColor.fromHex('#78350F')),
                pw.Container(width: 40, height: 1.5, color: PdfColor.fromHex('#78350F')),
              ],
            ),
            pw.SizedBox(height: 16),
            pw.Center(
              child: pw.Text(
                'Statement of Purpose',
                style: pw.TextStyle(font: pw.Font.timesBoldItalic(), fontSize: 26, color: PdfColor.fromHex('#78350F')),
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Center(
              child: pw.Container(width: 100, height: 1, color: PdfColor.fromHex('#78350F')),
            ),
            pw.SizedBox(height: 30),
          ],
        ),
        build: (context) => _renderBody(text, pw.TextStyle(font: pw.Font.times(), fontSize: 12, lineSpacing: 5)),
      ),
    );
    return pdf.save();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Template 8 — Medical Professional
  // ═══════════════════════════════════════════════════════════════════════════
  Future<Uint8List> _buildMedicalProfessional(SopModel sop, String text) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(0),
        header: (context) => pw.Column(
          children: [
            pw.Container(height: 8, color: PdfColor.fromHex('#0D9488')),
            pw.Container(
              color: PdfColor.fromHex('#F0FDF4'),
              padding: const pw.EdgeInsets.all(30),
              width: double.infinity,
              child: pw.Text(
                'STATEMENT OF PURPOSE',
                style: pw.TextStyle(font: pw.Font.helveticaBold(), fontSize: 20, color: PdfColor.fromHex('#0D9488')),
              ),
            ),
            pw.Container(height: 2, color: PdfColor.fromHex('#0D9488')),
          ],
        ),
        build: (context) => [
          pw.Padding(
            padding: const pw.EdgeInsets.all(40),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: _renderBody(text, pw.TextStyle(font: pw.Font.helvetica(), fontSize: 11, lineSpacing: 4)),
            ),
          ),
        ],
      ),
    );
    return pdf.save();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Template 9 — International / Global
  // ═══════════════════════════════════════════════════════════════════════════
  Future<Uint8List> _buildInternationalGlobal(SopModel sop, String text) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(0),
        header: (context) => pw.Column(
          children: [
            pw.Row(
              children: [
                pw.Expanded(child: pw.Container(height: 8, color: PdfColor.fromHex('#0369A1'))),
                pw.Expanded(child: pw.Container(height: 8, color: PdfColors.white)),
                pw.Expanded(child: pw.Container(height: 8, color: PdfColor.fromHex('#DC2626'))),
              ],
            ),
            pw.Container(
              color: PdfColor.fromHex('#F0F9FF'),
              padding: const pw.EdgeInsets.symmetric(vertical: 24, horizontal: 40),
              width: double.infinity,
              child: pw.Text(
                'STATEMENT OF PURPOSE',
                style: pw.TextStyle(font: pw.Font.helveticaBold(), fontSize: 22, color: PdfColor.fromHex('#0369A1')),
              ),
            ),
            pw.Container(height: 1, color: PdfColor.fromHex('#0369A1')),
          ],
        ),
        build: (context) => [
          pw.Padding(
            padding: const pw.EdgeInsets.all(40),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: _renderBody(text, pw.TextStyle(font: pw.Font.helvetica(), fontSize: 11, lineSpacing: 3)),
            ),
          ),
        ],
      ),
    );
    return pdf.save();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Template 10 — Premium Scholarship
  // ═══════════════════════════════════════════════════════════════════════════
  Future<Uint8List> _buildPremiumScholarship(SopModel sop, String text) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(0),
        header: (context) => pw.Column(
          children: [
            pw.Container(height: 4, color: PdfColor.fromHex('#D4A017')),
            pw.Container(
              color: PdfColor.fromHex('#0D1B2A'),
              padding: const pw.EdgeInsets.symmetric(vertical: 30, horizontal: 40),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'STATEMENT OF PURPOSE',
                        style: pw.TextStyle(font: pw.Font.timesBold(), fontSize: 22, color: PdfColors.white, letterSpacing: 1.5),
                      ),
                      pw.SizedBox(height: 6),
                      pw.Text(
                        'SCHOLARSHIP APPLICATION',
                        style: pw.TextStyle(font: pw.Font.times(), fontSize: 12, color: PdfColor.fromHex('#D4A017'), letterSpacing: 2),
                      ),
                    ],
                  ),
                  // Decorative emblem circle
                  pw.Container(
                    width: 40,
                    height: 40,
                    decoration: pw.BoxDecoration(
                      shape: pw.BoxShape.circle,
                      border: pw.Border.all(color: PdfColor.fromHex('#D4A017'), width: 2),
                    ),
                  ),
                ],
              ),
            ),
            pw.Container(height: 2, color: PdfColor.fromHex('#D4A017')),
          ],
        ),
        build: (context) => [
          pw.Padding(
            padding: const pw.EdgeInsets.all(40),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: _renderBody(text, pw.TextStyle(font: pw.Font.times(), fontSize: 11, lineSpacing: 4)),
            ),
          ),
        ],
      ),
    );
    return pdf.save();
  }
}
