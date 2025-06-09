import 'dart:math';

import 'package:comment_tree/widgets/comment_tree_widget.dart';
import 'package:comment_tree/widgets/tree_theme_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:get/get.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';
import 'package:yt_dart/cus_tree.pb.dart';
import 'package:yx/components/graph/comment/popup.dart';
import 'package:yx/utils/common_util.dart';
import 'package:yx/utils/common_widget.dart';

import 'controller.dart';

class GraphTaskCommentView extends GetView<GraphTaskCommentController> {
  const GraphTaskCommentView({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth, height = constraints.maxHeight;
        return Obx(() {
          Widget w;
          if (controller.loading) {
            w = buildLoading(context);
          } else if (controller.isReplyPopupLayer) {
            w = buildCommentReplyComp(context);
          } else {
            w = buildCommonCommentComp(context);
          }
          return SizedBox(width: width, height: height, child: w);
        });
      },
    );
  }

  Widget _buildHeadCommentReplyComp(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("@"),
        Text(
          controller.curTaskComment.value!.user.name,
          style: TextStyle(
            color: Colors.red,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 1),
        const TDBadge(TDBadgeType.message, message: "楼主", color: Colors.blue),
      ],
    );
  }

  Widget buildCommentReplyComp(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _buildHeadCommentReplyComp(context),
        _buildCommentReplyTextWidget(
          context,
          controller.curTaskComment.value!.data.content,
          reply: true,
        ),
        const TDDivider(
          height: 2.0,
          color: Colors.purpleAccent,
          isDashed: true,
          text: "回复列表",
          textStyle: TextStyle(color: Colors.lightBlueAccent),
          alignment: TextAlignment.left,
        ),
        Expanded(child: buildCommonCommentComp(context)),
      ],
    );
  }

  Widget buildCommonCommentComp(BuildContext context) {
    final comments =
        controller.curPopupLayerDataIsEmpty
            ? Center(child: emptyWidget(context))
            : RefreshIndicator(
              onRefresh: controller.refreshCommentsData,
              child: SingleChildScrollView(
                padding: EdgeInsets.only(bottom: 8, top: 8),
                child: Column(children: buildAllCommentsVoComp(context)),
              ),
            );

    return Column(
      children: [
        Expanded(child: comments),
        SizedBox(height: 10),
        buildEditCommentComp(context),
      ],
    );
  }

  PreferredSize avatarBuilder(
    BuildContext context,
    CusYooTaskComment data,
    bool isRoot,
  ) {
    var s = isRoot ? 18.0 : 12.0;
    return PreferredSize(
      preferredSize: Size.fromRadius(s),
      child: CircleAvatar(
        radius: s,
        backgroundColor: Colors.grey,
        backgroundImage: AssetImage(
          'assets/images/avatar_${isRoot ? 2 : 1}.png',
        ),
      ),
    );
  }

  Future<void> buildPopupLayerCommentComp(BuildContext context) async {
    WoltModalSheet.of(context).showAtIndex(1);
  }

  Widget buildEditCommentComp(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.blue[600]),
      child: Row(
        spacing: 4,
        children: [
          SizedBox(width: 4),
          Expanded(
            child: TextField(
              onTap: () async {
                if (!controller.popupComments.value.atLeast2Layers) {
                  // 避免创建不正确的回复或者评价
                  controller.curTaskComment.value = null;
                }
                controller.curEditingCommentOldContent.value = '';
                await buildPopupLayerCommentComp(context);
              },
              readOnly: true,
              // controller: controller.curInputCommentController,
              decoration: InputDecoration(
                hintText: "美好的一天从评论开始",
                hintStyle: TextStyle(color: Colors.white),
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              print('表情');
            },
            icon: Icon(Icons.tag_faces, color: Colors.yellow),
          ),
          // IconButton(onPressed: () {}, icon: Icon(Icons.tag)),
          IconButton(
            onPressed: () {},
            icon: const Text(
              "@",
              style: TextStyle(color: Colors.white, fontSize: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPopupColEditCommentComp(BuildContext context) {
    return Column(
      spacing: 4,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (controller.curTaskComment.value != null &&
            controller.curEditingCommentOldContent.value.isEmpty)
          _buildCommentReplyTextWidget(
            context,
            controller.curTaskComment.value!.data.content,
          ),
        Expanded(
          child: TextField(
            textInputAction: TextInputAction.send,
            expands: true,
            autofocus: true,
            maxLines: null,
            textAlign: TextAlign.start,
            textAlignVertical: TextAlignVertical.top,
            minLines: null,
            controller: controller.curInputCommentController,
            onChanged: (v) {
              print(v);
              // debounce(
              //   controller.curInputCommentController,
              //   (t) {
              //     print(t.text);
              //   },
              //   time: Duration(milliseconds: 500),
              // );
            },
            decoration: InputDecoration(
              hintText: "美好的一天从评论开始",
              border: OutlineInputBorder(
                borderSide: BorderSide(width: 1.0, style: BorderStyle.solid),
              ),
              hintStyle: TextStyle(color: Colors.grey),
              // border:,
              suffixIcon: IconButton(
                alignment: Alignment.bottomRight,
                onPressed: () {
                  controller.curInputCommentController.clear();
                },
                icon: Icon(Icons.clear, color: Colors.red),
              ),
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.only(left: 20, right: 20),
          decoration: BoxDecoration(color: Colors.blue[600]),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 4,
            children: [
              IconButton(
                onPressed: () {
                  print('表情');
                },
                icon: Icon(Icons.tag_faces, color: Colors.yellow),
              ),
              IconButton(
                onPressed: () {},
                icon: Text("@", style: TextStyle(fontSize: 20)),
              ),
              IconButton(
                onPressed: () async {
                  await controller.sendComment();
                  if (context.mounted) {
                    WoltModalSheet.of(context).showAtIndex(0);
                  }
                },
                icon: Icon(Icons.send, color: Colors.red),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDeleteCommentComp(BuildContext context, CusYooTaskComment data) {
    return IconButton(
      onPressed: () {
        controller.curDeletingCommentId.value = data.data.id;
        showGeneralDialog(
          context: context,
          pageBuilder: (
            BuildContext buildContext,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) {
            return TDAlertDialog(
              title: "确认删除吗？",
              titleColor: Colors.red,
              leftBtnAction: () {
                controller.curDeletingCommentId.value = null;
                Navigator.of(buildContext).pop();
              },
              rightBtnAction: () async {
                await controller.deleteCurComment();
                if (buildContext.mounted) {
                  Navigator.of(buildContext).pop();
                }
              },
            );
          },
        );
      },
      icon: Icon(Icons.delete, size: 16, color: Colors.red),
    );
  }

  Widget _buildCommentOperations(
    BuildContext context,
    CusYooTaskComment data,
    bool isRoot,
    bool hasMore,
  ) {
    return DefaultTextStyle(
      style: Theme.of(context).textTheme.bodySmall!.copyWith(
        color: Colors.grey[700],
        fontWeight: FontWeight.bold,
      ),
      child: Padding(
        padding: EdgeInsets.only(top: 4),
        child: Row(
          spacing: 12,
          children: [
            // SizedBox(width: 8),
            IconButton(
              onPressed: () {
                print('赞');
              },
              icon: Icon(Icons.thumb_up, size: 16),
            ),
            IconButton(
              onPressed: () {
                print('踩');
              },
              icon: Icon(Icons.thumb_down, size: 16),
            ),
            if (data.isMyself) _buildDeleteCommentComp(context, data),
            if (data.isMyself)
              IconButton(
                onPressed: () async {
                  // 修改
                  controller.curTaskComment.value = data;
                  controller.curEditingCommentOldContent.value =
                      data.data.content;
                  await buildPopupLayerCommentComp(context);
                },
                icon: Icon(Icons.edit, size: 16),
              ),
            // SizedBox(width: 24),
            // InkWell(
            //   onTap: () async {
            //     controller.curTaskComment.value = data;
            //     await buildPopupLayerCommentComp(context);
            //   },
            //   child: Text('回复'),
            // ),
            if (hasMore && isRoot)
              InkWell(
                onTap: () async {
                  controller.curTaskComment.value = data;
                  await controller.addNewPopupCommentLayer();
                  // await buildPopupLayerCommentReply(context);
                },
                child: Row(
                  children: [
                    const Text('更多'),
                    const SizedBox(width: 1),
                    TDBadge(TDBadgeType.bubble, message: '${data.childrenCount}'),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget commentBuilder(
    BuildContext context,
    CusYooTaskComment data,
    bool isRoot,
    bool hasMore,
  ) {
    return Obx(
      () =>
          controller.curDeletingCommentId.value == data.data.id
              ? Flash(
                preferences: const AnimationPreferences(
                  autoPlay: AnimationPlayStates.Loop,
                  duration: Duration(seconds: 5),
                ),
                child: ColoredBox(
                  color: Colors.blue,
                  child: _commentBuilder(
                    context,
                    data,
                    isRoot,
                    hasMore,
                  ),
                ),
              )
              : _commentBuilder(context, data, isRoot, hasMore),
    );
  }

  Widget _commentBuilder(
    BuildContext context,
    CusYooTaskComment data,
    bool isRoot,
    bool hasMore,
  ) {
    final now = DateTime.timestamp();
    final createDt = localFromMilliSeconds(
      data.data.createdAt.toInt(),
    ).replaceFirst(RegExp('^${now.year}-'), '');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () async {
            controller.curTaskComment.value = data;
            controller.curEditingCommentOldContent.value = '';
            await buildPopupLayerCommentComp(context);
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          Text(
                            data.user.name,
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall!.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                              fontSize: 18,
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 4,
                            child: TDBadge(
                              TDBadgeType.message,
                              message: createDt,
                              color: Colors.lightBlueAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  data.data.content,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    fontWeight: FontWeight.w300,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
        _buildCommentOperations(context, data, isRoot, hasMore),
      ],
    );
  }

  Widget _buildCommentReplyTextWidget(
    BuildContext context,
    String txt, {
    bool reply = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '回复:${txt.substring(0, min(10, txt.length))}',
        style: Theme.of(context).textTheme.bodySmall!.copyWith(
          fontWeight: FontWeight.w300,
          color: Colors.black,
          fontSize: reply ? 20 : 14,
        ),
      ),
    );
  }

  List<Widget> buildAllCommentsVoComp(BuildContext context) {
    var ret = <Widget>[];
    final hasCurLayerMore = controller.hasMoreCommentsData;
    for (var commentVo in controller.popupComments.value.curLayerData!.pages) {
      commentVo.data?.forEach((voData) {
        var ctw = CommentTreeWidget<CusYooTaskComment, CusYooTaskComment>(
          voData,
          voData.children,
          treeThemeData: TreeThemeData(
            lineColor: Colors.green[500]!,
            lineWidth: 3,
          ),
          avatarRoot: (context, data) => avatarBuilder(context, data, true),
          avatarChild: (context, data) => avatarBuilder(context, data, false),
          contentChild:
              // 回复节点不需要点击更多按钮
              (context, data) => commentBuilder(
                context,
                data,
                false,
                false
              ),
          contentRoot:
              (context, data) =>
                  commentBuilder(context, data, true, hasCurLayerMore),
        );
        ret.add(ctw);
      });
    }
    var more = ret.isNotEmpty && hasCurLayerMore;
    // ret.add(Spacer())
    if (more) {
      ret.add(
        InkWell(
          onTap: () async {
            await controller.fetchMoreCommentsData();
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 4,
            children: [
              Text('加载更多', style: TextStyle(color: Colors.blue)),
              Icon(Icons.more_horiz, color: Colors.blue),
            ],
          ),
        ),
      );
    }
    return ret;
  }
}

class GraphEditTaskCommentView extends GraphTaskCommentView {
  const GraphEditTaskCommentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: GetPlatform.isMobile ? 500 : 720,
        ),
        child: buildPopupColEditCommentComp(context),
      ),
    );
  }
}
