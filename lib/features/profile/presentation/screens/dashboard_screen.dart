import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import 'package:quickcvpro/core/widgets/app_buttons.dart';
import 'package:quickcvpro/core/widgets/pressable_scale.dart';

import '../bloc/profile_bloc.dart';
import '../widgets/gradient_promo_card.dart';
import '../widgets/profile_action_square.dart';
import '../widgets/profile_colors.dart';
import '../widgets/trusted_payment_partners.dart';
import '../../../cv_builder/presentation/screens/cv_list_screen.dart';
import '../../../dashboard/presentation/bloc/dashboard_bloc.dart';
import '../../../../core/widgets/no_internet_screen.dart';
import '../../../../core/network/bloc/connectivity_bloc.dart';
import '../../../../core/network/bloc/connectivity_state.dart';
import '../../../../core/services/auth_service.dart';





/// Profile tab UI (converted from HTML). Light theme only.
class ProfileDashboardScreen extends StatelessWidget {
  const ProfileDashboardScreen({super.key});

  static const _maxContentWidth = 448.0;

  @override
  Widget build(BuildContext context) {
    return const _ProfileDashboardBody();
  }

}

class _ProfileDashboardBody extends StatelessWidget {
  const _ProfileDashboardBody();

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
        listeners: [
          BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthUnauthenticated || state is AuthUnsubscribeSuccess) {
                if (state is AuthUnsubscribeSuccess) {
                  context.read<ProfileBloc>().add(const ResetProfile());
                }
                Navigator.pushNamedAndRemoveUntil(context, '/auth', (route) => false);
              } else if (state is AuthUnsubscribeFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              }
            },
          ),
          BlocListener<ProfileBloc, ProfileState>(
            listener: (context, state) async {
              if (state is ProfileSessionExpired) {
                // Try a silent refresh once before forcing logout
                final refreshed = await AuthService.refreshToken();
                if (!context.mounted) return;
                if (!refreshed) {
                  Navigator.pushNamedAndRemoveUntil(context, '/auth', (route) => false);
                } else {
                  // Refresh succeeded — retry fetching the profile
                  context.read<ProfileBloc>().add(const FetchProfile());
                }
              }
            },
          ),
        ],
        child: BlocBuilder<ConnectivityBloc, ConnectivityState>(
        builder: (context, connectivityState) {
          if (connectivityState is ConnectivityOffline) {
            return NoInternetScreen(
              onRetry: () => context.read<ProfileBloc>().add(const FetchProfile()),
            );
          }

          return BlocBuilder<ProfileBloc, ProfileState>(
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
                    Text(
                      'Error: ${state.message}',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    AppButton(
                      label: 'Retry',
                      isPrimary: false,
                      width: 120,
                      onTap: () =>
                          context.read<ProfileBloc>().add(const FetchProfile()),
                    ),

                  ],
                ),
              ),
            );
          }

          if (state is ProfileLoaded) {
            final maskedPhone = _maskPhone(state.phoneNumber);

            return LayoutBuilder(
              builder: (context, constraints) {
                final horizontal = _horizontalPadding(constraints.maxWidth);
                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    horizontal,
                    16,
                    horizontal,
                    100,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: ProfileDashboardScreen._maxContentWidth,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _ProfileHeaderCard(
                            phone: maskedPhone,
                            email: state.email,
                            memberSince: state.memberSince,
                            cvCount: state.cvCount,
                            isSubscriptionActive: state.isSubscriptionActive,
                            profileImageUrl: state.profileImageUrl,
                          ),
                          const SizedBox(height: 28),
                          const _ActionGrid(),
                          const SizedBox(height: 28),
                          GradientPromoCard(
                            title: state.isSubscriptionActive
                                ? 'Premium Activated'
                                : 'Get Premium',
                            subtitle: state.isSubscriptionActive
                                ? 'Your premium plan is active'
                                : 'Unlock all templates',
                            actionLabel: state.isSubscriptionActive ? 'Manage' : 'Get Pro',
                            onAction: () {
                              context.read<DashboardBloc>().add(
                                const DashboardNavTabChanged(2),
                              );
                            },
                          ),
                          const SizedBox(height: 28),
                          // Unsubscribe Button
                          BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, authState) {
                              final isLoading = authState is AuthUnsubscribeLoading;
                              final isValidOperator = _isRobiOrAirtel(state.phoneNumber);
                              return Material(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                child: InkWell(
                                  onTap: (isLoading || !isValidOperator)
                                      ? null
                                      : () {
                                          _showUnsubscribeConfirm(context, state.phoneNumber);
                                        },
                                  borderRadius: BorderRadius.circular(16),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16, horizontal: 20),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: isValidOperator ? Colors.orange.shade50 : Colors.grey.shade100,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Icon(
                                            Icons.unsubscribe_rounded,
                                            color: isValidOperator ? Colors.orange.shade700 : Colors.grey.shade400,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Text(
                                          'Unsubscribe',
                                          style: GoogleFonts.manrope(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: isValidOperator ? Colors.orange.shade700 : Colors.grey.shade400,
                                          ),
                                        ),
                                        const Spacer(),
                                        if (isLoading)
                                          const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                                            ),
                                          )
                                        else
                                          Icon(
                                            Icons.chevron_right,
                                            color: isValidOperator ? Colors.grey : Colors.grey.shade300,
                                            size: 18,
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          // Premium Logout Button
                          Material(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            child: InkWell(
                              onTap: () {
                                _showLogoutConfirm(context);
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 20),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFEBEB),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.logout_rounded,
                                        color: Colors.redAccent,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Text(
                                      'Logout Session',
                                      style: GoogleFonts.manrope(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.redAccent,
                                      ),
                                    ),
                                    const Spacer(),
                                    const Icon(
                                      Icons.chevron_right,
                                      color: Colors.grey,
                                      size: 18,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                          const TrustedPaymentPartners(),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }

          return const Center(child: Text('No profile data available'));
        },
      );
    },
  ),
);
}

  void _showUnsubscribeConfirm(BuildContext context, String phone) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Unsubscribe',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (context, anim1, anim2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
          child: FadeTransition(
            opacity: anim1,
            child: Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              elevation: 0,
              backgroundColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.unsubscribe_rounded, color: Colors.orange.shade700, size: 32),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Unsubscribe',
                      style: GoogleFonts.manrope(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF191C1D),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Are you sure you want to unsubscribe? You will lose access to all premium features.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF3E4A3C),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            label: 'Cancel',
                            isPrimary: false,
                            height: 50,
                            onTap: () => Navigator.pop(context),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: AppButton(
                            label: 'Unsubscribe',
                            backgroundColor: Colors.orange.shade700,
                            height: 50,
                            onTap: () {
                              final connectivityState = context.read<ConnectivityBloc>().state;
                              if (connectivityState is ConnectivityOffline) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('No internet connection', style: GoogleFonts.inter(color: Colors.white)),
                                    backgroundColor: Colors.redAccent,
                                  )
                                );
                                Navigator.pop(context);
                                return;
                              }
                              Navigator.pop(context);
                              context.read<AuthBloc>().add(UnsubscribeRequested(phone));
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showLogoutConfirm(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Logout',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (context, anim1, anim2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
          child: FadeTransition(
            opacity: anim1,
            child: Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              elevation: 0,
              backgroundColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.logout_rounded, color: Colors.red, size: 32),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Logout?',
                      style: GoogleFonts.manrope(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF191C1D),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Are you sure you want to logout? You will need to verify your phone number again.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF3E4A3C),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            label: 'Cancel',
                            isPrimary: false,
                            height: 50,
                            onTap: () => Navigator.pop(context),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: AppButton(
                            label: 'Logout',
                            backgroundColor: Colors.red,
                            height: 50,
                            onTap: () {
                              Navigator.pop(context);
                              context.read<AuthBloc>().add(const LogoutRequested());
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }



  String _maskPhone(String phone) {
    if (phone.length < 7) return phone;
    return '${phone.substring(0, 4)}****${phone.substring(phone.length - 3)}';
  }

  bool _isRobiOrAirtel(String phoneNumber) {
    if (phoneNumber.isEmpty) return false;
    final digits = phoneNumber.replaceAll(RegExp(r'\D'), '');
    String normalized = digits;
    if (digits.startsWith('880') && digits.length == 13) {
      normalized = '0${digits.substring(3)}';
    } else if (digits.startsWith('88') && digits.length == 12) {
      normalized = '0${digits.substring(2)}';
    }
    return normalized.startsWith('016') ||
           normalized.startsWith('018') ||
           normalized.startsWith('011');
  }

  double _horizontalPadding(double width) {
    if (width >= 600) return 32;
    if (width >= 400) return 24;
    return 20;
  }
}


