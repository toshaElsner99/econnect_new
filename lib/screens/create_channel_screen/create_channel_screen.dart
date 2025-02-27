import 'package:e_connect/main.dart';
import 'package:e_connect/utils/app_color_constants.dart';
import 'package:e_connect/utils/app_preference_constants.dart';
import 'package:e_connect/utils/common/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/channel_list_provider.dart';
import '../../utils/common/common_function.dart';
import '../bottom_nav_tabs/home_screen.dart';

class CreateChannelScreen extends StatefulWidget {
  const CreateChannelScreen({super.key});

  @override
  State<CreateChannelScreen> createState() => _CreateChannelScreenState();
}

class _CreateChannelScreenState extends State<CreateChannelScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _purposeController = TextEditingController();
  // final channelListCubit = ChannelListCubit();

  bool isPrivate = true;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _purposeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isAdmin = signInModel.data?.user?.roleName == "Admin";

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: commonBackButton(),
        title:  commonText(
          text : 'New Channel',
            fontSize: 20,
        ),
        actions: [
          TextButton(
            onPressed: () {
              pushReplacement(screen: HomeScreen());
              if(_nameController.text.trim().isNotEmpty){
                context.read<ChannelListProvider>().createNewChannelCall(
                  channelName: _nameController.text.trim(),
                  isPrivateChannel: "$isPrivate",
                  description: _descriptionController.text.trim(),
                );
              }else {
                commonShowToast("Add channel name to proceed");
              }
            },
            child:  commonText(
              text : 'CREATE',
                color: Colors.white,
                fontSize: 16,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPrivateToggle(isAdmin),
              const SizedBox(height: 24),

              _buildInputField(
                controller: _nameController,
                label: 'Name',
                hintText: 'e.g. marketing, product-dev, design',
              ),
              const SizedBox(height: 24),

              _buildInputField(
                controller: _purposeController,
                label: 'Purpose (optional)',
                hintText: 'What\'s this channel about?',
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              Text(
                'Specify text to appear in the channel header beside the channel name. For example, include frequently used links by typing link text [Link Title](http://example.com).',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrivateToggle(bool isAdmin) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppPreferenceConstants.themeModeBoolValueGet ? Colors.black54 : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lock_outline,
                color: AppPreferenceConstants.themeModeBoolValueGet ? Colors.white : Colors.grey[800],
                size: 24,
              ),
              const SizedBox(width: 16),
              commonText(
                text : 'Make Private',
                  fontSize: 16,
              ),
              const Spacer(),
              Switch.adaptive(
                // activeColor: AppColor.commonAppColor,
                // activeTrackColor: AppColor.commonAppColor,
                value: isPrivate,
                onChanged: isAdmin
                    ? (value) => setState(() => isPrivate = value)
                    : null,
              ),
            ],
          ),
          if (isPrivate) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 40),
              child: Text(
                'When a channel is set to private, only invited team members can access and participate in that channel.',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 15,
            ),
            filled: true,
            fillColor: AppPreferenceConstants.themeModeBoolValueGet ? AppColor.borderColor.withOpacity(0.1) : Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.blue),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }
}
