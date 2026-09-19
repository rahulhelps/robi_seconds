import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_file/open_file.dart';
import '../../../../core/services/download_service.dart';
import '../../domain/sop_model.dart';
import '../bloc/sop_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/sop_pdf_generator.dart';
import '../../../cv_builder/presentation/screens/pdf_preview_screen.dart';

class SopOutputScreen extends StatefulWidget {
  final SavedSop saved;
  final Uint8List? pdfBytes;
  final SopModel? model;
  final String? generatedPayload;

  const SopOutputScreen({super.key, required this.saved, this.pdfBytes, this.model, this.generatedPayload});

  @override
  State<SopOutputScreen> createState() => _SopOutputScreenState();
}

class _SopOutputScreenState extends State<SopOutputScreen> {
  bool _isDownloading = false;
  Uint8List? _cachedPdfBytes;

  String get _fullText =>
      widget.generatedPayload ?? '${widget.saved.header}\n\n${widget.saved.body}\n\n${widget.saved.footer}';

  Future<Uint8List> _getPdfBytes() async {
    if (widget.pdfBytes != null && widget.pdfBytes!.isNotEmpty) {
      return widget.pdfBytes!;
    }
    if (_cachedPdfBytes != null && _cachedPdfBytes!.isNotEmpty) {
      return _cachedPdfBytes!;
    }
    final model = widget.model ??
        const SopModel(
          name: 'Applicant',
          programName: 'Master of Science',
          universityName: 'University',
          country: 'Abroad',
          templateId: 'classic_academic',
        );
    final template = const SopTemplate(
      id: 'classic_academic',
      title: 'Classic Academic',
    );
    final bytes = await SopPdfGenerator().generatePdf(model, template, _fullText);
    _cachedPdfBytes = bytes;
    return bytes;
  }

