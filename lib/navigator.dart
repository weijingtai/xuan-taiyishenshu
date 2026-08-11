import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:taiyishenshu/controllers/taiyi_pan_controller.dart';
import 'package:taiyishenshu/pages/deity_editor_page.dart';
import 'package:taiyishenshu/pages/my_home_page.dart';
import 'package:taiyishenshu/pages/rectangle_pan.dart';
import 'package:taiyishenshu/pages/school_editor_page.dart';
import 'package:taiyishenshu/pages/taiyi_pan_page.dart';
import 'package:taiyishenshu/taiyi/viewmodels/deity_view_model.dart';
import 'package:taiyishenshu/taiyi/viewmodels/school_view_model.dart';
import 'package:taiyishenshu/taiyi/taiyi_assembly.dart';

class NavigatorGenerator {
static final RouteObserver<PageRoute> routeObserver =
RouteObserver<PageRoute>();
static Logger logger = Logger();
static final routes = {
"/taiyishenshu": (BuildContext context, {arguments}) {
  final controller = context.read<TaiYiPanController>();
  final assembly = context.read<TaiYiDataAssembly>();
  return TaiYiPanPage(controller: controller, assembly: assembly);
},
"/taiyishenshu/legacy": (BuildContext context, {arguments}) =>
    const RectanglePanel(),
"/taiyishenshu/demo": (BuildContext context, {arguments}) =>
    MyHomePage(title: "太乙神数"),
"/taiyishenshu/school-editor": _buildSchoolEditor,
"/taiyishenshu/deity-editor": _buildDeityEditor,
};

  /// Build the school editor for the `/taiyishenshu/school-editor` route.
  ///
  /// Accepts a [SchoolEditorArgs] payload. If a [TaiYiPanController] is
  /// reachable from the current [BuildContext] (e.g., the route was pushed
  /// from a screen that already provides one), the editor is wrapped in a
  /// [ChangeNotifierProvider<SchoolViewModel>.value] re-exposing the
  /// controller's `schoolViewModel`. When no controller is in scope the
  /// editor still renders but degrades gracefully via its own
  /// `ProviderNotFoundException` handling (the page shows a load error).
  static Widget _buildSchoolEditor(BuildContext context, {dynamic arguments}) {
    final args = arguments is SchoolEditorArgs
        ? arguments
        : const SchoolEditorArgs(schoolId: '', mode: 'view');
    final controller = _tryReadController(context);
    final page = SchoolEditorPage(args: args);
    if (controller == null) {
      return page;
    }
    return ChangeNotifierProvider<SchoolViewModel>.value(
      value: controller.schoolViewModel,
      child: page,
    );
  }

  /// Build the deity editor for the `/taiyishenshu/deity-editor` route.
  ///
  /// Accepts a [DeityEditorArgs] payload (or null for "new user deity"
  /// mode). When a [TaiYiPanController] is in scope, both
  /// [DeityViewModel] and [SchoolViewModel] are re-exposed via
  /// [MultiProvider] so the editor can resolve `availableSchools` and
  /// persist saves through the production ViewModel chain.
  static Widget _buildDeityEditor(BuildContext context, {dynamic arguments}) {
    final args = arguments is DeityEditorArgs ? arguments : null;
    final controller = _tryReadController(context);
    final page = DeityEditorPage(deity: args?.deity);
    if (controller == null) {
      return page;
    }
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<DeityViewModel>.value(
          value: controller.deityViewModel,
        ),
        ChangeNotifierProvider<SchoolViewModel>.value(
          value: controller.schoolViewModel,
        ),
      ],
      child: page,
    );
  }

  /// Best-effort lookup of [TaiYiPanController] in the current context.
  /// Returns null if no provider exists (e.g., route pushed from a root
  /// scope outside the TaiYi feature). Never throws.
  static TaiYiPanController? _tryReadController(BuildContext context) {
    try {
      return Provider.of<TaiYiPanController>(context, listen: false);
    } on ProviderNotFoundException {
      return null;
    }
  }

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final String? name = settings.name;
    if (name != null && name.isNotEmpty) {
      final Function? pageContentBuilder = routes[name];
      if (pageContentBuilder != null) {
        final Route route = MaterialPageRoute(
            builder: (context) =>
                pageContentBuilder(context, arguments: settings.arguments));
        return route;
      } else {
        return _errorPage('Could not found route for $name');
      }
    } else {
      return _errorPage("Navigator required naviation name.");
    }
  }

  static Route _errorPage(msg) {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
          appBar: AppBar(title: const Text('奇门遁甲_未知页面')),
          body: Center(child: Text(msg)));
    });
  }

  static Route<dynamic> generateRoute1(RouteSettings settings) {
    switch (settings.name) {
      case '/taiyishenshu/primary':
        return PageRouteBuilder(
            settings:
                settings, // Pass this to make popUntil(), pushNamedAndRemoveUntil(), works
            // pageBuilder: (_, __, ___) => CreateOrderPage(settings.arguments == null ?null:settings.arguments as CreateOrderPageArgs),
            pageBuilder: (_, __, ___) => const MyHomePage(title: "太乙神数"),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(0.0, 1.0);
              const end = Offset.zero;
              const curve = Curves.ease;
              final tween = Tween(begin: begin, end: end);
              final curvedAnimation = CurvedAnimation(
                parent: animation,
                curve: curve,
              );
              return SlideTransition(
                position: tween.animate(curvedAnimation),
                child: child,
              );
            });
      default:
        return MaterialPageRoute(
            builder: (_) => Scaffold(
                  body: Center(
                      child: Text('No route defined for ${settings.name}')),
                ));
    }
  }
}
