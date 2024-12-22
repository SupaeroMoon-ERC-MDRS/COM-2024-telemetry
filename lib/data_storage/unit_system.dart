import 'dart:math';

import '../../io/file_system.dart';
import '../../io/logger.dart';

typedef UnitAlias = String;

class UnitDescription{
  final List<String> representations;    // [s, sec, seconds]   |  [min, minutes]   |  [kg, kilogramms]
  final bool isBase;                     // true                |  false            |  true
  final String dim;                      // time                |  time             |  weight

  const UnitDescription({required this.representations, required this.isBase, required this.dim});

  @override
  String toString() {
    return representations.first;
  }
}

class ConversionHelper{
  final UnitAlias to;
  final double multiplier;

  ConversionHelper({required this.to, required this.multiplier});
}

class UnitConversionTable{
  final Map<UnitAlias, ConversionHelper> conversionsToBase = {};

  List toJson(){
    return conversionsToBase.entries.map((entry) => {
      "from": entry.key,
      "to": entry.value.to,
      "multiplier": entry.value.multiplier
    }).toList();
  }
}

class UnitCompositionTable{
  final Map<UnitAlias,   List<MapEntry<double, List<MapEntry<UnitAlias, int>>>>> compositions = {};
  //        CompoundUnit [   [     {SimpleUnit: exponent},{SimpleUnit: exponent}],[{SimpleUnit: exponent},{SimpleUnit: exponent}]]

  void load(List data){
    for(final Map comp in data){
      final List<MapEntry<double, List<MapEntry<UnitAlias, int>>>> compOptions = [];
      for(final Map compOption in comp["composition_options"]){
        compOptions.add(MapEntry(compOption["amount"]!, []));
        for(final MapEntry<UnitAlias, int> compOptionComponent in compOption["composition"]!.cast<UnitAlias, int>().entries){
          compOptions.last.value.add(compOptionComponent);
        }
      }
      compositions[comp["to"]] = compOptions;
    }
  }

  List toJson(){
    return compositions.entries.map((entry) => {
      "to": entry.key,
      "composition_options": entry.value.map((e) => 
        {"amount": e.key, "composition": Map.fromEntries(e.value)}
      ).toList()
    }).toList();
  }
}

abstract class UnitSystem{
  static final Map<UnitAlias, UnitDescription> _unitDescriptions = {};
  static final UnitConversionTable _conversionTable = UnitConversionTable();
  static final UnitCompositionTable _compositionTable = UnitCompositionTable();

  static void _syncToDisk(){
    Map jsonEncodeable = {};

    jsonEncodeable["unit_descriptions"] = _unitDescriptions.entries.map((desc) => {
      desc.key: {
        "representations": desc.value.representations,
        "is_base": desc.value.isBase,
        "dim": desc.value.dim
      }
    }).toList();

    jsonEncodeable["conversions"] = _conversionTable.toJson();
    jsonEncodeable["compositions"] = _compositionTable.toJson();

    FileSystem.trySaveMapToLocalAsync(FileSystem.unitSystemDir, "unit_system.json", jsonEncodeable, withIndent: true);
  }

