import 'dart:math';

import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Node;
import 'package:graphview/GraphView.dart' hide Edge;
import 'package:tdesign_flutter/tdesign_flutter.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';
import 'package:yt_dart/cus_tree.pb.dart';
import 'package:yx/api/task_api.dart' as task_api;
import 'package:yx/types.dart';
import 'package:yx/utils/common_util.dart';
import 'package:yx/utils/common_widget.dart';
import 'package:yx/utils/toast.dart';

import 'comment/controller.dart';
import 'comment/view.dart';

class GraphTreeView extends StatelessWidget {
  const GraphTreeView({
    super.key,
    required this.id,
    required this.graphViewType,
  });

  final GraphViewType graphViewType;
  final Int64 id;

  bool get hasMoreLayer => id == Int64.ZERO;

  @override
  Widget build(BuildContext context) {
    switch (graphViewType) {
      case GraphViewType.task:
        return _TaskGraphTreeView(id: id);
      case GraphViewType.organization:
        return _OrganizationGraphTreeView(id: id);
    }
  }
}

mixin _GraphTreeViewMixin<T extends State> {
  bool _isLoading = false;
  Graph? _graph;
  Color _boxShadowColor = Colors.blue.shade300;

  T get _state;

  final _minScale = 0.8;
  final _maxScale = 4.0;
  final double _nodeWidth = 60.0;
  final double _nodeHeight = 40.0;
  final double _nodePadding = 4.0;
  double _scale = 1.0;
  final TransformationController _transformationController =
      TransformationController();

  bool get hasGraphData => false;

  // 处理双击放大/缩小
  void _handleDoubleTap() {
    _state.setState(() {
      _scale = _scale <= _minScale ? _maxScale * 0.4 : _minScale;
      _transformationController.value =
          Matrix4.identity()..scale(_scale, _scale);
    });
  }

  // 通过按钮放大
  void _zoomIn() => _zoomByButton(_scale + 0.3);

  // 通过按钮缩小
  void _zoomOut() => _zoomByButton(_scale - 0.3);

  void _zoomRestore() {
    _state.setState(() {
      _scale = 1.0;
      _transformationController.value =
          Matrix4.identity()..scale(_scale, _scale);
    });
  }

  void _zoomByButton(double newScale) {
    _state.setState(() {
      _scale = newScale.clamp(_minScale, _maxScale);
      _transformationController.value =
          Matrix4.identity()..scale(_scale, _scale);
    });
  }

  // late AnimationController _animationController;
  // late Animation<double> _animation;
  static final BuchheimWalkerConfiguration _graphBuilder =
      BuchheimWalkerConfiguration()
        ..siblingSeparation = (80)
        ..levelSeparation = (40)
        ..subtreeSeparation = (60)
        ..orientation = (BuchheimWalkerConfiguration.ORIENTATION_TOP_BOTTOM);

  static final _algorithm = BuchheimWalkerAlgorithm(
    _graphBuilder,
    TreeEdgeRenderer(_graphBuilder),
  );
  static final _paint =
      Paint()
        ..color = Colors.green
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;

  void _setGraphEdges(List<Edge> edges) {
    _graph = Graph()..isTree = true;
    for (var element in edges) {
      _graph!.addEdge(Node.Id(element.fromId), Node.Id(element.toId));
    }
  }

  void nodeTapAction(BuildContext context, Node node) {}

  void nodeDoubleTapAction(BuildContext context, Node node) {}

  Widget _toolTipContent(String content) => Tooltip(
    message: content,
    preferBelow: false,
    child: Text(
      content,
      overflow: TextOverflow.clip,
      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    ),
  );

  Widget _buildNodeContent(BuildContext context, Node node) {
    throw UnimplementedError();
  }

  Future<void> _commonPopupView(
    BuildContext context,
    Int64 id,
    GraphViewType graphViewType,
  ) async {
    Navigator.of(context).push(
      TDSlidePopupRoute(
        modalBarrierColor: TDTheme.of(context).fontGyColor2,
        slideTransitionFrom: SlideTransitionFrom.center,
        builder: (context) {
          final size = MediaQuery.sizeOf(context);
          return Container(
            decoration: BoxDecoration(
              color: Colors.lightGreen.shade100,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [BoxShadow(color: _boxShadowColor)],
            ),
            width: size.width * 0.8,
            height: size.height * 0.8,
            child: Stack(
              children: [
                GraphTreeView(id: id, graphViewType: graphViewType),
                Positioned(
                  right: 10,
                  top: 10,
                  child: IconButton(
                    onPressed: () {
                      Navigator.of(context).maybePop();
                    },
                    icon: Tooltip(
                      message: '关闭',
                      preferBelow: false,
                      child: Icon(Icons.close, color: Colors.red, size: 24),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGraphNodeContainer(Widget child, {Color? color}) {
    return Container(
      padding: EdgeInsets.all(_nodePadding),
      width: _nodeWidth,
      height: _nodeHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        boxShadow: [BoxShadow(color: color ?? _boxShadowColor)],
      ),
      child: Center(child: child),
    );
  }

  Widget _buildGraphNode(BuildContext context, Node node) {
    final id = node.key!.value as Int64;
    final child = _buildNodeContent(context, node);
    if (id < 1) {
      return _buildGraphNodeContainer(child, color: Colors.purple.shade200);
    }
    return InkWell(
      onTap: () => nodeTapAction(context, node),
      onDoubleTap: () => nodeDoubleTapAction(context, node),
      child: _buildGraphNodeContainer(child),
    );
  }

  Widget _buildGraphView(BuildContext context) {
    return GraphView(
      graph: _graph!,
      algorithm: _algorithm,
      paint: _paint,
      builder: (node) => _buildGraphNode(context, node),
    );
  }

  // 计算整个图形的边界
  static Rect _calculateGraphBounds(
    Graph graph,
    double nodeWidth,
    double nodeHeight,
  ) {
    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;

    // 遍历所有节点找到边界
    graph.nodes.forEach((node) {
      minX = min(minX, node.position.dx);
      minY = min(minY, node.position.dy);
      maxX = max(maxX, node.position.dx);
      maxY = max(maxY, node.position.dy);
    });

    // 如果没有节点，返回一个默认矩形
    if (minX == double.infinity) {
      return Rect.fromLTWH(0, 0, 100, 100);
    }

    // 添加一些边距
    return Rect.fromLTRB(
      minX - nodeWidth / 2,
      minY - nodeHeight / 2,
      maxX + nodeWidth / 2,
      maxY + nodeHeight / 2,
    );
  }

  Widget _buildInteractiveViewer(BuildContext context) {
    double? top = 0, right = 10, bottom = 0;
    if (isBigScreen(context)) {
      top = 0;
    } else {
      top = null;
      bottom = 10;
    }
    return Stack(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            // 计算图形布局
            _algorithm.run(_graph!, 10, 10);
            // 获取图形的边界
            Rect graphBounds = _calculateGraphBounds(
              _graph!,
              _nodeWidth,
              _nodeHeight,
            );
            // 计算居中偏移量
            double dx =
                (constraints.maxWidth - graphBounds.width) / 3 + 10; // -
            // graphBounds.left;
            double dy =
                (constraints.maxHeight - graphBounds.height) / 3 - 30; // -
            // graphBounds.top;
            return GestureDetector(
              onDoubleTap: _handleDoubleTap,
              child: InteractiveViewer(
                transformationController: _transformationController,
                minScale: _minScale,
                maxScale: _maxScale,
                boundaryMargin: const EdgeInsets.all(double.infinity),
                constrained: false,
                child:
                // 应用变换使图形居中
                Transform.translate(
                  offset: Offset(dx, dy),
                  child: _buildGraphView(context),
                ),
              ),
            );
          },
          // Center(child: _buildGraphView(context)),
        ),
        Positioned(
          top: top,
          right: right,
          bottom: bottom,
          child: SizedBox(
            width: 40,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 14,
              children: [
                IconButton(
                  onPressed: _zoomIn,
                  icon: Tooltip(message: '放大', child: Icon(Icons.zoom_in)),
                ),
                IconButton(
                  onPressed: _zoomOut,
                  icon: Tooltip(message: '缩小', child: Icon(Icons.zoom_out)),
                ),
                IconButton(
                  onPressed: _zoomRestore,
                  icon: Tooltip(
                    message: '还原',
                    child: Icon(Icons.looks_one_outlined),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGraph(BuildContext context) {
    if (_isLoading) {
      return buildLoading(context);
    } else if (!hasGraphData) {
      return emptyWidget(context);
    }
    return _buildInteractiveViewer(context);
  }
}

class _TaskGraphTreeView extends StatefulWidget {
  const _TaskGraphTreeView({super.key, required this.id});

  final Int64 id;

  bool get hasMoreLayer => id == Int64.ZERO;

  @override
  _TaskGraphTreeViewState createState() => _TaskGraphTreeViewState();
}

class _TaskGraphTreeViewState extends State<_TaskGraphTreeView>
    with
        SingleTickerProviderStateMixin,
        _GraphTreeViewMixin<_TaskGraphTreeViewState> {
  CusYooWorkTaskGraphViewData? _graphData;

  @override
  _TaskGraphTreeViewState get _state => this;

  @override
  Widget build(BuildContext context) => _buildGraph(context);

  @override
  bool get hasGraphData => _graphData != null;

  @override
  void initState() {
    super.initState();
    _loadGraphData();
  }

  Future<void> _loadGraphData() async {
    setState(() {
      _isLoading = true;
    });
    task_api
        .taskGraphViewData(widget.id)
        .then((data) {
          if (data != null && data.edges.isNotEmpty) {
            _graphData = data;
            _setGraphEdges(_graphData!.edges);
          }
        })
        .whenComplete(() {
          _isLoading = false;
          setState(() {});
        });
  }

  @override
  void nodeTapAction(BuildContext context, Node graphNode) {
    if (!widget.hasMoreLayer) {
      return;
    }
    final taskId = graphNode.key!.value as Int64;
    if (taskId < 1) {
      return;
    }
    final node = _graphData!.nodes[taskId]!;
    // 单击展示任务涉及到的组织树
    _commonPopupView(context, taskId, GraphViewType.organization);
  }

  @override
  Widget _buildNodeContent(BuildContext context, Node graphNode) {
    final taskId = graphNode.key!.value as Int64;
    final node = _graphData!.nodes[taskId]!;
    return _toolTipContent(node.name);
  }

  @override
  void nodeDoubleTapAction(BuildContext context, Node graphNode) {
    // 双击任务时才会展示任务评价
    final taskId = graphNode.key!.value as Int64;
    final node = _graphData!.nodes[taskId]!;
    Get.put(GraphTaskCommentController(node));
    // 打开任务评价页面 并且设置当前任务节点
    WoltModalSheet.show(
      useSafeArea: true,
      context: context,
      showDragHandle: GetPlatform.isMobile,
      enableDrag: GetPlatform.isMobile,
      onModalDismissedWithBarrierTap: () async {
        // 避免快速点击
        if (GraphTaskCommentController.instance.loading) {
          errIsLoadingData();
        } else {
          await GraphTaskCommentController.instance.closeOrRemoveOnePopupLayer(
            context,
          );
        }
      },
      onModalDismissedWithDrag: () async {
        if (GraphTaskCommentController.instance.loading) {
          errIsLoadingData();
        } else {
          await GraphTaskCommentController.instance.closeOrRemoveOnePopupLayer(
            context,
          );
        }
      },
      modalTypeBuilder: (BuildContext context) {
        final width = MediaQuery.sizeOf(context).width;
        if (width < 600) {
          return WoltModalType.bottomSheet();
        } else if (width < 800) {
          return WoltModalType.dialog();
        } else {
          return WoltModalType.sideSheet();
        }
      },
      pageListBuilder:
          (modalSheetContext) => [
            NonScrollingWoltModalSheetPage(
              topBarTitle: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("任务："),
                    Tooltip(
                      message: node.name,
                      child: Text(
                        node.name.substring(0, min(5, node.name.length)),
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 26,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.red, // 下划线颜色（可选）
                        ),
                      ),
                    ),
                    Text("的评价"),
                  ],
                ),
              ),
              hasTopBarLayer: true,
              // hasSabGradient: false,
              // isTopBarLayerAlwaysVisible: true,
              child: GraphTaskCommentView(),
            ),

            NonScrollingWoltModalSheetPage(
              topBarTitle: Center(
                child: Obx(
                  () => Text(
                    GraphTaskCommentController.instance.editCompSheetPageTitle,
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ),
              ),
              hasTopBarLayer: true,
              // hasSabGradient: false,
              // isTopBarLayerAlwaysVisible: true,
              leadingNavBarWidget: IconButton(
                padding: const EdgeInsets.all(4),
                icon: const Text("返回"),
                // icon: Text("取消"),
                onPressed: () {
                  WoltModalSheet.of(modalSheetContext).showAtIndex(0);
                  // Navigator.pop(modalSheetContext);
                  // controller.closeOrRemoveOnePopupLayer(modalSheetContext);
                },
              ),
              trailingNavBarWidget: IconButton(
                padding: const EdgeInsets.all(4),
                icon: const Text("关闭", style: TextStyle(color: Colors.blue)),
                // icon: Text("确定"),
                onPressed:
                    () => GraphTaskCommentController.instance
                        .closeTheEntirePopupLayer(modalSheetContext),
              ),
              child: GraphEditTaskCommentView(),
            ),
          ],
    );
  }
}

class _OrganizationGraphTreeView extends StatefulWidget {
  const _OrganizationGraphTreeView({super.key, required this.id});

  final Int64 id;

  bool get hasMoreLayer => id == Int64.ZERO;

  @override
  _OrganizationGraphTreeViewState createState() =>
      _OrganizationGraphTreeViewState();
}

class _OrganizationGraphTreeViewState extends State<_OrganizationGraphTreeView>
    with
        SingleTickerProviderStateMixin,
        _GraphTreeViewMixin<_OrganizationGraphTreeViewState> {
  CusYooOrganizationGraphViewData? _graphData;

  @override
  bool get hasGraphData => _graphData != null;

  @override
  _OrganizationGraphTreeViewState get _state => this;

  @override
  void initState() {
    super.initState();
    _loadGraphData();
    _boxShadowColor = Colors.orange.shade400;
  }

  Future<void> _loadGraphData() async {
    setState(() {
      _isLoading = true;
    });
    task_api
        .organizationGraphViewData(widget.id)
        .then((data) {
          if (data != null && data.edges.isNotEmpty) {
            _graphData = data;
            _setGraphEdges(_graphData!.edges);
          }
        })
        .whenComplete(() {
          _isLoading = false;
          setState(() {});
        });
  }

  @override
  void nodeTapAction(BuildContext context, Node graphNode) {
    if (!widget.hasMoreLayer) {
      return;
    }
    final orgId = graphNode.key!.value as Int64;
    if (orgId < 1) {
      // 此节点不能点击
      return;
    }
    final node = _graphData!.nodes[orgId]!;
    // 单击展示任务涉及到的组织树
    _commonPopupView(context, orgId, GraphViewType.task);
  }

  @override
  Widget _buildNodeContent(BuildContext context, Node graphNode) {
    final id = graphNode.key!.value as Int64;
    final node = _graphData!.nodes[id]!;
    return _toolTipContent(node.name);
  }

  @override
  Widget build(BuildContext context) => _buildGraph(context);
}
