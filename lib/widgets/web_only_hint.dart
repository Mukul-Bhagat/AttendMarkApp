import 'package:flutter/material.dart';
import '../config/theme.dart';

/// Web-Only Hint Widget
/// Shows a message indicating the feature is only available on web
class WebOnlyHint extends StatelessWidget {
  final String? customMessage;
  
  const WebOnlyHint({
    super.key,
    this.customMessage,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: AppTheme.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.info.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: AppTheme.info,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              customMessage ?? 'Manage this from web dashboard',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.info,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

