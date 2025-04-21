import 'package:fixnum/fixnum.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';

import 'controller.dart';
import 'header_crud.dart';

class SelectSubmitItemView extends GetView<SelectSubmitItemsController> {
  SelectSubmitItemView(
    GlobalKey<PublishItemsViewSimpleCrudState> treeStateKey,
    Int64 taskId, {
    super.key,
  }) {
    Get.put(SelectSubmitItemsController(treeStateKey, taskId));
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
