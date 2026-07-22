import 'dart:convert';
import 'package:repository_interface_taiyishenshu/repository_interface_taiyishenshu.dart';
import '../../enums/taiyi_enum_extensions.dart';
import '../pan_data_model.dart';

class SaveRecordUseCase {
  final TaiyiRecordRepository _recordRepo;

  SaveRecordUseCase(this._recordRepo);

  Future<String> call(PanDataModel panData) async {
    final record = TaiyiDivinationRecordContract(
      uuid: _generateUuid(),
      question: null,
      datetimeJson: panData.input.dateTime.toIso8601String(),
      schoolId: panData.input.schoolId,
      juNumber: panData.juNumber,
      taiYiPalaceJson: jsonEncode(panData.taiYiPalace.id),
      ninePalaceJson: jsonEncode(panData.palaces.map((p) => p.toJson()).toList()),
      deitiesJson: null,
      paramsJson: jsonEncode(panData.toJson()),
      createdAt: DateTime.now(),
    );
    return _recordRepo.saveRecord(record);
  }

  String _generateUuid() {
    final now = DateTime.now();
    final ms = now.microsecondsSinceEpoch;
    final r = (ms % 1000000).toString().padLeft(6, '0');
    return '${now.millisecondsSinceEpoch.toRadixString(36)}-$r';
  }
}
