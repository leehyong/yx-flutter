import 'package:fixnum/fixnum.dart';
import 'package:get/get.dart';
import 'package:yt_dart/cus_tree.pb.dart';
import 'package:yt_dart/generate_sea_orm_query.pb.dart';
import 'package:yx/api/comment_api.dart' as comment_api;
import 'package:yx/services/auth_service.dart';
import 'package:yx/utils/common_util.dart';
import 'package:yx/utils/toast.dart';

enum FetchDataAction {
  // 加载新一层数据
  popupNew,
  // 当前层分页加载更多数据
  curLayerMore,
  // 重置当前层的数据
  refresh,
}

const commentPageLimit = 4;

extension CusYooTaskCommentExtension on CusYooTaskComment {
  // 总的回复数，是否比children的多
  bool get hasMore => childrenCount > children.length;

  bool get isMyself => user.id == AuthService.instance.user!.userId;
}

class SoloCommentLayer {
  // 是哪个任务的评论
  final WorkTask curTask;

  // 当前层是由哪个评论带出来 为null 时， 表示的是curTask的评论， 否则，就是评论的回复
  CusYooTaskComment? curCusYooTaskComment;

  // 每一层的所有页面数据
  // 每一页的数据就是一个 ProtoPageVo<CusYooTaskComment> 对象
  final _pages = <ProtoPageVo<CusYooTaskComment>?>[].obs;

  SoloCommentLayer(this.curTask, [this.curCusYooTaskComment]);

  List<ProtoPageVo<CusYooTaskComment>> get pages =>
      isEmpty
          ? <ProtoPageVo<CusYooTaskComment>>[]
          : _pages.map((e) => e!).toList();

  bool get isEmpty => _pages.isEmpty || _pages.first == null;

  // 当前层是否有下一页数据, 以便可以加载更多
  bool get hasMore {
    if (_pages.isEmpty) {
      // isEmpty表示， 数据查询过了， 但是返回的是空数组，表示没有评论或回复的数据
      return true;
    }
    final first = _pages.first;
    // 第一个元素为null 表示数据数据查询过了，但不存在数据， 那就表明没有更多数据了
    if (first == null) {
      return false;
    }
    return _pages.first!.totalPages > _pages.length;
  }

  Future<void> refreshData() async {
    _pages.value.clear();
    return loadMoreData();
  }

  Future<void> loadMoreData() async {
    if (!hasMore) {
      warnToast('没有更多数据了');
      return;
    }
    final id = curCusYooTaskComment?.data.id ?? Int64.ZERO;
    final page = _pages.length + 1;
    return comment_api
        .queryAllComments(id, curTask.id, page, commentPageLimit)
        .then((data) {
          _pages.value.add(data);
        });
  }
}

class PopupLayerModel {
  // _layers[0] 表示任务的评论； 其它就表示评论的回复
  final _layers = <SoloCommentLayer>[].obs;
  final loading = false.obs;

  int get curLayer => _layers.length - 1;

  SoloCommentLayer? get curLayerData => curLayer > -1 ? _layers.last : null;

  // 0 表示对任务的评价， 其它的表示评价的回复
  bool get isReply =>
      _layers.length > 1 && curLayerData!.curCusYooTaskComment != null;

  bool get isEmpty => curLayerData?.isEmpty ?? true;

  bool get atLeast2Layers => _layers.length > 1;

  void _ensure() {
    // 以下断言必须满足
    // 第 0 层的 commentVo 肯定是 null
    assert(_layers[0].curCusYooTaskComment == null);
  }

  // 弹出最后一层的数据
  void popLast() {
    _ensure();
    _layers.removeLast();
  }

  // 在最后添加新的层数据
  Future<void> pushNew(WorkTask task, CusYooTaskComment? comment) async {
    final layer = SoloCommentLayer(task, comment);
    loading.value = true;
    return layer
        .refreshData()
        .then((_) {
          _layers.add(layer);
          _ensure();
        })
        .whenComplete(() {
          loading.value = false;
        });
  }

  // 在当前层添加下一页的数据
  Future<void> fetchMoreCommentsData() async {
    _ensure();
    loading.value = true;
    return curLayerData?.loadMoreData().whenComplete(() {
      loading.value = false;
    });
  }

  void clear() {
    loading.value = false;
    _layers.value.clear();
  }

  Future<void> refreshData() async {
    loading.value = true;
    return curLayerData?.refreshData().whenComplete(() {
      loading.value = false;
    });
  }
}
