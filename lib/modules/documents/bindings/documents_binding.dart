import 'package:catalyst/data/services/document_service.dart';
import 'package:catalyst/modules/documents/controllers/documents_controller.dart';
import 'package:get/get.dart';

class DocumentsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(DocumentService.new);
    Get.lazyPut(DocumentsController.new);
  }
}
