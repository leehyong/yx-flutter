import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toastification/toastification.dart';
import 'package:yx/api/comment_api.dart';
import 'package:yx/utils/toast.dart';
import 'package:yx/vo/comment_vo.dart';
import 'package:yx/vo/graph_vo.dart' as graph_vo;

import 'popup.dart';

class GraphTaskCommentController extends GetxController {
  final popupCommentsOfLeader = PopupLayerModel().obs;
  final popupCommentsOfRoom = PopupLayerModel().obs;
  final curTaskNode = (null as graph_vo.Node?).obs;
  final curTaskId = ''.obs;
  final curCommentVo = (null as CommentVoData?).obs;
  static const limit = 4;
  final loading = false.obs;
  final needRefreshLastLayer = false.obs;
  final curInputCommentController = TextEditingController();
  final tabBarIdx = 0.obs;
  final curDeletingCommentId = (null as String?).obs;
  final curEditingCommentOldContent = ''.obs;


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

  PopupLayerModel get curPopupModel {
    if (isLeaderCommentTabBar) {
      return popupCommentsOfLeader.value;
    } else if (isRoomCommentTabBar) {
      return popupCommentsOfRoom.value;
    }
    throw 'unreachable';
  }

  bool get isReplyPopupLayer =>
      curCommentVo.value != null && (curPopupModel.isReply ?? false);

  Future<void> fetchMoreCommentsData() async => _fetchCommentsData(
    curPopupModel.nextPage,
    FetchDataAction.curLayerMore,
    curCommentCat,
  );

  List<CommentVo> get curPopupLayerData =>
      curPopupModel.curLayerData?.value ?? [];

  bool get curPopupLayerDataIsEmpty => curPopupModel.isEmpty ?? true;

  static GraphTaskCommentController get instance => Get.find();

  // 暂时不需要考虑其它类型， 有需要后续再扩充
  CommentCat get curCommentCat =>
      isRoomCommentTabBar ? CommentCat.room : CommentCat.leader;

  Future<void> _fetchCommentsData(
    int page,
    FetchDataAction action,
    CommentCat cat, {
    bool? isReply,
  }) async {
    // 如果当前层已经没有更多数据，则不执行加载操作
    Rx<PopupLayerModel> popupModel;
    if (cat == CommentCat.leader) {
      popupModel = popupCommentsOfLeader;
    } else if (cat == CommentCat.room) {
      popupModel = popupCommentsOfRoom;
    } else {
      throw 'unknown comment cat $cat';
    }
    if (action == FetchDataAction.curLayerMore && !popupModel.value.hasMore) {
      return;
    }
    isReply ??= popupModel.value.isReply;
    loading.value = true;
    var id = '';
    switch (action) {
      case FetchDataAction.popupNew:
        id = isReply ? curCommentVo.value!.id! : curTaskId.value;
        break;
      case FetchDataAction.curLayerMore:
      case FetchDataAction.refresh:
        id =
            isReply ? popupModel.value.curCommentVodData!.id! : curTaskId.value;
        break;
    }
    // 加载评价数据
    var d = await queryAllComments(id, cat, page, limit, isReply: isReply);
    switch (action) {
      case FetchDataAction.popupNew:
        popupModel.value.pushNew(curCommentVo.value, d);
        break;
      case FetchDataAction.curLayerMore:
        popupModel.value.addNextPageData(d);
        break;
      case FetchDataAction.refresh:
        popupModel.value.resetData(d);
        break;
    }
    loading.value = false;
  }

  Future<void> fetchInitData({bool both = true}) async {
    //  首次加载时不需要 检查 是否有更多数据
    if (both) {
      await Future.wait([
        _fetchCommentsData(1, FetchDataAction.popupNew, CommentCat.room),
        _fetchCommentsData(1, FetchDataAction.popupNew, CommentCat.leader),
      ]);
    } else {
      await _fetchCommentsData(1, FetchDataAction.popupNew, curCommentCat);
    }
  }

  get isLeaderCommentTabBar => tabBarIdx.value == 0;

  get isRoomCommentTabBar => tabBarIdx.value == 1;

  // 是否还有更多评论数据需要加载
  bool get hasMoreCommentsData => curPopupModel.hasMore ?? false;

  Future<void> _refreshCommentsData() async {
    //  loading.value 避免重复加载数据
    if (loading.value) {
      errIsLoadingData();
      return;
    }
    return _fetchCommentsData(1, FetchDataAction.refresh, curCommentCat);
  }

  get commentType => tabBarIdx.value == 0 ? '领导' : '科室';

  void _clearAllPopupLayer() {
    // 清空
    popupCommentsOfLeader.value.clear();
    popupCommentsOfRoom.value.clear();
    curTaskNode.value = null;
    curCommentVo.value = null;
    curTaskId.value = '';
    curEditingCommentOldContent.value = '';
    curDeletingCommentId.value = null;
  }

  Future<void> addNewPopupCommentLayer() async {
    return _fetchCommentsData(
      1,
      FetchDataAction.popupNew,
      curCommentCat,
      isReply: true,
    );
  }

  Future<void> closeOrRemoveOnePopupLayer(BuildContext context) async {
    if (curPopupModel.atLeast2Layers) {
      curPopupModel.popLast();
      if (needRefreshLastLayer.value) {
        await _fetchCommentsData(1, FetchDataAction.refresh, curCommentCat);
        needRefreshLastLayer.value = false;
      }
    } else {
      _clearAllPopupLayer();
      Navigator.maybePop(context);
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
      // 调用修改接口来修改评论
      success = await updateGraphComment(
        curCommentCat,
        curCommentVo.value!.id!,
        comment,
      );
      curEditingCommentOldContent.value = '';
      curCommentVo.value = curPopupModel.curCommentVodData;
    } else {
      // 调用新增接口来修新增评论
      success = await addGraphComment(
        curCommentCat,
        curTaskId.value,
        comment,
        replyId: curCommentVo.value?.id,
      );
      msg = (curCommentVo.value?.id?.isNotEmpty ?? false) ? '回复' : '评论';
      // 不管评论还是回复， 不能把curCommentVo置为null， 因为在加载更多页面的时候，
      // 需要 curCommentVo 存在，否则导致状态错误
      // curCommentVo.value = null;
    }
    if (success) {
      curInputCommentController.clear();
      needRefreshLastLayer.value = true;
      toastification.show(
        type: ToastificationType.success,
        title: Text('$msg$commentType成功'),
        autoCloseDuration: const Duration(seconds: 1),
      );
      // 新增评论之后，重置当前层的数据，并重新加载数据
      await _refreshCommentsData();
    }
  }

  Future<void> deleteCurComment() async {
    if (curDeletingCommentId.value == null ||
        curDeletingCommentId.value!.isEmpty) {
      return;
    }
    var success = await deleteGraphComment(
      curCommentCat,
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
      await _refreshCommentsData();
    }
    // 不管成功还是失败均把它置为null， 不然正在删除的那个评论一直闪烁
    curDeletingCommentId.value = null;
  }

  bool get isEditing =>
      curCommentVo.value != null &&
      curEditingCommentOldContent.value.isNotEmpty;

  String get editCompSheetPageTitle {
    if (curCommentVo.value == null) {
      return '创建$commentType评论';
    } else if (isEditing) {
      return '修改评论';
    } else {
      return curCommentVo.value!.evaluationAuthor!;
    }
  }
}
