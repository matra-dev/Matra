import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_text_styles.dart';
import '../utils/haptics.dart';
import '../providers/app_provider.dart';
import 'auth_screen.dart';

class AdminScreen extends ConsumerStatefulWidget {
  const AdminScreen({super.key});

  @override
  ConsumerState<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends ConsumerState<AdminScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _stats;
  List<Map<String, dynamic>> _users = [];

  late final AnimationController _entranceCtrl;

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
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
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);

    return Scaffold(
      backgroundColor: tc.bg,
      appBar: AppBar(
        backgroundColor: tc.bg,
        elevation: 0,
        title: Text('Admin', style: AppTextStyles.h2(context)),
        actions: [
          TextButton(
            onPressed: () {
              Haptics.medium();
              ref.read(authStateProvider.notifier).logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const AuthScreen()),
                (route) => false,
              );
            },
            child: Text('Logout', style: AppTextStyles.bodySmall(context, color: tc.accentDark)),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: tc.accent))
          : _error != null
              ? Center(
                  child: Text(
                    'Error: $_error',
                    style: AppTextStyles.body(context, color: tc.textSecondary),
                  ),
                )
              : SingleChildScrollView(
                  padding: EdgeInsets.all(GR.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Stats Grid
                      _buildStatsGrid(tc),
                      SizedBox(height: GR.xl),

                      // Users Section
                      Text(
                        'Users',
                        style: AppTextStyles.h3(context),
                      )
                          .animate(controller: _entranceCtrl)
                          .fadeIn(delay: 200.ms, duration: 400.ms)
                          .slideY(begin: 0.2, end: 0, delay: 200.ms, duration: 400.ms, curve: Curves.easeOutCubic),

                      SizedBox(height: GR.md),

                      ..._users.asMap().entries.map((entry) {
                        final i = entry.key;
                        final user = entry.value;
                        return _buildUserCard(user, tc, i);
                      }),
                    ],
                  ),
                ),
    );
  }

  Widget _buildStatsGrid(ThemeColors tc) {
    final stats = [
      {'label': 'Users', 'value': '${_stats?['total_users'] ?? 0}'},
      {'label': 'Supplements', 'value': '${_stats?['total_supplements'] ?? 0}'},
      {'label': 'Dose Logs', 'value': '${_stats?['total_dose_logs'] ?? 0}'},
      {'label': 'Measurements', 'value': '${_stats?['total_measurements'] ?? 0}'},
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: GR.md,
      crossAxisSpacing: GR.md,
      childAspectRatio: 1.6,
      children: stats.asMap().entries.map((entry) {
        final i = entry.key;
        final stat = entry.value;
        return Container(
          padding: EdgeInsets.all(GR.lg),
          decoration: BoxDecoration(
            color: tc.cardBg,
            borderRadius: BorderRadius.circular(GR.radiusMd),
            border: Border.all(color: tc.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stat['value']!,
                style: AppTextStyles.h2(context, color: tc.accentDark),
              ),
              SizedBox(height: GR.xs),
              Text(
                stat['label']!,
                style: AppTextStyles.caption(context, color: tc.textSecondary),
              ),
            ],
          ),
        )
            .animate(controller: _entranceCtrl)
            .fadeIn(delay: Duration(milliseconds: i * 80), duration: 400.ms)
            .slideY(begin: 0.2, end: 0, delay: Duration(milliseconds: i * 80), duration: 400.ms, curve: Curves.easeOutCubic);
      }).toList(),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user, ThemeColors tc, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: GR.sm),
      padding: EdgeInsets.all(GR.md),
      decoration: BoxDecoration(
        color: tc.cardBg,
        borderRadius: BorderRadius.circular(GR.radiusMd),
        border: Border.all(color: tc.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: tc.accent.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                (user['name'] ?? user['email'] ?? 'U').toString().substring(0, 1).toUpperCase(),
                style: AppTextStyles.h3(context, color: tc.accentDark),
              ),
            ),
          ),
          SizedBox(width: GR.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['name'] ?? 'No name',
                  style: AppTextStyles.body(context, weight: FontWeight.w600),
                ),
                SizedBox(height: 2),
                Text(
                  user['email'] ?? '',
                  style: AppTextStyles.caption(context, color: tc.textSecondary),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    _buildBadge('${user['supplement_count'] ?? 0} supps', tc),
                    SizedBox(width: 6),
                    _buildBadge('${user['dose_log_count'] ?? 0} logs', tc),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate(controller: _entranceCtrl)
        .fadeIn(delay: Duration(milliseconds: 300 + index * 60), duration: 350.ms)
        .slideY(begin: 0.15, end: 0, delay: Duration(milliseconds: 300 + index * 60), duration: 350.ms, curve: Curves.easeOutCubic);
  }

  Widget _buildBadge(String text, ThemeColors tc) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: tc.surface,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: AppTextStyles.micro(context, color: tc.textSecondary),
      ),
    );
  }
}