  static void _loadDefaults(){
    _unitDescriptions.addAll(const {
      "millimeters": UnitDescription(representations: ["mm"], isBase: false, dim: "length"),
      "meters": UnitDescription(representations: ["m"], isBase: true, dim: "length"),
      "kilometers": UnitDescription(representations: ["km"], isBase: false, dim: "length"),

      "milliseconds": UnitDescription(representations: ["ms"], isBase: false, dim: "time"),
      "seconds": UnitDescription(representations: ["s", "sec"], isBase: true, dim: "time"),
      "minutes": UnitDescription(representations: ["min"], isBase: false, dim: "time"),
      "hours": UnitDescription(representations: ["h"], isBase: false, dim: "time"),
      
      "g": UnitDescription(representations: ["g"], isBase: true, dim: "acceleration"),

      "kilogramms": UnitDescription(representations: ["kg"], isBase: true, dim: "mass"),

      "newtons": UnitDescription(representations: ["N"], isBase: true, dim: "force"),
      "kilonewtons": UnitDescription(representations: ["kN"], isBase: false, dim: "force"),

      "milliampere": UnitDescription(representations: ["mA"], isBase: false, dim: "current"),
      "ampere": UnitDescription(representations: ["A"], isBase: true, dim: "current"),

      "millivolts": UnitDescription(representations: ["mV"], isBase: false, dim: "voltage"),
      "volts": UnitDescription(representations: ["V"], isBase: true, dim: "voltage"),
      "kilovolts": UnitDescription(representations: ["kV"], isBase: false, dim: "voltage"),

      "milliwatts": UnitDescription(representations: ["mW"], isBase: false, dim: "power"),
      "watts": UnitDescription(representations: ["W"], isBase: true, dim: "power"),
      "kilowatts": UnitDescription(representations: ["kW"], isBase: false, dim: "power"),

      "celsius": UnitDescription(representations: ["°C"], isBase: true, dim: "temperature"),
      
      "joules": UnitDescription(representations: ["J"], isBase: true, dim: "energy"),
      "kilojoules": UnitDescription(representations: ["kJ"], isBase: false, dim: "energy"),
      
      "pascals": UnitDescription(representations: ["Pa"], isBase: true, dim: "pressure"),
      "bars": UnitDescription(representations: ["bar"], isBase: false, dim: "pressure"),

      "radians": UnitDescription(representations: ["rad"], isBase: true, dim: "angle"),
      "degrees": UnitDescription(representations: ["°", "deg"], isBase: false, dim: "angle"),

      "percent": UnitDescription(representations: ["%"], isBase: true, dim: "percentage"),
      "ppm": UnitDescription(representations: ["ppm"], isBase: false, dim: "percentage"),
  });

    _conversionTable.conversionsToBase.addAll({
      "millimeters": ConversionHelper(to: "meters", multiplier: 0.001),
      "kilometers": ConversionHelper(to: "meters", multiplier: 1000),

      "milliseconds": ConversionHelper(to: "seconds", multiplier: 0.001),
      "minutes": ConversionHelper(to: "seconds", multiplier: 60),
      "hours": ConversionHelper(to: "seconds", multiplier: 3600),

      "kilonewtons": ConversionHelper(to: "newtons", multiplier: 1000),

      "milliampere": ConversionHelper(to: "ampere", multiplier: 0.001),

      "millivolts": ConversionHelper(to: "volts", multiplier: 0.001),
      "kilovolts": ConversionHelper(to: "volts", multiplier: 1000),

      "milliwatts": ConversionHelper(to: "watts", multiplier: 0.001),
      "kilowatts": ConversionHelper(to: "watts", multiplier: 1000),

      "kilojoules": ConversionHelper(to: "joules", multiplier: 1000),

      "bars": ConversionHelper(to: "pascals", multiplier: 100000),

      "degrees": ConversionHelper(to: "radians", multiplier: pi/180),

      "ppm": ConversionHelper(to: "percent", multiplier: 10000)
    });

    _compositionTable.compositions.addAll({
      "g": [
        const MapEntry(9.80665, [MapEntry("meters", 1), MapEntry("seconds", -2)]),
      ],
      "newtons": [
        const MapEntry(1, [MapEntry("kilogramms", 1), MapEntry("meters", 1), MapEntry("seconds", -2)]),
        const MapEntry(1 / 9.80665, [MapEntry("kilogramms", 1), MapEntry("g", 1)]),
        const MapEntry(1, [MapEntry("pascals", 1), MapEntry("meters", 2)]),
        const MapEntry(1, [MapEntry("joules", 1), MapEntry("meters", -1)]),
      ],
      "watts": [
        const MapEntry(1, [MapEntry("joules", 1), MapEntry("seconds", -1)]),
        const MapEntry(1, [MapEntry("volts", 1), MapEntry("ampere", 1)]),
      ],
      "joules": [
        const MapEntry(1, [MapEntry("newtons", 1), MapEntry("meters", 1)]),
        const MapEntry(1, [MapEntry("watts", 1), MapEntry("seconds", 1)]),
        const MapEntry(1, [MapEntry("pascals", 1), MapEntry("meters", 3)]),
      ],
      "pascals": [
        const MapEntry(1, [MapEntry("newtons", 1), MapEntry("meters", -2)]),
        const MapEntry(1, [MapEntry("joules", 1), MapEntry("meters", -3)]),
      ],
      "volts": [
        const MapEntry(1, [MapEntry("kilogramms", 1), MapEntry("meters", 2), MapEntry("seconds", -3), MapEntry("ampere", -1)])
      ]
    });
  }

  static bool _ensureShortestUnitDescriptionRepresentationFirst(){
    for(final UnitDescription desc in _unitDescriptions.values){
      final String shortestRep = desc.representations.reduce((previousValue, element) => previousValue.length < element.length ? previousValue : element);
      final int shortestIndex = desc.representations.indexOf(shortestRep);
      if(shortestIndex != 0){
        desc.representations[shortestIndex] = desc.representations[0];
        desc.representations[0] = shortestRep;
      }
    }
    return true;
  }

