import 'package:yx/api/duty_provider.dart';
import 'package:yx/vo/duty_vo.dart';
import 'package:yx/vo/room_vo.dart';
import 'package:yx/vo/user_info_vo.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:toastification/toastification.dart';

import '../../../api/department_provider.dart';
import '../../../api/user_provider.dart';

class TaskCreationController extends GetxController {
  final int totalSteps = 3;
  final DepartmentProvider departmentProvider = Get.put(DepartmentProvider());
  final UserProvider userProvider = Get.find();
  final DutyProvider dutyProvider = Get.find();
  RxInt currentStep = 1.obs;
  RxString superTaskId = ''.obs;
  RxString dutyName = ''.obs;
  RxString dutyType = ''.obs;
  RxString dutyTypeSubTitle = ''.obs;
  RxString responsibleDepartmentId = ''.obs;
  RxString collaborativeDepartmentId = ''.obs;
  RxString dutyImportance = '一般'.obs;
  RxString dutyUrgency = '一般'.obs;
  RxString dutyEndDate = ''.obs;
  RxList<RoomVo> departmentNameList = <RoomVo>[].obs;
  RxList<DutyVo> parentDutyList = <DutyVo>[].obs;

  // 修改管控方式为单选
  RxString selectedControlMethod = '按日'.obs;

  // 修改延期选择为单选
  RxString responsibleIfPostpone = '0'.obs;

  //进度考核方式为单选
  RxString processAssessmentMethod = '2'.obs;

  RxList<Map<String, dynamic>> assigneeList = <Map<String, dynamic>>[
  ].obs;

  final formKeyStep1 = GlobalKey<FormState>();
  final formKeyStep2 = GlobalKey<FormState>();

  //管理组件初始化
  RxBool isStep3Initialized = false.obs;
  @override
  void onInit() {
    super.onInit();
    initialize();
    // 监听步骤变化
    ever(currentStep, (int step) {
      if (step == 3 && !isStep3Initialized.value) {
        initializeAssigneeList();
        isStep3Initialized.value = true;
      }
    });
  }



  //获取科室信息
  Future<void> initialize() async {
    departmentProvider.onInit();
    //初始化科室信息，改成使用接口
    departmentNameList.value = await departmentProvider.getYunWangDepartmentRoomsList();
    //初始化父任务列表
    parentDutyList.value = await dutyProvider.getDutyList();
  }

  void nextStep() {
    if (currentStep.value < totalSteps) {
      currentStep.value++;
    }
  }

  void previousStep() {
    if (currentStep.value > 1) {
      currentStep.value--;
    }
  }

  //上传任务
  void submitDuty(){
    final leaders = assigneeList.where((user) => user['isLeader'].value).map((user) =>ResponsiblePerson(responsibleId:user['data']['userId'],responsibleType:1) ).toList();
    final participants = assigneeList.where((user) => user['isParticipant'].value).map((user) => DutyParticipant(responsibleId:user['data']['userId'],responsibleType:2) ).toList();

    if (leaders.isEmpty) {
      toastification.show(
        type: ToastificationType.info,
        title: Text("请至少选择一个分配对象"),
        autoCloseDuration: const Duration(seconds: 3),
      );
      return;
    }
    
    dutyProvider.createDuty(
        DutyVo(dutyName: dutyName.value,
      dutyType: dutyType.value,
      dutyTypeSubTitle: dutyTypeSubTitle.value,
      responsibleDepartment : [RoomVo(departmentId: responsibleDepartmentId.value)],
      collaborativeDepartment: [RoomVo(departmentId: collaborativeDepartmentId.value)],
      dutyImportance: dutyImportance.value,
      dutyUrgency: dutyUrgency.value,
      dutyEndDate: dutyEndDate.value.toString(),
      controlMethod: selectedControlMethod.value,
      responsibleIfPostpone : int.tryParse(responsibleIfPostpone.value),
      dutyQuantificationMethod : int.tryParse(processAssessmentMethod.value),
      parentDutyId: superTaskId.value,
      responsiblePerson:leaders,
      dutyParticipant: participants,)
    );
  }

//根据选择的科室获取员工清单
  Future<void> initializeAssigneeList() async {
    assigneeList.clear();
    RxList<UserInfoVo> tmpUserList = <UserInfoVo>[].obs;
    tmpUserList.addAll(await userProvider.getUserByOrgId(responsibleDepartmentId.value));
    tmpUserList.addAll(await userProvider.getUserByOrgId(collaborativeDepartmentId.value));
    for(var userInfo in tmpUserList){
      Map<String, dynamic> convertedItem = {
        'id':assigneeList.length,
        'data': userInfo.toJson(),
        'isLeader': false.obs,
        'isParticipant': false.obs,
      };
      assigneeList.add(convertedItem);
    }

  }

  // 切换选择状态
  void toggleSelection(int index, bool isLeader) {
    if (isLeader) {
      assigneeList[index]['isLeader'].value = !assigneeList[index]['isLeader'].value;
      if (assigneeList[index]['isLeader'].value) {
        assigneeList[index]['isParticipant'].value= false;
      }
    } else {
      assigneeList[index]['isParticipant'].value = !assigneeList[index]['isParticipant'].value;
      if (assigneeList[index]['isParticipant'].value) {
        assigneeList[index]['isLeader'].value = false;
      }
    }
  }
  void completeTask() {
    submitDuty();
    // 处理任务提交逻辑
    Get.back();
  }
}
