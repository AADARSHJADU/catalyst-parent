import 'dart:io';

import 'package:catalyst/core/constants/app_colors.dart';
import 'package:catalyst/core/network/api_exception.dart';
import 'package:catalyst/data/models/student_model.dart';
import 'package:catalyst/data/services/student_service.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StudentProfileController extends GetxController {
  final StudentService _service = Get.find<StudentService>();

  // ── State ──────────────────────────────────────────────────────────────
  final isLoading = true.obs;
  final isSaving = false.obs;
  final errorMessage = ''.obs;

  // ── Data ───────────────────────────────────────────────────────────────
  final students = <StudentModel>[].obs;

  // ── Lookups ────────────────────────────────────────────────────────────
  final ageGroups = <StudentLookup>[].obs;
  final skillLevels = <StudentLookup>[].obs;
  final danceStyles = <StudentDanceStyle>[].obs;
  final studios = <StudentStudio>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadAll();
  }

  Future<void> _loadAll() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final results = await Future.wait([
        _service.getStudents(),
        _service.getAgeGroups(),
        _service.getSkillLevels(),
        _service.getDanceStyles(),
        _service.getStudios(),
      ]);
      students.value = results[0] as List<StudentModel>;
      ageGroups.value = results[1] as List<StudentLookup>;
      skillLevels.value = results[2] as List<StudentLookup>;
      danceStyles.value = results[3] as List<StudentDanceStyle>;
      studios.value = results[4] as List<StudentStudio>;
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } catch (_) {
      errorMessage.value = 'Something went wrong. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refresh() async {
    try {
      students.value = await _service.getStudents();
    } on ApiException catch (e) {
      Get.snackbar('Error', e.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: Colors.white);
    }
  }

  // ── Create Student ─────────────────────────────────────────────────────
  Future<bool> createStudent({
    required String firstName,
    required String lastName,
    required String dateOfBirth,
    required String gender,
    String? email,
    String? mobileNumber,
    String? emergencyContact1,
    String? emergencyContact2,
    String? medicalNotes,
    String? notes,
    int? ageGroupId,
    int? levelId,
    int? studioId,
    List<int> danceStyleIds = const [],
    File? profilePic,
  }) async {
    isSaving.value = true;
    try {
      final map = <String, dynamic>{
        'firstName': firstName,
        'lastName': lastName,
        'dateOfBirth': dateOfBirth,
        'gender': gender,
        'status': true,
        'enrollmentDate': DateTime.now().toIso8601String().split('T').first,
      };
      if (email != null && email.isNotEmpty) map['email'] = email;
      if (mobileNumber != null && mobileNumber.isNotEmpty) {
        map['mobileNumber'] = mobileNumber;
      }
      if (emergencyContact1 != null && emergencyContact1.isNotEmpty) {
        map['emergencyContact1'] = emergencyContact1;
      }
      if (emergencyContact2 != null && emergencyContact2.isNotEmpty) {
        map['emergencyContact2'] = emergencyContact2;
      }
      if (medicalNotes != null && medicalNotes.isNotEmpty) {
        map['medicalNotes'] = medicalNotes;
      }
      if (notes != null && notes.isNotEmpty) map['notes'] = notes;
      if (ageGroupId != null) map['ageGroupId'] = ageGroupId;
      if (levelId != null) map['levelId'] = levelId;
      if (studioId != null) map['studioId'] = studioId;
      if (danceStyleIds.isNotEmpty) map['danceStyles'] = danceStyleIds;
      if (profilePic != null) {
        map['profile_pic'] = await dio.MultipartFile.fromFile(
          profilePic.path,
          filename: profilePic.path.split('/').last,
        );
      }

      final formData = dio.FormData.fromMap(map);
      final student = await _service.createStudent(formData);
      students.add(student);
      Future.delayed(const Duration(milliseconds: 300), () {
        Get.snackbar('Success', 'Student created successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.success,
            colorText: Colors.white);
      });
      return true;
    } on ApiException catch (e) {
      Get.snackbar('Error', e.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: Colors.white);
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  // ── Update Student ─────────────────────────────────────────────────────
  Future<bool> updateStudent({
    required int id,
    required String firstName,
    required String lastName,
    required String dateOfBirth,
    required String gender,
    String? email,
    String? mobileNumber,
    String? emergencyContact1,
    String? emergencyContact2,
    String? medicalNotes,
    String? notes,
    int? ageGroupId,
    int? levelId,
    int? studioId,
    List<int> danceStyleIds = const [],
    File? profilePic,
  }) async {
    isSaving.value = true;
    try {
      final map = <String, dynamic>{
        'firstName': firstName,
        'lastName': lastName,
        'dateOfBirth': dateOfBirth,
        'gender': gender,
      };
      if (email != null && email.isNotEmpty) map['email'] = email;
      if (mobileNumber != null && mobileNumber.isNotEmpty) {
        map['mobileNumber'] = mobileNumber;
      }
      if (emergencyContact1 != null && emergencyContact1.isNotEmpty) {
        map['emergencyContact1'] = emergencyContact1;
      }
      if (emergencyContact2 != null && emergencyContact2.isNotEmpty) {
        map['emergencyContact2'] = emergencyContact2;
      }
      if (medicalNotes != null && medicalNotes.isNotEmpty) {
        map['medicalNotes'] = medicalNotes;
      }
      if (notes != null && notes.isNotEmpty) map['notes'] = notes;
      if (ageGroupId != null) map['ageGroupId'] = ageGroupId;
      if (levelId != null) map['levelId'] = levelId;
      if (studioId != null) map['studioId'] = studioId;
      if (danceStyleIds.isNotEmpty) map['danceStyles'] = danceStyleIds;
      if (profilePic != null) {
        map['profile_pic'] = await dio.MultipartFile.fromFile(
          profilePic.path,
          filename: profilePic.path.split('/').last,
        );
      }

      final formData = dio.FormData.fromMap(map);
      final updated = await _service.updateStudent(id, formData);
      final idx = students.indexWhere((s) => s.id == id);
      if (idx != -1) students[idx] = updated;
      Future.delayed(const Duration(milliseconds: 300), () {
        Get.snackbar('Success', 'Student updated successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.success,
            colorText: Colors.white);
      });
      return true;
    } on ApiException catch (e) {
      Get.snackbar('Error', e.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: Colors.white);
      return false;
    } finally {
      isSaving.value = false;
    }
  }
}
