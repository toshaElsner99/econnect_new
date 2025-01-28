import 'package:flutter/material.dart';

class StatusProvider extends ChangeNotifier {
  String _currentStatus = 'Online';
  Color _currentStatusColor = Colors.green;
  IconData _currentStatusIcon = Icons.check_circle;

  String get currentStatus => _currentStatus;
  Color get currentStatusColor => _currentStatusColor;
  IconData get currentStatusIcon => _currentStatusIcon;

  void updateStatus(String status, Color color, IconData icon) {
    _currentStatus = status;
    _currentStatusColor = color;
    _currentStatusIcon = icon;
    notifyListeners();
  }
} 