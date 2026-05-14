import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../models/app_config.dart';
import '../services/video_service.dart';

class AddVideoScreen extends StatefulWidget {
  final String? initialTitle;
  final String? initialUrl;

  const AddVideoScreen({
    Key? key,
    this.initialTitle,
    this.initialUrl,
  }) : super(key: key);

  @override
  State<AddVideoScreen> createState() => _AddVideoScreenState();
}

class _AddVideoScreenState extends State<AddVideoScreen> {
  late TextEditingController _titleController;
  late TextEditingController _urlController;
  bool _isSubmitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle ?? '');
    _urlController = TextEditingController(text: widget.initialUrl ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_validateForm()) return;

    setState(() => _isSubmitting = true);

    try {
      final videoService = context.read<VideoService>();
      final newVideo = await videoService.createVideo(
        _titleController.text.trim(),
        _urlController.text.trim(),
      );

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Video added successfully'),
            backgroundColor: const Color(AppConfig.successColor),
          ),
        );

        // Navigate to video detail
        context.go('/video/${newVideo.id}');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'Failed to add video: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  bool _validateForm() {
    setState(() => _error = null);

    if (_titleController.text.trim().isEmpty) {
      setState(() => _error = 'Please enter a video title');
      return false;
    }

    if (_urlController.text.trim().isEmpty) {
      setState(() => _error = 'Please enter a video URL');
      return false;
    }

    if (!_isValidUrl(_urlController.text.trim())) {
      setState(() => _error = 'Please enter a valid URL');
      return false;
    }

    return true;
  }

  bool _isValidUrl(String url) {
    try {
      Uri.parse(url);
      return url.startsWith('http://') || url.startsWith('https://');
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(AppConfig.backgroundColor),
      appBar: AppBar(
        title: const Text('Add Video'),
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: const Color(AppConfig.backgroundColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Text
            if (widget.initialTitle != null || widget.initialUrl != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  border: Border.all(
                    color: const Color(0xFFBFDBFE),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info,
                      color: Color(AppConfig.primaryColor),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Pre-filled from share intent',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: const Color(AppConfig.primaryColor),
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            if (widget.initialTitle != null || widget.initialUrl != null)
              const SizedBox(height: 24),

            // Error Message
            if (_error != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  border: Border.all(
                    color: const Color(0xFFFFCDD2),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error,
                      color: Color(AppConfig.destructiveColor),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _error!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: const Color(AppConfig.destructiveColor),
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            if (_error != null) const SizedBox(height: 24),

            // Title Field
            _buildFormField(
              context,
              label: 'Video Title',
              controller: _titleController,
              hint: 'Enter video title',
              maxLines: 1,
            ),
            const SizedBox(height: 24),

            // URL Field
            _buildFormField(
              context,
              label: 'Video URL',
              controller: _urlController,
              hint: 'https://example.com/video',
              maxLines: 2,
            ),
            const SizedBox(height: 48),

            // Form Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSubmitting ? null : () => context.pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      side: const BorderSide(
                        color: Color(AppConfig.borderColor),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: const Color(AppConfig.textPrimary),
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(AppConfig.primaryColor),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Add Video',
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: const Color(AppConfig.textPrimary),
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Color(AppConfig.textTertiary),
            ),
            filled: true,
            fillColor: const Color(AppConfig.surfaceColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(AppConfig.borderColor),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(AppConfig.borderColor),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(AppConfig.primaryColor),
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(AppConfig.textPrimary),
              ),
        ),
      ],
    );
  }
}
