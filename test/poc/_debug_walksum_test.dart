import 'package:flutter_test/flutter_test.dart';
import 'package:taiyishenshu/taiyi/rules/foundation_result.dart';
import 'package:taiyishenshu/taiyi/rules/school_repository.dart';
import 'package:taiyishenshu/taiyi/rules/rule_engine.dart';
import 'package:taiyishenshu/taiyi/rules/rule_models.dart';

void main() {
  test('Debug jingMirror walkSum rules for year 2026', () {
    final doc = SchoolRepository.loadOfficialSchoolSync('jingMirror');
    expect(doc, isNotNull);
    
    final engine = RuleEngine(
      school: doc!,
      contextVars: {'Y': 2026},
      isYang: true,
    );

    // Evaluate host calc
    try {
      final val = engine.evaluateRuleById('calc.host');
      print('calc.host: $val (type: ${val.runtimeType})');
      if (val is ScalarRuleValue) {
        print('  host value: ${val.value}');
      }
    } catch (e) {
      print('calc.host ERROR: $e');
    }

    // Evaluate guest calc
    try {
      final val = engine.evaluateRuleById('calc.guest');
      print('calc.guest: $val (type: ${val.runtimeType})');
      if (val is ScalarRuleValue) {
        print('  guest value: ${val.value}');
      }
    } catch (e) {
      print('calc.guest ERROR: $e');
    }

    // Evaluate ding calc
    try {
      final val = engine.evaluateRuleById('calc.ding');
      print('calc.ding: $val (type: ${val.runtimeType})');
      if (val is ScalarRuleValue) {
        print('  ding value: ${val.value}');
      }
    } catch (e) {
      print('calc.ding ERROR: $e');
    }

    // Evaluate foundation wenChang
    try {
      final val = engine.evaluateRuleById('foundation.wenChang');
      print('foundation.wenChang: $val (type: ${val.runtimeType})');
    } catch (e) {
      print('foundation.wenChang ERROR: $e');
    }

    // Evaluate foundation shiJi
    try {
      final val = engine.evaluateRuleById('foundation.shiJi');
      print('foundation.shiJi: $val (type: ${val.runtimeType})');
    } catch (e) {
      print('foundation.shiJi ERROR: $e');
    }

    // Evaluate foundation taiYi
    try {
      final val = engine.evaluateRuleById('foundation.taiYi');
      print('foundation.taiYi: $val (type: ${val.runtimeType})');
    } catch (e) {
      print('foundation.taiYi ERROR: $e');
    }

    // Evaluate foundation dingStart
    try {
      final val = engine.evaluateRuleById('foundation.dingStart');
      print('foundation.dingStart: $val (type: ${val.runtimeType})');
    } catch (e) {
      print('foundation.dingStart ERROR: $e');
    }
  });
}
