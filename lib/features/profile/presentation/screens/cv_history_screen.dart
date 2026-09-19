import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickcvpro/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:quickcvpro/features/profile/presentation/screens/pdf_viewer_screen.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/pressable_scale.dart';


class CVHistoryScreen extends StatelessWidget {
  const CVHistoryScreen({super.key});

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
        title: Text(
          'CV History',
          style: GoogleFonts.manrope(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF191C1D),
          ),
        ),
        backgroundColor: Colors.white,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF191C1D), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProfileError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 16),
                    AppButton(
                      label: 'Retry',
                      isPrimary: false,
                      width: 140,
                      onTap: () => context.read<ProfileBloc>().add(const FetchProfile()),
                    ),

                  ],
                ),
              ),
            );
          }

          if (state is ProfileLoaded) {
            if (state.cvHistory.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.description_outlined, size: 80, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text(
                      'No CV found',
                      style: GoogleFonts.manrope(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF3E4A3C),
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: state.cvHistory.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final pdfPath = state.cvHistory[index];
                final fileName = pdfPath.split('/').last;

                return PressableScale(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PDFViewerScreen(pdfPath: pdfPath),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF51B1E1).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.picture_as_pdf, color: Color(0xFF51B1E1)),
                      ),
                      title: Text(
                        'CV #${state.cvHistory.length - index}',
                        style: GoogleFonts.manrope(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF191C1D),
                        ),
                      ),
                      subtitle: Text(
                        fileName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                    ),
                  ),
                );

              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    ),
    );
  }
}
