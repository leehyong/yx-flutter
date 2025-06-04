import 'package:get/get.dart';
import 'package:yx/vo/comment_vo.dart';

enum FetchDataAction {
  // 加载新一层数据
  popupNew,
  // 当前层分页加载更多数据
  curLayerMore,
  // 重置当前层的数据
  refresh,
}

class _PageCommentVo {
  late int page;
  late CommentVoData? commentVo;

  _PageCommentVo(this.page, this.commentVo);
}

class PopupLayerModel {
  final _layers = <RxList<CommentVo>>[];
  final _pages = <_PageCommentVo>[];
  final _curLayer = (-1).obs;
  var loaded = false;

  int get curLayer => _curLayer.value;

  RxList<CommentVo>? get curLayerData =>
      _curLayer.value > -1 ? _layers[_curLayer.value] : null;

  int get count =>
      curLayerData?.fold(0, (prev, cur) => prev! + (cur.data?.length ?? 0)) ??
      0;

  bool get isEmpty => count == 0;

  // 0 表示对任务的评价， 其它的表示评价的回复
  bool get isReply => _curLayer.value > 0;

  // 当前
  bool get hasMore {
    if (isEmpty) {
      return false;
    }
    return curLayerData == null ? false : curLayerData!.last.count! > count;
  }

  int get curPage => _pages.isEmpty ? 1 : _pages[_curLayer.value].page;

  CommentVoData? get curCommentVodData =>
      _pages.isEmpty ? null : _pages[_curLayer.value].commentVo;

  int get nextPage => curPage + 1;

  // 至少有两层
  bool get atLeast2Layers => _curLayer.value > 0;

  // 清空全部数据
  void clear() {
    _layers.clear();
    _pages.clear();
    _curLayer.value = -1;
    loaded = false;
  }

  // 清空当前层的数据，并把页号置为 1
  void resetCurLayerData() {
    curLayerData?.clear();
    _pages[_curLayer.value].page = 1;
  }

  void _ensure() {
    // 以下断言必须满足
    // 第 0 层的 commentVo 肯定是 null
    assert(_pages[0].commentVo == null);
    assert(_pages.length - 1 == _curLayer.value);
    assert(_layers.length - 1 == _curLayer.value);
    loaded = true;
  }

  // 弹出最后一层的数据
  void popLast() {
    _ensure();
    if (_curLayer.value > 0) {
      _pages.removeLast();
      _layers.removeLast();
      --_curLayer.value;
    } else {
      clear();
    }
  }

  // 在最后添加新的层数据
  void pushNew(CommentVoData? cur, CommentVo data) {
    ++_curLayer.value;
    _pages.add(_PageCommentVo(1, cur));
    _layers.add([data].obs);
    _ensure();
  }

  // 初始化数据
  void initData(CommentVoData cur, CommentVo data) {
    clear();
    pushNew(cur, data);
  }

  // 在当前层添加下一页的数据
  void addNextPageData(CommentVo comment) {
    _ensure();
    _pages[_curLayer.value].page = nextPage;
    curLayerData?.add(comment);
  }

  void resetData(CommentVo comment) {
    // 重置当前层的数据
    _ensure();
    _pages[_curLayer.value].page = 1;
    _layers[_curLayer.value] = [comment].obs;
  }
}