  static bool _checkUnitAliasesReferecedHaveDesc(){
    for(final MapEntry<UnitAlias, ConversionHelper> entry in _conversionTable.conversionsToBase.entries){
      if(!_unitDescriptions.containsKey(entry.key)){
        localLogger.error("Unit alias ${entry.key} was referenced in conversion table, but was not declared in unit descriptions");
        return false;
      }
      if(!_unitDescriptions.containsKey(entry.value.to)){
        localLogger.error("Unit alias ${entry.value.to} was referenced in conversion table, but was not declared in unit descriptions");
        return false;
      }
    }

    for(final MapEntry<String, List<MapEntry<double, List<MapEntry<UnitAlias, int>>>>> entry in _compositionTable.compositions.entries){
      if(!_unitDescriptions.containsKey(entry.key)){
        localLogger.error("Unit alias ${entry.key} was referenced in composition table, but was not declared in unit descriptions");
        return false;
      }

      if(entry.value.any((e) => e.value.map((e) => e.key).any((alias) => !_unitDescriptions.containsKey(alias)))){
        localLogger.error("Some unit alias(es) were referenced as a component in composition table, but was not declared in unit descriptions");
        return false;
      }
    }

    return true;
  }

  static bool _checkDimHasOneBase(){
    final Iterable<String> dimsWithBase = _unitDescriptions.values.where((desc) => desc.isBase).map((desc) => desc.dim);
    final Set<String> allDims = _unitDescriptions.values.map((e) => e.dim).toSet();
    final bool success = dimsWithBase.length == dimsWithBase.toSet().length && dimsWithBase.toSet().length == allDims.length;
    if(!success){
      localLogger.error("Each dimension must have one and only one base unit");
    }
    return success;
  }

  static bool _checkConversionStaysWithinDim(){
    for(final MapEntry<UnitAlias, ConversionHelper> entry in _conversionTable.conversionsToBase.entries){
      if(_unitDescriptions[entry.key]!.dim != _unitDescriptions[entry.value.to]!.dim){
        localLogger.error("Invalid conversion found: ${entry.key} is of dimension ${_unitDescriptions[entry.key]!.dim}, which cannot convert to ${entry.value.to} which is of dimension ${_unitDescriptions[entry.value.to]!.dim}");
        return false;
      }
    }
    return true;
  }

  static bool _checkConversionIsToBase(){
    for(final MapEntry<UnitAlias, ConversionHelper> entry in _conversionTable.conversionsToBase.entries){
      if(_unitDescriptions[entry.key]!.isBase){
        localLogger.error("Conversion for base unit ${entry.key} cannot be declared");
        return false;
      }

      if(!_unitDescriptions[entry.value.to]!.isBase){
        localLogger.error("Conversion to non-base unit ${entry.value.to} cannot be declared");
        return false;
      }
    }
    return true;
  }

  static bool _checkNonBaseIsConvertible(){
    for(final MapEntry<UnitAlias, UnitDescription> entry in _unitDescriptions.entries.where((entry) => !entry.value.isBase)){
      if(!_conversionTable.conversionsToBase.containsKey(entry.key)){
        localLogger.error("Missing conversion to base for unit ${entry.key}");
        return false;
      }
    }
    return true;
  }

  static bool _checkCompositionUsesBaseUnits(){
    for(final MapEntry<String, List<MapEntry<double, List<MapEntry<UnitAlias, int>>>>> entry in _compositionTable.compositions.entries){
      if(!_unitDescriptions[entry.key]!.isBase){
        localLogger.error("Composition to non base unit ${entry.key} cannot be declared");
        return false;
      }

      if(entry.value.any((element) => element.value.map((e) => e.key).any((alias) => !_unitDescriptions[alias]!.isBase))){
        localLogger.error("Compositions cannot use non base units as components");
        return false;
      }
    }
    return true;
  }

  static bool _validate(){
    bool success = true;

    _ensureShortestUnitDescriptionRepresentationFirst();

    success &= _checkUnitAliasesReferecedHaveDesc();
    if(!success){
      return false;
    }

    success &= _checkDimHasOneBase();
    success &= _checkConversionStaysWithinDim();
    success &= _checkConversionIsToBase();
    success &= _checkNonBaseIsConvertible();
    success &= _checkCompositionUsesBaseUnits();
    
    if(!success){
      localLogger.error("Unit system validation failed");
    }

    return success;
  }

  static bool _setDefaults(){
    _loadDefaults();
    if(!_validate()){
      localLogger.error("Default unitsystem data is not valid", doNoti: false);
      return false;
    }
    localLogger.info("Default unit system loaded");
    _syncToDisk();
    return true;
  }

