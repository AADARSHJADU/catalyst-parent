import 'package:catalyst/core/constants/app_colors.dart';
import 'package:catalyst/data/models/models.dart';
import 'package:flutter/material.dart';

class WellnessMockData {
  WellnessMockData._();

  static const String profileImageUrl =
      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200';

  static const UserModel wellnessUser = UserModel(
    id: 'w1',
    name: 'Jessica Parker',
    email: 'jessica.parker@email.com',
    phone: '(555) 987-6543',
    role: 'Member',
  );

  static const activeMembership = (
    name: 'Wellness 10 Class Pass',
    remaining: 7,
    total: 10,
    expiryDate: 'Jun 15, 2025',
  );

  static const accountOverview = (
    credits: 7,
    passExpiry: 'Jun 15, 2025',
    passName: 'Wellness 10 Class Pass',
    monthlyAttendance: 4,
    lifetimeAttendance: 28,
  );

  static const List<WellnessPassModel> passes = [
    WellnessPassModel(
      id: 'pass5',
      name: '5 Class Pass',
      subtitle: 'Wellness Pass',
      price: 75,
      perClassPrice: 15,
      classesCount: 5,
      validity: 'Valid for 2 months',
    ),
    WellnessPassModel(
      id: 'pass10',
      name: '10 Class Pass',
      subtitle: 'Wellness Pass',
      price: 150,
      perClassPrice: 15,
      classesCount: 10,
      validity: 'Valid for 3 months',
      isPopular: true,
    ),
    WellnessPassModel(
      id: 'pass20',
      name: '20 Class Pass',
      subtitle: 'Wellness Pass',
      price: 250,
      perClassPrice: 12.50,
      classesCount: 20,
      validity: 'Valid for 6 months',
    ),
    WellnessPassModel(
      id: 'dropin',
      name: 'Drop-In',
      subtitle: 'Single Class',
      price: 20,
      perClassPrice: 20,
      classesCount: 1,
      validity: 'Valid for 1 day',
    ),
  ];

  static const List<String> membershipFeatures = [
    'Access to all wellness classes',
    'Easy online booking',
    'Reserve your spot in advance',
    'Use credits at any location',
  ];

  static const List<WellnessPurchaseModel> purchaseHistory = [
    WellnessPurchaseModel(
      id: 'ph1',
      passName: '10 Class Pass',
      orderNumber: '#CD12345',
      date: 'May 10, 2025',
      price: 150,
      status: 'Completed',
    ),
    WellnessPurchaseModel(
      id: 'ph2',
      passName: '5 Class Pass',
      orderNumber: '#CD12301',
      date: 'Mar 15, 2025',
      price: 75,
      status: 'Completed',
    ),
  ];

  static const List<WellnessClassModel> classes = [
    WellnessClassModel(
      id: 'w1',
      title: 'Vinyasa Flow Yoga',
      instructor: 'Inferno',
      room: 'Inferno',
      date: 'Today, May 13',
      startTime: '10:00 AM',
      endTime: '11:00 AM',
      durationMinutes: 60,
      level: 'All Levels',
      spotsLeft: 6,
      capacity: 15,
      imageUrl:
          'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=600',
      category: 'Yoga',
      period: 'Morning',
      description:
          'A dynamic vinyasa flow designed to build strength and flexibility.',
      whatToBring: ['Yoga Mat', 'Water Bottle'],
      icon: Icons.self_improvement,
    ),
    WellnessClassModel(
      id: 'w2',
      title: 'Core Pilates',
      instructor: 'Lily',
      room: 'Kindle',
      date: 'Today, May 13',
      startTime: '12:00 PM',
      endTime: '1:00 PM',
      durationMinutes: 60,
      level: 'Intermediate',
      spotsLeft: 3,
      capacity: 12,
      imageUrl:
          'https://images.unsplash.com/photo-1518611012118-696072aa579a?w=600',
      category: 'Pilates',
      period: 'Afternoon',
      description: 'Strengthen your core with controlled Pilates movements.',
      whatToBring: ['Mat', 'Water Bottle'],
      icon: Icons.accessibility_new,
    ),
    WellnessClassModel(
      id: 'w3',
      title: 'Barre Fusion',
      instructor: 'Emma',
      room: 'Inferno',
      date: 'May 14, 2025',
      startTime: '9:00 AM',
      endTime: '10:00 AM',
      durationMinutes: 60,
      level: 'All Levels',
      spotsLeft: 8,
      capacity: 15,
      imageUrl:
          'https://images.unsplash.com/photo-1599901860904-17e6ed7083a0?w=600',
      category: 'Barre',
      period: 'Morning',
      description: 'Low-impact barre workout combining ballet and strength.',
      whatToBring: ['Water Bottle'],
      icon: Icons.fitness_center,
    ),
    WellnessClassModel(
      id: 'w4',
      title: 'Hip Hop Dance',
      instructor: 'Marcus',
      room: 'Ignite',
      date: 'May 14, 2025',
      startTime: '6:00 PM',
      endTime: '7:00 PM',
      durationMinutes: 60,
      level: 'Beginner',
      spotsLeft: 4,
      capacity: 20,
      imageUrl:
          'https://images.unsplash.com/photo-1545291730-faff8ca1d4b0?w=600',
      category: 'Dance',
      period: 'Evening',
      description: 'High-energy hip hop dance class for all skill levels.',
      whatToBring: ['Water Bottle', 'Sneakers'],
      icon: Icons.music_note,
    ),
    WellnessClassModel(
      id: 'w5',
      title: 'Restorative Yoga',
      instructor: 'Sarah',
      room: 'Inferno',
      date: 'May 15, 2025',
      startTime: '7:00 PM',
      endTime: '8:00 PM',
      durationMinutes: 60,
      level: 'All Levels',
      spotsLeft: 10,
      capacity: 15,
      imageUrl:
          'https://images.unsplash.com/photo-1506126613408-eca07ce68773?w=600',
      category: 'Wellness',
      period: 'Evening',
      description: 'Gentle restorative yoga for deep relaxation.',
      whatToBring: ['Yoga Mat', 'Blanket'],
      icon: Icons.spa,
    ),
  ];

