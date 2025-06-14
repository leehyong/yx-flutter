import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yt_dart/cus_tree.pb.dart';
import 'package:yt_dart/cus_user_organization.pb.dart';
import 'package:yt_dart/generate_sea_orm_new.pb.dart';
import 'package:yt_dart/generate_sea_orm_query.pb.dart';
import 'package:yx/api/organization_api.dart' as organization_api;
import 'package:yx/components/common.dart';
import 'package:yx/root/nest_nav_key.dart';
import 'package:yx/types.dart';
import 'package:yx/utils/common_util.dart';
import 'package:yx/utils/common_widget.dart';
import 'package:yx/utils/toast.dart';

import '../mixin.dart';

class JoinableOrganizationView extends StatefulWidget {
  JoinableOrganizationView({super.key, required this.params}) {
    assert(params.action == UserCenterAction.joinOrganization);
  }

  final UserCenterPageParams params;

  @override
  JoinableOrganizationViewState createState() =>
      JoinableOrganizationViewState();
}

class JoinableOrganizationViewState extends State<JoinableOrganizationView>
    with CommonUserCenterView, CommonEasyRefresherMixin {
  final PageReq _pageReq = PageReq();
  var _initLoading = false;
  var _checkedOrganizationId = Int64.ZERO;
  var _isEmpty = false;
  final TreeNode<CusYooOrganizationTree> _rootTreeData =
      TreeNode<CusYooOrganizationTree>.root();

  @override
  void initState() {
    super.initState();
    setState(() {
      _initLoading = true;
    });
    loadData().whenComplete(() {
      _initLoading = false;
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    _rootTreeData.clear();
  }

  @override
  Widget build(BuildContext context) => buildScaffold(context);

  Widget _buildOrganizationActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () {
            Get.back(id: NestedNavigatorKeyId.userCenterId);
          },
          child: Text('取消'),
        ),
        const SizedBox(width: 30),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue, // 背景色
            foregroundColor: Colors.white,
            // padding: EdgeInsets.all(4),
            // 文字颜色
          ),
          onPressed: () {
            Get.back(id: NestedNavigatorKeyId.userCenterId);
          },
          child: Text('确认'),
        ),
      ],
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    if (_initLoading) {
      return buildLoading(context);
    }
    return buildEasyRefresher(context);
  }

  @override
  UserCenterPageParams get pageParams => widget.params;

  Widget _buildOrganizationItem(BuildContext context, Organization data) {
    return RadioListTile(
      title: Text(
        data.name,
        style: TextStyle(overflow: TextOverflow.ellipsis, fontSize: 16),
      ),
      subtitle: Row(
        children: [
          const Text(
            '创建时间',
            style: TextStyle(overflow: TextOverflow.ellipsis, fontSize: 12),
          ),
          Text(
            localFromMilliSeconds(data.createdAt.toInt()),
            style: TextStyle(
              overflow: TextOverflow.ellipsis,
              fontSize: 12,
              color: Colors.lightBlueAccent,
            ),
          ),
        ],
      ),
      value: data.id,
      groupValue: _checkedOrganizationId,
      onChanged: (v) {
        setState(() {
          _checkedOrganizationId = v!;
        });
      },
    );
  }

  Widget _buildOrganizationTree(BuildContext context) {
    return TreeView.simpleTyped<
      CusYooOrganizationTree,
      TreeNode<CusYooOrganizationTree>
    >(
      showRootNode: false,
      // focusToNewNode: true,
      tree: _rootTreeData,
      expansionBehavior: ExpansionBehavior.collapseOthers,
      // expansionIndicatorBuilder:
      //     (cxt, node) =>
      //         node.childrenAsList.isEmpty
      //             ? NoExpansionIndicator(tree: node)
      //             : ChevronIndicator.rightDown(
      //               tree: node,
      //               padding: EdgeInsets.all(8),
      //             ),
      shrinkWrap: true,
      indentation: const Indentation(style: IndentStyle.roundJoint),
      builder: (context, node) {
        // 不显示根节点
        if (node.key == INode.ROOT_KEY) {
          return SizedBox.shrink();
        } else if (node.key == hasMoreData || node.key == noMoreData) {
          return buildLoadMoreTipAction(
            context,
            _pageReq.hasMore,
            () => _loadData(),
          );
        }
        return buildRandomColorfulBox(
          _buildOrganizationItem(context, node.data!.data),
          node.data!.data.id.toInt(),
        );
      },
      onItemTap: (node) {
        debugPrint("${node.level}");
      },
    );
  }

  @override
  Widget buildRefresherChildDataBox(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child:
              _isEmpty ? emptyWidget(context) : _buildOrganizationTree(context),
        ),
        const SizedBox(height: 20),
        _buildOrganizationActions(context),
      ],
    );
  }

  void _buildTreeData(
    TreeNode<CusYooOrganizationTree> parent,
    CusYooOrganizationTree childData,
  ) {
    final headerId = childData.data.id;
    final node = TreeNode(key: treeNodeKey(headerId), data: childData);
    parent.add(node);
    for (var child in childData.children) {
      _buildTreeData(node, child);
    }
  }

  Future<bool> _loadData() async {
    if (!_pageReq.hasMore) {
      warnToast("没有更多数据了");
      return true;
    } else {
      final data = await organization_api.queryJoinableOrganizations(
        _pageReq.page,
        _pageReq.limit,
      );
      if (data.error == null || data.error!.isEmpty) {
        final trees = data.data ?? <CusYooOrganizationTree>[];
        _isEmpty = trees.isEmpty;
        assert(_pageReq.limit == data.limit);
        _pageReq.hasMore = _pageReq.page < data.totalPages;
        _pageReq.page++;
        for (var child in trees) {
          _buildTreeData(_rootTreeData, child);
        }
        TreeNode<CusYooOrganizationTree> tmp;
        if (_pageReq.hasMore) {
          tmp = TreeNode(
            data: CusYooOrganizationTree(data: Organization(name: '加载更多')),
            key: hasMoreData,
          );
        } else {
          tmp = TreeNode(
            data: CusYooOrganizationTree(data: Organization(name: '没有更多数据了')),
            key: noMoreData,
          );
        }
        _rootTreeData.add(tmp);
        return true;
      }
      return false;
    }
  }

  @override
  Future<void> loadData() async {
    _loadData().then((success) {
      setState(() {});
      if (success) {
        refreshController.finishLoad(
          _pageReq.hasMore ? IndicatorResult.noMore : IndicatorResult.success,
        );
      } else {
        refreshController.finishLoad(IndicatorResult.fail);
      }
    });
  }

  @override
  Future<void> refreshData() async {
    _loadData().then((success) {
      setState(() {});
      if (success) {
        refreshController.finishRefresh(
          _pageReq.hasMore ? IndicatorResult.noMore : IndicatorResult.success,
        );
      } else {
        refreshController.finishRefresh(IndicatorResult.fail);
      }
      refreshController.resetFooter();
    });
  }

  @override
  JoinableOrganizationViewState get widgetState => this;
}

