import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'memo_board.dart';
import 'memo_card.dart';

import 'images_mgr.dart';

class Player {
  final String name;
  int pairsFound = 0;
  int cardsUp = 0;

  Player({required this.name});

  void clearStatistics() {
    pairsFound = cardsUp = 0;
  }
}

class MemoGameMultiPlayer extends StatefulWidget {
  const MemoGameMultiPlayer({super.key, required this.playerNames});
  final List<String> playerNames;
  @override
  State<MemoGameMultiPlayer> createState() => _MemoGameMultiPlayerState();
}

class ColorPair {
  final Color fg;
  final Color bg;
  ColorPair({required this.fg, required this.bg});
}

final _appBarColorDefault = ColorPair(
  fg: Colors.white,
  bg: const Color(0xff003909),
);

final _appBarColors = [
  ColorPair(fg: Colors.white, bg: Colors.blue),
  ColorPair(fg: Colors.white, bg: Colors.green),
  ColorPair(fg: Colors.black, bg: Colors.yellow),
  ColorPair(fg: Colors.black, bg: Colors.cyan),
  ColorPair(fg: Colors.white, bg: Colors.deepOrange),
  ColorPair(fg: Colors.white, bg: Colors.indigo),
];

class _MemoGameMultiPlayerState extends State<MemoGameMultiPlayer> {
  static const cardUnset = -1;
  static const picUnset = -1;

  static const minNumberOfPairs = 6;
  static const maxNumberOfPairs = 36;
  static const numberOfChoices = 11;

  static const timeout = Duration(seconds: 2);
  int numberOfPairs = 0;
  int numberOfPairsLeft = 0;
  List<int> cards = [];
  int card1 = cardUnset;
  int card2 = cardUnset;
  late Timer tt;
  final _players = <Player>[];
  int currentPlayer = -1;
  bool isGameStarted = false;

  @override
  Widget build(BuildContext context) {
    if (currentPlayer >= 0 && numberOfPairsLeft == 0) {
      // game ended
      return Statistics(
        pl: _players.sublist(0),
      );
    }
    if ((currentPlayer < 0) &&
        (numberOfPairs > 0) &&
        (numberOfPairsLeft == numberOfPairs)) {
      _players.clear();
      for (var p in widget.playerNames) {
        _players.add(Player(name: p));
      }
      currentPlayer = 0;
    }
    final appBarColors = currentPlayer >= 0
        ? _appBarColors[currentPlayer % _appBarColors.length]
        : _appBarColorDefault;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColors.bg,
        title: Text(
          currentPlayer >= 0 ? _players[currentPlayer].name : 'Memo',
          style: TextStyle(color: appBarColors.fg),
        ),
        centerTitle: true,
        actions: [if (numberOfPairs <= 0) getNumberOfPairs()],
      ),
      body: numberOfPairsLeft > 0
          ? MemoBoard(numberOfPairs: numberOfPairs, genPairs: genPairs)
          : genWarning(context),
    );
  }

  Widget genWarning(BuildContext context) {
    return Center(
      child: Text(
        'Select # of pairs with the icon above',
        style: Theme.of(context).textTheme.displaySmall,
        overflow: TextOverflow.ellipsis,
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
      _players[currentPlayer].cardsUp++;
      setState(() => card1 = index);
      tt = Timer(timeout, _onFuture);
      return;
    }
    if (card2 == cardUnset) {
      _players[currentPlayer].cardsUp++;
      if (cards[card1] == cards[index]) {
        tt.cancel();
        _players[currentPlayer].pairsFound++;
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
      _players[currentPlayer].pairsFound++;
      cards[card1] = cards[card2] = picUnset;
      numberOfPairsLeft--;
    }
    setState(() {
      card1 = card2 = cardUnset;
      currentPlayer = (currentPlayer + 1) % _players.length;
    });
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

class Statistics extends StatelessWidget {
  final List<Player> pl;
  const Statistics({
    super.key,
    required this.pl,
  });

  @override
  Widget build(BuildContext context) {
    pl.sort(
      (a, b) => b.pairsFound.compareTo(a.pairsFound),
    );
    var internalPadding = const EdgeInsets.all(8.0);
    final headerBackgroundColor = Colors.amber[900];
    final txtStyle = Theme.of(context).textTheme.titleLarge;
    final tableHeader = TableRow(
      children: [
        TableCell(
          child: Container(
            padding: internalPadding,
            color: headerBackgroundColor,
            child: Text('Player Name', style: txtStyle),
          ),
        ),
        TableCell(
          child: Container(
            padding: internalPadding,
            color: headerBackgroundColor,
            child: Text('#cards up', style: txtStyle),
          ),
        ),
        TableCell(
          child: Container(
            padding: internalPadding,
            color: headerBackgroundColor,
            child: Text('#Pairs found', style: txtStyle),
          ),
        ),
      ],
    );
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
              tableHeader,
              for (int i = 0; i < pl.length; i++)
                TableRow(children: [
                  TableCell(
                    child: Container(
                      padding: internalPadding,
                      alignment: Alignment.center,
                      child: Text(pl[i].name, style: txtStyle),
                    ),
                  ),
                  TableCell(
                    child: Container(
                      padding: internalPadding,
                      alignment: Alignment.centerRight,
                      child: Text(pl[i].cardsUp.toString(), style: txtStyle),
                    ),
                  ),
                  TableCell(
                    child: Container(
                      padding: internalPadding,
                      alignment: Alignment.centerRight,
                      child: Text(pl[i].pairsFound.toString(), style: txtStyle),
                    ),
                  ),
                ])
            ]),
      ),
    );
  }
}