  Future<void> _previewPdf() async {
    try {
      final bytes = await _getPdfBytes();
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PdfPreviewScreen.fromBytes(pdfBytes: bytes),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cannot render PDF: $e')),
        );
      }
    }
  }

  Future<void> _download() async {
    setState(() => _isDownloading = true);
    try {
      final bytes = await _getPdfBytes();
      final savedPath = await DownloadService.downloadAndSaveFile(
        existingBytes: bytes,
        baseFileName: 'StatementOfPurpose',
        fileExtension: 'pdf',
      );

      debugPrint('[SopOutputScreen] Saved: $savedPath');

      if (mounted) {
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text('Saved to: $savedPath', style: GoogleFonts.inter(color: Colors.white, fontSize: 13)),
              action: SnackBarAction(
                label: 'OPEN',
                textColor: Colors.white,
                onPressed: () {
                  try {
                    OpenFile.open(savedPath);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cannot open file')),
                    );
                  }
                },
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: const Color(0xFF024D87),
              duration: const Duration(seconds: 5),
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: Colors.white, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text('Download failed: $e',
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFFBA1A1A),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
      }
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  void _share() {
    Clipboard.setData(ClipboardData(text: _fullText));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('SOP text copied to clipboard!', style: GoogleFonts.inter(color: Colors.white)),
        backgroundColor: const Color(0xFF024D87),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    TextStyle bodyStyle;
    TextStyle headerStyle;
    TextStyle footerStyle;
    BoxDecoration containerDecoration;
    EdgeInsets padding;

    final tplId = widget.saved.templateId ?? 'classic_academic';

    switch (tplId) {
      case 'classic_academic':
        bodyStyle = GoogleFonts.lora(fontSize: 11, height: 1.8, color: const Color(0xFF1A1A1A));
        headerStyle = GoogleFonts.lora(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A1A));
        footerStyle = GoogleFonts.lora(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.grey);
        containerDecoration = const BoxDecoration(color: Colors.white);
        padding = const EdgeInsets.symmetric(horizontal: 32, vertical: 48);
        break;
      case 'modern_professional':
        bodyStyle = GoogleFonts.inter(fontSize: 12, height: 1.6, color: const Color(0xFF333333));
        headerStyle = GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w800, color: const Color(0xFF024D87));
        footerStyle = GoogleFonts.inter(fontSize: 12, color: Colors.grey);
        containerDecoration = const BoxDecoration(
          color: Colors.white,
          border: Border(left: BorderSide(color: Color(0xFF024D87), width: 4)),
        );
        padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 36);
        break;
      case 'research_focused':
        bodyStyle = GoogleFonts.roboto(fontSize: 11.5, height: 1.7, color: const Color(0xFF222222));
        headerStyle = GoogleFonts.robotoMono(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1E3A8A));
        footerStyle = GoogleFonts.roboto(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.grey);
        containerDecoration = BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade200),
        );
        padding = const EdgeInsets.symmetric(horizontal: 30, vertical: 40);
        break;
      case 'career_change':
        bodyStyle = GoogleFonts.openSans(fontSize: 12, height: 1.65, color: const Color(0xFF333333));
        headerStyle = GoogleFonts.openSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF7C3AED));
        footerStyle = GoogleFonts.openSans(fontSize: 12, color: Colors.grey);
        containerDecoration = BoxDecoration(
          color: const Color(0xFFFAF5FF),
          borderRadius: BorderRadius.circular(8),
        );
        padding = const EdgeInsets.all(28);
        break;
      case 'engineering_tech':
        bodyStyle = GoogleFonts.robotoMono(fontSize: 11, height: 1.6, color: const Color(0xFF111827));
        headerStyle = GoogleFonts.robotoMono(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF10B981));
        footerStyle = GoogleFonts.robotoMono(fontSize: 11, color: Colors.grey);
        containerDecoration = BoxDecoration(
          color: const Color(0xFFF9FAFB),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        );
        padding = const EdgeInsets.all(24);
        break;
      case 'business_mba':
        bodyStyle = GoogleFonts.ptSerif(fontSize: 12, height: 1.75, color: const Color(0xFF1F2937));
        headerStyle = GoogleFonts.cinzel(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF111827));
        footerStyle = GoogleFonts.ptSerif(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey);
        containerDecoration = const BoxDecoration(color: Colors.white);
        padding = const EdgeInsets.symmetric(horizontal: 40, vertical: 60);
        break;
      case 'medical_health':
        bodyStyle = GoogleFonts.playfairDisplay(fontSize: 11.5, height: 1.8, color: const Color(0xFF111827));
        headerStyle = GoogleFonts.playfairDisplay(fontSize: 19, fontWeight: FontWeight.bold, color: const Color(0xFF0D9488));
        footerStyle = GoogleFonts.playfairDisplay(fontSize: 11.5, color: Colors.grey);
        containerDecoration = BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFF0D9488), width: 6)),
        );
        padding = const EdgeInsets.symmetric(horizontal: 32, vertical: 48);
        break;
      case 'arts_humanities':
        bodyStyle = GoogleFonts.ebGaramond(fontSize: 13, height: 1.8, color: const Color(0xFF1C1917));
        headerStyle = GoogleFonts.ebGaramond(fontSize: 22, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: const Color(0xFF78350F));
        footerStyle = GoogleFonts.ebGaramond(fontSize: 13, color: Colors.grey);
        containerDecoration = const BoxDecoration(color: Colors.white);
        padding = const EdgeInsets.symmetric(horizontal: 36, vertical: 54);
        break;
      case 'international_student':
        bodyStyle = GoogleFonts.openSans(fontSize: 12, height: 1.6, color: const Color(0xFF1F2937));
        headerStyle = GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0369A1));
        footerStyle = GoogleFonts.openSans(fontSize: 12, color: Colors.grey);
        containerDecoration = BoxDecoration(
          color: const Color(0xFFF0F9FF),
          borderRadius: BorderRadius.circular(12),
        );
        padding = const EdgeInsets.symmetric(horizontal: 28, vertical: 42);
        break;
      case 'scholarship_application':
        bodyStyle = GoogleFonts.lora(fontSize: 11.5, height: 1.75, color: const Color(0xFF111827));
        headerStyle = GoogleFonts.manrope(fontSize: 19, fontWeight: FontWeight.bold, color: const Color(0xFF0F766E));
        footerStyle = GoogleFonts.lora(fontSize: 11.5, color: Colors.grey);
        containerDecoration = BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFF0F766E), width: 1.5),
        );
        padding = const EdgeInsets.symmetric(horizontal: 32, vertical: 48);
        break;
      default:
        bodyStyle = GoogleFonts.inter(fontSize: 12, height: 1.7, color: const Color(0xFF1A1A1A));
        headerStyle = GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A1A));
        footerStyle = GoogleFonts.inter(fontSize: 12, color: Colors.grey);
        containerDecoration = const BoxDecoration(color: Colors.white);
        padding = const EdgeInsets.symmetric(horizontal: 32, vertical: 48);
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: const Color(0xFF191C1D),
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          ),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Statement of Purpose',
            style: GoogleFonts.manrope(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          actions: [
            IconButton(
              tooltip: 'Share / Copy',
              icon: const Icon(Icons.share_rounded, color: Colors.white),
              onPressed: _share,
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                tooltip: 'Download PDF',
                icon: _isDownloading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                      )
                    : const Icon(Icons.download_rounded, color: Colors.white),
                onPressed: _isDownloading ? null : _download,
              ),
            ),
          ],
        ),
        body: InteractiveViewer(
          boundaryMargin: const EdgeInsets.all(20),
          minScale: 0.5,
          maxScale: 3.0,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
            child: Center(
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 800),
                decoration: containerDecoration.copyWith(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: padding,
                child: BlocBuilder<SopBloc, SopState>(
                  builder: (context, state) {
                    final currentModel = widget.model ?? 
                        (state is SopSuccess ? state.model : null) ?? 
                        const SopModel(name: '', programName: '', universityName: '', country: '');
                    
                    final hasBackendText = widget.saved.header.isNotEmpty || widget.saved.body.isNotEmpty;

                    final String displayHeader = hasBackendText ? widget.saved.header : 'Statement of Purpose';
                    final String displayFooter = hasBackendText ? widget.saved.footer : 'Sincerely,\n${currentModel.name}';
                    
                    String displayBody = widget.saved.body;
                    if (!hasBackendText) {
                      displayBody = '''I am writing to express my profound interest in the ${currentModel.programName} program at ${currentModel.universityName}, ${currentModel.country}. With a strong academic foundation and a clear vision for my future, I am confident that this program aligns perfectly with my career aspirations.

${currentModel.academicBackground != null ? 'My academic journey in ${currentModel.academicBackground} ' : 'My academic journey '}${currentModel.gpa != null ? 'with a GPA of ${currentModel.gpa} ' : ''}has equipped me with the analytical and technical skills necessary to thrive in a rigorous academic environment. 

${currentModel.workExperience != null ? 'Professionally, my experience in ${currentModel.workExperience} has further solidified my practical understanding and ability to apply theoretical concepts to real-world challenges. ' : ''}${currentModel.researchExperience != null ? 'Additionally, my research on ${currentModel.researchExperience} highlights my commitment to advancing knowledge in this field. ' : ''}

${currentModel.whyThisUniversity != null ? 'I chose ${currentModel.universityName} because of ${currentModel.whyThisUniversity}. ' : 'The esteemed faculty, state-of-the-art facilities, and diverse community at ${currentModel.universityName} make it the ideal place for me to pursue my studies. '}

Upon completing the ${currentModel.programName} program, my goal is to ${currentModel.goals ?? 'contribute meaningfully to the industry and society'}. ${currentModel.skills != null ? 'My proficiency in ${currentModel.skills} will be instrumental in achieving these objectives. ' : ''}

I look forward to the opportunity to contribute to and grow within your esteemed institution.''';
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SelectableText(
                          displayHeader,
                          style: headerStyle,
                        ),
                        const SizedBox(height: 32),
                        SelectableText(
                          displayBody,
                          style: bodyStyle,
                          textAlign: TextAlign.justify,
                        ),
                        const SizedBox(height: 32),
                        SelectableText(
                          displayFooter,
                          style: footerStyle,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _previewPdf,
                    icon: const Icon(Icons.visibility_outlined, size: 18),
                    label: Text('Preview PDF', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF024D87),
                      side: const BorderSide(color: Color(0xFF024D87)),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isDownloading ? null : _download,
                    icon: _isDownloading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.picture_as_pdf_rounded, size: 18),
                    label: Text(
                      _isDownloading ? 'Saving…' : 'Download PDF',
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF024D87),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFF024D87).withValues(alpha: 0.5),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
