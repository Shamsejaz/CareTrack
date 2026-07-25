import 'package:flutter/material.dart';

void showErrorSnackBar(BuildContext context, String prefix, Object error) {
  final errorStr = error.toString().toLowerCase();
  String userFriendlyMessage;

  if (errorStr.contains('socketexception') || 
      errorStr.contains('failed host lookup') || 
      errorStr.contains('network') ||
      errorStr.contains('connection failed') ||
      errorStr.contains('clientexception') ||
      errorStr.contains('network_error') ||
      errorStr.contains('host lookup')) {
    userFriendlyMessage = 'You are offline. Please check your network connection and try again.';
  } else if (errorStr.contains('invalid login credentials') || errorStr.contains('invalid_credentials')) {
    userFriendlyMessage = 'Incorrect email or password. Please verify and try again.';
  } else {
    userFriendlyMessage = '$prefix: ${error.toString()}';
    // Clean up standard prefixes
    userFriendlyMessage = userFriendlyMessage
        .replaceAll('Exception: ', '')
        .replaceAll('AuthException: ', '')
        .replaceAll('AuthApiException: ', '');
  }

  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              userFriendlyMessage,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFD32F2F), // Premium deep red
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 4),
      elevation: 6,
    ),
  );
}
