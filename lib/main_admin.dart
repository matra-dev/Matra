import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

// Haptics utility for admin app
class Haptics {
  static void light() {}
  static void medium() {}
}

// ─── Admin App Entry Point ───────────────────────────────────────────────────

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: AdminApp(),
    ),
  );
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StackSense Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0A0F),
        fontFamily: 'Artific',
        useMaterial3: true,
      ),
      home: const AdminDashboard(),
    );
  }
}

// ─── Golden Ratio Spacing ───────────────────────────────────────────────────

class GR {
  static const double phi = 1.618;
  static const double base = 8.0;

  static double get xs => base / phi;
  static double get sm => base;
  static double get md => base * phi;
  static double get lg => base * phi * phi;
  static double get xl => base * phi * phi * phi;
  static double get xxl => base * phi * phi * phi * phi;

  static double get radiusSm => xs;
  static double get radiusMd => sm;
  static double get radiusLg => md;
  static double get radiusXl => lg;

  static double get iconXs => sm;
  static double get iconSm => md;
  static double get iconMd => lg;
  static double get iconLg => xl;
}

// ─── Admin Colors ────────────────────────────────────────────────────────────

class AdminColors {
  static const bg = Color(0xFF0A0A0F);
  static const cardBg = Color(0xFF111118);
  static const surface = Color(0xFF1A1A24);
  static const surfaceElevated = Color(0xFF22222E);
  static const border = Color(0xFF2A2A36);
  static const borderLight = Color(0xFF1E1E28);
  static const divider = Color(0xFF2A2A36);

  static const textPrimary = Color(0xFFF0F0F5);
  static const textSecondary = Color(0xFF9CA3AF);
  static const textMuted = Color(0xFF6B7280);

  static const accent = Color(0xFF00E5B8);
  static const accentLight = Color(0xFF00BFA5);
  static const accentDark = Color(0xFF00897B);
  static const accentBg = Color(0xFF00BFA5);

  static const blue = Color(0xFF60A5FA);
  static const purple = Color(0xFFA78BFA);
  static const orange = Color(0xFFFB923C);
  static const red = Color(0xFFEF4444);
  static const amber = Color(0xFFFBBF24);
  static const green = Color(0xFF34D399);

  static const shadowColor = Color(0xFF000000);
}

// ─── Admin Text Styles (Golden Ratio Sized) ─────────────────────────────────

class AdminTextStyles {
  AdminTextStyles._();

  static const double _display = 42;
  static const double _h1 = 28;
  static const double _h2 = 20;
  static const double _h3 = 16;
  static const double _body = 15;
  static const double _bodySmall = 13;
  static const double _caption = 11;
  static const double _micro = 10;

  static TextStyle display({Color? color, FontWeight? weight}) => TextStyle(
    fontFamily: 'Artific',
    fontSize: _display,
    fontWeight: weight ?? FontWeight.w900,
    color: color ?? AdminColors.textPrimary,
    height: 1.0,
    letterSpacing: -1.2,
  );

  static TextStyle h1({Color? color, FontWeight? weight}) => TextStyle(
    fontFamily: 'Artific',
    fontSize: _h1,
    fontWeight: weight ?? FontWeight.w800,
    color: color ?? AdminColors.textPrimary,
    letterSpacing: -0.6,
  );

  static TextStyle h2({Color? color, FontWeight? weight}) => TextStyle(
    fontFamily: 'Artific',
    fontSize: _h2,
    fontWeight: weight ?? FontWeight.w700,
    color: color ?? AdminColors.textPrimary,
    letterSpacing: -0.3,
  );

  static TextStyle h3({Color? color, FontWeight? weight}) => TextStyle(
    fontFamily: 'Artific',
    fontSize: _h3,
    fontWeight: weight ?? FontWeight.w600,
    color: color ?? AdminColors.textPrimary,
    letterSpacing: 0.2,
  );

  static TextStyle body({Color? color, FontWeight? weight, double? height}) => TextStyle(
    fontFamily: 'Artific',
    fontSize: _body,
    fontWeight: weight ?? FontWeight.w400,
    color: color ?? AdminColors.textPrimary,
    height: height ?? 1.5,
  );

  static TextStyle bodySmall({Color? color, FontWeight? weight, double? height}) => TextStyle(
    fontFamily: 'Artific',
    fontSize: _bodySmall,
    fontWeight: weight ?? FontWeight.w400,
    color: color ?? AdminColors.textSecondary,
    height: height ?? 1.5,
  );

  static TextStyle caption({Color? color, FontWeight? weight}) => TextStyle(
    fontFamily: 'Artific',
    fontSize: _caption,
    fontWeight: weight ?? FontWeight.w600,
    color: color ?? AdminColors.textMuted,
    letterSpacing: 0.5,
  );

  static TextStyle micro({Color? color, FontWeight? weight}) => TextStyle(
    fontFamily: 'Artific',
    fontSize: _micro,
    fontWeight: weight ?? FontWeight.w500,
    color: color ?? AdminColors.textMuted,
  );
}

// ─── Section Enum ────────────────────────────────────────────────────────────

enum AdminSection {
  overview('Overview', Icons.dashboard_outlined, Icons.dashboard_rounded),
  users('Users', Icons.people_outline, Icons.people_rounded),
  kanban('Customer Care', Icons.view_kanban_outlined, Icons.view_kanban_rounded),
  engine('Matra Engine', Icons.memory_outlined, Icons.memory_rounded),
  analytics('Analytics', Icons.analytics_outlined, Icons.analytics_rounded),
  logs('Audit Logs', Icons.receipt_long_outlined, Icons.receipt_long_rounded);

  final String label;
  final IconData icon;
  final IconData activeIcon;
  const AdminSection(this.label, this.icon, this.activeIcon);
}

// ─── Demo Data ───────────────────────────────────────────────────────────────

class DemoData {
  static final stats = {
    'total_users': 1247,
    'active_users': 892,
    'new_users_today': 34,
    'total_supplements': 3842,
    'total_dose_logs': 128450,
    'total_measurements': 5621,
    'total_appointments': 234,
    'open_tickets': 18,
    'resolved_today': 7,
    'avg_session': '4m 32s',
    'retention': '78.4%',
    'churn': '2.1%',
  };

