import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:group_button/group_button.dart';
import 'package:yx/root/nest_nav_key.dart';
import 'package:yx/types.dart';
import 'package:yx/utils/common_util.dart';

mixin CommonOrganizationView {
  UserCenterPageParams get pageParams;

  Widget buildBody(BuildContext context);

  Widget buildScaffold(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pageParams.action.i18name, style: defaultTitleStyle),
      ),
      body: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 20),
        child:
            isBigScreen(context)
                ? ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 500),
                  child: buildBody(context),
                )
                : buildBody(context),
      ),
    );
  }
}

class OrganizationView extends StatefulWidget {
  OrganizationView({super.key, required this.params}) {
    assert(
      params.action == UserCenterAction.joinOrganization ||
          params.action == UserCenterAction.switchOrganization,
    );
  }

  final UserCenterPageParams params;

  @override
  OrganizationViewState createState() => OrganizationViewState();
}

class OrganizationViewState extends State<OrganizationView>
    with CommonOrganizationView {
  @override
  void initState() {
    super.initState();
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Expanded(
        //   child:
          GroupButton<int>(
            isRadio: true,
            buttons: List.generate(20, (i) => i + 1),
            buttonTextBuilder:
                (selected, content, context) => content.toString(),
          ),
        // ),
        const SizedBox(height: 20,),
        _buildOrganizationActions(context),
      ],
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
    with CommonOrganizationView {
  final _formKey = GlobalKey<FormState>();
  final _nameTxtController = TextEditingController();
  final _addressTxtController = TextEditingController();
  final _remarkTxtController = TextEditingController();

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

  Widget _buildOrganizationForm(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: ListView(
        children: [
          _buildNameTextField(context),
          _buildAddressTextField(context),
          _buildRemarkTextField(context),
          SizedBox(height: 40,),
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
