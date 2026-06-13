import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/cover_letter_repository.dart';
import '../bloc/cover_letter_bloc.dart';
import 'cover_letter_output_screen.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../../core/network/bloc/connectivity_bloc.dart';
import '../../../../core/network/bloc/connectivity_state.dart';
import '../../../../core/widgets/no_internet_widget.dart';

/// Cover letter editor screen.
///
/// - Opens with default template pre-loaded.
/// - AppBar trailing icon opens template selector bottom sheet.
/// - Three editable sections: header, body, footer.
/// - FAB → POST /cover-letters → navigate to output screen.
class CoverLetterScreen extends StatelessWidget {
  const CoverLetterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          CoverLetterBloc(context.read<CoverLetterRepository>())..add(const LoadTemplates()),
      child: const _CoverLetterView(),
    );
  }
}

// ── View ──────────────────────────────────────────────────────────────────────

class _CoverLetterView extends StatefulWidget {
  const _CoverLetterView();

  @override
  State<_CoverLetterView> createState() => _CoverLetterViewState();
}

class _CoverLetterViewState extends State<_CoverLetterView> {
  late final TextEditingController _headerCtrl;
  late final TextEditingController _bodyCtrl;
  late final TextEditingController _footerCtrl;

  @override
  void initState() {
    super.initState();
    // Will be populated dynamically when templates are loaded
    _headerCtrl = TextEditingController();
    _bodyCtrl = TextEditingController();
    _footerCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _headerCtrl.dispose();
    _bodyCtrl.dispose();
    _footerCtrl.dispose();
    super.dispose();
  }

  // ── Template switch ────────────────────────────────────────────────────────

  void _syncControllersFromState(CoverLetterState state) {
    if (_headerCtrl.text != state.model.header) {
      _headerCtrl.text = state.model.header;
    }
    if (_bodyCtrl.text != state.model.body) {
      _bodyCtrl.text = state.model.body;
    }
    if (_footerCtrl.text != state.model.footer) {
      _footerCtrl.text = state.model.footer;
    }
  }

