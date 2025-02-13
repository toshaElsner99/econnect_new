import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_connect/main.dart';
import 'package:e_connect/model/search_user_model.dart';
import 'package:e_connect/screens/chat/single_chat_message_screen.dart';
import 'package:e_connect/utils/api_service/api_string_constants.dart';
import 'package:e_connect/utils/common/common_function.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/channel_list/channel_list_cubit.dart';
import '../../utils/common/common_widgets.dart';

class OpenDirectMessage extends StatefulWidget {
  const OpenDirectMessage({super.key});

  @override
  State<OpenDirectMessage> createState() => _OpenDirectMessageState();
}

class _OpenDirectMessageState extends State<OpenDirectMessage> {
  final _searchController = TextEditingController();
  // final channelListCubit = ChannelListCubit();
  final channelListProvider1 = Provider.of<ChannelListProvider>(navigatorKey.currentState!.context,listen: false);

  @override
  void initState() {
    super.initState();
    channelListProvider1.getUserSuggestionsListing();

    _searchController.addListener(() {
      if (_searchController.text.isNotEmpty && _searchController.text.length > 1) {
        channelListProvider1.searchUserByName(search: _searchController.text);
      } else if (_searchController.text.isEmpty) {
        channelListProvider1.searchUserModel = SearchUserModel();
        channelListProvider1.searchUserByName(search: "");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Consumer<ChannelListProvider>(builder: (context, channelListProvider, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            // backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: commonText(
              text: 'Direct Messages',
                fontSize: 20,
            ),
          ),
          body: Column(
            children: [
              // Search Field
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: commonTextFormField(
                  controller: _searchController,
                  hintText: 'Search names',
                  prefixIcon: const Icon(CupertinoIcons.search),
                ),
              ),
              _searchController.text.isEmpty ?

              Visibility(
                visible: channelListProvider.getUserSuggestions != null,
                child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 20,vertical: 20),
                    alignment: Alignment.centerLeft,
                    child: commonText(text: "${channelListProvider.getUserSuggestions?.data?.suggestions?.length ?? 0} of ${channelListProvider.getUserSuggestions?.data?.totalUsers ?? 0} members")),
              ) :
              Visibility(
                visible: channelListProvider.searchUserModel != null,
                child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 20,vertical: 20),
                    alignment: Alignment.centerLeft,
                    child: commonText(text: "${channelListProvider.searchUserModel?.data?.totalSearchResults} of ${channelListProvider.searchUserModel?.data?.totalUsers} members")),
              ),


              if(_searchController.text.isNotEmpty)...{
                Expanded(
                  // child: BlocBuilder<ChannelListCubit, ChannelListState>(
                  //   bloc: channelListCubit,
                  //   builder: (context, state) {
                child: Consumer<ChannelListProvider>(builder: (context, channelListProvider, child) {

                      final users =  channelListProvider.searchUserModel?.data?.users;

                      if (users == null || users.isEmpty) {
                        return Center(
                          child: commonText(
                            text: 'No users found',
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          final user = users[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: CachedNetworkImageProvider(
                                ApiString.profileBaseUrl + (user.avatarUrl ?? ""),
                              ),
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      commonText(
                                        text: user.username ?? "",
                                        color: Colors.black87,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                      ),
                                      SizedBox(height: 4,),
                                      commonText(
                                        text: user.email ?? "",
                                        color: Colors.black87,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),

                                    ],
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              print("tapped>>>> ${user.username} ${user.sId} ");
                              pushReplacement(screen: SingleChatMessageScreen(userName: user.username ?? "", oppositeUserId: user.sId ?? "",needToCallAddMessage: true,)
                              );},
                          );
                        },
                      );
                    },
                  ),
                ),
              }else...{
                Expanded(
                child:  Consumer<ChannelListProvider>(builder: (context, channelListProvider, child) {

                  // child: BlocBuilder<ChannelListCubit, ChannelListState>(
                  //   bloc: channelListCubit,
                  //   builder: (context, state) {
                      final users =  channelListProvider.getUserSuggestions?.data?.suggestions;

                      if (users == null || users.isEmpty) {
                        return Center(
                          child: commonText(
                            text: 'No users found',
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          final user = users[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: CachedNetworkImageProvider(
                                ApiString.profileBaseUrl + (user.avatarUrl ?? ""),
                              ),
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      commonText(
                                        text: user.username ?? "",
                                        color: Colors.black87,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                      ),
                                      SizedBox(height: 4,),
                                      commonText(
                                        text: user.email ?? "",
                                        color: Colors.black87,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),

                                    ],
                                  ),
                                ),
                              ],
                            ),

                            onTap: () {
                              print("tapped>>>> ${user.username} ${user.userId} ");
                              pushReplacement(screen: SingleChatMessageScreen(userName: user.username ?? "", oppositeUserId: user.userId ?? "",needToCallAddMessage: true)
                              );},
                          );
                        },
                      );
                    },
                  ),
                ),
              }
            ],
          ),
        );
      },),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}