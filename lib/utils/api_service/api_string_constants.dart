class ApiString{

  static const String baseUrl= 'https://econnect.weekmate.in/v1/'; /// THIS NEW DEVELOPMENT URL
  static const String profileBaseUrl = 'https://econnect.weekmate.in/public/'; /// Profile Image

  // static const String baseUrl= 'https://dev-econnect-sass.elsnerdev.co/v1/'; /// THIS NEW DEVELOPMENT URL
  // static const String profileBaseUrl = 'https://dev-econnect-sass.elsnerdev.co/'; /// Profile Image

  //static const String baseUrl = 'https://e-connect.elsner.com/v1/'; /// THIS LIVE URL
  // static const String profileBaseUrl = 'https://e-connect.elsner.com/public/'; /// Profile Image

  // static const String karmaBaseUrl = "https://dev-hrms.elsner.com/";
  static const String karmaBaseUrl = "https://hrms.elsner.com/";

  static const getAppVersion = "updateFCM_Mobile/get";

  /// End Point , Don't Change Belows End Point until didn't confirm through backend ///
  /*Changed*/static const login = "auth/userLogin"; ///done
  static const googleSignIn = "user/googleSSOLginApp";  /// skipping due to no google login method in ui
  static const allowGoogleSignIN = "user/alloawgoogleSSOLogin"; ///skipping due to no google login method in ui
  /*Changed*/static const getUserById = "user/getUserDetails"; ///done
  /*Changed*/static const updateStatus = "user/updateUserDetails"; /// New Updatestatus api
  /*Changed*/static const favoriteListGet = "favorite/getFavoriteChatList";
  /*Changed*/static const String channelList="channelManage/getChannel";  ///New Get Channel List Api End-Point
  /*Changed*/static const directMessageChatList = "chatList/getChatList"; // done
  /*Changed*/static const createChannel = "channelManage/addChannel"; ///New Add Channel Api End-point
  ///*Changed*/static const browseChannel = "search/searchUserChannel";
  /*Changed*/static const browseChannel = "channelManage/searchUserChannel";  // testing now for the channel search  --- done
  /*Changed*/static const removeFromFavorite = "favorite/removeFavoriteChat";
  /*Changed*/static const removeFromChannelFromFavorite = "favorite/removeFavoriteChannel";
  /*Changed*/static const muteUser = "muteManage/muteUser"; // done
  /*Changed*/static const unMuteUser = "muteManage/unmuteUser"; // done
  /*Changed*/static const closeConversation = "chatList/closeConversation"; // done
  /*Changed*/static const messageUnread = "chatMessageAction/unreadMessage/"; // done
  /*Changed*/static const messageSeen = "/chatMessageAction/seenMessage/";  //done
  /*Changed*/static const addTOFavorite = "favorite/addFavoriteChat";
  /*Changed*/static const leaveChannel = "channelManage/leaveChannel/"; // done
  /*Changed*/static const userSuggestions = "user/getUserSuggestions"; // done
  /*Changed*/static const searchUser = "search/searchUserChannel";   //   //done
  static const addDeviceToken = "user/deviceToken";   /// not working
  static const removeDeviceToken = "user/removeDeviceToken"; /// not working
  static const sendKarma = "api/send-karma";/// not needed


  // Chat
  /*Changed*/ static const getMessages = "chatMessage/getMessages"; // done
  /*Changed*/ static const sendMessage = "chatMessage/sendMessage"; // done


  // static const readChannelMessage = "messages/channel/channel-message-seen/";
  // static const unReadChannelMessage = "channels/message-unread/";
  /*Changed*/static const addChannelTOFavorite = "/favorite/addFavoriteChannel";
  /*Changed*/static const unMuteChannel = "muteManage/unmuteChannel"; // done
  /*Changed*/static const muteChannel = "muteManage/muteChannel"; // done
  /*Changed*/static const addUserToChatList = "chatList/addInChatList"; // done
  /*Changed*/static const sendChannelMessage = "channelMessage/sendMessage"; // done
  /*Changed*/static const deleteMessage = "chatMessageAction/deleteMessage/"; //done
  /*Changed*/static const replayMsgSeen = "reply/seenMessage/"; // done
  /*Changed*/static const getRepliesMsg = "reply/getReplies"; // done
  static const uploadFileForMessageMedia = "upload/uploadFile?file_for=message_media";//done
  /*Changed*/static const getFileListingInChat = "chatMessage/getFileList"; // done
  /*Changed*/static const getUser = "user/getUserSuggestions"; //done
  /*Changed*/static String pinMessage(String messageId, bool pinned) => "chatMessageAction/pinMessage/$messageId/$pinned";  // done
  /*Changed*/static String reactMessage = "chatMessageAction/reactionMessage";// done
  /*Changed*/static String removeReact = "chatMessageAction/removeMessageReaction";//done

  // Channel
  /*Changed*/static getChannelMembersList(String channelId) => "channelManage/getChannelMembers/$channelId"; // done
  /*Changed*/static addMembersToChannel(String channelId) => "channelManage/addMember/$channelId";
  /*Changed*/static getChannelInfo(String channelId) => "channelManage/getChannelById/$channelId";
  static readChannelMessage(String channelId) => "channelMessage/seenMessage/$channelId";  // issue the api is not getting called or might be something els
  /*Changed*/static unReadChannelMessage(String channelId) => "channelManage/unreadMessage/$channelId"; // done
  static const getChannelChat = "channelMessage/getMessages"; // done
  /*Changed*/static toggleAdminAndMember(String channelId) => "channelManage/toggleAdmin/$channelId";
  /*Changed*/static removeMember(String channelId) => "channelManage/removeMember/$channelId";
  /*Changed*/static renameChannel(String channelId) => "channelManage/editChannel/$channelId";
  /*Changed*/static const getFilesListingInChannelChat = "channelMessage/getFileList/"; //done
  /*Changed*/static const getChannelPinnedMessage = "/channelMessage/getPinnedMessages/"; // done
  // static deleteMessageFromChannel (String messageId) => "messages/delete/$messageId";
  /*Changed*/static const String addChannelTO = "channelManage/addChannel";// Done

  ///New Delete Message Api End-point`
  /*Changed*/static String deleteMessageFromChannel  (String messageId) => "chatMessageAction/deleteMessage/$messageId"; // Done
  /// New Search Message Api End-Point
  /*Changed*/ static const searchMessages = "searchMessage/search"; // Done
  ///New Message Jump Api End-point
  /*Changed*/static const messageJump = "chatMessage/getMessageJump"; // done
  ///New Get Thread Unread List api
  /*Changed*/static const getUnreadThread = "unreadThread/getUnreadThread"; // done
  ///New Get Thread list account api
  /*Changed*/ static const getUnreadThreadCounts = "unreadThread/getUnreadThreadCount"; // done
  /*Changed*/static const forgotPassword = "auth/forgotPassword";
}