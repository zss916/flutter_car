import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';


class CarView extends StatefulWidget {
  static Timer? timer;

  const CarView({Key? key}) : super(key: key);

  @override
  State<CarView> createState() => _CarViewState();
}

class _CarViewState extends State<CarView> with WidgetsBindingObserver, RouteAware {
  Worker? workerListener;

  final singleW = (Get.width - 71.0) / 8.0;
  var carLeft = ((Get.width - 71.0) / 8.0 * 3.5).obs;
  var carTop = ((Get.width - 71.0) / 8.0 * 8 + 6).obs;
  var carAngle = 0.0.obs;

  final double scaleH = Get.height / 812.0;
  final double scaleW = Get.width / 375.0;

  List<WallItem> walls = [];
  List<AnchorItem> anchors = [];
  @override
  void initState() {
    super.initState();
    // 注册应用生命周期监听
    WidgetsBinding.instance.addObserver(this);
    //Wakelock.enable();
    //Get.put(CarLogic());
    addWall();
    addAnchors();

  }

  @override
  void deactivate() {
    super.deactivate();
    handleMusic(false);
  }

  /// 监听应用生命周期变化
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      // 处于这种状态的应用程序应该假设他们可能在任何时候暂停
      case AppLifecycleState.inactive:
        // ios 退到桌面会到这里
        handleMusic(false);
        break;
      // 从后台切前台，界面可见
      case AppLifecycleState.resumed:
        //if (Get.currentRoute != HbbwhVGqAppPagesnqcCaWHKB.main) return;
        handleMusic(true);
        break;
      // 界面不可见，后台
      case AppLifecycleState.paused:
        handleMusic(false);
        break;
      // APP 结束时调用
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
   // Wakelock.disable();
   // Get.delete<CarLogic>();
    workerListener?.dispose();
    super.dispose();
  }

  @override
  void didPopNext() {
    super.didPopNext();
    handleMusic(true);
  }

  @override
  void didPushNext() {
    handleMusic(false);
    super.didPushNext();
  }

  void handleMusic(bool play) {
    /*if (GetPlatform.isIOS) {
      if (play &&
          Get.find<Hbbf620tMainControlleruMceoz4qQCt>().currentIndex != 0) {
        return;
      }
      Get.find<HbbBtNdFMatchControllervKDwFVOqar>().setBgmPlay(play);
    } else {
      if (play &&
          Get.find<Hbbf620tMainControlleruMceoz4qQCt>().currentIndex != 2) {
        return;
      }
      Get.find<HbbBtNdFMatchControllervKDwFVOqar>().setBgmPlay(play);
    }*/
  }

  // 1 上 2 下 3 左 4 右
  handleCarMove(int type) {

    switch (type) {
      case 1:
        {
          carTop.value--;
          carAngle.value = 0;
        }
        break;
      case 2:
        {
          carTop.value++;
          carAngle.value = pi;
        }
        break;
      case 3:
        {
          carLeft.value--;
          carAngle.value = -pi / 2;
        }
        break;
      case 4:
        {
          carLeft.value++;
          carAngle.value = pi / 2;
        }
        break;
      default:
    }
    // 边界判断
    if (carLeft.value <= 0) {
      carLeft.value = 0;
    }
    if (carTop.value <= 0) {
      carTop.value = 0;
    }
    if (carLeft.value >= singleW * 7 + 6) {
      carLeft.value = singleW * 7 + 6;
    }
    if (carTop.value >= singleW * 8 + 6) {
      carTop.value = singleW * 8 + 6;
    }
    //墙壁判断
    final carRect =
        Rect.fromLTWH(carLeft.value, carTop.value, singleW - 6, singleW - 6);
    for (final item in walls) {
      final itemRect =
          Rect.fromLTWH(item.offset.dx, item.offset.dy, singleW, singleW);
      if (carRect.overlaps(itemRect)) {
        switch (type) {
          case 1:
            {
              carTop.value++;
            }
            break;
          case 2:
            {
              carTop.value--;
            }
            break;
          case 3:
            {
              carLeft.value++;
            }
            break;
          case 4:
            {
              carLeft.value--;
            }
            break;
          default:
        }
      }
    }
    // 主播判断
    for (final item in anchors) {
      final itemRect =
          Rect.fromLTWH(item.offset.dx, item.offset.dy, singleW, singleW);
      if (carRect.overlaps(itemRect)) {
        anchors.remove(item);
       // Get.find<HbbBtNdFMatchControllervKDwFVOqar>().showMatched();
        if (anchors.isEmpty) {
          Future.delayed(const Duration(seconds: 2), () {
            addAnchors();
            carLeft.value = ((Get.width - 30.0) / 9.0 * 4 + 3);
            carTop.value = ((Get.width - 30.0) / 9.0 * 8 + 6);
          });
        }
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        elevation: 0,
        backgroundColor: Colors.transparent,
        leadingWidth: 200,
        leading: const Row(
          children: [
            SizedBox(
              width: 15,
            ),
            Text(
              "Game",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions:  [],
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        width: Get.width,
        color: Colors.cyan,
        padding: EdgeInsets.only(
            top: GetPlatform.isIOS
                ? Get.statusBarHeight - 50
                : Get.statusBarHeight),
        child: Column(
          children: [
            //操作台
            Stack(
              children: [
                Container(
                  width: (Get.width - 71.0),
                  height: singleW * 9,

                  child: Stack(
                    children: [
                      Obx(() {
                        return Positioned(
                          left: carLeft.value,
                          top: carTop.value,
                          child: Transform.rotate(
                            angle: carAngle.value,
                            child: Image.asset(
                              'assets/car/car.png',
                              width: singleW - 6,
                              height: singleW - 6,
                            ),
                          ),
                        );
                      }),
                      ...walls.map((e) => e.child),
                      ...anchors.map((e) => e.child)
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              width: Get.width,
              height: 150 * scaleH,
              child: Stack(
                alignment: Alignment.topCenter,
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: 10,
                    child: Container(
                      width: 56 * scaleW,
                      height: 56 * scaleW,
                      color: Colors.transparent,
                      child: PressButton(
                            () => handleCarMove(1),
                        Image.asset(
                          'assets/car/up.png',
                          width: 56 * scaleW,
                          height: 56 * scaleW,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 17 + 56 * scaleW,
                    child: Container(
                      width: 56 * scaleW,
                      height: 56 * scaleW,
                      color: Colors.transparent,
                      child: PressButton(
                            () => handleCarMove(2),
                        Image.asset(
                          'assets/car/down.png',
                          width: 56 * scaleW,
                          height: 56 * scaleW,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 7 + 56 * scaleW * 33 / 56,
                    left: (Get.width - 56 * scaleW) / 2 - 7 - 56 * scaleW,
                    child: Container(
                      width: 56 * scaleW,
                      height: 56 * scaleW,
                      color: Colors.transparent,
                      child: PressButton(
                            () => handleCarMove(3),
                        Image.asset(
                          'assets/car/down.png',
                          width: 56 * scaleW,
                          height: 56 * scaleW,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 7 + 56 * scaleW * 33 / 56,
                    left: Get.width / 2 + 7 + 56 * scaleW / 2,
                    child: Container(
                      width: 56 * scaleW,
                      height: 56 * scaleW,
                      color: Colors.transparent,
                      child: PressButton(
                            () => handleCarMove(4),
                        Image.asset(
                          'assets/car/down.png',
                          width: 56 * scaleW,
                          height: 56 * scaleW,
                        ),),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  addWall() {
    List<Offset> offsets = [
      const Offset(0, 0),
      Offset(singleW, 0),
      Offset(singleW * 2, 0),
      Offset(0, singleW * 2),
      Offset(0, singleW * 3),
      Offset(0, singleW * 6),
      Offset(0, singleW * 7),
      Offset(0, singleW * 8),
      Offset(singleW * 7, 0),
      Offset(singleW * 5, singleW),
      Offset(singleW * 7, singleW),
      Offset(singleW * 3, singleW * 2),
      Offset(singleW * 4, singleW * 2),
      Offset(singleW * 5, singleW * 2),
      Offset(singleW * 5, singleW * 3),
      Offset(singleW * 2, singleW * 5),
      Offset(singleW * 7, singleW * 5),
      Offset(singleW * 2, singleW * 6),
      Offset(singleW * 3, singleW * 6),
      Offset(singleW * 4, singleW * 6),
      Offset(singleW * 4, singleW * 6),
      Offset(singleW * 7, singleW * 7),
      Offset(singleW * 1, singleW * 8),
      Offset(singleW * 2, singleW * 8),
      Offset(singleW * 5, singleW * 8),
      Offset(singleW * 6, singleW * 8),
      Offset(singleW * 7, singleW * 8),
    ];
    for (final offset in offsets) {
      walls.add(WallItem(
          offset,
          Positioned(
            left: offset.dx,
            top: offset.dy,
            child: Image.asset(
              'assets/car/wall.png',
              width: singleW,
              height: singleW,
            ),
          )));
    }
    setState(() {});
  }

  addAnchors() {
    anchors = [];
    final indexes = getRandomAnchors();
    List<Offset> offsets = [
      Offset(0, singleW),
      Offset(0, singleW * 4),
      Offset(singleW * 6, 0),
      Offset(singleW * 4, singleW * 3),
      Offset(singleW * 7, singleW * 3),
      Offset(singleW * 3, singleW * 5),
      Offset(singleW * 7, singleW * 6),
    ];
    for (int i = 0; i < indexes.length; i++) {
      final offset = offsets[i];
      anchors.add(AnchorItem(
          offset,
          Positioned(
            left: offset.dx,
            top: offset.dy,
            child: Image.asset(
                "assets/car/diamond.png",
                width: singleW,
                height: singleW),
          )));
    }
    setState(() {});
  }

  List<int> getRandomAnchors() {
    final random = Random();
    final uniqueNumbers = <int>{};
    while (uniqueNumbers.length < 7) {
      uniqueNumbers.add(random.nextInt(14) + 1);
    }
    return uniqueNumbers.toList();
  }
}

class PressButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;
  PressButton(this.onPressed, this.child);

  @override
  _PressButtonState createState() => _PressButtonState();
}

class _PressButtonState extends State<PressButton> {

  @override
  void dispose() {
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
        onTap: () {
          widget.onPressed();
        },
        onTapDown: (_) {
        CarView.timer?.cancel();
        CarView.timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
            widget.onPressed();
          });
        },
        onTapUp: (_) {
          CarView.timer?.cancel();
        },
        onLongPressEnd: (_) {
          CarView.timer?.cancel();
        },
        child: widget.child);
  }
}

class WallItem {
  final Offset offset;
  final Widget child;
  WallItem(this.offset, this.child);
}

class AnchorItem {
  final Offset offset;
  final Widget child;
  AnchorItem(this.offset, this.child);
}
