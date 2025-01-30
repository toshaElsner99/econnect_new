import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_connect/main.dart';
import 'package:e_connect/screens/sign_in_screen/sign_in_Screen.dart';
import 'package:e_connect/utils/app_image_assets.dart';
import 'package:e_connect/utils/app_preference_constants.dart';
import 'package:e_connect/utils/common/prefrance_function.dart';
import 'package:e_connect/utils/loading_widget/loading_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oktoast/oktoast.dart';
import '../../cubit/common_cubit/common_cubit.dart';
import '../api_service/api_string_constants.dart';
import '../app_color_constants.dart';
import '../app_fonts_constants.dart';
import '../app_string_constants.dart';
import 'common_function.dart';
import 'enums.dart';

startLoading() {


var commonCubit = CommonCubit();

startLoading(){
  navigatorKey.currentState!.context.read<LoadingCubit>().startLoading();
}

stopLoading() {
  navigatorKey.currentState!.context.read<LoadingCubit>().stopLoading();
}

ToastFuture commonShowToast(String msg, [Color? bgColor]) {
void commonProfilePreview(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => const ProfilePreviewSheet(),
  );
}

class ProfilePreviewSheet extends StatelessWidget {
  const ProfilePreviewSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: const BoxDecoration(
        // color: Color(0xFF1B1E23),
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with close button
          _buildHeader(context),

          // Profile Settings Section
          _buildProfileSettings(),

          // Profile Details Form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Profile Settings'),
                  const SizedBox(height: 24),

                  // Full Name Field
                  _buildProfileField(
                    title: 'Full Name',
                    value: signInModel.data?.user?.fullName ?? '',
                    readOnly: true,
                  ),
                  const SizedBox(height: 24),

                  // Username Field
                  _buildProfileField(
                    title: 'Username',
                    value: signInModel.data?.user?.username ?? '',
                    readOnly: true,
                  ),
                  const SizedBox(height: 24),

                  // Profile Picture Section
                  _buildProfilePictureSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 8, 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColor.borderColor.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          commonText(
            text: 'Profile',
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.close,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSettings() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColor.borderColor.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(
            color: AppColor.borderColor.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.settings,
            size: 24,
          ),
          const SizedBox(width: 16),
          commonText(
            text: 'Profile Settings',
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return commonText(
      text: title,
      fontSize: 28,
      fontWeight: FontWeight.bold,
    );
  }

  Widget _buildProfileField({
    required String title,
    required String value,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        commonText(
          text: title,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColor.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColor.borderColor.withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: commonText(
                  text: value,
                  fontSize: 16,
                ),
              ),
              if (readOnly)
                Icon(
                  Icons.lock_outline,
                  size: 18,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfilePictureSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        commonText(
          text: 'Profile Picture',
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        const SizedBox(height: 16),
        Center(
          child: Column(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColor.borderColor.withOpacity(0.2),
                    width: 2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(60),
                  child: commonImageHolder(radius: 60),
                ),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () {
                  // Handle profile picture update
                },
                icon: Icon(
                  Icons.camera_alt_outlined,
                  color: AppColor.commonAppColor,
                  size: 20,
                ),
                label: commonText(
                  text: 'Change Picture',
                  color: AppColor.commonAppColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

ToastFuture commonShowToast(String msg,[Color? bgColor]) {
  return showToastWidget(
    duration: const Duration(seconds: 5),
    Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: bgColor ?? Colors.white,
          borderRadius: BorderRadius.circular(5)),
      margin: const EdgeInsets.only(bottom: 25, left: 20, right: 20),
      child: commonText(
          text: msg,
          color: bgColor == null ? Colors.black : Colors.white,
          fontSize: 16,
          textAlign: TextAlign.center,
          fontWeight: FontWeight.w600),
    ),
    position: const ToastPosition(align: Alignment.bottomCenter),
  );
}

updateSystemUiChrome() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark));
}

  void showLogoutDialog(BuildContext context,) {
  showGeneralDialog(
  context: context,
  barrierDismissible: false,
  barrierColor: Colors.black.withOpacity(0.5),
  transitionDuration: const Duration(milliseconds: 300),
  pageBuilder: (context, animation, secondaryAnimation) {
  return commonLogoutDialog();
  },
  transitionBuilder: (context, animation, secondaryAnimation, child) {
  return FadeTransition(
  opacity: animation,
  child: child,
  );
  },
  );
  }

Widget commonText({
  required String text,
  Color? color,
  double? fontSize,
  TextAlign? textAlign,
  TextDecoration? decoration,
  TextOverflow? overflow,
  double? height = 1.1,
  int? maxLines,
  double? letterSpacing = 1,
  VoidCallback? onTap,
  FontWeight? fontWeight = FontWeight.w600,
  bool? isHelonikFamily = false,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      textScaler: const TextScaler.linear(1.0),
      style: TextStyle(
        decorationColor: Colors.black,
        decorationThickness: 1.2,
        decorationStyle: TextDecorationStyle.solid,
        overflow: overflow,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
        decoration: decoration,
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontFamily: isHelonikFamily == true
            ? AppFonts.helonikETDFontFamily
            : AppFonts.interFamily,
      ),
    ),
  );
}

Widget commonTextFormField({
  required TextEditingController controller,
  String? labelText,
  required String hintText,
  bool? isInputFormatForEmail,
  TextInputType keyboardType = TextInputType.text,
  bool obscureText = false,
  Widget? prefixIcon,
  Widget? suffixIcon,
  Widget? suffixWidget,
  List<TextInputFormatter>? inputFormatters,
  String? initialValue,
  TextInputAction? textInputAction,
  bool readOnly = false,
  Widget? prefixWidget,
  FocusNode? focusNode,
  String? Function(String?)? validator,
  int? errorMaxLines,
}) {
  return TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    obscureText: obscureText,
    autovalidateMode: AutovalidateMode.onUserInteraction,
    validator: validator,
    readOnly: readOnly,
    focusNode: focusNode,
    textInputAction: textInputAction,
    initialValue: initialValue,
    inputFormatters: inputFormatters,
    //   inputFormatters:  isInputFormatForEmail == true? [
    //   // FilteringTextInputFormatter.allow(RegExp(r'[ a-zA-Z]')),
    //     NoLeadingSpacesFormatter()
    //     // LengthLimitingTextInputFormatter(20),
    //     ] : inputFormatters /*[
    //     FilteringTextInputFormatter.allow(RegExp(r'[ a-zA-Z]')),
    //     NoLeadingSpacesFormatter(),
    //     LengthLimitingTextInputFormatter(15),
    // ]*/,
    style: const TextStyle(
        color: Colors.black, fontWeight: FontWeight.w700, fontSize: 14),
    decoration: InputDecoration(
      labelText: labelText,
      hintText: hintText,
      errorMaxLines: errorMaxLines,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      suffix: suffixWidget,
      prefix: prefixWidget,
      fillColor: Colors.white,
      filled: true,
      border: const OutlineInputBorder(
        borderSide: BorderSide(color: AppColor.lightBlueColor, width: 1),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: AppColor.lightBlueColor, width: 1),
      ),
      errorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: AppColor.lightBlueColor, width: 1),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: AppColor.lightBlueColor, width: 1),
      ),
      disabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: AppColor.lightBlueColor, width: 1),
      ),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: AppColor.lightBlueColor, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      // errorStyle: TextStyle() ,
      labelStyle: const TextStyle(
        // color: ,
        fontFamily: AppFonts.interFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      hintStyle: const TextStyle(
        // color: AppColor.brownColor,
        fontFamily: AppFonts.interFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
    ),
  );
}

