import 'package:e_connect/screens/splash_screen/splash_screen.dart';
import 'package:e_connect/utils/common/common_widgets.dart';
import 'package:e_connect/utils/loading_widget/loading_cubit.dart';
import 'package:e_connect/utils/loading_widget/loading_widget.dart';
import 'package:e_connect/utils/network_connectivity/network_connectivity.dart';
import 'package:e_connect/utils/theme/theme_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:e_connect/providers/status_provider.dart';

import 'cubit/sign_in/sign_in_model.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
late SignInModel signInModel;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  NetworkStatusService();
  updateSystemUiChrome();
  runApp(
    ChangeNotifierProvider(
      create: (_) => StatusProvider(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider<LoadingCubit>(create: (_) => LoadingCubit()),
          BlocProvider<ThemeCubit>(
            create: (context) => ThemeCubit()..loadThemeMode(), // Initialize ThemeCubit and load theme
          ),
        ],
        child: OKToast(
          child: BlocConsumer<ThemeCubit, ThemeState>(
            listener: (context, state) {
            },
            builder: (context, state) {
              final themeCubit = context.read<ThemeCubit>();
              return MaterialApp(
                title: 'eConnect',
                debugShowCheckedModeBanner: false,
                navigatorKey: navigatorKey,
                theme: themeCubit.themeData,
                home: const SplashScreen(),
                builder: (context, child) {
                  return Loading(child: child!);
                },
              );
            },
          ),
        ),
      ),
    ),
  );
}