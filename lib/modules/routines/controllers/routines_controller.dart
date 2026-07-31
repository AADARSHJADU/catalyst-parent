import 'package:catalyst/data/mock/wellness_mock_data.dart';
import 'package:catalyst/data/models/models.dart';
import 'package:get/get.dart';

class RoutinesController extends GetxController {
  final tabIndex = 0.obs;
  final routines = RoutinesMockData.routines;
  final selectedRoutine = Rxn<RoutineModel>();

  List<RoutineModel> get activeRoutines =>
      routines.where((r) => !r.isCompleted).toList();

  List<RoutineModel> get completedRoutines =>
      routines.where((r) => r.isCompleted).toList();

  void selectTab(int index) => tabIndex.value = index;

  void selectRoutine(RoutineModel routine) {
    selectedRoutine.value = routine;
  }
}
