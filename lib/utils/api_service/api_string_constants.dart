class ApiString{



  static const String baseUrl= 'https://dev-econnect-sass.elsnerdev.co/v1/'; /// THIS NEW DEVELOPMENT URL
  static const String profileBaseUrl = 'https://dev-econnect-sass.elsnerdev.co/'; /// Profile Image

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
  /*Changed*/static const directMessageChatList = "chatList/getChatList";
  /*Changed*/static const createChannel = "channelManage/addChannel"; ///New Add Channel Api End-point
  /*Changed*/static const browseChannel = "search/searchUserChannel";
  /*Changed*/static const removeFromFavorite = "favorite/removeFavoriteChat";
  /*Changed*/static const removeFromChannelFromFavorite = "favorite/removeFavoriteChannel";
  /*Changed*/static const muteUser = "muteManage/muteUser"; // done
  /*Changed*/static const unMuteUser = "muteManage/unmuteUser"; // done
  /*Changed*/static const closeConversation = "chatList/closeConversation";// done
  /*Changed*/static const messageUnread = "chatMessageAction/unreadMessage"; // done
  /*Changed*/static const messageSeen = "/chatMessageAction/seenMessage/";  //need to confirm
  /*Changed*/static const addTOFavorite = "favorite/addFavoriteChat";
  /*Changed*/static const leaveChannel = "channelManage/leaveChannel/"; // done
  static const userSuggestions = "user/user-suggestions";
  static const searchUser = "user/search-user";
  static const addDeviceToken = "user/deviceToken";
  static const removeDeviceToken = "user/removeDeviceToken";
  static const sendKarma = "api/send-karma";


  // Chat
  /*Changed*/ static const getMessages = "chatMessage/getMessages"; // need to check
  /*Changed*/ static const sendMessage = "chatMessage/sendMessage";


  // static const readChannelMessage = "messages/channel/channel-message-seen/";
  // static const unReadChannelMessage = "channels/message-unread/";
  /*Changed*/static const addChannelTOFavorite = "/favorite/addFavoriteChannel";
  /*Changed*/static const unMuteChannel = "muteManage/unmuteChannel";
  /*Changed*/static const muteChannel = "muteManage/muteChannel";
  /*Changed*/static const addUserToChatList = "chatList/addInChatList"; // just need to check
  static const sendChannelMessage = "messages/channel/send-message";
  /*Changed*/static const deleteMessage = "chatMessageAction/deleteMessage/"; //done
  static const replayMsgSeen = "messages/reply-message-seen";
  static const getRepliesMsg = "messages/get-replies";
  static const uploadFileForMessageMedia = "files/upload?file_for=message_media";
  static const getFileListingInChat = "messages/getFilesListing";
  /*Changed*/static const getUser = "user/getUserSuggestions";
  static String pinMessage(String messageId, bool pinned) => "messages/message-pin/$messageId/$pinned";
  static String reactMessage = "messages/message-reaction";
  static String removeReact = "messages/message-reaction-remove";

  // Channel
  /*Changed*/static getChannelMembersList(String channelId) => "channelManage/getChannelMembers/$channelId";
  /*Changed*/static addMembersToChannel(String channelId) => "channelManage/addMember/$channelId";
  /*Changed*/static getChannelInfo(String channelId) => "channelManage/getChannelById/$channelId";
  static readChannelMessage(String channelId) => "channelMessage/seenMessage/$channelId";
  /*Changed*/static unReadChannelMessage(String channelId) => "channelManage/unreadMessage/$channelId"; // done
  static const getChannelChat = "channelMessage/getMessages";
  /*Changed*/static toggleAdminAndMember(String channelId) => "channelManage/toggleAdmin/$channelId";
  /*Changed*/static removeMember(String channelId, String memberId) => "channelManage/removeMember/$channelId/$memberId";
  /*Changed*/static renameChannel(String channelId) => "channelManage/editChannel/$channelId";
  static const getFilesListingInChannelChat = "messages/channel/getFilesListingForChannel";
  static const getChannelPinnedMessage = "messages/channel/get-pinned-message-for-channel";
  // static deleteMessageFromChannel (String messageId) => "messages/delete/$messageId";
  /*Changed*/static const String addChannelTO = "channelManage/addChannel";// need to check

  ///New Delete Message Api End-point`
  /*Changed*/static String deleteMessageFromChannel  (String messageId) => "chatMessageAction/deleteMessage/$messageId";
  /// New Search Message Api End-Point
  /*Changed*/ static const searchMessages = "searchMessage/search"; // need to check
  ///New Message Jump Api End-point
  /*Changed*/static const messageJump = "chatMessage/getMessageJump"; // need to check
  ///New Get Thread Unread List api
  /*Changed*/static const getUnreadThread = "unreadThread/getUnreadThread"; // need to check
  ///New Get Thread list account api
  static const getUnreadThreadCounts = "unreadThread/getUnreadThreadCount"; // need to check
  /*Changed*/static const forgotPassword = "auth/forgtpassword";
}