import 'package:e_connect/cubit/channel_list/channel_list_cubit.dart';
import 'package:e_connect/main.dart';
import 'package:e_connect/utils/app_color_constants.dart';
import 'package:e_connect/utils/common/common_function.dart';
import 'package:e_connect/utils/common/common_widgets.dart';
import 'package:flutter/material.dart';

class CreateChannelScreen extends StatefulWidget {
  const CreateChannelScreen({super.key});

  @override
  State<CreateChannelScreen> createState() => _CreateChannelScreenState();
}

class _CreateChannelScreenState extends State<CreateChannelScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _purposeController = TextEditingController();
  final channelListCubit = ChannelListCubit();

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'New Channel',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if(_nameController.text.trim().isNotEmpty){
                channelListCubit.createNewChannelCall(
                  channelName: _nameController.text.trim(),
                  isPrivateChannel: "$isPrivate",
                  description: _descriptionController.text.trim(),
                );
              }else {
                commonShowToast("Add channel name to proceed");
              }
            },
            child: const Text(
              'CREATE',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
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
        color: Colors.grey[50],
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
                color: Colors.grey[800],
                size: 24,
              ),
              const SizedBox(width: 16),
              const Text(
                'Make Private',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              Switch.adaptive(
                activeColor: AppColor.commonAppColor,
                activeTrackColor: AppColor.commonAppColor,
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
            color: Colors.black87,
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
            fillColor: Colors.grey[50],
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
