import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'loading_cubit.dart';  // Make sure to import your LoadingCubit

class Loading extends StatelessWidget {
  final Widget? child;

  const Loading({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoadingCubit, LoadingState>(
      listener: (context, state) {
        // Add any side-effects if needed, e.g., show a snackbar or handle navigation
      },
      builder: (context, state) {
        // final loadingCubit = context.read<LoadingCubit>();
        return IgnorePointer(
          ignoring: (state is LoadingInProgress),
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              child!,
              if (state is LoadingInProgress) ...{
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(16)),
                      color: Colors.black.withOpacity(0.2),
                    ),
                    child: const SpinKitCircle(
                      color: Colors.white,
                      size: 38,
                    ),
                  ),
                )
              },
              // You can handle network errors or other logic here similarly if needed.
            ],
          ),
        );
      },
    );
  }
}
