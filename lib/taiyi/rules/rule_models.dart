abstract class RuleValue {
  String get type;
  Map<String, dynamic> toJson();

  factory RuleValue.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String? ?? '';
    switch (type) {
      case 'scalar':
        return ScalarRuleValue(json['value'] as int? ?? 0);
      case 'palace':
        return PalaceRuleValue(json['palace'] as String? ?? '');
      case 'deity':
        return DeityRuleValue(json['name'] as String? ?? '');
      case 'predicate':
        return PredicateRuleValue(
          json['matched'] as bool? ?? false,
          json['name'] as String? ?? '',
        );
      case 'record':
        return RecordRuleValue(Map<String, dynamic>.from(json['value'] as Map? ?? {}));
      default:
        throw ArgumentError('Unknown RuleValue type: $type');
    }
  }
}

class ScalarRuleValue implements RuleValue {
  @override
  String get type => 'scalar';
  final int value;
  ScalarRuleValue(this.value);

  @override
  Map<String, dynamic> toJson() => {'type': 'scalar', 'value': value};

  @override
  bool operator ==(Object other) => other is ScalarRuleValue && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Scalar($value)';
}

class PalaceRuleValue implements RuleValue {
  @override
  String get type => 'palace';
  final String palace;
  PalaceRuleValue(this.palace);

  @override
  Map<String, dynamic> toJson() => {'type': 'palace', 'palace': palace};

  @override
  bool operator ==(Object other) => other is PalaceRuleValue && other.palace == palace;

  @override
  int get hashCode => palace.hashCode;

  @override
  String toString() => 'Palace($palace)';
}

class DeityRuleValue implements RuleValue {
  @override
  String get type => 'deity';
  final String name;
  DeityRuleValue(this.name);

  @override
  Map<String, dynamic> toJson() => {'type': 'deity', 'name': name};

  @override
  bool operator ==(Object other) => other is DeityRuleValue && other.name == name;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => 'Deity($name)';
}

class PredicateRuleValue implements RuleValue {
  @override
  String get type => 'predicate';
  final bool matched;
  final String name;
  PredicateRuleValue(this.matched, this.name);

  @override
  Map<String, dynamic> toJson() => {'type': 'predicate', 'matched': matched, 'name': name};

  @override
  bool operator ==(Object other) =>
      other is PredicateRuleValue && other.matched == matched && other.name == name;

  @override
  int get hashCode => Object.hash(matched, name);

  @override
  String toString() => 'Predicate($matched, $name)';
}

class RecordRuleValue implements RuleValue {
  @override
  String get type => 'record';
  final Map<String, dynamic> value;
  RecordRuleValue(this.value);

  @override
  Map<String, dynamic> toJson() => {'type': 'record', 'value': value};

  @override
  bool operator ==(Object other) {
    if (other is! RecordRuleValue) return false;
    if (other.value.length != value.length) return false;
    for (final key in value.keys) {
      if (other.value[key] != value[key]) return false;
    }
    return true;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Record($value)';
}
