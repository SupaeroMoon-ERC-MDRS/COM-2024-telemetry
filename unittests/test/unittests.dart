import 'package:test/test.dart';
import 'package:unittests/file_system.dart';
import 'package:unittests/unit_system.dart';

void testUnitSystem() {
  test('unit_system', () async {
    FileSystem.tryDeleteFromLocalSync(FileSystem.unitSystemDir, "unit_system.json");
    await UnitSystem.loadFromDisk();
    expect(UnitManipulation.unitMult(CompoundUnit.scalar(), CompoundUnit.fromString("1/sm")).denom, {"meters": 1, "seconds": 1});
    expect(UnitManipulation.unitMult(CompoundUnit.scalar(), CompoundUnit.fromString("1/ms")).denom, {"seconds": 1});
    expect(UnitManipulation.unitMult(CompoundUnit.scalar(), CompoundUnit.fromString("1/ms")).multiplier, 1000);
    expect(UnitManipulation.unitDiv(CompoundUnit.fromString("mkg/s"), CompoundUnit.fromString("s")).nom, {"newtons": 1});
    expect(UnitManipulation.unitMult(CompoundUnit.fromString("N"), CompoundUnit.fromString("s/mkg")).denom, {"seconds": 1});
  });
}
