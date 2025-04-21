import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:supaeromoon_ground_station/io/logger.dart';

enum NodeType{
    rover,
    drone,
    remote,
    gs
}

typedef BytesC = Pointer<Void>;
typedef PacketsC = Pointer<Void>;
typedef NetC = Pointer<Void>;

typedef BytesCreateCD = BytesC Function();
typedef BytesDestroyC = Void Function(BytesC p);
typedef BytesDestroyD = void Function(BytesC p);

typedef PacketsCreateCD = PacketsC Function();
typedef PacketsDestroyC = Void Function(PacketsC p);
typedef PacketsDestroyD = void Function(PacketsC p);

typedef NetCreateCD = NetC Function();
typedef NetDestroyC = Void Function(NetC p);
typedef NetDestroyD = void Function(NetC p);

typedef NetInitResetC = Uint32 Function(NetC p, Uint16 dbcVersion, Uint16 port, Int32 type);
typedef NetInitResetD = int Function(NetC p, int dbcVersion, int port, int type);

typedef NetCallC = Uint32 Function(NetC p);
typedef NetCallD = int Function(NetC p);

typedef NetPredC = Bool Function(NetC p);
typedef NetPredD = bool Function(NetC p);

typedef NetPredTypeC = Bool Function(NetC p, Int32 type);
typedef NetPredTypeD = bool Function(NetC p, int type);

typedef NetGetPacketsC = Uint32 Function(NetC p, PacketsC packets);
typedef NetGetPacketsD = int Function(NetC p, PacketsC packets);

typedef NetMessageC = Uint32 Function(NetC p, BytesC message);
typedef NetMessageD = int Function(NetC p, BytesC message);

typedef NetSendToC = Uint32 Function(NetC p, BytesC message, Pointer<Utf8> ip, Uint16 port);
typedef NetSendToD = int Function(NetC p, BytesC message, Pointer<Utf8> ip, int port);

typedef NetSendConnC = Uint32 Function(NetC p, Uint16 port);
typedef NetSendConnD = int Function(NetC p, int port);

typedef NetSendDiscC = Uint32 Function(NetC p, Int32 port);
typedef NetSendDiscD = int Function(NetC p, int port);


abstract class _NetCodeDLL{
  static late final BytesCreateCD bytesCreate;
  static late final BytesDestroyD bytesDestroy;
  static late final PacketsCreateCD packetsCreate;
  static late final PacketsDestroyD packetsDestroy;

  static late final NetCreateCD netCreate;
  static late final NetDestroyD netDestroy;

  static late final NetInitResetD netInit;
  static late final NetInitResetD netReset;
  static late final NetCallD netShutdown;

  static late final NetPredD netIsInitialized;
  static late final NetPredD netNeedReset;

  static late final NetCallD netRecv;
  static late final NetGetPacketsD netGetPackets;
  static late final NetMessageD netPush;
  static late final NetCallD netFlush;

  static late final NetPredD netHasSubscribers;
  static late final NetPredTypeD netHasSubscribersType;
  static late final NetPredTypeD netHasPublishersType;
  
  static late final NetMessageD netSend;
  static late final NetSendToD netSendTo;
  static late final NetSendConnD netSendConn;
  static late final NetSendDiscD netSendDisc;

