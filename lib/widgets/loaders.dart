import 'package:flutter/material.dart';
import '../config/theme.dart';

/// Full screen loading indicator
class FullScreenLoader extends StatelessWidget {
  final String? message;
  
  const FullScreenLoader({
    super.key,
    this.message,
  });
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryRed),
            ),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message!,
                style: const TextStyle(
                  color: AppTheme.darkTextSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Center loading indicator
class CenterLoader extends StatelessWidget {
  final String? message;
  
  const CenterLoader({
    super.key,
    this.message,
  });
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryRed),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: const TextStyle(
                color: AppTheme.darkTextSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Small loading indicator
class SmallLoader extends StatelessWidget {
  const SmallLoader({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 20,
      width: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryRed),
      ),
    );
  }
}

