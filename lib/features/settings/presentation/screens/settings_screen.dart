import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/theme.dart';
import '../../../../config/routes.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../cubit/settings_cubit.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isDark = context.isDark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Pengaturan',
          style: AppText.headlineSm.copyWith(
            fontWeight: FontWeight.w800,
            color: palette.onSurface,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.notifications),
          ),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, settings) {
            final cubit = context.read<SettingsCubit>();

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // AKUN Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'AKUN',
                        style: AppText.labelSm.copyWith(
                          letterSpacing: 1.1,
                          color: palette.outline,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Terverifikasi',
                        style: AppText.labelSm.copyWith(
                          color: isDark ? AppColors.primaryFixed : AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // User Info Card
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, authState) {
                      final user = authState is Authenticated ? authState.user : null;
                      final name = user?.fullName ?? 'Achmad Buana';
                      final email = user?.email ?? 'achmad.buana@email.com';

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: palette.card,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: palette.cardBorder),
                          boxShadow: AppShadows.card,
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Stack(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.primaryFixedDim,
                                        image: const DecorationImage(
                                          image: NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80'),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(
                                          color: AppColors.primaryContainer,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.check, size: 10, color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        style: AppText.titleMedium.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: palette.onSurface,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        email,
                                        style: AppText.bodySm.copyWith(color: palette.onSurfaceVariant, fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.chevron_right_rounded, color: palette.outline),
                              ],
                            ),
                            Divider(color: palette.cardBorder, height: 24),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF1E2838) : const Color(0xFFEFF6FF),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.shield_outlined, size: 18, color: Color(0xFF2563EB)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Keamanan & Ubah Password', style: AppText.titleMedium.copyWith(fontWeight: FontWeight.bold, fontSize: 13)),
                                      Text('PIN transaksi, Password & 2FA', style: AppText.bodySm.copyWith(fontSize: 10, color: palette.onSurfaceVariant)),
                                    ],
                                  ),
                                ),
                                Icon(Icons.chevron_right_rounded, color: palette.outline),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF132F28) : const Color(0xFFECFDF5),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.fingerprint_rounded, size: 18, color: Color(0xFF059669)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text('Masuk Cepat & PIN Biometrik', style: AppText.titleMedium.copyWith(fontWeight: FontWeight.bold, fontSize: 13)),
                                ),
                                Switch(
                                  value: settings.isBiometricEnabled,
                                  onChanged: (val) => cubit.toggleBiometric(val),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // GRUP SAYA Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'GRUP SAYA',
                        style: AppText.labelSm.copyWith(
                          letterSpacing: 1.1,
                          color: palette.outline,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, AppRoutes.groupsList),
                        child: Text(
                          'Lihat Semua (4) >',
                          style: AppText.labelSm.copyWith(
                            color: isDark ? AppColors.primaryFixed : AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // 2 Horizontal mini cards
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: palette.card,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: palette.cardBorder),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFD1FAE5),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text('Kost Melati', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF006C49))),
                                  ),
                                  const Icon(Icons.group_outlined, size: 14, color: Color(0xFF64748B)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              const Text('Listrik & WiFi Bulanan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                              const SizedBox(height: 4),
                              Text('Kamu ditagih Rp125.000', style: TextStyle(fontSize: 10, color: AppColors.error, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              Text('Aktif 2j lalu', style: TextStyle(fontSize: 9, color: palette.outline)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: palette.card,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: palette.cardBorder),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFCFFAFE),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text('Trip Bali', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0E7490))),
                                  ),
                                  const Icon(Icons.flight_takeoff_rounded, size: 14, color: Color(0xFF64748B)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              const Text('Villa & Rental Mobil', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                              const SizedBox(height: 4),
                              const Text('Lunas (Selesai)', style: TextStyle(fontSize: 10, color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              Text('Settled', style: TextStyle(fontSize: 9, color: palette.outline)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // PREFERENSI Section
                  Text(
                    'PREFERENSI',
                    style: AppText.labelSm.copyWith(
                      letterSpacing: 1.1,
                      color: palette.outline,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Container(
                    decoration: BoxDecoration(
                      color: palette.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: palette.cardBorder),
                      boxShadow: AppShadows.card,
                    ),
                    child: Column(
                      children: [
                        _buildSettingsRow(
                          icon: Icons.payments_outlined,
                          title: 'Mata Uang',
                          subtitle: 'Default perhitungan tagihan',
                          trailingBadge: 'IDR (Rp)',
                          onTap: () {},
                          palette: palette,
                        ),
                        Divider(color: palette.cardBorder),
                        _buildSettingsRow(
                          icon: Icons.translate_rounded,
                          title: 'Bahasa',
                          subtitle: 'Bahasa tampilan antarmuka',
                          trailingText: 'Bahasa Indonesia',
                          onTap: () {},
                          palette: palette,
                        ),
                        Divider(color: palette.cardBorder),
                        _buildSettingsRow(
                          icon: Icons.pin_outlined,
                          title: 'Format Angka',
                          subtitle: 'Pemisah desimal & ribuan',
                          trailingText: '100.000 (Titik ribuan)',
                          onTap: () {},
                          palette: palette,
                        ),
                        Divider(color: palette.cardBorder),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF281E38) : const Color(0xFFFAF5FF),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.dark_mode_outlined, size: 18, color: Color(0xFF9333EA)),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Mode Gelap (Dark Mode)', style: AppText.titleMedium.copyWith(fontWeight: FontWeight.bold, fontSize: 13)),
                                    Text('Gunakan tema gelap ramah mata', style: AppText.bodySm.copyWith(fontSize: 10, color: palette.onSurfaceVariant)),
                                  ],
                                ),
                              ),
                              Switch(
                                value: settings.isDarkMode,
                                onChanged: (val) => cubit.toggleTheme(val),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // NOTIFIKASI Section
                  Text(
                    'NOTIFIKASI',
                    style: AppText.labelSm.copyWith(
                      letterSpacing: 1.1,
                      color: palette.outline,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: palette.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: palette.cardBorder),
                      boxShadow: AppShadows.card,
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF132F28) : const Color(0xFFECFDF5),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.notifications_active_outlined, size: 18, color: Color(0xFF059669)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Notifikasi Push', style: AppText.titleMedium.copyWith(fontWeight: FontWeight.bold, fontSize: 13)),
                                  Text('Pemberitahuan aktivitas grup langsung', style: AppText.bodySm.copyWith(fontSize: 10, color: palette.onSurfaceVariant)),
                                ],
                              ),
                            ),
                            Switch(
                              value: settings.isPushEnabled,
                              onChanged: (val) => cubit.togglePush(val),
                            ),
                          ],
                        ),
                        Divider(color: palette.cardBorder, height: 20),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF3B2E12) : const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.alarm_on_rounded, size: 18, color: Color(0xFFD97706)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Pengingat Pembayaran Otomatis', style: AppText.titleMedium.copyWith(fontWeight: FontWeight.bold, fontSize: 13)),
                                  Text('Kirim pengingat ramah H-1 jatuh tempo', style: AppText.bodySm.copyWith(fontSize: 10, color: palette.onSurfaceVariant)),
                                ],
                              ),
                            ),
                            Switch(
                              value: settings.isAutoReminderEnabled,
                              onChanged: (val) => cubit.toggleAutoReminder(val),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // LAINNYA & DUKUNGAN Section
                  Text(
                    'LAINNYA & DUKUNGAN',
                    style: AppText.labelSm.copyWith(
                      letterSpacing: 1.1,
                      color: palette.outline,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Container(
                    decoration: BoxDecoration(
                      color: palette.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: palette.cardBorder),
                      boxShadow: AppShadows.card,
                    ),
                    child: Column(
                      children: [
                        _buildSettingsRow(
                          icon: Icons.info_outline_rounded,
                          title: 'Tentang Patungan',
                          subtitle: 'Versi aplikasi dan changelog',
                          trailingBadge: 'Versi 2.4.0',
                          onTap: () {},
                          palette: palette,
                        ),
                        Divider(color: palette.cardBorder),
                        _buildSettingsRow(
                          icon: Icons.privacy_tip_outlined,
                          title: 'Kebijakan Privasi & Syarat Ketentuan',
                          subtitle: 'Ketentuan layanan & proteksi data',
                          onTap: () {},
                          palette: palette,
                        ),
                        Divider(color: palette.cardBorder),
                        _buildSettingsRow(
                          icon: Icons.support_agent_rounded,
                          title: 'Pusat Bantuan & Hubungi CS',
                          subtitle: 'FAQ, panduan & respon 24/7',
                          onTap: () {},
                          palette: palette,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Logout Button
                  OutlinedButton.icon(
                    onPressed: () {
                      context.read<AuthBloc>().add(AuthLogoutRequested());
                      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.loginRegister, (r) => false);
                    },
                    icon: const Icon(Icons.logout_rounded, color: Color(0xFFBA1A1A), size: 18),
                    label: const Text('Keluar (Logout)', style: TextStyle(color: Color(0xFFBA1A1A), fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      side: const BorderSide(color: Color(0xFFFFDAD6), width: 1.5),
                      backgroundColor: isDark ? const Color(0xFF2D1616) : const Color(0xFFFFF8F7),
                    ),
                  ),

                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      'ID Akun: PTG-8921-9920',
                      style: AppText.bodySm.copyWith(
                        fontSize: 11,
                        color: palette.outline,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSettingsRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required AppPalette palette,
    String? trailingBadge,
    String? trailingText,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: palette.surfaceLow,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: palette.onSurface),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppText.titleMedium.copyWith(fontWeight: FontWeight.bold, fontSize: 13)),
                  Text(subtitle, style: AppText.bodySm.copyWith(fontSize: 10, color: palette.onSurfaceVariant)),
                ],
              ),
            ),
            if (trailingBadge != null)
              Container(
                margin: const EdgeInsets.only(right: 8),
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
            if (trailingText != null)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  trailingText,
                  style: AppText.bodySm.copyWith(fontSize: 11, color: palette.onSurfaceVariant),
                ),
              ),
            Icon(Icons.chevron_right_rounded, color: palette.outline, size: 20),
          ],
        ),
      ),
    );
  }
}
