part of 'loading_cubit.dart';

@immutable
sealed class LoadingState {}

final class LoadingInitial extends LoadingState {}

final class LoadingInProgress extends LoadingState {}

final class LoadingComplete extends LoadingState {}
