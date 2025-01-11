import 'package:flutter/material.dart';
import 'package:supaeromoon_ground_station/ui/theme.dart';

class SlidingSwitchController<T>{
  final List<T> items;
  final List<String> names;
  final void Function(int) onChanged;
  T active;

  SlidingSwitchController({required this.items, required this.names, required this.onChanged, required this.active});
}

class SlidingSwitch extends StatefulWidget {
  const SlidingSwitch({
    super.key, required this.controller,
  });

  final SlidingSwitchController controller;

  @override
  State<SlidingSwitch> createState() => _SlidingSwitchState();
}

class _SlidingSwitchState extends State<SlidingSwitch> {
  int _activeIdx = 0;

  @override
  void initState() {
    _activeIdx = widget.controller.items.indexOf(widget.controller.active);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double elementWidth = constraints.maxWidth / widget.controller.items.length;
        return Container(
          decoration: BoxDecoration(
            border: Border.symmetric(horizontal: BorderSide(width: 1, color: ThemeManager.globalStyle.primaryColor))
          ),
          width: widget.controller.items.length * elementWidth,
          height: 30,
          child: Stack(
            fit: StackFit.expand,
            alignment: AlignmentDirectional.centerStart,
            children: [
              AnimatedPositioned(
                left: _activeIdx * elementWidth,
                duration: const Duration(milliseconds: 200), 
                curve: Curves.easeInOutCubic,
                child: Container(
                  width: elementWidth,
                  height: 30 - 2 * 1,
                  color: ThemeManager.globalStyle.primaryColor,
              )),
        
              for(int i = 0; i < widget.controller.items.length; i++)
                Positioned(left: i * elementWidth, child: SizedBox(
                  width: elementWidth,
                  height: 30 - 2 * 1,
                  child: TextButton(
                    onPressed: (() {
                      _activeIdx = i;
                      widget.controller.active = widget.controller.items[i];
                      widget.controller.onChanged(_activeIdx);
                      setState(() {});
                    }),
                    child: Text(
                      widget.controller.names[i],
                      style: ThemeManager.textStyle,
                    ),
                  ),
                ))
            ],
          ),
        );
      }
    );
  }
}
