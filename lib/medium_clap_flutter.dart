library medium_clap_flutter;

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

/// A Custom Floating Action Button (FAB) library like clapping effect on Medium.
class ClapFAB extends StatefulWidget {
  /// The color of count's circle background
  final countCircleColor;

  /// The color of count's circle text
  final countTextColor;

  /// Whether to have shadow or not around ClapFab button
  final hasShadow;

  /// The color of the shadow
  final shadowColor;

  /// The outline color/ border color of the ClabFab button
  final floatingOutlineColor;

  /// The Background color of the ClabFab button
  final floatingBgColor;

  /// The color of sparkels around the count
  final sparkleColor;

  /// The default icon of the ClapFab button
  final defaultIcon;

  /// The color of default icon of the ClapFab button
  final defaultIconColor;

  /// The filled icon after clapping of the ClapFab button
  final filledIcon;

  /// The filled icon color after clapping of the ClapFab button
  final filledIconColor;

  /// On Tap Down callback
  final clapFabCallback;

  /// On Tap Up callback
  final clapUpCallback;

  /// The default image of the ClapFab button
  final defaultImage;

  /// The color of default image of the ClapFab button
  final defaultImageColor;

  /// The filled image after clapping of the ClapFab button
  final filledImage;

  /// The color of filled image of the ClapFab button
  final filledImageColor;

  /// Starting counter value (default 0)
  final initCounter;

  /// Maximum counter value (default -1, which will not limit increment)
  final maxCounter;

  const ClapFAB.icon(
      {this.countCircleColor = Colors.blue,
      this.countTextColor = Colors.white,
      this.hasShadow = false,
      this.shadowColor = Colors.blue,
      this.floatingOutlineColor = Colors.white,
      this.floatingBgColor = Colors.white,
      this.defaultIcon = Icons.favorite_border,
      this.defaultIconColor = Colors.blue,
      this.sparkleColor = Colors.blue,
      this.filledIcon = Icons.favorite,
      this.filledIconColor = Colors.blue,
      this.initCounter = 0,
      this.maxCounter = -1,
      this.clapFabCallback,
      this.clapUpCallback})
      : defaultImage = null,
        defaultImageColor = null,
        filledImage = null,
        filledImageColor = null;

  const ClapFAB.image(
      {this.countCircleColor = Colors.blue,
      this.countTextColor = Colors.white,
      this.hasShadow = false,
      this.shadowColor = Colors.blue,
      this.floatingOutlineColor = Colors.white,
      this.floatingBgColor = Colors.white,
      this.sparkleColor = Colors.blue,
      this.defaultImage = "images/clap.png",
      this.defaultImageColor = Colors.blue,
      this.filledImageColor = Colors.blue,
      this.filledImage = "images/clap.png",
      this.initCounter = 0,
      this.maxCounter = -1,
      this.clapFabCallback,
      this.clapUpCallback})
      : defaultIcon = null,
        defaultIconColor = null,
        filledIcon = null,
        filledIconColor = null;

  @override
  _ClapFABState createState() => _ClapFABState();
}

enum ScoreWidgetStatus { HIDDEN, BECOMING_VISIBLE, VISIBLE, BECOMING_INVISIBLE }

class _ClapFABState extends State<ClapFAB> with TickerProviderStateMixin {
  int counter = 0;
  double _sparklesAngle = 0.0;
  ScoreWidgetStatus _scoreWidgetStatus = ScoreWidgetStatus.HIDDEN;
  final duration = Duration(milliseconds: 400);
  final oneSecond = Duration(seconds: 1);
  Random random;
  Timer holdTimer, scoreOutETA;
  AnimationController scoreInAnimationController,
      scoreOutAnimationController,
      scoreSizeAnimationController,
      sparklesAnimationController;
  Animation scoreOutPositionAnimation, sparklesAnimation;

