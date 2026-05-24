import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taiyishenshu/taiyi/viewmodels/school_view_model.dart';
import 'package:taiyishenshu/taiyi/core/school_config.dart';

class SchoolManagerPage extends StatefulWidget {
  const SchoolManagerPage({Key? key}) : super(key: key);

  @override
  State<SchoolManagerPage> createState() => _SchoolManagerPageState();
}

class _SchoolManagerPageState extends State<SchoolManagerPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SchoolViewModel>().loadSchools();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('流派管理'),
      ),
      body: Consumer<SchoolViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final schools = viewModel.schools;
          if (schools.isEmpty) {
            return const Center(child: Text('无流派数据'));
          }

          return ListView.builder(
            itemCount: schools.length,
            itemBuilder: (context, index) {
              final school = schools[index];
              final isCurrent = viewModel.currentSchool?.id == school.id;
              
              return ListTile(
                title: Text(school.name),
                subtitle: Text(school.source == 'official' ? '官方' : '自定义'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.copy),
                      tooltip: 'Copy',
                      onPressed: () => _showCopyDialog(context, viewModel, school),
                    ),
                    if (school.source == 'user')
                      IconButton(
                        icon: const Icon(Icons.edit),
                        tooltip: 'Edit',
                        onPressed: () => _showEditDialog(context, viewModel, school),
                      ),
                    if (isCurrent) const Icon(Icons.check, color: Colors.green),
                  ],
                ),
                onTap: () {
                  viewModel.selectSchool(school.id);
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _showCopyDialog(BuildContext context, SchoolViewModel viewModel, TaiYiSchool school) async {
    final controller = TextEditingController(text: '${school.name} (Copy)');
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Copy School'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'New Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Copy'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      await viewModel.copySchool(
        sourceId: school.id,
        newId: '${school.id}_copy_${DateTime.now().millisecondsSinceEpoch}',
        newName: result,
      );
    }
  }

  Future<void> _showEditDialog(BuildContext context, SchoolViewModel viewModel, TaiYiSchool school) async {
    final controller = TextEditingController(text: school.name);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit School'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      await viewModel.saveSchool(school.copyWith(name: result));
    }
  }
}
