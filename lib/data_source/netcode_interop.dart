import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import 'package:supaeromoon_ground_station/io/logger.dart';

enum NodeType{
    rover,
    drone,
    remote,
    gs
}

class RecvPacket{
  final Uint8List buf;
  final String ip;
  final int port;
  final NodeType type;

  const RecvPacket({required this.buf, required this.ip, required this.port, required this.type});
}

typedef BytesC = Pointer<Void>;
typedef PacketsC = Pointer<Void>;
typedef PacketC = Pointer<Void>;
typedef NetC = Pointer<Void>;

typedef BytesCreateCD = BytesC Function();

typedef BytesFromC = BytesC Function(Pointer<Uint8> p, Uint32 size);
typedef BytesFromD = BytesC Function(Pointer<Uint8> p, int size);

typedef BytesDestroyC = Void Function(BytesC p);
typedef BytesDestroyD = void Function(BytesC p);

typedef BytesDataC = Pointer<Uint8> Function(BytesC p);
typedef BytesDataD = Pointer<Uint8> Function(BytesC p);
typedef BytesSizeC = Uint32 Function(BytesC p);
typedef BytesSizeD = int Function(BytesC p);

typedef PacketsCreateCD = PacketsC Function();

typedef PacketsDestroyC = Void Function(PacketsC p);
typedef PacketsDestroyD = void Function(PacketsC p);

typedef PacketsSizeC = Uint32 Function(PacketsC p);
typedef PacketsSizeD = int Function(PacketsC p);

typedef PacketsIndexC = PacketC Function(PacketsC p, Uint32 i);
typedef PacketsIndexD = PacketC Function(PacketsC p, int i);

typedef PacketGetBufCD = BytesC Function(PacketC p);

typedef PacketGetTypeC = Uint8 Function(PacketC p);
typedef PacketGetTypeD = int Function(PacketC p);

typedef PacketGetIPCD = Pointer<Utf8> Function(PacketC p);

typedef PacketGetPortC = Uint16 Function(PacketC p);
typedef PacketGetPortD = int Function(PacketC p);

typedef PacketDestroyC = Void Function(PacketC p);
typedef PacketDestroyD = void Function(PacketC p);

typedef NetCreateCD = NetC Function();
typedef NetDestroyC = Void Function(NetC p);
typedef NetDestroyD = void Function(NetC p);

typedef NetInitResetC = Uint32 Function(NetC p, Uint16 dbcVersion, Pointer<Utf8> ip, Uint16 port, Int32 type);
typedef NetInitResetD = int Function(NetC p, int dbcVersion, Pointer<Utf8> ip, int port, int type);

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

typedef NetSendConnC = Uint32 Function(NetC p, Pointer<Utf8> ip, Uint16 port);
typedef NetSendConnD = int Function(NetC p, Pointer<Utf8> ip, int port);

typedef NetSendDiscC = Uint32 Function(NetC p, Int32 port);
typedef NetSendDiscD = int Function(NetC p, int port);


abstract class _NetCodeDLL{
  //static late final BytesCreateCD bytesCreate;
  static late final BytesFromD bytesFrom;
  static late final BytesDestroyD bytesDestroy;
  static late final BytesDataD bytesData;
  static late final BytesSizeD bytesSize;

  static late final PacketsCreateCD packetsCreate;
  static late final PacketsDestroyD packetsDestroy;
  static late final PacketsSizeD packetsSize;
  static late final PacketsIndexD packetsIndex;

  static late final PacketGetBufCD packetGetBuf;
  static late final PacketGetTypeD packetGetType;
  static late final PacketGetIPCD packetGetIP;
  static late final PacketGetPortD packetGetPort;
  //static late final PacketDestroyD packetDestroy;

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
      final DynamicLibrary dll;
      if(Platform.isWindows){
        dll = DynamicLibrary.open("udpcan-net-exports.dll");
      }
      else if(Platform.isLinux){
        dll = DynamicLibrary.open("libudpcan-net-exports.so");
      }
      else{
        exit(1);
      }

      //bytesCreate = dll.lookup<NativeFunction<BytesCreateCD>>('BytesCreate').asFunction<BytesCreateCD>();
      bytesFrom = dll.lookup<NativeFunction<BytesFromC>>('BytesFrom').asFunction<BytesFromD>();
      bytesDestroy = dll.lookup<NativeFunction<BytesDestroyC>>('BytesDestroy').asFunction<BytesDestroyD>();
      bytesData = dll.lookup<NativeFunction<BytesDataC>>('BytesData').asFunction<BytesDataD>();
      bytesSize = dll.lookup<NativeFunction<BytesSizeC>>('BytesSize').asFunction<BytesSizeD>();

      packetsCreate = dll.lookup<NativeFunction<PacketsCreateCD>>('PacketsCreate').asFunction<PacketsCreateCD>();
      packetsDestroy = dll.lookup<NativeFunction<PacketsDestroyC>>('PacketsDestroy').asFunction<PacketsDestroyD>();
      packetsSize = dll.lookup<NativeFunction<PacketsSizeC>>('PacketsSize').asFunction<PacketsSizeD>();
      packetsIndex = dll.lookup<NativeFunction<PacketsIndexC>>('PacketsIndex').asFunction<PacketsIndexD>();