class SwitchableOrganizationView extends StatefulWidget {
  SwitchableOrganizationView({super.key, required this.params}) {
    assert(params.action == UserCenterAction.switchOrganization);
  }

  final UserCenterPageParams params;

  @override
  SwitchableOrganizationViewState createState() =>
      SwitchableOrganizationViewState();
}

class SwitchableOrganizationViewState extends State<SwitchableOrganizationView>
    with CommonUserCenterView {
  late final List<SwitchableOrganization> _organizations;
  var _initLoading = false;
  SwitchableOrganization? _checkedSwitchOrg;

  @override
  void initState() {
    super.initState();
    setState(() {
      _initLoading = true;
    });
    organization_api.querySwitchableOrganizations().then((v) {
      setState(() {
        _organizations = v;
        _initLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) => buildScaffold(context);

  Widget _buildOrganizationActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () {
            Get.back(id: NestedNavigatorKeyId.userCenterId);
          },
          child: Text('取消'),
        ),
        const SizedBox(width: 30),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue, // 背景色
            foregroundColor: Colors.white,
            // padding: EdgeInsets.all(4),
            // 文字颜色
          ),
          onPressed: () {
            if (_checkedSwitchOrg != null) {
              organization_api
                  .switchOrganization(
                    _checkedSwitchOrg!.organization.id,
                    _checkedSwitchOrg!.role.id,
                  )
                  .then((success) {
                    if (success) {
                      Get.back(id: NestedNavigatorKeyId.userCenterId);
                    }
                  });
            } else {
              Get.back(id: NestedNavigatorKeyId.userCenterId);
            }
          },
          child: Text('确认'),
        ),
      ],
    );
  }

  Widget _buildOrganizationList(BuildContext context) {
    return ListView(
      children:
          _organizations
              .map((org) => _buildOrganizationItem(context, org))
              .toList(),
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    if (_initLoading) {
      return buildLoading(context);
    }
    return Column(
      children: [
        Expanded(
          child:
              _organizations.isEmpty
                  ? emptyWidget(context)
                  : _buildOrganizationList(context),
        ),
        _buildOrganizationActions(context),
      ],
    );
  }

  Widget _buildTitle(
    BuildContext context,
    String name,
    String title,
    double fontSize,
  ) => Row(
    spacing: 4,
    children: [
      Text('$name:'),
      Tooltip(
        message: title,
        child: Text(
          title,
          style: TextStyle(fontSize: fontSize, overflow: TextOverflow.ellipsis),
        ),
      ),
    ],
  );

  Widget _buildOrganizationItem(
    BuildContext context,
    SwitchableOrganization org,
  ) {
    return buildRandomColorfulBox(
      RadioListTile(
        title: _buildTitle(context, '名称', org.organization.name, 16.0),
        subtitle: _buildTitle(context, '角色', org.role.name, 12.0),
        value: org,
        groupValue: _checkedSwitchOrg,
        onChanged: (v) {
          setState(() {
            _checkedSwitchOrg = v;
          });
        },
      ),
      org.organization.id.toInt() + org.role.id.toInt(),
    );
  }

  @override
  UserCenterPageParams get pageParams => widget.params;
}

