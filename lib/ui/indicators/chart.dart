import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supaeromoon_ground_station/data_misc/notifiers.dart';
import 'package:supaeromoon_ground_station/data_source/data_source.dart';
import 'package:supaeromoon_ground_station/data_storage/data_storage.dart';
import 'package:supaeromoon_ground_station/data_storage/session.dart';
import 'package:supaeromoon_ground_station/io/logger.dart';
import 'package:supaeromoon_ground_station/ui/common.dart';
import 'package:supaeromoon_ground_station/ui/indicators/axis_data.dart';
import 'package:supaeromoon_ground_station/ui/theme.dart';

// TODO y-autoscale?

const double fullHeight = 360;
const double titleHeight = 30;
const double xAxisHeight = 30;
const double yAxisWidth = 45;

const Map<int, Color> _colormap = {
  0: Color.fromARGB(255, 255, 0, 0),
  1: Color.fromARGB(255, 0, 255, 0),
  2: Colors.blue,
  3: Colors.yellow,
  4: Colors.purple,
  5: Colors.brown
};

class ChartLinePaintData{
  double xStart;
  double xScale;
  double yStart;
  double yScale;
  int start;
  int stop;
  late Color color;

  ChartLinePaintData({required this.xStart, required this.xScale, required this.yStart, required this.yScale, required this.start, required this.stop});
}

class ChartSliderData{
  bool realTime;
  bool isAtEnd;
  int startShowTimestamp;

  ChartSliderData({required this.realTime, required this.isAtEnd, required this.startShowTimestamp});

  ChartSliderData update({bool? realTime, bool? enteredRealtime, bool? isAtEnd, int? startShowTimestamp}){
    this.realTime = realTime ?? this.realTime;
    this.isAtEnd = isAtEnd ?? this.isAtEnd;
    this.startShowTimestamp = startShowTimestamp ?? this.startShowTimestamp;
    return this;
  }
}

class ChartState{
  num maxValue;
  num minValue;
  int showSeconds;
  bool gridOn;
  final ChartSliderData sliderData;
  final List<bool> visibility;
  ValueAxisData? xData;
  ValueAxisData? yData;

  ChartState({
    required this.maxValue,
    required this.minValue,
    required this.showSeconds,
    required this.gridOn,
    required this.sliderData,
    required this.visibility,
  });

  ChartState update({num? maxValue, num? minValue, int? showSeconds, bool? gridOn}){
    this.maxValue = maxValue ?? this.maxValue;
    this.minValue = minValue ?? this.minValue;
    this.showSeconds = showSeconds ?? this.showSeconds;
    this.gridOn = gridOn ?? this.gridOn;
    return this;
  }
}

class TimeSeriesChart extends StatefulWidget {
  const TimeSeriesChart({super.key, required this.subscribedSignals, required this.title, required this.min, required this.max});

  final List<String> subscribedSignals;
  final String title;
  final double min;
  final double max;
  
  @override
  State<TimeSeriesChart> createState() => _TimeSeriesChartState();
}

class _TimeSeriesChartState extends State<TimeSeriesChart>{
  final List<String> labels = [];
  final UpdateableValueNotifier<ChartState> state = UpdateableValueNotifier<ChartState>(
    ChartState(
      maxValue: 0,
      minValue: 0,
      showSeconds: 40,
      gridOn: true, 
      sliderData: ChartSliderData(
        realTime: true,
        isAtEnd: false,
        startShowTimestamp: 0
      ),
      visibility: [],
    )
  );

  @override
  void initState() {
    labels.addAll(widget.subscribedSignals.map((sig) => DataStorage.storage[sig]?.displayName ?? sig));
    state.value.maxValue = widget.max;
    state.value.minValue = widget.min;
    state.value.visibility.addAll(List.generate(widget.subscribedSignals.length, (index) => true));
    state.addListener(_update);
    super.initState();
  }