  static bool initialize(){
    try{
      final DynamicLibrary dll = DynamicLibrary.open("udpcan-net-exports.dll");

      bytesCreate = dll.lookup<NativeFunction<BytesCreateCD>>('BytesCreate').asFunction<BytesCreateCD>();
      bytesDestroy = dll.lookup<NativeFunction<BytesDestroyC>>('BytesDestroy').asFunction<BytesDestroyD>();
      packetsCreate = dll.lookup<NativeFunction<PacketsCreateCD>>('PacketsCreate').asFunction<PacketsCreateCD>();
      packetsDestroy = dll.lookup<NativeFunction<PacketsDestroyC>>('PacketsDestroy').asFunction<PacketsDestroyD>();

      netCreate = dll.lookup<NativeFunction<NetCreateCD>>('NetCreate').asFunction<NetCreateCD>();
      netDestroy = dll.lookup<NativeFunction<NetDestroyC>>('NetDestroy').asFunction<NetDestroyD>();

      netInit = dll.lookup<NativeFunction<NetInitResetC>>('NetInit').asFunction<NetInitResetD>();
      netReset = dll.lookup<NativeFunction<NetInitResetC>>('NetReset').asFunction<NetInitResetD>();
      netShutdown = dll.lookup<NativeFunction<NetCallC>>('NetShutdown').asFunction<NetCallD>();

      netIsInitialized = dll.lookup<NativeFunction<NetPredC>>('NetIsInitialized').asFunction<NetPredD>();
      netNeedReset = dll.lookup<NativeFunction<NetPredC>>('NetNeedReset').asFunction<NetPredD>();
      
      netRecv = dll.lookup<NativeFunction<NetCallC>>('NetRecv').asFunction<NetCallD>();
      netGetPackets = dll.lookup<NativeFunction<NetGetPacketsC>>('NetGetPackets').asFunction<NetGetPacketsD>();
      netPush = dll.lookup<NativeFunction<NetMessageC>>('NetPush').asFunction<NetMessageD>();
      netFlush = dll.lookup<NativeFunction<NetCallC>>('NetFlush').asFunction<NetCallD>();

      netHasSubscribers = dll.lookup<NativeFunction<NetPredC>>('NetHasSubscribers').asFunction<NetPredD>();
      netHasSubscribersType = dll.lookup<NativeFunction<NetPredTypeC>>('NetHasSubscribersType').asFunction<NetPredTypeD>();
      netHasPublishersType = dll.lookup<NativeFunction<NetPredTypeC>>('NetHasPublishersType').asFunction<NetPredTypeD>();

      netSend = dll.lookup<NativeFunction<NetMessageC>>('NetSend').asFunction<NetMessageD>();
      netSendTo = dll.lookup<NativeFunction<NetSendToC>>('NetSendTo').asFunction<NetSendToD>();
      netSendConn = dll.lookup<NativeFunction<NetSendConnC>>('NetSendConn').asFunction<NetSendConnD>();
      netSendDisc = dll.lookup<NativeFunction<NetSendDiscC>>('NetSendDisc').asFunction<NetSendDiscD>();

      return true;
    }catch(ex){
      localLogger.critical("Failed to load netcode dll, reason ${ex.toString()}", doNoti: false);
      return false;
    }
  }
}

class NetCode{
  late final NetC net;

  static bool loadDLL() => _NetCodeDLL.initialize();

  NetCode(){
    net = _NetCodeDLL.netCreate();
  }

  void destroy(){
    _NetCodeDLL.netDestroy(net);
  }

  bool init(int dbcVersion, int port, NodeType type){
    int res = _NetCodeDLL.netInit(net, dbcVersion, port, type.index);
    if(res == 0){
      return true;
    }
    localLogger.error("NetInit failed with error code $res");
    return false;
  }

  bool reset(int dbcVersion, int port, NodeType type){
    int res = _NetCodeDLL.netReset(net, dbcVersion, port, type.index);
    if(res == 0){
      return true;
    }
    localLogger.error("NetReset failed with error code $res");
    return false;
  }

  bool shutdown(){
    int res = _NetCodeDLL.netShutdown(net);
    if(res == 0){
      return true;
    }
    localLogger.error("NetShutdown failed with error code $res");
    return false;
  }

  bool isInitialized() => _NetCodeDLL.netIsInitialized(net);
  bool needReset() => _NetCodeDLL.netNeedReset(net);

  bool recv(){
    int res = _NetCodeDLL.netRecv(net);
    if(res == 0){
      return true;
    }
    localLogger.error("NetRecv failed with error code $res");
    return false;
  }

  // static late final NetGetPacketsD netGetPackets; // TODO need bindigs on RecvPacket that exposes the address, the type of the header and the buf and has a destroy
  // static late final NetMessageD netPush;
  // static late final NetCallD netFlush;
}