import 'package:flutter/material.dart';
import 'package:supaeromoon_ground_station/data_misc/notifiers.dart';
import 'package:supaeromoon_ground_station/ui/indicator_panels/numeric_panel.dart';
import 'package:supaeromoon_ground_station/ui/tabs/custom_tab_config_elements.dart';
import 'package:supaeromoon_ground_station/ui/theme.dart';

class CustomTabController{
  final String name = "Custom Tab";
  final List<ConfigurableStatefulWidget> editTree = [];
  final List<Widget> layoutFrozenTree = [];
  final List<Widget> layoutEditTree = [];
  double widthAvail = 0;
  bool isEdit = false;
  final BlankNotifier refresh = BlankNotifier(null);

  void toggleEdit(){
    isEdit = !isEdit;
    refreshLayout();
  }

  double _widthOf(final dynamic w){
    if(w is NumericPanelConfigurable){
      return w.config.width;
    }
    return 0;
  }

  Widget _toFrozen(final ConfigurableStatefulWidget conf){
    if(conf is NumericPanelConfigurable){
      return NumericPanel(key: UniqueKey(), subscribedSignals: conf.config.subscribedSignals.whereType<String>().toList(), colSize: conf.config.colSize,);
    }
    return SizedBox();
  }

  void _layoutInto(final List<ConfigurableStatefulWidget> raw, final List<Widget> layout){
    layout.clear();

    final List<ConfigurableStatefulWidget> row = [];
    double bufW = 0;

    for(int i = 0; i < raw.length; i++){
      final double currW = _widthOf(raw[i]);

      if(currW + bufW < widthAvail){
        row.add(raw[i]);
        bufW += currW;
        continue;
      }

      layout.add(Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: row.toList(),));
      bufW = currW;
      row.clear();
      row.add(raw[i]);
    }

    layout.add(Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: row,));
  }

  void refreshLayout(){
    _layoutInto(editTree, layoutEditTree);

    if(isEdit){
      refresh.update();
      return;
    }

    layoutFrozenTree.clear();

    for(int i = 0; i < layoutEditTree.length; i++){
      if(layoutEditTree[i] is Row){
        final List<Widget> row = (layoutEditTree[i] as Row).children.cast<ConfigurableStatefulWidget>().map<Widget>(_toFrozen).toList();
        layoutFrozenTree.add(Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: row,));
      }
      else{
        layoutFrozenTree.add(_toFrozen(layoutEditTree[i] as ConfigurableStatefulWidget));
      }
    }
    
    refresh.update();
  }
}

class CustomTabContainer extends StatelessWidget {
  const CustomTabContainer({super.key, required this.controller});

  final CustomTabController controller;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        controller.widthAvail = constraints.maxWidth;
        controller.refreshLayout();
        return SizedBox(
          width: constraints.maxWidth,
          child: Column(
            children: [
              CustomTabAppBar(controller: controller,),
              CustomTab(controller: controller,)
            ],
          ),
        );
      },
    );
  }
}

class CustomTabAppBar extends StatefulWidget {
  const CustomTabAppBar({super.key, required this.controller});

  final CustomTabController controller;

  @override
  State<CustomTabAppBar> createState() => _CustomTabAppBarState();
}

class _CustomTabAppBarState extends State<CustomTabAppBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: ThemeManager.globalStyle.padding),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(width: 1.0, color: ThemeManager.globalStyle.primaryColor))
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border(right: BorderSide(width: 1.0, color: ThemeManager.globalStyle.primaryColor))
            ),
            padding: EdgeInsets.all(ThemeManager.globalStyle.padding),
            child: Text(widget.controller.name, style: ThemeManager.subTitleStyle,),
          ),
          IconButton(
            padding: EdgeInsets.symmetric(horizontal: ThemeManager.globalStyle.padding * 2),
            onPressed: (){
              widget.controller.toggleEdit();
              setState(() {});
            },
            icon: widget.controller.isEdit ? Icon(Icons.check) : Icon(Icons.edit)
          ),
          if(widget.controller.isEdit)
            TextButton(
              onPressed: (){
                widget.controller.editTree.add(
                  NumericPanelConfigurable(
                    key: UniqueKey(),
                    config: NumericPanelConfig(),
                    onChange: () => widget.controller.refreshLayout()
                  )
                );
                widget.controller.refreshLayout();
                setState(() {});
              },
              child: Text("Add numeric", style: ThemeManager.textStyle,)
            )
            // button to add numeric panel / need edit version using signal selector from 3D
            // button to add boolean panel / need edit version using signal selector from 3D
            // button to add chart / need edit version using signal selector from 3D
            // button to add scale panel / need edit version using signal selector from 3D
            // button to add rotary / need edit version using signal selector from 3D
        ],
      ),
    );
  }
}

class CustomTab extends StatefulWidget {
  const CustomTab({super.key, required this.controller});
  
  final CustomTabController controller;

  @override
  State<CustomTab> createState() => _CustomTabState();
}

class _CustomTabState extends State<CustomTab> {

  @override
  void initState() {
    widget.controller.refresh.addListener(_update);
    super.initState();
  }

  void _update() => setState(() {});

  @override
  Widget build(BuildContext context) {
    // Any change in the indicator setups in edit mode should call this 
    widget.controller.refreshLayout();
    return widget.controller.isEdit ?
      Column(
        children: widget.controller.layoutEditTree,
      )
      :
      Column(
        children: widget.controller.layoutFrozenTree,
      );
  }

  @override
  void dispose() {
    widget.controller.refresh.removeListener(_update);
    super.dispose();
  }
}