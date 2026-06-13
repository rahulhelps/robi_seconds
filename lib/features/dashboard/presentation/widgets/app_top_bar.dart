import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';

class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: const Color(0xFF024D87),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo
              Row(
                children: [
                  const Icon(
                    Icons.description,
                    color: Colors.white,
                    size: 26,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'QuickCV',
                    style: GoogleFonts.manrope(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),

              // Actions
              Row(
                children: [
                  // // Notifications
                  // Stack(
                  //   children: [
                  //     IconButton(
                  //       onPressed: () {},
                  //       icon: const Icon(
                  //         Icons.notifications_outlined,
                  //         color: Colors.white,
                  //       ),
                  //     ),
                  //     Positioned(
                  //       top: 8,
                  //       right: 8,
                  //       child: Container(
                  //         width: 16,
                  //         height: 16,
                  //         decoration: BoxDecoration(
                  //           color: const Color(0xFFBA1A1A),
                  //           shape: BoxShape.circle,
                  //           border: Border.all(color: Colors.white, width: 2),
                  //         ),
                  //         child: const Center(
                  //           child: Text(
                  //             '3',
                  //             style: TextStyle(
                  //               color: Colors.white,
                  //               fontSize: 9,
                  //               fontWeight: FontWeight.w700,
                  //             ),
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  // const SizedBox(width: 4),

                  // Avatar
                  BlocBuilder<ProfileBloc, ProfileState>(
                    builder: (context, state) {
                      String? avatarUrl;
                      if (state is ProfileLoaded) {
                        avatarUrl = state.profileImageUrl;
                      }
                      
                      return Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF28A745),
                            width: 2,
                          ),
                          color: const Color(0xFF024D87),
                        ),
                        child: ClipOval(
                          child: (avatarUrl != null && avatarUrl.isNotEmpty)
                              ? CachedNetworkImage(
                                  imageUrl: avatarUrl,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => const Icon(Icons.person, color: Colors.white, size: 20),
                                  errorWidget: (context, url, error) => const Icon(Icons.person, color: Colors.white, size: 20),
                                )
                              : const Icon(Icons.person, color: Colors.white, size: 20),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
