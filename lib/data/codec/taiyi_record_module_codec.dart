import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:repository_interface_record/repository_interface_record.dart';
import 'package:repository_interface_taiyishenshu/repository_interface_taiyishenshu.dart';

final _log = Logger();

class TaiyiRecordModuleCodec
    implements RecordModuleCodec<TaiyiDivinationRecordContract> {
  @override
  String get module => 'taiyishenshu';

  @override
  String get category => 'divination';

  @override
  String get divinationType => 'taiyi';

  @override
  String uuidOf(TaiyiDivinationRecordContract contract) => contract.uuid;

  @override
  TaiyiDivinationRecordContract withUuid(
    TaiyiDivinationRecordContract contract,
    String uuid,
  ) {
    return TaiyiDivinationRecordContract(
      uuid: uuid,
      question: contract.question,
      datetimeJson: contract.datetimeJson,
      schoolId: contract.schoolId,
      juNumber: contract.juNumber,
      taiYiPalaceJson: contract.taiYiPalaceJson,
      ninePalaceJson: contract.ninePalaceJson,
      deitiesJson: contract.deitiesJson,
      paramsJson: contract.paramsJson,
      createdAt: contract.createdAt,
      updatedAt: contract.updatedAt,
      deletedAt: contract.deletedAt,
    );
  }

  @override
  EncodedRecord encode(
    TaiyiDivinationRecordContract contract, {
    required String scopeUid,
  }) {
    Map<String, dynamic>? params;
    if (contract.paramsJson != null && contract.paramsJson!.isNotEmpty) {
      try {
        params = jsonDecode(contract.paramsJson!) as Map<String, dynamic>;
      } catch (e) {
        _log.w('paramsJson decode failed, ignored: $e');
        params = null;
      }
    }

    final meta = RecordMeta(
      uuid: contract.uuid,
      scopeUid: scopeUid,
      module: module,
      category: category,
      divinationType: divinationType,
      createdAt: contract.createdAt,
      gender: (params?['isMale'] == true) ? 'M' : 'F',
      question: contract.question,
      occurredAtUtc: contract.createdAt,
      reckoningType: '标准时间',
      timezoneStr: params?['timezone'] ?? 'Asia/Shanghai',
      latitude: params?['latitude'],
      longitude: params?['longitude'],
      locationName: params?['locationName'],
    );

    final moduleData = <String, dynamic>{
      'chartJson': jsonEncode(contract.toJson()),
      'chartRequestJson': contract.paramsJson,
      'chartResultJson': contract.paramsJson,
    };

    return (meta: meta, moduleData: moduleData);
  }

  @override
  TaiyiDivinationRecordContract decode(
    RecordMeta meta,
    Map<String, dynamic>? moduleData,
  ) {
    if (meta.module != module) {
      throw RecordCodecMismatch(
        message: 'Expected module $module, got ${meta.module}',
      );
    }

    final chartJsonStr = moduleData?['chartJson'] as String?;
    Map<String, dynamic> chartMap = const {};
    if (chartJsonStr != null) {
      try {
        chartMap = jsonDecode(chartJsonStr) as Map<String, dynamic>;
      } catch (e) {
        _log.w('chartJson decode failed, ignored: $e');
        chartMap = const {};
      }
    }

    final uuid = meta.uuid;
    final question = (chartMap['question'] as String?) ?? meta.question ?? '';
    final createdAt = meta.occurredAtUtc ?? meta.createdAt;

    return TaiyiDivinationRecordContract(
      uuid: uuid,
      question: question,
      datetimeJson: chartMap['datetimeJson'] as String?,
      schoolId: null,
      juNumber: chartMap['juNumber'] as int?,
      taiYiPalaceJson: chartMap['taiYiPalaceJson'] as String?,
      ninePalaceJson: chartMap['ninePalaceJson'] as String?,
      deitiesJson: chartMap['deitiesJson'] as String?,
      paramsJson: moduleData?['chartResultJson'] as String?,
      createdAt: createdAt,
      updatedAt: null,
      deletedAt: null,
    );
  }

  @override
  List<SearchTag> extractSearchTags(
    RecordMeta meta,
    Map<String, dynamic>? moduleData,
  ) {
    final tags = <SearchTag>[];

    if (meta.gender != null) {
      tags.add(SearchTag('gender', meta.gender!));
    }

    if (meta.question != null) {
      tags.add(SearchTag('question', meta.question!));
    }

    if (meta.timezoneStr != null) {
      tags.add(SearchTag('timezone', meta.timezoneStr!));
    }

    tags.add(SearchTag('createdAt', meta.createdAt.toIso8601String()));

    return tags;
  }
}