Widget commonImageHolder({
  double radius = 25,
  bool isMyProfile = true,
  String? otherUserProfile,
}) {
  String imageUrl = isMyProfile
      ? ApiString.profileBaseUrl + signInModel.data!.user!.avatarUrl!
      : ApiString.profileBaseUrl + (otherUserProfile ?? '');

  return CircleAvatar(
    radius: radius,
    backgroundColor: Colors.grey[200],
    child: ClipOval(
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        progressIndicatorBuilder: (context, url, downloadProgress) => Center(
          child: CircularProgressIndicator(value: downloadProgress.progress),
        ),
        errorWidget: (context, url, error) => Icon(Icons.error),
      ),
    ),
  );
}

Widget commonElevatedButton({
  required VoidCallback onPressed,
  required String buttonText,
  Color? color = Colors.white,
  double? fontSize = 16,
  FontWeight? fontWeight = FontWeight.w400,
  Color? backgroundColor,
  String? fontFamily = AppFonts.interFamily,
  FocusNode? focusNode,
}) {
  return ElevatedButton(
    onPressed: onPressed,
    focusNode: focusNode,
    style: ButtonStyle(
      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
      elevation: WidgetStateProperty.all(0),
      fixedSize: WidgetStateProperty.all(const Size(double.maxFinite, 46)),
      backgroundColor:
          WidgetStateProperty.all(backgroundColor ?? AppColor.commonAppColor),
    ),
    child: Text(
      buttonText,
      textScaler: const TextScaler.linear(1.0),
      style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: fontWeight,
          fontFamily: fontFamily,
          letterSpacing: 1),
    ),
  );
}

