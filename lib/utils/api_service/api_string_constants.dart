class ApiString{



  static const String baseUrl= 'https://dev-econnect-sass.elsnerdev.co/v1/'; /// THIS NEW DEVELOPMENT URL
  static const String profileBaseUrl = 'https://dev-econnect-sass.elsnerdev.co/'; /// Profile Image

  //static const String baseUrl = 'https://e-connect.elsner.com/v1/'; /// THIS LIVE URL
  // static const String profileBaseUrl = 'https://e-connect.elsner.com/public/'; /// Profile Image

  // static const String karmaBaseUrl = "https://dev-hrms.elsner.com/";
  static const String karmaBaseUrl = "https://hrms.elsner.com/";

  static const getAppVersion = "updateFCM_Mobile/get";

  /// End Point , Don't Change Belows End Point until didn't confirm through backend ///
  static const login = "auth/userLogin"; ///New Login End point
  static const googleSignIn = "user/googleSSOLginApp";
  static const allowGoogleSignIN = "user/alloawgoogleSSOLogin";
  static const updateStatus = "user/updateUserDetails"; ///New User update api end-point
  static const getUserById = "user/getUserDetails"; ///New Get UserDetails Api end-point
  /*Changed*/static const favoriteListGet = "favorite/getFavoriteChatList";
  static const String channelList="channelManage/getChannel";  ///New Get Channel List Api End-Point
  /*Changed*/static const directMessageChatList = "chatList/getChatList";
  static const createChannel = "channelManage/addChannel"; ///New Add Channel Api End-point
  /*Changed*/static const browseChannel = "search/searchUserChannel";
  /*Changed*/static const removeFromFavorite = "favorite/removeFavoriteChat";
  /*Changed*/static const removeFromChannelFromFavorite = "favorite/removeFavoriteChannel";
  static const muteUser = "user/mute-user";
  static const unMuteUser = "user/unmute-user";
  static const closeConversation = "chatList/close-conversation";
  static const messageUnread = "messages/message-unread/";
  static const messageSeen = "messages/message-seen/";
  /*Changed*/static const addTOFavorite = "favorite/addFavoriteChat";
  static const leaveChannel = "channels/leaveChannel/";
  static const userSuggestions = "user/user-suggestions";
  static const searchUser = "user/search-user";
  static const addDeviceToken = "user/deviceToken";
  static const removeDeviceToken = "user/removeDeviceToken";
  static const sendKarma = "api/send-karma";
  // Chat

  static const getMessages = "messages/get-message";
  // static const readChannelMessage = "messages/channel/channel-message-seen/";
  // static const unReadChannelMessage = "channels/message-unread/";
  /*Changed*/static const addChannelTOFavorite = "/favorite/addFavoriteChannel";
  /*Changed*/static const unMuteChannel = "muteManage/unmuteChannel";
  /*Changed*/static const muteChannel = "muteManage/muteChannel";
  static const addUserToChatList = "chatList/add";
  static const sendMessage = "messages/send-message";
  static const sendChannelMessage = "messages/channel/send-message";
  static const deleteMessage = "messages/delete/";
  static const replayMsgSeen = "messages/reply-message-seen";
  static const getRepliesMsg = "messages/get-replies";
  static const uploadFileForMessageMedia = "files/upload?file_for=message_media";
  static const getFileListingInChat = "messages/getFilesListing";
  static const getUser = "user/getUsers";
  static String pinMessage(String messageId, bool pinned) => "messages/message-pin/$messageId/$pinned";
  static String reactMessage = "messages/message-reaction";
  static String removeReact = "messages/message-reaction-remove";

  // Channel
  /*Changed*/static getChannelMembersList(String channelId) => "channelManage/getChannelMembers/$channelId";
  /*Changed*/static addMembersToChannel(String channelId) => "channelManage/addMember/$channelId";
  /*Changed*/static getChannelInfo(String channelId) => "channelManage/getChannelById/$channelId";
  static readChannelMessage(String channelId) => "channelMessage/seenMessage/$channelId";
  /*Changed*/static unReadChannelMessage(String channelId) => "channelManage/unreadMessage/$channelId";
  static const getChannelChat = "channelMessage/getMessages";
  /*Changed*/static toggleAdminAndMember(String channelId) => "channelManage/toggleAdmin/$channelId";
  /*Changed*/static removeMember(String channelId, String memberId) => "channelManage/removeMember/$channelId/$memberId";
  /*Changed*/static renameChannel(String channelId) => "channelManage/editChannel/$channelId";
  static const getFilesListingInChannelChat = "messages/channel/getFilesListingForChannel";
  static const getChannelPinnedMessage = "messages/channel/get-pinned-message-for-channel";
  // static deleteMessageFromChannel (String messageId) => "messages/delete/$messageId";
  static const String addChannelTO = "channels/add";

  ///New Delete Message Api End-point`
  /*Changed*/static String deleteMessageFromChannel  (String messageId) => "chatMessageAction/deleteMessage/$messageId";
  /// New Search Message Api End-Point
  static const searchMessages = "searchMessage/search";
  ///New Message Jump Api End-point
  static const messageJump = "chatMessage/getMessageJump";
  ///New Get Thread Unread List api
  static const getUnreadThread = "unreadThread/getUnreadThread";
  ///New Get Thread list account api
  static const getUnreadThreadCounts = "unreadThread/getUnreadThreadCount";
  /*Changed*/static const forgotPassword = "auth/forgtpassword";
}