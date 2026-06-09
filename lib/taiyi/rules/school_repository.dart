import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'school_document.dart';

class SchoolRepository {
  final Map<String, SchoolDocument> _userSchools = {};
  final Map<String, SchoolDocument> _cache = {};
  
  // Custom asset loader for tests or mock bundles
  final Future<String> Function(String path)? assetLoader;
  
  SchoolRepository({this.assetLoader});

  static SchoolDocument? loadOfficialSchoolSync(String id) {
    final Map<String, String> officialJsonStrings = {
      'jingMirror': _kJingMirrorJson,
      'jing_mirror': _kJingMirrorJson,
      'tongZong': _kTongZongJson,
      'tong_zong': _kTongZongJson,
      'tao_jin_ge': _kTaoJinGeJson,
      'fu_ying': _kFuYingJson,
      'jiCheng': _kJiChengJson,
      'ji_cheng': _kJiChengJson
    };
    final jsonStr = officialJsonStrings[id];
    if (jsonStr == null) return null;
    try {
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      return SchoolDocument.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  Future<SchoolDocument?> loadSchool(String id) async {
    // Check cache first
    if (_cache.containsKey(id)) {
      return _cache[id];
    }
    if (_userSchools.containsKey(id)) {
      return _userSchools[id];
    }
    
    // Try synchronous loader first
    final syncSchool = loadOfficialSchoolSync(id);
    if (syncSchool != null) {
      _cache[id] = syncSchool;
      return syncSchool;
    }

    // Fallback to loading from assets
    final officialNames = {
      'jingMirror': 'jing_mirror.json',
      'jing_mirror': 'jing_mirror.json',
      'tongZong': 'tong_zong.json',
      'tong_zong': 'tong_zong.json',
      'tao_jin_ge': 'tao_jin_ge.json',
      'fu_ying': 'fu_ying.json',
      'jiCheng': 'ji_cheng.json',
      'ji_cheng': 'ji_cheng.json'
    };
    
    final filename = officialNames[id];
    if (filename != null) {
      try {
        final path = 'assets/schools/$filename';
        String content;
        if (assetLoader != null) {
          content = await assetLoader!(path);
        } else {
          content = await rootBundle.loadString(path);
        }
        final json = jsonDecode(content) as Map<String, dynamic>;
        final errors = validateSchoolJson(json);
        if (errors.isNotEmpty) {
          throw FormatException('Official school validation failed: $errors');
        }
        final doc = SchoolDocument.fromJson(json);
        _cache[id] = doc;
        return doc;
      } catch (_) {
        final hyphenatedFilename = filename.replaceAll('_', '-');
        try {
          final path = 'assets/schools/$hyphenatedFilename';
          String content;
          if (assetLoader != null) {
            content = await assetLoader!(path);
          } else {
            content = await rootBundle.loadString(path);
          }
          final json = jsonDecode(content) as Map<String, dynamic>;
          final errors = validateSchoolJson(json);
          if (errors.isNotEmpty) {
            throw FormatException('Official school validation failed: $errors');
          }
          final doc = SchoolDocument.fromJson(json);
          _cache[id] = doc;
          return doc;
        } catch (_) {
          // Ignore
        }
      }
    }
    return null;
  }

  Future<List<SchoolDocument>> loadAllSchools() async {
    final List<SchoolDocument> all = [];
    final officialIds = ['jing_mirror', 'tong_zong', 'tao_jin_ge', 'fu_ying', 'ji_cheng'];
    for (final id in officialIds) {
      final s = await loadSchool(id);
      if (s != null) {
        all.add(s);
      }
    }
    all.addAll(_userSchools.values);
    return all;
  }

  Future<void> saveSchool(SchoolDocument school) async {
    if (school.meta.owner == 'official') {
      throw UnsupportedError('Cannot modify official school document');
    }
    
    final errors = validateSchoolJson(school.toJson());
    if (errors.isNotEmpty) {
      throw ArgumentError('School document validation failed: $errors');
    }
    
    _userSchools[school.meta.id] = school;
    _cache[school.meta.id] = school;
  }

  Future<void> deleteSchool(String id) async {
    final officialIds = {'jingMirror', 'jing_mirror', 'tongZong', 'tong_zong', 'tao_jin_ge', 'fu_ying', 'jiCheng', 'ji_cheng'};
    if (officialIds.contains(id)) {
      throw UnsupportedError('Cannot delete official school document');
    }
    _userSchools.remove(id);
    _cache.remove(id);
  }
  
  void clearCache() {
    _cache.clear();
    _userSchools.clear();
  }
}

const String _kJingMirrorJson = r'''{
  "schemaVersion": 1,
  "meta": {
    "id": "jing_mirror",
    "name": "金镜派",
    "version": 1,
    "source": "太乙金镜式经",
    "owner": "official"
  },
  "palace": "taiyi9",
  "rules": [
    {
      "id": "accumulation.year",
      "kind": "scalar",
      "output": "scalar",
      "tree": {
        "op": "+",
        "a": {
          "int": 1937281
        },
        "b": {
          "op": "-",
          "a": {
            "var": "Y"
          },
          "b": {
            "int": 724
          }
        }
      }
    },
    {
      "id": "ruJu.year",
      "kind": "scalar",
      "output": "scalar",
      "tree": {
        "op": "%",
        "a": {
          "var": "accumulation.year"
        },
        "b": {
          "int": 360
        }
      },
      "zeroAsCycle": 360
    },
    {
      "id": "ju.year",
      "kind": "scalar",
      "output": "scalar",
      "tree": {
        "op": "%",
        "a": {
          "var": "ruJu.year"
        },
        "b": {
          "int": 72
        }
      },
      "zeroAsCycle": 72
    },
    {
      "id": "foundation.taiYi",
      "kind": "table",
      "output": "palace",
      "table": [1, 2, 3, 4, 6, 7, 8, 9],
      "indexTree": {
        "op": "+",
        "a": {
          "op": "%",
          "a": {
            "op": "~/",
            "a": {
              "op": "-",
              "a": {
                "var": "ju.year"
              },
              "b": {
                "int": 1
              }
            },
            "b": {
              "int": 3
            }
          },
          "b": {
            "int": 8
          }
        },
        "b": {
          "int": 1
        }
      }
    },
    {
      "id": "foundation.wenChang",
      "kind": "walk",
      "output": "deity",
      "palaceSystem": "sixteenGods",
      "start": "武德",
      "direction": "forward",
      "steps": {
        "op": "%",
        "a": {
          "op": "-",
          "a": {
            "var": "ju.year"
          },
          "b": {
            "int": 1
          }
        },
        "b": {
          "int": 18
        }
      },
      "restAt": {
        "values": ["阴德", "大武", "乾", "坤"],
        "source": "5_in_one_classes_alg.md §4.1"
      }
    },
    {
      "id": "foundation.jiShen",
      "kind": "walk",
      "output": "deity",
      "palaceSystem": "twelveBranch",
      "start": {
        "yang": "寅",
        "yin": "申"
      },
      "direction": "reverse",
      "steps": {
        "op": "%",
        "a": {
          "op": "-",
          "a": {
            "op": "%",
            "a": {
              "var": "ruJu.year"
            },
            "b": {
              "int": 12
            }
          },
          "b": {
            "int": 1
          }
        },
        "b": {
          "int": 12
        }
      }
    },
    {
      "id": "foundation.shiJi",
      "kind": "shiJi",
      "output": "deity",
      "wenChangRef": "foundation.wenChang",
      "jiShenRef": "foundation.jiShen"
    },
    {
      "id": "calc.host",
      "kind": "walkSum",
      "output": "scalar",
      "palaceSystem": "sixteenGods",
      "rawSum": true,
      "chartType": "year",
      "startRef": "foundation.wenChang"
    },
    {
      "id": "calc.guest",
      "kind": "walkSum",
      "output": "scalar",
      "palaceSystem": "sixteenGods",
      "rawSum": true,
      "chartType": "year",
      "startRef": "foundation.shiJi"
    },
    {
      "id": "foundation.dingStart",
      "kind": "dingMu",
      "output": "deity",
      "wenChangRef": "foundation.wenChang"
    },
    {
      "id": "calc.ding",
      "kind": "walkSum",
      "output": "scalar",
      "palaceSystem": "sixteenGods",
      "rawSum": true,
      "chartType": "year",
      "startRef": "foundation.dingStart"
    },
    {
      "id": "general.hostMajor",
      "kind": "deriveCount",
      "output": "palace",
      "countRef": "calc.host",
      "daMap": {
        "1": "乾",
        "2": "离",
        "3": "艮",
        "4": "震",
        "6": "兑",
        "7": "坤",
        "8": "坎",
        "9": "巽",
        "10": "巽"
      }
    },
    {
      "id": "general.hostMinor",
      "kind": "deriveCount",
      "output": "palace",
      "countRef": "calc.host",
      "daMap": {
        "1": "乾",
        "2": "离",
        "3": "艮",
        "4": "震",
        "6": "兑",
        "7": "坤",
        "8": "坎",
        "9": "巽",
        "10": "巽"
      },
      "minorTree": {
        "op": "%",
        "a": {
          "op": "*",
          "a": {
            "var": "general.hostMajor"
          },
          "b": {
            "int": 3
          }
        },
        "b": {
          "int": 10
        }
      }
    },
    {
      "id": "general.guestMajor",
      "kind": "deriveCount",
      "output": "palace",
      "countRef": "calc.guest",
      "daMap": {
        "1": "乾",
        "2": "离",
        "3": "艮",
        "4": "震",
        "6": "兑",
        "7": "坤",
        "8": "坎",
        "9": "巽",
        "10": "巽"
      }
    },
    {
      "id": "general.guestMinor",
      "kind": "deriveCount",
      "output": "palace",
      "countRef": "calc.guest",
      "daMap": {
        "1": "乾",
        "2": "离",
        "3": "艮",
        "4": "震",
        "6": "兑",
        "7": "坤",
        "8": "坎",
        "9": "巽",
        "10": "巽"
      },
      "minorTree": {
        "op": "%",
        "a": {
          "op": "*",
          "a": {
            "var": "general.guestMajor"
          },
          "b": {
            "int": 3
          }
        },
        "b": {
          "int": 10
        }
      }
    },
    {
      "id": "general.dingMajor",
      "kind": "deriveCount",
      "output": "palace",
      "countRef": "calc.ding",
      "daMap": {
        "1": "乾",
        "2": "离",
        "3": "艮",
        "4": "震",
        "6": "兑",
        "7": "坤",
        "8": "坎",
        "9": "巽",
        "10": "巽"
      }
    },
    {
      "id": "general.dingMinor",
      "kind": "deriveCount",
      "output": "palace",
      "countRef": "calc.ding",
      "daMap": {
        "1": "乾",
        "2": "离",
        "3": "艮",
        "4": "震",
        "6": "兑",
        "7": "坤",
        "8": "坎",
        "9": "巽",
        "10": "巽"
      },
      "minorTree": {
        "op": "%",
        "a": {
          "op": "*",
          "a": {
            "var": "general.dingMajor"
          },
          "b": {
            "int": 3
          }
        },
        "b": {
          "int": 10
        }
      }
    }
  ],
  "charts": {
    "year": {
      "enabled": true,
      "ruJuRef": "ruJu.year",
      "appliesTo": [
        "year"
      ]
    }
  },
  "dun": {
    "resolver": "metaphysicsCoreJieQi",
    "termMode": "leveling"
  },
  "foundation": {
    "taiYiRef": "foundation.taiYi",
    "wenChangRef": "foundation.wenChang",
    "jiShenRef": "foundation.jiShen",
    "shiJiRef": "foundation.shiJi"
  },
  "threeCalc": {
    "hostRef": "calc.host",
    "guestRef": "calc.guest",
    "dingRef": "calc.ding"
  },
  "generals": {
    "hostMajorRef": "general.hostMajor",
    "hostMinorRef": "general.hostMinor",
    "guestMajorRef": "general.guestMajor",
    "guestMinorRef": "general.guestMinor",
    "dingMajorRef": "general.dingMajor",
    "dingMinorRef": "general.dingMinor"
  },
  "deities": [],
  "geJu": []
}''';

const String _kTongZongJson = r'''{
  "schemaVersion": 1,
  "meta": {
    "id": "tong_zong",
    "name": "统宗派",
    "version": 1,
    "source": "太乙统宗宝鉴",
    "owner": "official"
  },
  "palace": "taiyi9",
  "rules": [
    {
      "id": "accumulation.year",
      "kind": "scalar",
      "output": "scalar",
      "tree": {
        "op": "+",
        "a": {
          "int": 10155220
        },
        "b": {
          "op": "-",
          "a": {
            "var": "Y"
          },
          "b": {
            "int": 1303
          }
        }
      }
    },
    {
      "id": "ruJu.year",
      "kind": "scalar",
      "output": "scalar",
      "tree": {
        "op": "%",
        "a": {
          "var": "accumulation.year"
        },
        "b": {
          "int": 360
        }
      },
      "zeroAsCycle": 360
    },
    {
      "id": "ju.year",
      "kind": "scalar",
      "output": "scalar",
      "tree": {
        "op": "%",
        "a": {
          "var": "ruJu.year"
        },
        "b": {
          "int": 72
        }
      },
      "zeroAsCycle": 72
    },
    {
      "id": "foundation.taiYi",
      "kind": "table",
      "output": "palace",
      "table": [1, 2, 3, 4, 6, 7, 8, 9],
      "indexTree": {
        "op": "+",
        "a": {
          "op": "%",
          "a": {
            "op": "~/",
            "a": {
              "op": "-",
              "a": {
                "var": "ju.year"
              },
              "b": {
                "int": 1
              }
            },
            "b": {
              "int": 3
            }
          },
          "b": {
            "int": 8
          }
        },
        "b": {
          "int": 1
        }
      }
    },
    {
      "id": "foundation.wenChang",
      "kind": "walk",
      "output": "deity",
      "palaceSystem": "sixteenGods",
      "start": {
        "yang": "武德",
        "yin": "吕申"
      },
      "direction": "forward",
      "steps": {
        "op": "%",
        "a": {
          "op": "-",
          "a": {
            "var": "ju.year"
          },
          "b": {
            "int": 1
          }
        },
        "b": {
          "int": 18
        }
      },
      "restAt": {
        "values": ["阴德", "大武", "乾", "坤"],
        "source": "5_in_one_classes_alg.md §4.1"
      }
    },
    {
      "id": "foundation.jiShen",
      "kind": "walk",
      "output": "deity",
      "palaceSystem": "twelveBranch",
      "start": {
        "yang": "寅",
        "yin": "申"
      },
      "direction": "reverse",
      "steps": {
        "op": "%",
        "a": {
          "op": "-",
          "a": {
            "op": "%",
            "a": {
              "var": "ruJu.year"
            },
            "b": {
              "int": 12
            }
          },
          "b": {
            "int": 1
          }
        },
        "b": {
          "int": 12
        }
      }
    },
    {
      "id": "foundation.shiJi",
      "kind": "shiJi",
      "output": "deity",
      "wenChangRef": "foundation.wenChang",
      "jiShenRef": "foundation.jiShen"
    },
    {
      "id": "calc.host",
      "kind": "walkSum",
      "output": "scalar",
      "palaceSystem": "sixteenGods",
      "rawSum": true,
      "chartType": "year",
      "startRef": "foundation.wenChang"
    },
    {
      "id": "calc.guest",
      "kind": "walkSum",
      "output": "scalar",
      "palaceSystem": "sixteenGods",
      "rawSum": true,
      "chartType": "year",
      "startRef": "foundation.shiJi"
    },
    {
      "id": "foundation.dingStart",
      "kind": "dingMu",
      "output": "deity",
      "wenChangRef": "foundation.wenChang"
    },
    {
      "id": "calc.ding",
      "kind": "walkSum",
      "output": "scalar",
      "palaceSystem": "sixteenGods",
      "rawSum": true,
      "chartType": "year",
      "startRef": "foundation.dingStart"
    },
    {
      "id": "general.hostMajor",
      "kind": "deriveCount",
      "output": "palace",
      "countRef": "calc.host",
      "daMap": {
        "1": "乾",
        "2": "离",
        "3": "艮",
        "4": "震",
        "6": "兑",
        "7": "坤",
        "8": "坎",
        "9": "巽",
        "10": "巽"
      }
    },
    {
      "id": "general.hostMinor",
      "kind": "deriveCount",
      "output": "palace",
      "countRef": "calc.host",
      "daMap": {
        "1": "乾",
        "2": "离",
        "3": "艮",
        "4": "震",
        "6": "兑",
        "7": "坤",
        "8": "坎",
        "9": "巽",
        "10": "巽"
      },
      "minorTree": {
        "op": "%",
        "a": {
          "op": "*",
          "a": {
            "var": "general.hostMajor"
          },
          "b": {
            "int": 3
          }
        },
        "b": {
          "int": 10
        }
      }
    },
    {
      "id": "general.guestMajor",
      "kind": "deriveCount",
      "output": "palace",
      "countRef": "calc.guest",
      "daMap": {
        "1": "乾",
        "2": "离",
        "3": "艮",
        "4": "震",
        "6": "兑",
        "7": "坤",
        "8": "坎",
        "9": "巽",
        "10": "巽"
      }
    },
    {
      "id": "general.guestMinor",
      "kind": "deriveCount",
      "output": "palace",
      "countRef": "calc.guest",
      "daMap": {
        "1": "乾",
        "2": "离",
        "3": "艮",
        "4": "震",
        "6": "兑",
        "7": "坤",
        "8": "坎",
        "9": "巽",
        "10": "巽"
      },
      "minorTree": {
        "op": "%",
        "a": {
          "op": "*",
          "a": {
            "var": "general.guestMajor"
          },
          "b": {
            "int": 3
          }
        },
        "b": {
          "int": 10
        }
      }
    },
    {
      "id": "general.dingMajor",
      "kind": "deriveCount",
      "output": "palace",
      "countRef": "calc.ding",
      "daMap": {
        "1": "乾",
        "2": "离",
        "3": "艮",
        "4": "震",
        "6": "兑",
        "7": "坤",
        "8": "坎",
        "9": "巽",
        "10": "巽"
      }
    },
    {
      "id": "general.dingMinor",
      "kind": "deriveCount",
      "output": "palace",
      "countRef": "calc.ding",
      "daMap": {
        "1": "乾",
        "2": "离",
        "3": "艮",
        "4": "震",
        "6": "兑",
        "7": "坤",
        "8": "坎",
        "9": "巽",
        "10": "巽"
      },
      "minorTree": {
        "op": "%",
        "a": {
          "op": "*",
          "a": {
            "var": "general.dingMajor"
          },
          "b": {
            "int": 3
          }
        },
        "b": {
          "int": 10
        }
      }
    }
  ],
  "charts": {
    "year": {
      "enabled": true,
      "ruJuRef": "ruJu.year",
      "appliesTo": [
        "year"
      ]
    }
  },
  "dun": {
    "resolver": "metaphysicsCoreJieQi",
    "termMode": "leveling"
  },
  "foundation": {
    "taiYiRef": "foundation.taiYi",
    "wenChangRef": "foundation.wenChang",
    "jiShenRef": "foundation.jiShen",
    "shiJiRef": "foundation.shiJi"
  },
  "threeCalc": {
    "hostRef": "calc.host",
    "guestRef": "calc.guest",
    "dingRef": "calc.ding"
  },
  "generals": {
    "hostMajorRef": "general.hostMajor",
    "hostMinorRef": "general.hostMinor",
    "guestMajorRef": "general.guestMajor",
    "guestMinorRef": "general.guestMinor",
    "dingMajorRef": "general.dingMajor",
    "dingMinorRef": "general.dingMinor"
  },
  "deities": [],
  "geJu": []
}''';

const String _kTaoJinGeJson = r'''{
  "schemaVersion": 1,
  "meta": {
    "id": "tao_jin_ge",
    "name": "淘金歌派",
    "version": 1,
    "source": "太乙淘金歌",
    "owner": "official"
  },
  "palace": "taiyi9",
  "rules": [
    {
      "id": "accumulation.year",
      "kind": "scalar",
      "output": "scalar",
      "tree": {
        "op": "+",
        "a": {
          "var": "Y"
        },
        "b": {
          "int": 2697
        }
      }
    },
    {
      "id": "ruJu.year",
      "kind": "scalar",
      "output": "scalar",
      "tree": {
        "op": "%",
        "a": {
          "var": "accumulation.year"
        },
        "b": {
          "int": 360
        }
      },
      "zeroAsCycle": 360
    },
    {
      "id": "ju.year",
      "kind": "scalar",
      "output": "scalar",
      "tree": {
        "op": "%",
        "a": {
          "var": "ruJu.year"
        },
        "b": {
          "int": 72
        }
      },
      "zeroAsCycle": 72
    },
    {
      "id": "foundation.taiYi",
      "kind": "table",
      "output": "palace",
      "table": [1, 2, 3, 4, 6, 7, 8, 9],
      "indexTree": {
        "op": "+",
        "a": {
          "op": "%",
          "a": {
            "op": "~/",
            "a": {
              "op": "-",
              "a": {
                "var": "ju.year"
              },
              "b": {
                "int": 1
              }
            },
            "b": {
              "int": 3
            }
          },
          "b": {
            "int": 8
          }
        },
        "b": {
          "int": 1
        }
      }
    },
    {
      "id": "foundation.wenChang",
      "kind": "walk",
      "output": "deity",
      "palaceSystem": "twelveBranch",
      "start": "申",
      "direction": "forward",
      "steps": {
        "op": "%",
        "a": {
          "var": "ruJu.year"
        },
        "b": {
          "int": 18
        }
      }
    },
    {
      "id": "foundation.jiShen",
      "kind": "walk",
      "output": "deity",
      "palaceSystem": "twelveBranch",
      "start": "寅",
      "direction": "reverse",
      "steps": {
        "op": "%",
        "a": {
          "var": "ruJu.year"
        },
        "b": {
          "int": 12
        }
      }
    },
    {
      "id": "foundation.shiJi",
      "kind": "relative",
      "output": "deity",
      "baseRef": "foundation.jiShen",
      "mode": "opposition",
      "palaceSystem": "twelveBranch"
    },
    {
      "id": "calc.host",
      "kind": "walkSum",
      "output": "scalar",
      "startRef": "foundation.wenChang",
      "endpoint": {
        "yang": "taiYiPrev",
        "yin": "taiYiPrev"
      },
      "normalize": "满十去十",
      "wuSuan": {
        "samePalace": 0,
        "oneStep": 0,
        "sameEnd": 0
      }
    },
    {
      "id": "calc.guest",
      "kind": "walkSum",
      "output": "scalar",
      "startRef": "foundation.shiJi",
      "endpoint": {
        "yang": "taiYiPrev",
        "yin": "taiYiPrev"
      },
      "normalize": "满十去十",
      "wuSuan": {
        "samePalace": 0,
        "oneStep": 0,
        "sameEnd": 0
      }
    },
    {
      "id": "general.hostMajor",
      "kind": "deriveCount",
      "output": "palace",
      "countRef": "calc.host",
      "daMap": {
        "1": "乾",
        "2": "离",
        "3": "艮",
        "4": "震",
        "6": "兑",
        "7": "坤",
        "8": "坎",
        "9": "巽",
        "10": "巽"
      }
    },
    {
      "id": "general.hostMinor",
      "kind": "deriveCount",
      "output": "palace",
      "countRef": "calc.host",
      "daMap": {
        "1": "乾",
        "2": "离",
        "3": "艮",
        "4": "震",
        "6": "兑",
        "7": "坤",
        "8": "坎",
        "9": "巽",
        "10": "巽"
      },
      "minorTree": {
        "op": "%",
        "a": {
          "op": "*",
          "a": {
            "var": "general.hostMajor"
          },
          "b": {
            "int": 3
          }
        },
        "b": {
          "int": 10
        }
      }
    },
    {
      "id": "general.guestMajor",
      "kind": "deriveCount",
      "output": "palace",
      "countRef": "calc.guest",
      "daMap": {
        "1": "乾",
        "2": "离",
        "3": "艮",
        "4": "震",
        "6": "兑",
        "7": "坤",
        "8": "坎",
        "9": "巽",
        "10": "巽"
      }
    },
    {
      "id": "general.guestMinor",
      "kind": "deriveCount",
      "output": "palace",
      "countRef": "calc.guest",
      "daMap": {
        "1": "乾",
        "2": "离",
        "3": "艮",
        "4": "震",
        "6": "兑",
        "7": "坤",
        "8": "坎",
        "9": "巽",
        "10": "巽"
      },
      "minorTree": {
        "op": "%",
        "a": {
          "op": "*",
          "a": {
            "var": "general.guestMajor"
          },
          "b": {
            "int": 3
          }
        },
        "b": {
          "int": 10
        }
      }
    }
  ],
  "charts": {
    "year": {
      "enabled": true,
      "ruJuRef": "ruJu.year",
      "appliesTo": [
        "year"
      ]
    }
  },
  "dun": {
    "resolver": "metaphysicsCoreJieQi",
    "termMode": "leveling"
  },
  "foundation": {
    "taiYiRef": "foundation.taiYi",
    "wenChangRef": "foundation.wenChang",
    "jiShenRef": "foundation.jiShen",
    "shiJiRef": "foundation.shiJi"
  },
  "threeCalc": {
    "hostRef": "calc.host",
    "guestRef": "calc.guest",
    "dingRef": "calc.host"
  },
  "generals": {
    "hostMajorRef": "general.hostMajor",
    "hostMinorRef": "general.hostMinor",
    "guestMajorRef": "general.guestMajor",
    "guestMinorRef": "general.guestMinor"
  },
  "deities": [],
  "geJu": []
}''';

const String _kFuYingJson = r'''{
  "schemaVersion": 1,
  "meta": {
    "id": "fu_ying",
    "name": "福应经派",
    "version": 1,
    "source": "景祐太乙福应经",
    "owner": "official"
  },
  "palace": "taiyi9",
  "rules": [
    {
      "id": "accumulation.year",
      "kind": "scalar",
      "output": "scalar",
      "tree": {
        "op": "+",
        "a": {
          "int": 10153917
        },
        "b": {
          "op": "-",
          "a": {
            "var": "Y"
          },
          "b": {
            "int": 742
          }
        }
      }
    },
    {
      "id": "ruJu.year",
      "kind": "scalar",
      "output": "scalar",
      "tree": {
        "op": "%",
        "a": {
          "var": "accumulation.year"
        },
        "b": {
          "int": 360
        }
      },
      "zeroAsCycle": 360
    },
    {
      "id": "ju.year",
      "kind": "scalar",
      "output": "scalar",
      "tree": {
        "op": "%",
        "a": {
          "var": "ruJu.year"
        },
        "b": {
          "int": 72
        }
      },
      "zeroAsCycle": 72
    },
    {
      "id": "foundation.taiYi",
      "kind": "table",
      "output": "palace",
      "table": [1, 2, 3, 4, 6, 7, 8, 9],
      "indexTree": {
        "op": "+",
        "a": {
          "op": "%",
          "a": {
            "op": "~/",
            "a": {
              "op": "-",
              "a": {
                "var": "ju.year"
              },
              "b": {
                "int": 1
              }
            },
            "b": {
              "int": 3
            }
          },
          "b": {
            "int": 8
          }
        },
        "b": {
          "int": 1
        }
      }
    },
    {
      "id": "foundation.wenChang",
      "kind": "walk",
      "output": "deity",
      "palaceSystem": "sixteenGods",
      "start": "武德",
      "direction": "forward",
      "steps": {
        "op": "%",
        "a": {
          "var": "ruJu.year"
        },
        "b": {
          "int": 18
        }
      },
      "restAt": {
        "values": ["阴德", "大武", "乾", "坤"],
        "source": "5_in_one_classes_alg.md §4.1"
      }
    },
    {
      "id": "foundation.jiShen",
      "kind": "walk",
      "output": "deity",
      "palaceSystem": "twelveBranch",
      "start": {
        "yang": "寅",
        "yin": "申"
      },
      "direction": "reverse",
      "steps": {
        "op": "%",
        "a": {
          "op": "-",
          "a": {
            "op": "%",
            "a": {
              "var": "ruJu.year"
            },
            "b": {
              "int": 12
            }
          },
          "b": {
            "int": 1
          }
        },
        "b": {
          "int": 12
        }
      }
    },
    {
      "id": "foundation.shiJi",
      "kind": "shiJi",
      "output": "deity",
      "wenChangRef": "foundation.wenChang",
      "jiShenRef": "foundation.jiShen"
    },
    {
      "id": "calc.host",
      "kind": "walkSum",
      "output": "scalar",
      "palaceSystem": "sixteenGods",
      "rawSum": true,
      "chartType": "year",
      "startRef": "foundation.wenChang"
    },
    {
      "id": "calc.guest",
      "kind": "walkSum",
      "output": "scalar",
      "palaceSystem": "sixteenGods",
      "rawSum": true,
      "chartType": "year",
      "startRef": "foundation.shiJi"
    },
    {
      "id": "general.hostMajor",
      "kind": "deriveCount",
      "output": "palace",
      "countRef": "calc.host",
      "daMap": {
        "1": "乾",
        "2": "离",
        "3": "艮",
        "4": "震",
        "6": "兑",
        "7": "坤",
        "8": "坎",
        "9": "巽",
        "10": "巽"
      }
    },
    {
      "id": "foundation.dingStart",
      "kind": "relative",
      "output": "palace",
      "baseRef": "general.hostMajor",
      "mode": "offset",
      "offset": 1,
      "palaceSystem": "eight8"
    },
    {
      "id": "calc.ding",
      "kind": "walkSum",
      "output": "scalar",
      "palaceSystem": "sixteenGods",
      "rawSum": true,
      "chartType": "year",
      "startRef": "foundation.dingStart"
    },
    {
      "id": "general.hostMinor",
      "kind": "deriveCount",
      "output": "palace",
      "countRef": "calc.host",
      "daMap": {
        "1": "乾",
        "2": "离",
        "3": "艮",
        "4": "震",
        "6": "兑",
        "7": "坤",
        "8": "坎",
        "9": "巽",
        "10": "巽"
      },
      "minorTree": {
        "op": "%",
        "a": {
          "op": "*",
          "a": {
            "var": "general.hostMajor"
          },
          "b": {
            "int": 3
          }
        },
        "b": {
          "int": 10
        }
      }
    },
    {
      "id": "general.guestMajor",
      "kind": "deriveCount",
      "output": "palace",
      "countRef": "calc.guest",
      "daMap": {
        "1": "乾",
        "2": "离",
        "3": "艮",
        "4": "震",
        "6": "兑",
        "7": "坤",
        "8": "坎",
        "9": "巽",
        "10": "巽"
      }
    },
    {
      "id": "general.guestMinor",
      "kind": "deriveCount",
      "output": "palace",
      "countRef": "calc.guest",
      "daMap": {
        "1": "乾",
        "2": "离",
        "3": "艮",
        "4": "震",
        "6": "兑",
        "7": "坤",
        "8": "坎",
        "9": "巽",
        "10": "巽"
      },
      "minorTree": {
        "op": "%",
        "a": {
          "op": "*",
          "a": {
            "var": "general.guestMajor"
          },
          "b": {
            "int": 3
          }
        },
        "b": {
          "int": 10
        }
      }
    },
    {
      "id": "general.dingMajor",
      "kind": "deriveCount",
      "output": "palace",
      "countRef": "calc.ding",
      "daMap": {
        "1": "乾",
        "2": "离",
        "3": "艮",
        "4": "震",
        "6": "兑",
        "7": "坤",
        "8": "坎",
        "9": "巽",
        "10": "巽"
      }
    },
    {
      "id": "general.dingMinor",
      "kind": "deriveCount",
      "output": "palace",
      "countRef": "calc.ding",
      "daMap": {
        "1": "乾",
        "2": "离",
        "3": "艮",
        "4": "震",
        "6": "兑",
        "7": "坤",
        "8": "坎",
        "9": "巽",
        "10": "巽"
      },
      "minorTree": {
        "op": "%",
        "a": {
          "op": "*",
          "a": {
            "var": "general.dingMajor"
          },
          "b": {
            "int": 3
          }
        },
        "b": {
          "int": 10
        }
      }
    }
  ],
  "charts": {
    "year": {
      "enabled": true,
      "ruJuRef": "ruJu.year",
      "appliesTo": [
        "year"
      ]
    }
  },
  "dun": {
    "resolver": "metaphysicsCoreJieQi",
    "termMode": "stabilizing",
    "calibration": "winterReset"
  },
  "foundation": {
    "taiYiRef": "foundation.taiYi",
    "wenChangRef": "foundation.wenChang",
    "jiShenRef": "foundation.jiShen",
    "shiJiRef": "foundation.shiJi"
  },
  "threeCalc": {
    "hostRef": "calc.host",
    "guestRef": "calc.guest",
    "dingRef": "calc.ding"
  },
  "generals": {
    "hostMajorRef": "general.hostMajor",
    "hostMinorRef": "general.hostMinor",
    "guestMajorRef": "general.guestMajor",
    "guestMinorRef": "general.guestMinor",
    "dingMajorRef": "general.dingMajor",
    "dingMinorRef": "general.dingMinor"
  },
  "deities": [],
  "geJu": []
}''';

const String _kJiChengJson = r'''{
  "schemaVersion": 1,
  "meta": {
    "id": "jiCheng",
    "name": "集成派",
    "version": 1,
    "source": "近代集成",
    "owner": "official"
  },
  "palace": "taiyi9",
  "rules": [
    {
      "id": "accumulation.year",
      "kind": "scalar",
      "output": "scalar",
      "tree": {
        "op": "-",
        "a": {
          "var": "Y"
        },
        "b": {
          "int": 1683
        }
      }
    },
    {
      "id": "ruJu.year",
      "kind": "scalar",
      "output": "scalar",
      "tree": {
        "op": "%",
        "a": {
          "var": "accumulation.year"
        },
        "b": {
          "int": 360
        }
      },
      "zeroAsCycle": 360
    },
    {
      "id": "ju.year",
      "kind": "scalar",
      "output": "scalar",
      "tree": {
        "op": "%",
        "a": {
          "var": "ruJu.year"
        },
        "b": {
          "int": 360
        }
      },
      "zeroAsCycle": 72
    },
    {
      "id": "foundation.taiYi",
      "kind": "table",
      "output": "palace",
      "table": [
        1,
        2,
        3,
        4,
        6,
        7,
        8,
        9
      ],
      "indexTree": {
        "op": "+",
        "a": {
          "op": "%",
          "a": {
            "op": "~/",
            "a": {
              "var": "ju.year"
            },
            "b": {
              "int": 3
            }
          },
          "b": {
            "int": 8
          }
        },
        "b": {
          "int": 1
        }
      }
    },
    {
      "id": "foundation.wenChang",
      "kind": "walk",
      "output": "deity",
      "palaceSystem": "sixteenGods",
      "start": {
        "yang": "武德",
        "yin": "吕申"
      },
      "direction": "forward",
      "steps": {
        "op": "%",
        "a": {
          "var": "ruJu.year"
        },
        "b": {
          "int": 18
        }
      },
      "restAt": {
        "values": [
          "阴德",
          "大武",
          "乾",
          "坤"
        ],
        "source": "5_in_one_classes_alg.md §4.1"
      }
    },
    {
      "id": "foundation.jiShen",
      "kind": "walk",
      "output": "deity",
      "palaceSystem": "twelveBranch",
      "start": {
        "yang": "寅",
        "yin": "申"
      },
      "direction": "reverse",
      "steps": {
        "op": "%",
        "a": {
          "var": "ruJu.year"
        },
        "b": {
          "int": 12
        }
      }
    },
    {
      "id": "foundation.shiJi",
      "kind": "relative",
      "output": "deity",
      "baseRef": "foundation.jiShen",
      "mode": "opposition",
      "palaceSystem": "twelveBranch"
    },
    {
      "id": "calc.host",
      "kind": "walkSum",
      "output": "scalar",
      "startRef": "foundation.wenChang",
      "endpoint": {
        "yang": "taiYiPrev",
        "yin": "taiYiPrev"
      },
      "normalize": "满十去十",
      "wuSuan": {
        "samePalace": 0,
        "oneStep": 0,
        "sameEnd": 0
      }
    },
    {
      "id": "calc.guest",
      "kind": "walkSum",
      "output": "scalar",
      "startRef": "foundation.shiJi",
      "endpoint": {
        "yang": "taiYiPrev",
        "yin": "taiYiPrev"
      },
      "normalize": "满十去十",
      "wuSuan": {
        "samePalace": 0,
        "oneStep": 0,
        "sameEnd": 0
      }
    },
    {
      "id": "foundation.dingStart",
      "kind": "relative",
      "output": "palace",
      "baseRef": "foundation.taiYi",
      "mode": "offset",
      "offset": -1,
      "palaceSystem": "eight8"
    },
    {
      "id": "calc.ding",
      "kind": "walkSum",
      "output": "scalar",
      "startRef": "foundation.dingStart",
      "endpoint": {
        "yang": "taiYiPrev",
        "yin": "taiYiPrev"
      },
      "normalize": "满十去十",
      "wuSuan": {
        "samePalace": 0,
        "oneStep": 0,
        "sameEnd": 0
      }
    },
    {
      "id": "general.hostMajor",
      "kind": "deriveCount",
      "output": "palace",
      "countRef": "calc.host",
      "daMap": {
        "1": "乾",
        "2": "离",
        "3": "艮",
        "4": "震",
        "6": "兑",
        "7": "坤",
        "8": "坎",
        "9": "巽",
        "10": "巽"
      }
    },
    {
      "id": "general.hostMinor",
      "kind": "deriveCount",
      "output": "palace",
      "countRef": "calc.host",
      "daMap": {
        "1": "乾",
        "2": "离",
        "3": "艮",
        "4": "震",
        "6": "兑",
        "7": "坤",
        "8": "坎",
        "9": "巽",
        "10": "巽"
      },
      "minorTree": {
        "op": "%",
        "a": {
          "op": "*",
          "a": {
            "var": "general.hostMajor"
          },
          "b": {
            "int": 3
          }
        },
        "b": {
          "int": 10
        }
      }
    },
    {
      "id": "general.guestMajor",
      "kind": "deriveCount",
      "output": "palace",
      "countRef": "calc.guest",
      "daMap": {
        "1": "乾",
        "2": "离",
        "3": "艮",
        "4": "震",
        "6": "兑",
        "7": "坤",
        "8": "坎",
        "9": "巽",
        "10": "巽"
      }
    },
    {
      "id": "general.guestMinor",
      "kind": "deriveCount",
      "output": "palace",
      "countRef": "calc.guest",
      "daMap": {
        "1": "乾",
        "2": "离",
        "3": "艮",
        "4": "震",
        "6": "兑",
        "7": "坤",
        "8": "坎",
        "9": "巽",
        "10": "巽"
      },
      "minorTree": {
        "op": "%",
        "a": {
          "op": "*",
          "a": {
            "var": "general.guestMajor"
          },
          "b": {
            "int": 3
          }
        },
        "b": {
          "int": 10
        }
      }
    },
    {
      "id": "general.dingMajor",
      "kind": "deriveCount",
      "output": "palace",
      "countRef": "calc.ding",
      "daMap": {
        "1": "乾",
        "2": "离",
        "3": "艮",
        "4": "震",
        "6": "兑",
        "7": "坤",
        "8": "坎",
        "9": "巽",
        "10": "巽"
      }
    },
    {
      "id": "general.dingMinor",
      "kind": "deriveCount",
      "output": "palace",
      "countRef": "calc.ding",
      "daMap": {
        "1": "乾",
        "2": "离",
        "3": "艮",
        "4": "震",
        "6": "兑",
        "7": "坤",
        "8": "坎",
        "9": "巽",
        "10": "巽"
      },
      "minorTree": {
        "op": "%",
        "a": {
          "op": "*",
          "a": {
            "var": "general.dingMajor"
          },
          "b": {
            "int": 3
          }
        },
        "b": {
          "int": 10
        }
      }
    }
  ],
  "charts": {
    "year": {
      "enabled": true,
      "ruJuRef": "ruJu.year",
      "appliesTo": [
        "year"
      ]
    }
  },
  "dun": {
    "resolver": "metaphysicsCoreJieQi",
    "termMode": "leveling"
  },
  "foundation": {
    "taiYiRef": "foundation.taiYi",
    "wenChangRef": "foundation.wenChang",
    "jiShenRef": "foundation.jiShen",
    "shiJiRef": "foundation.shiJi"
  },
  "threeCalc": {
    "hostRef": "calc.host",
    "guestRef": "calc.guest",
    "dingRef": "calc.ding"
  },
  "generals": {
    "hostMajorRef": "general.hostMajor",
    "hostMinorRef": "general.hostMinor",
    "guestMajorRef": "general.guestMajor",
    "guestMinorRef": "general.guestMinor",
    "dingMajorRef": "general.dingMajor",
    "dingMinorRef": "general.dingMinor"
  },
  "deities": [],
  "geJu": []
}''';
