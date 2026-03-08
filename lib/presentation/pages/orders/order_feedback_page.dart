import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../domain/entities/order.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/primary_button.dart';

class OrderFeedbackPage extends StatefulWidget {
  final OrderItem order;

  const OrderFeedbackPage({super.key, required this.order});

  @override
  State<OrderFeedbackPage> createState() => _OrderFeedbackPageState();
}

class _OrderFeedbackPageState extends State<OrderFeedbackPage> {
  late int _rating;
  late final TextEditingController _feedbackController;
  final List<String> _photoPaths = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final currentRating = widget.order.rating ?? 4;
    _rating = currentRating.clamp(1, 5).round();
    _feedbackController = TextEditingController(
      text: widget.order.reviewComment,
    );
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (_photoPaths.length >= 5) return;
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked != null) {
      setState(() {
        _photoPaths.add(picked.path);
      });
    }
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
              const AppTopBar(title: 'Give your feedback'),
              const SizedBox(height: 18),
              Text(
                'How was your experience with ${widget.order.provider.name}?',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 14),
              Row(
                children: List.generate(5, (index) {
                  final active = index < _rating;
                  return IconButton(
                    onPressed: () => setState(() => _rating = index + 1),
                    icon: Icon(
                      active ? Icons.star : Icons.star_border,
                      color: active ? AppColors.primary : AppColors.divider,
                      size: 34,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 10),
              Text(
                'Add photos (optional)',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 80,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    ..._photoPaths.map((path) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(File(path), width: 80, height: 80, fit: BoxFit.cover),
                          ),
                          Positioned(
                            top: 2,
                            right: 2,
                            child: GestureDetector(
                              onTap: () => setState(() => _photoPaths.remove(path)),
                              child: Container(
                                decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                child: const Icon(Icons.close, color: Colors.white, size: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                    if (_photoPaths.length < 5)
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Theme.of(context).dividerColor),
                          ),
                          child: const Icon(Icons.add_a_photo_outlined, color: AppColors.textSecondary),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Write in below box',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _feedbackController,
                maxLines: 5,
                maxLength: 500,
                decoration: const InputDecoration(
                  hintText: 'Write here...',
                  alignLabelWithHint: true,
                ),
              ),
              const Spacer(),
              PrimaryButton(label: 'Send', onPressed: _submit),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    final comment = _feedbackController.text.trim();
    final updated = widget.order.copyWith(
      status: OrderStatus.completed,
      rating: _rating.toDouble(),
      reviewComment: comment,
      photoUrls: _photoPaths,
    );
    Navigator.pop(context, updated);
  }
}
