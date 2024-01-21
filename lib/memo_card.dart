import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MemoCard extends StatelessWidget {
  final bool isTapable;
  final SvgPicture pic;
  final int index;
  final Function onCardTapped;

  const MemoCard({
    super.key,
    required this.isTapable,
    required this.pic,
    required this.index,
    required this.onCardTapped,
  });
  static const cardPadding = 5.0;

  @override
  Widget build(BuildContext context) {
    var w = Container(
      padding: const EdgeInsets.all(cardPadding),
      // decoration: BoxDecoration(
      //   border: Border.all(color: Colors.grey.shade400, width: 2.0),
      //   borderRadius: BorderRadius.circular(cardPadding),
      //   color: Colors.white,
      // ),
      child: SizedBox.expand(child: pic),
    );
    if (!isTapable) return w;
    return GestureDetector(
      onTap: () => onCardTapped(index),
      child: w,
    );
  }
}