  void _update() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          height: fullHeight,
          width: constraints.maxWidth,
          padding: EdgeInsets.all(ThemeManager.globalStyle.padding),
          child: Row(
            children: [
              CustomPaint(
                size: Size(yAxisWidth, fullHeight - 2 * ThemeManager.globalStyle.padding),
                painter: _YAxisPainter(
                  state: state,
                ),
              ),
              SizedBox(
                width: constraints.maxWidth - yAxisWidth - 2 * ThemeManager.globalStyle.padding,
                child: Column(
                  children: [
                    ChartTopBar(
                      state: state,
                      title: widget.title,
                      labels: labels,
                      signals: widget.subscribedSignals
                    ),
                    TimeSeriesPlotArea(
                      state: state, 
                      subscribedSignals: widget.subscribedSignals,
                      size: Size(constraints.maxWidth - yAxisWidth - 2 * ThemeManager.globalStyle.padding, fullHeight - titleHeight - xAxisHeight - 2 * ThemeManager.globalStyle.padding),
                    ),
                    CustomPaint(
                      size: Size(constraints.maxWidth - yAxisWidth - 2 * ThemeManager.globalStyle.padding, xAxisHeight),
                      painter: _XAxisPainter(state: state),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    state.removeListener(_update);
    super.dispose();
  }
}

class _XAxisPainter extends CustomPainter {

  final UpdateableValueNotifier<ChartState> state;

  _XAxisPainter({required this.state});
  
  @override
  void paint(Canvas canvas, Size size) {
    final double showTime = state.value.sliderData.realTime ? 0 : (DataSource.now() - state.value.sliderData.startShowTimestamp - state.value.showSeconds * 1e3).toDouble();
    final ValueAxisData data = ValueAxisData.from(showTime, state.value.showSeconds * 1e3, size.width, null);
    state.value.xData = data;
    
    final Path ticks = Path();
    for(int i = data.majorTickPositions.first == 0 ? 1 : 0; i < data.majorTickPositions.length; i++){
      ticks.moveTo(size.width - data.majorTickPositions[i], 0);
      ticks.lineTo(size.width - data.majorTickPositions[i], 5);

      final TextPainter valuetp = TextPainter(
        text: TextSpan(
          text: msToTimeString(-data.majorTickValues[i], addMs: data.majorTickValues.length > 1 && data.majorTickValues[1] - data.majorTickValues[0] < 1000),
          style: ThemeManager.textStyle
        ),
        textDirection: TextDirection.ltr
      );

      valuetp.layout();
      valuetp.paint(canvas, Offset(size.width - data.majorTickPositions[i] - valuetp.width / 2, 15 - valuetp.height / 2));
    }

    canvas.drawPath(ticks, Paint()..color = ThemeManager.globalStyle.tertiaryColor..style = PaintingStyle.stroke);
  }

  @override
  bool shouldRepaint(_XAxisPainter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(_XAxisPainter oldDelegate) => false;
}

class _YAxisPainter extends CustomPainter {

  final UpdateableValueNotifier<ChartState> state;

  _YAxisPainter({required this.state});
  
  @override
  void paint(Canvas canvas, Size size) {
    final ValueAxisData data = ValueAxisData.from(state.value.minValue, state.value.maxValue - state.value.minValue, size.height - titleHeight - xAxisHeight, null);
    state.value.yData = data;

    final Path ticks = Path();
    for(int i = 0; i < data.majorTickPositions.length; i++){
      final double y = size.height - xAxisHeight - data.majorTickPositions[i];
      ticks.moveTo(size.width - 5, y);
      ticks.lineTo(size.width, y);

      final TextPainter valuetp = TextPainter(
        text: TextSpan(text: representNumber(data.majorTickValues[i]), style: ThemeManager.textStyle),
        textDirection: TextDirection.ltr
      );

      valuetp.layout();
      valuetp.paint(canvas, Offset(size.width - 12 - valuetp.width, y - valuetp.height / 2 - 1));
    }

    canvas.drawPath(ticks, Paint()..color = ThemeManager.globalStyle.tertiaryColor..style = PaintingStyle.stroke);
  }

  @override
  bool shouldRepaint(_YAxisPainter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(_YAxisPainter oldDelegate) => false;
}

class ChartTopBar extends StatefulWidget {
  const ChartTopBar({super.key, required this.state, required this.title, required this.labels, required this.signals});

  final UpdateableValueNotifier<ChartState> state;
  final String title;
  final List<String> labels;
  final List<String> signals;

  @override
  State<ChartTopBar> createState() => _ChartTopBarState();
}

class _ChartTopBarState extends State<ChartTopBar> {
  bool editMode = false;
  final TextEditingController maxC = TextEditingController();
  final TextEditingController minC = TextEditingController();
  final TextEditingController showSecondsC = TextEditingController();
  bool gridTmp = true;

  bool validate(){
    final num? maybeMax = int.tryParse(maxC.text) ?? double.tryParse(maxC.text);
    final num? maybeMin = int.tryParse(minC.text) ?? double.tryParse(minC.text);
    final int? maybeShowSeconds = int.tryParse(showSecondsC.text);

    if(maxC.text.isNotEmpty && maybeMax == null){
      localLogger.warning("Max must be a number, ${maxC.text} given");
      return false;
    }
    if(minC.text.isNotEmpty && maybeMin == null){
      localLogger.warning("Min must be a number, ${minC.text} given");
      return false;
    }
    if(showSecondsC.text.isNotEmpty && maybeShowSeconds == null){
      localLogger.warning("Duration must be an integer, ${showSecondsC.text} given");
      return false;
    }

    if((maybeMin ?? widget.state.value.minValue) >= (maybeMax ?? widget.state.value.maxValue)){
      localLogger.warning("Max must be bigger than min");
      return false;
    }

    if((maybeShowSeconds ?? widget.state.value.showSeconds) * 1e3 >= Session.bufferMs){
      localLogger.warning("Shown duration cannot be longer than whats buffered (${Session.bufferMs})");
      return false;
    }

    if((maybeShowSeconds ?? widget.state.value.showSeconds) <= 0){
      localLogger.warning("Shown duration must be greater than zero");
      return false;
    }

    if(maybeMax != null){
      widget.state.value.maxValue = maybeMax;
    }
    if(maybeMin != null){
      widget.state.value.minValue = maybeMin;
    }
    if(maybeShowSeconds != null){
      widget.state.value.showSeconds = maybeShowSeconds;
    }
    widget.state.value.gridOn = gridTmp;
    return true;
  }

  void clear(){
    maxC.text = "";
    minC.text = "";
    showSecondsC.text = "";
    widget.state.value.gridOn = gridTmp;
  }

  @override
  void initState() {
    gridTmp = widget.state.value.gridOn;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: titleHeight,
      child: Row(
        children: 
        editMode ?
        [
          SizedBox(
            width: ThemeManager.globalStyle.padding * 6
          ),
          SizedBox(
            width: 100,
            child: TextFormField(
              decoration: const InputDecoration(hintText: "MAX",),
              controller: maxC,
            ),
          ),
          SizedBox(
            width: 100,
            child: TextFormField(
              decoration: const InputDecoration(hintText: "MIN",),
              controller: minC,
            ),
          ),
          SizedBox(
            width: 100,
            child: TextFormField(
              decoration: const InputDecoration(hintText: "SECONDS",),
              controller: showSecondsC,
            ),
          ),
          TextButton(
            onPressed:(){
              gridTmp = !gridTmp;
              setState(() {});
            },
            child: Text(gridTmp ? "Grid on " : "Grid off",
              style: ThemeManager.textStyle,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: (){
              if(validate()){
                editMode = false;
                clear();
                setState(() {});
              }
            },
            padding: const EdgeInsets.all(0),
            splashRadius: 20,
            icon: Icon(Icons.check, color: ThemeManager.globalStyle.primaryColor,),
          ),
          IconButton(
            onPressed: (){
              editMode = false;
              clear();
              setState(() {});
            },
            padding: const EdgeInsets.all(0),
            splashRadius: 20,
            icon: Icon(Icons.undo, color: ThemeManager.globalStyle.primaryColor,),
          )
        ]
        :
        [
          Padding(
            padding: EdgeInsets.only(left: ThemeManager.globalStyle.padding * 6),
            child: Text(widget.title, style: ThemeManager.subTitleStyle),
          ),
          IconButton(
            onPressed: () async {
              editMode = true;
              setState(() {});
            },
            padding: const EdgeInsets.all(0),
            splashRadius: 20,
            icon: Icon(Icons.settings, color: ThemeManager.globalStyle.primaryColor,),
          ),
          Flexible(
            child: ChartSlider(state: widget.state)
          ),
          for(int i = 0; i < widget.labels.length; i++)
            TextButton(
              onPressed: () {
                widget.state.update((value) {
                  value.visibility[i] = !value.visibility[i];
                });
              },
              child: AdvancedTooltip(
                tooltipText: "Listening to ${widget.signals[i]}",
                child: Text(widget.labels[i], 
                  style: TextStyle(
                    color: widget.state.value.visibility[i] ? _colormap[i] : Colors.grey,
                    fontSize: ThemeManager.globalStyle.fontSize
                  ),
                )
              )
            )
        ],
      ),
    );
  }
}

class TimeSeriesPlotArea extends StatefulWidget {
  const TimeSeriesPlotArea({super.key, required this.state, required this.subscribedSignals, required this.size});
  
  final UpdateableValueNotifier<ChartState> state;
  final List<String> subscribedSignals;
  final Size size;

  @override
  State<TimeSeriesPlotArea> createState() => _TimeSeriesPlotAreaState();
}

class _TimeSeriesPlotAreaState extends State<TimeSeriesPlotArea> {
  late final Timer timer;
  final List<ChartLinePaintData> paintData = [];

  @override
  void initState() {
    timer = Timer.periodic(Duration(milliseconds: Session.chartRefreshMs), (timer) => _tick());
    paintData.addAll(List.generate(widget.subscribedSignals.length, (index) => ChartLinePaintData(xStart: 0, xScale: 0, yStart: 0, yScale: 0, start: 0, stop: 0)));
    for(int i = 0; i < paintData.length; i++){
      paintData[i].color = _colormap[i]!;
    }

    _recalcPaintData();
    super.initState();
  }

  void _recalcPaintData(){
    int now = DataSource.now();
    for(int i = 0; i < paintData.length; i++){
      if(widget.state.value.sliderData.realTime){
        paintData[i].xStart = now - widget.state.value.showSeconds * 1e3;
      }
      else if(widget.state.value.sliderData.isAtEnd){
        paintData[i].xStart = now - Session.bufferMs.toDouble();
      }
      else{
        paintData[i].xStart = widget.state.value.sliderData.startShowTimestamp.toDouble();
      }
      paintData[i].xScale = widget.size.width / (widget.state.value.showSeconds * 1e3);
      paintData[i].yStart = widget.state.value.minValue.toDouble();
      paintData[i].yScale = widget.size.height / (widget.state.value.maxValue - widget.state.value.minValue);
    }
  }

  void _tick(){
    _recalcPaintData();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Stack(
        children: [          
          CustomPaint(
            size: widget.size,
            painter: _GridPainter(state: widget.state),
          ),
          for(int i = 0; i < widget.subscribedSignals.length; i++)
            if(widget.state.value.visibility[i])
              CustomPaint(
                size: widget.size,
                painter: _TimeSeriesLinePainter(sig: widget.subscribedSignals[i], data: paintData[i], showSeconds: widget.state.value.showSeconds.toDouble()),
              ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }
}

class _TimeSeriesLinePainter extends CustomPainter {

  final String sig;
  final ChartLinePaintData data;
  final double showSeconds;
  
  static final Paint _chartLinePaint = Paint()..style = PaintingStyle.stroke..strokeWidth = 1;

  _TimeSeriesLinePainter({required this.sig, required this.data, required this.showSeconds});

  @override
  void paint(Canvas canvas, Size size) {
    data.start = DataStorage.timeIndexOf(sig, data.xStart, data.start);
    data.stop = DataStorage.timeIndexOf(sig, data.xStart + showSeconds * 1e3, data.stop, data.start);
    if(data.start == data.stop){
      return;
    }
    final Paint paint = _chartLinePaint..color = data.color;

    canvas.clipRect(Rect.fromCenter(center: size.center(Offset.zero), width: size.width, height: size.height));
    canvas.translate(0, size.height + data.yStart * data.yScale);
    canvas.scale(1, -1);

    final Path line = Path();
    line.moveTo((DataStorage.storage[sig]!.vt.time[data.start] - data.xStart) * data.xScale, (DataStorage.storage[sig]!.vt.value as List)[data.start] * data.yScale);

    for(int i = data.start + 1; i < data.stop; i++){
      line.lineTo((DataStorage.storage[sig]!.vt.time[i] - data.xStart) * data.xScale, (DataStorage.storage[sig]!.vt.value as List)[i] * data.yScale);
    }
    canvas.drawPath(line, paint);
  }

  @override
  bool shouldRepaint(_TimeSeriesLinePainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(_TimeSeriesLinePainter oldDelegate) => false;
}

class _GridPainter extends CustomPainter {

  final UpdateableValueNotifier<ChartState> state;

  _GridPainter({required this.state});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromCenter(center: size.center(Offset.zero), width: size.width, height: size.height),
      Paint()..color = ThemeManager.globalStyle.secondaryColor..style = PaintingStyle.stroke..strokeWidth = 1
    );

    if(state.value.xData == null || state.value.yData == null || !state.value.gridOn){
      return;
    }

    final Path majorGrid = Path();
    final Path grid = Path();
    for(int i = 0; i < state.value.yData!.majorTickPositions.length; i++){
      majorGrid.moveTo(0, size.height - state.value.yData!.majorTickPositions[i]);
      majorGrid.lineTo(size.width, size.height - state.value.yData!.majorTickPositions[i]);
    }
    for(int i = 0; i < state.value.yData!.tickPositions.length; i++){
      grid.moveTo(0, size.height - state.value.yData!.tickPositions[i]);
      grid.lineTo(size.width, size.height - state.value.yData!.tickPositions[i]);
    }

    canvas.drawPath(majorGrid, Paint()..color = ThemeManager.globalStyle.tertiaryColor..style = PaintingStyle.stroke);
    canvas.drawPath(grid, Paint()..color = ThemeManager.globalStyle.tertiaryColor..style = PaintingStyle.stroke..strokeWidth = 0.25);
  }

  @override
  bool shouldRepaint(_GridPainter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(_GridPainter oldDelegate) => false;
}

class ChartSlider extends StatefulWidget{
  const ChartSlider({super.key, required this.state});

  final UpdateableValueNotifier<ChartState> state;

  @override
  State<ChartSlider> createState() => _ChartSliderState();
}

class _ChartSliderState extends State<ChartSlider> {
  late Timer timer;
  int now = 0;
  double min = 0;
  double max = 1;

  @override
  void initState() {    
    now = DataSource.now();
    min = (now - Session.bufferMs).toDouble();
    max = now - widget.state.value.showSeconds * 1e3;
    widget.state.value.sliderData.startShowTimestamp = 0;
    widget.state.value.sliderData.realTime = true;
    timer = Timer.periodic(Duration(milliseconds: Session.chartRefreshMs), (timer) {_update();});
    super.initState();
  }

  void _update(){
    now = DataSource.now();
    min = (now - Session.bufferMs).toDouble();
    max = now - widget.state.value.showSeconds * 1e3;
    if(widget.state.value.sliderData.startShowTimestamp <= min){
      widget.state.value.sliderData.startShowTimestamp = min.toInt();
      widget.state.value.sliderData.isAtEnd = true;
    }
    else if(widget.state.value.sliderData.startShowTimestamp >= max){
      widget.state.value.sliderData.startShowTimestamp = max.toInt();
      widget.state.value.sliderData.isAtEnd = false;
    }
    else{
      widget.state.value.sliderData.isAtEnd = false;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Slider(
      min: min,
      max: max,
      activeColor: ThemeManager.globalStyle.primaryColor,
      value: widget.state.value.sliderData.realTime ? max : widget.state.value.sliderData.startShowTimestamp.clamp(min, max).toDouble(),
      onChanged: (newValue){
        if(newValue == max){
          widget.state.value.sliderData.realTime = true;
        }
        else{
          widget.state.value.sliderData.startShowTimestamp = newValue.toInt();
          widget.state.value.sliderData.realTime = false;
        }
        setState(() {});
      }
    );
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }
}