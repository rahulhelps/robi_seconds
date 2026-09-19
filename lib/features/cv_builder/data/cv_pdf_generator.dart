import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../domain/cv_model.dart';

class CvPdfGenerator {
  Future<Uint8List> generatePdf(
    CvModel cv, {
    String? primaryColorHex,
    String? layout,
  }) async {
    final pdf = pw.Document();

    final primaryColor = (primaryColorHex != null && primaryColorHex.startsWith('#'))
        ? PdfColor.fromHex(primaryColorHex)
        : PdfColor.fromHex('#024D87');
    final textColor = PdfColor.fromHex('#1A1A1A');

    final name = cv.personalInfo.name.trim();
    final email = cv.personalInfo.email.trim();
    final phone = cv.personalInfo.phone.trim();
    final address = cv.personalInfo.address.trim();
    final careerObjective = cv.careerObjective.trim();

    final selectedLayout = layout ?? 'single_column';

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(36),
        ),
        build: (context) {
          if (selectedLayout == 'sidebar_left') {
            return [
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Left sidebar
                  pw.Container(
                    width: 160,
                    padding: const pw.EdgeInsets.only(right: 16),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _contactBox(primaryColor, textColor, email, phone, address),
                        pw.SizedBox(height: 14),
                        _sectionWithString('Skills', _buildSkills(cv.skills), textColor, primaryColor),
                        pw.SizedBox(height: 14),
                        _sectionWithString('Languages', _buildLanguages(cv.languages), textColor, primaryColor),
                      ],
                    ),
                  ),
                  // Right main content
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          name,
                          style: pw.TextStyle(
                            font: pw.Font.helveticaBold(),
                            fontSize: 22,
                            color: primaryColor,
                          ),
                        ),
                        pw.Container(height: 2, color: primaryColor, margin: const pw.EdgeInsets.symmetric(vertical: 8)),
                        if (careerObjective.isNotEmpty) ...[
                          _sectionWithString('Career Objective', careerObjective, textColor, primaryColor),
                          pw.SizedBox(height: 12),
                        ],
                        _sectionWithString('Education', _buildEducation(cv.education), textColor, primaryColor),
                        pw.SizedBox(height: 12),
                        _sectionWithWidgets('Work Experience', _buildWork(cv.workExperience), textColor, primaryColor),
                      ],
                    ),
                  ),
                ],
              ),
            ];
          } else if (selectedLayout == 'two_column') {
            return [
              _header(primaryColor, textColor, name, email, phone, address),
              pw.SizedBox(height: 16),
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Left column (40%)
                  pw.Expanded(
                    flex: 40,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _sectionWithString('Education', _buildEducation(cv.education), textColor, primaryColor),
                        pw.SizedBox(height: 12),
                        _sectionWithString('Skills', _buildSkills(cv.skills), textColor, primaryColor),
                        pw.SizedBox(height: 12),
                        _sectionWithString('Languages', _buildLanguages(cv.languages), textColor, primaryColor),
                      ],
                    ),
                  ),
                  pw.SizedBox(width: 16),
                  // Right column (60%)
                  pw.Expanded(
                    flex: 60,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        if (careerObjective.isNotEmpty) ...[
                          _sectionWithString('Executive Summary', careerObjective, textColor, primaryColor),
                          pw.SizedBox(height: 12),
                        ],
                        _sectionWithWidgets('Work Experience', _buildWork(cv.workExperience), textColor, primaryColor),
                      ],
                    ),
                  ),
                ],
              ),
            ];
          } else {
            // Default single column
            return [
              _header(primaryColor, textColor, name, email, phone, address),
              pw.SizedBox(height: 16),
              if (careerObjective.isNotEmpty)
                _sectionWithString('Career Objective', careerObjective, textColor, primaryColor),
              pw.SizedBox(height: 12),
              _sectionWithString('Education', _buildEducation(cv.education), textColor, primaryColor),
              pw.SizedBox(height: 12),
              _sectionWithString('Skills', _buildSkills(cv.skills), textColor, primaryColor),
              pw.SizedBox(height: 12),
              _sectionWithWidgets('Work Experience', _buildWork(cv.workExperience), textColor, primaryColor),
              pw.SizedBox(height: 12),
              _sectionWithString('Languages', _buildLanguages(cv.languages), textColor, primaryColor),
            ];
          }
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _contactBox(PdfColor primary, PdfColor textColor, String email, String phone, String address) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#F8F9FA'),
        border: pw.Border.all(color: PdfColor.fromHex('#E1E3E4')),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('CONTACT', style: pw.TextStyle(font: pw.Font.helveticaBold(), fontSize: 10, color: primary)),
          pw.SizedBox(height: 4),
          if (email.isNotEmpty) pw.Text(email, style: pw.TextStyle(font: pw.Font.helvetica(), fontSize: 9, color: textColor)),
          if (phone.isNotEmpty) pw.Text(phone, style: pw.TextStyle(font: pw.Font.helvetica(), fontSize: 9, color: textColor)),
          if (address.isNotEmpty) pw.Text(address, style: pw.TextStyle(font: pw.Font.helvetica(), fontSize: 9, color: textColor)),
        ],
      ),
    );
  }

  pw.Widget _header(
    PdfColor primary,
    PdfColor textColor,
    String name,
    String email,
    String phone,
    String address,
  ) {
    final items = <String>[];
    if (email.isNotEmpty) items.add(email);
    if (phone.isNotEmpty) items.add(phone);
    if (address.isNotEmpty) items.add(address);

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          name,
          style: pw.TextStyle(
            font: pw.Font.helveticaBold(),
            fontSize: 24,
            color: primary,
          ),
        ),
        pw.SizedBox(height: 6),
        pw.Text(
          items.join('  |  '),
          style: pw.TextStyle(
            font: pw.Font.helvetica(),
            fontSize: 10,
            color: textColor,
          ),
        ),
      ],
    );
  }

  pw.Widget _sectionWithString(
      String title, String body, PdfColor textColor, PdfColor primaryColor) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            font: pw.Font.helveticaBold(),
            fontSize: 13,
            color: primaryColor,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
            color: PdfColor.fromHex('#F8F9FA'),
            border: pw.Border.all(color: PdfColor.fromHex('#E1E3E4')),
            borderRadius: pw.BorderRadius.circular(6),
          ),
          child: pw.Text(
            body,
            style: pw.TextStyle(
              font: pw.Font.helvetica(),
              fontSize: 11,
              color: textColor,
              lineSpacing: 2,
            ),
          ),
        ),
      ],
    );
  }

  pw.Widget _sectionWithWidgets(String title, List<pw.Widget> children,
      PdfColor textColor, PdfColor primaryColor) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            font: pw.Font.helveticaBold(),
            fontSize: 13,
            color: primaryColor,
          ),
        ),
        pw.SizedBox(height: 4),
        ...children.map((child) => pw.Container(
              width: double.infinity,
              margin: const pw.EdgeInsets.only(bottom: 6),
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#F8F9FA'),
                border: pw.Border.all(color: PdfColor.fromHex('#E1E3E4')),
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: child,
            )),
      ],
    );
  }

  String _buildEducation(List<Education> education) {
    if (education.isEmpty) return 'No education entries added.';
    return education.map((e) {
      final title = e.fieldOfStudy.isNotEmpty ? '${e.degree} - ${e.fieldOfStudy}' : e.degree;
      final instBoard = e.board.isNotEmpty ? '${e.institution} (${e.board} Board)' : e.institution;
      final year = e.passingYear.isNotEmpty ? e.passingYear : e.endDate;
      final yearResult = [
        if (year.isNotEmpty) 'Passing Year: $year',
        if (e.result.isNotEmpty) 'Result: ${e.result}',
      ].join('  |  ');

      final parts = <String>[
        if (title.isNotEmpty) title,
        if (instBoard.isNotEmpty) instBoard,
        if (yearResult.isNotEmpty) yearResult,
      ];

      return parts.join('\n');
    }).join('\n\n');
  }

  String _buildSkills(List<SkillCategory> skills) {
    if (skills.isEmpty) return 'No skills added.';
    return skills.map((s) {
      final items = s.skills.map((sk) => '• $sk').join('\n');
      return '${s.category}\n$items';
    }).join('\n\n');
  }

  List<pw.Widget> _buildWork(List<WorkExperience> experiences) {
    if (experiences.isEmpty) {
      return [
        pw.Text(
          'No work experience added.',
          style: pw.TextStyle(
            font: pw.Font.helvetica(),
            fontSize: 11,
            color: PdfColor.fromHex('#1A1A1A'),
          ),
        ),
      ];
    }
    return experiences.map((e) {
      final lines = <String>[
        e.company,
        if (e.position.isNotEmpty) e.position,
        if (e.startDate.isNotEmpty || e.endDate.isNotEmpty) '${e.startDate}${e.endDate.isNotEmpty ? " - ${e.endDate}" : ""}',
        if (e.description.isNotEmpty) e.description,
        ...e.bullets.map((b) => '• $b'),
      ];
      return pw.Text(
        lines.join('\n'),
        style: pw.TextStyle(
          font: pw.Font.helvetica(),
          fontSize: 11,
          color: PdfColor.fromHex('#1A1A1A'),
          lineSpacing: 2,
        ),
      );
    }).toList();
  }

  String _buildLanguages(List<Language> languages) {
    if (languages.isEmpty) return 'No languages added.';
    return languages.map((l) => '${l.language} — ${l.proficiency}').join('\n');
  }
}
