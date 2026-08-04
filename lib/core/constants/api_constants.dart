/// All API endpoints and base URL in one place.
/// Change [baseUrl] to switch environments.
abstract class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'http://192.168.1.14:8080/api/v1';
  //static const String baseUrl = 'https://darksalmon-dragonfly-928313.hostingersite.com/api/v1';

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

  // ── Private Booking ───────────────────────────────────────────────────────
  static const String privateBookingDanceStyles =
      '/parent/private-booking/dance-styles';
  static const String privateBookingInstructors =
      '/parent/private-booking/instructors';
  static String privateBookingAvailability(int instructorId) =>
      '/parent/private-booking/instructors/$instructorId/availability';
  static const String privateBookingCalculatePrice =
      '/parent/private-booking/calculate-price';
  static const String privateBookingRequestClass =
      '/parent/private-booking/request-class';
  static const String privateBookingCheckout =
      '/parent/private-booking/checkout';
  static const String privateBookingCapture =
      '/parent/private-booking/capture';
  static const String privateBookingPaypalCapture =
      '/parent/private-booking/paypal-capture';
  static const String privateBookingMyBookings =
      '/parent/private-booking/my-bookings';
  static const String privateBookingHistory =
      '/parent/private-booking/history';
  static String privateBookingLessonCheckout(int lessonId) =>
      '/parent/private-booking/$lessonId/checkout';
  static String privateBookingLessonCapture(int lessonId) =>
      '/parent/private-booking/$lessonId/capture';
  static const String paymentMethods =
      '/parent/settings/payment-methods';
  static const String registrationFee =
      '/parent/settings/registration-fee';

  // ── Student Progress & Analytics ────────────────────────────────────────
  static String studentEvaluations(int studentId) =>
      '/parent/progress/student/$studentId/evaluations';
  static String studentFeedback(int studentId) =>
      '/parent/progress/student/$studentId/feedback';
  static String studentAttendance(int studentId) =>
      '/parent/attendance/student/$studentId';

  // ── Bookings History ──────────────────────────────────────────────────────
  static const String classBookingHistory =
      '/parent/class-booking/history';
  static const String choreographyBookingHistory =
      '/parent/choreography-booking/history';
  static const String privateBookingHistoryEndpoint =
      '/parent/private-booking/history';
  static String classBookingDetails(int classId) =>
      '/parent/class-booking/details/$classId';

  // ── Regular Class Booking ─────────────────────────────────────────────────
  static const String regularClasses = '/parent/class-booking/classes';
  static const String regularClassCheckout = '/parent/class-booking/checkout';
  static const String regularClassCapture = '/parent/class-booking/capture';
  static const String regularClassPaypalCapture = '/parent/class-booking/paypal-capture';
  static const String regularClassPayLater = '/parent/class-booking/pay-later';
  static const String regularClassMyBookings = '/parent/class-booking/my-bookings';
  static String regularClassDetail(int classId) => '/parent/class-booking/details/$classId';
  static String dropEnrollment(int id) => '/parent/enrollment/regular/$id';
  static String payClassInvoice(int id) => '/parent/payments/class/$id/pay';

  // ── Choreography Booking ──────────────────────────────────────────────────
  static const String choreographyList = '/parent/choreography-booking';
  static const String choreographyCheckout =
      '/parent/choreography-booking/checkout';
  static const String choreographyCapture =
      '/parent/choreography-booking/capture';
  static const String choreographyPaypalCapture =
      '/parent/choreography-booking/paypal-capture';
  static const String choreographyPayLater =
      '/parent/choreography-booking/pay-later';
  static const String choreographyHistory =
      '/parent/choreography-booking/history';

  // ── Schedule ──────────────────────────────────────────────────────────────
  static const String myEnrollments = '/parent/enrollment/my-enrollments';
  static const String wellnessSchedule = '/parent/schedule/wellness';
  static const String studiosList = '/admin/studios';

  // ── Wellness ──────────────────────────────────────────────────────────────
  static const String wellnessClasses = '/parent/wellness/classes';
  static const String wellnessBookClass = '/parent/wellness/classes/book';
  static const String wellnessDropinCheckout =
      '/parent/wellness/classes/dropin-checkout';
  static const String wellnessDropinConfirm =
      '/parent/wellness/classes/dropin-confirm';
  static const String wellnessCancelBooking =
      '/parent/wellness/classes/cancel-booking';
  static const String wellnessMyBookings =
      '/parent/wellness/classes/my-bookings';
  static const String wellnessProducts =
      '/parent/wellness-membership/products';
  static const String wellnessMembershipCheckout =
      '/parent/wellness-membership/checkout';
  static const String wellnessMembershipCapture =
      '/parent/wellness-membership/capture';
  static const String wellnessMyMemberships =
      '/parent/wellness-membership/my-memberships';

  // ── Routines ──────────────────────────────────────────────────────────────
  static String routinePayment(int paymentId) =>
      '/parent/payments/routine/$paymentId/pay';
  static const String routineEnroll = '/parent/enrollment/routine';
  static const String paymentsCapture = '/parent/payments/capture';

  // ── Competitions & Events ─────────────────────────────────────────────────
  static const String competitions = '/parent/events/competitions';
  static const String myRegistrations = '/parent/events/my-registrations';
  static String competitionSchedule(int id) =>
      '/parent/events/competition/$id/schedule';
  static const String pastResults = '/parent/events/past-results';
  static String competitionPayment(int id) =>
      '/parent/payments/competition/$id/pay';

  // ── Timeouts ──────────────────────────────────────────────────────────────
  static const int connectTimeoutMs = 15000;
  static const int receiveTimeoutMs = 15000;

  // ── Dashboard ─────────────────────────────────────────────────────────────
  static const String parentDashboard = '/parent/dashboard';
}
