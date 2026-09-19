import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class WebViewScreen extends StatefulWidget {
  final String url;
  final String title;

  const WebViewScreen({
    super.key,
    required this.url,
    this.title = 'Web View',
  });

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;
  String _currentUrl = '';

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.url;
    _initializeController();
  }

  void _initializeController() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) {
              setState(() {
                _isLoading = true;
                _hasError = false;
              });
            }
          },
          onPageFinished: (_) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onWebResourceError: (_) {
            if (mounted) {
              setState(() {
                _isLoading = false;
                _hasError = true;
              });
            }
          },
          onNavigationRequest: (request) {
            setState(() {
              _currentUrl = request.url;
            });
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF024D87)),
          onPressed: () async {
            if (await _controller.canGoBack()) {
              await _controller.goBack();
            } else {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  Navigator.pop(context);
                }
              });
            }
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: GoogleFonts.manrope(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF191C1D),
              ),
            ),
            if (_currentUrl.isNotEmpty)
              Text(
                _currentUrl,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: const Color(0xFF64748B),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await _controller.reload();
            },
            tooltip: 'Reload',
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF024D87)),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                minHeight: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF024D87)),
              ),
            ),
          if (_hasError)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.wifi_off_rounded, size: 48, color: Color(0xFF94A3B8)),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load page',
                      style: GoogleFonts.manrope(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () async {
                        setState(() {
                          _hasError = false;
                          _isLoading = true;
                        });
                        await _controller.reload();
                      },
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: Text(
                        'Retry',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF024D87),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
