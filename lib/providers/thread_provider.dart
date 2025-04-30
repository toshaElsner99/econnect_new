import 'package:flutter/material.dart';
import '../model/thread_counts_model.dart';
import '../model/thread_model.dart';
import '../utils/api_service/api_service.dart';
import '../utils/api_service/api_string_constants.dart';
import '../utils/common/common_function.dart';

class ThreadProvider extends ChangeNotifier {
  List<Thread> _threads = [];
  bool _isLoading = false;
  String? _error;
  int unreadThreadCount = 0;

  // Getters
  List<Thread> get threads => _threads;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch unread threads
  Future<void> fetchUnreadThreads() async {
    try {
      _isLoading = true;
      _error = null;
      // notifyListeners();

      final response = await ApiService.instance.request(
          endPoint: ApiString.getUnreadThread,
          method: Method.POST,
          reqBody: {});

      if (Cf.instance.statusCode200Check(response)) {
        _threads = (response['data'] as List).map((list) => Thread.fromJson(list as Map<String, dynamic>)).toList();
        print("_threads= $_threads");
      } else {
        _error = 'Failed to fetch threads. Status code: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Error fetching threads: $e';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch unread thread count
  Future<void> fetchUnreadThreadCount() async {
    try {
      final response = await ApiService.instance.request(
          endPoint: ApiString.getUnreadThreadCounts,
          method: Method.GET);

      if (Cf.instance.statusCode200Check(response)) {
        final ThreadCountsModel countModel = ThreadCountsModel.fromJson(response);
        unreadThreadCount = countModel.data?.count ?? 0;
      } else {
        print('Failed to fetch unread thread count: ${response['message']}');
      }
    } catch (e) {
      print('Error fetching unread thread count: $e');
    }
    notifyListeners();
  }
}
