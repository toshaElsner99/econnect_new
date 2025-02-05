part of 'common_cubit.dart';

@immutable
sealed class CommonState {}

final class CommonInitial extends CommonState {}
final class CommonLoading extends CommonState {}
final class SuccessState extends CommonState {}
final class FailureState extends CommonState {}
