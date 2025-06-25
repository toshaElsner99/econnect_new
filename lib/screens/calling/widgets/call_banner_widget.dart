import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_connect/utils/app_color_constants.dart';
import 'package:flutter/material.dart';

import '../call_screen.dart';

class CallingBanner {
  // Singleton instance
  static CallingBanner? _instance;

  // Private constructor
  CallingBanner._();

  // Static getter for singleton instance
  static CallingBanner get instance {
    _instance ??= CallingBanner._();
    return _instance!;
  }

  // Instance variables for state management
  OverlayEntry? _currentEntry;
  bool _isShowing = false;

  // Getter to check if banner is currently showing
  bool get isShowing => _isShowing;

  // Instance method to show call banner
  void showCallBanner(Map data, BuildContext context) {
    // Don't show if already showing
    if (_isShowing) {
      return;
    }

    // Check if overlay is available using the provided context
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) {
      print('CallingBanner: Overlay not available');
      return;
    }

    _currentEntry = OverlayEntry(
      builder: (_) => Positioned(
        top: 40,
        left: 16,
        right: 16,
        child: Material(
          borderRadius: BorderRadius.circular(12),
          color: AppColor.blueColor,
          elevation: 10,
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    hideCallBanner();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CallScreen(
                          callerName: 'John Doe',
                          callerId: '12345',
                          imageUrl:
                              'https://t3.ftcdn.net/jpg/02/99/04/20/360_F_299042079_vGBD7wIlSeNl7vOevWHiL93G4koMM967.jpg',
                          callDirection: CallDirection.incoming
                        ),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: data['imageUrl'] ?? '',
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.grey,
                          ),
                          errorWidget: (context, url, error) =>
                              const CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.grey,
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        data['callerName'] ?? 'Unknown Caller',
                        style: const TextStyle(
                          color: AppColor.whiteColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Spacer(),
                GestureDetector(
                  onTap: () {
                    // Handle decline
                    hideCallBanner();
                    // socket.emit('call_declined', {'callerId': data['callerId']});
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red,
                    ),
                    child: const Icon(Icons.call_end,
                        color: Colors.white, size: 22),
                  ),
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: () {
                    // Handle accept
                    hideCallBanner();
                    // Navigate to call screen or trigger action
                    // socket.emit('call_accepted', {'callerId': data['callerId']});
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green,
                    ),
                    child:
                        const Icon(Icons.call, color: Colors.white, size: 22),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      overlay.insert(_currentEntry!);
      _isShowing = true;

      // Auto-dismiss after 30s
      Future.delayed(const Duration(seconds: 30), () {
        if (_isShowing) {
          hideCallBanner();
        }
      });
    } catch (e) {
      print('CallingBanner: Error showing banner: $e');
      _currentEntry = null;
      _isShowing = false;
    }
  }

  // Instance method to hide call banner
  void hideCallBanner() {
    if (_isShowing && _currentEntry != null) {
      try {
        _currentEntry!.remove();
      } catch (e) {
        print('CallingBanner: Error hiding banner: $e');
      } finally {
        _currentEntry = null;
        _isShowing = false;
      }
    }
  }

  // Static convenience method for backward compatibility
  static void show(Map data, BuildContext context) {
    instance.showCallBanner(data, context);
  }

  // Static convenience method to hide
  static void hide() {
    instance.hideCallBanner();
  }

  // Method to check if banner is currently visible
  static bool get isVisible => instance.isShowing;
}
