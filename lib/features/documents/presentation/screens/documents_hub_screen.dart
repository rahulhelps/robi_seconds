import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/network/bloc/connectivity_bloc.dart';
import '../../../../core/network/bloc/connectivity_state.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../payments/presentation/bloc/payment_bloc.dart';
import '../../../payments/presentation/screens/payments_screen.dart';
import '../../domain/document_model.dart';
import '../../domain/document_repository.dart';
import '../../data/documents_datasource.dart';
import '../bloc/documents_bloc.dart';

class DocumentsHubScreen extends StatelessWidget {
  const DocumentsHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DocumentsBloc(
        DocumentRepository(DocumentsDatasource()),
      )..add(const DocumentsFetchRequested()),
      child: const _DocumentsHubView(),
    );
  }
}

class _DocumentsHubView extends StatelessWidget {
  const _DocumentsHubView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConnectivityBloc, ConnectivityState>(
      listener: (context, state) {
        if (state is ConnectivityOnline) {
          context.read<DocumentsBloc>().add(const DocumentsFetchRequested());
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                left: 20,
                right: 20,
                bottom: 16,
              ),
              color: const Color(0xFF024D87),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Documents',
                    style: GoogleFonts.manrope(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  _buildCreateMenu(context),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<DocumentsBloc, DocumentsState>(
                builder: (context, state) {
                  if (state is DocumentsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is DocumentsError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          state.message,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    );
                  }

                  if (state is DocumentsLoaded || state is DocumentsCreated || state is DocumentsUpdated) {
                    final documents = state is DocumentsLoaded
                        ? state.documents
                        : state is DocumentsCreated
                            ? [...(state as dynamic).documents, (state as dynamic).document]
                            : state is DocumentsUpdated
                                ? (state as dynamic).documents
                                : <DocumentModel>[];

                    final docs = documents is List<DocumentModel> ? documents : <DocumentModel>[];

                    if (docs.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Text('No documents yet. Create your first document.'),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final doc = docs[index];
                        return _DocumentCard(document: doc);
                      },
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateMenu(BuildContext context) {
    return PopupMenuButton<DocumentType>(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      onSelected: (DocumentType type) async {
        final profileState = context.read<ProfileBloc>().state;
        final isSubscribed = profileState is ProfileLoaded && profileState.isSubscriptionActive;

        if (!isSubscribed) {
          if (!context.mounted) return;
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<PaymentBloc>(),
                child: const PaymentsScreen(),
              ),
            ),
          );
          return;
        }

        if (!context.mounted) return;
        _showCreateDialog(context, type);
      },
      itemBuilder: (context) => DocumentType.values
          .map(
            (type) => PopupMenuItem(
              value: type,
              child: Row(
                children: [
                  Icon(_typeIcon(type), color: const Color(0xFF024D87)),
                  const SizedBox(width: 12),
                  Text(type.label),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  void _showCreateDialog(BuildContext context, DocumentType type) {
    final payload = <String, dynamic>{};
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('New ${type.label}'),
        content: Text('Create a new ${type.label} document.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              try {
                final request = CreateDocumentRequest(
                  type: type,
                  payload: payload,
                );
                if (!context.mounted) return;
                context.read<DocumentsBloc>().add(
                      DocumentsCreateRequested(request),
                    );
              } catch (e) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(content: Text(e.toString())),
                );
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  IconData _typeIcon(DocumentType type) {
    return switch (type) {
      DocumentType.cv => Icons.badge,
      DocumentType.coverLetter => Icons.mail,
      DocumentType.sop => Icons.school,
      DocumentType.email => Icons.email,
    };
  }
}

class _DocumentCard extends StatelessWidget {
  final DocumentModel document;

  const _DocumentCard({required this.document});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: const Color(0xFF024D87).withValues(alpha: 0.08)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF024D87).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _iconForType(document.type),
            color: const Color(0xFF024D87),
          ),
        ),
        title: Text(
          document.type.label,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF191C1D),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '${document.status.label} • ${_formatDate(document.updatedAt)}',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: const Color(0xFF3E4A3C),
            ),
          ),
        ),
        trailing: document.status == DocumentStatus.ready
            ? IconButton(
                icon: const Icon(Icons.download, color: Color(0xFF024D87)),
                onPressed: () {
                  if (document.generatedFileUrl != null) {
                    // TODO: open/download file
                  }
                },
              )
            : document.status == DocumentStatus.failed
                ? IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.redAccent),
                    onPressed: () {
                      // TODO: retry generation
                    },
                  )
                : null,
      ),
    );
  }

  IconData _iconForType(DocumentType type) {
    return switch (type) {
      DocumentType.cv => Icons.badge,
      DocumentType.coverLetter => Icons.mail,
      DocumentType.sop => Icons.school,
      DocumentType.email => Icons.email,
    };
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    return '${date.day}/${date.month}/${date.year}';
  }
}

extension DocumentStatusLabel on DocumentStatus {
  String get label {
    return switch (this) {
      DocumentStatus.draft => 'Draft',
      DocumentStatus.rendering => 'Rendering',
      DocumentStatus.ready => 'Ready',
      DocumentStatus.failed => 'Failed',
    };
  }
}