      packetGetBuf = dll.lookup<NativeFunction<PacketGetBufCD>>('PacketGetBuf').asFunction<PacketGetBufCD>();
      packetGetType = dll.lookup<NativeFunction<PacketGetTypeC>>('PacketGetType').asFunction<PacketGetTypeD>();
      packetGetIP = dll.lookup<NativeFunction<PacketGetIPCD>>('PacketGetIP').asFunction<PacketGetIPCD>();
      packetGetPort = dll.lookup<NativeFunction<PacketGetPortC>>('PacketGetPort').asFunction<PacketGetPortD>();
      //packetDestroy = dll.lookup<NativeFunction<PacketDestroyC>>('PacketDestroy').asFunction<PacketDestroyD>();

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

  bool init(final int dbcVersion, final int port, final String ip, final NodeType type){
    int res = _NetCodeDLL.netInit(net, dbcVersion, ip.toNativeUtf8(), port, type.index);
    if(res == 0){
      return true;
    }
    localLogger.error("NetInit failed with error code $res");
    return false;
  }

  bool reset(final int dbcVersion, final int port, final String ip, final NodeType type){
    int res = _NetCodeDLL.netReset(net, dbcVersion, ip.toNativeUtf8(), port, type.index);
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

  bool getPackets(final List<RecvPacket> packets){
    PacketsC packetsc = _NetCodeDLL.packetsCreate();
    int res = _NetCodeDLL.netGetPackets(net, packetsc);
    
    if(res == 0){
      int size = _NetCodeDLL.packetsSize(packetsc);
      for(int i = 0; i < size; i++){
        PacketC pack = _NetCodeDLL.packetsIndex(packetsc, i);
        BytesC buf = _NetCodeDLL.packetGetBuf(pack);
        packets.add(
          RecvPacket(
            buf: Uint8List.fromList(_NetCodeDLL.bytesData(buf).asTypedList(_NetCodeDLL.bytesSize(buf)).toList()),
            ip: _NetCodeDLL.packetGetIP(pack).toDartString(),
            port: _NetCodeDLL.packetGetPort(pack),
            type: NodeType.values[_NetCodeDLL.packetGetType(pack)]
          )
        );
      }
      
      _NetCodeDLL.packetsDestroy(packetsc);
      return true;
    }
    if(res != 2){
      localLogger.error("NetGetPackets failed with error code $res");
    }
    _NetCodeDLL.packetsDestroy(packetsc);
    return false;
  }

  bool push(final Uint8List bytes){
    Pointer<Uint8> p = calloc<Uint8>(bytes.length);
    p.asTypedList(bytes.length).setAll(0, bytes);
    BytesC bytesp = _NetCodeDLL.bytesFrom(p, bytes.length);
    calloc.free(p);
    
    int res = _NetCodeDLL.netPush(net, bytesp);
    _NetCodeDLL.bytesDestroy(bytesp);

    if(res == 0){
      return true;
    }
    localLogger.error("NetPush failed with error code $res");
    return false;
  }
  
  bool flush(){
    int res = _NetCodeDLL.netFlush(net);
    if(res == 0){
      return true;
    }
    localLogger.error("NetFlush failed with error code $res");
    return false;
  }

  bool hasSubscribers() => _NetCodeDLL.netHasSubscribers(net);
  bool hasSubscribersType(final NodeType type) => _NetCodeDLL.netHasSubscribersType(net, type.index);
  bool hasPublishersType(final NodeType type) => _NetCodeDLL.netHasPublishersType(net, type.index);
  
  bool send(final Uint8List bytes){
    Pointer<Uint8> p = calloc<Uint8>(bytes.length);
    p.asTypedList(bytes.length).setAll(0, bytes);
    BytesC bytesp = _NetCodeDLL.bytesFrom(p, bytes.length);
    calloc.free(p);
    
    int res = _NetCodeDLL.netSend(net, bytesp);
    _NetCodeDLL.bytesDestroy(bytesp);

    if(res == 0){
      return true;
    }
    localLogger.error("NetSend failed with error code $res");
    return false;
  }

  bool sendTo(final Uint8List bytes, final String ip, final int port){
    Pointer<Uint8> p = calloc<Uint8>(bytes.length);
    p.asTypedList(bytes.length).setAll(0, bytes);
    BytesC bytesp = _NetCodeDLL.bytesFrom(p, bytes.length);
    calloc.free(p);
    
    int res = _NetCodeDLL.netSendTo(net, bytesp, ip.toNativeUtf8(), port);
    _NetCodeDLL.bytesDestroy(bytesp);

    if(res == 0){
      return true;
    }
    localLogger.error("NetSendTo failed with error code $res");
    return false;
  }

  bool sendConn(final String ip, final int port){
    int res = _NetCodeDLL.netSendConn(net, ip.toNativeUtf8(), port);
    if(res == 0){
      return true;
    }
    localLogger.error("NetSendConn failed with error code $res");
    return false;
  }

  bool sendDisc(final NodeType type){
    int res = _NetCodeDLL.netSendDisc(net, type.index);
    if(res == 0){
      return true;
    }
    localLogger.error("NetSendDisc failed with error code $res");
    return false;
  }
}