  static Future<bool> loadFromDisk() async {
    _unitDescriptions.clear();
    _conversionTable.conversionsToBase.clear();
    _compositionTable.compositions.clear();
    Map data = await FileSystem.tryLoadMapFromLocalAsync(FileSystem.unitSystemDir, "unit_system.json");
    if(data.isEmpty){
      return _setDefaults();
    }
    bool success = true;
    try{
      for(Map desc in data["unit_descriptions"]){
        if(_unitDescriptions.containsKey(desc.keys.single)){
          localLogger.error("Duplicate unit description detected for alias ${desc.keys.single}");
          success = false;
        }
        _unitDescriptions[desc.keys.single] = UnitDescription(representations: desc.values.single["representations"].cast<String>(), isBase: desc.values.single["is_base"], dim: desc.values.single["dim"]);
      }
    } catch (ex){
      success = false;
      localLogger.error("Failed to load unit system descriptions: $ex", doNoti: false);
    }

    try{
      for(final Map conv in data["conversions"]){
        if(_conversionTable.conversionsToBase.containsKey(conv["from"])){
          localLogger.error("Duplicate unit conversion detected for alias ${conv["from"]}");
          success = false;
        }
        _conversionTable.conversionsToBase[conv["from"]] = ConversionHelper(to: conv["to"], multiplier: conv["multiplier"]);
      }
    }catch (ex){
      success = false;
      localLogger.error("Failed to load unit system conversion table: $ex", doNoti: false);
    }

    try{
      _compositionTable.load(data["compositions"]);
    }catch (ex){
      success = false;
      localLogger.error("Failed to load unit system composition table: $ex", doNoti: false);
    }


    if(!success){
      localLogger.warning("Failed to load unit system, falling back to defaults");
      _unitDescriptions.clear();
      _conversionTable.conversionsToBase.clear();
      _compositionTable.compositions.clear();
      _loadDefaults();
      if(!_validate()){
        localLogger.error("Default unitsystem data is not valid", doNoti: false);
        localLogger.error("Fallback to default unit system failed");
        return false;
      }
      return true;
    }

    if(!_validate()){
      localLogger.error("Unit system validation failed, falling back to defaults");
      _unitDescriptions.clear();
      _conversionTable.conversionsToBase.clear();
      _compositionTable.compositions.clear();
      _loadDefaults();
      if(!_validate()){
        localLogger.error("Default unitsystem data is not valid", doNoti: false);
        localLogger.error("Fallback to default unit system failed");
        return false;
      }
      return true;
    }
    return true;
  }

  static ConversionResult _convertComplexBaseUnitToSimpleBaseElements(final UnitAlias unit, final int exponent){
    final List<UnitAlias> unitsTouched = [unit];

    final List<MapEntry<double, List<MapEntry<UnitAlias, int>>>> compositions = _compositionTable.compositions[unit]!;
    final int allBaseComposition = compositions.indexWhere((final MapEntry<double, List<MapEntry<UnitAlias, int>>> composition) => composition.value.every((final MapEntry<UnitAlias, int> part) => !_compositionTable.compositions.containsKey(part.key)));
    if(allBaseComposition == -1){
      final Map<UnitAlias, int> components = Map.fromEntries(compositions.first.value);
      double multiplier = compositions.first.key;
      while(components.keys.any((alias) => _compositionTable.compositions.containsKey(alias))){
        List<String> complexUnitsToConvert = components.keys.where((alias) => _compositionTable.compositions.containsKey(alias) && !unitsTouched.contains(alias)).toList();
        if(complexUnitsToConvert.isEmpty){
          break;
        }
        for(final UnitAlias toConvert in complexUnitsToConvert){
          final List<MapEntry<double, List<MapEntry<UnitAlias, int>>>> compositionsToCheck = _compositionTable.compositions[toConvert]!;
          final int allBaseCompositionPart = compositionsToCheck.indexWhere((final MapEntry<double, List<MapEntry<UnitAlias, int>>> composition) => composition.value.every((final MapEntry<UnitAlias, int> part) => !_compositionTable.compositions.containsKey(part.key)));
          late final List<MapEntry<UnitAlias, int>> compositionToUse;
          if(allBaseCompositionPart == -1){
            compositionToUse = compositionsToCheck.first.value;
            multiplier *= compositionsToCheck.first.key;
          }
          else{
            compositionToUse = compositionsToCheck[allBaseCompositionPart].value;
            multiplier *= compositionsToCheck[allBaseCompositionPart].key;
          }
          
          final int partExponent = components[toConvert]!;
          for(final MapEntry<UnitAlias, int> part in compositionToUse){
            if(components.containsKey(part.key)){
              components[part.key] = components[part.key]! + part.value * partExponent;
            }
            else{
              components[part.key] = part.value * partExponent;
            }
          }
          components.remove(toConvert);
          unitsTouched.add(toConvert);
        }
      }
      return ConversionResult(multiplier: multiplier, unitSeries: components);
    }
    else{
      final List<MapEntry<UnitAlias, int>> composition = compositions[allBaseComposition].value.map((final MapEntry<UnitAlias, int> part) => MapEntry<UnitAlias, int>(part.key, part.value * exponent)).toList();
      return ConversionResult(multiplier: compositions[allBaseComposition].key, unitSeries: Map.fromEntries(composition));
    }

  }  
  
