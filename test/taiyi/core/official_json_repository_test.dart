import 'package:flutter_test/flutter_test.dart';
import 'package:taiyishenshu/taiyi/core/school_config.dart';
import 'package:taiyishenshu/taiyi/core/school_repository.dart';
import 'package:taiyishenshu/taiyi/core/deity_definition.dart';
import 'package:taiyishenshu/taiyi/core/algorithm_enums.dart';
import 'package:taiyishenshu/enums/deity_kind.dart';

void main() {
  group('SchoolEpochConfig', () {
    test('积年计算: 金镜 724年', () {
      const config = SchoolEpochConfig(
        ancientBase: 1937281,
        epochYear: 724,
        correction: 0,
      );
      expect(config.calculateAccumulatedYear(724), 1937281);
      expect(config.calculateAccumulatedYear(2024), 1937281 + (2024 - 724));
    });

    test('积年计算: 统宗 基年', () {
      const config = SchoolEpochConfig(
        ancientBase: 10155219,
        epochYear: 1303,
        correction: 0,
      );
      expect(config.calculateAccumulatedYear(1303), 10155219);
    });

    test('积年计算: 带修正值', () {
      const config = SchoolEpochConfig(
        ancientBase: 10155219,
        epochYear: 1303,
        correction: 130,
      );
      expect(config.calculateAccumulatedYear(1303), 10155219 + 130);
    });
  });

  group('TaiYiSchool JSON 序列化', () {
    test('从 JSON 反序列化', () {
      final json = {
        'id': 'testSchool',
        'name': '测试派',
        'source': 'official',
        'epoch': {
          'ancientBase': 10155219,
          'epochYear': 1303,
          'correction': 0,
          'tropicalYear': 365.2425,
        },
        'deityIds': ['junJi', 'chenJi'],
        'wenChangStayRule': true,
        'useTwelveJiShen': false,
        'palaceFormula': 'jingMirror',
        'eightDoorMode': 'dynamic',
      };
      final school = TaiYiSchool.fromJson(json);
      expect(school.id, 'testSchool');
      expect(school.name, '测试派');
      expect(school.epoch.ancientBase, 10155219);
      expect(school.epoch.epochYear, 1303);
      expect(school.deityIds, ['junJi', 'chenJi']);
    });
  });

  group('DeityDefinition JSON 序列化', () {
    test('从 JSON 反序列化', () {
      final json = {
        'id': 'siShen_qingLong',
        'name': '青龙',
        'layer': 'shenPan',
        'algorithm': {
          'templateId': 'fixedPosition',
          'params': {'gong': '艮'},
        },
        'priority': 50,
        'source': 'official',
      };
      final deity = DeityDefinition.fromJson(json);
      expect(deity.id, 'siShen_qingLong');
      expect(deity.name, '青龙');
      expect(deity.layer, EnumDeityLayer.shenPan);
      expect(deity.algorithm.templateId, AlgorithmTemplateId.fixedPosition);
      expect(deity.algorithm.params['gong'], '艮');
    });
  });

  group('OfficialJsonSchoolRepository', () {
    test('saveSchool 抛出 UnsupportedError', () {
      final repo = OfficialJsonSchoolRepositoryMock();
      expect(
        () => repo.saveSchool(const TaiYiSchool(
          id: 'test', name: 'test',
          epoch: SchoolEpochConfig(ancientBase: 0, epochYear: 0),
        )),
        throwsUnsupportedError,
      );
    });

    test('deleteSchool 抛出 UnsupportedError', () {
      final repo = OfficialJsonSchoolRepositoryMock();
      expect(
        () => repo.deleteSchool('test'),
        throwsUnsupportedError,
      );
    });
  });
}

class OfficialJsonSchoolRepositoryMock implements SchoolRepository {
  @override
  Future<List<TaiYiSchool>> loadAllSchools() async => [];
  @override
  Future<TaiYiSchool?> loadSchool(String id) async => null;
  @override
  Future<List<DeityDefinition>> loadAllDeities() async => [];
  @override
  Future<DeityDefinition?> loadDeity(String id) async => null;
  @override
  Future<void> saveSchool(TaiYiSchool school) => throw UnsupportedError('Official repository is read-only');
  @override
  Future<void> saveDeity(DeityDefinition deity) => throw UnsupportedError('Official repository is read-only');
  @override
  Future<void> deleteSchool(String id) => throw UnsupportedError('Official repository is read-only');
  @override
  Future<void> deleteDeity(String id) => throw UnsupportedError('Official repository is read-only');
}
