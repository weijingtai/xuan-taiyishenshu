import re

with open("lib/widgets/deity_management_dialog.dart", "r") as f:
    content = f.read()

# Add import
content = content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport '../l10n/generated/app_localizations.dart';")

content = content.replace("Text('未载入官方星神')", "Text(AppLocalizations.of(context)!.noOfficialDeityLoaded)")
content = content.replace("const Text('关闭')", "Text(AppLocalizations.of(context)!.close)")
content = content.replace("const Text('删除星神')", "Text(AppLocalizations.of(context)!.deleteDeity)")
content = content.replace("const Text('取消')", "Text(AppLocalizations.of(context)!.cancel)")
content = content.replace("const Text('删除')", "Text(AppLocalizations.of(context)!.delete)")

with open("lib/widgets/deity_management_dialog.dart", "w") as f:
    f.write(content)
