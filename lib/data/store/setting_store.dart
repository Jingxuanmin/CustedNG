import 'package:custed2/core/store/presistent_store.dart';

class SettingStore with PresistentStore {
  @override
  final boxName = 'setting';

  StoreProperty<bool> get useScheduleAsHome =>
      property('useScheduleAsHome', defaultValue: false);

  StoreProperty<bool> get showFestivalAndHoliday =>
      property('showFestivalAndHoliday', defaultValue: true);

  StoreProperty<bool> get showInactiveLessons =>
      property('showInactiveLessons', defaultValue: true);

  StoreProperty<bool> get autoUpdateSchedule =>
      property('autoUpdateSchedule', defaultValue: true);

  StoreProperty<bool> get autoUpdateWeather =>
      property('autoUpdateWeather', defaultValue: true);

  StoreProperty<bool> get dontCountElectiveCourseGrade =>
      property('dontCountElectiveCourseGrade', defaultValue: false);

  StoreProperty<bool> get agreeToShowExam =>
      property('agreeToShowExam', defaultValue: false);

  StoreProperty<bool> get showTipOnViewingExam =>
      property('showTipOnViewingExam', defaultValue: true);

  //default value 0 is Dark.auto
  StoreProperty<int> get darkMode =>
      property('darkMode', defaultValue: 0);

  StoreProperty<int> get ignoreUpdate => property('ignoreUpdate');

  StoreProperty<String> get notification => property('notification');
}