  initState() {
    super.initState();
    random = Random();
    counter = widget.initCounter;
    scoreInAnimationController =
        AnimationController(duration: Duration(milliseconds: 150), vsync: this);
    scoreInAnimationController.addListener(() {
      setState(() {}); // Calls render function
    });

    scoreOutAnimationController =
        AnimationController(vsync: this, duration: duration);
    scoreOutPositionAnimation = Tween(begin: 100.0, end: 150.0).animate(
        CurvedAnimation(
            parent: scoreOutAnimationController, curve: Curves.easeOut));
    scoreOutPositionAnimation.addListener(() {
      setState(() {});
    });
    scoreOutAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _scoreWidgetStatus = ScoreWidgetStatus.HIDDEN;
      }
    });

    scoreSizeAnimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 150));
    scoreSizeAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        scoreSizeAnimationController.reverse();
      }
    });
    scoreSizeAnimationController.addListener(() {
      setState(() {});
    });

    sparklesAnimationController =
        AnimationController(vsync: this, duration: duration);
    sparklesAnimation = CurvedAnimation(
        parent: sparklesAnimationController, curve: Curves.easeIn);
    sparklesAnimation.addListener(() {
      setState(() {});
    });
  }

  dispose() {
    scoreInAnimationController.dispose();
    scoreOutAnimationController.dispose();
    super.dispose();
  }

  void increment(Timer t) {
    scoreSizeAnimationController.forward(from: 0.0);
    sparklesAnimationController.forward(from: 0.0);

    if (_shouldIncrement()) {
      setState(() {
        counter++;
        _sparklesAngle = random.nextDouble() * (2 * pi);
      });
    }
  }

  bool _shouldIncrement() {
    if (widget.maxCounter == -1) {
      return true;
    }
    return counter < widget.maxCounter;
  }

  void onTapDown(TapDownDetails tap) {
    // User pressed the button. This can be a tap or a hold.
    if (scoreOutETA != null) {
      scoreOutETA.cancel(); // We do not want the score to vanish!
    }
    if (_scoreWidgetStatus == ScoreWidgetStatus.BECOMING_INVISIBLE) {
      // We tapped down while the widget was flying up. Need to cancel that animation.
      scoreOutAnimationController.stop(canceled: true);
      _scoreWidgetStatus = ScoreWidgetStatus.VISIBLE;
    } else if (_scoreWidgetStatus == ScoreWidgetStatus.HIDDEN) {
      _scoreWidgetStatus = ScoreWidgetStatus.BECOMING_VISIBLE;
      scoreInAnimationController.forward(from: 0.0);
    }
    increment(null); // Take care of tap
    holdTimer = Timer.periodic(duration, increment); // Takes care of hold
    if (widget.clapFabCallback != null) widget.clapFabCallback(counter);
  }

  void onTapUp(TapUpDetails tap) {
    // User removed his finger from button.
    scoreOutETA = Timer(oneSecond, () {
      scoreOutAnimationController.forward(from: 0.0);
      _scoreWidgetStatus = ScoreWidgetStatus.BECOMING_INVISIBLE;
    });
    if (widget.clapUpCallback != null) widget.clapUpCallback(counter);
    holdTimer.cancel();
  }

  Widget getClapButton() {
    // Using custom gesture detector because we want to keep increasing the claps
    // when user holds the button.

    var extraSize = 0.0;
    if (_scoreWidgetStatus == ScoreWidgetStatus.VISIBLE ||
        _scoreWidgetStatus == ScoreWidgetStatus.BECOMING_VISIBLE) {
      extraSize = scoreSizeAnimationController.value * 3;
    }
    return GestureDetector(
        onTapUp: onTapUp,
        onTapDown: onTapDown,
        child: Container(
          height: 60.0 + extraSize,
          width: 60.0 + extraSize,
          padding: EdgeInsets.all(10.0),
          decoration: BoxDecoration(
              border:
                  Border.all(color: widget.floatingOutlineColor, width: 1.0),
              borderRadius: BorderRadius.circular(50.0),
              color: widget.floatingBgColor,
              boxShadow: [
                widget.hasShadow
                    ? BoxShadow(color: widget.shadowColor, blurRadius: 8.0)
                    : BoxShadow()
              ]),
          child: widget.defaultImage == null
              ? Icon(
                  counter > 0 ? widget.filledIcon : widget.defaultIcon,
                  color: counter > 0
                      ? widget.filledIconColor
                      : widget.defaultIconColor,
                  size: 30.0,
                )
              : ImageIcon(
                  new AssetImage(
                      counter > 0 ? widget.filledImage : widget.defaultImage),
                  color: counter > 0
                      ? widget.filledImageColor
                      : widget.defaultImageColor,
                  size: 30.0),
        ));
  }

  Widget getScoreButton() {
    var scorePosition = 0.0;
    var scoreOpacity = 0.0;
    var extraSize = 0.0;
    switch (_scoreWidgetStatus) {
      case ScoreWidgetStatus.HIDDEN:
        break;
      case ScoreWidgetStatus.BECOMING_VISIBLE:
      case ScoreWidgetStatus.VISIBLE:
        scorePosition = scoreInAnimationController.value * 100;
        scoreOpacity = scoreInAnimationController.value;
        extraSize = scoreSizeAnimationController.value * 3;
        break;
      case ScoreWidgetStatus.BECOMING_INVISIBLE:
        scorePosition = scoreOutPositionAnimation.value;
        scoreOpacity = 1.0 - scoreOutAnimationController.value;
    }

    var stackChildren = <Widget>[];

    var firstAngle = _sparklesAngle;
    var sparkleRadius = (sparklesAnimationController.value * 50);
    var sparklesOpacity = (1 - sparklesAnimation.value);

    for (int i = 0; i < 5; ++i) {
      var currentAngle = (firstAngle + ((2 * pi) / 5) * (i));
      var sparklesWidget = Positioned(
        child: Transform.rotate(
            angle: currentAngle - pi / 2,
            child: Opacity(
                opacity: sparklesOpacity,
                child: Image.asset(
                  "images/sparkles.png",
                  color: widget.sparkleColor,
                  width: 14.0,
                  height: 14.0,
                ))),
        left: (sparkleRadius * cos(currentAngle)) + 20,
        top: (sparkleRadius * sin(currentAngle)) + 20,
      );
      stackChildren.add(sparklesWidget);
    }

    stackChildren.add(Opacity(
        opacity: scoreOpacity,
        child: Container(
            height: 50.0 + extraSize,
            width: 50.0 + extraSize,
            decoration: ShapeDecoration(
              shape: CircleBorder(side: BorderSide.none),
              color: widget.countCircleColor,
            ),
            child: Center(
                child: Text(
              "+" + counter.toString(),
              style: TextStyle(
                  color: widget.countTextColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 15.0),
            )))));

    var _currentWidget = Positioned(
        child: Stack(
          alignment: FractionalOffset.center,
          overflow: Overflow.visible,
          children: stackChildren,
        ),
        bottom: scorePosition);
    return _currentWidget;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 20.0),
      child: Stack(
        alignment: FractionalOffset.center,
        overflow: Overflow.visible,
        children: <Widget>[
          getScoreButton(),
          getClapButton(),
        ],
      ),
    );
  }
}
