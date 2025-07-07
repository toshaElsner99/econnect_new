import 'package:e_connect/model/get_user_model.dart';
import 'package:e_connect/utils/api_service/api_service.dart';
import 'package:e_connect/utils/api_service/api_string_constants.dart';
import 'package:e_connect/utils/common/common_function.dart';

/// Global user cache service for storing and retrieving user data
/// This service provides a centralized way to manage user data across the entire app
class UserCacheService {
  static final UserCacheService _instance = UserCacheService._internal();
  factory UserCacheService() => _instance;
  UserCacheService._internal();

  // Cache storage
  final Map<String, GetUserModel> _userCache = {};
  final Map<String, GetUserModelSecondUser> _secondUserCache = {};
  
  // Cache expiration (24 hours)
  final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheExpiration = Duration(hours: 24);

  /// Get user data from cache or fetch from API if not available
  Future<GetUserModel?> getUserData(String userId) async {
    // Check if user exists in cache and is not expired
    if (_userCache.containsKey(userId) && !_isCacheExpired(userId)) {
      return _userCache[userId];
    }

    // Fetch from API
    try {
      final response = await ApiService.instance.request(
        endPoint: "${ApiString.getUserById}/$userId",
        method: Method.POST,
        isRawPayload: false,
      );

      if (Cf.instance.statusCode200Check(response)) {
        final userModel = GetUserModel.fromJson(response);
        _cacheUser(userId, userModel);
        return userModel;
      }
    } catch (e) {
      print("Error fetching user data for $userId: $e");
    }

    return null;
  }

  /// Get second user data from cache or fetch from API if not available
  Future<GetUserModelSecondUser?> getSecondUserData(String userId) async {
    // Check if user exists in cache and is not expired
    if (_secondUserCache.containsKey(userId) && !_isCacheExpired(userId)) {
      return _secondUserCache[userId];
    }

    // Fetch from API
    try {
      final response = await ApiService.instance.request(
        endPoint: "${ApiString.getUserById}/$userId",
        method: Method.POST,
        isRawPayload: false,
      );

      if (Cf.instance.statusCode200Check(response)) {
        final userModel = GetUserModelSecondUser.fromJson(response);
        _cacheSecondUser(userId, userModel);
        return userModel;
      }
    } catch (e) {
      print("Error fetching second user data for $userId: $e");
    }

    return null;
  }

  /// Get user data synchronously from cache only (no API call)
  GetUserModel? getUserDataSync(String userId) {
    if (_userCache.containsKey(userId) && !_isCacheExpired(userId)) {
      return _userCache[userId];
    }
    return null;
  }

  /// Get second user data synchronously from cache only (no API call)
  GetUserModelSecondUser? getSecondUserDataSync(String userId) {
    if (_secondUserCache.containsKey(userId) && !_isCacheExpired(userId)) {
      return _secondUserCache[userId];
    }
    return null;
  }

  /// Cache user data
  void cacheUser(String userId, GetUserModel userModel) {
    _cacheUser(userId, userModel);
  }

  /// Cache second user data
  void cacheSecondUser(String userId, GetUserModelSecondUser userModel) {
    _cacheSecondUser(userId, userModel);
  }

  /// Remove user from cache
  void removeUser(String userId) {
    _userCache.remove(userId);
    _secondUserCache.remove(userId);
    _cacheTimestamps.remove(userId);
  }

  /// Clear all cache
  void clearCache() {
    _userCache.clear();
    _secondUserCache.clear();
    _cacheTimestamps.clear();
  }

  /// Get cache statistics
  Map<String, dynamic> getCacheStats() {
    return {
      'userCacheSize': _userCache.length,
      'secondUserCacheSize': _secondUserCache.length,
      'totalCachedUsers': _cacheTimestamps.length,
    };
  }

  /// Check if cache is expired for a user
  bool _isCacheExpired(String userId) {
    final timestamp = _cacheTimestamps[userId];
    if (timestamp == null) return true;
    
    return DateTime.now().difference(timestamp) > _cacheExpiration;
  }

  /// Cache user data with timestamp
  void _cacheUser(String userId, GetUserModel userModel) {
    _userCache[userId] = userModel;
    _cacheTimestamps[userId] = DateTime.now();
  }

