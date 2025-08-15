import 'package:flutter/material.dart';
import 'package:clarity/utils/design_system/app_colors.dart';
import 'package:clarity/presentation/widgets/standard_app_bar.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: const StandardAppBar(title: 'Tentang Aplikasi'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAppHeader(isDarkMode),
                  const SizedBox(height: 20),
                  _buildDescriptionSection(isDarkMode),
                  const SizedBox(height: 20),
                  buildFeaturesSection(isDarkMode),
                  const SizedBox(height: 20),
                  _buildTechnicalInfoSection(isDarkMode),
                  const SizedBox(height: 20),
                  _buildDeveloperInfo(isDarkMode),
                  const SizedBox(
                    height: 20,
                  ), // Informasi versi dihapus sesuai permintaan
                ],
              ),
            ),
    );
  }

  Widget _buildFeatureItem(_FeatureItem feature, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDarkMode
                  ? AppColors.primaryColor.withOpacity(0.25)
                  : AppColors.primaryColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.primaryColor.withOpacity(
                  isDarkMode ? 0.3 : 0.2,
                ),
                width: 1,
              ),
            ),
            child: Icon(feature.icon, size: 20, color: AppColors.primaryColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : Colors.grey[900],
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  feature.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                    height: 1.4,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFeaturesSection(bool isDarkMode) {
    final features = [
      _FeatureItem(
        icon: Icons.task_alt,
        title: 'Manajemen Tugas',
        description:
            'Buat, kelola, dan pantau progres tugas dengan sistem prioritas dan deadline yang fleksibel',
      ),
      _FeatureItem(
        icon: Icons.credit_card,
        title: 'Cash Card Management',
        description:
            'Kelola transaksi keuangan, pantau pengeluaran, dan analisis keuangan personal',
      ),
      _FeatureItem(
        icon: Icons.account_circle,
        title: 'Account Management',
        description:
            'Simpan dan kelola akun digital dengan enkripsi tingkat enterprise untuk keamanan maksimal',
      ),
      _FeatureItem(
        icon: Icons.sync,
        title: 'Auto Sync',
        description:
            'Sinkronisasi otomatis lintas perangkat dengan teknologi real-time Firebase',
      ),
      _FeatureItem(
        icon: Icons.security,
        title: 'Keamanan Tingkat Tinggi',
        description:
            'Autentikasi multi-faktor dan enkripsi end-to-end untuk perlindungan data optimal',
      ),
      _FeatureItem(
        icon: Icons.offline_bolt,
        title: 'Offline Support',
        description:
            'Akses penuh ke fitur aplikasi bahkan tanpa koneksi internet',
      ),
      _FeatureItem(
        icon: Icons.analytics,
        title: 'Analytics & Reports',
        description:
            'Dashboard analitik komprehensif untuk tracking produktivitas dan keuangan',
      ),
      _FeatureItem(
        icon: Icons.palette,
        title: 'Customizable Interface',
        description:
            'Tema gelap/terang dan personalisasi interface sesuai preferensi pengguna',
      ),
    ];

    return _buildSection(
      title: 'Fitur Utama',
      icon: Icons.star,
      isDarkMode: isDarkMode,
      child: Column(
        children: features
            .map((feature) => _buildFeatureItem(feature, isDarkMode))
            .toList(),
      ),
    );
  }

  PackageInfo? _packageInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _packageInfo = packageInfo;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Helper methods
  Widget _buildAppHeader(bool isDarkMode) {
    return Card(
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.1),
      color: isDarkMode ? Theme.of(context).colorScheme.surface : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.task_alt,
                        size: 40,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Clarity',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Jernihkan Pikiran, Selesaikan Tugas.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                  if (_packageInfo != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Versi ${_packageInfo!.version} (${_packageInfo!.buildNumber})',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionSection(bool isDarkMode) {
    return _buildSection(
      title: 'Deskripsi',
      icon: Icons.description,
      isDarkMode: isDarkMode,
      child: Text(
        'Clarity adalah aplikasi komprehensif yang dirancang untuk meningkatkan produktivitas dan efisiensi dalam mengelola tugas harian, keuangan, dan akun digital Anda. '
        'Dengan desain yang intuitif dan fitur-fitur canggih, aplikasi ini menjadi solusi all-in-one untuk kebutuhan manajemen personal dan profesional.\n\n'
        'Dikembangkan dengan teknologi terdepan dan mengutamakan keamanan data pengguna, aplikasi ini menyediakan sinkronisasi real-time dan akses multi-platform untuk memastikan data Anda selalu tersedia kapan pun dibutuhkan.',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          height: 1.6,
          color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
          fontSize: 15,
        ),
      ),
    );
  }

  Widget _buildTechSpecItem(_TechSpec spec, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              spec.label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primaryColor,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              spec.value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ...existing code...
  // Helper methods moved to top for correct scoping
  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
    bool isDarkMode = false,
  }) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      margin: const EdgeInsets.only(bottom: 8),
      color: isDarkMode ? Theme.of(context).colorScheme.surface : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primaryColor, size: 26),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            child,
          ],
        ),
      ),
    );
    // ...existing code...
  }

  Widget _buildTechnicalInfoSection(bool isDarkMode) {
    final techSpecs = [
      _TechSpec('Platform', 'Flutter 3.x (Android, iOS, Web, Windows)'),
      _TechSpec('Database', 'Firebase Firestore with offline persistence'),
      _TechSpec('Authentication', 'Firebase Auth with multi-factor support'),
      _TechSpec('Storage', 'Local storage with Hive + Cloud backup'),
      _TechSpec('Sync Engine', 'Real-time bidirectional synchronization'),
      _TechSpec('Security', 'AES-256 encryption + TLS 1.3'),
      _TechSpec('Performance', 'Optimized for low-latency operations'),
      _TechSpec('Compatibility', 'Android 6.0+, iOS 11.0+, Modern browsers'),
    ];

    return _buildSection(
      title: 'Informasi Teknis',
      icon: Icons.engineering,
      isDarkMode: isDarkMode,
      child: Column(
        children: techSpecs
            .map((spec) => _buildTechSpecItem(spec, isDarkMode))
            .toList(),
      ),
    );
  }

  Widget _buildDeveloperInfo(bool isDarkMode) {
    return _buildSection(
      title: 'Informasi Developer',
      icon: Icons.person_outline,
      isDarkMode: isDarkMode,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? AppColors.primaryColor.withOpacity(0.15)
                  : AppColors.primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primaryColor.withOpacity(
                  isDarkMode ? 0.2 : 0.1,
                ),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor.withOpacity(
                          isDarkMode ? 0.4 : 0.3,
                        ),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fathur Rohim',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryColor,
                              fontSize: 18,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Mobile Developer',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDarkMode
                              ? Colors.grey[300]
                              : Colors.grey[700],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Passionate Flutter developer focused on creating intuitive and powerful mobile applications.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDarkMode
                              ? Colors.grey[400]
                              : Colors.grey[600],
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildDeveloperDetail('Nama Lengkap', 'Fathur Rohim', isDarkMode),
          _buildDeveloperDetail(
            'Spesialisasi',
            'Flutter & Dart Development',
            isDarkMode,
          ),
          _buildDeveloperDetail(
            'Platform',
            'Android, iOS, Web, Desktop',
            isDarkMode,
          ),
          _buildDeveloperDetail(
            'Pengalaman',
            'Mobile App Development',
            isDarkMode,
          ),
          _buildDeveloperDetail(
            'Focus Area',
            'UI/UX Design & Backend Integration',
            isDarkMode,
          ),
        ],
      ),
    );
  }

  Widget _buildDeveloperDetail(String label, String value, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primaryColor,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Informasi versi dan helper terkait telah dihapus
}

class _FeatureItem {
  final IconData icon;
  final String title;
  final String description;

  _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class _TechSpec {
  final String label;
  final String value;

  _TechSpec(this.label, this.value);
}
