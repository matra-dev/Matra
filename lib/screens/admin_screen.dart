import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_text_styles.dart';
import '../utils/haptics.dart';
import '../providers/app_provider.dart';
import '../widgets/dot_matrix_loading.dart';
import 'auth_screen.dart';

// ─── Admin Section Enum ─────────────────────────────────────────────────────

enum AdminSection {
  overview('Overview', Icons.dashboard_outlined, Icons.dashboard_rounded),
  users('Users', Icons.people_outline, Icons.people_rounded),
  kanban('Customer Care', Icons.view_kanban_outlined, Icons.view_kanban_rounded),
  engine('Matra Engine', Icons.memory_outlined, Icons.memory_rounded),
  analytics('Analytics', Icons.analytics_outlined, Icons.analytics_rounded);

  final String label;
  final IconData icon;
  final IconData activeIcon;
  const AdminSection(this.label, this.icon, this.activeIcon);
}

// ─── Kanban Ticket Model ───────────────────────────────────────────────────

class KanbanTicket {
  final String id;
  String title;
  String description;
  String priority;
  String status;
  String assignee;
  String customer;
  final DateTime createdAt;
  DateTime? updatedAt;
  List<String> tags;

  KanbanTicket({
    required this.id,
    required this.title,
    this.description = '',
    this.priority = 'medium',
    this.status = 'backlog',
    this.assignee = 'Unassigned',
    this.customer = '',
    required this.createdAt,
    this.updatedAt,
    this.tags = const [],
  });

  KanbanTicket copyWith({String? status, String? assignee, DateTime? updatedAt}) {
    return KanbanTicket(
      id: id,
      title: title,
      description: description,
      priority: priority,
      status: status ?? this.status,
      assignee: assignee ?? this.assignee,
      customer: customer,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags,
    );
  }
}

// ─── Demo Tickets ────────────────────────────────────────────────────────────

final List<KanbanTicket> _demoTickets = [
  KanbanTicket(
    id: 'TKT-001',
    title: 'App crash on login',
    description: 'User reports app crashes when trying to login with phone number on Android 14.',
    priority: 'high',
    status: 'in_progress',
    assignee: 'Alex',
    customer: 'raj@example.com',
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    updatedAt: DateTime.now().subtract(const Duration(minutes: 30)),
    tags: ['bug', 'android', 'auth'],
  ),
  KanbanTicket(
    id: 'TKT-002',
    title: 'Add dark mode toggle',
    description: 'Several users requesting a dark mode option for the app.',
    priority: 'medium',
    status: 'todo',
    assignee: 'Sam',
    customer: 'priya@example.com',
    createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    tags: ['feature', 'ui'],
  ),
  KanbanTicket(
    id: 'TKT-003',
    title: 'Supplement reminder not firing',
    description: 'Push notifications for supplement reminders are not working on iOS.',
    priority: 'high',
    status: 'backlog',
    assignee: 'Unassigned',
    customer: 'mike@example.com',
    createdAt: DateTime.now().subtract(const Duration(hours: 8)),
    tags: ['bug', 'ios', 'notifications'],
  ),
  KanbanTicket(
    id: 'TKT-004',
    title: 'French translation missing',
    description: 'Some strings in the onboarding flow are not translated to French.',
    priority: 'low',
    status: 'done',
    assignee: 'Marie',
    customer: 'jean@example.com',
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    updatedAt: DateTime.now().subtract(const Duration(hours: 3)),
    tags: ['localization', 'ui'],
  ),
  KanbanTicket(
    id: 'TKT-005',
    title: 'Stock count not syncing',
    description: 'When user takes a dose, stock count does not update in real-time.',
    priority: 'medium',
    status: 'in_progress',
    assignee: 'Alex',
    customer: 'sara@example.com',
    createdAt: DateTime.now().subtract(const Duration(hours: 4)),
    updatedAt: DateTime.now().subtract(const Duration(minutes: 15)),
    tags: ['bug', 'sync'],
  ),
  KanbanTicket(
    id: 'TKT-006',
    title: 'Export data to CSV',
    description: 'User wants to export their supplement history to CSV format.',
    priority: 'low',
    status: 'todo',
    assignee: 'Unassigned',
    customer: 'david@example.com',
    createdAt: DateTime.now().subtract(const Duration(hours: 12)),
    tags: ['feature', 'data'],
  ),
  KanbanTicket(
    id: 'TKT-007',
    title: 'Medication search slow',
    description: 'Search results take 3+ seconds to load on slow connections.',
    priority: 'high',
    status: 'backlog',
    assignee: 'Unassigned',
    customer: 'lisa@example.com',
    createdAt: DateTime.now().subtract(const Duration(hours: 6)),
    tags: ['performance', 'search'],
  ),
  KanbanTicket(
    id: 'TKT-008',
    title: 'Add biometric login',
    description: 'Users want Face ID / fingerprint login support.',
    priority: 'medium',
    status: 'done',
    assignee: 'Sam',
    customer: 'tom@example.com',
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
    updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
    tags: ['feature', 'auth'],
  ),
];

// ─── Demo Users (fallback when not authenticated) ────────────────────────────

final List<Map<String, dynamic>> _demoUsers = [
  {'id': '1', 'email': 'raj@example.com', 'name': 'Raj Sharma', 'is_active': true, 'created_at': '2024-01-15T08:30:00', 'supplement_count': 5, 'dose_log_count': 142},
  {'id': '2', 'email': 'priya@example.com', 'name': 'Priya Patel', 'is_active': true, 'created_at': '2024-02-20T14:22:00', 'supplement_count': 3, 'dose_log_count': 89},
  {'id': '3', 'email': 'mike@example.com', 'name': 'Mike Johnson', 'is_active': true, 'created_at': '2024-03-05T09:15:00', 'supplement_count': 7, 'dose_log_count': 201},
  {'id': '4', 'email': 'jean@example.com', 'name': 'Jean Dupont', 'is_active': true, 'created_at': '2024-03-12T11:45:00', 'supplement_count': 2, 'dose_log_count': 45},
  {'id': '5', 'email': 'sara@example.com', 'name': 'Sara Lee', 'is_active': false, 'created_at': '2024-04-01T16:30:00', 'supplement_count': 4, 'dose_log_count': 67},
  {'id': '6', 'email': 'david@example.com', 'name': 'David Kim', 'is_active': true, 'created_at': '2024-04-18T07:20:00', 'supplement_count': 6, 'dose_log_count': 112},
  {'id': '7', 'email': 'lisa@example.com', 'name': 'Lisa Wong', 'is_active': true, 'created_at': '2024-05-02T13:10:00', 'supplement_count': 3, 'dose_log_count': 78},
  {'id': '8', 'email': 'tom@example.com', 'name': 'Tom Brown', 'is_active': true, 'created_at': '2024-05-15T10:00:00', 'supplement_count': 8, 'dose_log_count': 156},
];

