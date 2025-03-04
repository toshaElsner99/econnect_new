// import 'package:e_connect/model/channel_members_model.dart';
// import 'package:e_connect/providers/channel_chat_provider.dart';
// import 'package:e_connect/screens/chat/single_chat_message_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../../main.dart';
// import '../../../providers/channel_list_provider.dart';
// import '../../../utils/api_service/api_string_constants.dart';
// import '../../../utils/common/common_widgets.dart';
// import 'dart:async';
//
// class User {
//   final String? id;
//   final String? username;
//   final String? fullName;
//   final String? avatarUrl;
//   final String? email;
//
//   User({
//     this.id,
//     this.username,
//     this.fullName,
//     this.avatarUrl,
//     this.email,
//   });
//
//   // Update factory constructor to match searchUserModel's data structure
//   factory User.fromSearchResult(dynamic user) {
//     return User(
//       id: user.sId,
//       username: user.username,
//       fullName: user.fullName,
//       avatarUrl: ApiString.profileBaseUrl + (user.avatarUrl ?? ''),  // Add base URL
//       email: user.email,
//     );
//   }
//
//   @override
//   bool operator ==(Object other) =>
//       identical(this, other) ||
//       other is User && runtimeType == other.runtimeType && id == other.id;
//
//   @override
//   int get hashCode => id.hashCode;
// }
//
// class ChannelMembersInfo extends StatefulWidget {
//   final String channelId;
//   final String channelName;
//   const ChannelMembersInfo({
//     super.key,
//     required this.channelId,
//     required this.channelName,
//   });
//
//   @override
//   State<ChannelMembersInfo> createState() => _ChannelMembersInfoState();
// }
//
// class _ChannelMembersInfoState extends State<ChannelMembersInfo> {
//   bool isManageMode = false;
//   final TextEditingController _searchController = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//     Provider.of<ChannelChatProvider>(context, listen: false).getChannelMembersList(widget.channelId);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//           backgroundColor: Colors.black,
//           leading: IconButton(
//             icon: const Icon(Icons.arrow_back, color: Colors.white),
//             onPressed: () {
//               Navigator.pop(context);
//             },
//           ),
//           title: Consumer<ChannelChatProvider>(
//             builder: (context, provider, child) {
//               return Text(
//                 '${provider.channelMembersList.length} members',
//                 style: const TextStyle(color: Colors.white),
//               );
//             },
//           )),
//       body: Consumer<ChannelChatProvider>(
//         builder: (context, provider, child) {
//           final adminMembers = provider.channelMembersList
//               .where((MemberDetails member) => member.isAdmin == true)
//               .toList();
//           final regularMembers = provider.channelMembersList
//               .where((MemberDetails member) => member.isAdmin != true)
//               .toList();
//
//           return ListView(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             children: [
//               Consumer<ChannelChatProvider>(
//                 builder: (context, provider, child) {
//                   final isCurrentUserAdmin = adminMembers.any((member) =>
//                       member.isAdmin == true &&
//                       member.sId == signInModel.data?.user?.id);
//                   if (isCurrentUserAdmin) {
//                     return Padding(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 16, vertical: 8),
//                       child: Row(
//                         children: [
//                           Container(
//                             decoration: BoxDecoration(
//                               color: Colors
//                                   .lightBlue[900], // Dark background color
//                               borderRadius: BorderRadius.circular(4),
//                             ),
//                             child: TextButton(
//                               onPressed: () {
//                                 setState(() {
//                                   isManageMode =
//                                       !isManageMode; // Toggle manage mode
//                                 });
//                               },
//                               style: TextButton.styleFrom(
//                                 padding: const EdgeInsets.symmetric(
//                                     horizontal: 16, vertical: 8),
//                                 minimumSize: Size.zero,
//                                 tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                               ),
//                               child: const Text(
//                                 'Manage',
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 8),
//                           Container(
//                             decoration: BoxDecoration(
//                                 // color: const Color(0xFF1E1E1E), // Dark background color
//                                 borderRadius: BorderRadius.circular(4),
//                                 border: Border.all(color: Colors.grey)),
//                             child: TextButton.icon(
//                               onPressed: () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) => AddPeopleToChannel(
//                                       channelId: widget.channelId,
//                                       channelName: widget.channelName,
//                                     ),
//                                   ),
//                                 );
//                               },
//                               style: TextButton.styleFrom(
//                                 padding: const EdgeInsets.symmetric(
//                                     horizontal: 16, vertical: 8),
//                                 minimumSize: Size.zero,
//                                 tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                               ),
//                               icon: const Icon(
//                                 Icons.person_add_outlined,
//                                 color: Colors.white,
//                                 size: 16,
//                               ),
//                               label: const Text(
//                                 'Add',
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   }
//                   return const SizedBox.shrink();
//                 },
//               ),
//               if (adminMembers.isNotEmpty) ...[
//                 const Padding(
//                   padding: EdgeInsets.symmetric(vertical: 16),
//                   child: Text(
//                     'CHANNEL ADMINS',
//                     style: TextStyle(
//                       color: Colors.grey,
//                       fontSize: 12,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//                 ...adminMembers.map((member) => memberTile(member)),
//               ],
//               if (regularMembers.isNotEmpty) ...[
//                 const Padding(
//                   padding: EdgeInsets.symmetric(vertical: 16),
//                   child: Text(
//                     'MEMBERS',
//                     style: TextStyle(
//                       color: Colors.grey,
//                       fontSize: 12,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//                 ...regularMembers.map((member) => memberTile(member)),
//               ],
//             ],
//           );
//         },
//       ),
//     );
//   }
//
//   Widget memberTile(MemberDetails member) {
//     return ListTile(
//       contentPadding: EdgeInsets.zero,
//       leading: profileIconWithStatus(
//         userID: member.sId!,
//         otherUserProfile: member.avatarUrl,
//         status: member.status!,
//       ),
//       title: Text(
//         member.fullName ?? member.username ?? '',
//         style: const TextStyle(
//           color: Colors.white,
//           fontSize: 16,
//         ),
//       ),
//       trailing: !isManageMode
//           ? GestureDetector(
//               onTap: () {
//                 Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (context) => SingleChatMessageScreen(
//                             userName: member.username!,
//                             oppositeUserId: member.sId!,
//                             calledForFavorite: false,
//                             needToCallAddMessage: false)));
//               },
//               child: const Icon(Icons.send, color: Colors.blue, size: 20),
//             )
//           : Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   member.isAdmin == true ? 'Admin' : 'Member',
//                   style: const TextStyle(
//                     color: Colors.blue,
//                     fontSize: 14,
//                   ),
//                 ),
//                 dropDownForManageUsers(member)
//               ],
//             ),
//     );
//   }
//
//   dropDownForManageUsers(member) {
//     return PopupMenuButton<String>(
//       icon: const Icon(
//         Icons.keyboard_arrow_down,
//         color: Colors.blue,
//         size: 20,
//       ),
//       color: const Color(0xFF1E1E1E),
//       position: PopupMenuPosition.under,
//       constraints: const BoxConstraints(
//         minWidth: 200,
//         maxWidth: 200,
//       ),
//       itemBuilder: (context) {
//         if (member.isAdmin == true) {
//           // Admin options
//           return [
//             if (member.sId != signInModel.data?.user?.id) ...[
//               const PopupMenuItem(
//                 value: 'make_member',
//                 child: Text(
//                   'Make Channel Member',
//                   style: TextStyle(color: Colors.white),
//                 ),
//               ),
//               const PopupMenuItem(
//                 value: 'remove',
//                 child: Text(
//                   'Remove from Channel',
//                   style: TextStyle(color: Colors.white),
//                 ),
//               ),
//             ] else ...[
//               const PopupMenuItem(
//                 value: 'make_member',
//                 child: Text(
//                   'Make Channel Member',
//                   style: TextStyle(color: Colors.white),
//                 ),
//               ),
//               const PopupMenuItem(
//                 value: 'leave',
//                 child: Text(
//                   'Leave Channel',
//                   style: TextStyle(color: Colors.white),
//                 ),
//               ),
//             ]
//           ];
//         } else {
//           // Regular member options
//           return [
//             const PopupMenuItem(
//               value: 'make_admin',
//               child: Text(
//                 'Make Channel Admin',
//                 style: TextStyle(color: Colors.white),
//               ),
//             ),
//             const PopupMenuItem(
//               value: 'remove',
//               child: Text(
//                 'Remove from Channel',
//                 style: TextStyle(color: Colors.white),
//               ),
//             ),
//           ];
//         }
//       },
//       onSelected: (value) async {
//         switch (value) {
//           case 'make_member':
//             // Add logic to make admin a regular member
//             break;
//           case 'make_admin':
//             // Add logic to make member an admin
//             break;
//           case 'remove':
//             // Add logic to remove from channel
//             break;
//           case 'leave':
//             // Add logic to leave channel
//             break;
//         }
//       }
//     );
//   }
// }
//
// class AddPeopleToChannel extends StatefulWidget {
//   final String channelId;
//   final String channelName;
//   const AddPeopleToChannel({
//     super.key,
//     required this.channelId,
//     required this.channelName,
//   });
//
//   @override
//   State<AddPeopleToChannel> createState() => _AddPeopleToChannelState();
// }
//
// class _AddPeopleToChannelState extends State<AddPeopleToChannel> {
//   final TextEditingController _searchController = TextEditingController();
//   Timer? _debounceTimer;
//   List<User> selectedUsers = []; // Changed from List<Users> to List<User>
//
//   @override
//   void dispose() {
//     _debounceTimer?.cancel();
//     _searchController.dispose();
//     super.dispose();
//   }
//
//   void _onSearchChanged(String value) {
//     if (_debounceTimer?.isActive ?? false) {
//       _debounceTimer!.cancel();
//     }
//     _debounceTimer = Timer(const Duration(milliseconds: 500), () {
//       if (mounted) {
//         context.read<ChannelChatProvider>().searchUserByName(
//           search: _searchController.text
//         );
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         backgroundColor: Colors.black,
//         leading: IconButton(
//           icon: const Icon(Icons.close, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Text(
//           'Add people to ${widget.channelName}',
//           style: const TextStyle(
//             color: Colors.white,
//             fontSize: 16,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: selectedUsers.isEmpty ? null : () async {
//               // Get only the user IDs from selected users
//               final userIds = selectedUsers.map((user) => user.id ?? '').toList();
//
//               // Call the API with just the list of IDs
//               await context.read<ChannelChatProvider>().addMembersToChannel(
//                 channelId: widget.channelId,
//                 userIds: userIds,
//               );
//
//               // Close the screen
//               if (mounted) {
//                 Navigator.pop(context);
//               }
//             },
//             child: Text(
//               'Add',
//               style: TextStyle(
//                 color: selectedUsers.isEmpty ? Colors.grey : Colors.blue,
//                 fontSize: 14,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // Search TextField
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 8),
//               decoration: BoxDecoration(
//                 color: const Color(0xFF1E1E1E),
//                 borderRadius: BorderRadius.circular(4),
//               ),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Wrap(
//                       spacing: 8,
//                       runSpacing: 4,
//                       crossAxisAlignment: WrapCrossAlignment.center,
//                       children: [
//                         // Selected user chips
//                         ...selectedUsers.map((user) => Container(
//                           margin: const EdgeInsets.symmetric(vertical: 6),
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 8,
//                             vertical: 10,
//                           ),
//                           decoration: BoxDecoration(
//                             color: const Color(0xFF1E1E1E),
//                             borderRadius: BorderRadius.circular(16),
//                             border: Border.all(
//                               color: Colors.grey[800]!,
//                               width: 1
//                             ),
//                           ),
//                           child: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               ClipRRect(
//                                 borderRadius: BorderRadius.circular(16),
//                                 child: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
//                                     ? Image.network(
//                                         user.avatarUrl!,
//                                         width: 28,
//                                         height: 28,
//                                         fit: BoxFit.cover,
//                                         errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(),
//                                         loadingBuilder: (context, child, loadingProgress) {
//                                           if (loadingProgress == null) return child;
//                                           return _buildDefaultAvatar();
//                                         },
//                                       )
//                                     : _buildDefaultAvatar(),
//                               ),
//                               const SizedBox(width: 5),
//                               Text(
//                                 user.username ?? '',
//                                 style: const TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 14,
//                                 ),
//                               ),
//                               const SizedBox(width: 5),
//                               GestureDetector(
//                                 onTap: () {
//                                   setState(() {
//                                     selectedUsers.remove(user);
//                                   });
//                                 },
//                                 child: Container(
//                                   padding: const EdgeInsets.all(2),
//                                   decoration: BoxDecoration(
//                                     color: Colors.grey[800],  // Darker background for X icon
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                   child: const Icon(
//                                     Icons.close,
//                                     color: Colors.white,  // White X icon
//                                     size: 14,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         )).toList(),
//                         // Search TextField
//                         Container(
//                           constraints: const BoxConstraints(minWidth: 100),
//                           child: IntrinsicWidth(
//                             child: TextField(
//                               controller: _searchController,
//                               style: const TextStyle(color: Colors.white),
//                               decoration: InputDecoration(
//                                 hintText: selectedUsers.isEmpty ? 'Search for users' : '',
//                                 hintStyle: TextStyle(color: Colors.grey[600]),
//                                 border: InputBorder.none,
//                                 focusedBorder: InputBorder.none,
//                                 errorBorder: InputBorder.none,
//                                 contentPadding: const EdgeInsets.symmetric(
//                                   horizontal: 8,
//                                   vertical: 12,
//                                 ),
//                                 isDense: true,
//                               ),
//                               onChanged: _onSearchChanged,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//
//           // Search Results
//           Expanded(
//             child: Consumer<ChannelChatProvider>(
//               builder: (context, provider, child) {
//                 if (provider.isLoading) {
//                   return const Center(
//                     child: CircularProgressIndicator(color: Colors.blue),
//                   );
//                 }
//
//                 if (_searchController.text.isEmpty) {
//                   return Container();
//                 }
//
//                 final users = provider.searchUserModel?.data?.users;
//
//                 if (users == null || users.isEmpty) {
//                   return const Center(
//                     child: Text(
//                       'No users found',
//                       style: TextStyle(color: Colors.grey),
//                     ),
//                   );
//                 }
//
//                 // Filter the users list
//                 final filteredUsers = users.where((user) =>
//                   // Exclude current user
//                   user.sId != signInModel.data?.user?.id &&
//                   // Exclude already selected users
//                   !selectedUsers.any((selectedUser) => selectedUser.id == user.sId) &&
//                   // Exclude existing channel members
//                   !context.read<ChannelChatProvider>().channelMembersList
//                     .any((member) => member.sId == user.sId)
//                 ).toList();
//
//                 if (filteredUsers.isEmpty) {
//                   return const Center(
//                     child: Text(
//                       'No users found',
//                       style: TextStyle(color: Colors.grey),
//                     ),
//                   );
//                 }
//
//                 return ListView.builder(
//                   itemCount: filteredUsers.length,
//                   itemBuilder: (context, index) {
//                     final user = filteredUsers[index];
//                     return ListTile(
//                       leading: profileIconWithStatus(
//                         userID: user.sId ?? '',
//                         otherUserProfile: user.avatarUrl,
//                         status: '',
//                       ),
//                       title: Text(
//                         user.fullName ?? user.username ?? '',
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 16,
//                         ),
//                       ),
//                       subtitle: Text(
//                         user.email ?? '',
//                         style: TextStyle(
//                           color: Colors.grey[600],
//                           fontSize: 14,
//                         ),
//                       ),
//                       onTap: () {
//                         setState(() {
//                           selectedUsers.add(User.fromSearchResult(user));
//                           _searchController.clear();
//                         });
//                       },
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDefaultAvatar() {
//     return Container(
//       width: 28,
//       height: 28,
//       decoration: BoxDecoration(
//         color: Colors.grey[800],
//         borderRadius: BorderRadius.circular(14),
//       ),
//       child: const Icon(
//         Icons.person,
//         size: 18,
//         color: Colors.white,
//       ),
//     );
//   }
// }
import 'package:e_connect/model/channel_members_model.dart';
import 'package:e_connect/providers/channel_chat_provider.dart';
import 'package:e_connect/providers/channel_list_provider.dart';
import 'package:e_connect/screens/chat/single_chat_message_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../../../main.dart';
import '../../../utils/api_service/api_string_constants.dart';
import '../../../utils/common/common_widgets.dart';

class User {
  final String? id;
  final String? username;
  final String? fullName;
  final String? avatarUrl;
  final String? email;

  User({
    this.id,
    this.username,
    this.fullName,
    this.avatarUrl,
    this.email,
  });

  // Update factory constructor to match searchUserModel's data structure
  factory User.fromSearchResult(dynamic user) {
    return User(
      id: user.sId,
      username: user.username,
      fullName: user.fullName,
      avatarUrl: ApiString.profileBaseUrl + (user.avatarUrl ?? ''),  // Add base URL
      email: user.email,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is User && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class ChannelMembersInfo extends StatefulWidget {
  final String channelId;
  final String channelName;
  const ChannelMembersInfo({
    super.key,
    required this.channelId,
    required this.channelName,
  });

  @override
  State<ChannelMembersInfo> createState() => _ChannelMembersInfoState();
}

class _ChannelMembersInfoState extends State<ChannelMembersInfo> {
  bool isManageMode = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Provider.of<ChannelChatProvider>(context, listen: false).getChannelMembersList(widget.channelId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.black,
      appBar: AppBar(
          // backgroundColor: Colors.black,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Consumer<ChannelChatProvider>(
            builder: (context, provider, child) {
              return Text(
                '${provider.channelMembersList.length} members'
              );
            },
          )),
      body: Consumer<ChannelChatProvider>(
        builder: (context, provider, child) {
          final adminMembers = provider.channelMembersList
              .where((MemberDetails member) => member.isAdmin == true)
              .toList();
          final regularMembers = provider.channelMembersList
              .where((MemberDetails member) => member.isAdmin != true)
              .toList();

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              Consumer<ChannelChatProvider>(
                builder: (context, provider, child) {
                  final isCurrentUserAdmin = adminMembers.any((member) =>
                  member.isAdmin == true &&
                      member.sId == signInModel.data?.user?.id);
                  if (isCurrentUserAdmin) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors
                                  .lightBlue[900], // Dark background color
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  isManageMode =
                                  !isManageMode; // Toggle manage mode
                                });
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'Manage',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                              // color: const Color(0xFF1E1E1E), // Dark background color
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.grey)),
                            child: TextButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddPeopleToChannel(
                                      channelId: widget.channelId,
                                      channelName: widget.channelName,
                                    ),
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              icon: const Icon(
                                Icons.person_add_outlined,
                                // color: Colors.white,
                                size: 16,
                              ),
                              label: const Text(
                                'Add',
                                style: TextStyle(
                                  // color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              if (adminMembers.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'CHANNEL ADMINS',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ...adminMembers.map((member) => memberTile(member)),
              ],
              if (regularMembers.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'MEMBERS',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ...regularMembers.map((member) => memberTile(member)),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget memberTile(MemberDetails member) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: profileIconWithStatus(
        userID: member.sId!,
        otherUserProfile: member.avatarUrl,
        status: member.status!,
      ),
      title: Text(
        member.fullName ?? member.username ?? '',
        style: const TextStyle(
          // color: Colors.white,
          fontSize: 16,
        ),
      ),
      trailing: !isManageMode
          ? GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SingleChatMessageScreen(
                      userName: member.username!,
                      oppositeUserId: member.sId!,
                      calledForFavorite: false,
                      needToCallAddMessage: false)));
        },
        child: const Icon(Icons.send, color: Colors.blue, size: 20),
      )
          : PopupMenuButton<String>(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                member.isAdmin == true ? 'Admin' : 'Member',
                style: const TextStyle(
                  // color: Colors.blue,
                  fontSize: 14,
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down,
                // color: Colors.blue,
                size: 20,
              ),
            ],
          ),
          color: const Color(0xFF1E1E1E),
          position: PopupMenuPosition.under,
          constraints: const BoxConstraints(
            minWidth: 200,
            maxWidth: 200,
          ),
          itemBuilder: (context) {
            if (member.isAdmin == true) {
              // Admin options
              return [
                if (member.sId != signInModel.data?.user?.id) ...[
                  const PopupMenuItem(
                    value: 'make_member',
                    child: Text(
                      'Make Channel Member',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'remove',
                    child: Text(
                      'Remove from Channel',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ] else ...[
                  const PopupMenuItem(
                    value: 'make_member',
                    child: Text(
                      'Make Channel Member',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'leave',
                    child: Text(
                      'Leave Channel',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ]
              ];
            } else {
              // Regular member options
              return [
                const PopupMenuItem(
                  value: 'make_admin',
                  child: Text(
                    'Make Channel Admin',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const PopupMenuItem(
                  value: 'remove',
                  child: Text(
                    'Remove from Channel',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ];
            }
          },
          onSelected: (value) async {
            switch (value) {
              case 'make_admin':
                await context.read<ChannelListProvider>().toggleAdminAndMember(
                    channelId: widget.channelId,
                    userId: member.sId!
                );
                break;
              case 'make_member':
                await context.read<ChannelListProvider>().toggleAdminAndMember(
                    channelId: widget.channelId,
                    userId: member.sId!
                );
                break;
              case 'remove':
                await context.read<ChannelListProvider>().removeMember(
                    channelId: widget.channelId,
                    userId: member.sId!
                );
                break;
              case 'leave':
                await context.read<ChannelListProvider>().leaveChannel(channelId: widget.channelId, isFromMembersScreen: true);
                break;
            }
          }
      ),
    );
  }
}

class AddPeopleToChannel extends StatefulWidget {
  final String channelId;
  final String channelName;
  const AddPeopleToChannel({
    super.key,
    required this.channelId,
    required this.channelName,
  });

  @override
  State<AddPeopleToChannel> createState() => _AddPeopleToChannelState();
}

class _AddPeopleToChannelState extends State<AddPeopleToChannel> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  List<User> selectedUsers = []; // Changed from List<Users> to List<User>

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer!.cancel();
    }
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        context.read<ChannelListProvider>().searchUserByName(
            search: _searchController.text
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.black,
      appBar: AppBar(
        // backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Add people to ${widget.channelName}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          TextButton(
            onPressed: selectedUsers.isEmpty ? null : () async {
              // Get only the user IDs from selected users
              final userIds = selectedUsers.map((user) => user.id ?? '').toList();

              // Call the API with just the list of IDs
              await context.read<ChannelChatProvider>().addMembersToChannel(
                channelId: widget.channelId,
                userIds: userIds,
              );

              // Close the screen
              if (mounted) {
                Navigator.pop(context);
              }
            },
            child: Text(
              'Add',
              style: TextStyle(
                color: selectedUsers.isEmpty ? Colors.grey : Colors.blue,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search TextField
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                // color: Colors.grey,
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        // Selected user chips
                        ...selectedUsers.map((user) => Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            // color: const Color(0xFF1E1E1E),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: Colors.grey[800]!,
                                width: 1
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                                    ? Image.network(
                                  user.avatarUrl!,
                                  width: 28,
                                  height: 28,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(),
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return _buildDefaultAvatar();
                                  },
                                )
                                    : _buildDefaultAvatar(),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                user.username ?? '',
                                style: const TextStyle(
                                  // color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 5),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedUsers.remove(user);
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[800],  // Darker background for X icon
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 14
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )).toList(),
                        // Search TextField
                        Container(
                          constraints: const BoxConstraints(minWidth: 100),
                          child: IntrinsicWidth(
                            child: TextField(
                              controller: _searchController,
                              // style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: selectedUsers.isEmpty ? 'Search for users' : '',
                                hintStyle: TextStyle(color: Colors.grey[600]),
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 12,
                                ),
                                isDense: true,
                              ),
                              onChanged: _onSearchChanged,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Search Results
          Expanded(
            child: Consumer<ChannelListProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.blue),
                  );
                }

                if (_searchController.text.isEmpty) {
                  return Container();
                }

                final users = provider.searchUserModel?.data?.users;

                if (users == null || users.isEmpty) {
                  return const Center(
                    child: Text(
                      'No users found',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                // Filter the users list
                final filteredUsers = users.where((user) =>
                // Exclude current user
                user.sId != signInModel.data?.user?.id &&
                    // Exclude already selected users
                    !selectedUsers.any((selectedUser) => selectedUser.id == user.sId) &&
                    // Exclude existing channel members
                    !context.read<ChannelChatProvider>().channelMembersList
                        .any((member) => member.sId == user.sId)
                ).toList();

                if (filteredUsers.isEmpty) {
                  return const Center(
                    child: Text(
                      'No users found'
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    return ListTile(
                      leading: profileIconWithStatus(
                        userID: user.sId ?? '',
                        otherUserProfile: user.avatarUrl,
                        status: '',
                      ),
                      title: Text(
                        user.fullName ?? user.username ?? '',
                        style: const TextStyle(
                          // color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        user.email ?? '',
                        style: TextStyle(
                          // color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          selectedUsers.add(User.fromSearchResult(user));
                          _searchController.clear();
                        });
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Icon(
        Icons.person,
        size: 18,
        color: Colors.white,
      ),
    );
  }
}
