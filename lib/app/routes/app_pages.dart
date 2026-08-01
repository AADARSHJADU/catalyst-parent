import 'package:catalyst/app/routes/app_routes.dart';
import 'package:catalyst/app/theme/app_theme.dart';
import 'package:catalyst/core/constants/app_strings.dart';
import 'package:catalyst/modules/auth/bindings/auth_binding.dart';
import 'package:catalyst/modules/auth/views/forgot_password_view.dart';
import 'package:catalyst/modules/auth/views/verify_otp_view.dart';
import 'package:catalyst/modules/auth/views/reset_password_view.dart';
import 'package:catalyst/modules/auth/views/login_view.dart';
import 'package:catalyst/modules/auth/views/register_view.dart';
import 'package:catalyst/modules/bookings/bindings/bookings_binding.dart';
import 'package:catalyst/modules/bookings/views/booking_detail_view.dart';
import 'package:catalyst/modules/family/bindings/family_binding.dart';
import 'package:catalyst/modules/family/views/family_view.dart';
import 'package:catalyst/modules/main/bindings/main_binding.dart';
import 'package:catalyst/modules/main/views/main_view.dart';
import 'package:catalyst/modules/student_profile/bindings/student_profile_binding.dart';
import 'package:catalyst/modules/student_profile/views/student_profile_view.dart';
import 'package:catalyst/modules/documents/bindings/documents_binding.dart';
import 'package:catalyst/modules/announcements/bindings/announcements_binding.dart';
import 'package:catalyst/modules/announcements/views/announcements_view.dart';
import 'package:catalyst/modules/messages/bindings/messages_binding.dart';
import 'package:catalyst/modules/messages/views/chat_view.dart';
import 'package:catalyst/modules/messages/views/group_info_view.dart';
import 'package:catalyst/modules/messages/views/new_chat_view.dart';
import 'package:catalyst/modules/notifications/bindings/notifications_binding.dart';
import 'package:catalyst/modules/notifications/views/notifications_view.dart';
import 'package:catalyst/modules/payments/bindings/payments_binding.dart';
import 'package:catalyst/modules/payments/views/payments_view.dart';
import 'package:catalyst/modules/private_lessons/bindings/private_lessons_binding.dart';
import 'package:catalyst/modules/private_lessons/views/book_lesson_view.dart';
import 'package:catalyst/modules/private_lessons/views/lesson_history_view.dart';
import 'package:catalyst/modules/private_lessons/views/private_lesson_detail_view.dart';
import 'package:catalyst/modules/private_lessons/views/private_lessons_view.dart';
import 'package:catalyst/modules/profile/bindings/profile_binding.dart';
import 'package:catalyst/modules/profile/views/profile_view.dart';
import 'package:catalyst/modules/profile/views/settings_view.dart';
import 'package:catalyst/modules/student_progress/bindings/student_progress_binding.dart';
import 'package:catalyst/modules/student_progress/views/student_progress_view.dart';
import 'package:catalyst/modules/competitions/views/competitions_view.dart';
import 'package:catalyst/modules/documents/views/documents_view.dart';
import 'package:catalyst/modules/schedule/bindings/schedule_binding.dart';
import 'package:catalyst/modules/schedule/views/book_class_view.dart';
import 'package:catalyst/modules/schedule/views/class_detail_view.dart';
import 'package:catalyst/modules/schedule/views/class_schedule_view.dart';
import 'package:catalyst/modules/schedule/views/instructor_detail_view.dart';
import 'package:catalyst/modules/splash/bindings/splash_binding.dart';
import 'package:catalyst/modules/splash/views/splash_view.dart';
import 'package:catalyst/modules/routines/bindings/routines_binding.dart';
import 'package:catalyst/modules/routines/views/routine_detail_view.dart';
import 'package:catalyst/modules/routines/views/routines_list_view.dart';
import 'package:catalyst/modules/wellness/bindings/wellness_binding.dart';
import 'package:catalyst/modules/wellness/views/wellness_checkout_view.dart';
import 'package:catalyst/modules/wellness/views/wellness_confirmation_view.dart';
import 'package:catalyst/modules/wellness/views/wellness_main_view.dart';
import 'package:catalyst/modules/wellness/views/wellness_payment_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppPages {
  AppPages._();

  static const initial = AppRoutes.splash;

  static final routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.verifyOtp,
      page: () => const VerifyOtpView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.resetPassword,
      page: () => const ResetPasswordView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.main,
      page: () => const MainView(),
      binding: MainBinding(),
    ),
    GetPage(
      name: AppRoutes.classSchedule,
      page: () => const ClassScheduleView(),
      binding: ScheduleBinding(),
    ),
    GetPage(
      name: AppRoutes.classDetail,
      page: () => const ClassDetailView(),
      binding: ScheduleBinding(),
    ),
    GetPage(
      name: AppRoutes.bookClass,
      page: () => const BookClassView(),
      binding: ScheduleBinding(),
    ),
    GetPage(
      name: AppRoutes.instructorDetail,
      page: () => const InstructorDetailView(),
      binding: ScheduleBinding(),
    ),
    GetPage(
      name: AppRoutes.privateLessons,
      page: () => const PrivateLessonsView(),
      binding: PrivateLessonsBinding(),
    ),
    GetPage(
      name: AppRoutes.privateLessonDetail,
      page: () => const PrivateLessonDetailView(),
      binding: PrivateLessonsBinding(),
    ),
    GetPage(
      name: AppRoutes.lessonHistory,
      page: () => const LessonHistoryView(),
      binding: PrivateLessonsBinding(),
    ),
    GetPage(
      name: AppRoutes.bookLesson,
      page: () => const BookLessonView(),
      binding: PrivateLessonsBinding(),
    ),
    GetPage(
      name: AppRoutes.family,
      page: () => const FamilyView(),
      binding: FamilyBinding(),
    ),
    GetPage(
      name: AppRoutes.payments,
      page: () => const PaymentsView(),
      binding: PaymentsBinding(),
    ),
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationsView(),
      binding: NotificationsBinding(),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.studentProfile,
      page: () => const StudentProfileView(),
      binding: StudentProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.studentProgress,
      page: () => const StudentProgressView(),
      binding: StudentProgressBinding(),
    ),
    GetPage(
      name: AppRoutes.competitions,
      page: () => const CompetitionsView(),
    ),
    GetPage(
      name: AppRoutes.documents,
      page: () => const DocumentsView(),
      binding: DocumentsBinding(),
    ),
    GetPage(
      name: AppRoutes.bookingDetail,
      page: () => const BookingDetailView(),
      binding: BookingsBinding(),
    ),
    GetPage(
      name: AppRoutes.routines,
      page: () => const RoutinesListView(),
      binding: RoutinesBinding(),
    ),
    GetPage(
      name: AppRoutes.routineDetail,
      page: () => const RoutineDetailView(),
      binding: RoutinesBinding(),
    ),
    GetPage(
      name: AppRoutes.announcements,
      page: () => const AnnouncementsView(),
      binding: AnnouncementsBinding(),
    ),
    GetPage(
      name: AppRoutes.chat,
      page: () => const ChatView(),
      binding: MessagesBinding(),
    ),
    GetPage(
      name: AppRoutes.newChat,
      page: () => const NewChatView(),
      binding: MessagesBinding(),
    ),
    GetPage(
      name: AppRoutes.groupInfo,
      page: () => const GroupInfoView(),
      binding: MessagesBinding(),
    ),
    GetPage(
      name: AppRoutes.wellness,
      page: () => const WellnessMainView(),
      binding: WellnessBinding(),
    ),
    GetPage(
      name: AppRoutes.wellnessCheckout,
      page: () => const WellnessCheckoutView(),
      binding: WellnessBinding(),
    ),
    GetPage(
      name: AppRoutes.wellnessPayment,
      page: () => const WellnessPaymentView(),
      binding: WellnessBinding(),
    ),
    GetPage(
      name: AppRoutes.wellnessBookingConfirmed,
      page: () => const WellnessConfirmationView(),
      binding: WellnessBinding(),
    ),
  ];
}

class CatalystApp extends StatelessWidget {
  const CatalystApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      defaultTransition: Transition.cupertino,
    );
  }
}
