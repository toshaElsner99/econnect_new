import 'package:e_connect/providers/status_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B1E23),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Show current status
          Consumer<StatusProvider>(
            builder: (context, statusProvider, child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    statusProvider.currentStatusIcon,
                    color: statusProvider.currentStatusColor,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    statusProvider.currentStatus,
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              );
            },
          ),
          // ... rest of your profile screen widgets
        ],
      ),
    );
  }
} 