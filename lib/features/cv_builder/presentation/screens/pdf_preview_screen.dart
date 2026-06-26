import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_file/open_file.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../../../core/constants.dart';
import '../../../../core/services/auth_service.dart';
import '../bloc/download_bloc.dart';

/// Displays a CV PDF.
///
/// Two modes:
/// 1. **DB-based** (recommended): pass [cvId] + [bearerToken].
///    Uses [SfPdfViewer.network] with `Authorization: Bearer <token>` header.
///    URL: http://147.93.29.196:5000/api/v1/cvs/{id}/view
///
/// 2. **Legacy / generate flow**: pass [pdfUrl] only (no [cvId]).
///    Downloads bytes via the `http` package then uses [SfPdfViewer.memory].
///    This keeps backward compatibility with the existing CV-builder flow.
class PdfPreviewScreen extends StatefulWidget {
  /// The direct PDF download URL (legacy mode, set when cvId is null).
  final String? pdfUrl;

  /// The CV id used to build the authenticated streaming URL (DB mode).
  final String? cvId;

  /// Bearer token injected into [SfPdfViewer.network] headers (DB mode).
  final String? bearerToken;

  const PdfPreviewScreen({
    super.key,
    this.pdfUrl,
    this.cvId,
    this.bearerToken,
  }) : assert(
          pdfUrl != null || cvId != null,
          'Provide either pdfUrl (legacy) or cvId (DB mode)',
        );

  /// Convenience constructor for the DB-based view mode.
  const PdfPreviewScreen.fromId({
    super.key,
    required String cvId,
    required String bearerToken,
  })  : cvId = cvId,
        bearerToken = bearerToken,
        pdfUrl = null;

  /// Convenience constructor for the legacy generate flow.
  const PdfPreviewScreen.fromUrl({
    super.key,
    required String pdfUrl,
  })  : pdfUrl = pdfUrl,
        cvId = null,
        bearerToken = null;

  @override
  State<PdfPreviewScreen> createState() => _PdfPreviewScreenState();
}

class _PdfPreviewScreenState extends State<PdfPreviewScreen> {
  // ── Constants ──────────────────────────────────────────────────────────────

  static const _serverBase = ApiConstants.baseUrl;

  // ── State ──────────────────────────────────────────────────────────────────

  final PdfViewerController _pdfController = PdfViewerController();

  /// Only used in legacy mode — raw bytes fed to [SfPdfViewer.memory].
  Uint8List? _pdfBytes;
  bool _isLoadingPdf = true;
  String? _loadError;

  // ── Derived helpers ────────────────────────────────────────────────────────

  bool get _isDbMode => widget.cvId != null;

