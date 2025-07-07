import 'package:e_connect/utils/app_color_constants.dart';
import 'package:e_connect/utils/app_image_assets.dart';
import 'package:e_connect/utils/app_preference_constants.dart';
import 'package:e_connect/utils/common/common_widgets.dart';
import 'package:e_connect/utils/loading_widget/loading_cubit.dart';
import 'package:e_connect/utils/network_connectivity/network_connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';


class Loading extends StatelessWidget {
  final Widget? child;

  const Loading({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return Consumer2<LoadingProvider, NetworkStatusService>(
      builder: (context, loadingData, networkData, _) {
        if (!networkData.connectionValue) {
          return Container(
            color: AppPreferenceConstants.themeModeBoolValueGet ? CupertinoColors.darkBackgroundGray : AppColor.appBarColor,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(AppImage.noInternet,height: 100,width: 100,color: AppPreferenceConstants.themeModeBoolValueGet ? Colors.white : Colors.black,),
                  const SizedBox(height: 16),
                  Cw.commonText(text:
                  networkData.connectionStatus,
                      textAlign: TextAlign.center,
                      color: Colors.white,
                      fontSize: 16,
                      decoration: TextDecoration.none
                  ),
                ],
              ),
            ),
          );
        }

        return IgnorePointer(
          ignoring: (loadingData.isLoading),
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              child!,
              if (loadingData.isLoading)...{
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
      },
    );
  }
}
