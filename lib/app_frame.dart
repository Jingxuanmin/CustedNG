import 'package:after_layout/after_layout.dart';
import 'package:custed2/core/update.dart';
import 'package:custed2/data/store/setting_store.dart';
import 'package:custed2/locator.dart';
import 'package:custed2/ui/grade_tab/grade_legacy.dart';
import 'package:custed2/ui/home_tab/home_tab.dart';
import 'package:custed2/ui/bbs_tab/bbs_tab.dart';
import 'package:custed2/ui/schedule_tab/schedule_tab.dart';
import 'package:custed2/ui/theme.dart';
import 'package:custed2/ui/user_tab/user_tab.dart';
import 'package:custed2/ui/widgets/bottom_navbar.dart';
import 'package:flutter/material.dart';

class AppFrame extends StatefulWidget {
  @override
  _AppFrameState createState() => _AppFrameState();
}

class _AppFrameState extends State<AppFrame> with AfterLayoutMixin<AppFrame> {
  double _width;
  int _selectIndex;
  PageController _pageController;

  @override
  void initState() {
    super.initState();
    _selectIndex = locator<SettingStore>().useScheduleAsHome.fetch() ? 1 : 2;
    _pageController = PageController(initialPage: _selectIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: PageView(
        physics: NeverScrollableScrollPhysics(),
        controller: _pageController,
        children: [
          GradeReportLegacy(),
          ScheduleTab(),
          HomeTab(),
          BBSTab(),
          UserTab(),
        ],
      ),
      bottomNavigationBar: _buildBottom(context),
    );
  }

  static const List<NavigationItem> items = [
    NavigationItem(Icon(Icons.leaderboard, size: 29), Text('成绩')),
    NavigationItem(Icon(Icons.calendar_today, size: 27), Text('课表')),
    NavigationItem(Icon(Icons.home, size: 31), Text('主页')),
    NavigationItem(Icon(Icons.navigation, size: 29), Text('导航')),
    NavigationItem(Icon(Icons.settings, size: 29), Text('设置'))
  ];

  Widget _buildItem(NavigationItem item, bool isSelected) {
    bool isDarkMode = isDark(context);
    final width = _width / 5;
    return AnimatedContainer(
      duration: Duration(milliseconds: 377),
      curve: Curves.fastOutSlowIn,
      height: 50,
      width: isSelected ? width : width - 17,
      padding: isSelected ? const EdgeInsets.only(left: 1, right: 1) : null,
      decoration: isSelected
          ? BoxDecoration(
              color: isDarkMode ? Colors.white12 : Colors.black12,
              borderRadius: const BorderRadius.all(Radius.circular(50))
          )
          : null,
      child: item.icon,
    );
  }

  Widget _buildBottom(BuildContext context) {
    return SafeArea(
        child: Container(
          height: 56,
          padding: const EdgeInsets.only(left: 8, top: 4, bottom: 4, right: 8),
          width: _width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: items.map((item) {
              int itemIndex = items.indexOf(item);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectIndex = itemIndex;
                    _pageController.animateToPage(itemIndex,
                        duration: Duration(milliseconds: 677),
                        curve: Curves.fastLinearToSlowEaseIn);
                  });
                },
                child: _buildItem(item, _selectIndex == itemIndex),
              );
            }).toList(),
          ),
        )
    );
  }

  @override
  void afterFirstLayout(BuildContext context) {
    updateCheck(context);
  }
}