class _ProfileHeaderCard extends StatelessWidget {
  const _ProfileHeaderCard({
    required this.phone,
    this.email,
    this.memberSince,
    this.cvCount = 0,
    this.isSubscriptionActive = false,
    this.profileImageUrl,
  });

  final String phone;
  final String? email;
  final String? memberSince;
  final int cvCount;
  final bool isSubscriptionActive;
  final String? profileImageUrl;

  /// Formats an ISO-8601 string like "2025-04-10T08:21:22.000Z"
  /// into a human-friendly string like "April 2025".
  String _formatMemberSince(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    try {
      final dt = DateTime.parse(raw).toLocal();
      const months = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      return 'Member since ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final memberLabel = _formatMemberSince(memberSince);

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ProfileColors.primary,
            Color(0xFF012140),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: ProfileColors.primary.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Avatar + name/badge row ───────────────────────────────────────
          Row(
            children: [
              _Avatar(url: profileImageUrl ?? ''),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      phone,
                      style: GoogleFonts.manrope(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    if (email != null && email!.isNotEmpty) ...[  
                      const SizedBox(height: 2),
                      Text(
                        email!,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.verified,
                              color: Colors.white, size: 13),
                          const SizedBox(width: 5),
                          Text(
                            'Verified Profile',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          // ── Divider ───────────────────────────────────────────────────────
          Divider(
            color: Colors.white.withValues(alpha: 0.15),
            height: 1,
          ),
          const SizedBox(height: 20),

          // ── Stats row ─────────────────────────────────────────────────────
          Row(
            children: [
              // CV count
              Expanded(
                child: _StatChip(
                  icon: Icons.description_outlined,
                  value: '$cvCount',
                  label: cvCount == 1 ? 'CV Created' : 'CVs Created',
                ),
              ),
              const SizedBox(width: 12),
              // Subscription status
              Expanded(
                child: _StatChip(
                  icon: isSubscriptionActive
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  value: isSubscriptionActive ? 'Active' : 'Inactive',
                  label: 'Subscription',
                  valueColor: isSubscriptionActive
                      ? const Color(0xFFFFD700)
                      : Colors.white54,
                ),
              ),
            ],
          ),

          // ── Member since ─────────────────────────────────────────────────
          if (memberLabel.isNotEmpty) ...[  
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    color: Colors.white54, size: 13),
                const SizedBox(width: 6),
                Text(
                  memberLabel,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ── Small stat chip ────────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.value,
    required this.label,
    this.valueColor = Colors.white,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: valueColor, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: valueColor,
                  ),
                ),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.url});

  final String url;

  Future<void> _pickAndUploadImage(BuildContext context) async {
    final picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 800,
      );
      
      if (image == null) return; // User cancelled
      
      final int sizeInBytes = await image.length();
      // Assume 5MB limit
      if (sizeInBytes > 5 * 1024 * 1024) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image size too large')),
        );
        return;
      }
      
      if (!context.mounted) return;
      context.read<ProfileBloc>().add(UploadAvatarEvent(
        image.path,
        image.name,
        image.mimeType ?? 'image/jpeg',
      ));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is UploadAvatarFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error)),
          );
        } else if (state is UploadAvatarSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile picture updated successfully')),
          );
        }
      },
      builder: (context, state) {
        final bool isUploading = state is UploadAvatarLoading;
        final hasImage = url.isNotEmpty;

        return GestureDetector(
          onTap: isUploading ? null : () => _pickAndUploadImage(context),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 76,
                height: 76,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      ProfileColors.primaryContainer,
                      ProfileColors.primary,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: ProfileColors.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: hasImage
                      ? CachedNetworkImage(
                          imageUrl: url,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => _avatarPlaceholder(),
                          errorWidget: (context, url, error) => _avatarPlaceholder(),
                        )
                      : _avatarPlaceholder(),
                ),
              ),
              if (isUploading)
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withValues(alpha: 0.4),
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _avatarPlaceholder() {
    return ColoredBox(
      color: ProfileColors.surfaceLow,
      child: Center(
        child: Icon(
          Icons.person_rounded,
          color: ProfileColors.outline,
          size: 38,
        ),
      ),
    );
  }
}

class _ActionGrid extends StatelessWidget {
  const _ActionGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        ProfileActionSquare(
          icon: Icons.add_circle_outline,
          label: 'CREATE CV',
          onTap: () => Navigator.pushNamed(context, '/template_gallery'),
        ),
        ProfileActionSquare(
          icon: Icons.cloud_download_outlined,
          label: 'CV DOWNLOADS',
          onTap: () {
            // Navigate to CV List screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CvListScreen(),
              ),
            );
          },
        ),
      ],
    );
  }
}