  static ConversionResult _convertComplexUnitToSimpleBaseElements(final UnitAlias unit, final int exponent){
    final ConversionHelper helper = _conversionTable.conversionsToBase[unit]!;
    final ConversionResult res = _convertComplexBaseUnitToSimpleBaseElements(helper.to, exponent);
    return ConversionResult(multiplier: helper.multiplier * res.multiplier, unitSeries: res.unitSeries);
  }

  static ConversionResult _convertSimpleUnitToSimpleBase(final UnitAlias unit, final int exponent){
    final ConversionHelper helper = _conversionTable.conversionsToBase[unit]!;
    return ConversionResult(multiplier: helper.multiplier, unitSeries: {helper.to: exponent});
  }

  static CompoundUnit reduceToBase(final CompoundUnit unit){
    double multiplier = unit.multiplier;

    final Map<UnitAlias, int> nomReduced = {};

    for(final MapEntry<UnitAlias, int> elem in unit.nom.entries){
      if(_unitDescriptions[elem.key]!.isBase){
        if(!_compositionTable.compositions.containsKey(elem.key)){
          if(nomReduced.containsKey(elem.key)){
            nomReduced[elem.key] = nomReduced[elem.key]! + elem.value;
          }
          else{
            nomReduced[elem.key] = elem.value;
          }
        }
        else{
          final ConversionResult res = _convertComplexBaseUnitToSimpleBaseElements(elem.key, elem.value);
          multiplier *= res.multiplier;
          
          for(final MapEntry<UnitAlias, int> resElem in res.unitSeries.entries){
            if(nomReduced.containsKey(resElem.key)){
              nomReduced[resElem.key] = nomReduced[resElem.key]! + resElem.value;
            }
            else{
              nomReduced[resElem.key] = resElem.value;
            }
          }
        }
      }
      else{
        final UnitAlias baseAlias = _conversionTable.conversionsToBase[elem.key]!.to;
        if(!_compositionTable.compositions.containsKey(baseAlias)){
          final ConversionResult res = _convertSimpleUnitToSimpleBase(elem.key, elem.value);
          multiplier *= res.multiplier;
          
          for(final MapEntry<UnitAlias, int> resElem in res.unitSeries.entries){
            if(nomReduced.containsKey(resElem.key)){
              nomReduced[resElem.key] = nomReduced[resElem.key]! + resElem.value;
            }
            else{
              nomReduced[resElem.key] = resElem.value;
            }
          }
        }
        else{
          final ConversionResult res = _convertComplexUnitToSimpleBaseElements(elem.key, elem.value);
          multiplier *= res.multiplier;
          
          for(final MapEntry<UnitAlias, int> resElem in res.unitSeries.entries){
            if(nomReduced.containsKey(resElem.key)){
              nomReduced[resElem.key] = nomReduced[resElem.key]! + resElem.value;
            }
            else{
              nomReduced[resElem.key] = resElem.value;
            }
          }
        }
      }
    }

    for(final MapEntry<UnitAlias, int> elem in unit.denom.entries){
      if(_unitDescriptions[elem.key]!.isBase){
        if(!_compositionTable.compositions.containsKey(elem.key)){
          if(nomReduced.containsKey(elem.key)){
            nomReduced[elem.key] = nomReduced[elem.key]! - elem.value;
          }
          else{
            nomReduced[elem.key] = -elem.value;
          }
        }
        else{
          final ConversionResult res = _convertComplexBaseUnitToSimpleBaseElements(elem.key, elem.value);
          multiplier /= res.multiplier;
          
          for(final MapEntry<UnitAlias, int> resElem in res.unitSeries.entries){
            if(nomReduced.containsKey(resElem.key)){
              nomReduced[resElem.key] = nomReduced[resElem.key]! - resElem.value;
            }
            else{
              nomReduced[resElem.key] = -resElem.value;
            }
          }
        }
      }
      else{
        final UnitAlias baseAlias = _conversionTable.conversionsToBase[elem.key]!.to;
        if(!_compositionTable.compositions.containsKey(baseAlias)){
          final ConversionResult res = _convertSimpleUnitToSimpleBase(elem.key, elem.value);
          multiplier /= res.multiplier;
          
          for(final MapEntry<UnitAlias, int> resElem in res.unitSeries.entries){
            if(nomReduced.containsKey(resElem.key)){
              nomReduced[resElem.key] = nomReduced[resElem.key]! - resElem.value;
            }
            else{
              nomReduced[resElem.key] = -resElem.value;
            }
          }
        }
        else{
          final ConversionResult res = _convertComplexUnitToSimpleBaseElements(elem.key, elem.value);
          multiplier /= res.multiplier;
          
          for(final MapEntry<UnitAlias, int> resElem in res.unitSeries.entries){
            if(nomReduced.containsKey(resElem.key)){
              nomReduced[resElem.key] = nomReduced[resElem.key]! - resElem.value;
            }
            else{
              nomReduced[resElem.key] = -resElem.value;
            }
          }
        }
      }
    }

    return CompoundUnit(multiplier: multiplier, nom: nomReduced, denom: {});
  } 

