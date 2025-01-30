import 'package:e_connect/utils/app_color_constants.dart';
import 'package:e_connect/utils/common/common_widgets.dart';
import 'package:flutter/material.dart';

class ChatHeaderButtons extends StatelessWidget {
  const ChatHeaderButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColor.blackColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          commonButtonForHeaderFavoriteInfoCallMute(
            icon: Icons.edit,
            label: 'Set Header',
            onTap: () {},
            context: context,
            totalButtons: 3
          ),
          commonButtonForHeaderFavoriteInfoCallMute(
            icon: Icons.star,
            label: 'Favorited',
            isSelected: true,
            onTap: () {},
              context: context,
              totalButtons: 3
          ),
          commonButtonForHeaderFavoriteInfoCallMute(
            icon: Icons.info_outline,
            label: 'Info',
            onTap: () {},
              context: context,
              totalButtons: 3
          ),
        ],
      ),
    );
  }
} 