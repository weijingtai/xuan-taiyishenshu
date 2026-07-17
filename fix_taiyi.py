import re

with open("lib/widgets/deity_management_dialog.dart", "r") as f:
    content = f.read()

content = content.replace("import '../l10n/generated/app_localizations.dart';", "import 'package:flutter_gen/gen_l10n/app_localizations.dart';")
content = content.replace("const Padding(", "Padding(")

with open("lib/widgets/deity_management_dialog.dart", "w") as f:
    f.write(content)
