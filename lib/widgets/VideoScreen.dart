import 'dart:async';

import 'package:commuitynapp/widgets/app_bar.dart';
import 'package:fijkplayer/fijkplayer.dart';
import 'package:flutter/material.dart';

class VideoScreen extends StatefulWidget {
  final String url;
  final int index;
  final ValueNotifier<double> notifier;
  VideoScreen({@required this.url,@required this.index, @required this.notifier});

  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  //final FijkPlayer _player = FijkPlayer();
  FijkPlayer _player= FijkPlayer();
  Timer _timer;
  bool _start = false;
  bool _expectStart = false;

  _VideoScreenState();

  @override
  void dispose() {
    super.dispose();
    widget.notifier.removeListener(scrollListener);
    _timer?.cancel();
    finalizer();
  }
  @override
  void initState() {
    super.initState();
    widget.notifier.addListener(scrollListener);
   // int mills = widget.index <= 3 ? 100 : 500;
    //_timer = Timer(Duration(milliseconds: mills), () async {
      //_player = FijkPlayer();
      //await _player?.setDataSource(widget.url, autoPlay: true);
      //await _player?.prepareAsync();
      //await _player.addListener(pauseListener);
      //scrollListener();
      //if (mounted) {
      //  setState(() {});
      //}
   // });

    //player.setDataSource(widget.url, autoPlay: true);
  }
  void scrollListener() {
    if (!mounted) return;

    /// !!important
    /// If items in your list view have different height,
    /// You can't get the first visible item index by
    /// dividing a constant height simply

    double pixels = widget.notifier.value;
    int z=widget.index;
    int x = (pixels / 280).ceil();
    print("=======================$pixels=====$x====$z");
    if (_player != null && widget.index == x) {
       _player?.setDataSource(widget.url, autoPlay: true);
      _expectStart = true;
      _player.removeListener(pauseListener);
      if (_start == false && _player.isPlayable()) {
        FijkLog.i("start from scroll listener $_player");
        _player.start();
        _start = true;
      } else if (_start == false) {
        FijkLog.i("add start listener $_player");
        _player.addListener(startListener);
      }
    } else if (_player != null) {
      _expectStart = false;
      _player.removeListener(startListener);
      if (_player.isPlayable() && _start) {
        FijkLog.i("pause from scroll listener $_player");
        _player.pause();
        _start = false;
      } else if (_start) {
        FijkLog.i("add pause listener $_player");
        _player.addListener(pauseListener);
      }
    }
  }

  void startListener() {
    FijkValue value = _player.value;
    if (value.prepared && !_start && _expectStart) {
      _start = true;
      FijkLog.i("start from player listener $_player");
      _player.start();
    }
  }

  void pauseListener() {
    FijkValue value = _player.value;
    if (value.prepared && _start && !_expectStart) {
      _start = false;
      FijkLog.i("pause from player listener $_player");
      _player?.pause();
    }
  }

  void finalizer() {
    _player?.removeListener(startListener);
    _player?.removeListener(pauseListener);
    var player = _player;
    _player = null;
    player?.release();
  }



  FijkFit fit = FijkFit(
    sizeFactor: 1.0,
    aspectRatio: 480 / 270,
    alignment: Alignment.center,
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //appBar: FijkAppBar.defaultSetting(title:"111"),
        body: Container(
          alignment: Alignment.center,
          child: FijkView(
            player: _player,
            //fit: fit,
              color:Colors.white
          ),
        ));
  }

 // @override
  //void dispose() {
 //   super.dispose();
  //  player.release();
  //}
}