  static const List<WellnessBookingModel> upcomingBookings = [
    WellnessBookingModel(
      id: 'wb1',
      title: 'Vinyasa Flow Yoga',
      date: 'May 13, 2025',
      startTime: '10:00 AM',
      endTime: '11:00 AM',
      durationMinutes: 60,
      room: 'Inferno',
      instructor: 'Olivia',
      level: 'All Levels',
      imageUrl:
          'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=600',
      status: 'Confirmed',
      bookedFor: 'Jessica Parker',
      price: 0,
      category: 'Yoga',
      spots: 1,
    ),
    WellnessBookingModel(
      id: 'wb2',
      title: 'Core Pilates',
      date: 'May 13, 2025',
      startTime: '12:00 PM',
      endTime: '1:00 PM',
      durationMinutes: 60,
      room: 'Kindle',
      instructor: 'Lily',
      level: 'Intermediate',
      imageUrl:
          'https://images.unsplash.com/photo-1518611012118-696072aa579a?w=600',
      status: 'Waitlisted',
      bookedFor: 'Jessica Parker',
      price: 0,
      category: 'Pilates',
      spots: 1,
    ),
    WellnessBookingModel(
      id: 'wb3',
      title: 'Barre Fusion',
      date: 'May 14, 2025',
      startTime: '9:00 AM',
      endTime: '10:00 AM',
      durationMinutes: 60,
      room: 'Inferno',
      instructor: 'Emma',
      level: 'All Levels',
      imageUrl:
          'https://images.unsplash.com/photo-1599901860904-17e6ed7083a0?w=600',
      status: 'Confirmed',
      bookedFor: 'Jessica Parker',
      price: 0,
      category: 'Barre',
      spots: 1,
    ),
    WellnessBookingModel(
      id: 'wb4',
      title: 'Hip Hop Dance',
      date: 'May 14, 2025',
      startTime: '6:00 PM',
      endTime: '7:00 PM',
      durationMinutes: 60,
      room: 'Ignite',
      instructor: 'Marcus',
      level: 'Beginner',
      imageUrl:
          'https://images.unsplash.com/photo-1545291730-faff8ca1d4b0?w=600',
      status: 'Confirmed',
      bookedFor: 'Jessica Parker',
      price: 0,
      category: 'Dance',
      spots: 1,
    ),
  ];

  static const List<WellnessBookingModel> pastBookings = [
    WellnessBookingModel(
      id: 'wb5',
      title: 'Restorative Yoga',
      date: 'May 5, 2025',
      startTime: '7:00 PM',
      endTime: '8:00 PM',
      durationMinutes: 60,
      room: 'Ignite',
      instructor: 'Sarah',
      level: 'All Levels',
      imageUrl:
          'https://images.unsplash.com/photo-1506126613408-eca07ce68773?w=600',
      status: 'Completed',
      bookedFor: 'Jessica Parker',
      price: 0,
      category: 'Wellness',
      spots: 1,
      isPast: true,
    ),
  ];

  static const List<Map<String, dynamic>> browseCategories = [
    {'name': 'Yoga', 'classes': 12, 'icon': Icons.self_improvement},
    {'name': 'Pilates', 'classes': 8, 'icon': Icons.accessibility_new},
    {'name': 'Barre', 'classes': 6, 'icon': Icons.fitness_center},
    {'name': 'Dance', 'classes': 10, 'icon': Icons.music_note},
  ];

  static const List<String> classFilterCategories = [
    'All Classes',
    'Yoga',
    'Pilates',
    'Barre',
    'Dance',
    'Wellness',
  ];

