import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:yababos/models/tag.dart';

class TagChart extends StatefulWidget {
  final Map<Tag, double> chartData;
  const TagChart({super.key, required this.chartData});

  @override
  State<StatefulWidget> createState() => TagChartState();
}

class TagChartState extends State<TagChart> {
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.8,
      child: Card(
        child: PieChart(
          PieChartData(
            centerSpaceRadius: 40,
            sections: getSections(),
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> getSections() {
    List<PieChartSectionData> sectionDatas = List.empty(growable: true);
    widget.chartData.forEach((key, value) {
      sectionDatas.add(PieChartSectionData(
        color: key.color.withOpacity(.9),
        borderSide: BorderSide(color: key.color, width: 1.5),
        value: value,
        title: key.name,
      ));
    });
    return sectionDatas;
  }
}
