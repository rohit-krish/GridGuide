import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/progress_indicator_provider.dart';

class ProgressIndicatorWidget extends StatelessWidget {
  final double width;
  const ProgressIndicatorWidget(this.width, {super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProgressIndicatorProvider>(context);
    return CircularPercentIndicator(
        radius: width * .08,
        percent: provider.currentPercent / 100,
        progressColor: Colors.indigo,
        backgroundColor: Colors.indigo.shade100,
        circularStrokeCap: CircularStrokeCap.round,
        center: Text(
          '${provider.currentPercent.toInt()}%',
          textAlign: TextAlign.center,
        ),
      );
  }
}
