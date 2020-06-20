
import 'dart:async';

import 'package:raisingchildrenrecord2/data/recordRepository.dart';
import 'package:raisingchildrenrecord2/model/baby.dart';
import 'package:raisingchildrenrecord2/model/record.dart';
import 'package:raisingchildrenrecord2/viewmodel/baseViewModel.dart';
import 'package:raisingchildrenrecord2/viewmodel/chart/growthStatisticsScheme.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuple/tuple.dart';

class GrowthChartViewModel with ViewModelErrorHandler implements ViewModel {

  Stream<Baby> babyStream;
  RecordRepository recordRepository;

  StreamSubscription _babyAndCurrentIndexSubscription;

  final _currentIndexBehaviorSubject = BehaviorSubject<int>.seeded(0);
  Stream<int> get currentIndex => _currentIndexBehaviorSubject.stream;
  StreamSink<int> get onSelected => _currentIndexBehaviorSubject.sink;

  final _periodBehaviorSubject = BehaviorSubject<GrowthPeriodType>.seeded(GrowthPeriodType.oneYear);
  Stream<GrowthPeriodType> get period => _periodBehaviorSubject.stream;

  final _statisticsDataStreamController = StreamController<GrowthStatisticsData>();
  Stream<GrowthStatisticsData> get statisticsData => _statisticsDataStreamController.stream;

  final _growthChartDataStreamController = StreamController<GrowthChartData>();
  Stream<GrowthChartData> get growthChartData => _growthChartDataStreamController.stream;

  GrowthChartViewModel(this.babyStream, this.recordRepository) {
    _babyAndCurrentIndexSubscription = CombineLatestStream.combine2(
      babyStream,
      _currentIndexBehaviorSubject.stream,
      (baby, currentIndex) => Tuple2<Baby, int>(baby, currentIndex)
    )
    .listen((tuple) {
      final Baby baby = tuple.item1;
      final GrowthPeriodType period = GrowthPeriodTypeExtension.fromIndex(tuple.item2);
      print("### baby: ${baby.name}, period: ${period.months}");
      _periodBehaviorSubject.add(period);

      final growthStatisticsScheme = MHLWGrowthStatisticsScheme();
      final growthStatisticsSet = (baby.sex == Sex.female) ? growthStatisticsScheme.femaleSet : growthStatisticsScheme.maleSet;
      final List<GrowthData> minHeightList = growthStatisticsSet.heightStatistics.floorDataList.where((growData) => growData.month < period.months).toList();
      final List<GrowthData> maxHeightList = growthStatisticsSet.heightStatistics.ceilDataList.where((growData) => growData.month < period.months).toList();
      final List<GrowthData> minWeightList = growthStatisticsSet.weightStatistics.floorDataList.where((growData) => growData.month < period.months).toList();
      final List<GrowthData> maxWeightList = growthStatisticsSet.weightStatistics.ceilDataList.where((growData) => growData.month < period.months).toList();
      _statisticsDataStreamController.sink.add(GrowthStatisticsData(periodType: period, minHeightList: minHeightList, maxHeightList: maxHeightList, minWeightList: minWeightList, maxWeightList: maxWeightList));

      SharedPreferences.getInstance().then((sharedPreferences) {
        final String familyId = sharedPreferences.getString('familyId');

        final from = baby.birthday;
        final to = DateTime(from.year, from.month + period.months, from.day, from.hour, from.minute);
        recordRepository.getRecords(familyId, baby.id, recordTypesIn: [RecordType.height, RecordType.weight], from: from, to: to).then((records) {
          List<GrowthData> heightList = [];
          List<GrowthData> weightList = [];
          records.forEach((record) {
            switch (record.runtimeType) {
              case HeightRecord:
                break; // TODO create GrowthData of height
              case WeightRecord:
                break; // TODO create GrowthData of weight
              default:
                throw 'This line should not be reached';
            }
          });
        })
        .catchError(handleError);
      });
    });
  }

  @override
  void dispose() {
    super.dispose();

    _babyAndCurrentIndexSubscription.cancel();

    _currentIndexBehaviorSubject.close();
    _periodBehaviorSubject.close();
    _statisticsDataStreamController.close();
    _growthChartDataStreamController.close();
  }
}

enum GrowthPeriodType {
  oneYear,
  threeYears,
  sixYears,
}

extension GrowthPeriodTypeExtension on GrowthPeriodType {
  int get months {
    switch (this) {
      case GrowthPeriodType.oneYear:
        return 12;
      case GrowthPeriodType.threeYears:
        return 36;
      case GrowthPeriodType.sixYears:
        return 72;
      default:
        throw 'This line should not be reached.';
    }
  }

  static GrowthPeriodType fromIndex(int index) {
    switch (index) {
      case 0:
        return GrowthPeriodType.oneYear;
      case 1:
        return GrowthPeriodType.threeYears;
      case 2:
        return GrowthPeriodType.sixYears;
      default:
        throw 'This line should not be reached.';
    }
  }
}

class GrowthChartData {
  final GrowthPeriodType periodType;
  final List<GrowthData> heightList;
  final List<GrowthData> weightList;
  GrowthChartData({ this.periodType, this.heightList, this.weightList });
}

class GrowthStatisticsData {
  final GrowthPeriodType periodType;
  final List<GrowthData> minHeightList;
  final List<GrowthData> maxHeightList;
  final List<GrowthData> minWeightList;
  final List<GrowthData> maxWeightList;
  GrowthStatisticsData({ this.periodType, this.minHeightList, this.maxHeightList, this.minWeightList, this.maxWeightList });
}