class RegisterOrganizationView extends StatefulWidget {
  RegisterOrganizationView({super.key, required this.params}) {
    assert(params.action == UserCenterAction.registerOrganization);
  }

  final UserCenterPageParams params;

  @override
  RegisterOrganizationViewState createState() =>
      RegisterOrganizationViewState();
}

class RegisterOrganizationViewState extends State<RegisterOrganizationView>
    with CommonUserCenterView {
  final _formKey = GlobalKey<FormState>();
  final _nameTxtController = TextEditingController();
  final _addressTxtController = TextEditingController();
  final _remarkTxtController = TextEditingController();
  var _joinStrategy = OrganizationJoinStrategy.public;
  var _whetherRelateCurrentOrganization = false;

  @override
  void initState() {
    super.initState();
  }

  Widget _buildNameTextField(BuildContext context) {
    return TextFormField(
      controller: _nameTxtController,
      validator: (v) {
        if (v!.isEmpty) {
          return '组织名不能为空';
        }
        return null;
      },
      decoration: InputDecoration(labelText: "组织名", icon: Icon(Icons.layers)),
    );
  }

  Widget _buildAddressTextField(BuildContext context) {
    return TextFormField(
      controller: _addressTxtController,
      validator: (v) {
        if (v!.isEmpty) {
          return '位置信息不能为空';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "位置",
        icon: Icon(Icons.location_on_outlined),
      ),
    );
  }

  Widget _buildRemarkTextField(BuildContext context) {
    return TextFormField(
      controller: _remarkTxtController,
      decoration: InputDecoration(labelText: "备注", icon: Icon(Icons.reorder)),
    );
  }

  Widget _buildJoinStrategy(BuildContext context) {
    return DropdownButtonFormField(
      value: _joinStrategy,
      decoration: InputDecoration(
        labelText: '组织加入方式',
        icon: Icon(Icons.gas_meter),
      ),
      items:
          OrganizationJoinStrategy.values
              .map(
                (item) =>
                    DropdownMenuItem(value: item, child: Text(item.i18name)),
              )
              .toList(),
      onChanged: (v) {
        setState(() {
          _joinStrategy = v!;
        });
      },
    );
  }

  Widget _buildOrganizationActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () {
            Get.back(id: NestedNavigatorKeyId.userCenterId);
          },
          child: Text('取消'),
        ),
        const SizedBox(width: 30),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue, // 背景色
            foregroundColor: Colors.white,
            // padding: EdgeInsets.all(4),
            // 文字颜色
          ),
          onPressed: () {
            Int64 parentId = Int64.ZERO;
            if (_whetherRelateCurrentOrganization) {
              parentId = Int64(-1);
            }
            organization_api
                .registerOrganization(
                  parentId,
                  NewOrganization(
                    name: _nameTxtController.text,
                    address: _addressTxtController.text,
                    remark: _remarkTxtController.text,
                    joinStrategy: _joinStrategy.index,
                  ),
                )
                .then((v) {
                  if (v) {
                    // 注册成功后，再回退
                    Get.back(id: NestedNavigatorKeyId.userCenterId);
                  }
                });
          },
          child: Text('确认'),
        ),
      ],
    );
  }

  Widget _buildWhetherCurrentOrganization(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Switch(
          value: _whetherRelateCurrentOrganization,
          onChanged: (nv) {
            setState(() {
              _whetherRelateCurrentOrganization = nv;
            });
          },
        ),
        const SizedBox(width: 10),
        Text(
          '是否关联当前组织',
          style: TextStyle(
            color: _whetherRelateCurrentOrganization ? Colors.red : Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildOrganizationForm(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: ListView(
        children: [
          _buildNameTextField(context),
          const SizedBox(height: 10),
          _buildAddressTextField(context),
          const SizedBox(height: 10),
          _buildRemarkTextField(context),
          const SizedBox(height: 10),
          _buildJoinStrategy(context),
          const SizedBox(height: 10),
          _buildWhetherCurrentOrganization(context),
          const SizedBox(height: 40),
          _buildOrganizationActions(context),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => buildScaffold(context);

  @override
  Widget buildBody(BuildContext context) {
    return Column(children: [Expanded(child: _buildOrganizationForm(context))]);
  }

  @override
  UserCenterPageParams get pageParams => widget.params;
}
