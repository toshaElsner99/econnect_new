import 'package:e_connect/cubit/common_cubit/common_cubit.dart';
import 'package:e_connect/main.dart';
import 'package:e_connect/utils/app_color_constants.dart';
import 'package:e_connect/utils/app_image_assets.dart';
import 'package:e_connect/utils/app_string_constants.dart';
import 'package:e_connect/utils/common/common_function.dart';
import 'package:e_connect/utils/common/common_widgets.dart';
import 'package:e_connect/utils/theme/theme_cubit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../utils/app_preference_constants.dart';
import '../../widgets/set_Custom_status_bottom_sheet.dart';
import '../../widgets/status_bottom_sheet.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final commonCubit = CommonCubit();

  void _showStatusBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => StatusBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.commonAppColor,
      // body: BlocBuilder<ThemeCubit, ThemeState>(
      //   builder: (context, state) {
      //     final themeCubit = context.read<ThemeCubit>();
      //     return ;
      //   },
      // ),
      body: BlocConsumer<ThemeCubit, ThemeState>(builder: (context, state) {
        final themeCubit = context.read<ThemeCubit>();
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _buildProfileHeader(),
            ),

            SliverToBoxAdapter(
              child: Column(
                children: [
                  _buildSection(
                    children: [
                      _buildStatusTile(),
                      _buildCustomStatusTile(),
                    ],
                  ),
                  _buildSection(
                    children: [
                      _buildProfileTile(),
                      _buildThemeModeTile(themeCubit),
                    ],
                  ),
                  _buildSection(
                    children: [
                      _buildLogoutTile(),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      }, listener: (context, state) {},),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.3,
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
      decoration: BoxDecoration(
        color: AppColor.commonAppColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          commonImageHolder(radius: 50),
          const SizedBox(height: 16),
          commonText(
            text: "${signInModel.data?.user?.fullName}",
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          const SizedBox(height: 8),
          commonText(
            text: "@${signInModel.data?.user?.username}",
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColor.borderColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColor.borderColor.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildStatusTile() {
    return BlocBuilder<CommonCubit,CommonState>(
      bloc: commonCubit,
      builder: (context, state) {
      return _buildTile(
        onTap: () => _showStatusBottomSheet(context),
        leading: getCommonStatusIcons(
          status: "${commonCubit.getUserModel?.data?.user?.status}",
          assetIcon: false,
        ),
        title: capitalizeFirstLetter("${commonCubit.getUserModel?.data?.user?.status}"),
      );
    },);
  }

  // Widget _buildStatusTile() {
  //   return _buildTile(
  //     onTap: () => _showStatusBottomSheet(context),
  //     leading: getCommonStatusIcons(
  //       status: "${getUserModel?.data?.user?.status}",
  //       assetIcon: false,
  //     ),
  //     title: capitalizeFirstLetter("${getUserModel?.data?.user?.status}"),
  //   );
  // }

  Widget _buildCustomStatusTile() {
    return GestureDetector(
      onTap: () => showCustomStatusSheet(context),
      child: _buildTile(
        leading: Image.asset(
          AppImage.setStatusIcon,
          width: 24,
          height: 24,
          color: Colors.white.withOpacity(0.8),
        ),
        title: AppString.setACustomStatus,
      ),
    );
  }

  Widget _buildProfileTile() {
    return GestureDetector(
      onTap: () => commonProfilePreview(context),
      child: _buildTile(
        leading: Icon(
          CupertinoIcons.person,
          color: Colors.white.withOpacity(0.8),
          size: 24,
        ),
        title: AppString.profile,
      ),
    );
  }

  Widget _buildThemeModeTile(ThemeCubit themeCubit) {
    return _buildTile(
      leading: Image.asset(
        AppPreferenceConstants.themeModeBoolValueGet
            ? AppImage.darkModeIcon
            : AppImage.lightModeIcon,
        height: 24,
        width: 24,
        color: AppPreferenceConstants.themeModeBoolValueGet
            ? Colors.white
            : AppColor.borderColor,
      ),
      title: AppString.themMode,
      trailing: Transform.scale(
        scale: 0.8,
        child: Switch(
          activeColor: AppColor.commonAppColor,
          value: AppPreferenceConstants.themeModeBoolValueGet,
          onChanged: (value) => themeCubit.toggleTheme(),
        ),
      ),
    );
  }

  Widget _buildLogoutTile() {
    return _buildTile(
      onTap: ()=> showLogoutDialog(context),
      leading: Image.asset(
        AppImage.logOut,
        height: 24,
        width: 24,
        color: AppColor.redColor.withOpacity(0.8),
      ),
      title: AppString.logout,
      textColor: AppColor.redColor,
    );
  }

  Widget _buildTile({
    VoidCallback? onTap,
    required Widget leading,
    required String title,
    Widget? trailing,
    Color? textColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            SizedBox(
              width: 32,
              child: Center(child: leading),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: commonText(
                text: title,
                color: textColor ?? Colors.white.withOpacity(0.9),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }
}