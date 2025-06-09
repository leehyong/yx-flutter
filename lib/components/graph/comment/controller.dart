import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toastification/toastification.dart';
import 'package:yt_dart/cus_tree.pb.dart';
import 'package:yt_dart/generate_sea_orm_new.pb.dart';
import 'package:yt_dart/generate_sea_orm_query.pb.dart';
import 'package:yt_dart/generate_sea_orm_update.pb.dart';
import 'package:yx/api/comment_api.dart' as comment_api;
import 'package:yx/utils/toast.dart';

import 'popup.dart';

class GraphTaskCommentController extends GetxController {
  final popupComments = PopupLayerModel().obs;
  final needRefreshLastLayer = false.obs;
  final curInputCommentController = TextEditingController();
  final tabBarIdx = 0.obs;
  final curDeletingCommentId = (null as Int64?).obs;
  final curEditingCommentOldContent = ''.obs;
  final curTaskComment = (null as CusYooTaskComment?).obs;

  GraphTaskCommentController(this.curTask);

  final WorkTask curTask;

  @override
  void onInit() {
    super.onInit();
    ever(curEditingCommentOldContent, (v) {
      if (isEditing) {
        curInputCommentController.text = v;
      } else {
        curInputCommentController.clear();
      }
    });
  }

  @override
  void onReady() {
    super.onReady();
    addNewPopupCommentLayer();
  }

  bool get isReplyPopupLayer => popupComments.value.isReply;

  Future<void> fetchMoreCommentsData() async =>
      popupComments.value.fetchMoreCommentsData();

  SoloCommentLayer? get curPopupLayerData => popupComments.value.curLayerData;

  bool get curPopupLayerDataIsEmpty => popupComments.value.isEmpty;

  Int64 get curTaskId => curTask.id;

  bool get loading => popupComments.value.loading.value;

  static GraphTaskCommentController get instance => Get.find();

  Future<void> _fetchCommentsData(FetchDataAction action) async {
    // 加载评价数据
    switch (action) {
      case FetchDataAction.popupNew:
        return popupComments.value.pushNew(curTask, curTaskComment.value);
      case FetchDataAction.curLayerMore:
        return popupComments.value.fetchMoreCommentsData();
      case FetchDataAction.refresh:
        return popupComments.value.refreshData();
    }
  }

  get isLeaderCommentTabBar => tabBarIdx.value == 0;

  get isRoomCommentTabBar => tabBarIdx.value == 1;

  // 是否还有更多评论数据需要加载
  bool get hasMoreCommentsData =>
      popupComments.value.curLayerData?.hasMore ?? false;

  Future<void> refreshCommentsData() async {
    //  loading.value 避免重复加载数据
    if (loading) {
      errIsLoadingData();
      return;
    }
    return _fetchCommentsData(FetchDataAction.refresh);
  }

  get commentType => tabBarIdx.value == 0 ? '领导' : '科室';

  void _clearAllPopupLayer() {
    // 清空
    popupComments.value.clear();
    curTaskComment.value = null;
    curEditingCommentOldContent.value = '';
    curDeletingCommentId.value = null;
  }

  Future<void> addNewPopupCommentLayer() async {
    return _fetchCommentsData(FetchDataAction.popupNew);
  }

  Future<void> closeOrRemoveOnePopupLayer(BuildContext context) async {
    if (popupComments.value.atLeast2Layers) {
      popupComments.value.popLast();
      if (needRefreshLastLayer.value) {
        return _fetchCommentsData(FetchDataAction.refresh).whenComplete(() {
          needRefreshLastLayer.value = false;
        });
      }
    } else {
      _clearAllPopupLayer();
      Navigator.maybePop(context).whenComplete((){
       //  移除本controller
       WidgetsBinding.instance.addPostFrameCallback((_){
         Get.delete<GraphTaskCommentController>();
       });
      });

    }
  }

  void closeTheEntirePopupLayer(BuildContext context) {
    // 关闭整个弹出层
    while (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    _clearAllPopupLayer();
  }

  Future<void> sendComment() async {
    final comment = curInputCommentController.text.trim();
    // 不能提交完全空白的内容
    if (comment.isEmpty) {
      curEditingCommentOldContent.value = '';
      return;
    }
    var success = false;
    var msg = '';
    if (isEditing) {
      // 内容没变化, 直接返回
      if (comment == curEditingCommentOldContent.value) {
        curEditingCommentOldContent.value = '';
        return;
      }
      msg = '修改';
      final mask = 1; // 1 表示只修改了内容， 后续再增加附件的修改
      // 调用修改接口来修改评论
      success = await comment_api.updateTaskComment(
        curTaskComment.value!.data.id,
        UpdateTaskComment(taskId: curTaskId, content: comment),
        mask,
      );
      curEditingCommentOldContent.value = '';
      curTaskComment.value!.data.content = comment;
    } else {
      // 调用新增接口来修新增评论
      success = await comment_api.addTaskComment(
        curTaskId,
        NewTaskComment(taskId: curTaskId, content: comment),
        replyId: curTaskComment.value?.data.id,
      );
      // 不管评论还是回复， 不能把curCommentVo置为null， 因为在加载更多页面的时候，
      // 需要 curCommentVo 存在，否则导致状态错误
      // curCommentVo.value = null;
    }
    if (success) {
      curInputCommentController.clear();
      needRefreshLastLayer.value = true;
      toastification.show(
        type: ToastificationType.success,
        title: Text('$msg成功'),
        autoCloseDuration: const Duration(seconds: 1),
      );
      // 新增评论之后，重置当前层的数据，并重新加载数据
      await refreshCommentsData();
    }
  }

  Future<void> deleteCurComment() async {
    if (curDeletingCommentId.value == null ||
        curDeletingCommentId.value! == Int64.ZERO) {
      return;
    }
    var success = await comment_api.deleteTaskComment(
      curDeletingCommentId.value!,
    );
    if (success) {
      needRefreshLastLayer.value = true;
      toastification.show(
        type: ToastificationType.success,
        title: Text('删除成功'),
        autoCloseDuration: const Duration(seconds: 1),
      );
      // 新增评论之后，重置当前层的数据，并重新加载数据
      await refreshCommentsData();
    }
    // 不管成功还是失败均把它置为null， 不然正在删除的那个评论一直闪烁
    curDeletingCommentId.value = null;
  }

  bool get isEditing =>
      curTaskComment.value != null &&
      curEditingCommentOldContent.value.isNotEmpty;

  String get editCompSheetPageTitle {
    if (curTaskComment.value == null) {
      return '创建评论';
    } else if (isEditing) {
      return '修改评论';
    } else {
      return curTaskComment.value!.user.name;
    }
  }
}
