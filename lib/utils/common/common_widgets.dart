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



var commonCubit = CommonCubit();

startLoading(){
  navigatorKey.currentState!.context.read<LoadingCubit>().startLoading();
}
stopLoading(){
  navigatorKey.currentState!.context.read<LoadingCubit>().stopLoading();
}

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
          color: bgColor ?? Colors.white, borderRadius: BorderRadius.circular(5)),
      margin: const EdgeInsets.only(bottom: 25,left: 20,right: 20),
      child: commonText(text: msg,color: bgColor == null ? Colors.black : Colors.white,fontSize: 16,textAlign: TextAlign.center,
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

Widget getCommonStatusIcons({String status = "", double size = 25 , bool assetIcon = true}){
  print("getIconStatus>>> $status");
  if(status ==  AppString.online.toLowerCase()) {
    return assetIcon ? Image.asset(AppImage.onlineIcon,height: size,width: size,) : Icon(Icons.check_circle,size: size,color: AppColor.lightOrangeColor,);
  } else if(status == AppString.away.toLowerCase()){
    return assetIcon ? Image.asset(AppImage.awayIcon,height: size,width: size,) : Icon(Icons.access_time_filled_outlined,size: size,color: AppColor.orangeColor,);
  }else if(status == AppString.busy.toLowerCase()){
    return assetIcon ? Image.asset(AppImage.dndIcon,color: Colors.blue,height: size,width: size,) : Icon(Icons.remove_circle,size: size,color: AppColor.blueColor,);
  }else if(status == AppString.dnd.toLowerCase()){
    return assetIcon ? Image.asset(AppImage.dndIcon,height: size,width: size,) : Icon(Icons.do_not_disturb_on,size: size,color: AppColor.redColor,);
  }else {
    return assetIcon ? Image.asset(AppImage.offlineIcon,height: size,width: size,) : Icon(Icons.circle_outlined,color: AppColor.borderColor,size: size,);
  }
}

Widget profileIconWithStatus({
  required String userID,
  required String status,
  bool isMyProfile = true,
  String? otherUserProfile,
}){
  // String imageUrl = isMyProfile
  String imageUrl = signInModel.data?.user?.id == userID
      ? ApiString.profileBaseUrl + signInModel.data!.user!.avatarUrl!
      : ApiString.profileBaseUrl + (otherUserProfile ?? '');
  return Stack(
    alignment: Alignment.bottomRight,
    children: [
      CircleAvatar(
        radius: 15,
        backgroundColor: Colors.grey[200],
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            progressIndicatorBuilder: (context, url, downloadProgress) => Padding(
              padding: const EdgeInsets.all(3),
              child: CircularProgressIndicator(value: downloadProgress.progress),
            ),
            errorWidget: (context, url, error) => Icon(Icons.error),
          ),
        ),
      ),
      Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height:10,
            width: 10,
            decoration: BoxDecoration(
            color: status.contains("offline") ? Colors.transparent : Colors.white,
            shape: BoxShape.circle,
          ),),
          getCommonStatusIcons(status: status,size: 14,assetIcon: false),

        ],
      )
    ],
  );
}



Widget showLogOutDialog() {
  return WillPopScope(
    onWillPop: () async => false,
    child: Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1B1E23),
          // color: AppColor.commonAppColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColor.borderColor.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Warning Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColor.redColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.logout_rounded,
                color: AppColor.redColor,
                size: 32,
              ),
            ),
            const SizedBox(height: 20),

            // Title
            commonText(
              text: AppString.logoutTitle,
              color: Colors.white,
              fontSize: 20,
              textAlign: TextAlign.start,
              height: 1.3,
              fontWeight: FontWeight.w800,
            ),
            const SizedBox(height: 12),

            // Message
            commonText(
              text: AppString.logoutMessage,
              color: Colors.grey,
              fontSize: 16,
              textAlign: TextAlign.center,
              fontWeight: FontWeight.w400,
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => navigatorKey.currentState?.pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: AppColor.borderColor),
                      ),
                    ),
                    child: commonText(
                      text: AppString.cancel,
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Logout Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      commonCubit.logOut();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.commonAppColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: commonText(
                      text: AppString.logout,
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

// void commonLogoutDialog(BuildContext context,) {
//   showDialog(
//     context: context,
//     barrierDismissible: false,
//     builder: (context) => showLogOutDialog(),
//   );
// }
Widget commonLogoutDialog() {
  return WillPopScope(
    onWillPop: () async => false,
    child: Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 300),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: child,
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20,horizontal: 15),
          decoration: BoxDecoration(
            color: AppColor.commonAppColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColor.borderColor.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Warning Icon with animation
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 400),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: child,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.logout_rounded,
                    color: AppColor.redColor,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              commonText(
                text: AppString.logoutTitle,
                color: Colors.white,
                textAlign: TextAlign.center,
                fontSize: 22,
                height: 1.25,
                isHelonikFamily: false,
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 16),

              // // Message
              // commonText(
              //   text: AppString.logoutMessage,
              //   color: AppColor.borderColor,
              //   fontSize: 16,
              //   textAlign: TextAlign.center,
              //   fontWeight: FontWeight.w400,
              //   height: 1.4,
              // ),
              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  // Cancel Button
                  Expanded(
                    child: TextButton(
                      onPressed: () => navigatorKey.currentState?.pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: AppColor.borderColor.withOpacity(0.3)),
                        ),
                      ),
                      child: commonText(
                        text: AppString.cancel,
                        color: AppColor.borderColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Logout Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => commonCubit.logOut(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.redColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: commonText(
                        text: AppString.logout,
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
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
        fontFamily: isHelonikFamily == true ? AppFonts.helonikETDFontFamily : AppFonts.interFamily,
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
      prefixIcon:  prefixIcon,
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
      backgroundColor: WidgetStateProperty.all(backgroundColor ?? AppColor.commonAppColor),
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
