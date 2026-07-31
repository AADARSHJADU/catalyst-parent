import 'package:flutter/material.dart';

class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
  });

  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
}

class DancerModel {
  const DancerModel({
    required this.id,
    required this.name,
    required this.age,
    required this.level,
    required this.programs,
    this.avatarInitials,
  });

  final String id;
  final String name;
  final int age;
  final String level;
  final List<String> programs;
  final String? avatarInitials;
}

class ClassScheduleModel {
  const ClassScheduleModel({
    required this.id,
    required this.title,
    required this.instructor,
    required this.room,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.level,
    required this.spotsLeft,
    required this.capacity,
    this.danceStyle = '',
    this.ageRange = '',
    this.fullDate = '',
    this.timezone = 'CDT',
    this.classType = 'Group Class',
    this.durationMinutes = 60,
    this.description = '',
    this.isRecurring = false,
    this.recurringNote = '',
  });

  final String id;
  final String title;
  final String instructor;
  final String room;
  final String day;
  final String startTime;
  final String endTime;
  final String level;
  final int spotsLeft;
  final int capacity;
  final String danceStyle;
  final String ageRange;
  final String fullDate;
  final String timezone;
  final String classType;
  final int durationMinutes;
  final String description;
  final bool isRecurring;
  final String recurringNote;

  int get enrolled => capacity - spotsLeft;
}

class PrivateLessonModel {
  const PrivateLessonModel({
    required this.id,
    required this.title,
    required this.student,
    required this.instructor,
    required this.studio,
    required this.durationMins,
    required this.month,
    required this.dayNum,
    required this.dayName,
    required this.time,
    required this.status,
    this.isPast = false,
    this.fullDate = '',
    this.notes = '',
    this.lessonType = 'Private Lesson',
    this.focusAreas = const [],
  });

  final String id;
  final String title;
  final String student;
  final String instructor;
  final String studio;
  final int durationMins;
  final String month;
  final String dayNum;
  final String dayName;
  final String time;
  final String status;
  final bool isPast;
  final String fullDate;
  final String notes;
  final String lessonType;
  final List<String> focusAreas;
}

class BookingModel {
  const BookingModel({
    required this.id,
    required this.title,
    required this.type,
    required this.date,
    required this.time,
    required this.instructor,
    required this.status,
    required this.dancerName,
  });

  final String id;
  final String title;
  final String type;
  final String date;
  final String time;
  final String instructor;
  final String status;
  final String dancerName;
}

class InstructorModel {
  const InstructorModel({
    required this.id,
    required this.name,
    required this.specialty,
    required this.hourlyRate,
    required this.rating,
    required this.availableSlots,
    this.reviewCount = 0,
    this.bio = '',
    this.experience = '',
    this.styles = const [],
    this.certifications = const [],
    this.totalStudents = 0,
    this.classesPerWeek = 0,
    this.yearsExperience = 0,
  });

  final String id;
  final String name;
  final String specialty;
  final double hourlyRate;
  final double rating;
  final List<String> availableSlots;
  final int reviewCount;
  final String bio;
  final String experience;
  final List<String> styles;
  final List<String> certifications;
  final int totalStudents;
  final int classesPerWeek;
  final int yearsExperience;
}

class PaymentModel {
  const PaymentModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.dueDate,
    required this.status,
    required this.type,
  });

  final String id;
  final String title;
  final double amount;
  final String dueDate;
  final String status;
  final String type;
}

class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.type,
    required this.isRead,
  });

  final String id;
  final String title;
  final String message;
  final String time;
  final String type;
  final bool isRead;
}

class RoutineModel {
  const RoutineModel({
    required this.id,
    required this.name,
    required this.song,
    required this.duration,
    required this.category,
    required this.imageUrl,
    required this.isCompleted,
    required this.focus,
    required this.level,
    required this.choreographer,
    required this.performanceDate,
    required this.lastUpdated,
    required this.musicUrl,
    required this.spotlightColor,
  });

  final String id;
  final String name;
  final String song;
  final String duration;
  final String category;
  final String imageUrl;
  final bool isCompleted;
  final String focus;
  final String level;
  final String choreographer;
  final String performanceDate;
  final String lastUpdated;
  final String musicUrl;
  final Color spotlightColor;
}

class WellnessClassModel {
  const WellnessClassModel({
    required this.id,
    required this.title,
    required this.instructor,
    required this.room,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    required this.level,
    required this.spotsLeft,
    required this.capacity,
    required this.imageUrl,
    required this.category,
    required this.period,
    required this.description,
    required this.whatToBring,
    required this.icon,
    this.isFavorite = false,
  });

  final String id;
  final String title;
  final String instructor;
  final String room;
  final String date;
  final String startTime;
  final String endTime;
  final int durationMinutes;
  final String level;
  final int spotsLeft;
  final int capacity;
  final String imageUrl;
  final String category;
  final String period;
  final String description;
  final List<String> whatToBring;
  final IconData icon;
  final bool isFavorite;
}

class WellnessPassModel {
  const WellnessPassModel({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.price,
    required this.perClassPrice,
    required this.classesCount,
    required this.validity,
    this.isPopular = false,
  });

  final String id;
  final String name;
  final String subtitle;
  final double price;
  final double perClassPrice;
  final int classesCount;
  final String validity;
  final bool isPopular;
}

class WellnessPurchaseModel {
  const WellnessPurchaseModel({
    required this.id,
    required this.passName,
    required this.orderNumber,
    required this.date,
    required this.price,
    required this.status,
  });

  final String id;
  final String passName;
  final String orderNumber;
  final String date;
  final double price;
  final String status;
}

class WellnessBookingModel {
  const WellnessBookingModel({
    required this.id,
    required this.title,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    required this.room,
    required this.instructor,
    required this.level,
    required this.imageUrl,
    required this.status,
    required this.bookedFor,
    required this.price,
    this.category = '',
    this.spots = 1,
    this.isPast = false,
  });

  final String id;
  final String title;
  final String date;
  final String startTime;
  final String endTime;
  final int durationMinutes;
  final String room;
  final String instructor;
  final String level;
  final String imageUrl;
  final String status;
  final String bookedFor;
  final double price;
  final String category;
  final int spots;
  final bool isPast;
}

class MembershipPlanModel {
  const MembershipPlanModel({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.features,
    required this.icon,
    required this.isPopular,
    required this.isCurrent,
  });

  final String id;
  final String name;
  final double price;
  final String description;
  final List<String> features;
  final IconData icon;
  final bool isPopular;
  final bool isCurrent;
}

