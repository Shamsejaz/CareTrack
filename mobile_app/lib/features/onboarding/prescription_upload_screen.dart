import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PrescriptionUploadScreen extends StatefulWidget {
  const PrescriptionUploadScreen({super.key});

  @override
  State<PrescriptionUploadScreen> createState() => _PrescriptionUploadScreenState();
}

class _PrescriptionUploadScreenState extends State<PrescriptionUploadScreen> {
  bool _isAnalyzing = false;

  void _simulateUpload() async {
    setState(() => _isAnalyzing = true);
    
    // Simulate AI parsing delay
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      setState(() => _isAnalyzing = false);
      context.push('/setup/prescription/review');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isAnalyzing) {
      return _buildAnalyzingState(context);
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context),
      body: Stack(
        children: [
          _buildBackgroundElements(context),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildEditorialHeader(context),
                  const SizedBox(height: 48),
                  _buildPrimaryAction(context),
                  const SizedBox(height: 24),
                  _buildSecondaryActions(context),
                  const SizedBox(height: 48),
                  _buildPrivacySection(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_rounded, color: Theme.of(context).colorScheme.primaryContainer),
        onPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/dashboard');
          }
        },
      ),
      title: Text(
        'CareTrack',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildBackgroundElements(BuildContext context) {
    return Positioned(
      right: 0,
      top: 0,
      width: MediaQuery.of(context).size.width * 0.4,
      height: MediaQuery.of(context).size.height,
      child: Opacity(
        opacity: 0.05,
        child: Image.network(
          'https://lh3.googleusercontent.com/aida-public/AB6AXuA7Txew3nTt4IGqQruEfbt8hUHgZuDK9EVHHNjSdCRczorznUzqV23SYS2WDWjjJTH6wTPSvRrn_ACqSY_VEjs4TCFgWL2bGDXrwIVy_0rz7KnP4hgT-QaV1tFa9vfZMTEYVkVYhb72a7AXP9JGNQ9-XPLGF5ojC2SGam33wQ7FRK-Wz6vT6b7Japv09Yv3dXRjKTfctG66AgDPoP_DixYuVepHyFw3nStrGZJcauc0FgAdsZ3Ef_x56MialNIA-DWSLKA6mpdL0Q',
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildEditorialHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AI ENGINE',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.tertiary,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Add a new prescription.',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onSurface,
                height: 1.1,
              ),
        ),
        const SizedBox(height: 16),
        Text(
          'Our empathetic AI will analyze your document to schedule reminders and check for potential interactions.',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  Widget _buildPrimaryAction(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
            blurRadius: 40,
            spreadRadius: 5,
            offset: const Offset(0, 20),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _simulateUpload,
          borderRadius: BorderRadius.circular(32),
          child: Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primaryContainer,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.photo_camera_rounded, color: Colors.white, size: 56),
                ),
                const SizedBox(height: 24),
                Text(
                  'Take a Photo',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Point your camera at the physical prescription for instant scanning',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildSecondaryButton(
            context,
            icon: Icons.upload_file_rounded,
            iconColor: Theme.of(context).colorScheme.onTertiaryContainer, // mapped from on-tertiary-fixed-variant
            iconBg: Theme.of(context).colorScheme.tertiaryContainer, // mapped from tertiary-fixed
            title: 'Upload PDF',
            sub: 'Digital files or scans',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSecondaryButton(
            context,
            icon: Icons.history_rounded,
            iconColor: Theme.of(context).colorScheme.onSecondaryContainer,
            iconBg: Theme.of(context).colorScheme.secondaryContainer,
            title: 'Browse Gallery',
            sub: 'Select from camera roll',
          ),
        ),
      ],
    );
  }

  Widget _buildSecondaryButton(BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String sub,
  }) {
    return InkWell(
      onTap: _simulateUpload,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBg.withOpacity(0.4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(sub, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacySection(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.verified_user_rounded, color: Theme.of(context).colorScheme.secondary, size: 16),
            const SizedBox(width: 8),
            Text(
              'Your medical data is encrypted & HIPAA compliant',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyzingState(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            Text(
              'Analyzing Prescription...',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Extracting medicines and dosages safely.',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
