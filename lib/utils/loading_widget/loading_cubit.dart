import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

part 'loading_state.dart';

// class LoadingCubit extends Cubit<LoadingState> {
//   LoadingCubit() : super(LoadingInitial());
class LoadingProvider extends ChangeNotifier {
  bool isLoading = false;

  void startLoading() {
    isLoading = true;
    // emit(LoadingInProgress());
    notifyListeners();
  }

  void stopLoading() {
    isLoading = false;
    // emit(LoadingComplete());
    notifyListeners();
  }
}
