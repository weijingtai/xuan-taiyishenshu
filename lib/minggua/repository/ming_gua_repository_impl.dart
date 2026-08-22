import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:repository_contract_kernel/repository_contract_kernel.dart';
import 'package:repository_interface_taiyishenshu/repository_interface_taiyishenshu.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Shared [RequestContext] for minggua repo calls.
final _ctx = RequestContext(scopeUid: 'local-anonymous');

/// Unwrap a [Result] or throw the error.
T _unwrap<T>(Result<T> result) => switch (result) {
      Ok(:final value) => value,
      Err(:final error) => throw error,
    };

/// 从 assets/minggua/ 加载官方配置(只读)。
class OfficialMingGuaRepository implements MingGuaRepository {
  static const String _assetPath = 'assets/minggua';

  @override
  Future<List<MingGuaConfigContract>> loadAllConfigs() async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifest = jsonDecode(manifestContent);
    final mingguaAssets = manifest.keys
        .where((key) => key.startsWith('$_assetPath/') && key.endsWith('.json'))
        .toList();

    final configs = <MingGuaConfigContract>[];
    for (final asset in mingguaAssets) {
      final jsonStr = await rootBundle.loadString(asset);
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      configs.add(MingGuaConfigContract.fromJson(json));
    }
    return configs;
  }

  @override
  Future<MingGuaConfigContract?> loadConfig(String id) async {
    final configs = await loadAllConfigs();
    for (final c in configs) {
      if (c.id == id) return c;
    }
    return null;
  }

  @override
  Future<void> saveConfig(MingGuaConfigContract config) =>
      throw UnsupportedError('Official configs are read-only');

  @override
  Future<void> deleteConfig(String id) =>
      throw UnsupportedError('Official configs are read-only');

  // ── L0 slice methods ──

  @override
  Future<Result<MingGuaConfigContract?>> get(String id, RequestContext ctx) async =>
      Ok(await loadConfig(id));

  @override
  Future<Result<bool>> exists(String id, RequestContext ctx) async =>
      Ok(await loadConfig(id) != null);

  @override
  Future<Result<Rev>> put(
    MingGuaConfigContract entity,
    RequestContext ctx, {
    Precondition pre = const Unconditional(),
  }) async =>
      throw UnsupportedError('Official configs are read-only');

  @override
  Future<Result<Page<MingGuaConfigContract>>> query(
    Map<String, Object?> spec,
    PageRequest page,
    RequestContext ctx,
  ) async {
    final all = await loadAllConfigs();
    return Ok(Page(items: all));
  }

  @override
  Future<Result<int>> count(Map<String, Object?> spec, RequestContext ctx) async {
    final all = await loadAllConfigs();
    return Ok(all.length);
  }

  @override
  Future<Result<R>> inTransaction<R>(Future<R> Function() body) async {
    final r = await body();
    return Ok(r);
  }
}

/// 用户自定义配置存取(SharedPreferences)。
class UserMingGuaRepository implements MingGuaRepository {
  static const String _storageKey = 'user_ming_gua_configs';

  @override
  Future<List<MingGuaConfigContract>> loadAllConfigs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_storageKey);
    if (jsonStr == null) return [];
    final List<dynamic> list = jsonDecode(jsonStr);
    return list
        .map((e) => MingGuaConfigContract.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<MingGuaConfigContract?> loadConfig(String id) async {
    final configs = await loadAllConfigs();
    for (final c in configs) {
      if (c.id == id) return c;
    }
    return null;
  }

  @override
  Future<void> saveConfig(MingGuaConfigContract config) async {
    final configs = await loadAllConfigs();
    final idx = configs.indexWhere((c) => c.id == config.id);
    if (idx >= 0) {
      configs[idx] = config;
    } else {
      configs.add(config);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode(configs.map((c) => c.toJson()).toList()),
    );
  }

  @override
  Future<void> deleteConfig(String id) async {
    final configs = await loadAllConfigs();
    configs.removeWhere((c) => c.id == id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode(configs.map((c) => c.toJson()).toList()),
    );
  }

  // ── L0 slice methods ──

  @override
  Future<Result<MingGuaConfigContract?>> get(String id, RequestContext ctx) async =>
      Ok(await loadConfig(id));

  @override
  Future<Result<bool>> exists(String id, RequestContext ctx) async =>
      Ok(await loadConfig(id) != null);

  @override
  Future<Result<Rev>> put(
    MingGuaConfigContract entity,
    RequestContext ctx, {
    Precondition pre = const Unconditional(),
  }) async {
    await saveConfig(entity);
    return const Ok(Rev('rev_1'));
  }

  @override
  Future<Result<Page<MingGuaConfigContract>>> query(
    Map<String, Object?> spec,
    PageRequest page,
    RequestContext ctx,
  ) async {
    final all = await loadAllConfigs();
    return Ok(Page(items: all));
  }

  @override
  Future<Result<int>> count(Map<String, Object?> spec, RequestContext ctx) async {
    final all = await loadAllConfigs();
    return Ok(all.length);
  }

  @override
  Future<Result<R>> inTransaction<R>(Future<R> Function() body) async {
    final r = await body();
    return Ok(r);
  }
}

/// 合并官方+用户配置(用户 id 覆盖官方)。
class MergedMingGuaRepository implements MingGuaRepository {
  final OfficialMingGuaRepository official;
  final UserMingGuaRepository user;

  MergedMingGuaRepository({required this.official, required this.user});

  @override
  Future<List<MingGuaConfigContract>> loadAllConfigs() async {
    final officialConfigs = await official.loadAllConfigs();
    final userConfigs = await user.loadAllConfigs();

    final Map<String, MingGuaConfigContract> merged = {};
    for (final c in officialConfigs) {
      merged[c.id] = c;
    }
    for (final c in userConfigs) {
      merged[c.id] = c; // 用户覆盖官方
    }
    return merged.values.toList();
  }

  @override
  Future<MingGuaConfigContract?> loadConfig(String id) async {
    final userConfig = await user.loadConfig(id);
    if (userConfig != null) return userConfig;
    return official.loadConfig(id);
  }

  @override
  Future<void> saveConfig(MingGuaConfigContract config) =>
      user.saveConfig(config);

  @override
  Future<void> deleteConfig(String id) => user.deleteConfig(id);

  // ── L0 slice methods ──

  @override
  Future<Result<MingGuaConfigContract?>> get(String id, RequestContext ctx) async =>
      Ok(await loadConfig(id));

  @override
  Future<Result<bool>> exists(String id, RequestContext ctx) async =>
      Ok(await loadConfig(id) != null);

  @override
  Future<Result<Rev>> put(
    MingGuaConfigContract entity,
    RequestContext ctx, {
    Precondition pre = const Unconditional(),
  }) async {
    await saveConfig(entity);
    return const Ok(Rev('rev_1'));
  }

  @override
  Future<Result<Page<MingGuaConfigContract>>> query(
    Map<String, Object?> spec,
    PageRequest page,
    RequestContext ctx,
  ) async {
    final all = await loadAllConfigs();
    return Ok(Page(items: all));
  }

  @override
  Future<Result<int>> count(Map<String, Object?> spec, RequestContext ctx) async {
    final all = await loadAllConfigs();
    return Ok(all.length);
  }

  @override
  Future<Result<R>> inTransaction<R>(Future<R> Function() body) async {
    final r = await body();
    return Ok(r);
  }
}
