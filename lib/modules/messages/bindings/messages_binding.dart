import 'package:get/get.dart';

import '../controllers/chat_controller.dart';
import '../controllers/group_info_controller.dart';
import '../controllers/messages_controller.dart';

class MessagesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MessagesController>(() => MessagesController());
    Get.lazyPut<ChatController>(() => ChatController());
    Get.lazyPut<GroupInfoController>(() => GroupInfoController());
  }
}
