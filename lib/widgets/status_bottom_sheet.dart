import 'package:e_connect/cubit/common_cubit/common_cubit.dart';
import 'package:e_connect/utils/app_color_constants.dart';
import 'package:e_connect/utils/app_image_assets.dart';
import 'package:e_connect/utils/app_string_constants.dart';
import 'package:e_connect/utils/common/common_widgets.dart';
import 'package:e_connect/utils/common/enums.dart';
import 'package:flutter/material.dart';

class StatusBottomSheet extends StatelessWidget {
   StatusBottomSheet({super.key,});

  var commonCubit = CommonCubit();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1B1E23),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
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
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
            ),
          ),

          // Status options
          _buildStatusOption(
            context,
            icon: Icons.check_circle,
            color: Colors.green,
            text: AppString.online,
            index: 0,
          ),
          _buildStatusOption(
            context,
            icon: Icons.access_time_filled_outlined,
            color: Colors.orange,
            text: AppString.away,
            index: 1,
          ),
          _buildStatusOption(
            context,
            icon: Icons.remove_circle,
            color: Colors.red,
            text: AppString.busy,
            index: 2,
          ),
          _buildStatusOption(
            context,
            icon: Icons.remove_circle,
            color: Colors.red,
            text: AppString.dnd,
            index: 3,
          ),
          _buildStatusOption(
            context,
            icon: Icons.circle_outlined,
            color: AppColor.borderColor,
            text: AppString.offline,
            index: 4,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildStatusOption(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String text,
    required int index,
  }) {
    return InkWell(
      onTap: () {
        commonCubit.updateStatusCall(status: index == 0 ? UserStatus.online.toString() : index == 1 ? UserStatus.away.toString() : index == 2 ? UserStatus.busy.toString() : index == 3 ? UserStatus.doNotDisturb.toString() : UserStatus.offline.toString());
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 16),
            commonText(
              text: text,
                color: Colors.white,
                fontSize: 16,
            ),
          ],
        ),
      ),
    );
  }
} 