  static CompoundUnit compose(final CompoundUnit unit){
    CompoundUnit base = reduceToBase(unit)..simplify();
    
    for(final MapEntry<UnitAlias, int> elem in base.denom.entries){
      if(base.nom.containsKey(elem.key)){
        base.nom[elem.key] = base.nom[elem.key]! - elem.value;
      }
      else{
        base.nom[elem.key] = -elem.value;
      }
    }
    base.denom.clear();

    bool didConvert = true;
    while(didConvert){
      didConvert = false;
      for(final MapEntry<String, List<MapEntry<double, List<MapEntry<String, int>>>>> composition in _compositionTable.compositions.entries){
        for(final MapEntry<double, List<MapEntry<UnitAlias, int>>> compOption in composition.value){
          final List<int> convertAmounts = [];
          for(final MapEntry<UnitAlias, int> compPart in compOption.value){
            if(base.nom.containsKey(compPart.key)){
              int amount = (base.nom[compPart.key]! / compPart.value).floor();
              if(amount < 0){
                amount = 0;
              }
              convertAmounts.add(amount);
            }
            else{
              convertAmounts.add(0);
              break;
            }
          }
          
          if(convertAmounts.isEmpty){
            continue;
          }
          final int maxPossibleConvert = convertAmounts.fold(double.maxFinite.toInt(), (prev, elem) => min(prev, elem));
          if(maxPossibleConvert > 0){
            didConvert = true;
            for(final MapEntry<UnitAlias, int> compPart in compOption.value){
              base.nom[compPart.key] = base.nom[compPart.key]! - compPart.value * maxPossibleConvert;
            }
            if(base.nom.containsKey(composition.key)){
              base.nom[composition.key] = base.nom[composition.key]! + maxPossibleConvert;
            }
            else{
              base.nom[composition.key] = maxPossibleConvert;
            }
            base.multiplier /= pow(compOption.key, maxPossibleConvert);
          }
        }
      }
    }

    for(final MapEntry<UnitAlias, int> elem in base.nom.entries){
      if(base.denom.containsKey(elem.key)){
        base.denom[elem.key] = base.denom[elem.key]! - elem.value;
      }
      else{
        base.denom[elem.key] = -elem.value;
      }
    }
    base.nom.clear();

    didConvert = true;
    while(didConvert){
      didConvert = false;
      for(final MapEntry<String, List<MapEntry<double, List<MapEntry<String, int>>>>> composition in _compositionTable.compositions.entries){
        for(final MapEntry<double, List<MapEntry<UnitAlias, int>>> compOption in composition.value){
          final List<int> convertAmounts = [];
          for(final MapEntry<UnitAlias, int> compPart in compOption.value){
            if(base.denom.containsKey(compPart.key)){
              int amount = (base.denom[compPart.key]! / compPart.value).floor();
              if(amount < 0){
                amount = 0;
              }
              convertAmounts.add(amount);
            }
            else{
              convertAmounts.add(0);
              break;
            }
          }
          
          if(convertAmounts.isEmpty){
            continue;
          }
          final int maxPossibleConvert = convertAmounts.fold(double.maxFinite.toInt(), (prev, elem) => min(prev, elem));
          if(maxPossibleConvert > 0){
            didConvert = true;
            for(final MapEntry<UnitAlias, int> compPart in compOption.value){
              base.denom[compPart.key] = base.denom[compPart.key]! - compPart.value * maxPossibleConvert;
            }
            if(base.denom.containsKey(composition.key)){
              base.denom[composition.key] = base.denom[composition.key]! + maxPossibleConvert;
            }
            else{
              base.denom[composition.key] = maxPossibleConvert;
            }
            base.multiplier *= pow(compOption.key, maxPossibleConvert);
          }
        }
      }
    }

    return base..simplify();
  }

  // ignore: unnecessary_string_escapes
  static String getRepresentationForAlias(final UnitAlias alias) => alias == "percent" ? "\\%" : _unitDescriptions[alias]!.representations.first;

  static List<String> get allRepresentations => _unitDescriptions.values.fold([], (prev, e) => prev..addAll(e.representations));

