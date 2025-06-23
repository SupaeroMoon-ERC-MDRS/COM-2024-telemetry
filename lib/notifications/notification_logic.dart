import '../../io/logger.dart';

class Notification{
  final LogEntry entry;
  final int durationMs;
  final bool isDecaying;

  const Notification({required this.entry, required this.durationMs, required this.isDecaying});

  static Notification decaying(final LogEntry entry, final int durationMs){
    return Notification(entry: entry, durationMs: durationMs, isDecaying: true);
  }

  static Notification persistent(final LogEntry entry){
    return Notification(entry: entry, durationMs: 0, isDecaying: false);
  }

  @override
  int get hashCode => durationMs.hashCode ^ entry.message.hashCode ^ entry.timeStamp.hashCode ^ entry.level.index.hashCode;
  
  @override
  bool operator ==(covariant Notification other) {
    return durationMs == other.durationMs &&
          entry.message == other.entry.message &&
          entry.timeStamp == other.entry.timeStamp &&
          entry.level.index == other.entry.level.index;
  }
}

abstract class NotificationController{
  static Function(Notification)? _onNotificationAdded;

  static void register(final Function(Notification) onNotificationAdded){
    _onNotificationAdded = onNotificationAdded;
  }

  static void deRegister(){
    _onNotificationAdded = null;
  }

  static void add(final Notification noti){
    if(_onNotificationAdded != null){
      _onNotificationAdded!(noti);
    }
  }
}

class PositionController{
  final double Function() getTop;
  final double Function() getLeft;
  final void Function(double) setTop;
  final void Function(double) setLeft;

  const PositionController({required this.getTop, required this.getLeft, required this.setTop, required this.setLeft});
}