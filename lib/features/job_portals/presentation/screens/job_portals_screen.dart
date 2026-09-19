import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_gradient_header.dart';
import '../../../../core/widgets/webview_screen.dart';
import '../../data/job_portal_model.dart';
import '../../data/job_portal_datasource.dart';

class JobPortalsScreen extends StatefulWidget {
  final String initialCategory;

  const JobPortalsScreen({
    super.key,
    this.initialCategory = 'all',
  });

  @override
  State<JobPortalsScreen> createState() => _JobPortalsScreenState();
}

class _JobPortalsScreenState extends State<JobPortalsScreen> {
  final JobPortalDataSource _dataSource = JobPortalDataSource();
  final TextEditingController _searchController = TextEditingController();

  List<JobPortal> _allPortals = [];
  List<JobPortal> _filteredPortals = [];
  bool _isLoading = true;
  late String _selectedCategory;

  final List<Map<String, String>> _categories = [
    {'key': 'all', 'label': 'All Portals', 'bn': 'সব'},
    {'key': 'govt', 'label': 'Govt & BPSC', 'bn': 'সরকারি'},
    {'key': 'bank', 'label': 'Bank Jobs', 'bn': 'ব্যাংক'},
    {'key': 'results', 'label': 'Exam Results & Admit', 'bn': 'ফলাফল ও এডমিট'},
    {'key': 'private', 'label': 'Private & IT', 'bn': 'বেসরকারি'},
    {'key': 'overseas', 'label': 'Overseas', 'bn': 'প্রবাসী'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    _fetchPortals();
    _searchController.addListener(_filterPortals);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchPortals() async {
    setState(() => _isLoading = true);
    final portals = await _dataSource.getJobPortals(category: _selectedCategory);
    if (mounted) {
      setState(() {
        _allPortals = portals;
        _isLoading = false;
        _filterPortals();
      });
    }
  }

  void _filterPortals() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _filteredPortals = _allPortals.where((portal) {
        final matchesCategory = _selectedCategory == 'all' || portal.category == _selectedCategory;
        if (!matchesCategory) return false;

        if (query.isEmpty) return true;

        final titleMatch = portal.title.toLowerCase().contains(query);
        final bnMatch = portal.banglaTitle?.toLowerCase().contains(query) ?? false;
        final descMatch = portal.description?.toLowerCase().contains(query) ?? false;
        final badgeMatch = portal.badgeText?.toLowerCase().contains(query) ?? false;
        return titleMatch || bnMatch || descMatch || badgeMatch;
      }).toList();
    });
  }

  void _onCategorySelected(String key) {
    if (_selectedCategory == key) return;
    setState(() {
      _selectedCategory = key;
    });
    _fetchPortals();
  }

  Future<void> _launchUrl(String url) async {
    if (!mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Open Website',
          style: GoogleFonts.manrope(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'This will open the website inside the app. Continue?',
          style: GoogleFonts.inter(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: GoogleFonts.inter()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text('Open', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => WebViewScreen(
            url: url,
            title: 'Job Portal',
          ),
        ),
      );
    }
  }

  void _copyLink(String url, String title) {
    Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text('Link copied: $title')),
          ],
        ),
        backgroundColor: const Color(0xFF1E293B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'govt':
        return const Color(0xFF059669); // Emerald
      case 'bank':
        return const Color(0xFF4F46E5); // Indigo
      case 'results':
        return const Color(0xFFD97706); // Amber
      case 'private':
        return const Color(0xFF0284C7); // Sky blue
      case 'overseas':
        return const Color(0xFF7C3AED); // Purple
      default:
        return const Color(0xFF64748B);
    }
  }

  IconData _getPortalIcon(String? iconName, String category) {
    switch (iconName) {
      case 'building':
        return Icons.account_balance_rounded;
      case 'bank':
      case 'bank2':
        return Icons.account_balance_wallet_rounded;
      case 'award':
        return Icons.emoji_events_rounded;
      case 'mortarboard':
      case 'school':
        return Icons.school_rounded;
      case 'globe':
        return Icons.public_rounded;
      case 'linkedin':
        return Icons.business_center_rounded;
      case 'airplane':
        return Icons.flight_takeoff_rounded;
      case 'flag':
        return Icons.flag_rounded;
      case 'newspaper':
        return Icons.newspaper_rounded;
      case 'train':
        return Icons.train_rounded;
      case 'bell':
        return Icons.notifications_active_rounded;
      default:
        if (category == 'govt') return Icons.account_balance_rounded;
        if (category == 'bank') return Icons.savings_rounded;
        if (category == 'results') return Icons.fact_check_rounded;
        if (category == 'overseas') return Icons.flight_takeoff_rounded;
        return Icons.work_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Column(
          children: [
            // Custom Gradient Header
            CustomGradientHeader(
              title: _selectedCategory == 'results' ? 'Exam Results & Admit' : 'Job Portals & Results',
              subtitle: _selectedCategory == 'results'
                  ? 'Official exam results, marksheet notices & admit card downloads'
                  : 'Official application portals & exam result archives',
              badgeText: _selectedCategory == 'results' ? 'RESULTS & ADMIT' : 'CAREER HUB',
            ),

            // Search Bar & Info Banner
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    style: GoogleFonts.manrope(fontSize: 14, color: const Color(0xFF1E293B)),
                    decoration: InputDecoration(
                      hintText: 'Search portals (e.g. BCS, Bank, Result, Primary)...',
                      hintStyle: GoogleFonts.manrope(fontSize: 13.5, color: const Color(0xFF94A3B8)),
                      prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF64748B), size: 22),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 20, color: Color(0xFF94A3B8)),
                              onPressed: () => _searchController.clear(),
                            )
                          : null,
                      filled: true,
                      fillColor: const Color(0xFFF1F5F9),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Horizontal Filter Chips
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.only(bottom: 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: _categories.map((cat) {
                    final isSelected = _selectedCategory == cat['key'];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        onTap: () => _onCategorySelected(cat['key']!),
                        borderRadius: BorderRadius.circular(20),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                cat['label']!,
                                style: GoogleFonts.manrope(
                                  fontSize: 12.5,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                  color: isSelected ? Colors.white : const Color(0xFF475569),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '(${cat['bn']})',
                                style: GoogleFonts.hindSiliguri(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w500,
                                  color: isSelected ? Colors.white.withValues(alpha: 0.85) : const Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // Portals List View
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _fetchPortals,
                      child: _filteredPortals.isEmpty
                          ? ListView(
                              children: [
                                SizedBox(height: MediaQuery.of(context).size.height * 0.15),
                                Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.search_off_rounded, size: 56, color: Colors.grey.shade400),
                                      const SizedBox(height: 12),
                                      Text(
                                        'No matching portals found',
                                        style: GoogleFonts.manrope(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF64748B),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Try changing category or search keyword',
                                        style: GoogleFonts.manrope(
                                          fontSize: 13,
                                          color: const Color(0xFF94A3B8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              itemCount: _filteredPortals.length,
                              itemBuilder: (context, index) {
                                final portal = _filteredPortals[index];
                                final categoryColor = _getCategoryColor(portal.category);
                                final icon = _getPortalIcon(portal.icon, portal.category);

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: portal.isFeatured ? categoryColor.withValues(alpha: 0.35) : const Color(0xFFE2E8F0),
                                      width: portal.isFeatured ? 1.5 : 1.0,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: portal.isFeatured
                                            ? categoryColor.withValues(alpha: 0.08)
                                            : Colors.black.withValues(alpha: 0.03),
                                        blurRadius: 10,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Header Row: Badges and Tags
                                        Row(
                                          children: [
                                            // Category Tag
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                                              decoration: BoxDecoration(
                                                color: categoryColor.withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                portal.category.toUpperCase(),
                                                style: GoogleFonts.manrope(
                                                  fontSize: 10.5,
                                                  fontWeight: FontWeight.w700,
                                                  color: categoryColor,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                            ),

                                            if (portal.badgeText != null && portal.badgeText!.isNotEmpty) ...[
                                              const SizedBox(width: 8),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFF1F5F9),
                                                  borderRadius: BorderRadius.circular(6),
                                                  border: Border.all(color: const Color(0xFFCBD5E1)),
                                                ),
                                                child: Text(
                                                  portal.badgeText!,
                                                  style: GoogleFonts.manrope(
                                                    fontSize: 10.5,
                                                    fontWeight: FontWeight.w600,
                                                    color: const Color(0xFF475569),
                                                  ),
                                                ),
                                              ),
                                            ],

                                            const Spacer(),

                                            if (portal.isVerified)
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(Icons.verified_rounded, size: 16, color: Color(0xFF059669)),
                                                  const SizedBox(width: 3),
                                                  Text(
                                                    'Official',
                                                    style: GoogleFonts.manrope(
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.w600,
                                                      color: const Color(0xFF059669),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                          ],
                                        ),

                                        const SizedBox(height: 12),

                                        // Portal Title & Icon
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: 44,
                                              height: 44,
                                              decoration: BoxDecoration(
                                                color: categoryColor.withValues(alpha: 0.12),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Icon(icon, color: categoryColor, size: 22),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    portal.title,
                                                    style: GoogleFonts.manrope(
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.w700,
                                                      color: const Color(0xFF0F172A),
                                                      height: 1.25,
                                                    ),
                                                  ),
                                                  if (portal.banglaTitle != null && portal.banglaTitle!.isNotEmpty) ...[
                                                    const SizedBox(height: 3),
                                                    Text(
                                                      portal.banglaTitle!,
                                                      style: GoogleFonts.hindSiliguri(
                                                        fontSize: 13,
                                                        fontWeight: FontWeight.w500,
                                                        color: const Color(0xFF64748B),
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),

                                        // Description
                                        if (portal.description != null && portal.description!.isNotEmpty) ...[
                                          const SizedBox(height: 10),
                                          Text(
                                            portal.description!,
                                            style: GoogleFonts.manrope(
                                              fontSize: 12.5,
                                              color: const Color(0xFF64748B),
                                              height: 1.4,
                                            ),
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],

                                        const SizedBox(height: 14),

                                        // Actions Row
                                        Row(
                                          children: [
                                            Expanded(
                                              child: ElevatedButton.icon(
                                                onPressed: () => _launchUrl(portal.url),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: categoryColor,
                                                  foregroundColor: Colors.white,
                                                  elevation: 0,
                                                  padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 14),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                ),
                                                icon: const Icon(Icons.language_rounded, size: 16),
                                                label: Text(
                                                  portal.actionText,
                                                  style: GoogleFonts.manrope(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            IconButton(
                                              onPressed: () => _copyLink(portal.url, portal.title),
                                              tooltip: 'Copy website URL',
                                              icon: const Icon(Icons.content_copy_rounded, size: 18, color: Color(0xFF64748B)),
                                              style: IconButton.styleFrom(
                                                backgroundColor: const Color(0xFFF1F5F9),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                padding: const EdgeInsets.all(10),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
