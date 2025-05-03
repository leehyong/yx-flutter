import 'package:get/get.dart';
import 'package:yx/services/http_service.dart';
import 'package:yx/utils/common_util.dart';
import 'package:yx/vo/common_vo.dart';

import '../vo/comment_vo.dart';

enum CommentCat { leader, room }

Future<CommentVo> queryAllComments(
  String id,
  CommentCat cat,
  int page,
  int limit, {
  bool isReply = false,
}) async {
  var query = {
    "id": id,
    "limit": limit.toString(),
    "page": page.toString(),
    "type": cat == CommentCat.leader ? "1" : "2",
  };
  var url = '';
  if (isReply) {
    url = '/duty/get-reply-by-evaluation-id';
  } else {
    url = '/duty/get-evaluation-by-duty-id';
  }

  try {
    // 通过任务id查询评论
    var res = await HttpDioService.instance.dio.get<CommonCommentVo>(
      url,
      queryParameters: query,
      // decoder:
      //     (data) => CommonCommentVo.fromJson(
      //       data as CommonMapVoData,
      //       fromJsonT:
      //           CommentVo.fromJson as FromJsonFn<CommentVo, CommonMapVoData>,
      //     ),
    );
    final success = handleCommonToastResponse(res, 'queryAllComments错误');
    // 消息通知 toast
    if (!success) {
      return CommentVo();
    }
    return res.data!.data!;
  } catch (e) {
    e.printError(info: e.toString());
    return CommentVo();
  }
}

// 新增评论或者回复
Future<bool> addGraphComment(
  CommentCat cat,
  String taskId,
  String comment, {
  String? replyId,
}) async {
  var url = '';
  var data = {"dutyId": taskId, "evaluationDes": comment};
  if (replyId == null) {
    if (cat == CommentCat.room) {
      url = '/duty-department-evaluation/create-duty-department-evaluation';
    } else {
      url = '/duty-leader-evaluation/create-duty-leader-evaluation';
    }
  } else {
    data['id'] = replyId;
    if (cat == CommentCat.room) {
      url = '/duty-department-evaluation/reply-duty-department-evaluation';
    } else {
      url = '/duty-leader-evaluation/reply-duty-leader-evaluation';
    }
  }
  try {
    var res = await HttpDioService.instance.dio.post<CommonVo<Object, Object>>(
      url,
      data: data,
      // decoder:
      //     (data) => CommonVo.fromJsonNullData(
      //       data as Map<String, dynamic>,
      //       // fromJsonT: GraphVo.fromJson as FromJsonFn<GraphVo, CommonMapVoData>,
      //     ),
    );
    return handleCommonToastResponse(res, 'addGraphComment错误');
  } catch (e) {
    e.printError(info: e.toString());
    return false;
  }
}

Future<bool> deleteGraphComment(CommentCat cat, String id) async {
  var url = '';
  if (cat == CommentCat.leader) {
    url = '/duty-leader-evaluation/delete-duty-leader-evaluation';
  } else {
    url = '/duty-department-evaluation/delete-duty-department-evaluation';
  }
  try {
    var res = await HttpDioService.instance.dio.post<CommonVo<Object, Object>>(
      url,
      data: {"id": id},
      // decoder:
      //     (data) => CommonVo.fromJsonNullData(
      //       data as Map<String, dynamic>,
      //       // fromJsonT: GraphVo.fromJson as FromJsonFn<GraphVo, CommonMapVoData>,
      //     ),
    );
    return handleCommonToastResponse(res, 'deleteGraphComment错误');
  } catch (e) {
    e.printError(info: e.toString());
    return false;
  }
}

Future<bool> updateGraphComment(
  CommentCat cat,
  String id,
  String comment,
) async {
  var url = '';
  if (cat == CommentCat.leader) {
    url = '/duty-leader-evaluation/update-duty-leader-evaluation';
  } else {
    url = '/duty-department-evaluation/update-duty-department-evaluation';
  }
  try {
    var res = await HttpDioService.instance.dio.post<CommonVo<Object, Object>>(
      url,
      data: {"id": id, "evaluationDes": comment},
      // decoder:
      //     (data) => CommonVo.fromJsonNullData(
      //       data as Map<String, dynamic>,
      //       // fromJsonT: GraphVo.fromJson as FromJsonFn<GraphVo, CommonMapVoData>,
      //     ),
    );
    return handleCommonToastResponse(res, 'updateGraphComment错误');
  } catch (e) {
    e.printError(info: e.toString());
    return false;
  }
}