  void _openTemplateSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) {
        return BlocProvider.value(
          value: context.read<CoverLetterBloc>(),
          child: _TemplateSheet(
            onSelected: (id, index) {
              context
                  .read<CoverLetterBloc>()
                  .add(SelectTemplate(id, index));
              Navigator.pop(sheetCtx);
            },
          ),
        );
      },
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CoverLetterBloc, CoverLetterState>(
      listener: (context, state) {
        // Sync text controllers when template changes
        if (state is CoverLetterInitial) {
          _syncControllersFromState(state);
        }
        // if (state is CoverLetterError) {
        //   ScaffoldMessenger.of(context)
        //     ..hideCurrentSnackBar()
        //     ..showSnackBar(
        //       SnackBar(
        //         content: Row(
        //           children: [
        //             const Icon(Icons.error_outline_rounded, color: Colors.white, size: 18),
        //             const SizedBox(width: 10),
        //             Expanded(
        //               child: Text(state.message, style: GoogleFonts.inter(color: Colors.white, fontSize: 13), overflow: TextOverflow.ellipsis),
        //             ),
        //           ],
        //         ),
        //         backgroundColor: const Color(0xFFBA1A1A),
        //         behavior: SnackBarBehavior.floating,
        //         margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        //       ),
        //     );
        // }
        if (state is CoverLetterSuccess) {
          print("Cover Letter created → refreshing profile");
          context.read<ProfileBloc>().add(const FetchProfile(forceNetwork: true));

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => CoverLetterOutputScreen(saved: state.saved),
            ),
          );
        }
      },
      builder: (context, state) {
        final isSubmitting = state is CoverLetterLoading;

        return BlocBuilder<ConnectivityBloc, ConnectivityState>(
          builder: (context, connectivityState) {
            final isOffline = connectivityState is ConnectivityOffline;

            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: const SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.dark,
                statusBarBrightness: Brightness.light,
              ),
              child: Scaffold(
                backgroundColor: const Color(0xFFF8F9FA),
                appBar: AppBar(
                backgroundColor: Colors.white,
                systemOverlayStyle: const SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  statusBarIconBrightness: Brightness.dark,
                  statusBarBrightness: Brightness.light,
                ),
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF191C1D), size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text(
                  'Cover Letter',
                  style: GoogleFonts.manrope(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF191C1D),
                  ),
                ),
                actions: [
                  IconButton(
                    tooltip: 'Choose Template',
                    icon: const Icon(Icons.auto_awesome_motion_rounded, color: Color(0xFF024D87)),
                    onPressed: isSubmitting || isOffline ? null : () => _openTemplateSheet(context),
                  ),
                ],
              ),
              body: Column(
                children: [
                  AnimatedInternetBanner(
                    isOffline: isOffline,
                    onRetry: () => context.read<CoverLetterBloc>().add(const LoadTemplates()),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
                      child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Template badge
                _TemplateBadge(
                  templateName: state.model.title,
                  onTap: isSubmitting || isOffline ? () {} : () => _openTemplateSheet(context),
                ),
                const SizedBox(height: 24),

                // Header section
                _SectionLabel(icon: Icons.person_outline_rounded, label: 'Header', hint: 'Name, address, date…'),
                const SizedBox(height: 8),
                _EditorField(
                  controller: _headerCtrl,
                  minLines: 3,
                  onChanged: (v) => context.read<CoverLetterBloc>().add(UpdateCoverLetterField('header', v)),
                ),
                const SizedBox(height: 20),

                // Body section
                _SectionLabel(icon: Icons.article_outlined, label: 'Body', hint: 'Main letter content…'),
                const SizedBox(height: 8),
                _EditorField(
                  controller: _bodyCtrl,
                  minLines: 10,
                  onChanged: (v) => context.read<CoverLetterBloc>().add(UpdateCoverLetterField('body', v)),
                ),
                const SizedBox(height: 20),

                            // Footer section
                            _SectionLabel(icon: Icons.border_bottom_rounded, label: 'Footer', hint: 'Sign-off, name, links…'),
                            const SizedBox(height: 8),
                            _EditorField(
                              controller: _footerCtrl,
                              minLines: 2,
                              onChanged: (v) => context.read<CoverLetterBloc>().add(UpdateCoverLetterField('footer', v)),
                            ),
                          ],
                        ),
                      ),
                  ),
                ],
              ),
              floatingActionButton: FloatingActionButton.extended(
                backgroundColor: const Color(0xFF024D87),
                foregroundColor: Colors.white,
                onPressed: isOffline
                    ? () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No Internet Connection')))
                    : isSubmitting ? null : () => context.read<CoverLetterBloc>().add(const CreateCoverLetter()),
                icon: isSubmitting
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                    : const Icon(Icons.send_rounded),
                label: Text(
                  isSubmitting ? 'Saving…' : 'Save & Preview',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            );
          },
        );
      },
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _TemplateBadge extends StatelessWidget {
  final String templateName;
  final VoidCallback onTap;
  const _TemplateBadge({required this.templateName, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5EC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFA3CEB0)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_awesome_motion_rounded,
                color: Color(0xFF024D87), size: 18),
            const SizedBox(width: 8),
            Text(
              templateName,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF024D87),
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.arrow_drop_down_rounded,
                color: Color(0xFF024D87), size: 18),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final String hint;
  const _SectionLabel(
      {required this.icon, required this.label, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF024D87)),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF191C1D),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '· $hint',
          style: GoogleFonts.inter(
              fontSize: 12, color: const Color(0xFF9E9E9E)),
        ),
      ],
    );
  }
}

class _EditorField extends StatelessWidget {
  final TextEditingController controller;
  final int minLines;
  final ValueChanged<String> onChanged;

  const _EditorField({
    required this.controller,
    required this.minLines,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        minLines: minLines,
        maxLines: null,
        keyboardType: TextInputType.multiline,
        style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF191C1D)),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE1E3E4)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE1E3E4)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: Color(0xFF024D87), width: 1.5),
          ),
        ),
      ),
    );
  }
}

// ── Template selector bottom sheet ────────────────────────────────────────────

class _TemplateSheet extends StatelessWidget {
  final void Function(String id, int index) onSelected;
  const _TemplateSheet({required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final current = context.watch<CoverLetterBloc>().state.model.templateIndex;
    final templates = context.watch<CoverLetterBloc>().state.templates;
    
    if (templates.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 12),
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: const Color(0xFFD8DDD8),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Text(
                'Choose a Template',
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF191C1D),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Flexible(
          child: ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            itemCount: templates.length,
            itemBuilder: (_, i) {
              final tpl = templates[i];
              final isSelected = i == current;
              return ListTile(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                tileColor:
                    isSelected ? const Color(0xFFE8F5EC) : Colors.transparent,
                leading: CircleAvatar(
                  backgroundColor: isSelected
                      ? const Color(0xFF024D87)
                      : const Color(0xFFF0F2F5),
                  radius: 18,
                  child: Text(
                    '${i + 1}',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF6B7A6B),
                    ),
                  ),
                ),
                title: Text(
                  tpl.title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: const Color(0xFF191C1D),
                  ),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check_circle_rounded,
                        color: Color(0xFF024D87))
                    : null,
                onTap: () => onSelected(tpl.id, i),
              );
            },
          ),
        ),
      ],
    );
  }
}
