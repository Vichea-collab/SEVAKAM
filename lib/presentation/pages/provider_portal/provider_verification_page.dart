import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/utils/app_toast.dart';
import '../../state/profile_settings_state.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/primary_button.dart';

class ProviderVerificationPage extends StatefulWidget {
  static const String routeName = '/provider/verification';

  const ProviderVerificationPage({super.key});

  @override
  State<ProviderVerificationPage> createState() => _ProviderVerificationPageState();
}

class _ProviderVerificationPageState extends State<ProviderVerificationPage> {
  String? _idFrontPath;
  String? _idBackPath;
  bool _submitting = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(bool isFront) async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked != null) {
      setState(() {
        if (isFront) {
          _idFrontPath = picked.path;
        } else {
          _idBackPath = picked.path;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (_idFrontPath == null || _idBackPath == null) {
      AppToast.warning(context, 'Please upload both front and back of your ID.');
      return;
    }

    setState(() => _submitting = true);
    await Future.delayed(const Duration(seconds: 2)); // Simulate upload
    
    if (!mounted) return;
    ProfileSettingsState.providerVerified.value = true;
    AppToast.success(context, 'Verification documents submitted! You are now verified.');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppTopBar(title: 'Provider Verification'),
              const SizedBox(height: 16),
              Text(
                'Upload your National ID or Passport to receive a verified badge and increase customer trust.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              _UploadBox(
                label: 'Front Side',
                path: _idFrontPath,
                onTap: () => _pickImage(true),
              ),
              const SizedBox(height: 16),
              _UploadBox(
                label: 'Back Side',
                path: _idBackPath,
                onTap: () => _pickImage(false),
              ),
              const Spacer(),
              PrimaryButton(
                label: _submitting ? 'Submitting...' : 'Submit for Verification',
                onPressed: _submitting ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UploadBox extends StatelessWidget {
  final String label;
  final String? path;
  final VoidCallback onTap;

  const _UploadBox({required this.label, this.path, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: path != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(File(path!), fit: BoxFit.cover),
                  )
                : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo_outlined, color: AppColors.textSecondary, size: 32),
                      SizedBox(height: 8),
                      Text('Tap to upload', style: TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}
