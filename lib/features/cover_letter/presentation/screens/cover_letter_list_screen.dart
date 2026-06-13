import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/cover_letter_repository.dart';
import '../bloc/cover_letter_bloc.dart';
import 'cover_letter_output_screen.dart';

class CoverLetterListScreen extends StatelessWidget {
  const CoverLetterListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          CoverLetterBloc(context.read<CoverLetterRepository>())..add(const FetchCoverLetters()),
      child: const _CoverLetterListView(),
    );
  }
}

class _CoverLetterListView extends StatelessWidget {
  const _CoverLetterListView();

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
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        elevation: 0,
        title: Text(
          'My Cover Letters',
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF191C1D),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.black),
            onPressed: () => context.read<CoverLetterBloc>().add(const FetchCoverLetters()),
          ),
        ],
      ),
      body: BlocConsumer<CoverLetterBloc, CoverLetterState>(
        listener: (context, state) {
          if (state is CoverLetterError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is CoverLetterLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CoverLetterLoaded) {
            final items = state.items;
            if (items.isEmpty) {
              return _EmptyCoverLetterState(
                onRefresh: () => context.read<CoverLetterBloc>().add(const FetchCoverLetters()),
              );
            }

            return RefreshIndicator(
              onRefresh: () async =>
                  context.read<CoverLetterBloc>().add(const FetchCoverLetters()),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final letterNumber = items.length - index;
                  final dateStr = _formatDate(item.createdAt);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: const Icon(
                        Icons.mark_email_read_outlined,
                        color: Color(0xFF024D87),
                      ),
                      title: Text(
                        "Cover Letter #$letterNumber",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(dateStr),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.download_rounded, color: Color(0xFF51B1E1)),
                          const SizedBox(width: 8),
                          const Icon(Icons.chevron_right),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CoverLetterOutputScreen(saved: item),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    ),
    );
  }

  String _formatDate(String iso) {
    if (iso.isEmpty) return 'No date';
    try {
      final dt = DateTime.parse(iso).toLocal();
      return "${dt.day}/${dt.month}/${dt.year}";
    } catch (_) {
      return iso;
    }
  }
}

class _EmptyCoverLetterState extends StatelessWidget {
  final VoidCallback onRefresh;

  const _EmptyCoverLetterState({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.mail_lock_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            "No Cover Letters Found",
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRefresh, child: const Text("Refresh")),
        ],
      ),
    );
  }
}
