import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../controllers/taiyi_pan_controller.dart';
import '../taiyi/core/school_config.dart';
import '../taiyi/taiyi_assembly.dart';
import '../theme/taiyi_classic_theme.dart';
import '../widgets/ink_wash_widgets.dart';

/// 流派管理页 (ZenTao Task 14 / Story #4)
///
/// 职责:
/// 1. 列表展示官方 + 用户流派 (数据来自 ViewModel -> UseCase -> Repository,
///    页面不直接访问 assets / Drift / SharedPreferences)。
/// 2. 复制官方/用户流派为新的用户流派 (走 CopySchoolUseCase -> DriftUserRepository)。
/// 3. 编辑用户流派 -> 跳转流派编辑器 (路由名 `/taiyishenshu/school-editor`,
///    路由由 Master/Navigator wire；本页只发出意图)。
/// 4. 切换流派 -> controller.switchSchool(id) 触发重新排盘
///    (accumulatedYear / juNumber / 落宫等会真实变化)。
/// 5. 官方流派只读: 不展示 edit / delete 入口。
class SchoolManagerPage extends StatefulWidget {
  final TaiYiPanController? controller;
  final TaiYiDataAssembly? assembly; // NEW injected host-built assembly

  const SchoolManagerPage({super.key, this.controller, this.assembly});

  @override
  State<SchoolManagerPage> createState() => _SchoolManagerPageState();
}

class _SchoolManagerPageState extends State<SchoolManagerPage> {
  TaiYiPanController? _controller;
  bool _isLoading = true;
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  Future<void> _initController() async {
    if (widget.controller != null) {
      _controller = widget.controller;
      _ownsController = false;
    } else if (widget.assembly != null) {
      _controller = TaiYiPanController(assembly: widget.assembly!);
      _ownsController = true;
      await _controller!.loadSchools();
    } else {
      throw UnsupportedError(
        'Inject a TaiYiDataAssembly (built by the example host). '
        'See storage-refactor §12-E2.',
      );
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    if (_ownsController) {
      _controller?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _controller == null) {
      return const Scaffold(
        backgroundColor: TaiYiClassicTheme.ricePaper,
        body: Center(
          child: CircularProgressIndicator(color: TaiYiClassicTheme.cinnabar),
        ),
      );
    }
    return ChangeNotifierProvider<TaiYiPanController>.value(
      value: _controller!,
      child: const _SchoolManagerScaffold(),
    );
  }
}

class _SchoolManagerScaffold extends StatelessWidget {
  const _SchoolManagerScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TaiYiClassicTheme.ricePaper,
      appBar: AppBar(
        backgroundColor: TaiYiClassicTheme.darkWood,
        foregroundColor: TaiYiClassicTheme.paleGold,
        title: Text(
          '流派管理',
          style: TaiYiClassicTheme.getTitleStyle(
            fontSize: 22,
            color: TaiYiClassicTheme.paleGold,
          ),
        ),
      ),
      body: Consumer<TaiYiPanController>(
        builder: (context, controller, _) {
          final vm = controller.schoolViewModel;
          if (vm.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: TaiYiClassicTheme.cinnabar,
              ),
            );
          }
          final all = vm.schools;
          if (all.isEmpty) {
            return Center(
              child: Text(
                '尚无流派数据',
                style: TaiYiClassicTheme.getChineseStyle(
                  fontSize: 16,
                  color: TaiYiClassicTheme.inkWash,
                ),
              ),
            );
          }
          final official = all.where((s) => s.source == 'official').toList();
          final user = all.where((s) => s.source == 'user').toList();
          final currentId = controller.panData?.input.schoolId;

          return PaperBackground(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                const ChineseSectionHeader(title: '官方流派 (只读)'),
                ...official.map((s) => SchoolListItem(
                      key: Key('school-row-${s.id}'),
                      school: s,
                      isCurrent: currentId == s.id,
                      onTap: () => _switchTo(context, controller, s.id),
                      onCopy: () => _showCopyDialog(context, controller, s),
                      onEdit: null, // official 不可编辑
                      onShowLineage: () => _showLineageSheet(context, s),
                    )),
                const SizedBox(height: 16),
                ChineseSectionHeader(title: AppLocalizations.of(context)!.mySchoolsEditable),
                if (user.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 24),
                    child: Text(
                      '尚未派生任何用户流派。点击官方流派旁的复制图标即可创建一个属于你的副本。',
                      style: TaiYiClassicTheme.getChineseStyle(
                        fontSize: 14,
                        color: TaiYiClassicTheme.inkWash,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                else
                  ...user.map((s) => SchoolListItem(
                        key: Key('school-row-${s.id}'),
                        school: s,
                        isCurrent: currentId == s.id,
                        onTap: () => _switchTo(context, controller, s.id),
                        onCopy: () => _showCopyDialog(context, controller, s),
                        onEdit: () => _openEditor(context, s),
                        onShowLineage: () => _showLineageSheet(context, s),
                      )),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _switchTo(
      BuildContext context, TaiYiPanController controller, String id) async {
    await controller.switchSchool(id);
    if (!context.mounted) return;
    final newPan = controller.panData;
    final messenger = ScaffoldMessenger.of(context);
    if (newPan != null && newPan.input.schoolId == id) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            '已切换到「${newPan.input.schoolName}」，积年=${newPan.accumulatedYear}，局数=${newPan.juNumber}',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } else if (controller.error != null) {
      messenger.showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.switchFailed(controller.error.toString()))),
      );
    }
  }

