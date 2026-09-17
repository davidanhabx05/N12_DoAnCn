import 'package:flutter/material.dart';
import '../../models/menu_plan.dart';

class MenuViewModel extends ChangeNotifier {
  final List<MenuPlan> _allMenuPlans = [
    // Đang áp dụng
    MenuPlan(
      id: 'active_1',
      title: 'Thực đơn tăng cơ tuần 4 tháng 9',
      date: DateTime.now(),
      status: 'active',
      dishIds: ['1', '4', '8'],
    ),
    // Nháp
    MenuPlan(
      id: 'draft_1',
      title: 'Thực đơn cuối tuần ăn lẩu',
      date: DateTime.now().subtract(const Duration(days: 1)),
      status: 'draft',
      dishIds: [],
    ),
    MenuPlan(
      id: 'draft_2',
      title: 'Ý tưởng món ngon đãi khách',
      date: DateTime.now().subtract(const Duration(days: 2)),
      status: 'draft',
      dishIds: [],
    ),
    // Lịch sử
    MenuPlan(
      id: 'history_1',
      title: 'Tuần 1 tháng 9 - Ăn chay',
      date: DateTime.now().subtract(const Duration(days: 20)),
      status: 'history',
      dishIds: ['1', '5', '7'],
    ),
    MenuPlan(
      id: 'history_2',
      title: 'Tuần 2 tháng 9 - Đủ chất',
      date: DateTime.now().subtract(const Duration(days: 13)),
      status: 'history',
      dishIds: ['2', '3', '6'],
    ),
  ];

  List<MenuPlan> get allMenuPlans => _allMenuPlans;

  void addMenuPlan(String title, String description) {
    // Mặc định thêm vào mục Nháp khi nhấn từ bất kỳ đâu (hoặc có thể tùy biến)
    final newPlan = MenuPlan(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      date: DateTime.now(),
      status: 'draft',
      dishIds: [],
    );
    _allMenuPlans.insert(0, newPlan);
    notifyListeners();
  }
}