  static const taxRate = 0.10;
  static const orderNumber = '#CD12345';
  static const orderDate = 'May 10, 2025';
  static const paymentMethod = 'Visa •••• 4242';
}

class RoutinesMockData {
  RoutinesMockData._();

  static const List<RoutineModel> routines = [
    RoutineModel(
      id: 'r1',
      name: 'Lyrical Solo',
      song: 'A Thousand Years',
      duration: '2:45',
      category: 'Lyrical',
      imageUrl:
          'https://images.unsplash.com/photo-1508700110922-4b9034aecaeb?w=600',
      isCompleted: false,
      focus: 'Expression, musicality, and lyrical movement quality.',
      level: 'Intermediate',
      choreographer: 'Miss Sarah',
      performanceDate: 'May 24 – Showcase',
      lastUpdated: 'Jan 15, 2025',
      musicUrl: 'https://example.com/music/thousand-years.mp3',
      spotlightColor: Color(0xFF9C27B0),
    ),
    RoutineModel(
      id: 'r2',
      name: 'Jazz Group',
      song: 'Uptown Funk',
      duration: '3:10',
      category: 'Jazz',
      imageUrl:
          'https://images.unsplash.com/photo-1518834107812-67b0b7c58434?w=600',
      isCompleted: false,
      focus: 'Sharp isolations, energy, and group synchronization.',
      level: 'Advanced',
      choreographer: 'Mr. Marcus',
      performanceDate: 'Jun 1 – Competition',
      lastUpdated: 'Feb 3, 2025',
      musicUrl: 'https://example.com/music/uptown-funk.mp3',
      spotlightColor: AppColors.primary,
    ),
    RoutineModel(
      id: 'r3',
      name: 'Ballet Variation',
      song: 'Swan Lake Excerpt',
      duration: '2:30',
      category: 'Ballet',
      imageUrl:
          'https://images.unsplash.com/photo-1547159414-56c4b7d90272?w=600',
      isCompleted: false,
      focus: 'Classical technique, port de bras, and pointe work.',
      level: 'Intermediate',
      choreographer: 'Miss Rachel',
      performanceDate: 'May 24 – Showcase',
      lastUpdated: 'Jan 20, 2025',
      musicUrl: 'https://example.com/music/swan-lake.mp3',
      spotlightColor: Color(0xFF42A5F5),
    ),
    RoutineModel(
      id: 'r4',
      name: 'Hip Hop Duo',
      song: 'Industry Baby',
      duration: '2:55',
      category: 'Hip Hop',
      imageUrl:
          'https://images.unsplash.com/photo-1545291730-faff8ca1d4b0?w=600',
      isCompleted: false,
      focus: 'Grooves, tricks, and partner work.',
      level: 'Advanced',
      choreographer: 'Mr. Marcus',
      performanceDate: 'Jun 1 – Competition',
      lastUpdated: 'Feb 10, 2025',
      musicUrl: 'https://example.com/music/industry-baby.mp3',
      spotlightColor: Color(0xFF4CAF50),
    ),
    RoutineModel(
      id: 'r5',
      name: 'Tap Solo',
      song: 'Sing Sing Sing',
      duration: '2:20',
      category: 'Tap',
      imageUrl:
          'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=600',
      isCompleted: false,
      focus: 'Rhythm, clarity, and speed combinations.',
      level: 'Intermediate',
      choreographer: 'Miss Lily',
      performanceDate: 'May 24 – Showcase',
      lastUpdated: 'Jan 28, 2025',
      musicUrl: 'https://example.com/music/sing-sing-sing.mp3',
      spotlightColor: Color(0xFFEC407A),
    ),
    RoutineModel(
      id: 'r6',
      name: 'Contemporary Solo',
      song: 'Fix You',
      duration: '3:00',
      category: 'Contemporary',
      imageUrl:
          'https://images.unsplash.com/photo-1459749411175-04bf8532d0cc?w=600',
      isCompleted: true,
      focus: 'Floor work, emotion, and fluid transitions.',
      level: 'Advanced',
      choreographer: 'Miss Sarah',
      performanceDate: 'Apr 12 – Recital',
      lastUpdated: 'Dec 5, 2024',
      musicUrl: 'https://example.com/music/fix-you.mp3',
      spotlightColor: Color(0xFF7E57C2),
    ),
    RoutineModel(
      id: 'r7',
      name: 'Jazz Funk',
      song: 'Levitating',
      duration: '2:50',
      category: 'Jazz',
      imageUrl:
          'https://images.unsplash.com/photo-1504609773869-104da2a2a620?w=600',
      isCompleted: true,
      focus: 'Commercial jazz style and performance quality.',
      level: 'Intermediate',
      choreographer: 'Mr. Marcus',
      performanceDate: 'Apr 12 – Recital',
      lastUpdated: 'Nov 20, 2024',
      musicUrl: 'https://example.com/music/levitating.mp3',
      spotlightColor: AppColors.primary,
    ),
  ];
}
