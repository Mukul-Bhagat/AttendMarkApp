import 'package:flutter/material.dart';
import '../config/theme.dart';

/// Primary button widget
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  
  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.width,
  });
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}

/// Secondary button widget
class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  
  const SecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
  });
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppTheme.primaryRed),
          foregroundColor: AppTheme.primaryRed,
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryRed),
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}

/// Text button widget
class AppTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  
  const AppTextButton({
    super.key,
    required this.text,
    this.onPressed,
  });
  
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(text),
    );
  }
}