  Future<void> _showCopyDialog(
    BuildContext context,
    TaiYiPanController controller,
    TaiYiSchool school,
  ) async {
    final textController =
        TextEditingController(text: '${school.name}副本');
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: TaiYiClassicTheme.ricePaper,
        title: Text(
          '复制流派',
          style: TaiYiClassicTheme.getTitleStyle(
            fontSize: 18,
            color: TaiYiClassicTheme.darkWood,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '即将从「${school.name}」派生一个新的用户流派。',
              style: TaiYiClassicTheme.getChineseStyle(
                fontSize: 13,
                color: TaiYiClassicTheme.inkWash,
              ),
            ),
            const SizedBox(height: 12),
            Semantics(
              identifier: 'copy-name-input',
              textField: true,
              label: '新流派名称输入框',
              child: TextField(
                key: const Key('copy-name-field'),
                controller: textController,
                decoration: const InputDecoration(
                  labelText: '新流派名称',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(AppLocalizations.of(ctx)!.cancel),
          ),
          Semantics(
            identifier: 'copy-confirm-button',
            button: true,
            label: AppLocalizations.of(ctx)!.confirmCopy,
            child: TextButton(
              key: const Key('copy-confirm-button'),
              onPressed: () => Navigator.of(ctx).pop(textController.text.trim()),
              child: Text(AppLocalizations.of(ctx)!.copy),
            ),
          ),
        ],
      ),
    );

    if (result == null || result.isEmpty) return;
    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await controller.schoolViewModel.copySchool(
        sourceId: school.id,
        newId: 'user_${school.id}_${DateTime.now().millisecondsSinceEpoch}',
        newName: result,
      );
      messenger.showSnackBar(
        SnackBar(content: Text('已派生用户流派「$result」')),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.copyFailed(e.toString()))),
      );
    }
  }

  /// 跳转流派编辑器。
  /// 路由名 `/taiyishenshu/school-editor` 由 Master 在 navigator.dart 中 wire。
  /// Master wire 完毕前，路由不可达，本入口会提示用户。
  void _openEditor(BuildContext context, TaiYiSchool school) {
    Navigator.of(context)
        .pushNamed(
          '/taiyishenshu/school-editor',
          arguments: {'schoolId': school.id, 'name': school.name},
        )
        .catchError((_) => null);
  }

  void _showLineageSheet(BuildContext context, TaiYiSchool school) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: TaiYiClassicTheme.ricePaper,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Semantics(
            identifier: 'school-lineage-sheet-${school.id}',
            container: true,
            label: AppLocalizations.of(ctx)!.schoolDetailAndLineage(school.name),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  school.name,
                  style: TaiYiClassicTheme.getTitleStyle(
                    fontSize: 20,
                    color: TaiYiClassicTheme.darkWood,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _kv('ID', school.id),
                _kv('来源', school.source == 'official' ? '官方资产' : '用户派生'),
                _kv('积年基数', school.epoch.ancientBase.toString()),
                _kv('起算年份', school.epoch.epochYear.toString()),
                _kv('修正值', school.epoch.correction.toString()),
                if (school.lineage != null)
                  Semantics(
                    identifier: 'school-lineage-text',
                    label: '传承链 ${school.lineage!}',
                    child: _kv('传承链', school.lineage!),
                  ),
                if (school.rootOfficialId != null)
                  Semantics(
                    identifier: 'school-root-official',
                    label: '根官方流派 ${school.rootOfficialId!}',
                    child: _kv('根官方流派', school.rootOfficialId!),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _kv(String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 84,
            child: Text(
              key,
              style: TaiYiClassicTheme.getTitleStyle(
                fontSize: 13,
                color: TaiYiClassicTheme.inkWash,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TaiYiClassicTheme.getChineseStyle(
                fontSize: 14,
                color: TaiYiClassicTheme.inkBlack,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 流派列表行 widget。
///
/// 视觉规则:
/// - 官方流派: 显示锁形图标 + 信息按钮 + 复制按钮 (无 edit/delete)。
/// - 用户流派: 显示信息按钮 + 复制按钮 + 编辑按钮。
/// - 当前选中流派: 左侧高亮条 + check 标记。
///
/// 可访问性:
/// - 整行 InkWell 提供水波纹反馈 (≥48dp 高度)。
/// - 操作图标按钮均带 tooltip 与 semanticLabel。
class SchoolListItem extends StatelessWidget {
  final TaiYiSchool school;
  final bool isCurrent;
  final VoidCallback onTap;
  final VoidCallback onCopy;
  final VoidCallback? onEdit;
  final VoidCallback onShowLineage;

  const SchoolListItem({
    super.key,
    required this.school,
    required this.isCurrent,
    required this.onTap,
    required this.onCopy,
    required this.onEdit,
    required this.onShowLineage,
  });

  bool get _isOfficial => school.source == 'official';

  @override
  Widget build(BuildContext context) {
    final accent = _isOfficial
        ? TaiYiClassicTheme.goldLeaf
        : TaiYiClassicTheme.cinnabar;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Semantics(
        identifier: 'school-row-${school.id}',
        label: school.name,
        selected: isCurrent,
        container: true,
        child: Material(
        color: isCurrent
            ? TaiYiClassicTheme.paleGold.withValues(alpha: 0.35)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 56),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: isCurrent ? accent : Colors.transparent,
                  width: 4,
                ),
                bottom: BorderSide(
                  color: TaiYiClassicTheme.goldLeaf.withValues(alpha: 0.15),
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _isOfficial ? Icons.shield_outlined : Icons.edit_note,
                  size: 22,
                  color: accent,
                  semanticLabel: _isOfficial ? '官方流派' : '用户流派',
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Semantics(
                              identifier: 'school-name-${school.id}',
                              label: school.name,
                              child: Text(
                                school.name,
                                style: TaiYiClassicTheme.getTitleStyle(
                                  fontSize: 16,
                                  color: TaiYiClassicTheme.darkWood,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          if (isCurrent) ...[
                            const SizedBox(width: 6),
                            Semantics(
                              identifier: 'school-current-marker-${school.id}',
                              label: '当前流派',
                              child: const Icon(
                                Icons.check_circle,
                                size: 16,
                                color: TaiYiClassicTheme.jadeGreen,
                                semanticLabel: '当前流派',
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Semantics(
                        identifier: 'school-subtitle-${school.id}',
                        child: Text(
                          _isOfficial
                              ? '官方 · 积年基数 ${school.epoch.ancientBase}'
                              : (school.lineage ?? '用户派生'),
                          style: TaiYiClassicTheme.getChineseStyle(
                            fontSize: 12,
                            color: TaiYiClassicTheme.inkWash,
                            fontStyle: _isOfficial
                                ? FontStyle.normal
                                : FontStyle.italic,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                ),
                Semantics(
                  identifier: 'school-info-${school.id}',
                  button: true,
                  label: AppLocalizations.of(context)!.viewSchoolDetailAndLineage(school.name),
                  child: IconButton(
                    key: Key('info-${school.id}'),
                    icon: const Icon(Icons.info_outline, size: 20),
                    color: TaiYiClassicTheme.inkWash,
                    tooltip: AppLocalizations.of(context)!.detailAndLineage,
                    onPressed: onShowLineage,
                    constraints: const BoxConstraints(
                      minWidth: 44,
                      minHeight: 44,
                    ),
                  ),
                ),
                Semantics(
                  identifier: 'school-copy-${school.id}',
                  button: true,
                  label: AppLocalizations.of(context)!.copySchoolAsUser(school.name),
                  child: IconButton(
                    key: Key('copy-${school.id}'),
                    icon: const Icon(Icons.copy, size: 20),
                    color: TaiYiClassicTheme.darkWood,
                    tooltip: AppLocalizations.of(context)!.copyAsUserSchool,
                    onPressed: onCopy,
                    constraints: const BoxConstraints(
                      minWidth: 44,
                      minHeight: 44,
                    ),
                  ),
                ),
                if (!_isOfficial && onEdit != null)
                  Semantics(
                    identifier: 'school-edit-${school.id}',
                    button: true,
                    label: AppLocalizations.of(context)!.editSchool(school.name),
                    child: IconButton(
                      key: Key('edit-${school.id}'),
                      icon: const Icon(Icons.edit, size: 20),
                      color: TaiYiClassicTheme.cinnabar,
                      tooltip: AppLocalizations.of(context)!.editUserSchool,
                      onPressed: onEdit,
                      constraints: const BoxConstraints(
                        minWidth: 44,
                        minHeight: 44,
                      ),
                    ),
                  ),
                // 官方流派: 显式不渲染 edit/delete IconButton (反假完成红线#5)。
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}
