import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/cv_repository.dart';
import '../bloc/cv_bloc.dart';
import 'pdf_preview_screen.dart';

class CvListScreen extends StatelessWidget {
  const CvListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          CvBloc(context.read<CvRepository>())..add(const FetchCVs()),
      child: const _CvListView(),
    );
  }
}

class _CvListView extends StatelessWidget {
  const _CvListView();

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
          icon: Icon(Icons.arrow_back, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        elevation: 0,
        title: Text(
          'My CVs',
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF191C1D),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.black),
            onPressed: () => context.read<CvBloc>().add(const FetchCVs()),
          ),
        ],
      ),
      body: BlocConsumer<CvBloc, CvState>(
        listener: (context, state) {
          if (state is CvError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is CvLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CvLoaded) {
            final items = state.items;
            if (items.isEmpty) {
              return _EmptyCVState(
                onRefresh: () => context.read<CvBloc>().add(const FetchCVs()),
              );
            }

            return RefreshIndicator(
              onRefresh: () async =>
                  context.read<CvBloc>().add(const FetchCVs()),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  // "CV #1" naming logic (assuming items are newest first)
                  final cvNumber = items.length - index;
                  final dateStr = _formatDate(item.createdAt);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: const Icon(
                        Icons.description,
                        color: Color(0xFF024D87),
                      ),
                      title: Text(
                        "CV #$cvNumber",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(dateStr),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PdfPreviewScreen.fromId(
                              cvId: item.id,
                              bearerToken: state.token ?? '',
                            ),
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

class _EmptyCVState extends StatelessWidget {
  final VoidCallback onRefresh;

  const _EmptyCVState({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.folder_open, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            "No CV found",
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRefresh, child: const Text("Refresh")),
        ],
      ),
    );
  }
}
