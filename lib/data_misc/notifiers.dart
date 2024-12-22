import 'package:flutter/foundation.dart';

class BlankNotifier extends ValueNotifier{
  BlankNotifier(super.value);
  
  void update(){
    notifyListeners();
  }
}

class UpdateableValueNotifier<T> extends ValueNotifier<T>{
  UpdateableValueNotifier(super.value);
  
  void update(void Function(T value) updater){
    updater(value);
    notifyListeners();
  }

  void updateWithoutNotify(void Function(T value) updater){
    updater(value);
  }
}

typedef Condition<T> = bool Function(T);

class ConditionalNotifier<T>{
  ConditionalNotifier({required this.value});

  final T value;

  final List<VoidCallback> listeners = [];
  final List<Condition<T>> conditions = [];

  void addListener(final VoidCallback listener, final Condition<T> condition) {
    listeners.add(listener);
    conditions.add(condition);
  }

  void removeListener(final VoidCallback listener, final Condition<T> condition) {
    listeners.remove(listener);
    conditions.remove(condition);
  }

  void _notifyListeners() {
    for(int i = 0; i < listeners.length; i++){
      if(conditions[i](value)){
        listeners[i]();
      }
    }
  }

  void update(final void Function(T value) updater){
    updater(value);
    _notifyListeners();
  }
}

class MappedConditionalNotifier<T>{
  MappedConditionalNotifier({required this.value});

  final Map<String, T> value;
  
  final List<VoidCallback> listeners = [];
  final List<List<String>> keyUpdates = [];

  void addListener(final VoidCallback listener, final List<String> keysToWatch) {
    listeners.add(listener);
    keyUpdates.add(keysToWatch);
  }

  void removeListener(final VoidCallback listener) {
    final int index = listeners.indexOf(listener);
    listeners.removeAt(index);
    keyUpdates.removeAt(index);
  }

  void _notifyListeners(final String keyUpdated) {
    for(int i = 0; i < listeners.length; i++){
      if(keyUpdates[i].any((key) => keyUpdated.startsWith(key))){
        listeners[i]();
      }
    }
  }

  void _notifyListenersFromGroup(final List<String> keyUpdated) {
    for(int i = 0; i < listeners.length; i++){
      if(keyUpdates[i].any((key) => keyUpdated.any((updated) => updated.startsWith(key)))){
        listeners[i]();
      }
    }
  }

  void update(final String keyToUpdate, final T newValue){
    // check keyToUpdate is leaf
    value[keyToUpdate] = newValue;
    _notifyListeners(keyToUpdate);
  }

  void updateKey(final String keyToUpdate){
    // check keyToUpdate is leaf
    _notifyListeners(keyToUpdate);
  }

  void updateGroup(final List<String> keysToUpdate){
    // check keyToUpdate is leaf
    _notifyListenersFromGroup(keysToUpdate);
  }

  void updateAll(){
    for(final VoidCallback listener in listeners){
      listener();
    }
  }
}