  /// Cache second user data with timestamp
  void _cacheSecondUser(String userId, GetUserModelSecondUser userModel) {
    _secondUserCache[userId] = userModel;
    _cacheTimestamps[userId] = DateTime.now();
  }

  /// Preload multiple users at once
  Future<void> preloadUsers(List<String> userIds) async {
    for (String userId in userIds) {
      if (!_userCache.containsKey(userId) || _isCacheExpired(userId)) {
        await getUserData(userId);
      }
    }
  }

  /// Get user display name (username or fullName) - sync version (cache only)
  String getUserDisplayName(String userId) {
    final user = getUserDataSync(userId);
    if (user != null) {
      return user.data?.user?.fullName ?? 
             user.data?.user?.username ?? 
             'Unknown';
    }
    
    final secondUser = getSecondUserDataSync(userId);
    if (secondUser != null) {
      return secondUser.data?.user?.fullName ?? 
             secondUser.data?.user?.username ?? 
             'Unknown';
    }
    
    return 'Unknown';
  }

  /// Get user display name with API fallback
  Future<String> getUserDisplayNameAsync(String userId) async {
    // Try cache first
    String displayName = getUserDisplayName(userId);
    if (displayName != 'Unknown') {
      return displayName;
    }

    // Try to fetch from API
    try {
      final user = await getUserData(userId);
      if (user != null) {
        return user.data?.user?.fullName ?? 
               user.data?.user?.username ?? 
               'Unknown';
      }

      final secondUser = await getSecondUserData(userId);
      if (secondUser != null) {
        return secondUser.data?.user?.fullName ?? 
               secondUser.data?.user?.username ?? 
               'Unknown';
      }
    } catch (e) {
      print("Error fetching user display name for $userId: $e");
    }

    return 'Unknown';
  }

  /// Get user avatar URL - sync version (cache only)
  String getUserAvatarUrl(String userId) {
    final user = getUserDataSync(userId);
    if (user != null) {
      return user.data?.user?.thumbnailAvatarUrl ?? 
             user.data?.user?.avatarUrl ?? 
             '';
    }
    
    final secondUser = getSecondUserDataSync(userId);
    if (secondUser != null) {
      return secondUser.data?.user?.thumbnailAvatarUrl ?? 
             secondUser.data?.user?.avatarUrl ?? 
             '';
    }
    
    return '';
  }

  /// Get user avatar URL with API fallback
  Future<String> getUserAvatarUrlAsync(String userId) async {
    // Try cache first
    String avatarUrl = getUserAvatarUrl(userId);
    if (avatarUrl.isNotEmpty) {
      return avatarUrl;
    }

    // Try to fetch from API
    try {
      final user = await getUserData(userId);
      if (user != null) {
        return user.data?.user?.thumbnailAvatarUrl ?? 
               user.data?.user?.avatarUrl ?? 
               '';
      }

      final secondUser = await getSecondUserData(userId);
      if (secondUser != null) {
        return secondUser.data?.user?.thumbnailAvatarUrl ?? 
               secondUser.data?.user?.avatarUrl ?? 
               '';
      }
    } catch (e) {
      print("Error fetching user avatar for $userId: $e");
    }

    return '';
  }

  /// Get user status - sync version (cache only)
  String getUserStatus(String userId) {
    final user = getUserDataSync(userId);
    if (user != null) {
      return user.data?.user?.status ?? 'offline';
    }
    
    final secondUser = getSecondUserDataSync(userId);
    if (secondUser != null) {
      return secondUser.data?.user?.status ?? 'offline';
    }
    
    return 'offline';
  }

  /// Get user status with API fallback
  Future<String> getUserStatusAsync(String userId) async {
    // Try cache first
    String status = getUserStatus(userId);
    if (status != 'offline') {
      return status;
    }

    // Try to fetch from API
    try {
      final user = await getUserData(userId);
      if (user != null) {
        return user.data?.user?.status ?? 'offline';
      }

      final secondUser = await getSecondUserData(userId);
      if (secondUser != null) {
        return secondUser.data?.user?.status ?? 'offline';
      }
    } catch (e) {
      print("Error fetching user status for $userId: $e");
    }

    return 'offline';
  }

  /// Check if user exists in cache
  bool hasUser(String userId) {
    return (_userCache.containsKey(userId) || _secondUserCache.containsKey(userId)) && 
           !_isCacheExpired(userId);
  }
} 