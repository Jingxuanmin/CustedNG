import 'dart:async';

import 'package:custed2/core/provider/busy_provider.dart';
import 'package:custed2/data/models/jw_exam.dart';
import 'package:custed2/data/store/exam_store.dart';
import 'package:custed2/locator.dart';
import 'package:custed2/service/custed_service.dart';
import 'package:custed2/service/jw_service.dart';

int sortExamByTime(JwExamRows a, JwExamRows b) {
  return a.examTask.beginDate.compareTo(b.examTask.beginDate);
}

class ExamProvider extends BusyProvider {
  JwExamData data;
  var show = false;
  var failed = false;

  Timer _updateTimer;

  Future<void> init() async {
    show = await CustedService().getShouldShowExam();

    if (!show) {
      return;
    }

    setBusyState(true);
    await refreshData();
    startAutoRefresh();
  }

  JwExamRows getNextExam() {
    if (data == null) {
      return null;
    }

    for (JwExamRows exam in data.rows) {
      final examTime =
          exam.examTask.beginDate.substring(0, 11)
              + exam.examTask.beginTime.substring(6);

      if (DateTime.parse(examTime).isAfter(DateTime.now())) {
        return exam;
      }
    }

    return null;
  }

  int getRemainExam(){
    if (data == null) {
      return null;
    }

    for (JwExamRows exam in data.rows) {
      final examTime =
          exam.examTask.beginDate.substring(0, 11) + exam.examTask.beginTime;

      if (DateTime.parse(examTime).isAfter(DateTime.now())) {
        return data.rows.length - data.rows.indexOf(exam);
      }
    }

    return 0;
  }

  void refreshData() async {
    final examStore = await locator.getAsync<ExamStore>();
    try {
      final exam = await JwService().getExam();
      data = exam.data;
      examStore.put(data);
    } catch(e) {
      failed = true;
      print('use cached exam data.');
      data = examStore.fetch();
    } finally {
      setBusyState(false);
    }
    if (data == null) return;
    data.rows.sort((a, b) => sortExamByTime(a, b));
  }

  void startAutoRefresh() {
    if (_updateTimer != null && _updateTimer.isActive) {
      return;
    }

    _updateTimer = Timer.periodic(Duration(minutes: 1), (timer) async {
      notifyListeners();
    });
  }
}
