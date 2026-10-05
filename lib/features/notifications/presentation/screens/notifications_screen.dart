import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../config/theme.dart';
import '../../data/notification_repository.dart';
import '../../domain/models/notification_model.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationRepository _repo = NotificationRepositoryImpl();
  List<NotificationModel> _notifications = [];
  String _selectedFilter = 'Semua';

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final list = await _repo.getNotifications();
    if (mounted) {
      setState(() => _notifications = list);
    }
  }

  void _markAllAsRead() async {
    await _repo.markAllAsRead();
    await _loadNotifications();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua notifikasi telah ditandai dibaca')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isDark = context.isDark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifikasi',
          style: AppText.headlineSm.copyWith(
            fontWeight: FontWeight.w800,
            color: palette.onSurface,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _markAllAsRead,
            child: Text(
              'Tandai Semua Dibaca',
              style: AppText.labelSm.copyWith(
                color: isDark ? AppColors.primaryFixed : AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('Semua (${_notifications.isNotEmpty ? _notifications.length : 4})', _selectedFilter == 'Semua', () => setState(() => _selectedFilter = 'Semua')),
                    const SizedBox(width: 8),
                    _buildFilterChip('Tagihan & Pembayaran', _selectedFilter == 'Tagihan', () => setState(() => _selectedFilter = 'Tagihan')),
                    const SizedBox(width: 8),
                    _buildFilterChip('Grup', _selectedFilter == 'Grup', () => setState(() => _selectedFilter = 'Grup')),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Section HARI INI
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'HARI INI',
                    style: AppText.labelSm.copyWith(
                      letterSpacing: 1.1,
                      color: palette.outline,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${_notifications.where((n) => !n.isRead).isNotEmpty ? _notifications.where((n) => !n.isRead).length : 2} Baru',
                    style: AppText.labelSm.copyWith(
                      color: palette.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Notif 1: Budi menambahkan pengeluaran baru
              _buildNotifCard(
                icon: Icons.receipt_long_rounded,
                iconBg: isDark ? const Color(0xFF132F28) : const Color(0xFFD1FAE5),
                iconFg: const Color(0xFF006C49),
                borderColor: const Color(0xFF10B981),
                hasDot: true,
                dotColor: AppColors.primaryContainer,
                title: 'Budi menambahkan pengeluaran baru',
                subtitle: 'Makan Malam Reuni • Rp200.000',
                time: '10 menit lalu',
                palette: palette,
              ),

              const SizedBox(height: 12),

              // Notif 2: Ani belum menyelesaikan pembayaran
              _buildNotifCard(
                icon: Icons.access_time_rounded,
                iconBg: isDark ? const Color(0xFF3B2E12) : const Color(0xFFFEF3C7),
                iconFg: const Color(0xFFD97706),
                borderColor: const Color(0xFFF59E0B),
                hasDot: true,
                dotColor: const Color(0xFFF59E0B),
                title: 'Ani belum menyelesaikan pembayaran',
                subtitle: 'Rp50.000 • Makan Malam Reuni',
                time: '2 jam lalu',
                palette: palette,
                action: Container(
                  margin: const EdgeInsets.only(top: 12),
                  child: OutlinedButton.icon(
                    onPressed: () {
                      SharePlus.instance.share(
                        ShareParams(
                          text: 'Hai Ani, jangan lupa selesaikan tagihan patungan "Makan Malam Reuni" sebesar Rp50.000 ya! Terima kasih 🙏',
                        ),
                      );
                    },
                    icon: const Icon(Icons.send_rounded, size: 14),
                    label: const Text('Kirim Pengingat'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(40),
                      side: BorderSide(color: palette.cardBorder),
                      foregroundColor: palette.onSurface,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Section KEMARIN & SEBELUMNYA
              Text(
                'KEMARIN & SEBELUMNYA',
                style: AppText.labelSm.copyWith(
                  letterSpacing: 1.1,
                  color: palette.outline,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              // Notif 3: Citra menambahkan ke grup
              _buildNotifCard(
                icon: Icons.group_add_rounded,
                iconBg: isDark ? const Color(0xFF1E2838) : const Color(0xFFEFF6FF),
                iconFg: const Color(0xFF2563EB),
                borderColor: const Color(0xFF2563EB),
                title: 'Citra menambahkan Anda ke grup',
                subtitle: 'Grup "Liburan Jogja" (5 anggota)',
                time: '5 jam lalu',
                palette: palette,
                action: Container(
                  margin: const EdgeInsets.only(top: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Berhasil bergabung ke grup Liburan Jogja')),
                            );
                          },
                          icon: const Icon(Icons.check, size: 14),
                          label: const Text('Terima'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryContainer,
                            minimumSize: const Size.fromHeight(38),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(38),
                            side: BorderSide(color: palette.cardBorder),
                          ),
                          child: const Text('Tinjau'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Notif 4: Dimas melakukan pembayaran
              _buildNotifCard(
                icon: Icons.check_circle_outline_rounded,
                iconBg: isDark ? const Color(0xFF132F28) : const Color(0xFFD1FAE5),
                iconFg: const Color(0xFF006C49),
                borderColor: const Color(0xFF10B981),
                title: 'Dimas melakukan pembayaran',
                subtitle: 'Rp75.000 • Liburan Jogja via QRIS',
                time: 'Kemarin, 10:20',
                trailingBadge: 'Lunas',
                palette: palette,
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    final palette = context.palette;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryContainer : palette.surfaceLow,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Text(
          label,
          style: AppText.labelSm.copyWith(
            color: isSelected ? Colors.white : palette.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildNotifCard({
    required IconData icon,
    required Color iconBg,
    required Color iconFg,
    required Color borderColor,
    required String title,
    required String subtitle,
    required String time,
    required AppPalette palette,
    bool hasDot = false,
    Color dotColor = AppColors.primaryContainer,
    String? trailingBadge,
    Widget? action,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: palette.cardBorder),
        boxShadow: AppShadows.card,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: borderColor, width: 4)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: iconFg, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppText.titleMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: palette.onSurface,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          subtitle,
                          style: AppText.bodySm.copyWith(
                            color: palette.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.access_time_rounded, size: 12, color: palette.outline),
                            const SizedBox(width: 4),
                            Text(
                              time,
                              style: AppText.bodySm.copyWith(fontSize: 11, color: palette.outline),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (hasDot)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: dotColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  if (trailingBadge != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1FAE5),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Text(
                        trailingBadge,
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF006C49)),
                      ),
                    ),
                ],
              ),
              ?action,
            ],
          ),
        ),
      ),
    );
  }
}
