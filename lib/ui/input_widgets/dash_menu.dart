import 'package:flutter/material.dart';
import 'package:supaeromoon_ground_station/io/localization.dart';
import 'package:supaeromoon_ground_station/ui/input_widgets/sliding_switch.dart';
import 'package:supaeromoon_ground_station/ui/theme.dart';

class DashController{
  late final Function _updater;
  final List<IconData> icons;

  DashController({required this.icons});

  void register(final Function updater){
    _updater = updater;
  }

  void toggleOpen(){
    _updater();
  }
}

class DashMenuSlidingSwitch extends StatefulWidget {
  const DashMenuSlidingSwitch({
    super.key, required this.controller, required this.dashController,
  });

  final SlidingSwitchController controller;
  final DashController dashController;

  @override
  State<DashMenuSlidingSwitch> createState() => _DashMenuSlidingSwitchState();
}

class _DashMenuSlidingSwitchState extends State<DashMenuSlidingSwitch> {
  int _activeIdx = 0;
  bool _isOpened = true;
  bool _goingToOpen = true;

  @override
  void initState() {
    _activeIdx = widget.controller.items.indexOf(widget.controller.active);
    widget.dashController.register(_toggleOpen);
    super.initState();
  }

  void _toggleOpen(){
    _goingToOpen ? {_goingToOpen = false, _isOpened = false} : _goingToOpen = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      color: ThemeManager.globalStyle.secondaryColor,
      width: _goingToOpen ? 200.0 : 60.0,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeInOutCubic,
      onEnd: () {
        _isOpened = _goingToOpen;
        setState(() {});
      },
      child: Column(
        children: [
          SizedBox(
            width: _goingToOpen ? 200.0 : 60.0,
            height: _goingToOpen ? 200.0 : 60.0,
            child: Image.asset("assets/images/supaeromoon_dark_transparent.png",
              alignment: Alignment.center,
              filterQuality: FilterQuality.high,
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(
            height: ThemeManager.globalStyle.padding * 3,
          ),
          Expanded(
            child: ListView(
              children: [
                SizedBox(
                  width: _goingToOpen ? 200.0 : 60.0,
                  height: 30.0 * widget.controller.items.length,
                  child: Stack(
                    fit: StackFit.expand,
                    alignment: AlignmentDirectional.centerStart,
                    children: [
                      AnimatedPositioned(
                        top: _activeIdx * 30,
                        duration: const Duration(milliseconds: 200), 
                        curve: Curves.easeInOutCubic,
                        child: Container(
                          width: _goingToOpen ? 200.0 : 60.0,
                          height: 30,
                          color: ThemeManager.globalStyle.tertiaryColor,
                      )),
                
                      for(int i = 0; i < widget.controller.items.length; i++)
                        Positioned(top: i * 30, child: SizedBox(
                          width: _goingToOpen ? 200.0 : 60.0,
                          height: 30,
                          child: TextButton(
                            onPressed: (() {
                              _activeIdx = i;
                              widget.controller.active = widget.controller.items[i];
                              widget.controller.onChanged(_activeIdx);
                              setState(() {});
                            }),
                            child: Row(
                              mainAxisAlignment: _isOpened ? MainAxisAlignment.start : MainAxisAlignment.center,
                              children: [
                                Icon(
                                  widget.dashController.icons[i],
                                  color: ThemeManager.globalStyle.primaryColor,
                                  size: ThemeManager.globalStyle.titleFontSize,
                                ),
                                if(_isOpened)
                                  Padding(
                                    padding: EdgeInsets.only(left: ThemeManager.globalStyle.padding),
                                    child: Text(
                                      Loc.get(widget.controller.names[i]),
                                      style: ThemeManager.textStyle,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ))
                    ],
                  ),
                )
              ]
            ),
          ),
        ],
      ),
    );
  }
}
