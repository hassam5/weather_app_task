import 'package:weather_test_app/model/forcast.dart';

class FilterForcast {
  String date;
  final List<ListElement>? list;
  bool isSelected;

  FilterForcast(this.date, this.list, this.isSelected);
}
