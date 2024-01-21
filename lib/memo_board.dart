import 'package:flutter/material.dart';

class MemoBoard extends StatelessWidget {
  final int numberOfPairs;
  final Function genPairs;

  const MemoBoard({
    super.key,
    required this.numberOfPairs,
    required this.genPairs,
  });

  static const minCardSide = 32.0;
  static const boardPadding = 8.0;
  static const spacingBetweenCards = 5.0;

  static int _numberOfColumns({
    required double maxWidth,
    required double maxHeight,
    required int pairCount,
  }) {
    int totalCount = pairCount * 2;
    int columns = 1;
    double maxSide = minCardSide;
    for (int ncols = 1; ncols <= totalCount; ncols++) {
      double side = (maxWidth / ncols).floorToDouble();
      int nlines = (totalCount.toDouble() / ncols.toDouble()).ceil();
      if (side * nlines >= maxHeight) continue;
      if (side > maxSide) {
        maxSide = side;
        columns = ncols;
      }
    }
    return columns;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(boardPadding),
      child: LayoutBuilder(
        builder: (context, constraints) {
          var cols = _numberOfColumns(
            maxWidth: constraints.maxWidth,
            maxHeight: constraints.maxHeight,
            pairCount: numberOfPairs,
          );

          return GridView.count(
            crossAxisCount: cols,
            mainAxisSpacing: spacingBetweenCards,
            crossAxisSpacing: spacingBetweenCards,
            children: genPairs(),
          );
        },
      ),
    );
  }
}
