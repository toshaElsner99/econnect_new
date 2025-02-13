import 'package:e_connect/utils/loading_widget/loading_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';


class Loading extends StatelessWidget {
  final Widget? child;

  const Loading({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return Consumer<LoadingProvider>(builder: (context, data, _) {
      return  IgnorePointer(
        ignoring: (data.isLoading),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            child!,
            if (data.isLoading)...{
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(16)),
                      color: Colors.black.withOpacity(0.2)
                  ),
                  child: const SpinKitCircle(
                    color: Colors.white,
                    size: 38,
                  ),
                ),
              )
            },
          ],
        ),
      );
    },);
  }
}