  static final users = [
    {'id': '1', 'email': 'raj.sharma@health.com', 'name': 'Raj Sharma', 'phone': '+91 98765 43210', 'is_active': true, 'created_at': '2024-01-15T08:30:00', 'supplement_count': 5, 'dose_log_count': 142, 'last_active': '2 min ago', 'plan': 'Pro'},
    {'id': '2', 'email': 'priya.patel@ gmail.com', 'name': 'Priya Patel', 'phone': '+91 98765 43211', 'is_active': true, 'created_at': '2024-02-20T14:22:00', 'supplement_count': 3, 'dose_log_count': 89, 'last_active': '15 min ago', 'plan': 'Free'},
    {'id': '3', 'email': 'mike.j@ wellness.io', 'name': 'Mike Johnson', 'phone': '+1 555 0198', 'is_active': true, 'created_at': '2024-03-05T09:15:00', 'supplement_count': 7, 'dose_log_count': 201, 'last_active': '1 hr ago', 'plan': 'Pro'},
    {'id': '4', 'email': 'jean.dupont@fr.fr', 'name': 'Jean Dupont', 'phone': '+33 6 12 34 56', 'is_active': true, 'created_at': '2024-03-12T11:45:00', 'supplement_count': 2, 'dose_log_count': 45, 'last_active': '3 hr ago', 'plan': 'Free'},
    {'id': '5', 'email': 'sara.lee@kr.co', 'name': 'Sara Lee', 'phone': '+82 10 1234 5678', 'is_active': false, 'created_at': '2024-04-01T16:30:00', 'supplement_count': 4, 'dose_log_count': 67, 'last_active': '2 days ago', 'plan': 'Pro'},
    {'id': '6', 'email': 'david.kim@jp.jp', 'name': 'David Kim', 'phone': '+81 90 1234 5678', 'is_active': true, 'created_at': '2024-04-18T07:20:00', 'supplement_count': 6, 'dose_log_count': 112, 'last_active': '5 min ago', 'plan': 'Enterprise'},
    {'id': '7', 'email': 'lisa.wong@sg.sg', 'name': 'Lisa Wong', 'phone': '+65 9123 4567', 'is_active': true, 'created_at': '2024-05-02T13:10:00', 'supplement_count': 3, 'dose_log_count': 78, 'last_active': '30 min ago', 'plan': 'Pro'},
    {'id': '8', 'email': 'tom.brown@uk.co', 'name': 'Tom Brown', 'phone': '+44 7700 900123', 'is_active': true, 'created_at': '2024-05-15T10:00:00', 'supplement_count': 8, 'dose_log_count': 156, 'last_active': 'Just now', 'plan': 'Free'},
  ];

  static final tickets = [
    {'id': 'TKT-001', 'title': 'App crash on login', 'desc': 'User reports app crashes when trying to login with phone number on Android 14.', 'priority': 'critical', 'status': 'in_progress', 'assignee': 'Alex Chen', 'customer': 'raj.sharma@health.com', 'created': '2h ago', 'tags': ['bug', 'android', 'auth']},
    {'id': 'TKT-002', 'title': 'Add dark mode toggle', 'desc': 'Several users requesting a dark mode option for the app.', 'priority': 'medium', 'status': 'todo', 'assignee': 'Sam Park', 'customer': 'priya.patel@gmail.com', 'created': '5h ago', 'tags': ['feature', 'ui']},
    {'id': 'TKT-003', 'title': 'Supplement reminder not firing', 'desc': 'Push notifications for supplement reminders are not working on iOS.', 'priority': 'high', 'status': 'backlog', 'assignee': 'Unassigned', 'customer': 'mike.j@wellness.io', 'created': '8h ago', 'tags': ['bug', 'ios', 'notifications']},
    {'id': 'TKT-004', 'title': 'French translation missing', 'desc': 'Some strings in the onboarding flow are not translated to French.', 'priority': 'low', 'status': 'done', 'assignee': 'Marie Lefevre', 'customer': 'jean.dupont@fr.fr', 'created': '1d ago', 'tags': ['localization', 'ui']},
    {'id': 'TKT-005', 'title': 'Stock count not syncing', 'desc': 'When user takes a dose, stock count does not update in real-time.', 'priority': 'high', 'status': 'in_progress', 'assignee': 'Alex Chen', 'customer': 'sara.lee@kr.co', 'created': '4h ago', 'tags': ['bug', 'sync']},
    {'id': 'TKT-006', 'title': 'Export data to CSV', 'desc': 'User wants to export their supplement history to CSV format.', 'priority': 'low', 'status': 'todo', 'assignee': 'Unassigned', 'customer': 'david.kim@jp.jp', 'created': '12h ago', 'tags': ['feature', 'data']},
    {'id': 'TKT-007', 'title': 'Medication search slow', 'desc': 'Search results take 3+ seconds to load on slow connections.', 'priority': 'high', 'status': 'backlog', 'assignee': 'Unassigned', 'customer': 'lisa.wong@sg.sg', 'created': '6h ago', 'tags': ['performance', 'search']},
    {'id': 'TKT-008', 'title': 'Add biometric login', 'desc': 'Users want Face ID / fingerprint login support.', 'priority': 'medium', 'status': 'done', 'assignee': 'Sam Park', 'customer': 'tom.brown@uk.co', 'created': '2d ago', 'tags': ['feature', 'auth']},
  ];

  static final auditLogs = [
    {'action': 'User Created', 'target': 'raj.sharma@health.com', 'by': 'System', 'time': '2 min ago', 'type': 'success'},
    {'action': 'Supplement Added', 'target': 'Vitamin D3', 'by': 'Priya Patel', 'time': '5 min ago', 'type': 'info'},
    {'action': 'Dose Logged', 'target': 'Omega-3', 'by': 'Mike Johnson', 'time': '12 min ago', 'type': 'info'},
    {'action': 'Login Failed', 'target': 'sara.lee@kr.co', 'by': 'System', 'time': '15 min ago', 'type': 'warning'},
    {'action': 'User Deleted', 'target': 'test.user@temp.com', 'by': 'Admin', 'time': '1 hr ago', 'type': 'error'},
    {'action': 'Stock Alert', 'target': 'Magnesium', 'by': 'System', 'time': '2 hr ago', 'type': 'warning'},
    {'action': 'Password Reset', 'target': 'tom.brown@uk.co', 'by': 'System', 'time': '3 hr ago', 'type': 'info'},
    {'action': 'Plan Upgraded', 'target': 'david.kim@jp.jp', 'by': 'Stripe', 'time': '5 hr ago', 'type': 'success'},
  ];
}

