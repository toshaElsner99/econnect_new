import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_connect/main.dart';
import 'package:e_connect/screens/chat/single_chat_message_screen.dart';
import 'package:e_connect/utils/app_image_assets.dart';
import 'package:e_connect/utils/app_preference_constants.dart';
import 'package:e_connect/utils/loading_widget/loading_cubit.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:html/parser.dart';
import 'package:intl/intl.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:keyboard_actions/keyboard_actions_config.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/channel_chat_provider.dart';
import '../../providers/channel_list_provider.dart';
import '../../providers/common_provider.dart';
import '../../providers/file_service_provider.dart';
import '../../screens/chat/media_preview_screen.dart';
import '../api_service/api_string_constants.dart';
import '../app_color_constants.dart';
import '../app_fonts_constants.dart';
import '../app_string_constants.dart';
import 'common_function.dart';
import 'package:e_connect/providers/chat_provider.dart';
import 'package:html/parser.dart' as parser;

class ProfilePreviewSheet extends StatelessWidget {
  const ProfilePreviewSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildProfileSettings(),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileField(
                    title: 'Full Name',
                    value: signInModel!.data?.user?.fullName ?? '',
                    readOnly: true,
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: _buildProfileField(
                      title: 'Username',
                      value: signInModel!.data?.user?.userName ?? '',
                      readOnly: true,
                    ),
                  ),

