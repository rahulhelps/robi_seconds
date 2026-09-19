import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickcvpro/features/mock_test/presentation/screens/mock_test_screen.dart';
import 'package:quickcvpro/features/payments/presentation/screens/payments_screen.dart';
import 'package:quickcvpro/features/profile/presentation/screens/dashboard_screen.dart';
import 'package:quickcvpro/features/documents/presentation/screens/documents_hub_screen.dart';
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
import '../widgets/featured_document_card.dart';

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
            backgroundColor: const Color(0xFFFAFAFC),
            appBar: AppBar(
              backgroundColor: Colors.white,
              systemOverlayStyle: const SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.dark,
                statusBarBrightness: Brightness.light,
              ),
              elevation: 0,
              toolbarHeight: 68,
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
                      DocumentsHubScreen(),
                      PaymentsScreen(),
                      MockTestScreen(),
                      ProfileDashboardScreen(),
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
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    // 1. Profile Strength Gradient Card (Matching Landing Mockup)
                    ProfileQuickCard(),
                    SizedBox(height: 12),

                    // 2. 4 Quick Stats Pills (Matching Landing Mockup)
                    QuickStatsGrid(),
                    SizedBox(height: 14),

                    // 3. Featured Document Card + Create Button (Matching Landing Mockup)
                    FeaturedDocumentCard(),
                    SizedBox(height: 18),

                    // 4. Action Cards Grid (Career Suite Tools)
                    ActionCards(),
                    SizedBox(height: 20),
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
