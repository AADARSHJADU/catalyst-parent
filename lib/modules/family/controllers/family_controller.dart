import 'package:catalyst/data/mock/mock_data.dart';
import 'package:catalyst/data/models/models.dart';
import 'package:get/get.dart';

class FamilyController extends GetxController {
  final dancers = MockData.dancers.obs;
  final user = MockData.currentUser;

  void addDancer({
    required String name,
    required int age,
    required String level,
  }) {
    final newDancer = DancerModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      age: age,
      level: level,
      programs: [],
      avatarInitials: name.isNotEmpty ? name[0] : '?',
    );
    dancers.add(newDancer);
  }
}