// Widget commonNoInternet(){
//   return Stack(
//     fit: StackFit.expand,
//     children: [
//       Column(
//         mainAxisSize: MainAxisSize.min,
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             alignment: Alignment.center,
//             margin: const EdgeInsets.symmetric(horizontal: 90),
//             padding: const EdgeInsets.only(left: 30),
//             child: Image.asset(
//               AppImage.noInternetPng,
//               fit: BoxFit.contain,
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(vertical: 20.0,horizontal: 20),
//             child: Material(
//                 color: Colors.transparent,
//                 child: commonText(text: "Could not connect to internet. Please check your network.",color: Colors.white,fontSize: 17,textAlign: TextAlign.center,fontWeight: FontWeight.w500)),
//           ),
//           Material(
//             color: Colors.transparent,
//             child: GestureDetector(
//                 onTap: () {
//                   commonShowToast("Please check your internet connection",);
//                 },
//                 child: commonText(text: "Try Again",color: AppColor.red,fontWeight: FontWeight.w500,fontSize: 17)),
//           )
//         ],
//       ),
//
//     ],);
// }

Widget commonButtonForHeaderFavoriteInfoCallMute(
    {required IconData icon,
    required String label,
    required VoidCallback onTap,
    required BuildContext context,
    required int totalButtons,
    bool isSelected = false}) {
  double buttonWidth = MediaQuery.of(context).size.width / (totalButtons + 1);
  return InkWell(
    onTap: onTap,
    child: Container(
      width: buttonWidth,
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
          color: isSelected ? AppColor.appBarColor : AppColor.boxBgColor),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? AppColor.blueCommonColor : AppColor.whiteColor,
            size: 20,
          ),
          const SizedBox(height: 4),
          commonText(
            text: label,
            color: isSelected ? AppColor.blueCommonColor : AppColor.borderColor,
            fontSize: 12,
          ),
        ],
      ),
    ),
  );
}

void showChatSettingsBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Container(
        decoration: BoxDecoration(
          color: AppColor.dialogBgColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: AppColor.blackColor.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 5,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Sheet handle indicator
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColor.whiteColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey[800]!,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  commonButtonForHeaderFavoriteInfoCallMute(
                    icon: Icons.star,
                    label: 'Favorited',
                    onTap: () {},
                    context: context,
                    totalButtons: 4
                  ),
                  commonButtonForHeaderFavoriteInfoCallMute(
                    icon: Icons.notifications_off,
                    label: 'Mute',
                    onTap: () {},
                    context: context,
                    totalButtons: 4
                  ),
                  commonButtonForHeaderFavoriteInfoCallMute(
                    icon: Icons.edit,
                    label: 'Set Header',
                    onTap: () {},
                    context: context,
                    totalButtons: 4
                  ),
                  commonButtonForHeaderFavoriteInfoCallMute(
                    icon: Icons.call,
                    label: 'Start Call',
                    onTap: () {},
                    context: context,
                    totalButtons: 4
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey[800]!,
                    width: 1,
                  ),
                ),
              ),
              child: ListTile(
                leading: const Icon(Icons.info_outline, color: Colors.white),
                title: const Text('View info', 
                  style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  // Add your view info logic here
                },
              ),
            ),
            ListTile(
              leading: Icon(Icons.close, color: AppColor.redColor),
              title: Text('Close direct message', 
                style: TextStyle(color: AppColor.redColor)),
              onTap: () {
                Navigator.pop(context);
                // Add your close chat logic here
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    },
  );
}
