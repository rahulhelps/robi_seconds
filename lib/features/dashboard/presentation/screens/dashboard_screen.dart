import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickcvpro/features/packages/presentation/screens/packages_screen.dart';
import 'package:quickcvpro/features/payments/presentation/screens/payments_screen.dart';
import 'package:quickcvpro/features/profile/presentation/screens/dashboard_screen.dart';
import '../../../../core/widgets/no_internet_widget.dart';
import '../../../../core/network/bloc/connectivity_bloc.dart';
import '../../../../core/network/bloc/connectivity_state.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../packages/presentation/bloc/packages_bloc.dart';
import '../../../sop/presentation/bloc/sop_bloc.dart';
import '../bloc/dashboard_bloc.dart';
import '../widgets/action_cards.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/dashboard_bottom_nav_bar.dart';
import '../widgets/profile_quick_card.dart';
import '../widgets/quick_stats_grid.dart';


class QuickCVDashboardScreen extends StatelessWidget {
  const QuickCVDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _DashboardView();
  }

}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConnectivityBloc, ConnectivityState>(
      listener: (context, state) {
        if (state is ConnectivityOnline) {
          // Auto retry last failed API calls or reload data generally
          context.read<ProfileBloc>().add(const FetchProfile());
          context.read<PackagesBloc>().add(const FetchPackages());
          context.read<SopBloc>().add(const SopHistoryRequested());
        }
      },
      child: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: const Color(0xFFF8F9FA),
            appBar: AppBar(
              backgroundColor: const Color(0xFF024D87),
              systemOverlayStyle: const SystemUiOverlayStyle(
                statusBarColor: Color(0xFF024D87),
                statusBarIconBrightness: Brightness.light,
                statusBarBrightness: Brightness.dark,
              ),
              elevation: 0,
              toolbarHeight: 64,
              automaticallyImplyLeading: false,
              titleSpacing: 0,
              title: const AppTopBar(),
            ),
            bottomNavigationBar: const DashboardBottomNavBar(),
            body: Column(
              children: [
                Expanded(
                  child: IndexedStack(
                    index: state.selectedNavIndex,
                    children: const [
                      _HomeTab(),
                      ProfileDashboardScreen(),
                      ServicesScreen(),
                      PaymentsScreen(),
                    ],
                  ),
                ),
              ],
            ),
          );
      },
    ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityBloc, ConnectivityState>(
      builder: (context, connectivityState) {
        final isOffline = connectivityState is ConnectivityOffline;

        if (connectivityState is ConnectivityOnline) {
          print("Internet: Online");
        } else if (isOffline) {
          print("Internet: Offline");
        }

        return Column(
          children: [
            AnimatedInternetBanner(
              isOffline: isOffline,
              onRetry: () {
                context.read<ProfileBloc>().add(const FetchProfile());
                context.read<SopBloc>().add(const SopHistoryRequested());
              },
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 6),
                    Text(
                      'Build and manage your career-defining CV.',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: const Color(0xFF3E4A3C),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Action cards
                    const ActionCards(),
                    const SizedBox(height: 10),

                    // Profile quick card
                    const ProfileQuickCard(),
                    const SizedBox(height: 10),

                    // Quick stats
                    const QuickStatsGrid(),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