  static UnitAlias aliasOf(final String rep) => _unitDescriptions.entries.firstWhere((element) => element.value.representations.contains(rep)).key;
}

class ConversionResult{
  final double multiplier;
  final Map<UnitAlias, int> unitSeries;

  ConversionResult({required this.multiplier, required this.unitSeries});
}

class CompoundUnit{
  double multiplier;
  final Map<UnitAlias, int> nom;
  final Map<UnitAlias, int> denom;

  CompoundUnit({required this.multiplier, required this.nom, required this.denom});

  static CompoundUnit scalar(){
    return CompoundUnit(multiplier: 1, nom: {}, denom: {});
  }

  static CompoundUnit fromAlias(final UnitAlias alias){
    return CompoundUnit(multiplier: 1, nom: {alias: 1}, denom: {});
  }

  bool isScalar(){
    return nom.isEmpty && denom.isEmpty;
  }

  void simplify(){
    final List<UnitAlias> removeKeys = [];
    final List<UnitAlias> moveToDenomKeys = [];
    for(final MapEntry<UnitAlias, int> elem in denom.entries){
      if(nom.containsKey(elem.key)){
        nom[elem.key] = nom[elem.key]! - elem.value;
      }
      else{
        nom[elem.key] = -elem.value;
      }
    }

    denom.clear();

    for(final UnitAlias key in nom.keys){
      if(nom[key] == 0){
        removeKeys.add(key);
      }
      else if(nom[key]! < 0){
        moveToDenomKeys.add(key);
      }
    }

    for(final UnitAlias unit in removeKeys){
      nom.remove(unit);
    }

    for(final UnitAlias unit in moveToDenomKeys){
      denom[unit] = -nom.remove(unit)!;
    }
  }

  CompoundUnit compose(){
    return UnitSystem.compose(this);
  }

  CompoundUnit reducedToBaseSimplified(){
    return UnitSystem.reduceToBase(this)..simplify();
  }

  /*String toSimpleString(){
    
  }*/

  String toLaTextString(){
    if(isScalar()){
      return "";
    }
    else if(denom.isEmpty){
      final List<String> parts = nom.entries.map((e) {
        return e.value == 1 ? UnitSystem.getRepresentationForAlias(e.key) : "${UnitSystem.getRepresentationForAlias(e.key)}^{${e.value}}";
      }).toList();
      return "\$${parts.join(" \\cdot ")}\$";
    }
    else{
      final List<String> nomParts = nom.entries.map((e) {
        return e.value == 1 ? UnitSystem.getRepresentationForAlias(e.key) : "${UnitSystem.getRepresentationForAlias(e.key)}^{${e.value}}";
      }).toList();
      final List<String> denomParts = denom.entries.map((e) {
        return e.value == 1 ? UnitSystem.getRepresentationForAlias(e.key) : "${UnitSystem.getRepresentationForAlias(e.key)}^{${e.value}}";
      }).toList();
      return "\$\\frac{${nomParts.isEmpty ? "1" : nomParts.join(" \\cdot ")}}{${denomParts.join(" \\cdot ")}}\$";
    }
  }

  static CompoundUnit fromString(final String inp){
    final String str = inp.trim().toLowerCase();
    if(str.isEmpty){
      return CompoundUnit.scalar();
    }

    final Map<String, int> nom = {};
    final Map<String, int> denom = {};

    final List<String> tokens = List.unmodifiable(UnitSystem.allRepresentations);
    int i = 0;
    bool denomReached = false;
    if(str.startsWith('1/')){
      denomReached = true;
      i = 2;
    }

    while(i < str.length){
      if(str[i] == '/'){
        i++;
        denomReached = true;
      }

      Iterable<String> matched = tokens.where((token) => str.length - i >= token.length && str.substring(i, i + token.length) == token.toLowerCase());
      if(matched.isEmpty){
        localLogger.warning("Failed to parse unit $str", doNoti: false);
        return CompoundUnit.scalar();
      }
      final String largestMatch = matched.fold("", (previousValue, element) => previousValue.length > element.length ? previousValue : element);
      i += largestMatch.length;
      
      int j = 1;
      bool found = false;
      while(i + j <= str.length){
        final int? exp = int.tryParse(str.substring(i, (i + j).toInt()));
        if(exp != null){
          found = true;
          if(i + j + 1 <= str.length){
            j++;
          }
          else{
            break;
          }
        }
        else{
          j--;
          break;
        }
      }

      final int exp = found ? int.parse(str.substring(i, i + j)) : 1;
      i += j;

      if(denomReached){
        denom[UnitSystem.aliasOf(largestMatch)] = exp;
      }
      else{
        nom[UnitSystem.aliasOf(largestMatch)] = exp;
      }
    }    

    return CompoundUnit(multiplier: 1, nom: nom, denom: denom);
  }
}

