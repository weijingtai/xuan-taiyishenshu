import 'dart:convert';

class SchoolValidationError {
  final String schoolId;
  final String fieldPath;
  final String message;

  SchoolValidationError({
    required this.schoolId,
    required this.fieldPath,
    required this.message,
  });

  @override
  String toString() => '[$schoolId] $fieldPath: $message';

  Map<String, dynamic> toJson() => {
        'schoolId': schoolId,
        'fieldPath': fieldPath,
        'message': message,
      };
}

class SchoolDocument {
  final int schemaVersion;
  final SchoolMeta meta;
  final String palace;
  final List<SchoolRule> rules;
  final SchoolCharts charts;
  final SchoolDun dun;
  final SchoolFoundation foundation;
  final SchoolThreeCalc threeCalc;
  final SchoolGenerals generals;
  final List<SchoolDeity> deities;
  final List<SchoolGeJu> geJu;

  SchoolDocument({
    required this.schemaVersion,
    required this.meta,
    required this.palace,
    required this.rules,
    required this.charts,
    required this.dun,
    required this.foundation,
    required this.threeCalc,
    required this.generals,
    required this.deities,
    required this.geJu,
  });

  factory SchoolDocument.fromJson(Map<String, dynamic> json) {
    final rulesJson = json['rules'] as List? ?? [];
    final deitiesJson = json['deities'] as List? ?? [];
    final geJuJson = json['geJu'] as List? ?? [];

    return SchoolDocument(
      schemaVersion: json['schemaVersion'] as int? ?? 0,
      meta: SchoolMeta.fromJson(json['meta'] as Map<String, dynamic>? ?? {}),
      palace: json['palace'] as String? ?? '',
      rules: rulesJson.map((r) => SchoolRule.fromJson(r as Map<String, dynamic>)).toList(),
      charts: SchoolCharts.fromJson(json['charts'] as Map<String, dynamic>? ?? {}),
      dun: SchoolDun.fromJson(json['dun'] as Map<String, dynamic>? ?? {}),
      foundation: SchoolFoundation.fromJson(json['foundation'] as Map<String, dynamic>? ?? {}),
      threeCalc: SchoolThreeCalc.fromJson(json['threeCalc'] as Map<String, dynamic>? ?? {}),
      generals: SchoolGenerals.fromJson(json['generals'] as Map<String, dynamic>? ?? {}),
      deities: deitiesJson.map((d) => SchoolDeity.fromJson(d as Map<String, dynamic>)).toList(),
      geJu: geJuJson.map((g) => SchoolGeJu.fromJson(g as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'schemaVersion': schemaVersion,
        'meta': meta.toJson(),
        'palace': palace,
        'rules': rules.map((r) => r.toJson()).toList(),
        'charts': charts.toJson(),
        'dun': dun.toJson(),
        'foundation': foundation.toJson(),
        'threeCalc': threeCalc.toJson(),
        'generals': generals.toJson(),
        'deities': deities.map((d) => d.toJson()).toList(),
        'geJu': geJu.map((g) => g.toJson()).toList(),
      };
}

class SchoolMeta {
  final String id;
  final String name;
  final int version;
  final String source;
  final String owner; // official | user

  SchoolMeta({
    required this.id,
    required this.name,
    required this.version,
    required this.source,
    required this.owner,
  });

  factory SchoolMeta.fromJson(Map<String, dynamic> json) {
    return SchoolMeta(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      version: json['version'] as int? ?? 1,
      source: json['source'] as String? ?? '',
      owner: json['owner'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'version': version,
        'source': source,
        'owner': owner,
      };
}

class SchoolCharts {
  final SchoolChartConfig? year;
  final SchoolChartConfig? month;
  final SchoolChartConfig? day;
  final SchoolChartConfig? hour;

  SchoolCharts({this.year, this.month, this.day, this.hour});

  factory SchoolCharts.fromJson(Map<String, dynamic> json) {
    return SchoolCharts(
      year: json['year'] != null ? SchoolChartConfig.fromJson(json['year'] as Map<String, dynamic>) : null,
      month: json['month'] != null ? SchoolChartConfig.fromJson(json['month'] as Map<String, dynamic>) : null,
      day: json['day'] != null ? SchoolChartConfig.fromJson(json['day'] as Map<String, dynamic>) : null,
      hour: json['hour'] != null ? SchoolChartConfig.fromJson(json['hour'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        if (year != null) 'year': year!.toJson(),
        if (month != null) 'month': month!.toJson(),
        if (day != null) 'day': day!.toJson(),
        if (hour != null) 'hour': hour!.toJson(),
      };
}

class SchoolChartConfig {
  final bool enabled;
  final String ruJuRef;
  final List<String> appliesTo;

  SchoolChartConfig({
    required this.enabled,
    required this.ruJuRef,
    required this.appliesTo,
  });

  factory SchoolChartConfig.fromJson(Map<String, dynamic> json) {
    return SchoolChartConfig(
      enabled: json['enabled'] as bool? ?? false,
      ruJuRef: json['ruJuRef'] as String? ?? '',
      appliesTo: (json['appliesTo'] as List?)?.map((e) => e as String).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
        'enabled': enabled,
        'ruJuRef': ruJuRef,
        'appliesTo': appliesTo,
      };
}

class SchoolDun {
  final String resolver;
  final String termMode; // leveling | stabilizing
  final String? calibration; // winterReset

  SchoolDun({
    required this.resolver,
    required this.termMode,
    this.calibration,
  });

  factory SchoolDun.fromJson(Map<String, dynamic> json) {
    return SchoolDun(
      resolver: json['resolver'] as String? ?? '',
      termMode: json['termMode'] as String? ?? '',
      calibration: json['calibration'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'resolver': resolver,
        'termMode': termMode,
        if (calibration != null) 'calibration': calibration,
      };
}

class SchoolFoundation {
  final String taiYiRef;
  final String wenChangRef;
  final String jiShenRef;
  final String shiJiRef;

  SchoolFoundation({
    required this.taiYiRef,
    required this.wenChangRef,
    required this.jiShenRef,
    required this.shiJiRef,
  });

  factory SchoolFoundation.fromJson(Map<String, dynamic> json) {
    return SchoolFoundation(
      taiYiRef: json['taiYiRef'] as String? ?? '',
      wenChangRef: json['wenChangRef'] as String? ?? '',
      jiShenRef: json['jiShenRef'] as String? ?? '',
      shiJiRef: json['shiJiRef'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'taiYiRef': taiYiRef,
        'wenChangRef': wenChangRef,
        'jiShenRef': jiShenRef,
        'shiJiRef': shiJiRef,
      };
}

class SchoolThreeCalc {
  final String hostRef;
  final String guestRef;
  final String dingRef;

  SchoolThreeCalc({
    required this.hostRef,
    required this.guestRef,
    required this.dingRef,
  });

  factory SchoolThreeCalc.fromJson(Map<String, dynamic> json) {
    return SchoolThreeCalc(
      hostRef: json['hostRef'] as String? ?? '',
      guestRef: json['guestRef'] as String? ?? '',
      dingRef: json['dingRef'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'hostRef': hostRef,
        'guestRef': guestRef,
        'dingRef': dingRef,
      };
}

class SchoolGenerals {
  final String hostMajorRef;
  final String hostMinorRef;
  final String guestMajorRef;
  final String guestMinorRef;
  final String? dingMajorRef;
  final String? dingMinorRef;

  SchoolGenerals({
    required this.hostMajorRef,
    required this.hostMinorRef,
    required this.guestMajorRef,
    required this.guestMinorRef,
    this.dingMajorRef,
    this.dingMinorRef,
  });

  factory SchoolGenerals.fromJson(Map<String, dynamic> json) {
    return SchoolGenerals(
      hostMajorRef: json['hostMajorRef'] as String? ?? '',
      hostMinorRef: json['hostMinorRef'] as String? ?? '',
      guestMajorRef: json['guestMajorRef'] as String? ?? '',
      guestMinorRef: json['guestMinorRef'] as String? ?? '',
      dingMajorRef: json['dingMajorRef'] as String?,
      dingMinorRef: json['dingMinorRef'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'hostMajorRef': hostMajorRef,
        'hostMinorRef': hostMinorRef,
        'guestMajorRef': guestMajorRef,
        'guestMinorRef': guestMinorRef,
        if (dingMajorRef != null) 'dingMajorRef': dingMajorRef,
        if (dingMinorRef != null) 'dingMinorRef': dingMinorRef,
      };
}

class SchoolDeity {
  final String id;
  final String name;
  final String layer; // tian | ren | shen
  final List<String> appliesTo;
  final String ruleRef;
  final bool visible;

  SchoolDeity({
    required this.id,
    required this.name,
    required this.layer,
    required this.appliesTo,
    required this.ruleRef,
    required this.visible,
  });

  factory SchoolDeity.fromJson(Map<String, dynamic> json) {
    return SchoolDeity(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      layer: json['layer'] as String? ?? '',
      appliesTo: (json['appliesTo'] as List?)?.map((e) => e as String).toList() ?? [],
      ruleRef: json['ruleRef'] as String? ?? '',
      visible: json['visible'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'layer': layer,
        'appliesTo': appliesTo,
        'ruleRef': ruleRef,
        'visible': visible,
      };
}

class SchoolGeJu {
  final String id;
  final String ruleRef;

  SchoolGeJu({
    required this.id,
    required this.ruleRef,
  });

  factory SchoolGeJu.fromJson(Map<String, dynamic> json) {
    return SchoolGeJu(
      id: json['id'] as String? ?? '',
      ruleRef: json['ruleRef'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'ruleRef': ruleRef,
      };
}

class Provenance {
  final List<String> values;
  final String source;

  Provenance({required this.values, required this.source});

  factory Provenance.fromJson(Map<String, dynamic> json) {
    return Provenance(
      values: (json['values'] as List?)?.map((e) => e as String).toList() ?? [],
      source: json['source'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'values': values,
        'source': source,
      };
}

class SchoolRule {
  final String id;
  final String kind;
  final String output;
  final Map<String, dynamic> originalJson;

  SchoolRule({
    required this.id,
    required this.kind,
    required this.output,
    required this.originalJson,
  });

  factory SchoolRule.fromJson(Map<String, dynamic> json) {
    return SchoolRule(
      id: json['id'] as String? ?? '',
      kind: json['kind'] as String? ?? '',
      output: json['output'] as String? ?? '',
      originalJson: json,
    );
  }

  Map<String, dynamic> toJson() => originalJson;
}

List<SchoolValidationError> validateSchoolJson(Map<String, dynamic> json) {
  final List<SchoolValidationError> errors = [];
  final schoolId = (json['meta'] as Map?)?['id'] as String? ?? 'unknown';

  // 1. schemaVersion check
  final schemaVersion = json['schemaVersion'];
  if (schemaVersion == null) {
    errors.add(SchoolValidationError(
      schoolId: schoolId,
      fieldPath: 'schemaVersion',
      message: 'schemaVersion is required',
    ));
  } else if (schemaVersion != 1) {
    errors.add(SchoolValidationError(
      schoolId: schoolId,
      fieldPath: 'schemaVersion',
      message: 'unknown schemaVersion: $schemaVersion',
    ));
  }

  // 2. meta check
  final meta = json['meta'];
  if (meta is! Map) {
    errors.add(SchoolValidationError(
      schoolId: schoolId,
      fieldPath: 'meta',
      message: 'meta must be a Map',
    ));
  } else {
    final owner = meta['owner'];
    if (owner != 'official' && owner != 'user') {
      errors.add(SchoolValidationError(
        schoolId: schoolId,
        fieldPath: 'meta.owner',
        message: 'owner must be official or user',
      ));
    }
  }

  // 3. rules list check and unique id
  final rules = json['rules'];
  final Map<String, String> ruleOutputs = {};
  if (rules is! List) {
    errors.add(SchoolValidationError(
      schoolId: schoolId,
      fieldPath: 'rules',
      message: 'rules must be a List',
    ));
  } else {
    final Set<String> ruleIds = {};
    for (int i = 0; i < rules.length; i++) {
      final rule = rules[i];
      if (rule is! Map) {
        errors.add(SchoolValidationError(
          schoolId: schoolId,
          fieldPath: 'rules[$i]',
          message: 'rule must be a Map',
        ));
        continue;
      }

      final id = rule['id'];
      if (id is! String || id.isEmpty) {
        errors.add(SchoolValidationError(
          schoolId: schoolId,
          fieldPath: 'rules[$i].id',
          message: 'rule id must be a non-empty string',
        ));
      } else {
        if (ruleIds.contains(id)) {
          errors.add(SchoolValidationError(
            schoolId: schoolId,
            fieldPath: 'rules[$i].id',
            message: 'duplicate rule id: $id',
          ));
        }
        ruleIds.add(id);
      }

      final kind = rule['kind'] as String? ?? '';
      final validKinds = {'scalar', 'walk', 'walkSum', 'deriveCount', 'relative', 'table', 'predicate', 'shiJi', 'dingMu'};
      if (!validKinds.contains(kind)) {
        errors.add(SchoolValidationError(
          schoolId: schoolId,
          fieldPath: 'rules[$i].kind',
          message: 'unknown kind: $kind',
        ));
      }

      final output = rule['output'] as String? ?? '';
      final validOutputs = {'scalar', 'palace', 'deity', 'predicate'};
      if (!validOutputs.contains(output)) {
        errors.add(SchoolValidationError(
          schoolId: schoolId,
          fieldPath: 'rules[$i].output',
          message: 'unknown output: $output',
        ));
      } else if (id is String) {
        ruleOutputs[id] = output;
      }

      if (output == 'record') {
        errors.add(SchoolValidationError(
          schoolId: schoolId,
          fieldPath: 'rules[$i].output',
          message: 'record is not allowed in School JSON rules',
        ));
      }

      // Check specific fields of each kind
      _validateRuleDetails(schoolId, 'rules[$i]', rule, errors);
    }
  }

  // 4. references check and DAG check
  if (errors.isEmpty) {
    _validateReferencesAndDAG(schoolId, json, ruleOutputs, errors);
  }

  return errors;
}

void _validateRuleDetails(
    String schoolId, String path, Map<dynamic, dynamic> rule, List<SchoolValidationError> errors) {
  final kind = rule['kind'] as String? ?? '';

  if (kind == 'scalar') {
    final tree = rule['tree'];
    if (tree == null) {
      errors.add(SchoolValidationError(
          schoolId: schoolId, fieldPath: '$path.tree', message: 'tree is required for scalar rule'));
    } else {
      _validateAST(schoolId, '$path.tree', tree, errors, 0);
    }
    final z = rule['zeroAsCycle'];
    if (z != null && z is! int) {
      errors.add(SchoolValidationError(
          schoolId: schoolId, fieldPath: '$path.zeroAsCycle', message: 'zeroAsCycle must be an int'));
    }
  } else if (kind == 'walk') {
    final system = rule['palaceSystem'];
    final validSys = {'eight8', 'sixteenGods', 'twelveBranch'};
    if (system is! String || !validSys.contains(system)) {
      errors.add(SchoolValidationError(
          schoolId: schoolId, fieldPath: '$path.palaceSystem', message: 'invalid palaceSystem: $system'));
    }

    final start = rule['start'];
    if (start is! String && start is! Map) {
      errors.add(SchoolValidationError(
          schoolId: schoolId, fieldPath: '$path.start', message: 'start must be String or Map'));
    } else if (start is Map) {
      if (start['yang'] == null || start['yin'] == null) {
        errors.add(SchoolValidationError(
            schoolId: schoolId, fieldPath: '$path.start', message: 'start map must contain yang and yin'));
      }
    }

    final direction = rule['direction'];
    if (direction is! String && direction is! Map) {
      errors.add(SchoolValidationError(
          schoolId: schoolId, fieldPath: '$path.direction', message: 'direction must be String or Map'));
    }

    final steps = rule['steps'];
    if (steps == null) {
      errors.add(SchoolValidationError(
          schoolId: schoolId, fieldPath: '$path.steps', message: 'steps is required for walk rule'));
    } else {
      _validateAST(schoolId, '$path.steps', steps, errors, 0);
    }

    final restAt = rule['restAt'];
    if (restAt != null) {
      if (restAt is! Map) {
        errors.add(SchoolValidationError(
            schoolId: schoolId, fieldPath: '$path.restAt', message: 'restAt must be a Provenance object'));
      } else {
        if (restAt['values'] is! List || restAt['source'] is! String) {
          errors.add(SchoolValidationError(
              schoolId: schoolId,
              fieldPath: '$path.restAt',
              message: 'restAt must have values (List) and source (String)'));
        }
      }
    }
  } else if (kind == 'walkSum') {
    if (rule['startRef'] == null) {
      errors.add(SchoolValidationError(
          schoolId: schoolId, fieldPath: '$path.startRef', message: 'startRef is required for walkSum'));
    }
    final ep = rule['endpoint'];
    if (ep != null && ep is! Map) {
      errors.add(SchoolValidationError(
          schoolId: schoolId, fieldPath: '$path.endpoint', message: 'endpoint must be a Map'));
    }
    final norm = rule['normalize'];
    if (norm != null && norm != '满十去十') {
      errors.add(SchoolValidationError(
          schoolId: schoolId, fieldPath: '$path.normalize', message: 'unsupported normalize: $norm'));
    }
    final wu = rule['wuSuan'];
    if (wu != null && wu is! Map) {
      errors.add(SchoolValidationError(
          schoolId: schoolId, fieldPath: '$path.wuSuan', message: 'wuSuan must be a Map'));
    }
  } else if (kind == 'deriveCount') {
    if (rule['countRef'] == null) {
      errors.add(SchoolValidationError(
          schoolId: schoolId, fieldPath: '$path.countRef', message: 'countRef is required for deriveCount'));
    }
    if (rule['daMap'] is! Map) {
      errors.add(SchoolValidationError(
          schoolId: schoolId, fieldPath: '$path.daMap', message: 'daMap must be a Map'));
    }
    final minor = rule['minorTree'];
    if (minor != null) {
      _validateAST(schoolId, '$path.minorTree', minor, errors, 0);
    }
  } else if (kind == 'relative') {
    if (rule['baseRef'] == null) {
      errors.add(SchoolValidationError(
          schoolId: schoolId, fieldPath: '$path.baseRef', message: 'baseRef is required for relative'));
    }
    final mode = rule['mode'];
    if (mode != 'opposition' && mode != 'offset') {
      errors.add(SchoolValidationError(
          schoolId: schoolId, fieldPath: '$path.mode', message: 'invalid mode: $mode'));
    }
  } else if (kind == 'table') {
    if (rule['table'] is! List) {
      errors.add(SchoolValidationError(
          schoolId: schoolId, fieldPath: '$path.table', message: 'table must be a List'));
    }
    final idx = rule['indexTree'];
    if (idx == null) {
      errors.add(SchoolValidationError(
          schoolId: schoolId, fieldPath: '$path.indexTree', message: 'indexTree is required for table'));
    } else {
      _validateAST(schoolId, '$path.indexTree', idx, errors, 0);
    }
  } else if (kind == 'predicate') {
    final when = rule['when'];
    if (when is! Map) {
      errors.add(SchoolValidationError(
          schoolId: schoolId, fieldPath: '$path.when', message: 'when must be a Map'));
    } else {
      final op = when['op'];
      final validOps = {'eq', 'adjacent', 'coLocatedEqualCount'};
      if (!validOps.contains(op)) {
        errors.add(SchoolValidationError(
            schoolId: schoolId, fieldPath: '$path.when.op', message: 'invalid op: $op'));
      }
      if (when['args'] is! List) {
        errors.add(SchoolValidationError(
            schoolId: schoolId, fieldPath: '$path.when.args', message: 'args must be a List'));
      }
    }
  }
}

void _validateAST(String schoolId, String path, dynamic node, List<SchoolValidationError> errors, int depth) {
  if (depth > 16) {
    errors.add(SchoolValidationError(
      schoolId: schoolId,
      fieldPath: path,
      message: 'AST depth exceeds limit of 16',
    ));
    return;
  }

  if (node is! Map) {
    errors.add(SchoolValidationError(
      schoolId: schoolId,
      fieldPath: path,
      message: 'AST node must be a Map, got: $node',
    ));
    return;
  }

  final keys = node.keys.toSet();
  if (keys.isEmpty) {
    errors.add(SchoolValidationError(
      schoolId: schoolId,
      fieldPath: path,
      message: 'AST node cannot be empty',
    ));
    return;
  }

  // White list: int, num, var, op, floor
  final firstKey = keys.first;
  final allowedKeys = {'int', 'num', 'var', 'op', 'floor'};
  if (!allowedKeys.contains(firstKey)) {
    errors.add(SchoolValidationError(
      schoolId: schoolId,
      fieldPath: path,
      message: 'illegal AST node key: $firstKey',
    ));
    return;
  }

  if (firstKey == 'int') {
    if (node['int'] is! int) {
      errors.add(SchoolValidationError(
        schoolId: schoolId,
        fieldPath: '$path.int',
        message: 'int value must be an integer',
      ));
    }
  } else if (firstKey == 'num') {
    if (node['num'] is! num) {
      errors.add(SchoolValidationError(
        schoolId: schoolId,
        fieldPath: '$path.num',
        message: 'num value must be a number',
      ));
    }
  } else if (firstKey == 'var') {
    if (node['var'] is! String || (node['var'] as String).isEmpty) {
      errors.add(SchoolValidationError(
        schoolId: schoolId,
        fieldPath: '$path.var',
        message: 'var value must be a non-empty string',
      ));
    }
  } else if (firstKey == 'floor') {
    _validateAST(schoolId, '$path.floor', node['floor'], errors, depth + 1);
  } else if (firstKey == 'op') {
    final op = node['op'];
    final allowedOps = {'+', '-', '*', '~/', '%'};
    if (!allowedOps.contains(op)) {
      errors.add(SchoolValidationError(
        schoolId: schoolId,
        fieldPath: '$path.op',
        message: 'illegal operator: $op',
      ));
    }
    _validateAST(schoolId, '$path.a', node['a'], errors, depth + 1);
    _validateAST(schoolId, '$path.b', node['b'], errors, depth + 1);
  }
}

void _validateReferencesAndDAG(String schoolId, Map<String, dynamic> json, Map<String, String> ruleOutputs,
    List<SchoolValidationError> errors) {
  // Collect all references
  final Map<String, List<String>> adj = {};
  for (final ruleId in ruleOutputs.keys) {
    adj[ruleId] = [];
  }

  void addRef(String fromId, dynamic ref, String expectedType, String fieldName) {
    if (ref == null) return;
    if (ref is! String) {
      errors.add(SchoolValidationError(
        schoolId: schoolId,
        fieldPath: 'rules.$fromId.$fieldName',
        message: 'ref must be a string',
      ));
      return;
    }
    if (!ruleOutputs.containsKey(ref)) {
      errors.add(SchoolValidationError(
        schoolId: schoolId,
        fieldPath: 'rules.$fromId.$fieldName',
        message: 'referenced rule not found: $ref',
      ));
      return;
    }
    final actualType = ruleOutputs[ref]!;
    if (actualType != expectedType) {
      errors.add(SchoolValidationError(
        schoolId: schoolId,
        fieldPath: 'rules.$fromId.$fieldName',
        message: 'type mismatch: expected $expectedType, got $actualType for rule $ref',
      ));
    }
    adj[fromId]?.add(ref);
  }

  // Parse rules and add dependency edges
  final rules = json['rules'] as List? ?? [];
  for (final r in rules) {
    if (r is! Map) continue;
    final id = r['id'] as String? ?? '';
    final kind = r['kind'] as String? ?? '';
    if (id.isEmpty) continue;

    if (kind == 'walkSum') {
      final startRef = r['startRef'];
      if (startRef != null) {
        if (startRef is! String) {
          errors.add(SchoolValidationError(
            schoolId: schoolId,
            fieldPath: 'rules.$id.startRef',
            message: 'ref must be a string',
          ));
        } else if (!ruleOutputs.containsKey(startRef)) {
          errors.add(SchoolValidationError(
            schoolId: schoolId,
            fieldPath: 'rules.$id.startRef',
            message: 'referenced rule not found: $startRef',
          ));
        } else {
          final out = ruleOutputs[startRef]!;
          if (out != 'palace' && out != 'deity') {
            errors.add(SchoolValidationError(
              schoolId: schoolId,
              fieldPath: 'rules.$id.startRef',
              message: 'type mismatch: expected palace or deity, got $out for rule $startRef',
            ));
          }
          adj[id]?.add(startRef);
        }
      }
    } else if (kind == 'deriveCount') {
      addRef(id, r['countRef'], 'scalar', 'countRef');
    } else if (kind == 'relative') {
      final baseRef = r['baseRef'] as String?;
      if (baseRef != null && ruleOutputs.containsKey(baseRef)) {
        final out = ruleOutputs[baseRef]!;
        if (out != 'palace' && out != 'deity') {
          errors.add(SchoolValidationError(
            schoolId: schoolId,
            fieldPath: 'rules.$id.baseRef',
            message: 'type mismatch: expected palace or deity, got $out for rule $baseRef',
          ));
        }
      }
    } else if (kind == 'predicate') {
      final when = r['when'];
      if (when is Map && when['args'] is List) {
        for (final arg in when['args']) {
          // Predicate inputs can be any type
          if (arg is String && ruleOutputs.containsKey(arg)) {
            adj[id]?.add(arg);
          }
        }
      }
    }

    // Also parse AST tree vars to see if they reference other rules
    _collectASTVars(r['tree'], id, ruleOutputs, adj);
    _collectASTVars(r['steps']?['tree'], id, ruleOutputs, adj);
    _collectASTVars(r['indexTree']?['tree'], id, ruleOutputs, adj);
    _collectASTVars(r['minorTree']?['tree'], id, ruleOutputs, adj);
  }

  // Validation of school-level references
  void checkSchoolRef(dynamic ref, String expectedType, String fieldPath) {
    if (ref == null) return;
    if (ref is! String) {
      errors.add(SchoolValidationError(
        schoolId: schoolId,
        fieldPath: fieldPath,
        message: 'ref must be a string',
      ));
      return;
    }
    if (!ruleOutputs.containsKey(ref)) {
      errors.add(SchoolValidationError(
        schoolId: schoolId,
        fieldPath: fieldPath,
        message: 'referenced rule not found: $ref',
      ));
      return;
    }
    final actualType = ruleOutputs[ref]!;
    if (actualType != expectedType && !(expectedType == 'palace' && actualType == 'deity')) {
      errors.add(SchoolValidationError(
        schoolId: schoolId,
        fieldPath: fieldPath,
        message: 'type mismatch: expected $expectedType, got $actualType for rule $ref',
      ));
    }
  }

  final charts = json['charts'];
  if (charts is Map) {
    for (final key in ['year', 'month', 'day', 'hour']) {
      final config = charts[key];
      if (config is Map) {
        checkSchoolRef(config['ruJuRef'], 'scalar', 'charts.$key.ruJuRef');
      }
    }
  }

  final foundation = json['foundation'];
  if (foundation is Map) {
    checkSchoolRef(foundation['taiYiRef'], 'palace', 'foundation.taiYiRef');
    // wenChang stays can be deity or palace
    final wc = foundation['wenChangRef'];
    if (wc is String) {
      final out = ruleOutputs[wc];
      if (out != 'palace' && out != 'deity') {
        errors.add(SchoolValidationError(
          schoolId: schoolId,
          fieldPath: 'foundation.wenChangRef',
          message: 'type mismatch: expected palace or deity, got $out for rule $wc',
        ));
      }
    }
    checkSchoolRef(foundation['jiShenRef'], 'deity', 'foundation.jiShenRef');
    checkSchoolRef(foundation['shiJiRef'], 'deity', 'foundation.shiJiRef');
  }

  final threeCalc = json['threeCalc'];
  if (threeCalc is Map) {
    checkSchoolRef(threeCalc['hostRef'], 'scalar', 'threeCalc.hostRef');
    checkSchoolRef(threeCalc['guestRef'], 'scalar', 'threeCalc.guestRef');
    checkSchoolRef(threeCalc['dingRef'], 'scalar', 'threeCalc.dingRef');
  }

  final generals = json['generals'];
  if (generals is Map) {
    checkSchoolRef(generals['hostMajorRef'], 'palace', 'generals.hostMajorRef');
    checkSchoolRef(generals['hostMinorRef'], 'palace', 'generals.hostMinorRef');
    checkSchoolRef(generals['guestMajorRef'], 'palace', 'generals.guestMajorRef');
    checkSchoolRef(generals['guestMinorRef'], 'palace', 'generals.guestMinorRef');
    if (generals['dingMajorRef'] != null) {
      checkSchoolRef(generals['dingMajorRef'], 'palace', 'generals.dingMajorRef');
    }
    if (generals['dingMinorRef'] != null) {
      checkSchoolRef(generals['dingMinorRef'], 'palace', 'generals.dingMinorRef');
    }
  }

  final deities = json['deities'];
  if (deities is List) {
    for (int i = 0; i < deities.length; i++) {
      final d = deities[i];
      if (d is Map) {
        // Deity rules must produce deity or palace
        final ref = d['ruleRef'];
        if (ref is String) {
          final out = ruleOutputs[ref];
          if (out != 'palace' && out != 'deity') {
            errors.add(SchoolValidationError(
              schoolId: schoolId,
              fieldPath: 'deities[$i].ruleRef',
              message: 'type mismatch: expected deity or palace, got $out for deity rule $ref',
            ));
          }
        }
      }
    }
  }

  final geJu = json['geJu'];
  if (geJu is List) {
    for (int i = 0; i < geJu.length; i++) {
      final g = geJu[i];
      if (g is Map) {
        checkSchoolRef(g['ruleRef'], 'predicate', 'geJu[$i].ruleRef');
      }
    }
  }

  // DAG Check using Kahn's algorithm or DFS detection
  final visited = <String, int>{}; // 0 = unvisited, 1 = visiting, 2 = visited
  bool hasCycle(String node) {
    visited[node] = 1;
    for (final neighbor in adj[node] ?? []) {
      if (visited[neighbor] == 1) return true;
      if (visited[neighbor] == null || visited[neighbor] == 0) {
        if (hasCycle(neighbor)) return true;
      }
    }
    visited[node] = 2;
    return false;
  }

  for (final node in adj.keys) {
    if (visited[node] == null || visited[node] == 0) {
      if (hasCycle(node)) {
        errors.add(SchoolValidationError(
          schoolId: schoolId,
          fieldPath: 'rules',
          message: 'rules dependency graph contains a cycle',
        ));
        break;
      }
    }
  }
}

void _collectASTVars(dynamic node, String fromId, Map<String, String> ruleOutputs, Map<String, List<String>> adj) {
  if (node is! Map) return;
  if (node.containsKey('var')) {
    final v = node['var'];
    if (v is String && ruleOutputs.containsKey(v)) {
      adj[fromId]?.add(v);
    }
  } else if (node.containsKey('floor')) {
    _collectASTVars(node['floor'], fromId, ruleOutputs, adj);
  } else if (node.containsKey('op')) {
    _collectASTVars(node['a'], fromId, ruleOutputs, adj);
    _collectASTVars(node['b'], fromId, ruleOutputs, adj);
  }
}
