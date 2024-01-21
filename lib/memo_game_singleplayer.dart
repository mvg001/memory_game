import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'memo_board.dart';
import 'memo_card.dart';

import 'images_mgr.dart';

class MemoGameSinglePlayer extends StatefulWidget {
  const MemoGameSinglePlayer({super.key});

  @override
  State<MemoGameSinglePlayer> createState() => _MemoGameSinglePlayerState();
}

class _MemoGameSinglePlayerState extends State<MemoGameSinglePlayer> {
  static const cardUnset = -1;
  static const picUnset = -1;

  static const minNumberOfPairs = 6;
  static const maxNumberOfPairs = 36;
  static const numberOfChoices = 11;

  static const timeout = Duration(seconds: 2);
  int numberOfPairs = 0;
  int numberOfPairsLeft = 0;
  late List<int> cards;
  int card1 = cardUnset;
  int card2 = cardUnset;
  late Timer tt;
  int numberOfCardsUp = 0;
  var stopwatch = Stopwatch();

  @override
  Widget build(BuildContext context) {
    if (numberOfCardsUp > 0 && numberOfPairsLeft == 0) {
      stopwatch.stop();
      return showStatistics();
    }
    if (numberOfPairs > 0 && numberOfPairsLeft == numberOfPairs) {
      numberOfCardsUp = 0;
      stopwatch.start();
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memo'),
        centerTitle: true,
        actions: [getNumberOfPairs()],
      ),
      body: numberOfPairsLeft > 0
          ? MemoBoard(numberOfPairs: numberOfPairs, genPairs: genPairs)
          : genWarning(context),
    );
  }

  Widget showStatistics() {
    final timeElapsed = stopwatch.elapsed;
    const internalPadding = EdgeInsets.all(8.0);
    final headerBackgroundColor = Colors.amber[900];
    final txtStyle = Theme.of(context).textTheme.titleLarge;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        centerTitle: true,
      ),
      body: Center(
        child: Table(
          border: TableBorder.all(color: Colors.white),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          defaultColumnWidth: const IntrinsicColumnWidth(),
          children: [
            TableRow(children: [
              TableCell(
                child: Container(
                  padding: internalPadding,
                  color: headerBackgroundColor,
                  alignment: Alignment.centerRight,
                  child: Text('#Card Pairs:', style: txtStyle),
                ),
              ),
              TableCell(
                child: Container(
                  padding: internalPadding,
                  alignment: Alignment.centerRight,
                  child: Text(numberOfPairs.toString(), style: txtStyle),
                ),
              ),
            ]),
            TableRow(children: [
              TableCell(
                child: Container(
                  padding: internalPadding,
                  color: headerBackgroundColor,
                  alignment: Alignment.centerRight,
                  child: Text('#Cards up:', style: txtStyle),
                ),
              ),
              TableCell(
                child: Container(
                  padding: internalPadding,
                  alignment: Alignment.centerRight,
                  child: Text(numberOfCardsUp.toString(), style: txtStyle),
                ),
              ),
            ]),
            TableRow(children: [
              TableCell(
                child: Container(
                  padding: internalPadding,
                  color: headerBackgroundColor,
                  alignment: Alignment.centerRight,
                  child: Text('Elapsed time:', style: txtStyle),
                ),
              ),
              TableCell(
                child: Container(
                  padding: internalPadding,
                  alignment: Alignment.centerRight,
                  child: Text(displayDuration(timeElapsed), style: txtStyle),
                ),
              ),
            ]),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() {
          stopwatch.reset();
          numberOfCardsUp = 0;
        }),
        child: const Icon(Icons.replay),
      ),
    );
  }

  String displayDuration(Duration d) {
    var sb = StringBuffer();
    int secs = d.inSeconds % 60;
    int mins = d.inMinutes;
    if (mins != 0) sb.write('$mins min ');
    if (secs != 0) sb.write('$secs sec');
    return sb.toString();
  }

  Widget genWarning(BuildContext context) {
    return Center(
      child: Text(
        'Select # of pairs with the icon above',
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }

  void _onNumberOfPairsSelected(int value) {
    numberOfPairsLeft = numberOfPairs = value;
    var subset = ImageAssetsManager.shuffledSubset(numberOfPairs);
    cards = List<int>.filled(2 * numberOfPairs, cardUnset);
    for (int i = 0; i < numberOfPairs; i++) {
      cards[i] = subset[i];
      cards[(i + numberOfPairs) % cards.length] = subset[i];
    }
    subset.clear();
    cards.shuffle();
    for (int i = 0; i < cards.length; i++) {
      var j = (i + 1) % cards.length;
      var k = (i + 3) % cards.length;
      if (cards[i] == cards[j]) {
        var tmp = cards[k];
        cards[k] = cards[i];
        cards[i] = tmp;
      }
    }
    setState(() {
      card1 = card2 = cardUnset;
    });
  }

  Widget getNumberOfPairs() {
    return PopupMenuButton<int>(
      onSelected: _onNumberOfPairsSelected,
      itemBuilder: (context) => genChoices(
        min: minNumberOfPairs,
        max: min(maxNumberOfPairs, ImageAssetsManager.totalNumber()),
        nChoices: numberOfChoices,
      ),
    );
  }

  List<PopupMenuItem<int>> genChoices({
    required int min,
    required int max,
    required int nChoices,
  }) {
    double slope = (max - min).toDouble() / (nChoices - 1).toDouble();
    List<PopupMenuItem<int>> lst = [];
    for (int i = 0; i < nChoices; i++) {
      int v = (slope * i + min).round();
      lst.add(PopupMenuItem<int>(
        value: v,
        child: Text('$v pairs'),
      ));
    }
    return lst;
  }

  void _onTap(int index) {
    if (index == card1 || index == card2) return;
    if (card1 == cardUnset) {
      numberOfCardsUp++;
      setState(() => card1 = index);
      tt = Timer(timeout, _onFuture);
      return;
    }
    if (card2 == cardUnset) {
      numberOfCardsUp++;
      if (cards[card1] == cards[index]) {
        tt.cancel();
        cards[card1] = cards[index] = picUnset;
        numberOfPairsLeft--;
        setState(() => card1 = card2 = cardUnset);
        return;
      }
      setState(() => card2 = index);
    }
  }

  void _onFuture() {
    if (card1 == cardUnset) return;
    if ((card1 != cardUnset) &&
        (card2 != cardUnset) &&
        (cards[card1] == cards[card2])) {
      // found a pair
      cards[card1] = cards[card2] = picUnset;
      numberOfPairsLeft--;
    }
    setState(() => card1 = card2 = cardUnset);
  }

  List<Widget> genPairs() {
    List<Widget> pairs = [];
    for (int i = 0; i < cards.length; i++) {
      if (cards[i] == picUnset) {
        pairs.add(Container()); // empty space
        continue;
      }
      if (i == card1 || i == card2) {
        var pic = ImageAssetsManager.loadPicByIndex(cards[i]);
        pairs.add(MemoCard(
            isTapable: false, pic: pic, index: i, onCardTapped: _onTap));
        continue;
      }
      var pic = ImageAssetsManager.questionMarkPic;
      pairs.add(
          MemoCard(isTapable: true, pic: pic, index: i, onCardTapped: _onTap));
    }
    return pairs;
  }
}
/*
class SinglePlayerStats extends StatelessWidget {
  final int numberOfCardsUp;
  final int numberOfPairs;
  final Duration timeElapsed;

  const SinglePlayerStats({
    super.key,
    required this.numberOfCardsUp,
    required this.numberOfPairs,
    required this.timeElapsed,
  });

  String displayDuration(Duration d) {
    var sb = StringBuffer();
    int secs = d.inSeconds % 60;
    int mins = d.inMinutes;
    if (mins != 0) sb.write('$mins min ');
    if (secs != 0) sb.write('$secs sec');
    return sb.toString();
  }

  @override
  Widget build(BuildContext context) {
    var internalPadding = const EdgeInsets.all(8.0);
    var headerBackgroundColor = Colors.amber[900];
    final txtStyle = Theme.of(context).textTheme.displaySmall;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        centerTitle: true,
      ),
      body: Center(
        child: Table(
          border: TableBorder.all(color: Colors.white),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          defaultColumnWidth: const IntrinsicColumnWidth(),
          children: [
            TableRow(children: [
              TableCell(
                child: Container(
                  padding: internalPadding,
                  color: headerBackgroundColor,
                  alignment: Alignment.center,
                  child: Text('#Card Pairs:', style: txtStyle),
                ),
              ),
              TableCell(
                child: Container(
                  padding: internalPadding,
                  alignment: Alignment.centerRight,
                  child: Text(numberOfPairs.toString(), style: txtStyle),
                ),
              ),
            ]),
            TableRow(children: [
              TableCell(
                child: Container(
                  padding: internalPadding,
                  color: headerBackgroundColor,
                  alignment: Alignment.center,
                  child: Text('#Cards up:', style: txtStyle),
                ),
              ),
              TableCell(
                child: Container(
                  padding: internalPadding,
                  alignment: Alignment.centerRight,
                  child: Text(numberOfCardsUp.toString(), style: txtStyle),
                ),
              ),
            ]),
            TableRow(children: [
              TableCell(
                child: Container(
                  padding: internalPadding,
                  color: headerBackgroundColor,
                  alignment: Alignment.center,
                  child: Text('Elapsed time:', style: txtStyle),
                ),
              ),
              TableCell(
                child: Container(
                  padding: internalPadding,
                  alignment: Alignment.centerRight,
                  child: Text(displayDuration(timeElapsed), style: txtStyle),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
*/