abstract class UnitManipulation{
  static CompoundUnit unitMult(final CompoundUnit lhs, final CompoundUnit rhs){
    final CompoundUnit res = CompoundUnit.scalar();
    res.multiplier = lhs.multiplier * rhs.multiplier;

    final Map<UnitAlias, int> nom = {};
    final Map<UnitAlias, int> denom = {};
    nom.addAll(lhs.nom);
    denom.addAll(lhs.denom);

    for(final MapEntry<UnitAlias, int> elem in rhs.nom.entries){
      if(nom.containsKey(elem.key)){
        nom[elem.key] = nom[elem.key]! + elem.value;
      }
      else{
        nom[elem.key] = elem.value;
      }
    }

    for(final MapEntry<UnitAlias, int> elem in rhs.denom.entries){
      if(nom.containsKey(elem.key)){
        denom[elem.key] = denom[elem.key]! + elem.value;
      }
      else{
        denom[elem.key] = elem.value;
      }
    }

    res.nom.addAll(nom);
    res.denom.addAll(denom);

    res.simplify();
    return res.compose();
  }

  static CompoundUnit unitDiv(final CompoundUnit lhs, final CompoundUnit rhs){
    final CompoundUnit res = CompoundUnit.scalar();
    res.multiplier = lhs.multiplier / rhs.multiplier;
    
    final Map<UnitAlias, int> nom = {};
    final Map<UnitAlias, int> denom = {};    
    nom.addAll(lhs.nom);
    denom.addAll(lhs.denom);

    for(final MapEntry<UnitAlias, int> elem in rhs.nom.entries){
      if(nom.containsKey(elem.key)){
        nom[elem.key] = nom[elem.key]! - elem.value;
      }
      else{
        nom[elem.key] = -elem.value;
      }
    }

    for(final MapEntry<UnitAlias, int> elem in rhs.denom.entries){
      if(nom.containsKey(elem.key)){
        denom[elem.key] = denom[elem.key]! - elem.value;
      }
      else{
        denom[elem.key] = -elem.value;
      }
    }
    
    res.nom.addAll(nom);
    res.denom.addAll(denom);

    res.simplify();
    return res.compose();
  }
}

abstract class UnitConstraints{
  static bool isSameOrConvertible2(final CompoundUnit lhs, final CompoundUnit rhs){
    final CompoundUnit lhsReduced = lhs.reducedToBaseSimplified();
    final CompoundUnit rhsReduced = rhs.reducedToBaseSimplified();
    
    for(final MapEntry<UnitAlias, int> elem in lhsReduced.nom.entries){
      if(rhsReduced.nom.containsKey(elem.key) && rhsReduced.nom[elem.key] == elem.value){
        rhsReduced.nom.remove(elem.key);
      }
      else{
        return false;
      }
    }

    for(final MapEntry<UnitAlias, int> elem in lhsReduced.denom.entries){
      if(rhsReduced.denom.containsKey(elem.key) && rhsReduced.denom[elem.key] == elem.value){
        rhsReduced.denom.remove(elem.key);
      }
      else{
        return false;
      }
    }

    return rhsReduced.nom.isEmpty && rhsReduced.denom.isEmpty;
  }

  static bool isScalar1(final CompoundUnit lhs){
    return lhs.isScalar();
  }

  static bool isScalar2(final CompoundUnit lhs, final CompoundUnit rhs){
    return lhs.isScalar();
  }

  static bool isRadians1(final CompoundUnit lhs){
    return lhs.denom.isEmpty && lhs.nom.keys.singleOrNull == "radians";
  }

  static bool none1(final CompoundUnit lhs){
    return true;
  }

  static bool none2(final CompoundUnit lhs, final CompoundUnit rhs){
    return true;
  }
}

abstract class ResultUnits{
  static CompoundUnit unitOfInput1(final CompoundUnit inp){
    return inp;
  }

  static CompoundUnit scalar1(final CompoundUnit inp){
    return CompoundUnit.scalar();
  }

  static CompoundUnit unitOfEiher2(final CompoundUnit lhs, final CompoundUnit rhs){
    if(lhs.isScalar()){
      return rhs;
    }
    return lhs;
  }  
  
  static CompoundUnit unitOfFirst2(final CompoundUnit lhs, final CompoundUnit rhs){
    return lhs;
  }

  static CompoundUnit unitOfSecond2(final CompoundUnit lhs, final CompoundUnit rhs){
    return rhs;
  }

  static CompoundUnit scalar2(final CompoundUnit lhs, final CompoundUnit rhs){
    return CompoundUnit.scalar();
  }

  static CompoundUnit radians2(final CompoundUnit lhs, final CompoundUnit rhs){
    return CompoundUnit.fromAlias("radians");
  }
}
