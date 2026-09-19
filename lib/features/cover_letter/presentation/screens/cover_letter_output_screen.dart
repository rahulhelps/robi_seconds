
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_file/open_file.dart';
import '../../../../core/services/download_service.dart';
import '../../domain/cover_letter_model.dart';
import '../../data/cover_letter_pdf_generator.dart';
import '../../../cv_builder/presentation/screens/pdf_preview_screen.dart';

/// Displays the saved cover letter and allows the user to download it as a
/// professional PDF file.
class CoverLetterOutputScreen extends StatefulWidget {
  final SavedCoverLetter saved;
  final int templateIndex;

  const CoverLetterOutputScreen({
    super.key,
    required this.saved,
    this.templateIndex = 0,
  });

  @override
  State<CoverLetterOutputScreen> createState() =>
      _CoverLetterOutputScreenState();
}

class _CoverLetterOutputScreenState extends State<CoverLetterOutputScreen> {
  bool _isDownloading = false;
  Uint8List? _cachedPdfBytes;

  Future<Uint8List> _getPdfBytes() async {
    if (_cachedPdfBytes != null && _cachedPdfBytes!.isNotEmpty) {
      return _cachedPdfBytes!;
    }
    final bytes = await CoverLetterPdfGenerator().generatePdf(
      header: widget.saved.header,
      body: widget.saved.body,
      footer: widget.saved.footer,
      templateIndex: widget.templateIndex,
    );
    _cachedPdfBytes = bytes;
    return bytes;
  }

  // ── Download PDF ──────────────────────────────────────────────────────────

  Future<void> _download() async {
    setState(() => _isDownloading = true);
    try {
      final bytes = await _getPdfBytes();
      final savedPath = await DownloadService.downloadAndSaveFile(
        existingBytes: bytes,
        baseFileName: 'CoverLetter',
        fileExtension: 'pdf',
      );

      if (mounted) {
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.picture_as_pdf_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text('PDF saved: $savedPath',
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
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

  // ── UI ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
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
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Cover Letter',
          style: GoogleFonts.manrope(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              tooltip: 'Download',
              icon: _isDownloading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: Colors.white),
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
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Header ---
                  SelectableText(
                    widget.saved.header,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF333333),
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // --- Body ---
                  SelectableText(
                    widget.saved.body,
                    style: GoogleFonts.merriweather(
                      fontSize: 11,
                      color: const Color(0xFF1A1A1A),
                      height: 1.8,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 32),
                  // --- Footer ---
                  SelectableText(
                    widget.saved.footer,
                    style: GoogleFonts.merriweather(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF1A1A1A),
                      height: 1.6,
                    ),
                  ),
                ],
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
                  label: Text('Preview PDF',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF024D87),
                    side: const BorderSide(color: Color(0xFF024D87)),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
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
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.picture_as_pdf_rounded, size: 18),
                  label: Text(
                    _isDownloading ? 'Saving…' : 'Download PDF',
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF024D87),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        const Color(0xFF024D87).withValues(alpha: 0.5),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
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

