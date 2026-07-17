import re

with open("lib/widgets/deity_management_dialog.dart", "r") as f:
    content = f.read()

content = content.replace("import 'package:flutter_gen/gen_l10n/app_localizations.dart';", "import '../l10n/app_localizations.dart';")

with open("lib/widgets/deity_management_dialog.dart", "w") as f:
    f.write(content)