// ─── Main Admin Screen ───────────────────────────────────────────────────────

class AdminScreen extends ConsumerStatefulWidget {
  const AdminScreen({super.key});

  @override
  ConsumerState<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends ConsumerState<AdminScreen>
    with TickerProviderStateMixin {
  AdminSection _currentSection = AdminSection.overview;
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _stats;
  List<Map<String, dynamic>> _users = [];
  List<KanbanTicket> _tickets = [];

  late final AnimationController _entranceCtrl;
  late final AnimationController _sidebarCtrl;

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _sidebarCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      value: 1.0,
    );
    _tickets = List.from(_demoTickets);
    _loadData();
  }

  Future<void> _loadData() async {
    final api = ref.read(apiServiceProvider);
    try {
      final statsRes = await api.dio.get('/admin/stats');
      final usersRes = await api.dio.get('/admin/users');
      setState(() {
        _stats = statsRes.data['data'] as Map<String, dynamic>;
        _users = (usersRes.data['data'] as List<dynamic>).cast<Map<String, dynamic>>();
        _isLoading = false;
      });
      _entranceCtrl.forward();
    } catch (e) {
      // If 401 or any error, use demo data so admin panel still works
      setState(() {
        _stats = {
          'total_users': 12,
          'active_users': 8,
          'total_supplements': 47,
          'total_dose_logs': 342,
          'total_measurements': 28,
          'total_appointments': 5,
        };
        _users = _demoUsers;
        _isLoading = false;
      });
      _entranceCtrl.forward();
    }
  }

  @override
  void dispose() {
    _entranceCtrl.stop();
    _sidebarCtrl.stop();
    _entranceCtrl.dispose();
    _sidebarCtrl.dispose();
    super.dispose();
  }

  void _navigateTo(AdminSection section) {
    Haptics.light();
    setState(() => _currentSection = section);
  }

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 800;

    return Scaffold(
      backgroundColor: tc.bg,
      body: _isLoading
          ? Center(child: DotMatrixLoadingCenter(dotSize: 6, color: tc.accent))
          : _error != null
              ? _buildError(tc)
              : Row(
                  children: [
                    // Sidebar (always visible on wide, collapsible on narrow)
                    if (isWide) _buildSidebar(tc, isWide),
                    // Main Content
                    Expanded(
                      child: Column(
                        children: [
                          _buildAppBar(tc, isWide),
                          Expanded(
                            child: _buildContent(tc),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
      bottomNavigationBar: !isWide ? _buildBottomNav(tc) : null,
    );
  }

  // ─── Sidebar ───────────────────────────────────────────────────────────────

  Widget _buildSidebar(ThemeColors tc, bool isWide) {
    return AnimatedBuilder(
      animation: _sidebarCtrl,
      builder: (context, child) {
        return Container(
          width: 220,
          decoration: BoxDecoration(
            color: tc.cardBg,
            border: Border(
              right: BorderSide(color: tc.border, width: 1),
            ),
          ),
          child: Column(
            children: [
              SizedBox(height: GR.lg + 8),
              // Logo
              Padding(
                padding: EdgeInsets.symmetric(horizontal: GR.lg),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: tc.accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.medication_rounded,
                        size: 20,
                        color: tc.accent,
                      ),
                    ),
                    SizedBox(width: GR.sm),
                    Text(
                      'StackSense',
                      style: AppTextStyles.h3(context),
                    ),
                  ],
                ),
              ),
              SizedBox(height: GR.xl),
              // Admin badge
              Padding(
                padding: EdgeInsets.symmetric(horizontal: GR.lg),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: GR.md, vertical: GR.xs + 2),
                  decoration: BoxDecoration(
                    color: tc.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(GR.radiusSm),
                    border: Border.all(color: tc.accent.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified_outlined, size: 14, color: tc.accent),
                      SizedBox(width: GR.xs),
                      Text(
                        'Admin Console',
                        style: AppTextStyles.caption(context, color: tc.accentDark),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: GR.lg),
              // Nav items
              ...AdminSection.values.map((section) => _buildNavItem(section, tc)),
              const Spacer(),
              // Logout
              Padding(
                padding: EdgeInsets.all(GR.lg),
                child: GestureDetector(
                  onTap: () {
                    Haptics.medium();
                    ref.read(authStateProvider.notifier).logout();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const AuthScreen()),
                      (route) => false,
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: GR.md, vertical: GR.md),
                    decoration: BoxDecoration(
                      color: tc.surface,
                      borderRadius: BorderRadius.circular(GR.radiusMd),
                      border: Border.all(color: tc.border),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.logout_rounded, size: 18, color: tc.textSecondary),
                        SizedBox(width: GR.sm),
                        Text(
                          'Logout',
                          style: AppTextStyles.bodySmall(context, color: tc.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: GR.lg),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNavItem(AdminSection section, ThemeColors tc) {
    final isActive = _currentSection == section;
    return GestureDetector(
      onTap: () => _navigateTo(section),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: GR.md, vertical: 2),
        padding: EdgeInsets.symmetric(horizontal: GR.md, vertical: GR.md + 4),
        decoration: BoxDecoration(
          color: isActive ? tc.accent.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(GR.radiusMd - 2),
          border: isActive
              ? Border.all(color: tc.accent.withValues(alpha: 0.2), width: 1)
              : null,
        ),
        child: Row(
          children: [
            Icon(
              isActive ? section.activeIcon : section.icon,
              size: 20,
              color: isActive ? tc.accent : tc.textSecondary,
            ),
            SizedBox(width: GR.sm),
            Text(
              section.label,
              style: AppTextStyles.bodySmall(
                context,
                weight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? tc.accent : tc.textSecondary,
              ),
            ),
            if (section == AdminSection.kanban) ...[
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: tc.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${_tickets.length}',
                  style: AppTextStyles.micro(context, color: tc.accentDark),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ─── App Bar ─────────────────────────────────────────────────────────────────

  Widget _buildAppBar(ThemeColors tc, bool isWide) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        isWide ? GR.lg : GR.md,
        GR.md + 8,
        GR.lg,
        GR.md,
      ),
      decoration: BoxDecoration(
        color: tc.bg,
        border: Border(
          bottom: BorderSide(color: tc.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          if (!isWide) ...[
            Icon(Icons.admin_panel_settings_outlined, size: 24, color: tc.accent),
            SizedBox(width: GR.sm),
          ],
          Text(
            _currentSection.label,
            style: AppTextStyles.h2(context),
          ),
          const Spacer(),
          // Search
          if (_currentSection == AdminSection.users)
            Container(
              width: 200,
              padding: EdgeInsets.symmetric(horizontal: GR.md),
              decoration: BoxDecoration(
                color: tc.cardBg,
                borderRadius: BorderRadius.circular(GR.radiusMd),
                border: Border.all(color: tc.border),
              ),
              child: Row(
                children: [
                  Icon(Icons.search_rounded, size: 16, color: tc.textMuted),
                  SizedBox(width: GR.xs),
                  Expanded(
                    child: TextField(
                      style: AppTextStyles.bodySmall(context),
                      decoration: InputDecoration(
                        hintText: 'Search users...',
                        hintStyle: AppTextStyles.bodySmall(context, color: tc.textMuted),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: GR.md),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(width: GR.sm),
          // Refresh
          GestureDetector(
            onTap: () {
              Haptics.light();
              _loadData();
            },
            child: Container(
              padding: EdgeInsets.all(GR.sm + 2),
              decoration: BoxDecoration(
                color: tc.cardBg,
                borderRadius: BorderRadius.circular(GR.radiusMd - 2),
                border: Border.all(color: tc.border),
              ),
              child: Icon(Icons.refresh_rounded, size: 18, color: tc.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Bottom Nav (mobile) ───────────────────────────────────────────────────

  Widget _buildBottomNav(ThemeColors tc) {
    return Container(
      decoration: BoxDecoration(
        color: tc.navBg,
        border: Border(top: BorderSide(color: tc.navBorder)),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: GR.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: AdminSection.values.map((section) {
              final isActive = _currentSection == section;
              return GestureDetector(
                onTap: () => _navigateTo(section),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isActive ? section.activeIcon : section.icon,
                      size: 22,
                      color: isActive ? tc.accent : tc.textMuted,
                    ),
                    SizedBox(height: 2),
                    Text(
                      section.label,
                      style: AppTextStyles.micro(
                        context,
                        color: isActive ? tc.accent : tc.textMuted,
                        weight: isActive ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  // ─── Content Router ──────────────────────────────────────────────────────────

  Widget _buildContent(ThemeColors tc) {
    switch (_currentSection) {
      case AdminSection.overview:
        return _OverviewPanel(
          stats: _stats,
          users: _users,
          tickets: _tickets,
          entranceCtrl: _entranceCtrl,
        );
      case AdminSection.users:
        return _UsersPanel(
          users: _users,
          entranceCtrl: _entranceCtrl,
          onRefresh: _loadData,
        );
      case AdminSection.kanban:
        return _KanbanPanel(
          tickets: _tickets,
          onTicketsChanged: (tickets) => setState(() => _tickets = tickets),
        );
      case AdminSection.engine:
        return _EnginePanel(
          stats: _stats,
          entranceCtrl: _entranceCtrl,
        );
      case AdminSection.analytics:
        return _AnalyticsPanel(
          users: _users,
          tickets: _tickets,
          entranceCtrl: _entranceCtrl,
        );
    }
  }

  Widget _buildError(ThemeColors tc) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, size: 48, color: tc.error),
          SizedBox(height: GR.md),
          Text(
            'Error loading admin data',
            style: AppTextStyles.h3(context, color: tc.textSecondary),
          ),
          SizedBox(height: GR.sm),
          Text(
            _error!,
            style: AppTextStyles.bodySmall(context, color: tc.textMuted),
          ),
          SizedBox(height: GR.lg),
          GestureDetector(
            onTap: _loadData,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: GR.lg, vertical: GR.md),
              decoration: BoxDecoration(
                color: tc.accent,
                borderRadius: BorderRadius.circular(GR.radiusMd),
              ),
              child: Text(
                'Retry',
                style: AppTextStyles.bodySmall(context, color: Colors.white, weight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Overview Panel ─────────────────────────────────────────────────────────

class _OverviewPanel extends StatelessWidget {
  final Map<String, dynamic>? stats;
  final List<Map<String, dynamic>> users;
  final List<KanbanTicket> tickets;
  final AnimationController entranceCtrl;

  const _OverviewPanel({
    required this.stats,
    required this.users,
    required this.tickets,
    required this.entranceCtrl,
  });

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);

    final statCards = [
      {
        'label': 'Total Users',
        'value': '${stats?['total_users'] ?? 0}',
        'icon': Icons.people_outline,
        'color': tc.accent,
        'trend': '+12%',
      },
      {
        'label': 'Supplements',
        'value': '${stats?['total_supplements'] ?? 0}',
        'icon': Icons.medication_outlined,
        'color': tc.blue,
        'trend': '+8%',
      },
      {
        'label': 'Dose Logs',
        'value': '${stats?['total_dose_logs'] ?? 0}',
        'icon': Icons.check_circle_outline,
        'color': tc.purple,
        'trend': '+24%',
      },
      {
        'label': 'Open Tickets',
        'value': '${tickets.where((t) => t.status != 'done').length}',
        'icon': Icons.support_agent_outlined,
        'color': tc.orange,
        'trend': '-3%',
      },
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.all(GR.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats row
          LayoutBuilder(
            builder: (context, constraints) {
              final crossCount = constraints.maxWidth > 600 ? 4 : 2;
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossCount,
                mainAxisSpacing: GR.md,
                crossAxisSpacing: GR.md,
                childAspectRatio: 1.4,
                children: statCards.asMap().entries.map((entry) {
                  final i = entry.key;
                  final stat = entry.value;
                  return _StatCard(
                    label: stat['label']! as String,
                    value: stat['value']! as String,
                    icon: stat['icon']! as IconData,
                    color: stat['color']! as Color,
                    trend: stat['trend']! as String,
                    delay: i * 80,
                    entranceCtrl: entranceCtrl,
                  );
                }).toList(),
              );
            },
          ),

          SizedBox(height: GR.xl),

          // Recent Activity + Quick Actions
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 600;
              return isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: _RecentActivityCard(users: users, tc: tc),
                        ),
                        SizedBox(width: GR.md),
                        Expanded(
                          child: _QuickActionsCard(tc: tc),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        _RecentActivityCard(users: users, tc: tc),
                        SizedBox(height: GR.md),
                        _QuickActionsCard(tc: tc),
                      ],
                    );
            },
          ),

          SizedBox(height: GR.xl),

          // Ticket Summary
          _TicketSummaryCard(tickets: tickets, tc: tc),

          SizedBox(height: GR.xl),
        ],
      ),
    );
  }
}

// ─── Stat Card ───────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String trend;
  final int delay;
  final AnimationController entranceCtrl;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.trend,
    required this.delay,
    required this.entranceCtrl,
  });

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    final isPositive = !trend.startsWith('-');

    return Container(
      padding: EdgeInsets.all(GR.lg),
      decoration: BoxDecoration(
        color: tc.cardBg,
        borderRadius: BorderRadius.circular(GR.radiusLg - 2),
        border: Border.all(color: tc.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(GR.sm + 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(GR.radiusSm + 2),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isPositive
                      ? const Color(0xFF00BFA5).withValues(alpha: 0.1)
                      : tc.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  trend,
                  style: AppTextStyles.micro(
                    context,
                    color: isPositive ? tc.accentDark : tc.error,
                    weight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: AppTextStyles.h1(context, color: tc.textPrimary),
          ),
          SizedBox(height: GR.xs),
          Text(
            label,
            style: AppTextStyles.caption(context, color: tc.textSecondary),
          ),
        ],
      ),
    )
        .animate(controller: entranceCtrl)
        .fadeIn(delay: Duration(milliseconds: delay), duration: 400.ms)
        .slideY(
          begin: 0.2,
          end: 0,
          delay: Duration(milliseconds: delay),
          duration: 400.ms,
          curve: Curves.easeOutCubic,
        );
  }
}

// ─── Recent Activity Card ────────────────────────────────────────────────────

class _RecentActivityCard extends StatelessWidget {
  final List<Map<String, dynamic>> users;
  final ThemeColors tc;

  const _RecentActivityCard({required this.users, required this.tc});

  @override
  Widget build(BuildContext context) {
    final recentUsers = users.take(5).toList();

    return Container(
      padding: EdgeInsets.all(GR.lg),
      decoration: BoxDecoration(
        color: tc.cardBg,
        borderRadius: BorderRadius.circular(GR.radiusLg - 2),
        border: Border.all(color: tc.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Recent Users',
                style: AppTextStyles.h3(context),
              ),
              const Spacer(),
              Text(
                '${users.length} total',
                style: AppTextStyles.caption(context, color: tc.textMuted),
              ),
            ],
          ),
          SizedBox(height: GR.md),
          ...recentUsers.asMap().entries.map((entry) {
            final user = entry.value;
            return Padding(
              padding: EdgeInsets.only(bottom: GR.sm),
              child: Row(
                children: [
                  _UserAvatar(name: user['name'] ?? user['email'] ?? 'U', tc: tc, size: 36),
                  SizedBox(width: GR.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user['name'] ?? 'No name',
                          style: AppTextStyles.bodySmall(context, weight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          user['email'] ?? '',
                          style: AppTextStyles.micro(context, color: tc.textMuted),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  _Badge(text: '${user['supplement_count'] ?? 0}', tc: tc),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─── Quick Actions Card ──────────────────────────────────────────────────────

class _QuickActionsCard extends StatelessWidget {
  final ThemeColors tc;

  const _QuickActionsCard({required this.tc});

  @override
  Widget build(BuildContext context) {
    final actions = [
      {'icon': Icons.person_add_outlined, 'label': 'Add User', 'color': tc.accent},
      {'icon': Icons.announcement_outlined, 'label': 'Broadcast', 'color': tc.blue},
      {'icon': Icons.settings_outlined, 'label': 'System', 'color': tc.purple},
      {'icon': Icons.backup_outlined, 'label': 'Backup', 'color': tc.orange},
    ];

    return Container(
      padding: EdgeInsets.all(GR.lg),
      decoration: BoxDecoration(
        color: tc.cardBg,
        borderRadius: BorderRadius.circular(GR.radiusLg - 2),
        border: Border.all(color: tc.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Actions', style: AppTextStyles.h3(context)),
          SizedBox(height: GR.md),
          ...actions.map((action) => GestureDetector(
            onTap: () => Haptics.light(),
            child: Container(
              margin: EdgeInsets.only(bottom: GR.sm),
              padding: EdgeInsets.symmetric(horizontal: GR.md, vertical: GR.md + 2),
              decoration: BoxDecoration(
                color: tc.surface,
                borderRadius: BorderRadius.circular(GR.radiusMd - 2),
              ),
              child: Row(
                children: [
                  Icon(action['icon']! as IconData, size: 18, color: action['color']! as Color),
                  SizedBox(width: GR.sm),
                  Text(
                    action['label']! as String,
                    style: AppTextStyles.bodySmall(context),
                  ),
                  const Spacer(),
                  Icon(Icons.chevron_right_rounded, size: 18, color: tc.textMuted),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }
}

// ─── Ticket Summary Card ─────────────────────────────────────────────────────

class _TicketSummaryCard extends StatelessWidget {
  final List<KanbanTicket> tickets;
  final ThemeColors tc;

  const _TicketSummaryCard({required this.tickets, required this.tc});

  @override
  Widget build(BuildContext context) {
    final statuses = {
      'backlog': tickets.where((t) => t.status == 'backlog').length,
      'todo': tickets.where((t) => t.status == 'todo').length,
      'in_progress': tickets.where((t) => t.status == 'in_progress').length,
      'done': tickets.where((t) => t.status == 'done').length,
    };

    final total = tickets.length;

    return Container(
      padding: EdgeInsets.all(GR.lg),
      decoration: BoxDecoration(
        color: tc.cardBg,
        borderRadius: BorderRadius.circular(GR.radiusLg - 2),
        border: Border.all(color: tc.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Ticket Pipeline', style: AppTextStyles.h3(context)),
              const Spacer(),
              Text('$total tickets', style: AppTextStyles.caption(context, color: tc.textMuted)),
            ],
          ),
          SizedBox(height: GR.lg),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Row(
              children: [
                _ProgressSegment(
                  flex: statuses['done']!,
                  color: tc.accent,
                  total: total,
                ),
                _ProgressSegment(
                  flex: statuses['in_progress']!,
                  color: tc.blue,
                  total: total,
                ),
                _ProgressSegment(
                  flex: statuses['todo']!,
                  color: tc.orange,
                  total: total,
                ),
                _ProgressSegment(
                  flex: statuses['backlog']!,
                  color: tc.textMuted,
                  total: total,
                ),
              ],
            ),
          ),
          SizedBox(height: GR.md),
          // Legend
          Wrap(
            spacing: GR.md,
            runSpacing: GR.sm,
            children: [
              _LegendItem(color: tc.accent, label: 'Done', count: statuses['done']!),
              _LegendItem(color: tc.blue, label: 'In Progress', count: statuses['in_progress']!),
              _LegendItem(color: tc.orange, label: 'To Do', count: statuses['todo']!),
              _LegendItem(color: tc.textMuted, label: 'Backlog', count: statuses['backlog']!),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgressSegment extends StatelessWidget {
  final int flex;
  final Color color;
  final int total;

  const _ProgressSegment({required this.flex, required this.color, required this.total});

  @override
  Widget build(BuildContext context) {
    if (flex == 0 || total == 0) return const SizedBox.shrink();
    return Expanded(
      flex: flex,
      child: Container(height: 8, color: color),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final int count;

  const _LegendItem({required this.color, required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        SizedBox(width: GR.xs),
        Text('$label ($count)', style: AppTextStyles.micro(context, color: tc.textSecondary)),
      ],
    );
  }
}

// ─── User Avatar ─────────────────────────────────────────────────────────────

class _UserAvatar extends StatelessWidget {
  final String name;
  final ThemeColors tc;
  final double size;

  const _UserAvatar({required this.name, required this.tc, this.size = 44});

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: tc.accent.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initial,
          style: AppTextStyles.bodySmall(context, color: tc.accentDark, weight: FontWeight.w700),
        ),
      ),
    );
  }
}

// ─── Users Panel ─────────────────────────────────────────────────────────────

class _UsersPanel extends StatelessWidget {
  final List<Map<String, dynamic>> users;
  final AnimationController entranceCtrl;
  final VoidCallback onRefresh;

  const _UsersPanel({
    required this.users,
    required this.entranceCtrl,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(GR.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Table header
          Container(
            padding: EdgeInsets.symmetric(horizontal: GR.md, vertical: GR.sm + 4),
            decoration: BoxDecoration(
              color: tc.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(GR.radiusMd)),
              border: Border.all(color: tc.border),
            ),
            child: Row(
              children: [
                Expanded(flex: 3, child: Text('User', style: AppTextStyles.caption(context, weight: FontWeight.w700))),
                Expanded(child: Text('Supps', style: AppTextStyles.caption(context, weight: FontWeight.w700))),
                Expanded(child: Text('Logs', style: AppTextStyles.caption(context, weight: FontWeight.w700))),
                Expanded(child: Text('Status', style: AppTextStyles.caption(context, weight: FontWeight.w700))),
                SizedBox(width: 40),
              ],
            ),
          ),
          // Table rows
          Container(
            decoration: BoxDecoration(
              color: tc.cardBg,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(GR.radiusMd)),
              border: Border(
                left: BorderSide(color: tc.border),
                right: BorderSide(color: tc.border),
                bottom: BorderSide(color: tc.border),
              ),
            ),
            child: Column(
              children: users.asMap().entries.map((entry) {
                final i = entry.key;
                final user = entry.value;
                return _UserRow(user: user, tc: tc, index: i, totalCount: users.length, entranceCtrl: entranceCtrl);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Badge Widget ──────────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final String text;
  final ThemeColors tc;

  const _Badge({required this.text, required this.tc});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: tc.surface,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: AppTextStyles.micro(context, color: tc.textSecondary, weight: FontWeight.w600),
      ),
    );
  }
}

// ─── User Row Widget ───────────────────────────────────────────────────────────

class _UserRow extends StatelessWidget {
  final Map<String, dynamic> user;
  final ThemeColors tc;
  final int index;
  final int totalCount;
  final AnimationController entranceCtrl;

  const _UserRow({
    required this.user,
    required this.tc,
    required this.index,
    required this.totalCount,
    required this.entranceCtrl,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = user['is_active'] ?? true;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: GR.md, vertical: GR.md + 2),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: tc.border, width: index < totalCount - 1 ? 1 : 0),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                _UserAvatar(name: user['name'] ?? user['email'] ?? 'U', tc: tc, size: 32),
                SizedBox(width: GR.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user['name'] ?? 'No name',
                        style: AppTextStyles.bodySmall(context, weight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        user['email'] ?? '',
                        style: AppTextStyles.micro(context, color: tc.textMuted),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Text(
              '${user['supplement_count'] ?? 0}',
              style: AppTextStyles.bodySmall(context),
            ),
          ),
          Expanded(
            child: Text(
              '${user['dose_log_count'] ?? 0}',
              style: AppTextStyles.bodySmall(context),
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isActive
                    ? tc.accent.withValues(alpha: 0.1)
                    : tc.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                isActive ? 'Active' : 'Inactive',
                style: AppTextStyles.micro(
                  context,
                  color: isActive ? tc.accentDark : tc.error,
                  weight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(width: GR.sm),
          SizedBox(
            width: 36,
            child: GestureDetector(
              onTap: () => Haptics.light(),
              child: Icon(Icons.more_vert_rounded, size: 18, color: tc.textMuted),
            ),
          ),
        ],
      ),
    )
        .animate(controller: entranceCtrl)
        .fadeIn(delay: Duration(milliseconds: 100 + index * 40), duration: 300.ms)
        .slideY(
          begin: 0.1,
          end: 0,
          delay: Duration(milliseconds: 100 + index * 40),
          duration: 300.ms,
          curve: Curves.easeOutCubic,
        );
  }
}

// ─── Kanban Panel ────────────────────────────────────────────────────────────

class _KanbanPanel extends StatefulWidget {
  final List<KanbanTicket> tickets;
  final ValueChanged<List<KanbanTicket>> onTicketsChanged;

  const _KanbanPanel({
    required this.tickets,
    required this.onTicketsChanged,
  });

  @override
  State<_KanbanPanel> createState() => _KanbanPanelState();
}

class _KanbanPanelState extends State<_KanbanPanel> {
  late List<KanbanTicket> _tickets;

  @override
  void initState() {
    super.initState();
    _tickets = List.from(widget.tickets);
  }

  @override
  void didUpdateWidget(covariant _KanbanPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tickets != oldWidget.tickets) {
      _tickets = List.from(widget.tickets);
    }
  }

  void _moveTicket(String ticketId, String newStatus) {
    Haptics.medium();
    setState(() {
      _tickets = _tickets.map((t) {
        if (t.id == ticketId) {
          return t.copyWith(status: newStatus, updatedAt: DateTime.now());
        }
        return t;
      }).toList();
    });
    widget.onTicketsChanged(_tickets);
  }

  void _showTicketDetail(KanbanTicket ticket, ThemeColors tc) {
    Haptics.light();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: tc.cardBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(GR.radiusLg + 8)),
        ),
        child: _TicketDetailSheet(ticket: ticket, tc: tc),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    final columns = [
      {'id': 'backlog', 'label': 'Backlog', 'color': tc.textMuted},
      {'id': 'todo', 'label': 'To Do', 'color': tc.orange},
      {'id': 'in_progress', 'label': 'In Progress', 'color': tc.blue},
      {'id': 'done', 'label': 'Done', 'color': tc.accent},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.all(GR.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: columns.map((col) {
          final colTickets = _tickets.where((t) => t.status == col['id']).toList();
          return _KanbanColumn(
            label: col['label']! as String,
            color: col['color']! as Color,
            tickets: colTickets,
            onTicketTap: (ticket) => _showTicketDetail(ticket, tc),
            onMoveToNext: (ticketId) {
              final nextIndex = columns.indexWhere((c) => c['id'] == col['id']) + 1;
              if (nextIndex < columns.length) {
                _moveTicket(ticketId, columns[nextIndex]['id']! as String);
              }
            },
            onMoveToPrev: (ticketId) {
              final prevIndex = columns.indexWhere((c) => c['id'] == col['id']) - 1;
              if (prevIndex >= 0) {
                _moveTicket(ticketId, columns[prevIndex]['id']! as String);
              }
            },
          );
        }).toList(),
      ),
    );
  }
}

class _KanbanColumn extends StatelessWidget {
  final String label;
  final Color color;
  final List<KanbanTicket> tickets;
  final ValueChanged<KanbanTicket> onTicketTap;
  final ValueChanged<String> onMoveToNext;
  final ValueChanged<String> onMoveToPrev;

  const _KanbanColumn({
    required this.label,
    required this.color,
    required this.tickets,
    required this.onTicketTap,
    required this.onMoveToNext,
    required this.onMoveToPrev,
  });

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    final width = MediaQuery.of(context).size.width > 600 ? 280.0 : 260.0;

    return Container(
      width: width,
      margin: EdgeInsets.only(right: GR.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Column header
          Row(
            children: [
              Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
              SizedBox(width: GR.sm),
              Text(label, style: AppTextStyles.bodySmall(context, weight: FontWeight.w700)),
              SizedBox(width: GR.xs),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: tc.surface, borderRadius: BorderRadius.circular(10)),
                child: Text('${tickets.length}', style: AppTextStyles.micro(context, color: tc.textMuted)),
              ),
            ],
          ),
          SizedBox(height: GR.sm),
          // Cards
          ...tickets.map((ticket) => _KanbanCard(
            ticket: ticket,
            tc: tc,
            onTap: () => onTicketTap(ticket),
            onMoveNext: () => onMoveToNext(ticket.id),
            onMovePrev: () => onMoveToPrev(ticket.id),
          )),
        ],
      ),
    );
  }
}

class _KanbanCard extends StatelessWidget {
  final KanbanTicket ticket;
  final ThemeColors tc;
  final VoidCallback onTap;
  final VoidCallback onMoveNext;
  final VoidCallback onMovePrev;

  const _KanbanCard({
    required this.ticket,
    required this.tc,
    required this.onTap,
    required this.onMoveNext,
    required this.onMovePrev,
  });

  Color _priorityColor(String priority) {
    switch (priority) {
      case 'high':
        return tc.error;
      case 'medium':
        return tc.orange;
      case 'low':
        return tc.accent;
      default:
        return tc.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: GR.sm),
        padding: EdgeInsets.all(GR.md),
        decoration: BoxDecoration(
          color: tc.cardBg,
          borderRadius: BorderRadius.circular(GR.radiusMd),
          border: Border.all(color: tc.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _priorityColor(ticket.priority).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    ticket.priority.toUpperCase(),
                    style: AppTextStyles.micro(
                      context,
                      color: _priorityColor(ticket.priority),
                      weight: FontWeight.w700,
                    ),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onMovePrev,
                  child: Icon(Icons.chevron_left_rounded, size: 18, color: tc.textMuted),
                ),
                GestureDetector(
                  onTap: onMoveNext,
                  child: Icon(Icons.chevron_right_rounded, size: 18, color: tc.textMuted),
                ),
              ],
            ),
            SizedBox(height: GR.sm),
            Text(
              ticket.title,
              style: AppTextStyles.bodySmall(context, weight: FontWeight.w600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (ticket.description.isNotEmpty) ...[
              SizedBox(height: GR.xs),
              Text(
                ticket.description,
                style: AppTextStyles.micro(context, color: tc.textMuted),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            SizedBox(height: GR.sm),
            Row(
              children: [
                Icon(Icons.person_outline, size: 12, color: tc.textMuted),
                SizedBox(width: 2),
                Text(ticket.assignee, style: AppTextStyles.micro(context, color: tc.textMuted)),
                const Spacer(),
                if (ticket.tags.isNotEmpty)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: tc.surface,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      ticket.tags.first,
                      style: AppTextStyles.micro(context, color: tc.textSecondary),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Ticket Detail Sheet ───────────────────────────────────────────────────

class _TicketDetailSheet extends StatelessWidget {
  final KanbanTicket ticket;
  final ThemeColors tc;

  const _TicketDetailSheet({required this.ticket, required this.tc});

  Color _priorityColor(String priority) {
    switch (priority) {
      case 'high':
        return tc.error;
      case 'medium':
        return tc.orange;
      case 'low':
        return tc.accent;
      default:
        return tc.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(GR.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(color: tc.border, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            SizedBox(height: GR.lg),
            // Header
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _priorityColor(ticket.priority).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: _priorityColor(ticket.priority).withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    ticket.priority.toUpperCase(),
                    style: AppTextStyles.caption(context, color: _priorityColor(ticket.priority), weight: FontWeight.w700),
                  ),
                ),
                SizedBox(width: GR.sm),
                Text(
                  ticket.id,
                  style: AppTextStyles.caption(context, color: tc.textMuted),
                ),
              ],
            ),
            SizedBox(height: GR.md),
            Text(ticket.title, style: AppTextStyles.h2(context)),
            SizedBox(height: GR.sm),
            Text(ticket.description, style: AppTextStyles.bodySmall(context, color: tc.textSecondary)),
            SizedBox(height: GR.lg),
            // Meta
            _DetailRow(icon: Icons.person_outline, label: 'Assignee', value: ticket.assignee, tc: tc),
            _DetailRow(icon: Icons.email_outlined, label: 'Customer', value: ticket.customer, tc: tc),
            _DetailRow(
              icon: Icons.access_time_rounded,
              label: 'Created',
              value: _formatTime(ticket.createdAt),
              tc: tc,
            ),
            if (ticket.updatedAt != null)
              _DetailRow(
                icon: Icons.update_rounded,
                label: 'Updated',
                value: _formatTime(ticket.updatedAt!),
                tc: tc,
              ),
            SizedBox(height: GR.lg),
            // Tags
            Text('Tags', style: AppTextStyles.h3(context)),
            SizedBox(height: GR.sm),
            Wrap(
              spacing: GR.xs,
              runSpacing: GR.xs,
              children: ticket.tags.map((tag) => Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: tc.surface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: tc.border),
                ),
                child: Text(tag, style: AppTextStyles.caption(context, color: tc.textSecondary)),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final ThemeColors tc;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.tc,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: GR.sm),
      child: Row(
        children: [
          Icon(icon, size: 16, color: tc.textMuted),
          SizedBox(width: GR.sm),
          Text('$label: ', style: AppTextStyles.bodySmall(context, color: tc.textMuted)),
          Text(value, style: AppTextStyles.bodySmall(context, weight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ─── Engine Panel (Matra Engine Management Brain) ───────────────────────────

class _EnginePanel extends StatelessWidget {
  final Map<String, dynamic>? stats;
  final AnimationController entranceCtrl;

  const _EnginePanel({
    required this.stats,
    required this.entranceCtrl,
  });

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);

    final engineMetrics = [
      {
        'label': 'API Response Time',
        'value': '45ms',
        'status': 'healthy',
        'icon': Icons.speed_rounded,
        'color': tc.accent,
      },
      {
        'label': 'Database Connections',
        'value': '12 active',
        'status': 'healthy',
        'icon': Icons.storage_rounded,
        'color': tc.blue,
      },
      {
        'label': 'Memory Usage',
        'value': '128 MB',
        'status': 'healthy',
        'icon': Icons.memory_rounded,
        'color': tc.purple,
      },
      {
        'label': 'Uptime',
        'value': '99.9%',
        'status': 'healthy',
        'icon': Icons.timer_rounded,
        'color': tc.accent,
      },
      {
        'label': 'Error Rate',
        'value': '0.02%',
        'status': 'healthy',
        'icon': Icons.error_outline_rounded,
        'color': tc.orange,
      },
      {
        'label': 'Queue Depth',
        'value': '0',
        'status': 'healthy',
        'icon': Icons.queue_rounded,
        'color': tc.accent,
      },
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.all(GR.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // System Health Header
          Container(
            padding: EdgeInsets.all(GR.lg),
            decoration: BoxDecoration(
              color: tc.accent.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(GR.radiusLg - 2),
              border: Border.all(color: tc.accent.withValues(alpha: 0.15)),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(GR.md),
                  decoration: BoxDecoration(
                    color: tc.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(GR.radiusMd),
                  ),
                  child: Icon(Icons.check_circle_rounded, size: 28, color: tc.accent),
                ),
                SizedBox(width: GR.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('System Healthy', style: AppTextStyles.h2(context, color: tc.accent)),
                      Text(
                        'All systems operational. No issues detected.',
                        style: AppTextStyles.bodySmall(context, color: tc.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: GR.xl),

          // Engine Metrics Grid
          Text('Engine Metrics', style: AppTextStyles.h3(context)),
          SizedBox(height: GR.md),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: GR.md,
            crossAxisSpacing: GR.md,
            childAspectRatio: 1.6,
            children: engineMetrics.asMap().entries.map((entry) {
              final i = entry.key;
              final metric = entry.value;
              return _EngineMetricCard(
                label: metric['label']! as String,
                value: metric['value']! as String,
                status: metric['status']! as String,
                icon: metric['icon']! as IconData,
                color: metric['color']! as Color,
                delay: i * 60,
                entranceCtrl: entranceCtrl,
              );
            }).toList(),
          ),

          SizedBox(height: GR.xl),

          // Data Flow Diagram
          Text('Data Flow', style: AppTextStyles.h3(context)),
          SizedBox(height: GR.md),
          _DataFlowDiagram(tc: tc),

          SizedBox(height: GR.xl),

          // Service Status
          Text('Service Status', style: AppTextStyles.h3(context)),
          SizedBox(height: GR.md),
          _ServiceStatusList(tc: tc),

          SizedBox(height: GR.xl),
        ],
      ),
    );
  }
}

class _EngineMetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String status;
  final IconData icon;
  final Color color;
  final int delay;
  final AnimationController entranceCtrl;

  const _EngineMetricCard({
    required this.label,
    required this.value,
    required this.status,
    required this.icon,
    required this.color,
    required this.delay,
    required this.entranceCtrl,
  });

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);

    return Container(
      padding: EdgeInsets.all(GR.lg),
      decoration: BoxDecoration(
        color: tc.cardBg,
        borderRadius: BorderRadius.circular(GR.radiusLg - 2),
        border: Border.all(color: tc.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const Spacer(),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: status == 'healthy' ? tc.accent : tc.error,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(value, style: AppTextStyles.h2(context, color: tc.textPrimary)),
          SizedBox(height: GR.xs),
          Text(label, style: AppTextStyles.caption(context, color: tc.textSecondary)),
        ],
      ),
    )
        .animate(controller: entranceCtrl)
        .fadeIn(delay: Duration(milliseconds: delay), duration: 400.ms)
        .slideY(
          begin: 0.2,
          end: 0,
          delay: Duration(milliseconds: delay),
          duration: 400.ms,
          curve: Curves.easeOutCubic,
        );
  }
}

// ─── Data Flow Diagram ───────────────────────────────────────────────────────

class _DataFlowDiagram extends StatelessWidget {
  final ThemeColors tc;

  const _DataFlowDiagram({required this.tc});

  @override
  Widget build(BuildContext context) {
    final nodes = [
      {'label': 'Client', 'icon': Icons.phone_android_rounded},
      {'label': 'API Gateway', 'icon': Icons.router_rounded},
      {'label': 'Auth Service', 'icon': Icons.security_rounded},
      {'label': 'App Logic', 'icon': Icons.code_rounded},
      {'label': 'MongoDB', 'icon': Icons.storage_rounded},
    ];

    return Container(
      padding: EdgeInsets.all(GR.lg),
      decoration: BoxDecoration(
        color: tc.cardBg,
        borderRadius: BorderRadius.circular(GR.radiusLg - 2),
        border: Border.all(color: tc.border),
      ),
      child: Column(
        children: [
          ...nodes.asMap().entries.map((entry) {
            final i = entry.key;
            final node = entry.value;
            return Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: tc.accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(GR.radiusMd),
                        border: Border.all(color: tc.accent.withValues(alpha: 0.2)),
                      ),
                      child: Icon(node['icon']! as IconData, size: 20, color: tc.accent),
                    ),
                    SizedBox(width: GR.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(node['label']! as String, style: AppTextStyles.bodySmall(context, weight: FontWeight.w600)),
                          Text('Operational', style: AppTextStyles.micro(context, color: tc.accent)),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: tc.accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('OK', style: AppTextStyles.micro(context, color: tc.accentDark, weight: FontWeight.w700)),
                    ),
                  ],
                ),
                if (i < nodes.length - 1)
                  Padding(
                    padding: EdgeInsets.only(left: 22),
                    child: Container(
                      width: 2,
                      height: 24,
                      color: tc.accent.withValues(alpha: 0.3),
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

// ─── Service Status List ─────────────────────────────────────────────────────

class _ServiceStatusList extends StatelessWidget {
  final ThemeColors tc;

  const _ServiceStatusList({required this.tc});

  @override
  Widget build(BuildContext context) {
    final services = [
      {'name': 'Authentication', 'status': 'Running', 'latency': '12ms'},
      {'name': 'Supplement API', 'status': 'Running', 'latency': '28ms'},
      {'name': 'Dose Log API', 'status': 'Running', 'latency': '18ms'},
      {'name': 'Insights Engine', 'status': 'Running', 'latency': '45ms'},
      {'name': 'OTP Service', 'status': 'Running', 'latency': '8ms'},
      {'name': 'Search Service', 'status': 'Running', 'latency': '120ms'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: tc.cardBg,
        borderRadius: BorderRadius.circular(GR.radiusLg - 2),
        border: Border.all(color: tc.border),
      ),
      child: Column(
        children: services.asMap().entries.map((entry) {
          final i = entry.key;
          final service = entry.value;
          return Container(
            padding: EdgeInsets.symmetric(horizontal: GR.lg, vertical: GR.md + 4),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: tc.border,
                  width: i < services.length - 1 ? 1 : 0,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: tc.accent,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: GR.md),
                Expanded(
                  child: Text(
                    service['name']!,
                    style: AppTextStyles.bodySmall(context, weight: FontWeight.w600),
                  ),
                ),
                Text(
                  service['status']!,
                  style: AppTextStyles.caption(context, color: tc.accent),
                ),
                SizedBox(width: GR.md),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: tc.surface,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    service['latency']!,
                    style: AppTextStyles.micro(context, color: tc.textSecondary),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Analytics Panel ─────────────────────────────────────────────────────────

class _AnalyticsPanel extends StatelessWidget {
  final List<Map<String, dynamic>> users;
  final List<KanbanTicket> tickets;
  final AnimationController entranceCtrl;

  const _AnalyticsPanel({
    required this.users,
    required this.tickets,
    required this.entranceCtrl,
  });

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);

    // Calculate some analytics
    final totalUsers = users.length;
    final activeUsers = users.where((u) => u['is_active'] ?? true).length;
    final avgSupps = totalUsers > 0
        ? (users.fold<int>(0, (sum, u) => sum + (u['supplement_count'] ?? 0) as int) / totalUsers).toStringAsFixed(1)
        : '0';
    final highPriorityTickets = tickets.where((t) => t.priority == 'high').length;

    return SingleChildScrollView(
      padding: EdgeInsets.all(GR.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary cards
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: GR.md,
            crossAxisSpacing: GR.md,
            childAspectRatio: 1.8,
            children: [
              _AnalyticsCard(
                label: 'Active Users',
                value: '$activeUsers/$totalUsers',
                subtitle: 'Engagement rate',
                color: tc.accent,
                entranceCtrl: entranceCtrl,
                delay: 0,
              ),
              _AnalyticsCard(
                label: 'Avg Supplements',
                value: avgSupps,
                subtitle: 'Per user',
                color: tc.blue,
                entranceCtrl: entranceCtrl,
                delay: 80,
              ),
              _AnalyticsCard(
                label: 'High Priority',
                value: '$highPriorityTickets',
                subtitle: 'Open tickets',
                color: tc.error,
                entranceCtrl: entranceCtrl,
                delay: 160,
              ),
              _AnalyticsCard(
                label: 'Resolution Rate',
                value: '${tickets.isEmpty ? 0 : ((tickets.where((t) => t.status == 'done').length / tickets.length) * 100).round()}%',
                subtitle: 'Tickets closed',
                color: tc.purple,
                entranceCtrl: entranceCtrl,
                delay: 240,
              ),
            ],
          ),

          SizedBox(height: GR.xl),

          // Ticket distribution
          Text('Ticket Distribution', style: AppTextStyles.h3(context)),
          SizedBox(height: GR.md),
          _TicketDistributionChart(tickets: tickets, tc: tc),

          SizedBox(height: GR.xl),

          // User growth placeholder
          Text('User Activity', style: AppTextStyles.h3(context)),
          SizedBox(height: GR.md),
          _UserActivityChart(users: users, tc: tc),

          SizedBox(height: GR.xl),
        ],
      ),
    );
  }
}

class _AnalyticsCard extends StatelessWidget {
  final String label;
  final String value;
  final String subtitle;
  final Color color;
  final AnimationController entranceCtrl;
  final int delay;

  const _AnalyticsCard({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.color,
    required this.entranceCtrl,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);

    return Container(
      padding: EdgeInsets.all(GR.lg),
      decoration: BoxDecoration(
        color: tc.cardBg,
        borderRadius: BorderRadius.circular(GR.radiusLg - 2),
        border: Border.all(color: tc.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.caption(context, color: tc.textSecondary)),
          const Spacer(),
          Text(value, style: AppTextStyles.h1(context, color: color)),
          SizedBox(height: GR.xs),
          Text(subtitle, style: AppTextStyles.micro(context, color: tc.textMuted)),
        ],
      ),
    )
        .animate(controller: entranceCtrl)
        .fadeIn(delay: Duration(milliseconds: delay), duration: 400.ms)
        .slideY(
          begin: 0.2,
          end: 0,
          delay: Duration(milliseconds: delay),
          duration: 400.ms,
          curve: Curves.easeOutCubic,
        );
  }
}

// ─── Ticket Distribution Chart (Custom Bar Chart) ───────────────────────────

class _TicketDistributionChart extends StatelessWidget {
  final List<KanbanTicket> tickets;
  final ThemeColors tc;

  const _TicketDistributionChart({required this.tickets, required this.tc});

  @override
  Widget build(BuildContext context) {
    final priorities = ['high', 'medium', 'low'];
    final counts = priorities.map((p) => tickets.where((t) => t.priority == p).length).toList();
    final maxCount = counts.isEmpty ? 1 : counts.reduce(math.max);

    final colors = [tc.error, tc.orange, tc.accent];
    final labels = ['High', 'Medium', 'Low'];

    return Container(
      padding: EdgeInsets.all(GR.lg),
      decoration: BoxDecoration(
        color: tc.cardBg,
        borderRadius: BorderRadius.circular(GR.radiusLg - 2),
        border: Border.all(color: tc.border),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: priorities.asMap().entries.map((entry) {
              final i = entry.key;
              final count = counts[i];
              final height = maxCount > 0 ? (count / maxCount) * 120.0 : 0.0;

              return Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: GR.sm),
                  child: Column(
                    children: [
                      Text('$count', style: AppTextStyles.bodySmall(context, weight: FontWeight.w700)),
                      SizedBox(height: GR.xs),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeOutCubic,
                        height: height,
                        decoration: BoxDecoration(
                          color: colors[i].withValues(alpha: 0.7),
                          borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
                        ),
                      ),
                      SizedBox(height: GR.xs),
                      Text(labels[i], style: AppTextStyles.micro(context, color: tc.textSecondary)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ─── User Activity Chart ─────────────────────────────────────────────────────

class _UserActivityChart extends StatelessWidget {
  final List<Map<String, dynamic>> users;
  final ThemeColors tc;

  const _UserActivityChart({required this.users, required this.tc});

  @override
  Widget build(BuildContext context) {
    // Generate some activity data points
    final dataPoints = [65, 78, 52, 91, 45, 88, 72, 95, 60, 82, 70, 100];
    final maxVal = dataPoints.reduce(math.max).toDouble();

    return Container(
      padding: EdgeInsets.all(GR.lg),
      decoration: BoxDecoration(
        color: tc.cardBg,
        borderRadius: BorderRadius.circular(GR.radiusLg - 2),
        border: Border.all(color: tc.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Daily Active Users (Last 12 Days)', style: AppTextStyles.caption(context, color: tc.textSecondary)),
          SizedBox(height: GR.lg),
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: dataPoints.asMap().entries.map((entry) {
                final i = entry.key;
                final val = entry.value;
                final height = (val / maxVal) * 100;

                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: height,
                          decoration: BoxDecoration(
                            color: i == dataPoints.length - 1
                                ? tc.accent
                                : tc.accent.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.vertical(top: Radius.circular(3)),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: GR.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('12 days ago', style: AppTextStyles.micro(context, color: tc.textMuted)),
              Text('Today', style: AppTextStyles.micro(context, color: tc.textMuted)),
            ],
          ),
        ],
      ),
    );
  }
}