// ─── Main Admin Dashboard ────────────────────────────────────────────────────

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with TickerProviderStateMixin {
  AdminSection _currentSection = AdminSection.overview;
  late final AnimationController _entranceCtrl;

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _entranceCtrl.forward();
    });
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 900;

    return Scaffold(
      backgroundColor: AdminColors.bg,
      body: Row(
        children: [
          if (isWide) _buildSidebar(),
          Expanded(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(child: _buildContent()),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: !isWide ? _buildBottomNav() : null,
    );
  }

  // ─── Sidebar ───────────────────────────────────────────────────────────────

  Widget _buildSidebar() {
    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: AdminColors.cardBg,
        border: Border(right: BorderSide(color: AdminColors.border)),
      ),
      child: Column(
        children: [
          SizedBox(height: GR.lg),
          _buildLogo(),
          SizedBox(height: GR.xl),
          _buildNavItems(),
          const Spacer(),
          _buildUserProfile(),
          SizedBox(height: GR.lg),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: GR.lg),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AdminColors.accent, AdminColors.blue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(GR.radiusMd),
            ),
            child: const Icon(Icons.medication_rounded, size: 22, color: Colors.white),
          ),
          SizedBox(width: GR.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('StackSense', style: AdminTextStyles.h2()),
              Text('Management Console', style: AdminTextStyles.caption()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavItems() {
    return Column(
      children: AdminSection.values.map((section) => _buildNavItem(section)).toList(),
    );
  }

  Widget _buildNavItem(AdminSection section) {
    final isActive = _currentSection == section;
    return GestureDetector(
      onTap: () {
        Haptics.light();
        setState(() => _currentSection = section);
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: GR.md, vertical: 3),
        padding: EdgeInsets.symmetric(horizontal: GR.md, vertical: GR.md + 4),
        decoration: BoxDecoration(
          color: isActive ? AdminColors.accent.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(GR.radiusMd),
          border: isActive ? Border.all(color: AdminColors.accent.withValues(alpha: 0.2)) : null,
        ),
        child: Row(
          children: [
            Icon(
              isActive ? section.activeIcon : section.icon,
              size: 20,
              color: isActive ? AdminColors.accent : AdminColors.textMuted,
            ),
            SizedBox(width: GR.sm),
            Text(
              section.label,
              style: AdminTextStyles.bodySmall(
                weight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? AdminColors.accent : AdminColors.textMuted,
              ),
            ),
            const Spacer(),
            if (section == AdminSection.kanban)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AdminColors.red.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${DemoData.tickets.where((t) => t['status'] != 'done').length}',
                  style: AdminTextStyles.micro(color: AdminColors.red, weight: FontWeight.w700),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfile() {
    return Padding(
      padding: EdgeInsets.all(GR.md),
      child: Container(
        padding: EdgeInsets.all(GR.md),
        decoration: BoxDecoration(
          color: AdminColors.surface,
          borderRadius: BorderRadius.circular(GR.radiusLg),
          border: Border.all(color: AdminColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AdminColors.purple, AdminColors.blue],
                ),
                borderRadius: BorderRadius.circular(GR.radiusSm),
              ),
              child: const Center(
                child: Text('A', style: TextStyle(fontFamily: 'Artific', fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
            SizedBox(width: GR.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Admin User', style: AdminTextStyles.bodySmall(weight: FontWeight.w600)),
                  Text('Super Admin', style: AdminTextStyles.micro()),
                ],
              ),
            ),
            Icon(Icons.logout_rounded, size: 18, color: AdminColors.textMuted),
          ],
        ),
      ),
    );
  }

  // ─── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(GR.lg, GR.md + 8, GR.lg, GR.md),
      decoration: BoxDecoration(
        color: AdminColors.bg,
        border: Border(bottom: BorderSide(color: AdminColors.border)),
      ),
      child: Row(
        children: [
          Text(_currentSection.label, style: AdminTextStyles.h1()),
          const Spacer(),
          _buildSearchBar(),
          SizedBox(width: GR.md),
          _buildNotificationBell(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      width: 280,
      height: 40,
      padding: EdgeInsets.symmetric(horizontal: GR.md),
      decoration: BoxDecoration(
        color: AdminColors.surface,
        borderRadius: BorderRadius.circular(GR.radiusMd),
        border: Border.all(color: AdminColors.border),
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, size: 18, color: AdminColors.textMuted),
          SizedBox(width: GR.sm),
          Expanded(
            child: TextField(
              style: AdminTextStyles.bodySmall(color: AdminColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search...',
                hintStyle: AdminTextStyles.bodySmall(color: AdminColors.textMuted),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationBell() {
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.all(GR.sm + 2),
          decoration: BoxDecoration(
            color: AdminColors.surface,
            borderRadius: BorderRadius.circular(GR.radiusMd),
            border: Border.all(color: AdminColors.border),
          ),
          child: Icon(Icons.notifications_outlined, size: 20, color: AdminColors.textSecondary),
        ),
        Positioned(
          right: 6,
          top: 6,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: AdminColors.red, shape: BoxShape.circle),
          ),
        ),
      ],
    );
  }

  // ─── Bottom Nav (mobile) ───────────────────────────────────────────────────

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AdminColors.cardBg,
        border: Border(top: BorderSide(color: AdminColors.border)),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: GR.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: AdminSection.values.map((section) {
              final isActive = _currentSection == section;
              return GestureDetector(
                onTap: () => setState(() => _currentSection = section),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isActive ? section.activeIcon : section.icon,
                      size: 22,
                      color: isActive ? AdminColors.accent : AdminColors.textMuted,
                    ),
                    SizedBox(height: 2),
                    Text(
                      section.label,
                      style: AdminTextStyles.micro(
                        color: isActive ? AdminColors.accent : AdminColors.textMuted,
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

  // ─── Content Router ─────────────────────────────────────────────────────────

  Widget _buildContent() {
    switch (_currentSection) {
      case AdminSection.overview:
        return _OverviewPanel(entranceCtrl: _entranceCtrl);
      case AdminSection.users:
        return _UsersPanel(entranceCtrl: _entranceCtrl);
      case AdminSection.kanban:
        return _KanbanPanel();
      case AdminSection.engine:
        return _EnginePanel(entranceCtrl: _entranceCtrl);
      case AdminSection.analytics:
        return _AnalyticsPanel(entranceCtrl: _entranceCtrl);
      case AdminSection.logs:
        return _LogsPanel(entranceCtrl: _entranceCtrl);
    }
  }
}

// ─── Overview Panel ──────────────────────────────────────────────────────────

class _OverviewPanel extends StatelessWidget {
  final AnimationController entranceCtrl;
  const _OverviewPanel({required this.entranceCtrl});

  @override
  Widget build(BuildContext context) {
    final stats = DemoData.stats;

    final statCards = [
      {'label': 'Total Users', 'value': '${stats['total_users']}', 'change': '+12%', 'icon': Icons.people_outline, 'color': AdminColors.accent},
      {'label': 'Active Now', 'value': '${stats['active_users']}', 'change': '+5%', 'icon': Icons.trending_up_rounded, 'color': AdminColors.green},
      {'label': 'Supplements', 'value': '${stats['total_supplements']}', 'change': '+8%', 'icon': Icons.medication_outlined, 'color': AdminColors.blue},
      {'label': 'Dose Logs', 'value': '${stats['total_dose_logs']}', 'change': '+24%', 'icon': Icons.check_circle_outline, 'color': AdminColors.purple},
      {'label': 'Open Tickets', 'value': '${stats['open_tickets']}', 'change': '-3%', 'icon': Icons.support_agent_outlined, 'color': AdminColors.orange},
      {'label': 'Avg Session', 'value': '${stats['avg_session']}', 'change': '+18%', 'icon': Icons.timer_outlined, 'color': AdminColors.amber},
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.all(GR.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome
          Text('Welcome back, Admin', style: AdminTextStyles.h1()),
          SizedBox(height: GR.xs),
          Text('Here is what is happening across your platform today.', style: AdminTextStyles.bodySmall()),
          SizedBox(height: GR.xl),

          // Stats Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final crossCount = constraints.maxWidth > 700 ? 3 : 2;
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossCount,
                mainAxisSpacing: GR.md,
                crossAxisSpacing: GR.md,
                childAspectRatio: 1.5,
                children: statCards.asMap().entries.map((entry) {
                  final i = entry.key;
                  final stat = entry.value;
                  return _StatCard(
                    label: stat['label']! as String,
                    value: stat['value']! as String,
                    change: stat['change']! as String,
                    icon: stat['icon']! as IconData,
                    color: stat['color']! as Color,
                    delay: i * 80,
                    entranceCtrl: entranceCtrl,
                  );
                }).toList(),
              );
            },
          ),

          SizedBox(height: GR.xl),

          // Two column layout
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 700;
              return isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 2, child: _RecentActivityCard()),
                        SizedBox(width: GR.md),
                        Expanded(child: _QuickActionsCard()),
                      ],
                    )
                  : Column(
                      children: [
                        _RecentActivityCard(),
                        SizedBox(height: GR.md),
                        _QuickActionsCard(),
                      ],
                    );
            },
          ),

          SizedBox(height: GR.xl),

          // Ticket Pipeline
          _TicketPipelineCard(),

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
  final String change;
  final IconData icon;
  final Color color;
  final int delay;
  final AnimationController entranceCtrl;

  const _StatCard({
    required this.label,
    required this.value,
    required this.change,
    required this.icon,
    required this.color,
    required this.delay,
    required this.entranceCtrl,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = !change.startsWith('-');

    return Container(
      padding: EdgeInsets.all(GR.lg),
      decoration: BoxDecoration(
        color: AdminColors.cardBg,
        borderRadius: BorderRadius.circular(GR.radiusLg),
        border: Border.all(color: AdminColors.border),
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
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isPositive ? AdminColors.green.withValues(alpha: 0.1) : AdminColors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  change,
                  style: AdminTextStyles.micro(
                    color: isPositive ? AdminColors.green : AdminColors.red,
                    weight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(value, style: AdminTextStyles.display(color: AdminColors.textPrimary)),
          SizedBox(height: GR.xs),
          Text(label, style: AdminTextStyles.caption()),
        ],
      ),
    )
        .animate(controller: entranceCtrl)
        .fadeIn(delay: Duration(milliseconds: delay), duration: 400.ms)
        .slideY(begin: 0.2, end: 0, delay: Duration(milliseconds: delay), duration: 400.ms, curve: Curves.easeOutCubic);
  }
}

// ─── Recent Activity Card ────────────────────────────────────────────────────

class _RecentActivityCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final users = DemoData.users.take(5).toList();

    return Container(
      padding: EdgeInsets.all(GR.lg),
      decoration: BoxDecoration(
        color: AdminColors.cardBg,
        borderRadius: BorderRadius.circular(GR.radiusLg),
        border: Border.all(color: AdminColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Recent Users', style: AdminTextStyles.h2()),
              const Spacer(),
              Text('${DemoData.users.length} total', style: AdminTextStyles.caption()),
            ],
          ),
          SizedBox(height: GR.md),
          ...users.map((user) => _UserListItem(user: user)),
        ],
      ),
    );
  }
}

class _UserListItem extends StatelessWidget {
  final Map<String, dynamic> user;
  const _UserListItem({required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: GR.sm),
      child: Row(
        children: [
          _UserAvatar(name: user['name'] ?? 'U', size: 36),
          SizedBox(width: GR.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user['name'] ?? 'No name', style: AdminTextStyles.bodySmall(weight: FontWeight.w600)),
                Text(user['email'] ?? '', style: AdminTextStyles.micro(),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: (user['plan'] == 'Pro' || user['plan'] == 'Enterprise')
                  ? AdminColors.accent.withValues(alpha: 0.1)
                  : AdminColors.surface,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AdminColors.border),
            ),
            child: Text(
              user['plan'] ?? 'Free',
              style: AdminTextStyles.micro(
                color: (user['plan'] == 'Pro' || user['plan'] == 'Enterprise')
                    ? AdminColors.accent
                    : AdminColors.textMuted,
                weight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Quick Actions Card ──────────────────────────────────────────────────────

class _QuickActionsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final actions = [
      {'icon': Icons.person_add_outlined, 'label': 'Add User', 'color': AdminColors.accent},
      {'icon': Icons.announcement_outlined, 'label': 'Broadcast', 'color': AdminColors.blue},
      {'icon': Icons.settings_outlined, 'label': 'System', 'color': AdminColors.purple},
      {'icon': Icons.backup_outlined, 'label': 'Backup', 'color': AdminColors.orange},
    ];

    return Container(
      padding: EdgeInsets.all(GR.lg),
      decoration: BoxDecoration(
        color: AdminColors.cardBg,
        borderRadius: BorderRadius.circular(GR.radiusLg),
        border: Border.all(color: AdminColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Actions', style: AdminTextStyles.h2()),
          SizedBox(height: GR.md),
          ...actions.map((action) => GestureDetector(
            onTap: () => Haptics.light(),
            child: Container(
              margin: EdgeInsets.only(bottom: GR.sm),
              padding: EdgeInsets.symmetric(horizontal: GR.md, vertical: GR.md + 2),
              decoration: BoxDecoration(
                color: AdminColors.surface,
                borderRadius: BorderRadius.circular(GR.radiusMd),
                border: Border.all(color: AdminColors.borderLight),
              ),
              child: Row(
                children: [
                  Icon(action['icon']! as IconData, size: 18, color: action['color']! as Color),
                  SizedBox(width: GR.sm),
                  Text(action['label']! as String, style: AdminTextStyles.bodySmall()),
                  const Spacer(),
                  Icon(Icons.chevron_right_rounded, size: 18, color: AdminColors.textMuted),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }
}

// ─── Ticket Pipeline Card ────────────────────────────────────────────────────

class _TicketPipelineCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final statuses = {
      'backlog': DemoData.tickets.where((t) => t['status'] == 'backlog').length,
      'todo': DemoData.tickets.where((t) => t['status'] == 'todo').length,
      'in_progress': DemoData.tickets.where((t) => t['status'] == 'in_progress').length,
      'done': DemoData.tickets.where((t) => t['status'] == 'done').length,
    };
    final total = DemoData.tickets.length;

    return Container(
      padding: EdgeInsets.all(GR.lg),
      decoration: BoxDecoration(
        color: AdminColors.cardBg,
        borderRadius: BorderRadius.circular(GR.radiusLg),
        border: Border.all(color: AdminColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Ticket Pipeline', style: AdminTextStyles.h2()),
              const Spacer(),
              Text('$total tickets', style: AdminTextStyles.caption()),
            ],
          ),
          SizedBox(height: GR.lg),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Row(
              children: [
                _ProgressSegment(flex: statuses['done']!, color: AdminColors.green, total: total),
                _ProgressSegment(flex: statuses['in_progress']!, color: AdminColors.blue, total: total),
                _ProgressSegment(flex: statuses['todo']!, color: AdminColors.orange, total: total),
                _ProgressSegment(flex: statuses['backlog']!, color: AdminColors.textMuted, total: total),
              ],
            ),
          ),
          SizedBox(height: GR.md),
          Wrap(
            spacing: GR.md,
            runSpacing: GR.sm,
            children: [
              _LegendItem(color: AdminColors.green, label: 'Done', count: statuses['done']!),
              _LegendItem(color: AdminColors.blue, label: 'In Progress', count: statuses['in_progress']!),
              _LegendItem(color: AdminColors.orange, label: 'To Do', count: statuses['todo']!),
              _LegendItem(color: AdminColors.textMuted, label: 'Backlog', count: statuses['backlog']!),
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        SizedBox(width: GR.xs),
        Text('$label ($count)', style: AdminTextStyles.micro(color: AdminColors.textSecondary)),
      ],
    );
  }
}

// ─── User Avatar ─────────────────────────────────────────────────────────────

class _UserAvatar extends StatelessWidget {
  final String name;
  final double size;
  const _UserAvatar({required this.name, this.size = 40});

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AdminColors.accent, AdminColors.blue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(fontFamily: 'Artific', fontSize: size * 0.4, fontWeight: FontWeight.w700, color: Colors.white),
        ),
      ),
    );
  }
}

// ─── Users Panel ─────────────────────────────────────────────────────────────

class _UsersPanel extends StatelessWidget {
  final AnimationController entranceCtrl;
  const _UsersPanel({required this.entranceCtrl});

  @override
  Widget build(BuildContext context) {
    final users = DemoData.users;

    return SingleChildScrollView(
      padding: EdgeInsets.all(GR.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('User Management', style: AdminTextStyles.h1()),
          SizedBox(height: GR.xs),
          Text('Manage and monitor all platform users', style: AdminTextStyles.bodySmall()),
          SizedBox(height: GR.xl),

          // Table
          Container(
            decoration: BoxDecoration(
              color: AdminColors.cardBg,
              borderRadius: BorderRadius.circular(GR.radiusLg),
              border: Border.all(color: AdminColors.border),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: EdgeInsets.symmetric(horizontal: GR.lg, vertical: GR.md),
                  decoration: BoxDecoration(
                    color: AdminColors.surface,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(GR.radiusLg)),
                  ),
                  child: Row(
                    children: [
                      Expanded(flex: 3, child: Text('User', style: AdminTextStyles.caption(weight: FontWeight.w700))),
                      Expanded(child: Text('Plan', style: AdminTextStyles.caption(weight: FontWeight.w700))),
                      Expanded(child: Text('Supps', style: AdminTextStyles.caption(weight: FontWeight.w700))),
                      Expanded(child: Text('Logs', style: AdminTextStyles.caption(weight: FontWeight.w700))),
                      Expanded(child: Text('Status', style: AdminTextStyles.caption(weight: FontWeight.w700))),
                      Expanded(child: Text('Last Active', style: AdminTextStyles.caption(weight: FontWeight.w700))),
                      SizedBox(width: 40),
                    ],
                  ),
                ),
                // Rows
                ...users.asMap().entries.map((entry) {
                  final i = entry.key;
                  final user = entry.value;
                  return _UserTableRow(user: user, index: i, entranceCtrl: entranceCtrl);
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UserTableRow extends StatelessWidget {
  final Map<String, dynamic> user;
  final int index;
  final AnimationController entranceCtrl;

  const _UserTableRow({required this.user, required this.index, required this.entranceCtrl});

  @override
  Widget build(BuildContext context) {
    final isActive = user['is_active'] ?? true;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: GR.lg, vertical: GR.md + 2),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AdminColors.borderLight)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                _UserAvatar(name: user['name'] ?? 'U', size: 32),
                SizedBox(width: GR.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user['name'] ?? 'No name', style: AdminTextStyles.bodySmall(weight: FontWeight.w600)),
                      Text(user['email'] ?? '', style: AdminTextStyles.micro(), overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: (user['plan'] == 'Pro' || user['plan'] == 'Enterprise')
                    ? AdminColors.accent.withValues(alpha: 0.1)
                    : AdminColors.surface,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AdminColors.border),
              ),
              child: Text(
                user['plan'] ?? 'Free',
                style: AdminTextStyles.micro(
                  color: (user['plan'] == 'Pro' || user['plan'] == 'Enterprise')
                      ? AdminColors.accent
                      : AdminColors.textMuted,
                  weight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Expanded(child: Text('${user['supplement_count'] ?? 0}', style: AdminTextStyles.bodySmall())),
          Expanded(child: Text('${user['dose_log_count'] ?? 0}', style: AdminTextStyles.bodySmall())),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isActive ? AdminColors.green.withValues(alpha: 0.1) : AdminColors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                isActive ? 'Active' : 'Inactive',
                style: AdminTextStyles.micro(
                  color: isActive ? AdminColors.green : AdminColors.red,
                  weight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Expanded(child: Text(user['last_active'] ?? '', style: AdminTextStyles.micro())),
          SizedBox(
            width: 36,
            child: Icon(Icons.more_vert_rounded, size: 18, color: AdminColors.textMuted),
          ),
        ],
      ),
    )
        .animate(controller: entranceCtrl)
        .fadeIn(delay: Duration(milliseconds: 100 + index * 40), duration: 300.ms)
        .slideY(begin: 0.1, end: 0, delay: Duration(milliseconds: 100 + index * 40), duration: 300.ms, curve: Curves.easeOutCubic);
  }
}

// ─── Kanban Panel ────────────────────────────────────────────────────────────

class _KanbanPanel extends StatefulWidget {
  @override
  State<_KanbanPanel> createState() => _KanbanPanelState();
}

class _KanbanPanelState extends State<_KanbanPanel> {
  late List<Map<String, dynamic>> _tickets;

  @override
  void initState() {
    super.initState();
    _tickets = List.from(DemoData.tickets);
  }

  void _moveTicket(String ticketId, String newStatus) {
    Haptics.medium();
    setState(() {
      _tickets = _tickets.map((t) {
        if (t['id'] == ticketId) {
          return {...t, 'status': newStatus};
        }
        return t;
      }).toList();
    });
  }

  Color _priorityColor(String priority) {
    switch (priority) {
      case 'critical': return AdminColors.red;
      case 'high': return AdminColors.orange;
      case 'medium': return AdminColors.amber;
      case 'low': return AdminColors.green;
      default: return AdminColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final columns = [
      {'id': 'backlog', 'label': 'Backlog', 'color': AdminColors.textMuted},
      {'id': 'todo', 'label': 'To Do', 'color': AdminColors.orange},
      {'id': 'in_progress', 'label': 'In Progress', 'color': AdminColors.blue},
      {'id': 'done', 'label': 'Done', 'color': AdminColors.green},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.all(GR.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: columns.map((col) {
          final colTickets = _tickets.where((t) => t['status'] == col['id']).toList();
          return _KanbanColumn(
            label: col['label']! as String,
            color: col['color']! as Color,
            tickets: colTickets,
            onMoveNext: (ticketId) {
              final nextIndex = columns.indexWhere((c) => c['id'] == col['id']) + 1;
              if (nextIndex < columns.length) {
                _moveTicket(ticketId, columns[nextIndex]['id']! as String);
              }
            },
            onMovePrev: (ticketId) {
              final prevIndex = columns.indexWhere((c) => c['id'] == col['id']) - 1;
              if (prevIndex >= 0) {
                _moveTicket(ticketId, columns[prevIndex]['id']! as String);
              }
            },
            priorityColor: _priorityColor,
          );
        }).toList(),
      ),
    );
  }
}

class _KanbanColumn extends StatelessWidget {
  final String label;
  final Color color;
  final List<Map<String, dynamic>> tickets;
  final ValueChanged<String> onMoveNext;
  final ValueChanged<String> onMovePrev;
  final Color Function(String) priorityColor;

  const _KanbanColumn({
    required this.label,
    required this.color,
    required this.tickets,
    required this.onMoveNext,
    required this.onMovePrev,
    required this.priorityColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      margin: EdgeInsets.only(right: GR.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
              SizedBox(width: GR.sm),
              Text(label, style: AdminTextStyles.bodySmall(weight: FontWeight.w700)),
              SizedBox(width: GR.xs),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: AdminColors.surface, borderRadius: BorderRadius.circular(10)),
                child: Text('${tickets.length}', style: AdminTextStyles.micro()),
              ),
            ],
          ),
          SizedBox(height: GR.sm),
          ...tickets.map((ticket) => _KanbanCard(
            ticket: ticket,
            priorityColor: priorityColor,
            onMoveNext: () => onMoveNext(ticket['id']! as String),
            onMovePrev: () => onMovePrev(ticket['id']! as String),
          )),
        ],
      ),
    );
  }
}

class _KanbanCard extends StatelessWidget {
  final Map<String, dynamic> ticket;
  final Color Function(String) priorityColor;
  final VoidCallback onMoveNext;
  final VoidCallback onMovePrev;

  const _KanbanCard({
    required this.ticket,
    required this.priorityColor,
    required this.onMoveNext,
    required this.onMovePrev,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: GR.sm),
      padding: EdgeInsets.all(GR.md),
      decoration: BoxDecoration(
        color: AdminColors.cardBg,
        borderRadius: BorderRadius.circular(GR.radiusMd),
        border: Border.all(color: AdminColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: priorityColor(ticket['priority']! as String).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  (ticket['priority']! as String).toUpperCase(),
                  style: AdminTextStyles.micro(
                    color: priorityColor(ticket['priority']! as String),
                    weight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              GestureDetector(onTap: onMovePrev, child: Icon(Icons.chevron_left_rounded, size: 18, color: AdminColors.textMuted)),
              GestureDetector(onTap: onMoveNext, child: Icon(Icons.chevron_right_rounded, size: 18, color: AdminColors.textMuted)),
            ],
          ),
          SizedBox(height: GR.sm),
          Text(ticket['title']! as String, style: AdminTextStyles.bodySmall(weight: FontWeight.w600)),
          if ((ticket['desc']! as String).isNotEmpty) ...[
            SizedBox(height: GR.xs),
            Text(ticket['desc']! as String, style: AdminTextStyles.micro(), maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
          SizedBox(height: GR.sm),
          Row(
            children: [
              Icon(Icons.person_outline, size: 12, color: AdminColors.textMuted),
              SizedBox(width: 2),
              Text(ticket['assignee']! as String, style: AdminTextStyles.micro()),
              const Spacer(),
              if ((ticket['tags']! as List).isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(color: AdminColors.surface, borderRadius: BorderRadius.circular(3)),
                  child: Text((ticket['tags']! as List).first as String, style: AdminTextStyles.micro()),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Engine Panel ────────────────────────────────────────────────────────────

class _EnginePanel extends StatelessWidget {
  final AnimationController entranceCtrl;
  const _EnginePanel({required this.entranceCtrl});

  @override
  Widget build(BuildContext context) {
    final metrics = [
      {'label': 'API Response', 'value': '45ms', 'status': 'healthy', 'icon': Icons.speed_rounded, 'color': AdminColors.green},
      {'label': 'DB Connections', 'value': '12 active', 'status': 'healthy', 'icon': Icons.storage_rounded, 'color': AdminColors.blue},
      {'label': 'Memory', 'value': '128 MB', 'status': 'healthy', 'icon': Icons.memory_rounded, 'color': AdminColors.purple},
      {'label': 'Uptime', 'value': '99.9%', 'status': 'healthy', 'icon': Icons.timer_rounded, 'color': AdminColors.accent},
      {'label': 'Error Rate', 'value': '0.02%', 'status': 'healthy', 'icon': Icons.error_outline_rounded, 'color': AdminColors.orange},
      {'label': 'Queue', 'value': '0', 'status': 'healthy', 'icon': Icons.queue_rounded, 'color': AdminColors.green},
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.all(GR.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('System Health', style: AdminTextStyles.h1()),
          SizedBox(height: GR.xs),
          Text('Real-time monitoring of the Matra Engine', style: AdminTextStyles.bodySmall()),
          SizedBox(height: GR.xl),

          // Health banner
          Container(
            padding: EdgeInsets.all(GR.lg),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00BFA5), Color(0xFF00897B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(GR.radiusLg),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(GR.md),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(GR.radiusMd),
                  ),
                  child: const Icon(Icons.check_circle_rounded, size: 28, color: Colors.white),
                ),
                SizedBox(width: GR.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('All Systems Operational', style: AdminTextStyles.h2(color: Colors.white)),
                      Text('No issues detected. All services running normally.', style: AdminTextStyles.bodySmall(color: Colors.white.withValues(alpha: 0.8))),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('99.9% Uptime', style: AdminTextStyles.bodySmall(color: Colors.white, weight: FontWeight.w700)),
                ),
              ],
            ),
          ),

          SizedBox(height: GR.xl),

          // Metrics grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: GR.md,
            crossAxisSpacing: GR.md,
            childAspectRatio: 1.4,
            children: metrics.asMap().entries.map((entry) {
              final i = entry.key;
              final m = entry.value;
              return _EngineMetricCard(
                label: m['label']! as String,
                value: m['value']! as String,
                icon: m['icon']! as IconData,
                color: m['color']! as Color,
                delay: i * 60,
                entranceCtrl: entranceCtrl,
              );
            }).toList(),
          ),

          SizedBox(height: GR.xl),

          // Data Flow
          Text('Data Architecture', style: AdminTextStyles.h2()),
          SizedBox(height: GR.md),
          _DataFlowDiagram(),

          SizedBox(height: GR.xl),

          // Services
          Text('Service Status', style: AdminTextStyles.h2()),
          SizedBox(height: GR.md),
          _ServiceStatusList(),
        ],
      ),
    );
  }
}

class _EngineMetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final int delay;
  final AnimationController entranceCtrl;

  const _EngineMetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.delay,
    required this.entranceCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(GR.lg),
      decoration: BoxDecoration(
        color: AdminColors.cardBg,
        borderRadius: BorderRadius.circular(GR.radiusLg),
        border: Border.all(color: AdminColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const Spacer(),
              Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            ],
          ),
          const Spacer(),
          Text(value, style: AdminTextStyles.h1(color: AdminColors.textPrimary)),
          SizedBox(height: GR.xs),
          Text(label, style: AdminTextStyles.caption()),
        ],
      ),
    )
        .animate(controller: entranceCtrl)
        .fadeIn(delay: Duration(milliseconds: delay), duration: 400.ms)
        .slideY(begin: 0.2, end: 0, delay: Duration(milliseconds: delay), duration: 400.ms, curve: Curves.easeOutCubic);
  }
}

class _DataFlowDiagram extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final nodes = [
      {'label': 'Mobile Client', 'icon': Icons.phone_android_rounded, 'status': 'Online', 'latency': '12ms'},
      {'label': 'API Gateway', 'icon': Icons.router_rounded, 'status': 'Online', 'latency': '8ms'},
      {'label': 'Auth Service', 'icon': Icons.security_rounded, 'status': 'Online', 'latency': '15ms'},
      {'label': 'App Logic', 'icon': Icons.code_rounded, 'status': 'Online', 'latency': '28ms'},
      {'label': 'MongoDB Cluster', 'icon': Icons.storage_rounded, 'status': 'Online', 'latency': '18ms'},
    ];

    return Container(
      padding: EdgeInsets.all(GR.lg),
      decoration: BoxDecoration(
        color: AdminColors.cardBg,
        borderRadius: BorderRadius.circular(GR.radiusLg),
        border: Border.all(color: AdminColors.border),
      ),
      child: Column(
        children: nodes.asMap().entries.map((entry) {
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
                      gradient: const LinearGradient(
                        colors: [AdminColors.accent, AdminColors.blue],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(GR.radiusMd),
                    ),
                    child: Icon(node['icon']! as IconData, size: 20, color: Colors.white),
                  ),
                  SizedBox(width: GR.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(node['label']! as String, style: AdminTextStyles.bodySmall(weight: FontWeight.w600)),
                        Text('${node['status']} • ${node['latency']}', style: AdminTextStyles.micro(color: AdminColors.green)),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AdminColors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('OK', style: AdminTextStyles.micro(color: AdminColors.green, weight: FontWeight.w700)),
                  ),
                ],
              ),
              if (i < nodes.length - 1)
                Padding(
                  padding: EdgeInsets.only(left: 22),
                  child: Container(width: 2, height: 24, color: AdminColors.accent.withValues(alpha: 0.3)),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _ServiceStatusList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final services = [
      {'name': 'Authentication', 'status': 'Running', 'latency': '12ms', 'uptime': '99.9%'},
      {'name': 'Supplement API', 'status': 'Running', 'latency': '28ms', 'uptime': '99.8%'},
      {'name': 'Dose Log API', 'status': 'Running', 'latency': '18ms', 'uptime': '99.9%'},
      {'name': 'Insights Engine', 'status': 'Running', 'latency': '45ms', 'uptime': '99.7%'},
      {'name': 'OTP Service', 'status': 'Running', 'latency': '8ms', 'uptime': '99.9%'},
      {'name': 'Search Service', 'status': 'Running', 'latency': '120ms', 'uptime': '99.5%'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: AdminColors.cardBg,
        borderRadius: BorderRadius.circular(GR.radiusLg),
        border: Border.all(color: AdminColors.border),
      ),
      child: Column(
        children: services.asMap().entries.map((entry) {
          final i = entry.key;
          final s = entry.value;
          return Container(
            padding: EdgeInsets.symmetric(horizontal: GR.lg, vertical: GR.md + 4),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: i == 0 ? Colors.transparent : AdminColors.borderLight)),
            ),
            child: Row(
              children: [
                Container(width: 8, height: 8, decoration: BoxDecoration(color: AdminColors.green, shape: BoxShape.circle)),
                SizedBox(width: GR.md),
                Expanded(child: Text(s['name']!, style: AdminTextStyles.bodySmall(weight: FontWeight.w600))),
                Text(s['status']!, style: AdminTextStyles.caption(color: AdminColors.green)),
                SizedBox(width: GR.lg),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: AdminColors.surface, borderRadius: BorderRadius.circular(6)),
                  child: Text(s['latency']!, style: AdminTextStyles.micro()),
                ),
                SizedBox(width: GR.md),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: AdminColors.surface, borderRadius: BorderRadius.circular(6)),
                  child: Text(s['uptime']!, style: AdminTextStyles.micro()),
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
  final AnimationController entranceCtrl;
  const _AnalyticsPanel({required this.entranceCtrl});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(GR.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Platform Analytics', style: AdminTextStyles.h1()),
          SizedBox(height: GR.xs),
          Text('Deep insights into user behavior and platform performance', style: AdminTextStyles.bodySmall()),
          SizedBox(height: GR.xl),

          // Summary cards
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            mainAxisSpacing: GR.md,
            crossAxisSpacing: GR.md,
            childAspectRatio: 1.8,
            children: [
              _AnalyticsCard(label: 'Active Users', value: '892/1247', subtitle: '71.5% engagement', color: AdminColors.accent, entranceCtrl: entranceCtrl, delay: 0),
              _AnalyticsCard(label: 'Avg Supplements', value: '3.8', subtitle: 'Per user', color: AdminColors.blue, entranceCtrl: entranceCtrl, delay: 80),
              _AnalyticsCard(label: 'Retention', value: '78.4%', subtitle: '30-day', color: AdminColors.green, entranceCtrl: entranceCtrl, delay: 160),
              _AnalyticsCard(label: 'Churn Rate', value: '2.1%', subtitle: 'Monthly', color: AdminColors.orange, entranceCtrl: entranceCtrl, delay: 240),
            ],
          ),

          SizedBox(height: GR.xl),

          // Charts row
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 800;
              return isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _UserGrowthChart()),
                        SizedBox(width: GR.md),
                        Expanded(child: _TicketDistributionChart()),
                      ],
                    )
                  : Column(
                      children: [
                        _UserGrowthChart(),
                        SizedBox(height: GR.md),
                        _TicketDistributionChart(),
                      ],
                    );
            },
          ),

          SizedBox(height: GR.xl),

          // Supplement popularity
          _SupplementPopularityChart(),

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
    return Container(
      padding: EdgeInsets.all(GR.lg),
      decoration: BoxDecoration(
        color: AdminColors.cardBg,
        borderRadius: BorderRadius.circular(GR.radiusLg),
        border: Border.all(color: AdminColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AdminTextStyles.caption()),
          const Spacer(),
          Text(value, style: AdminTextStyles.h1(color: color)),
          SizedBox(height: GR.xs),
          Text(subtitle, style: AdminTextStyles.micro()),
        ],
      ),
    )
        .animate(controller: entranceCtrl)
        .fadeIn(delay: Duration(milliseconds: delay), duration: 400.ms)
        .slideY(begin: 0.2, end: 0, delay: Duration(milliseconds: delay), duration: 400.ms, curve: Curves.easeOutCubic);
  }
}