                  _buildProfilePictureSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildProfileSettings() {
    return Container(
      padding: const EdgeInsets.all(18),
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
            color: AppColor.appBarColor,
            size: 24,
          ),
          const SizedBox(width: 16),
          Cw.commonText(
            text: 'Profile Settings',
            fontSize: 18,
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
          Spacer(),
          IconButton(
            onPressed: () => Cf.instance.pop(),
            icon: Icon(
              color: AppColor.appBarColor,
              Icons.close,
              size: 28,
            ),
          ),
        ],
      ),
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
        Cw.commonText(
          text: title,
          fontSize: 16,
          color: Colors.black,
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
                child: Cw.commonText(
                  text: value,
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
              Icon(
                Icons.lock_outline,
                color: AppColor.commonAppColor,
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
        Cw.commonText(
          text: 'Profile Picture',
          color: Colors.black,
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
                  child: Cw.commonImageHolder(radius: 60),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}


class Cw {
  // Cw._privateConstructor();
  // static final Cw instance = Cw._privateConstructor();

  static final Cw instance = Cw._internal();
  factory Cw() {
    return instance;
  }
  Cw._internal();

  static startLoading() {
    navigatorKey.currentState!.context.read<LoadingProvider>().startLoading();
  }

  static stopLoading() {
    navigatorKey.currentState!.context.read<LoadingProvider>().stopLoading();
  }

  static void commonProfilePreview(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const ProfilePreviewSheet(),
    );
  }


  static Widget previewImageDialog(BuildContext context, String imageUrl) {
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
            children: [
              Center(
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
              Positioned(
                top: 40,
                right: 20,
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static ToastFuture commonShowToast(String msg, [Color? bgColor]) {
    final effectiveBgColor = bgColor ??
        (AppPreferenceConstants.themeModeBoolValueGet ? Colors.white : Colors
            .black);
    return showToastWidget(
      duration: const Duration(seconds: 5),
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: effectiveBgColor,
          borderRadius: BorderRadius.circular(5),
        ),
        margin: const EdgeInsets.only(bottom: 25, left: 20, right: 20),
        child: commonText(
          text: msg,
          color: effectiveBgColor == Colors.white ? Colors.black : Colors.white,
          fontSize: 16,
          textAlign: TextAlign.center,
          fontWeight: FontWeight.w600,
        ),
      ),
      position: const ToastPosition(align: Alignment.bottomCenter),
    );
  }


  static Widget getCommonStatusIcons(
      {required String status, double size = 25, bool assetIcon = true}) {
    if (status == AppString.online.toLowerCase()) {
      return assetIcon ? Image.asset(
        AppImage.onlineIcon, height: size, width: size,) : Icon(
        Icons.check_circle, size: size, color: AppColor.greenColor,);
    } else if (status == AppString.away.toLowerCase()) {
      return assetIcon ? Image.asset(
        AppImage.awayIcon, height: size, width: size,) : Icon(
        Icons.access_time_filled_outlined, size: size,
        color: AppColor.orangeColor,);
    } else if (status == AppString.busy.toLowerCase()) {
      return assetIcon
          ? Image.asset(
        AppImage.dndIcon, color: Colors.blue, height: size, width: size,)
          : Icon(Icons.remove_circle, size: size, color: AppColor.blueColor,);
    }
    //dnd => do_not_disturb
    else if (status == "do_not_disturb") {
      return assetIcon ? Image.asset(
        AppImage.dndIcon, height: size, width: size,) : Icon(
        Icons.do_not_disturb_on, size: size, color: AppColor.redColor,);
    } else {
      return assetIcon ? Image.asset(
        AppImage.offlineIcon, height: size, width: size,) : Icon(
        Icons.circle_outlined, 
        color: AppPreferenceConstants.themeModeBoolValueGet ? Colors.grey[400] : AppColor.borderColor, 
        size: size,);
    }
  }


  static Widget popMenuChannel(BuildContext context, {
    required bool opened,
    required bool isPinned,
    required VoidCallback onOpened,
    required VoidCallback onClosed,
    required VoidCallback onForward,
    required VoidCallback onReply,
    required VoidCallback onPin,
    required VoidCallback onCopy,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
    required String createdAt, // Pass createdAt timestamp
    required String currentUserId, // Current user's ID
    required bool isForwarded,
  }) {
    final RenderBox overlay = Overlay
        .of(context)
        .context
        .findRenderObject() as RenderBox;
    final double screenHeight = MediaQuery
        .of(context)
        .size
        .height;
    final double buttonPositionY = overlay
        .localToGlobal(Offset.zero)
        .dy;
    const double menuHeight = 220;

    final bool openAbove = (buttonPositionY + menuHeight) > screenHeight;
    DateTime createdTime = DateTime.parse(createdAt).toLocal();
    DateTime now = DateTime.now();
    final isEditable = now
        .difference(createdTime)
        .inHours < 24;
    final isCurrentUser = currentUserId ==
        signInModel!.data?.user?.sId; // Check if message belongs to the user

    return Container(
      // color: Colors.red,
      alignment: Alignment.topCenter,
      height: 22,
      width: 20,
      child: PopupMenuButton<int>(
        padding: EdgeInsets.zero,
        // Remove padding
        iconSize: 25,
        // Reduce icon size
        constraints: const BoxConstraints(minWidth: 120),
        // Limit menu width
        color: AppPreferenceConstants.themeModeBoolValueGet ? AppColor
            .darkAppBarColor : AppColor.appBarColor,
        position: openAbove ? PopupMenuPosition.over : PopupMenuPosition.under,
        offset: const Offset(-15, 0),
        onOpened: () => onOpened(),
        onCanceled: () => onClosed(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: AppPreferenceConstants.themeModeBoolValueGet
              ? const BorderSide(color: Colors.white38, width: 0.5)
              : BorderSide.none,
        ),
        onSelected: (value) {
          switch (value) {
            case 0:
              onForward.call();
              break;
            case 1:
              onReply.call();
              break;
            case 2:
              onPin.call();
              break;
            case 3:
              onCopy.call();
              break;
            case 4:
              onEdit.call();
              break;
            case 5:
              onDelete.call();
              break;
          }
        },
        itemBuilder: (context) {
          List<PopupMenuEntry<int>> menuItems = [
            _menuItem(0, Icons.forward, "Forward"),
            _menuItem(1, Icons.reply, "Reply"),
            _menuItem(2, Icons.push_pin,
                isPinned ? "Unpin from Channel" : "Pin to Channel"),
            _menuItem(3, Icons.copy, "Copy Text"),
          ];

          if (isCurrentUser && isEditable) {
            menuItems.add(_menuItem(4, Icons.edit, "Edit"));
          }

          if (isCurrentUser) {
            menuItems.add(const PopupMenuDivider());
            menuItems.add(
                _menuItem(5, Icons.delete, "Delete", color: Colors.red));
          }

          return menuItems;
        },
        icon: Icon(Icons.more_vert,
            color: !opened ? AppColor.borderColor : AppPreferenceConstants
                .themeModeBoolValueGet ? Colors.white : Colors.black),
      ),
    );
  }


  static Widget popMenu2(BuildContext context, {
    required bool opened,
    required bool isPinned,
    required VoidCallback onOpened,
    required VoidCallback onClosed,
    required VoidCallback onForward,
    required VoidCallback onReply,
    required VoidCallback onPin,
    required VoidCallback onCopy,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
    required VoidCallback onReact,
    required String createdAt, // Pass createdAt timestamp
    required String currentUserId, // Current user's ID
    required bool isForwarded,
    bool hasAudioFile = false, // Add new parameter with default value
  }) {
    final RenderBox overlay = Overlay
        .of(context)
        .context
        .findRenderObject() as RenderBox;
    final double screenHeight = MediaQuery
        .of(context)
        .size
        .height;
    final double buttonPositionY = overlay
        .localToGlobal(Offset.zero)
        .dy;
    const double menuHeight = 220;

    final bool openAbove = (buttonPositionY + menuHeight) > screenHeight;
    DateTime createdTime = DateTime.parse(createdAt).toLocal();
    DateTime now = DateTime.now();
    final isEditable = now
        .difference(createdTime)
        .inHours < 24;
    final isCurrentUser = currentUserId == signInModel!.data?.user?.sId;

    return Container(
      alignment: Alignment.topCenter,
      height: 22,
      width: 20,
      child: PopupMenuButton<int>(
        padding: EdgeInsets.zero,
        iconSize: 25,
        constraints: const BoxConstraints(minWidth: 120),
        color: AppPreferenceConstants.themeModeBoolValueGet ? AppColor
            .darkAppBarColor : AppColor.appBarColor,
        position: openAbove ? PopupMenuPosition.over : PopupMenuPosition.under,
        offset: const Offset(-15, 0),
        onOpened: () => onOpened(),
        onCanceled: () => onClosed(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: AppPreferenceConstants.themeModeBoolValueGet
              ? const BorderSide(color: Colors.white38, width: 0.5)
              : BorderSide.none,
        ),
        onSelected: (value) {
          switch (value) {
            case 0:
              onForward.call();
              break;
            case 1:
              onReply.call();
              break;
            case 2:
              onPin.call();
              break;
            case 3:
              onCopy.call();
              break;
            case 4:
              onEdit.call();
              break;
            case 5:
              onDelete.call();
              break;
            case 6:
              onReact.call();
              break;
          }
        },
        itemBuilder: (context) {
          List<PopupMenuEntry<int>> menuItems = [
            _menuItem(6, Icons.emoji_emotions_outlined, "React"),
            _menuItem(1, Icons.reply, "Reply"),
            _menuItem(2, Icons.push_pin,
                isPinned ? "Unpin from Channel" : "Pin to Channel"),
            _menuItem(3, Icons.copy, "Copy Text"),
          ];
          if (isForwarded == true) {
            menuItems.insert(1, _menuItem(0, Icons.forward, "Forward"));
          }
          // Show Edit option only if message is under 24 hours old and not an audio file
          if (isCurrentUser && isEditable && !hasAudioFile) {
            menuItems.add(_menuItem(4, Icons.edit, "Edit"));
          }

          // Show Delete option only if the message belongs to the current user
          if (isCurrentUser) {
            menuItems.add(const PopupMenuDivider());
            menuItems.add(
                _menuItem(5, Icons.delete, "Delete", color: Colors.red));
          }

          return menuItems;
        },
        icon: Icon(Icons.more_vert,
            color: !opened ? AppColor.borderColor : AppPreferenceConstants
                .themeModeBoolValueGet ? Colors.white : Colors.black),
      ),
    );
  }

  static Widget popMenuForReply2(BuildContext context, {
    required bool opened,
    required bool isPinned,
    required VoidCallback onOpened,
    required VoidCallback onClosed,
    required VoidCallback onForward,
    required VoidCallback onPin,
    required VoidCallback onCopy,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
    required VoidCallback onReact,
    required String createdAt,
    required String currentUserId,
    required bool hasAudioFile,
  }) {
    final RenderBox overlay = Overlay
        .of(context)
        .context
        .findRenderObject() as RenderBox;
    final double screenHeight = MediaQuery
        .of(context)
        .size
        .height;
    final double buttonPositionY = overlay
        .localToGlobal(Offset.zero)
        .dy;
    const double menuHeight = 220;

    final bool openAbove = (buttonPositionY + menuHeight) > screenHeight;

    DateTime createdTime = DateTime.parse(createdAt).toLocal();
    DateTime now = DateTime.now();
    final isEditable = now
        .difference(createdTime)
        .inHours < 24;
    final isCurrentUser = currentUserId == signInModel!.data?.user?.sId;

    return Container(
      alignment: Alignment.topCenter,
      height: 22,
      width: 20,
      child: PopupMenuButton<int>(
        padding: EdgeInsets.zero,
        iconSize: 25,
        constraints: const BoxConstraints(minWidth: 120),
        color: AppPreferenceConstants.themeModeBoolValueGet ? AppColor
            .darkAppBarColor : AppColor.appBarColor,
        position: openAbove ? PopupMenuPosition.over : PopupMenuPosition.under,
        offset: const Offset(-15, 0),
        onOpened: () => onOpened(),
        onCanceled: () => onClosed(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: AppPreferenceConstants.themeModeBoolValueGet
              ? const BorderSide(color: Colors.white38, width: 0.5)
              : BorderSide.none,
        ),
        onSelected: (value) {
          switch (value) {
            case 0:
              onForward.call();
              break;
            case 1:
              onPin.call();
              break;
            case 2:
              onCopy.call();
              break;
            case 3:
              onEdit.call();
              break;
            case 4:
              onDelete.call();
              break;
            case 5:
              onReact.call();
              break;
          }
        },
        itemBuilder: (context) {
          List<PopupMenuEntry<int>> menuItems = [
            _menuItem(5, Icons.emoji_emotions_outlined, "React"),
            _menuItem(0, Icons.forward, "Forward"),
            _menuItem(1, Icons.push_pin,
                isPinned ? "Unpin from Channel" : "Pin to Channel"),
          ];

          menuItems.add(const PopupMenuDivider());
          menuItems.add(_menuItem(2, Icons.copy, "Copy Text"));
          if (isCurrentUser && isEditable && !hasAudioFile) {
            menuItems.add(_menuItem(3, Icons.edit, "Edit"));
          }
          if (isCurrentUser) {
            menuItems.add(_menuItem(4, Icons.delete, "Delete"));
          }

          return menuItems;
        },
        icon: Icon(Icons.more_vert,
            color: !opened ? AppColor.borderColor : AppPreferenceConstants
                .themeModeBoolValueGet ? Colors.white : Colors.black),
      ),
    );
  }

  static PopupMenuItem<int> _menuItem(int value, IconData icon, String text,
      {Color? color}) {
    final iconColor = color ?? (AppPreferenceConstants.themeModeBoolValueGet ? Colors.white : Colors.white);
    final textColor = color ?? (AppPreferenceConstants.themeModeBoolValueGet ? Colors.white : Colors.white);
    
    return PopupMenuItem<int>(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 18),
          const SizedBox(width: 10),
          FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(text, style: TextStyle(color: textColor))),
        ],
      ),
    );
  }


  Widget commonPopUpForMsg(
      {double size = 20, Function? delete, Function? pinMessage }) {
    final color = AppPreferenceConstants.themeModeBoolValueGet ? Colors.white : AppColor.borderColor;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppPreferenceConstants.themeModeBoolValueGet ? Colors.grey[700]! : Colors.grey),
        color: AppPreferenceConstants.themeModeBoolValueGet ? AppColor.darkAppBarColor : CupertinoColors.darkBackgroundGray,
      ),
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Transform.flip(flipX: true,
              child: Image.asset(AppImage.forwardIcon, height: size,
                width: size,
                color: color,)),
          SizedBox(width: 12),
          Image.asset(
              AppImage.forwardIcon, height: size, width: size, color: color),
          SizedBox(width: 12),
          GestureDetector(
              onTap: () => pinMessage?.call(),
              child: Image.asset(AppImage.pinTiltIcon, height: size,
                  width: size,
                  color: color)),
          SizedBox(width: 12),
          Image.asset(
              AppImage.copyIcon, height: size, width: size, color: color),
          SizedBox(width: 12),
          Image.asset(
              AppImage.editIcon, height: size, width: size, color: color),
          SizedBox(width: 12),
          GestureDetector(
              onTap: () => delete?.call(),
              child: Image.asset(AppImage.deleteIcon, height: size,
                  width: size,
                  color: color)),

        ],
      ),
    );
  }


  static Widget profileIconWithStatus({
    required String userID,
    required String status,
    required String userName,
    String? otherUserProfile,
    double radius = 15.0,
    double iconSize = 14.0,
    double containerSize = 10.0,
    bool needToShowIcon = true,
    bool isMuted = false,
    Color borderColor = AppColor.blueColor,
    void Function()? onTap
  }) {
    String imageUrl = signInModel!.data?.user?.sId == userID
        ? ApiString.profileBaseUrl +
        (signInModel!.data!.user!.thumbnailAvatarUrl ?? '')
        : ApiString.profileBaseUrl + (otherUserProfile ?? '');

    return GestureDetector(
      onTap: onTap ?? () {
        if (userID == signInModel!.data?.user?.sId) {
          showUserProfilePopup(
              navigatorKey.currentState!.context,
              userId: userID,
              username: signInModel!.data!.user!.userName ?? '',
              fullName: signInModel!.data!.user!.fullName ?? '',
              email: signInModel!.data!.user!.email ?? '',
              avatarUrl: signInModel!.data!.user!.avatarUrl ?? '',
              status: status
          );
        } else {
          final commonProvider = Provider.of<CommonProvider>(
              navigatorKey.currentState!.context, listen: false);
          commonProvider.getUserByIDCallForSecondUser(userId: userID).then((
              userModel) {
            if (userModel != null && userModel.data != null &&
                userModel.data!.user != null) {
              showUserProfilePopup(
                  navigatorKey.currentState!.context,
                  userId: userID,
                  username: userModel.data!.user!.username ?? '',
                  fullName: userModel.data!.user!.fullName ?? '',
                  email: userModel.data!.user!.email ?? '',
                  avatarUrl: userModel.data!.user!.avatarUrl ?? '',
                  status: userModel.data!.user!.status ?? 'offline'
              );
            }
          });
        }
      },
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: borderColor,
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: radius,
              backgroundColor: AppPreferenceConstants.themeModeBoolValueGet ? Colors.grey[800] : Colors.grey[200],
              child: ClipOval(
                child: CachedNetworkImage(
                  color: isMuted ? Colors.black26 : null,
                  colorBlendMode: isMuted ? BlendMode.srcOver : null,
                  imageUrl: imageUrl,
                  width: radius * 2,
                  height: radius * 2,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                  errorWidget: (context, url, error) {
                    String name = signInModel!.data?.user?.sId == userID
                        ? signInModel!.data?.user?.userName ?? ''
                        : userName; // Ensure 'userName' is defined if it's for another user
                    String firstLetter = name.isNotEmpty
                        ? name[0].toUpperCase()
                        : '?'; // First letter or 'U' if empty
                    return Center(child: commonText(
                        text: firstLetter,
                        color: AppPreferenceConstants.themeModeBoolValueGet ? Colors.white : Colors.black,
                    )); // Display the first letter of the username
                  },
                ),
              ),
            ),
          ),
          if (needToShowIcon)
            Stack(
              alignment: Alignment.center,
              children: [

                /// background ///
                Container(
                  height: containerSize,
                  width: containerSize,
                  decoration: BoxDecoration(
                    color: status.contains("offline")
                        ? Colors.transparent
                        : Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),

                /// status Icon ///
                getCommonStatusIcons(
                    status: status, size: iconSize, assetIcon: false),

                /// mute overlay //
                Visibility(
                  visible: isMuted,
                  child: Container(
                    height: containerSize,
                    width: containerSize,
                    decoration: BoxDecoration(
                      color: AppColor.borderColor.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
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
                        Provider.of<CommonProvider>(navigatorKey.currentState!
                            .context, listen: false).logOut();
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

  Future commonForwardMSGDialog({required BuildContext context,
    required String msgToForward,
    required String userID,
    required String otherUserProfile,
    required String userName,
    required String time,

  }) {
    final TextEditingController searchController = TextEditingController();
    return showDialog(
      context: context, builder: (context) {
      return Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 10),
        child: StatefulBuilder(
          builder: (context, setState) {
            return Container(
              // padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                // borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: AppColor.borderColor.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    color: AppPreferenceConstants.themeModeBoolValueGet
                        ? CupertinoColors.darkBackgroundGray
                        : AppColor.appBarColor,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        commonText(
                            text: "Forward Message", color: Colors.white),
                        IconButton(onPressed: () => Cf.instance.pop(),
                            icon: Icon(Icons.close, color: Colors.white,))
                      ],
                    ),
                  ),
                  Container(
                    color: Colors.blue.withOpacity(0.1),
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Icon(Icons.info, color: Colors.white,),
                        SizedBox(width: 5,),
                        Flexible(child: commonText(
                            text: "This message is from a private conversation",
                            color: Colors.white)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: commonTextFormField(controller: searchController,
                        hintText: "Search for people"),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 30.0, horizontal: 20),
                    child: commonTextFormField(
                        controller: TextEditingController(),
                        hintText: "Add a comment (optional)"),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: commonText(text: "Message preview",
                        color: AppPreferenceConstants.themeModeBoolValueGet
                            ? Colors.white
                            : Colors.white),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(color: AppColor.borderColor)
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            profileIconWithStatus(userID: userID,
                                status: "",
                                otherUserProfile: otherUserProfile,
                                needToShowIcon: false,
                                userName: userName),
                            commonText(text: userName),
                            commonText(text: time),
                          ],
                        ),
                        commonHTMLText(message: msgToForward),
                      ],
                    ),
                  )


                ],
              ),
            );
          },
        ),
      );
    },);
  }

  static Row newMessageDivider() {
    return Row(children: [
      Expanded(child: Divider(color: Colors.orange,)),
      Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.orange,
          borderRadius: BorderRadius.circular(12),
        ),
        child: commonText(
          text: "New Messages",
          fontSize: 12,
          color: Colors.white,
        ),
      ),
      Expanded(child: Divider(color: Colors.orange,)),
    ],);
  }

  static Widget commonBackButton() {
    return IconButton(
        icon: const Icon(CupertinoIcons.back, color: Colors.white,),
        color: Colors.white,
        onPressed: () => Cf.instance.pop());
  }

  static Widget commonLogoutDialog() {
    return PopScope(
      canPop: false,
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
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
            decoration: BoxDecoration(
              color: AppPreferenceConstants.themeModeBoolValueGet
                  ? CupertinoColors.darkBackgroundGray
                  : AppColor.appBarColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColor.borderColor.withOpacity(
                  AppPreferenceConstants.themeModeBoolValueGet ? 0.9 : 0.2)),
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
                            side: BorderSide(
                                color: AppColor.borderColor.withOpacity(0.3)),
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
                        onPressed: () =>
                            navigatorKey.currentState!.context.read<
                                CommonProvider>().logOut(),
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

  static void showLogoutDialog(BuildContext context,) {
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

  static Widget commonText({
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
    FontStyle? fontStyle
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
          fontStyle: fontStyle,
          fontWeight: fontWeight,
          fontFamily: isHelonikFamily == true
              ? AppFonts.helonikETDFontFamily
              : AppFonts.interFamily,
        ),
      ),
    );
  }

  String htmlToPlainText(String htmlString) {

    final document = parse(htmlString);
    return document.body?.text ?? '';
  }

  static Widget commonHTMLText(
      {required String message, String userId = "", bool isLog = false, String userName = "", color}) {
    final commonProvider = Provider.of<CommonProvider>(
        navigatorKey.currentState!.context, listen: false);
    final currentUserId = signInModel!.data?.user?.sId ?? "";

    // First process @mentions
    String processedMessage = message.replaceAllMapped(
      RegExp(r'@(\w+)'),
          (match) {
        return '<span class="username">@${match.group(1)}</span>';
      },
    );
    print("processedMessage = $processedMessage");
    // Then process usernames/fullnames without @ symbol
    if (commonProvider.getUserMentionModel?.data?.users != null) {
      for (var user in commonProvider.getUserMentionModel!.data!.users!) {
        if (user.username != null) {
          if (processedMessage.startsWith("<")) {
            processedMessage = processedMessage.replaceAllMapped(
              RegExp(r'\b' + RegExp.escape(user.username!) + r'\b',
                  caseSensitive: false),
                  (match) {
                if (match.input.substring(match.start - 20, match.start)
                    .contains('class="username"')) {
                  return match.group(0)!;
                }
                return '<span class="username">${match.group(0)}</span>';
              },
            );
          }
          if (user.fullName != null) {
            if (processedMessage.startsWith("<")) {
              processedMessage = processedMessage.replaceAllMapped(
                RegExp(r'\b' + RegExp.escape(user.fullName!) + r'\b',
                    caseSensitive: false),
                    (match) {
                  if (match.input.substring(match.start - 20, match.start)
                      .contains('class="username"')) {
                    return match.group(0)!;
                  }
                  return '<span class="username">${match.group(0)}</span>';
                },
              );
            }
          }
        }
      }
      print("processedMessage = $processedMessage");
    }

    // Replace "added to the channel by" with a dynamic value
    if (processedMessage.contains("added to the channel by")) {
      final isCurrentUser = userId == currentUserId;
      String replacement = isCurrentUser
          ? "added to the channel by you"
          : 'added to the channel by <span class="username" id="$userId">@${userName
          .isNotEmpty ? userName : "someone"}</span>';

      processedMessage =
          processedMessage.replaceAll("added to the channel by", replacement);
    }
    processedMessage = processedMessage.replaceAll("\n", "<br>");

    return HtmlWidget(
      processedMessage,
      textStyle: TextStyle(
        height: 1.2,
        fontFamily: AppFonts.interFamily,
        color: color ?? (AppPreferenceConstants.themeModeBoolValueGet
            ? Colors.white
            : Colors.black),
        fontSize: 16,
      ),
      customStylesBuilder: (element) {
        Map<String, String> styles = {
          'color': AppPreferenceConstants.themeModeBoolValueGet
              ? '#FFFFFF'
              : '#000000',
        };

        if (element.classes.contains('renderer_bold')) {
          styles['font-weight'] = 'bold';
        }
        if (element.classes.contains('renderer_italic')) {
          styles['font-style'] = 'italic';
        }
        if (element.classes.contains('renderer_strikethrough')) {
          styles['text-decoration'] = 'line-through';
        }
        if (element.classes.contains('renderer_link')) {
          styles['color'] = '#2196F3';
        }
        if (element.classes.contains('renderer_emoji')) {
          styles['display'] = 'inline-block';
          styles['vertical-align'] = 'middle';
        }
        if (element.classes.contains('username')) {
          String username = element.text;
          if (username.startsWith('@')) {
            username = username.substring(1);
          }

          final commonProvider = Provider.of<CommonProvider>(
              navigatorKey.currentState!.context, listen: false);
          if (commonProvider.getUserMentionModel == null) {
            commonProvider.getUserApi(id: signInModel!.data!.user!.sId!);
            return {};
          }

          bool isValidUser = commonProvider.isUserInAllUsers(username);
          if (isValidUser) {
            styles['background-color'] = '#007770';
            styles['color'] = '#FFFFFF';
            styles['border-radius'] = '10px';
            styles['padding'] = '4px 8px';
            styles['margin'] = '2px';
            styles['display'] = 'inline-block';
          }
        }
        return styles;
      },
      customWidgetBuilder: (element) {
        if (element.localName == 'a' ||
            element.localName.toString().startsWith("https") ||
            element.localName.toString().startsWith("http")) {
          // final String? url = element.attributes['href'];
          final String? url = element.text.trim();
          if (url != null) {
            return GestureDetector(
              onTap: () => _openUrl(url),
              child: Text(
                url,
                style: TextStyle(color: Colors.blue,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.blue),
              ),
            );
          }
        }
        if (element.classes.contains('renderer_emoji')) {
          final imageUrl = element.attributes['style']
              ?.split('url(\'')
              .last
              .split('\')')
              .first;
          if (imageUrl != null) {
            return CachedNetworkImage(
              imageUrl: imageUrl,
              width: 21,
              height: 21,
              fit: BoxFit.contain,
            );
          }
        }
        return null;
      },
      enableCaching: true,
    );
  }

  static Widget HtmlTextOnly({required String htmltext}){

    log("Images1 ");
    String a = '''$htmltext''';
    final Map<String, String> imageMap = {};

    // Split by <img to isolate each image tag
    final parts = a.toString().split('<img');

    for (var part in parts) {
      if (part.contains('class=') && part.contains('src=')) {
        // Extract class name
        final classPart = part.split('class=')[1].split(RegExp(r'[ >]'))[0];
        final className = classPart.replaceAll('"', '').replaceAll("'", "");

        // Extract src
        final srcPart = part.split('src=')[1].split(RegExp(r'[ >]'))[0];
        final src = srcPart.replaceAll('"', '').replaceAll("'", "");

        imageMap[className] = src;
      }
    }
    log("Images2 $imageMap");

    final document = parse(a);
    final text = document.body?.text ?? '';
    // Step 1: Split by line breaks
    final lines = text.split('\n');

    // Step 2: Clean each line and remove empty ones
    final cleanLines = lines
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();



    // If you need it as a List<String>
    print('\nAs a List<String>:');
    log("cleanLines $cleanLines");


    List<TextSpan> spans = [];
    bool needMore = true;
    for (int i = 2; i < cleanLines.length; i++) {
      String msg = cleanLines[i];

      // Convert to lowercase for matching without affecting original case
      String lowerMsg = msg.toLowerCase();
      int wishingIndex = lowerMsg.indexOf("wishing");
      int aIndex = lowerMsg.indexOf(" a");

      if (wishingIndex != -1 && aIndex > wishingIndex && needMore) {
        // Separate the parts
        String before = msg.substring(0, wishingIndex + 7); // includes "wishing"
        String bold = msg.substring(wishingIndex + 7, aIndex); // in between
        String after = msg.substring(aIndex); // from " a" to end

        spans.addAll([
          TextSpan(text: before),
          TextSpan(
            text: bold,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: after + " "), // Add space after each sentence
        ]);
        needMore = false; // Stop after the first match
      } else {
        // If "wishing" or " a" is not found, just add plain text
        spans.add(TextSpan(text: msg + " "));
      }
    }

    return Container(
     width: double.infinity,
     decoration: BoxDecoration(
       color: Color(0xFF005282),
       borderRadius: BorderRadius.circular(20),
     ),
     child: Column(
       children: [
         Padding(
           padding: const EdgeInsets.only(top: 16.0,bottom: 18),
           child: ClipRRect(  borderRadius: BorderRadius.circular(75), // half of width
                  child: CachedNetworkImage(imageUrl: imageMap['emp_img']!,width: 100,)),
         ),
         Text(cleanLines[0],style: TextStyle(color:Color(0xFFFFFFFF),fontSize: 30,fontWeight: FontWeight.bold),),
         Padding(
           padding: const EdgeInsets.only(top: 15.0,bottom: 25),
           child: Image.network(imageMap['bdy_img']!.trim()),
         ),
         Text(cleanLines[1],style: TextStyle(color:Color(0xFFFFFFFF),fontSize: 18,fontWeight: FontWeight.w600),),
         Padding(
           padding: const EdgeInsets.only(top: 24.0,right: 20,left: 20,bottom: 24),
           // child: MarkdownBody(data: "We have the pleasure of wishing **Mr. Kartik Trivedi** a very happy birthday. May your day be filled with joy, laughter, and all the happiness you deserve. Wishing you a fantastic birthday!",style: TextStyle(color:Color(0xFFFFFFFF),fontSize: 14),textAlign: TextAlign.center,),
           child: Text.rich(
              TextSpan(
               style: TextStyle(color: Colors.white, fontSize: 14),
               children: spans,
             ),
             textAlign: TextAlign.center,
           ),
         ),

       ],
     ) ,
   );
    // return HtmlWidget(htmltext,
    //   customWidgetBuilder: (element){
    //
    //   return Container(
    //     width: double.infinity,
    //     decoration: BoxDecoration(
    //       color: Color(0xFF005282),
    //       borderRadius: BorderRadius.circular(20),
    //     ),
    //     child: Column(
    //         children: [
    //           SizedBox(width: 140,child: CachedNetworkImage(imageUrl: imageMap['emp_img']!))
    //         ],
    //     ),
    //   );
    //
    //   },
    //   enableCaching: true,
    // );
  }
  /// ✅ Function to Open URL in Browser

  static void _openUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }


  static Widget commonChannelIcon(
      {required bool isPrivate, bool? isShowPersons = false, Color? color, bool isMuted = false}) {
    return Container(
      width: 35,
      height: 35,
      decoration: BoxDecoration(
          color: AppColor.borderColor.withOpacity(0.1),
          // borderRadius: BorderRadius.circular(6),
          shape: BoxShape.circle
      ),
      child: Center(
        child: Image.asset(
          isPrivate == true ? AppImage.lockIcon : isShowPersons == true
              ? AppImage.persons
              : AppImage.globalIcon,
          width: 16,
          height: 16,
          color: isMuted ? AppColor.borderColor : color ?? Colors.white,
        ),
      ),
    );
  }

  Widget commonPopUpMenuForUser(
      {required int index, required bool muteConversation, Function? removeFromFavorite}) {
    return SizedBox(
      height: 20,
      width: 20,
      child: PopupMenuButton<String>(
        padding: EdgeInsets.zero,
        constraints: BoxConstraints(minWidth: 150),
        icon: Icon(Icons.more_vert, size: 24),
        onSelected: (value) {
          if (index == 0 && value == "favorite") {
            removeFromFavorite?.call();
          }
        },
        itemBuilder: (BuildContext context) =>
        [
          PopupMenuItem(
            height: 35,
            value: "unread",
            child: Row(
              children: [
                Icon(Icons.mark_chat_unread_outlined, size: 20),
                SizedBox(width: 10),
                commonText(text: "Mark as unread"),
              ],
            ),
          ),
          PopupMenuItem(
            height: 35,
            value: "favorite",
            child: Row(
              children: [
                Icon(index == 0 ? Icons.star : Icons
                    .star_border_purple500_outlined, size: 20),
                SizedBox(width: 10),
                commonText(text: index == 0 ? "Unfavorite" : "Favorite"),
              ],
            ),
          ),
          PopupMenuItem(
            height: 35,
            value: "mute",
            child: Row(
              children: [
                Icon(muteConversation == true
                    ? Icons.notifications_off_outlined
                    : Icons.notifications_none, size: 20),
                SizedBox(width: 10),
                commonText(text: "Mute Conversation"),
              ],
            ),
          ),
          PopupMenuItem(
            height: 35,
            value: "leave",
            child: Row(
              children: [
                Icon(Icons.exit_to_app, size: 20, color: Colors.red),
                SizedBox(width: 10),
                Text(
                  "Close Conversation",
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget commonPopUpMenuForChannel() {
    return SizedBox(
      height: 20,
      width: 20,
      child: PopupMenuButton<String>(
        padding: EdgeInsets.zero,
        constraints: BoxConstraints(minWidth: 150),
        icon: Icon(Icons.more_vert, size: 24),
        onSelected: (value) {
          if (value == "unread") {

          } else if (value == "favorite") {

          } else if (value == "mute") {

          } else {

          }
        },
        itemBuilder: (BuildContext context) =>
        [
          PopupMenuItem(
            height: 35,
            value: "unread",
            child: Row(
              children: [
                Icon(Icons.mark_chat_unread, size: 20),
                SizedBox(width: 10),
                Text("Mark as unread"),
              ],
            ),
          ),
          PopupMenuItem(
            height: 35,
            value: "favorite",
            child: Row(
              children: [
                Icon(Icons.star_border, size: 20),
                SizedBox(width: 10),
                Text("Favorite"),
              ],
            ),
          ),
          PopupMenuItem(
            height: 35,
            value: "mute",
            child: Row(
              children: [
                Icon(Icons.notifications_off, size: 20),
                SizedBox(width: 10),
                Text("Mute Channel"),
              ],
            ),
          ),
          PopupMenuItem(
            height: 35,
            value: "leave",
            child: Row(
              children: [
                Icon(Icons.exit_to_app, size: 20, color: Colors.red),
                SizedBox(width: 10),
                Text(
                  "Leave Channel",
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static KeyboardActionsConfig keyboardConfigIos(FocusNode focusNode) {
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.IOS,
      keyboardBarColor: AppPreferenceConstants.themeModeBoolValueGet
          ? CupertinoColors.darkBackgroundGray
          : null,
      defaultDoneWidget: Padding(
        padding: const EdgeInsets.only(right: 16.0),
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => focusNode.unfocus(),
          child: Text(
            "Done",
            style: TextStyle(
              color: AppPreferenceConstants.themeModeBoolValueGet
                  ? Colors.grey
                  : Colors.black, // Custom color works now!
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      actions: [
        KeyboardActionsItem(
          focusNode: focusNode,
          displayArrows: false,
        ),
      ],
    );
  }


  static Widget commonTextFormField({
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
    String? Function(String?)? fieldSubmitted,
    int? errorMaxLines,
    void Function()? onTap,
    Color? fillColor = Colors.white,
    bool? filled = false,
    TextStyle? textStyle,
  }) {
    return TextFormField(
      controller: controller,
      onTap: () => onTap?.call(),
      keyboardType: keyboardType,
      obscureText: obscureText,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: validator,
      onFieldSubmitted: fieldSubmitted,
      readOnly: readOnly,
      focusNode: focusNode,
      textInputAction: textInputAction,
      initialValue: initialValue,
      inputFormatters: inputFormatters,
      style: textStyle,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        errorMaxLines: errorMaxLines,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        suffix: suffixWidget,
        prefix: prefixWidget,
        fillColor: fillColor,
        filled: filled,
        // border: const OutlineInputBorder(
        //   borderSide: BorderSide(color: AppColor.lightBlueColor, width: 1),
        // ),
        // focusedBorder: const OutlineInputBorder(
        //   borderSide: BorderSide(color: AppColor.lightBlueColor, width: 1),
        // ),
        // errorBorder: const OutlineInputBorder(
        //   borderSide: BorderSide(color: AppColor.lightBlueColor, width: 1),
        // ),
        // focusedErrorBorder: const OutlineInputBorder(
        //   borderSide: BorderSide(color: AppColor.lightBlueColor, width: 1),
        // ),
        // disabledBorder: const OutlineInputBorder(
        //   borderSide: BorderSide(color: AppColor.lightBlueColor, width: 1),
        // ),
        // enabledBorder: const OutlineInputBorder(
        //   borderSide: BorderSide(color: AppColor.lightBlueColor, width: 1),
        // ),
        contentPadding: const EdgeInsets.symmetric(
            vertical: 14, horizontal: 16),
        labelStyle: const TextStyle(
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

  static Widget commonImageHolder({
    double radius = 25,
    bool isMyProfile = true,
    String? otherUserProfile,
  }) {
    String? avatarUrl = isMyProfile
        ? signInModel!.data?.user?.avatarUrl
        : otherUserProfile;

    String imageUrl = (avatarUrl != null && avatarUrl.isNotEmpty)
        ? ApiString.profileBaseUrl + avatarUrl
        : '';

    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey[200],
      child: ClipOval(
        child: imageUrl.isNotEmpty
            ? CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          progressIndicatorBuilder: (context, url, downloadProgress) =>
              Center(
                child: CircularProgressIndicator(
                    value: downloadProgress.progress),
              ),
          errorWidget: (context, url, error) =>
              Image.asset(AppImage.person, fit: BoxFit.cover),
        )
            : Image.asset(AppImage.person, fit: BoxFit.cover),
      ),
    );
  }


  static Widget commonElevatedButton({
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
        fixedSize: WidgetStateProperty.all(const Size(double.maxFinite, 40)),
        backgroundColor: WidgetStateProperty.all(
            backgroundColor ?? AppColor.commonAppColor),
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


  static Widget commonButtonForHeaderFavoriteInfoCallMute({required String icon,
    required bool needAssetIcon,
    IconData? iconData,
    required String label,
    required VoidCallback onTap,
    required BuildContext context,
    required int totalButtons,
    bool isSelected = false}) {
    double buttonWidth = MediaQuery
        .of(context)
        .size
        .width / (totalButtons + 1);
    return InkWell(
      onTap: onTap,
      child: Container(
        width: buttonWidth,
        height: 60,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          // color: isSelected ? AppColor.redColor : AppColor.boxBgColor
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if(needAssetIcon)...{
              Image.asset(
                icon,
                color: isSelected ? AppColor.blueCommonColor : AppColor
                    .whiteColor,
                height: 20, width: 20,
              ),
            } else
              ...{
                Icon(iconData, size: 20,
                    color: isSelected ? AppColor.blueCommonColor : AppColor
                        .whiteColor)
              },
            const SizedBox(height: 4),
            commonText(
              text: label,
              color: isSelected ? AppColor.blueCommonColor : AppColor
                  .borderColor,
              fontSize: 12,
            ),
          ],
        ),
      ),
    );
  }

  static Widget customLoading() {
    return Center(
      child: SpinKitCircle(
        color: AppPreferenceConstants.themeModeBoolValueGet
            ? Colors.white
            : AppColor.appBarColor,
        size: 50.0,
      ),
    );
  }

  static void showChatSettingsBottomSheet({required String userId}) {
    showModalBottomSheet(
      context: navigatorKey.currentState!.context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Consumer2<ChannelListProvider, CommonProvider>(
          builder: (context, channelListProvider, commonProvider, child) {
            final isMutedUser = commonProvider.getUserModel?.data?.user
                ?.muteUsers?.contains(userId) ?? false;
            final isFavoriteUser = commonProvider.getUserModelSecondUser?.data
                ?.user?.isFavourite ?? false;
            return Container(
              decoration: BoxDecoration(
                color: AppPreferenceConstants.themeModeBoolValueGet ? AppColor
                    .dialogBgColor : AppColor.appBarColor,
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20)),
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
                            icon: '',
                            iconData: isFavoriteUser
                                ? Icons.star
                                : CupertinoIcons.star,
                            needAssetIcon: false,
                            label: isFavoriteUser ? 'Favorited' : "Favorite",
                            onTap: () {
                              if (isFavoriteUser) {
                                channelListProvider.removeFromFavorite(
                                    favouriteUserId: userId,
                                    needToUpdateGetUserModel: true);
                              } else {
                                channelListProvider.addUserToFavorite(
                                    favouriteUserId: userId,
                                    needToUpdateGetUserModel: true);
                              }
                            },
                            context: context,
                            totalButtons: 4
                        ),
                        commonButtonForHeaderFavoriteInfoCallMute(
                            needAssetIcon: true,
                            icon: isMutedUser
                                ? AppImage.muteNotification
                                : AppImage.unMuteNotification,
                            label: isMutedUser ? 'Muted' : 'Mute',
                            onTap: () => Provider.of<ChannelListProvider>(
                                context, listen: false).muteUser(
                                userIdToMute: userId,
                                isForMute: isMutedUser ? true : false),
                            context: context,
                            totalButtons: 4
                        ),

                      ],
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.close, color: AppColor.redColor),
                    title: Text('Close direct message',
                        style: TextStyle(color: AppColor.redColor)),
                    onTap: () {
                      Cf.instance.pop();
                      Cf.instance.pop();
                      channelListProvider.closeConversation(
                          conversationUserId: userId,
                          isCalledForFav: isFavoriteUser);
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },);
      },
    );
  }


  static Future<dynamic> deleteMessageDialog(BuildContext context,
      Function deleteMsgFun) {
    return showDialog(context: context, builder: (context) {
      return Consumer2<ChannelListProvider, CommonProvider>(
        builder: (context, channelListProvider, commonProvider, child) {
          return AlertDialog(
            contentPadding: EdgeInsets.zero,
            insetPadding: EdgeInsets.zero,
            content: Container(
              color: AppPreferenceConstants.themeModeBoolValueGet
                  ? Colors.black
                  : Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    color: AppPreferenceConstants.themeModeBoolValueGet
                        ? CupertinoColors.darkBackgroundGray
                        : AppColor.commonAppColor,
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        commonText(text: "Confirm Message Delete",
                            color: Colors.white),
                        GestureDetector(
                            onTap: () => Cf.instance.pop(),
                            child: Icon(Icons.close, color: Colors.white,)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20.0, horizontal: 20),
                    child: commonText(
                        text: "Are you sure you want to delete this Message?"),
                  ),
                  Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () => Cf.instance.pop(),
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.grey.withOpacity(0.1)
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            child: commonText(text: "Cancel"),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Cf.instance.pop();
                            deleteMsgFun.call();
                          },
                          child: Container(
                            margin: EdgeInsets.only(left: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: AppColor.redColor,
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            child: commonText(
                                text: "Delete", color: Colors.white),
                          ),
                        ),
                      ],),
                  )
                ],
              ),
            ),
          );
        },);
    },);
  }


  static Widget selectedFilesWidget({required String screenName}) {
    return Consumer<FileServiceProvider>(
      builder: (context, provider, _) {
        List<PlatformFile> selectedFiles = provider.getFilesForScreen(
            screenName);

        return Visibility(
          visible: selectedFiles.isNotEmpty,
          child: SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: selectedFiles.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                MediaPreviewScreen(
                                  files: selectedFiles,
                                  initialIndex: index,
                                ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: 60,
                          height: 60,
                          color: AppColor.commonAppColor,
                          child: Cf.instance.getFileIcon(
                            selectedFiles[index].extension!,
                            selectedFiles[index].path,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: GestureDetector(
                        onTap: () {
                          provider.removeFile(screenName, index);
                        },
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: AppColor.blackColor,
                          child: CircleAvatar(
                            radius: 10,
                            backgroundColor: AppColor.borderColor,
                            child: Icon(
                              Icons.close,
                              color: AppColor.blackColor,
                              size: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  static void showCameraOptionsBottomSheet(BuildContext context, String screenName) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppPreferenceConstants.themeModeBoolValueGet
          ? CupertinoColors.darkBackgroundGray
          : AppColor.appBarColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              commonText(
                text: 'Camera Options',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColor.whiteColor,
              ),
              const SizedBox(height: 20),
              ListTile(
                leading:
                const Icon(Icons.camera_alt, color: AppColor.whiteColor),
                title: commonText(
                  text: 'Capture Photo',
                  color: AppColor.whiteColor,
                ),
                onTap: () {
                  Navigator.pop(context);
                  FileServiceProvider.instance.captureMedia(
                      isVideo: false, screenName: screenName);
                },
              ),
              ListTile(
                leading: const Icon(Icons.videocam, color: AppColor.whiteColor),
                title: commonText(
                  text: 'Record Video',
                  color: AppColor.whiteColor,
                ),
                onTap: () {
                  Navigator.pop(context);
                  FileServiceProvider.instance.captureMedia(
                      isVideo: true, screenName: screenName);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  static void showUserProfilePopup(BuildContext context, {
    required String userId,
    required String username,
    required String fullName,
    required String email,
    required String avatarUrl,
    required String status,
  }) {
    final bool isCurrentUser = userId == signInModel!.data?.user?.sId;

    showDialog(
      context: context,
      builder: (context) =>
          Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              width: 300,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppPreferenceConstants.themeModeBoolValueGet ? AppColor
                    .darkAppBarColor : AppColor.appBarColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppPreferenceConstants.themeModeBoolValueGet ? Colors
                      .grey[800]! : Colors.grey[300]!,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      CircleAvatar(
                        radius: 80,
                        backgroundColor: Colors.grey[200],
                        child: ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: ApiString.profileBaseUrl + avatarUrl,
                            width: 160,
                            height: 160,
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.person, size: 160),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 10,
                        bottom: 10,
                        child: Container(
                          padding: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: getCommonStatusIcons(
                              status: status, size: 30, assetIcon: false),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Visibility(
                    visible: fullName.isNotEmpty,
                    child: Column(
                      children: [
                        commonText(
                            text: fullName,
                            color: Colors.white,
                            fontSize: 18
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                  ),
                  commonText(
                      text: '@$username',
                      color: Colors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.w400
                  ),
                  SizedBox(height: 5),
                  Divider(color: Colors.white),
                  SizedBox(height: 5),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        commonText(text:
                        email,
                            fontSize: 14,
                            color: Colors.blue,
                            fontWeight: FontWeight.w400
                        ),
                        SizedBox(height: 10),
                        commonText(text:
                        "Local Time (GMT+5:30)",
                            fontSize: 14,
                            color: Colors.grey
                        ),
                        SizedBox(height: 5),
                        commonText(text:
                        DateFormat('h.mm a').format(DateTime.now()),
                            fontSize: 14,
                            color: Colors.grey
                        ),
                        SizedBox(height: 5),
                      ],
                    ),
                  ),
                  Divider(color: Colors.white),
                  SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        if (isCurrentUser) {
                          commonProfilePreview(context);
                        } else {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  SingleChatMessageScreen(
                                    userName: username,
                                    oppositeUserId: userId,
                                    calledForFavorite: false,
                                    needToCallAddMessage: false,
                                  ),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.blueColor,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.send, color: Colors.white),
                            SizedBox(width: 10),
                            commonText(
                                text: isCurrentUser
                                    ? 'Edit Profile'
                                    : 'Message',
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w400
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  static Widget reactionBar({
    required BuildContext context,
    required Function(String) onReactionSelected,
  }) {
    final reactions = [
      {
        'url': 'https://cdn.jsdelivr.net/npm/emoji-datasource-apple/img/apple/64/1f44d.png',
        'name': 'Thumb'
      },
      {
        'url': 'https://cdn.jsdelivr.net/npm/emoji-datasource-apple/img/apple/64/2764-fe0f.png',
        'name': 'Heart'
      },
      {
        'url': 'https://cdn.jsdelivr.net/npm/emoji-datasource-apple/img/apple/64/1f603.png',
        'name': 'Smile'
      },
      {
        'url': 'https://cdn.jsdelivr.net/npm/emoji-datasource-apple/img/apple/64/1f622.png',
        'name': 'Sad'
      },
      {
        'url': 'https://cdn.jsdelivr.net/npm/emoji-datasource-apple/img/apple/64/1f64f.png',
        'name': 'Hands'
      },
    ];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppPreferenceConstants.themeModeBoolValueGet
            ? Colors.grey[900]
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppPreferenceConstants.themeModeBoolValueGet ? Colors
              .grey[800]! : Colors.grey[300]!,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: reactions.map((reaction) {
          return GestureDetector(
            onTap: () => onReactionSelected(reaction['url']!),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: CachedNetworkImage(
                imageUrl: reaction['url']!,
                width: 24,
                height: 24,
                placeholder: (context, url) =>
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  static void showReactionBar(BuildContext context, String messageId,
      String receiverId, String isFrom) {
    final RenderBox? button = context.findRenderObject() as RenderBox?;
    if (button == null) return;

    final RenderBox overlay = Overlay
        .of(context)
        .context
        .findRenderObject() as RenderBox;
    final buttonPos = button.localToGlobal(Offset.zero, ancestor: overlay);
    final buttonSize = button.size;

    // Position the reaction bar to the right of the message
    final position = RelativeRect.fromLTRB(
      buttonPos.dx + buttonSize.width - 180,
      // Align right edge, adjust 180 based on reaction bar width
      buttonPos.dy - 40, // Show above the message
      buttonPos.dx + buttonSize.width,
      buttonPos.dy,
    );

    showMenu(
      context: context,
      position: position,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.transparent,
      items: [
        PopupMenuItem(
          enabled: false,
          padding: EdgeInsets.zero,
          child: reactionBar(
            context: context,
            onReactionSelected: (reactionUrl) {
              // print("Reaction Bar = $isFrom");
              if (isFrom == "Chat" || isFrom == "Reply") {
                final chatProvider =
                Provider.of<ChatProvider>(context, listen: false);
                chatProvider.reactMessage(
                    messageId: messageId,
                    reactUrl: reactionUrl,
                    receiverId: receiverId,
                    isFrom: isFrom);
              } else {
                final channelChatProvider =
                Provider.of<ChannelChatProvider>(context, listen: false);
                channelChatProvider.reactMessage(
                    messageId: messageId,
                    reactUrl: reactionUrl,
                    channelId: receiverId,
                    isFrom: isFrom
                );
              }
              Navigator.pop(context);
              // print("Selected reaction: $reactionUrl"); // Print the selected reaction URL
            },
          ),
        ),
      ],
    );
  }

  static Widget messageReactions({
    required List<String> reactions,
    double size = 16,
  }) {
    return Wrap(
      spacing: 4,
      children: reactions.map((reactionUrl) {
        return Container(
          padding: EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: AppPreferenceConstants.themeModeBoolValueGet ? Colors
                .grey[900] : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppPreferenceConstants.themeModeBoolValueGet ? Colors
                  .grey[800]! : Colors.grey[300]!,
            ),
          ),
          child: CachedNetworkImage(
            imageUrl: reactionUrl,
            width: size,
            height: size,
            placeholder: (context, url) =>
                SizedBox(
                  width: size,
                  height: size,
                  child: CircularProgressIndicator(strokeWidth: 1),
                ),
            errorWidget: (context, url, error) => Icon(Icons.error, size: size),
          ),
        );
      }).toList(),
    );
  }

  static Map<String, int> groupReactions(List<dynamic> reactions) {
    final Map<String, int> groupedReactions = {};
    for (var reaction in reactions) {
      if (reaction.emoji != null) {
        groupedReactions[reaction.emoji!] =
            (groupedReactions[reaction.emoji!] ?? 0) + 1;
      }
    }
    return groupedReactions;
  }
}