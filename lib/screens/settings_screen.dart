import 'package:flutter/material.dart';
import 'package:e_connect/widgets/status_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:e_connect/providers/status_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showStatusBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => StatusBottomSheet(
        onStatusSelected: (status, color, icon) {
          context.read<StatusProvider>().updateStatus(status, color, icon);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B1E23),
      body: ListView(
        children: [
          Consumer<StatusProvider>(
            builder: (context, statusProvider, child) {
              return ListTile(
                leading: const Icon(
                  Icons.emoji_emotions_outlined,
                  color: Colors.grey,
                ),
                title: const Text(
                  'Set a custom status',
                  style: TextStyle(color: Colors.grey),
                ),
                subtitle: Row(
                  children: [
                    Icon(
                      statusProvider.currentStatusIcon,
                      color: statusProvider.currentStatusColor,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      statusProvider.currentStatus,
                      style: TextStyle(color: statusProvider.currentStatusColor),
                    ),
                  ],
                ),
                onTap: () => _showStatusBottomSheet(context),
              );
            },
          ),
          // Add other settings options here
        ],
      ),
    );
  }
} 