class _UserGrowthChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final data = [65, 78, 52, 91, 45, 88, 72, 95, 60, 82, 70, 100, 85, 92];
    final maxVal = data.reduce(math.max).toDouble();

    return Container(
      padding: EdgeInsets.all(GR.lg),
      decoration: BoxDecoration(
        color: AdminColors.cardBg,
        borderRadius: BorderRadius.circular(GR.radiusLg),
        border: Border.all(color: AdminColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('User Growth (14 Days)', style: AdminTextStyles.h2()),
          SizedBox(height: GR.lg),
          SizedBox(
            height: 150,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: data.asMap().entries.map((entry) {
                final i = entry.key;
                final val = entry.value;
                final height = (val / maxVal) * 120;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: height,
                          decoration: BoxDecoration(
                            color: i == data.length - 1 ? AdminColors.accent : AdminColors.accent.withValues(alpha: 0.3),
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
              Text('14 days ago', style: AdminTextStyles.micro()),
              Text('Today', style: AdminTextStyles.micro()),
            ],
          ),
        ],
      ),
    );
  }
}

class _TicketDistributionChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final priorities = ['critical', 'high', 'medium', 'low'];
    final counts = priorities.map((p) => DemoData.tickets.where((t) => t['priority'] == p).length).toList();
    final maxCount = counts.isEmpty ? 1 : counts.reduce(math.max);
    final colors = [AdminColors.red, AdminColors.orange, AdminColors.amber, AdminColors.green];
    final labels = ['Critical', 'High', 'Medium', 'Low'];

    return Container(
      padding: EdgeInsets.all(GR.lg),
      decoration: BoxDecoration(
        color: AdminColors.cardBg,
        borderRadius: BorderRadius.circular(GR.radiusLg),
        border: Border.all(color: AdminColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ticket Priority Distribution', style: AdminTextStyles.h2()),
          SizedBox(height: GR.lg),
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
                      Text('$count', style: AdminTextStyles.bodySmall(weight: FontWeight.w700)),
                      SizedBox(height: GR.xs),
                      Container(
                        height: height,
                        decoration: BoxDecoration(
                          color: colors[i].withValues(alpha: 0.7),
                          borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
                        ),
                      ),
                      SizedBox(height: GR.xs),
                      Text(labels[i], style: AdminTextStyles.micro(color: AdminColors.textSecondary)),
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

class _SupplementPopularityChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final supplements = [
      {'name': 'Vitamin D3', 'users': 892, 'color': AdminColors.accent},
      {'name': 'Omega-3', 'users': 756, 'color': AdminColors.blue},
      {'name': 'Magnesium', 'users': 634, 'color': AdminColors.purple},
      {'name': 'Zinc', 'users': 521, 'color': AdminColors.orange},
      {'name': 'Probiotics', 'users': 498, 'color': AdminColors.green},
      {'name': 'B-Complex', 'users': 445, 'color': AdminColors.amber},
    ];
    final maxUsers = supplements.map((s) => s['users'] as int).reduce(math.max);

    return Container(
      padding: EdgeInsets.all(GR.lg),
      decoration: BoxDecoration(
        color: AdminColors.cardBg,
        borderRadius: BorderRadius.circular(GR.radiusLg),
        border: Border.all(color: AdminColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Most Popular Supplements', style: AdminTextStyles.h2()),
          SizedBox(height: GR.lg),
          ...supplements.map((s) {
            final ratio = (s['users']! as int) / maxUsers;
            return Padding(
              padding: EdgeInsets.only(bottom: GR.md),
              child: Row(
                children: [
                  SizedBox(
                    width: 120,
                    child: Text(s['name']! as String, style: AdminTextStyles.bodySmall()),
                  ),
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: AdminColors.surface,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: ratio,
                          child: Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: s['color']! as Color,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: GR.md),
                  Text('${s['users']}', style: AdminTextStyles.bodySmall(weight: FontWeight.w600)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─── Logs Panel ────────────────────────────────────────────────────────────

class _LogsPanel extends StatelessWidget {
  final AnimationController entranceCtrl;
  const _LogsPanel({required this.entranceCtrl});

  Color _logTypeColor(String type) {
    switch (type) {
      case 'success': return AdminColors.green;
      case 'error': return AdminColors.red;
      case 'warning': return AdminColors.orange;
      default: return AdminColors.blue;
    }
  }

  IconData _logTypeIcon(String type) {
    switch (type) {
      case 'success': return Icons.check_circle_rounded;
      case 'error': return Icons.error_rounded;
      case 'warning': return Icons.warning_rounded;
      default: return Icons.info_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(GR.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Audit Logs', style: AdminTextStyles.h1()),
          SizedBox(height: GR.xs),
          Text('Real-time activity tracking across the platform', style: AdminTextStyles.bodySmall()),
          SizedBox(height: GR.xl),

          Container(
            decoration: BoxDecoration(
              color: AdminColors.cardBg,
              borderRadius: BorderRadius.circular(GR.radiusLg),
              border: Border.all(color: AdminColors.border),
            ),
            child: Column(
              children: DemoData.auditLogs.asMap().entries.map((entry) {
                final i = entry.key;
                final log = entry.value;
                final color = _logTypeColor(log['type'] as String);

                return Container(
                  padding: EdgeInsets.symmetric(horizontal: GR.lg, vertical: GR.md + 4),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: i == 0 ? Colors.transparent : AdminColors.borderLight)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(GR.sm + 2),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(GR.radiusSm),
                        ),
                        child: Icon(_logTypeIcon(log['type'] as String), size: 16, color: color),
                      ),
                      SizedBox(width: GR.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(log['action'] as String, style: AdminTextStyles.bodySmall(weight: FontWeight.w600)),
                            Text('${log['target']} • by ${log['by']}', style: AdminTextStyles.micro()),
                          ],
                        ),
                      ),
                      Text(log['time'] as String, style: AdminTextStyles.micro()),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
