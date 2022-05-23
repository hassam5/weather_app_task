import 'package:flutter/material.dart';

import '../../model/filter_forcast.dart';
import '../../model/forcast.dart';

class ForcastWidget extends StatefulWidget {
  List<FilterForcast>? filteredForcast;

  ForcastWidget(this.filteredForcast);

  @override
  State<ForcastWidget> createState() => _ForcastWidgetState();
}

class _ForcastWidgetState extends State<ForcastWidget> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Column(
        children: [
          horizentolDivider(),
          showTabar(),
          horizentolDivider(),
          showDetailFragment(widget.filteredForcast![selectedIndex]),
        ],
      ),
    );
  }

  Widget horizentolDivider() {
    return Container(
      width: double.infinity,
      height: 1,
      color: Colors.grey,
    );
  }

  Widget showTabar() {
    return Container(
      height: 40,
      child: ListView.separated(
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              setState(() {
                widget.filteredForcast![selectedIndex].isSelected = false;
                widget.filteredForcast![index].isSelected = true;
                selectedIndex = index;
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.center,
              color: widget.filteredForcast![index].isSelected ? Colors.grey : Colors.transparent,
              child: Text(
                widget.filteredForcast![index].date,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
        itemCount: widget.filteredForcast!.length,
        scrollDirection: Axis.horizontal,
        separatorBuilder: (BuildContext context, int index) {
          return Container(
            width: 1,
            height: 50,
            color: Colors.grey,
          );
        },
      ),
    );
  }

  Widget showDetailFragment(FilterForcast filterForcast) {
    // Day
    // Weather description
    // Temperature in Celsius Degrees (current, min and max)
    return filterForcast.list!.length == 0
        ? Center(
            child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text("Sorry, No Data available for this day"),
          ))
        : Container(
            width: double.infinity,
            child: ListView.separated(
              itemBuilder: (context, index) {
                return Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.all(
                      Radius.circular(12),
                    ),
                  ),
                  child: Column(
                    children: [
                      showItem(
                        "Time",
                        filterForcast.list![index].time ?? "",
                        color: Colors.green,
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      showItem(
                        "Description:",
                        showDescription(filterForcast.list![index].weather),
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      showItem("Current Temperature", filterForcast.list![index].main!.temp.toString()+" C"),
                      SizedBox(
                        height: 12,
                      ),
                      showItem("Min Temperature", filterForcast.list![index].main!.tempMin.toString()+" C"),
                      SizedBox(
                        height: 12,
                      ),
                      showItem("Max Temperature", filterForcast.list![index].main!.tempMax.toString()+" C"),
                      SizedBox(
                        height: 12,
                      ),
                      showItem("Humidity", filterForcast.list![index].main!.humidity.toString() + "%"),
                    ],
                  ),
                );
              },
              separatorBuilder: (context, index) {
                return SizedBox(
                  height: 12,
                );
              },
              itemCount: filterForcast.list!.length,
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: EdgeInsets.all(12),
            ),
          );
  }

  Widget showItem(String title, String value, {Color color = Colors.black}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 16, color: color),
        ),
      ],
    );
  }

  String showDescription(final List<Weather>? weather) {
    String description = "";
    weather!.forEach((element) {
      description = description + (element.description ?? "") + " | ";
    });
    return description;
  }
}
