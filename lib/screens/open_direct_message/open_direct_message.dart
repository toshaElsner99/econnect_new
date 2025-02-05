import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_connect/model/search_user_model.dart';
import 'package:e_connect/utils/api_service/api_string_constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/channel_list/channel_list_cubit.dart';
import '../../utils/common/common_widgets.dart';

class OpenDirectMessage extends StatefulWidget {
  const OpenDirectMessage({super.key});

  @override
  State<OpenDirectMessage> createState() => _OpenDirectMessageState();
}

class _OpenDirectMessageState extends State<OpenDirectMessage> {
  final _searchController = TextEditingController();
  final channelListCubit = ChannelListCubit();

  @override
  void initState() {
    super.initState();
    channelListCubit.getUserSuggestionsListing();

    _searchController.addListener(() {
      if (_searchController.text.isNotEmpty && _searchController.text.length > 2) {
        channelListCubit.searchUserByName(search: _searchController.text);
      } else if (_searchController.text.isEmpty) {
        // channelListCubit.searchUserByName(search: "");
        channelListCubit.searchUserModel = SearchUserModel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: BlocBuilder<ChannelListCubit, ChannelListState>(
        bloc: channelListCubit,
        builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.black87),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Direct Messages',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
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
                visible: channelListCubit.getUserSuggestions != null,
                child: Container(
                margin: EdgeInsets.symmetric(horizontal: 20,vertical: 20),
                alignment: Alignment.centerLeft,
                child: commonText(text: "${channelListCubit.getUserSuggestions?.data?.suggestions?.length} of ${channelListCubit.getUserSuggestions?.data?.totalUsers} members")),
              ) :
              Visibility(
                visible: channelListCubit.searchUserModel != null,
                child: Container(
                margin: EdgeInsets.symmetric(horizontal: 20,vertical: 20),
                alignment: Alignment.centerLeft,
                child: commonText(text: "${channelListCubit.searchUserModel?.data?.totalSearchResults} of ${channelListCubit.searchUserModel?.data?.totalUsers} members")),
              ),


              if(_searchController.text.isNotEmpty)...{
                Expanded(
                  child: BlocBuilder<ChannelListCubit, ChannelListState>(
                    bloc: channelListCubit,
                    builder: (context, state) {
                      final users =  channelListCubit.searchUserModel?.data?.users;

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
                              // Handle user selection
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              }else...{
                Expanded(
                  child: BlocBuilder<ChannelListCubit, ChannelListState>(
                    bloc: channelListCubit,
                    builder: (context, state) {
                      final users =  channelListCubit.getUserSuggestions?.data?.suggestions;

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
                              // Handle user selection
                            },
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