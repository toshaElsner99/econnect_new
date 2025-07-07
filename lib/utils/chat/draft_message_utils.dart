import '../app_preference_constants.dart';
import '../common/prefrance_function.dart';

/// Utility class for handling draft messages in chat screens
class DraftMessageUtils {
  /// Get the draft message key for a specific chat
  static String getDraftKey(String chatId, {bool isChannel = false}) {
    final prefix = isChannel ? "channel_" : "";
    return "${AppPreferenceConstants.draftMessageKey}${prefix}${chatId}";
  }

  /// Save a draft message for a specific chat
  static Future<void> saveDraftMessage(String chatId, String message, {bool isChannel = false}) async {
    try {
      final draftKey = getDraftKey(chatId, isChannel: isChannel);
      if (message.trim().isNotEmpty) {
        await setData(draftKey, message);
        print("Saved draft for ${isChannel ? 'channel' : 'chat'} $chatId: $draftKey = $message");
      } else {
        await clearDraftMessage(chatId, isChannel: isChannel);
      }
    } catch (e) {
      print("Error saving draft for ${isChannel ? 'channel' : 'chat'} $chatId: $e");
    }
  }

  /// Load a draft message for a specific chat
  static Future<String?> loadDraftMessage(String chatId, {bool isChannel = false}) async {
    try {
      final draftKey = getDraftKey(chatId, isChannel: isChannel);
      final draftMessage = await getData(draftKey);
      if (draftMessage != null && draftMessage.trim().isNotEmpty) {
        print("Loaded draft for ${isChannel ? 'channel' : 'chat'} $chatId: $draftMessage");
        return draftMessage;
      }
    } catch (e) {
      print("Error loading draft for ${isChannel ? 'channel' : 'chat'} $chatId: $e");
    }
    return null;
  }

  /// Clear a draft message for a specific chat
  static Future<void> clearDraftMessage(String chatId, {bool isChannel = false}) async {
    try {
      final draftKey = getDraftKey(chatId, isChannel: isChannel);
      await removeData(draftKey);
      print("Cleared draft for ${isChannel ? 'channel' : 'chat'} $chatId");
    } catch (e) {
      print("Error clearing draft for ${isChannel ? 'channel' : 'chat'} $chatId: $e");
    }
  }

  /// Check if a draft message exists for a specific chat
  static Future<bool> hasDraftMessage(String chatId, {bool isChannel = false}) async {
    try {
      final draftMessage = await loadDraftMessage(chatId, isChannel: isChannel);
      return draftMessage != null && draftMessage.trim().isNotEmpty;
    } catch (e) {
      print("Error checking draft for ${isChannel ? 'channel' : 'chat'} $chatId: $e");
      return false;
    }
  }
} 