import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/download_service.dart';
import '../../../../core/storage/token_manager.dart';
import '../../../../core/constants.dart';
import '../../../../core/widgets/custom_gradient_header.dart';
import '../../../cv_builder/presentation/screens/pdf_preview_screen.dart';
import '../../../cover_letter/data/cover_letter_pdf_generator.dart';
import '../../../sop/data/sop_pdf_generator.dart';
import '../../../sop/domain/sop_model.dart';
import '../../../professional_email/data/email_pdf_generator.dart';
import '../../../professional_email/domain/email_model.dart';

enum DocType { cv, coverLetter, sop, email }

class UnifiedDocument {
  final String id;
  final DocType type;
  final String title;
  final String subtitle;
  final String? pdfUrl;
  final Map<String, dynamic> raw;
  final DateTime? createdAt;

  const UnifiedDocument({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    this.pdfUrl,
    required this.raw,
    this.createdAt,
  });
}

class MyDocumentsScreen extends StatefulWidget {
  final int initialTabIndex;

  const MyDocumentsScreen({super.key, this.initialTabIndex = 0});

  @override
  State<MyDocumentsScreen> createState() => _MyDocumentsScreenState();
}

class _MyDocumentsScreenState extends State<MyDocumentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String? _errorMessage;

  List<UnifiedDocument> _allDocs = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 5,
      vsync: this,
      initialIndex: widget.initialTabIndex.clamp(0, 4),
    );
    _loadAllDocuments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllDocuments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await AuthService.authenticatedGet('/profile');
      if (response['__status'] == 401) {
        throw 'Session expired. Please log in again.';
      }

      final data = response['data'] as Map<String, dynamic>? ?? response;

      final List<UnifiedDocument> docs = [];

      // 1. CVs
      final cvsRaw = data['cvHistory'] as List<dynamic>? ?? [];
      for (final item in cvsRaw) {
        if (item is Map<String, dynamic>) {
          DateTime? date;
          try {
            if (item['createdAt'] != null) date = DateTime.parse(item['createdAt']);
          } catch (_) {}
          docs.add(UnifiedDocument(
            id: item['id']?.toString() ?? '',
            type: DocType.cv,
            title: item['title']?.toString().isNotEmpty == true
                ? item['title'].toString()
                : 'Curriculum Vitae',
            subtitle: item['templateName']?.toString().isNotEmpty == true
                ? item['templateName'].toString()
                : 'Standard CV',
            pdfUrl: item['pdfUrl']?.toString(),
            raw: item,
            createdAt: date,
          ));
        }
      }

      // 2. Cover Letters
      final clRaw = data['coverLetterHistory'] as List<dynamic>? ?? [];
      for (final item in clRaw) {
        if (item is Map<String, dynamic>) {
          DateTime? date;
          try {
            if (item['createdAt'] != null) date = DateTime.parse(item['createdAt']);
          } catch (_) {}
          docs.add(UnifiedDocument(
            id: item['id']?.toString() ?? '',
            type: DocType.coverLetter,
            title: item['title']?.toString().isNotEmpty == true
                ? item['title'].toString()
                : 'Cover Letter',
            subtitle: 'Professional Letter',
            raw: item,
            createdAt: date,
          ));
        }
      }

      // 3. SOPs
      final sopRaw = data['sopHistory'] as List<dynamic>? ?? [];
      for (final item in sopRaw) {
        if (item is Map<String, dynamic>) {
          DateTime? date;
          try {
            if (item['createdAt'] != null) date = DateTime.parse(item['createdAt']);
          } catch (_) {}
          docs.add(UnifiedDocument(
            id: item['id']?.toString() ?? '',
            type: DocType.sop,
            title: item['title']?.toString().isNotEmpty == true
                ? item['title'].toString()
                : 'Statement of Purpose',
            subtitle: 'Academic Statement',
            raw: item,
            createdAt: date,
          ));
        }
      }

      // 4. Emails
      final emailRaw = data['emailHistory'] as List<dynamic>? ?? [];
      for (final item in emailRaw) {
        if (item is Map<String, dynamic>) {
          DateTime? date;
          try {
            if (item['createdAt'] != null) date = DateTime.parse(item['createdAt']);
          } catch (_) {}
          docs.add(UnifiedDocument(
            id: item['id']?.toString() ?? '',
            type: DocType.email,
            title: item['subject']?.toString().isNotEmpty == true
                ? item['subject'].toString()
                : 'Professional Email',
            subtitle: item['templateId']?.toString().isNotEmpty == true
                ? item['templateId'].toString()
                : 'Standard Email',
            raw: item,
            createdAt: date,
          ));
        }
      }

      // Sort by newest first
      docs.sort((a, b) {
        if (a.createdAt == null) return 1;
        if (b.createdAt == null) return -1;
        return b.createdAt!.compareTo(a.createdAt!);
      });

      setState(() {
        _allDocs = docs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  List<UnifiedDocument> _filterDocs(DocType? type) {
    var list = type == null ? _allDocs : _allDocs.where((d) => d.type == type).toList();
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      list = list.where((d) =>
          d.title.toLowerCase().contains(q) ||
          d.subtitle.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  // ── Preview PDF ───────────────────────────────────────────────────────────

  Future<void> _previewDocument(UnifiedDocument doc) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF024D87)),
      ),
    );

    try {
      late final Uint8List pdfBytes;

      switch (doc.type) {
        case DocType.cv:
          Navigator.pop(context); // close loader
          final token = await TokenManager.getAccessToken() ?? '';
          if (!mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PdfPreviewScreen.fromId(
                cvId: doc.id,
                bearerToken: token,
              ),
            ),
          );
          return;

        case DocType.coverLetter:
          final header = doc.raw['header']?.toString() ?? '';
          final body = doc.raw['body']?.toString() ?? '';
          final footer = doc.raw['footer']?.toString() ?? '';
          pdfBytes = await CoverLetterPdfGenerator().generatePdf(
            header: header,
            body: body,
            footer: footer,
          );
          break;

        case DocType.sop:
          final header = doc.raw['header']?.toString() ?? '';
          final body = doc.raw['body']?.toString() ?? '';
          final footer = doc.raw['footer']?.toString() ?? '';
          final text = '$header\n\n$body\n\n$footer';
          const model = SopModel(
            name: 'Applicant',
            programName: 'Degree',
            universityName: 'University',
            country: 'Abroad',
            templateId: 'classic_academic',
          );
          const template = SopTemplate(
            id: 'classic_academic',
            title: 'Academic SOP',
          );
          pdfBytes = await SopPdfGenerator().generatePdf(model, template, text);
          break;

        case DocType.email:
          final subject = doc.raw['subject']?.toString() ?? 'Professional Email';
          final templateId = doc.raw['templateId']?.toString() ?? 'job_application';
          final body = doc.raw['body']?.toString() ?? '';
          final model = EmailModel(
            emailType: 'Professional Email',
            senderName: '',
            recipientName: '',
            recipientDesignation: '',
            companyName: '',
            subject: subject,
            templateId: templateId,
          );
          pdfBytes = await EmailPdfGenerator().generatePdf(model, body);
          break;
      }

      if (!mounted) return;
      Navigator.pop(context); // close loader

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PdfPreviewScreen.fromBytes(pdfBytes: pdfBytes),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // close loader
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cannot render PDF: $e')),
      );
    }
  }

  // ── Download PDF ──────────────────────────────────────────────────────────

  Future<void> _downloadDocument(UnifiedDocument doc) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Preparing PDF download...'),
        duration: Duration(seconds: 1),
      ),
    );

    try {
      Uint8List? bytes;
      String baseName = 'Document';

      switch (doc.type) {
        case DocType.cv:
          baseName = 'CV_${doc.title.replaceAll(' ', '_')}';
          if (doc.pdfUrl != null && doc.pdfUrl!.isNotEmpty) {
            final savedPath = await DownloadService.downloadAndSaveFile(
              url: doc.pdfUrl,
              baseFileName: baseName,
              fileExtension: 'pdf',
            );
            _notifySaved(savedPath);
            return;
          } else {
            // Fetch directly from server endpoint
            final savedPath = await DownloadService.downloadAndSaveFile(
              url: '${ApiConstants.baseUrl}/cvs/${doc.id}/view',
              baseFileName: baseName,
              fileExtension: 'pdf',
            );
            _notifySaved(savedPath);
            return;
          }

        case DocType.coverLetter:
          baseName = 'CoverLetter_${doc.id.substring(0, doc.id.length.clamp(0, 6))}';
          final header = doc.raw['header']?.toString() ?? '';
          final body = doc.raw['body']?.toString() ?? '';
          final footer = doc.raw['footer']?.toString() ?? '';
          bytes = await CoverLetterPdfGenerator().generatePdf(
            header: header,
            body: body,
            footer: footer,
          );
          break;

        case DocType.sop:
          baseName = 'SOP_${doc.id.substring(0, doc.id.length.clamp(0, 6))}';
          final header = doc.raw['header']?.toString() ?? '';
          final body = doc.raw['body']?.toString() ?? '';
          final footer = doc.raw['footer']?.toString() ?? '';
          final text = '$header\n\n$body\n\n$footer';
          const model = SopModel(
            name: 'Applicant',
            programName: 'Degree',
            universityName: 'University',
            country: 'Abroad',
            templateId: 'classic_academic',
          );
          const template = SopTemplate(
            id: 'classic_academic',
            title: 'Academic SOP',
          );
          bytes = await SopPdfGenerator().generatePdf(model, template, text);
          break;

        case DocType.email:
          baseName = 'Email_${doc.id.substring(0, doc.id.length.clamp(0, 6))}';
          final subject = doc.raw['subject']?.toString() ?? 'Professional Email';
          final templateId = doc.raw['templateId']?.toString() ?? 'job_application';
          final body = doc.raw['body']?.toString() ?? '';
          final model = EmailModel(
            emailType: 'Professional Email',
            senderName: '',
            recipientName: '',
            recipientDesignation: '',
            companyName: '',
            subject: subject,
            templateId: templateId,
          );
          bytes = await EmailPdfGenerator().generatePdf(model, body);
          break;
      }

      final savedPath = await DownloadService.downloadAndSaveFile(
        existingBytes: bytes,
        baseFileName: baseName,
        fileExtension: 'pdf',
      );
      _notifySaved(savedPath);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Download failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _notifySaved(String savedPath) {
    if (!mounted) return;
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
                child: Text('Saved: $savedPath',
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
              } catch (_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cannot open file')),
                );
              }
            },
          ),
          backgroundColor: const Color(0xFF024D87),
          duration: const Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Column(
          children: [
            CustomGradientHeader(
              title: 'Saved Documents',
              subtitle: 'Access and download all your generated PDF files',
              badgeText: '${_allDocs.length} Files',
              onBackPressed: () => Navigator.pop(context),
            ),

            // ── Search & Filter Bar ─────────────────────────────────────────
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      onChanged: (v) => setState(() => _searchQuery = v),
                      style: GoogleFonts.inter(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Search documents by title or keyword...',
                        hintStyle: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF94A3B8)),
                        prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Color(0xFF64748B)),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    labelColor: const Color(0xFF024D87),
                    unselectedLabelColor: const Color(0xFF64748B),
                    indicatorColor: const Color(0xFF024D87),
                    indicatorWeight: 3,
                    labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700),
                    unselectedLabelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
                    tabs: [
                      Tab(text: 'All (${_allDocs.length})'),
                      Tab(text: 'CVs (${_filterDocs(DocType.cv).length})'),
                      Tab(text: 'Cover Letters (${_filterDocs(DocType.coverLetter).length})'),
                      Tab(text: 'SOPs (${_filterDocs(DocType.sop).length})'),
                      Tab(text: 'Emails (${_filterDocs(DocType.email).length})'),
                    ],
                  ),
                ],
              ),
            ),

            // ── Tab Views ───────────────────────────────────────────────────
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                      ? _buildErrorView()
                      : TabBarView(
                          controller: _tabController,
                          children: [
                            _buildDocumentList(null),
                            _buildDocumentList(DocType.cv),
                            _buildDocumentList(DocType.coverLetter),
                            _buildDocumentList(DocType.sop),
                            _buildDocumentList(DocType.email),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 48),
            const SizedBox(height: 12),
            Text(
              'Failed to load documents',
              style: GoogleFonts.manrope(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              _errorMessage ?? 'Network error',
              style: GoogleFonts.inter(fontSize: 13, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadAllDocuments,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF024D87),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentList(DocType? type) {
    final list = _filterDocs(type);

    if (list.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadAllDocuments,
        child: ListView(
          padding: const EdgeInsets.all(32),
          children: [
            const SizedBox(height: 60),
            Icon(Icons.folder_open_rounded, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'No documents found',
                style: GoogleFonts.manrope(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF334155),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Generate a CV, Cover Letter, SOP, or Professional Email to see your saved PDF files here.',
                style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B)),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAllDocuments,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        itemCount: list.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final doc = list[index];
          return _buildDocumentCard(doc);
        },
      ),
    );
  }

  Widget _buildDocumentCard(UnifiedDocument doc) {
    Color typeColor;
    String typeLabel;
    IconData typeIcon;

    switch (doc.type) {
      case DocType.cv:
        typeColor = const Color(0xFF0284C7);
        typeLabel = 'CV';
        typeIcon = Icons.badge_outlined;
        break;
      case DocType.coverLetter:
        typeColor = const Color(0xFF024D87);
        typeLabel = 'Cover Letter';
        typeIcon = Icons.mark_email_read_outlined;
        break;
      case DocType.sop:
        typeColor = const Color(0xFF7C3AED);
        typeLabel = 'SOP';
        typeIcon = Icons.school_outlined;
        break;
      case DocType.email:
        typeColor = const Color(0xFF059669);
        typeLabel = 'Email';
        typeIcon = Icons.alternate_email_rounded;
        break;
    }

    final dateStr = doc.createdAt != null
        ? DateFormat('MMM dd, yyyy • hh:mm a').format(doc.createdAt!.toLocal())
        : 'Saved Document';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Accent Bar ──────────────────────────────────────────────
              Container(width: 5, color: typeColor),

              // ── Info Column ─────────────────────────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: typeColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(typeIcon, size: 12, color: typeColor),
                                const SizedBox(width: 4),
                                Text(
                                  typeLabel,
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: typeColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.picture_as_pdf_rounded, size: 11, color: Color(0xFFEF4444)),
                                const SizedBox(width: 3),
                                Text(
                                  'PDF',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFFEF4444),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        doc.title,
                        style: GoogleFonts.manrope(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        doc.subtitle,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF64748B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.access_time_rounded, size: 12, color: Color(0xFF94A3B8)),
                          const SizedBox(width: 4),
                          Text(
                            dateStr,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // ── Action Buttons ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // View PDF
                    Material(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        onTap: () => _previewDocument(doc),
                        borderRadius: BorderRadius.circular(10),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Icon(Icons.visibility_outlined, size: 20, color: typeColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Download PDF
                    Material(
                      color: typeColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        onTap: () => _downloadDocument(doc),
                        borderRadius: BorderRadius.circular(10),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Icon(Icons.download_rounded, size: 20, color: typeColor),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
