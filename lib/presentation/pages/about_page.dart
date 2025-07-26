import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myapp/utils/design_system/app_colors.dart';
import 'package:myapp/presentation/widgets/standard_app_bar.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
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

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Disalin ke clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: StandardAppBar(
        title: 'Tentang Clarity',
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 2,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAppHeader(),
                  const SizedBox(height: 20),
                  _buildDescriptionSection(),
                  const SizedBox(height: 16),
                  _buildFeaturesSection(),
                  const SizedBox(height: 16),
                  _buildTechnicalInfoSection(),
                  const SizedBox(height: 16),
                  _buildDeveloperInfo(),
                  const SizedBox(height: 16),
                  _buildVersionInfo(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildAppHeader() {
    return Card(
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.1),
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
                    // Fallback to icon if image fails to load
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
                      color: Colors.grey[700],
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

  Widget _buildDescriptionSection() {
    return _buildSection(
      title: 'Deskripsi',
      icon: Icons.description,
      child: Text(
        'Clarity adalah aplikasi komprehensif yang dirancang untuk meningkatkan produktivitas dan efisiensi dalam mengelola tugas harian, keuangan, dan akun digital Anda. '
        'Dengan desain yang intuitif dan fitur-fitur canggih, aplikasi ini menjadi solusi all-in-one untuk kebutuhan manajemen personal dan profesional.\n\n'
        'Dikembangkan dengan teknologi terdepan dan mengutamakan keamanan data pengguna, aplikasi ini menyediakan sinkronisasi real-time dan akses multi-platform untuk memastikan data Anda selalu tersedia kapan pun dibutuhkan.',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          height: 1.6,
          color: Colors.grey[800],
          fontSize: 15,
        ),
      ),
    );
  }

  Widget _buildFeaturesSection() {
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
      child: Column(
        children: features
            .map((feature) => _buildFeatureItem(feature))
            .toList(),
      ),
    );
  }

  Widget _buildFeatureItem(_FeatureItem feature) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.primaryColor.withOpacity(0.2),
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
                    color: Colors.grey[900],
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  feature.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[700],
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

  Widget _buildTechnicalInfoSection() {
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
      child: Column(
        children: techSpecs.map((spec) => _buildTechSpecItem(spec)).toList(),
      ),
    );
  }

  Widget _buildTechSpecItem(_TechSpec spec) {
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
                color: Colors.grey[800],
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeveloperInfo() {
    return _buildSection(
      title: 'Informasi Developer',
      icon: Icons.person_outline,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primaryColor.withOpacity(0.1),
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
                        color: AppColors.primaryColor.withOpacity(0.3),
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
                          color: Colors.grey[700],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Passionate Flutter developer focused on creating intuitive and powerful mobile applications.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
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
          _buildDeveloperDetail('Nama Lengkap', 'Fathur Rohim'),
          _buildDeveloperDetail('Spesialisasi', 'Flutter & Dart Development'),
          _buildDeveloperDetail('Platform', 'Android, iOS, Web, Desktop'),
          _buildDeveloperDetail('Pengalaman', 'Mobile App Development'),
          _buildDeveloperDetail(
            'Focus Area',
            'UI/UX Design & Backend Integration',
          ),
        ],
      ),
    );
  }

  Widget _buildDeveloperDetail(String label, String value) {
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
                color: Colors.grey[800],
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionInfo() {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      color: Colors.grey[50],
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.primaryColor,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  'Informasi Versi',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryColor,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_packageInfo != null) ...[
              _buildVersionItem('Nama Aplikasi', _packageInfo!.appName),
              _buildVersionItem('Package Name', _packageInfo!.packageName),
              _buildVersionItem('Versi', _packageInfo!.version),
              _buildVersionItem('Build Number', _packageInfo!.buildNumber),
            ],
            _buildVersionItem(
              'Build Date',
              DateTime.now().toString().split(' ')[0],
            ),
            _buildVersionItem('Flutter Version', '3.x.x'),
            _buildVersionItem('Dart Version', '3.x.x'),
            const SizedBox(height: 12),
            Center(
              child: Text(
                '© 2024 Clarity. All rights reserved.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVersionItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[700],
                fontSize: 13,
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: GestureDetector(
              onLongPress: () => _copyToClipboard(value),
              child: Text(
                value,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[900],
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      margin: const EdgeInsets.only(bottom: 8),
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
  }
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