  String get _networkUrl =>
      '$_serverBase/cvs/${widget.cvId}/view';

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    if (_isDbMode) {
      // The render is queued async on the server; the first view can return
      // 409 ("still being generated"). Fetch bytes with a short retry, then
      // render via SfPdfViewer.memory (same path as legacy mode).
      _loadDbPdfWithRetry();
    } else {
      _loadPdfBytes();
    }
  }

  // ── Fetch PDF bytes (DB mode, retry while the render is in progress) ───────

  Future<void> _loadDbPdfWithRetry() async {
    if (!mounted) return;
    setState(() {
      _isLoadingPdf = true;
      _loadError = null;
      _pdfBytes = null;
    });

    const maxAttempts = 6;
    const retryDelay = Duration(milliseconds: 1500);

    try {
      for (var attempt = 1; attempt <= maxAttempts; attempt++) {
        final response = await AuthService.authenticatedGetRaw(_networkUrl);
        print('[PdfPreviewScreen] DB view attempt $attempt → ${response.statusCode}');

        if (response.statusCode == 200) {
          final bytes = response.bodyBytes;
          if (bytes.length < 4 ||
              String.fromCharCodes(bytes.sublist(0, 4)) != '%PDF') {
            throw 'Response is not a valid PDF file.';
          }
          if (mounted) {
            setState(() {
              _pdfBytes = bytes;
              _isLoadingPdf = false;
            });
          }
          return;
        }

        // 409 = still rendering → back off and retry. Anything else is fatal.
        if (response.statusCode == 409 && attempt < maxAttempts) {
          await Future.delayed(retryDelay);
          continue;
        }
        throw 'Server returned ${response.statusCode}.';
      }
      throw 'Your CV is taking longer than expected to generate. Please try again in a moment.';
    } catch (e) {
      print('[PdfPreviewScreen] DB view ERROR: $e');
      if (mounted) {
        setState(() {
          _loadError = e.toString();
          _isLoadingPdf = false;
        });
      }
    }
  }

  // ── Fetch PDF bytes (legacy mode) ──────────────────────────────────────────

  Future<void> _loadPdfBytes() async {
    if (!mounted) return;
    setState(() {
      _isLoadingPdf = true;
      _loadError = null;
      _pdfBytes = null;
    });

    final url = widget.pdfUrl!;
    print('[PdfPreviewScreen] Fetching (legacy): $url');

    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 30));

      print('[PdfPreviewScreen] Status: ${response.statusCode}');

      if (response.statusCode != 200) {
        throw 'Server returned ${response.statusCode}. Check backend.';
      }
      if (response.bodyBytes.isEmpty) {
        throw 'Downloaded file is empty — check the backend URL.';
      }

      // Verify PDF magic bytes (%PDF-)
      final magic = response.bodyBytes.sublist(0, 4);
      if (String.fromCharCodes(magic) != '%PDF') {
        throw 'Response is not a valid PDF file.\n'
            'Content-Type: ${response.headers['content-type']}\n'
            'URL: $url';
      }

      if (mounted) {
        setState(() {
          _pdfBytes = response.bodyBytes;
          _isLoadingPdf = false;
        });
      }
    } catch (e) {
      print('[PdfPreviewScreen] ERROR: $e');
      if (mounted) {
        setState(() {
          _loadError = e.toString();
          _isLoadingPdf = false;
        });
      }
    }
  }

  // ── UI ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DownloadBloc(),
      child: BlocConsumer<DownloadBloc, DownloadState>(
        listener: (context, state) {
          if (state is DownloadSuccess) {
            HapticFeedback.mediumImpact();
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text('Saved to: ${state.path}'),
                  action: SnackBarAction(
                    label: 'OPEN',
                    textColor: Colors.white,
                    onPressed: () {
                      try {
                        OpenFile.open(state.path);
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
                ),
              );
          } else if (state is DownloadError) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: const Color(0xFFBA1A1A),
                  behavior: SnackBarBehavior.floating,
                ),
              );
          }
        },
        builder: (context, state) {
          final isDownloading = state is DownloadLoading;

          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.dark,
              statusBarBrightness: Brightness.light,
            ),
            child: Scaffold(
              backgroundColor: const Color(0xFFF0F2F5),
            appBar: _buildAppBar(isDownloading, context),
            body: _buildBody(),
            bottomNavigationBar: _buildBottomBar(isDownloading, context),
          ),
          );
        },
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────────

  AppBar _buildAppBar(bool isDownloading, BuildContext outContext) {
    return AppBar(
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
        'Your CV',
        style: GoogleFonts.manrope(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
      actions: [
        if (!_isLoadingPdf && _loadError == null)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              tooltip: 'Download PDF',
              icon: isDownloading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: Colors.white),
                    )
                  : const Icon(Icons.download_rounded, color: Colors.white),
              onPressed: isDownloading ? null : () {
                 outContext.read<DownloadBloc>().add(
                    StartDownload(
                      existingBytes: _pdfBytes,
                      networkUrl: _isDbMode ? _networkUrl : null,
                      bearerToken: widget.bearerToken,
                    ),
                 );
              },
            ),
          ),
      ],
    );
  }

  // ── Body ──────────────────────────────────────────────────────────────────

  Widget _buildBody() {
    if (_loadError != null) {
      return _ErrorView(
        message: _loadError!,
        onRetry: () {
          setState(() {
            _loadError = null;
            _isLoadingPdf = true;
          });
          if (!_isDbMode) _loadPdfBytes();
        },
        onBack: () => Navigator.pop(context),
      );
    }

    // ── Both modes render downloaded bytes via SfPdfViewer.memory ────────────
    // DB mode fetches with retry (handles async-render 409s); legacy mode
    // downloads directly. Either way the bytes land in [_pdfBytes].
    return Stack(
      children: [
        if (_pdfBytes != null)
          SfPdfViewer.memory(
            _pdfBytes!,
            controller: _pdfController,
            enableTextSelection: true,
            pageSpacing: 4,
            canShowScrollHead: true,
            canShowScrollStatus: true,
            canShowPaginationDialog: true,
            onDocumentLoaded: (details) {
              print('[PdfPreviewScreen] Rendered ${details.document.pages.count} pages ✅');
              if (mounted) setState(() => _isLoadingPdf = false);
            },
            onDocumentLoadFailed: (details) {
              print('[PdfPreviewScreen] Render error: ${details.error}');
              if (mounted) {
                setState(() {
                  _loadError = details.description;
                  _isLoadingPdf = false;
                });
              }
            },
          ),
        if (_isLoadingPdf)
          const Center(
            child: CircularProgressIndicator(color: Color(0xFF024D87)),
          ),
      ],
    );
  }

  // ── Bottom bar ────────────────────────────────────────────────────────────

  Widget _buildBottomBar(bool isDownloading, BuildContext outContext) {
    return SafeArea(
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
                onPressed: () => Navigator.popUntil(
                  context,
                  ModalRoute.withName('/dashboard'),
                ),
                icon: const Icon(Icons.dashboard_outlined, size: 18),
                label: Text('Dashboard',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF191C1D),
                  side: const BorderSide(color: Color(0xFFD8DDD8)),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed:
                    (isDownloading || (!_isDbMode && _pdfBytes == null))
                        ? null
                        : () {
                           outContext.read<DownloadBloc>().add(
                              StartDownload(
                                existingBytes: _pdfBytes,
                                networkUrl: _isDbMode ? _networkUrl : null,
                                bearerToken: widget.bearerToken,
                              ),
                           );
                        },
                icon: isDownloading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.download_rounded, size: 18),
                label: Text(
                  isDownloading ? 'Saving…' : 'Download',
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
    );
  }
}

// ── Error view ────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final VoidCallback onBack;

  const _ErrorView({
    required this.message,
    required this.onRetry,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFFFEDED),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.picture_as_pdf_outlined,
                  color: Color(0xFFBA1A1A), size: 36),
            ),
            const SizedBox(height: 20),
            Text(
              'Unable to Load PDF',
              style: GoogleFonts.manrope(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF191C1D),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: const Color(0xFF6B7A6B),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onBack,
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 14),
                    label: Text('Go Back',
                        style:
                            GoogleFonts.inter(fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF191C1D),
                      side: const BorderSide(color: Color(0xFFD8DDD8)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: Text('Retry',
                        style:
                            GoogleFonts.inter(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF024D87),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
