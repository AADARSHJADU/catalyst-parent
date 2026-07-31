/// All API endpoints and base URL in one place.
/// Change [baseUrl] to switch environments.
abstract class ApiConstants {
  ApiConstants._();

  static const String baseUrl =
      'https://darksalmon-dragonfly-928313.hostingersite.com/api/v1';

  // ── Auth ──────────────────────────────────────────────────────────────────
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String profile = '/auth/profile';
  static const String forgotPassword = '/auth/forgot-password';
  static const String verifyOtp = '/auth/verify-otp';
  static const String resetPassword = '/auth/reset-password';
  static const String fcmToken = '/auth/fcm-token';

  // ── Parent / Settings ────────────────────────────────────────────────────
  static const String parentProfile = '/parent/profile';
  static const String relationships = '/common/relationships';
  static const String languages = '/common/languages';
  static const String changePassword = '/auth/change-password';

  // ── Notifications ─────────────────────────────────────────────────────────
  static const String notifications = '/notifications/web';
  static const String markAllNotificationsRead = '/notifications/web/read-all';

  // ── Students ──────────────────────────────────────────────────────────────
  static const String parentStudents = '/parent/students';
  static const String ageGroups = '/admin/age-groups';
  static const String skillLevels = '/admin/skill-levels';
  static const String danceStyles = '/admin/dance-styles';
  static const String studios = '/admin/studios';

  // ── Documents ─────────────────────────────────────────────────────────────
  static const String parentDocuments = '/parent/documents';

  // ── Billing ───────────────────────────────────────────────────────────────
  static const String parentBilling = '/parent/billing';

  // ── Announcements ─────────────────────────────────────────────────────────
  static const String announcements = '/announcements';

  // ── Messages / Chat ───────────────────────────────────────────────────────
  static const String socketUrl =
      'https://darksalmon-dragonfly-928313.hostingersite.com';
  static const String conversations = '/messages/conversations';
  static const String conversationsUnreadCount =
      '/messages/conversations/unread-count';
  static const String messageUsers = '/messages/users';

  static String conversationMessages(String id) =>
      '/messages/conversations/$id/messages';
  static String markConversationRead(String id) =>
      '/messages/conversations/$id/messages/read';
  static String archiveConversation(String id) =>
      '/messages/conversations/$id/archive';
  static String conversationMembers(String id) =>
      '/messages/conversations/$id/members';
  static String conversationMember(String convId, String userId) =>
      '/messages/conversations/$convId/members/$userId';
  static String conversationMemberRole(String convId, String userId) =>
      '/messages/conversations/$convId/members/$userId/role';

  // ── Timeouts ──────────────────────────────────────────────────────────────
  static const int connectTimeoutMs = 15000;
  static const int receiveTimeoutMs = 15000;
}
