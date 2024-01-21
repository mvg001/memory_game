import 'package:flutter/material.dart';
import 'memo_game_multiplayer.dart';

class MemoPlayerMgmt extends StatefulWidget {
  final String title;
  const MemoPlayerMgmt({super.key, required this.title});

  @override
  State<MemoPlayerMgmt> createState() => _MemoPlayerMgmtState();
}

class _MemoPlayerMgmtState extends State<MemoPlayerMgmt> {
  final _players = <String>[];
  final _textFieldController = TextEditingController();

  void _addPlayerEntry(String name) {
    setState(() {
      _players.add(name);
    });
    _textFieldController.clear();
  }

  void _deletePlayerEntry(String playerName) {
    setState(() {
      _players.removeWhere((element) => element == playerName);
    });
  }

  String sanitize(String sIn) {
    sIn = sIn.trim();
    if (sIn.isEmpty) return '';
    sIn = sIn.replaceAll(RegExp(r'\s+'), ' ');
    var allPlayers = <String>{};
    for (var p in _players) {
      allPlayers.add(p.toLowerCase());
    }
    if (allPlayers.contains(sIn.toLowerCase())) return '';
    return sIn;
  }

  Future<void> _displayDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add a player'),
          content: TextField(
            controller: _textFieldController,
            decoration: const InputDecoration(hintText: 'Type player name'),
            autofocus: true,
          ),
          actions: <Widget>[
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                var name = sanitize(_textFieldController.text);
                if (name.isNotEmpty) _addPlayerEntry(name);
                _textFieldController.clear();
              },
              child: const Text('Add'),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        children: _players.map((String p) {
          return PlayerItem(player: p, removePlayer: _deletePlayerEntry);
        }).toList(),
      ),
      floatingActionButton: _doubleActionButton(),
    );
  }

  Widget _doubleActionButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: _displayDialog,
          // tooltip: 'Add player',
          child: const Icon(Icons.add),
        ),
        if (_players.length > 1)
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      MemoGameMultiPlayer(playerNames: _players),
                ),
              );
            },
            child: const Icon(Icons.play_arrow),
          ),
      ],
    );
  }
}

class PlayerItem extends StatelessWidget {
  final String player;
  final void Function(String player) removePlayer;

  PlayerItem({
    required this.player,
    required this.removePlayer,
  }) : super(key: ObjectKey(player));
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: () {},
        title: Row(
          children: <Widget>[
            Expanded(
              child: Text(player, overflow: TextOverflow.ellipsis),
            ),
            IconButton(
              onPressed: () {
                removePlayer(player);
              },
              icon: const Icon(Icons.delete),
              color: Colors.red,
              alignment: Alignment.centerRight,
            )
          ],
        ),
      ),
    );
  }
}
