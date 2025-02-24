
import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_connect/main.dart';
import 'package:e_connect/utils/app_color_constants.dart';
import 'package:e_connect/utils/app_image_assets.dart';
import 'package:e_connect/utils/app_string_constants.dart';
import 'package:e_connect/utils/common/common_function.dart';
import 'package:e_connect/utils/common/common_widgets.dart';
import 'package:e_connect/utils/theme/theme_cubit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/common_provider.dart';
import '../../utils/app_preference_constants.dart';
import '../../widgets/set_Custom_status_bottom_sheet.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {


  @override
  Widget build(BuildContext context) {
    return Consumer2<CommonProvider,ThemeProvider>(builder: (context, commonProvider,themeProvider, child) {
      return Scaffold(
        backgroundColor: AppPreferenceConstants.themeModeBoolValueGet ? AppColor.darkAppBarColor : AppColor.appBarColor,
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _buildProfileHeader(),
            ),

            SliverToBoxAdapter(
              child: Column(
                children: [
                  _buildSection(
                    children: [
                      _buildStatusTile(commonProvider),
                      _buildCustomStatusTile(commonProvider),
                    ],
                  ),
                  _buildSection(
                    children: [
                      _buildProfileTile(),
                      _buildThemeModeTile(themeProvider),
                    ],
                  ),
                  _buildSection(
                    children: [
                      _buildLogoutTile(),
                    ],
                  ),
                  closeScreen()
                ],
              ),
            ),
          ],
        ),
      );
    },);
  }

  Container closeScreen() {
    return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColor.borderColor.withOpacity(0.15),
                    // borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColor.redColor.withOpacity(0.4),
                    ),
                  ),
                  child: IconButton(onPressed: () => pop(), icon: Icon(Icons.close,color: Colors.white,)),
                );
  }

  Widget _buildProfileHeader() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.3,
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
      decoration: BoxDecoration(
        // color: AppColor.commonAppColor,
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
            text: signInModel.data?.user?.fullName ?? signInModel.data?.user?.username ?? "",
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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

  Widget _buildStatusTile(CommonProvider commonProvider) {
    print("STATUSS >>> ${commonProvider.getUserModel?.data?.user!.status!}");
    return _buildTile(
      onTap: () => _showStatusBottomSheet(context),
      leading: getCommonStatusIcons(
        status: "${commonProvider.getUserModel?.data?.user!.status!}",
        assetIcon: false,
      ),
      title: capitalizeFirstLetter("${commonProvider.getUserModel?.data?.user!.status!}"),
    );
  }


  Widget _buildCustomStatusTile(CommonProvider commonProvider) {
    return GestureDetector(
      onTap: () => showCustomStatusSheet(context),
      child: _buildTile(
          leading: commonProvider.customStatusUrl.isNotEmpty ? CachedNetworkImage(imageUrl: commonProvider.customStatusUrl,width: 24,height: 24,) : Image.asset(
            AppImage.setStatusIcon,
            width: 24,
            height: 24,
            color: Colors.white.withOpacity(0.8),
          ),
          title: commonProvider.customStatusUrl.isNotEmpty ? commonProvider.customStatusTitle : AppString.setACustomStatus,
          trailing: commonProvider.customStatusUrl.isNotEmpty ? GestureDetector(
            onTap: () => commonProvider.updateCustomStatusCall(status: "", emojiUrl: ""),
            child: Container(
                margin: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close,size: 22,color: Colors.red,)),
          ) : SizedBox.shrink()
      ),
    );
  }

  Widget _buildProfileTile() {
    return GestureDetector(
      onTap: () => commonProfilePreview(context),
      child: _buildTile(
        leading: Image.asset(AppImage.person,width: 22,height: 22,color:  Colors.white.withOpacity(0.8),),
        title: AppString.profile,
      ),
    );
  }

  Widget _buildThemeModeTile(ThemeProvider themeProvider) {
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
          onChanged: (value) => themeProvider.toggleTheme(),
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
  }) {return InkWell(
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
    );}

  void _showStatusBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          // color: Color(0xFF1B1E23),
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Consumer<CommonProvider>(builder: (context, commonProvider, child) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bottom sheet indicator
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Status text
              Padding(
                padding: EdgeInsets.only(left: 16, bottom: 16),
                child: commonText(
                  text: AppString.status,
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              // Status options
              _buildStatusOption(
                commonProvider: commonProvider,
                context,
                icon: Icons.check_circle,
                color: Colors.green,
                text: AppString.online,
                index: 0,
              ),
              _buildStatusOption(
                commonProvider: commonProvider,
                context,
                icon: Icons.access_time_filled_outlined,
                color: Colors.orange,
                text: AppString.away,
                index: 1,
              ),
              _buildStatusOption(
                commonProvider: commonProvider,
                context,
                icon: Icons.remove_circle,
                color: Colors.blue,
                text: AppString.busy,
                index: 2,
              ),
              _buildStatusOption(
                commonProvider: commonProvider,
                context,
                icon: Icons.remove_circle,
                color: Colors.red,
                text: AppString.dnd,
                index: 3,
              ),
              _buildStatusOption(
                commonProvider: commonProvider,
                context,
                icon: Icons.circle_outlined,
                color: AppColor.borderColor,
                text: AppString.offline,
                index: 4,
              ),
              const SizedBox(height: 16),
            ],
          );
        },),
      ),
    );
  }
  Widget _buildStatusOption(
      BuildContext context, {
        required CommonProvider commonProvider,
        required IconData icon,
        required Color color,
        required String text,
        required int index,
      }) {
    return InkWell(
      onTap: () {
        pop();
        commonProvider.updateStatusCall(status: index == 0 ? AppString.online.toLowerCase() : index == 1 ? AppString.away.toLowerCase() : index == 2 ? AppString.busy.toLowerCase() : index == 3 ? AppString.dnd.toLowerCase() : AppString.offline.toLowerCase());
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 16),
            commonText(
              text: text,
              color: Colors.black,
              fontSize: 16,
            ),
          ],
        ),
      ),
    );
  }
}