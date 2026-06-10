/// 递归求值「JSON 算术树」(规则引擎 R1 的算术叶子)。
///
/// 节点形状(均为 Map<String, dynamic>):
///   {"int": int}                                整数字面量
///   {"num": num}                                实数字面量(仅应作为 * 的操作数,最终须由 floor 收成整数)
///   {"var": String}                             变量,从 [vars] 取值;缺失 → ArgumentError
///   {"op": "+|-|*|~/|%", "a": <node>, "b": <node>}  二元运算(整除一律 "~/";不支持 "/")
///   {"floor": <node>}                           向下取整为 int
///
/// 约束:
/// - 非上述形状/未知键 → ArgumentError('非法 AST 节点: ...')
/// - op 不在白名单(含 "/") → ArgumentError
/// - 递归深度 > [maxDepth] → ArgumentError('AST 超过最大深度 $maxDepth')
///
/// 返回 num(纯整数运算返回 int;floor 返回 int)。不做字符串解析、不访问 IO、不执行代码。
num evalArithmeticTree(Object? node, Map<String, num> vars, {int maxDepth = 16}) {
  return _eval(node, vars, maxDepth, 0);
}

num _eval(Object? node, Map<String, num> vars, int maxDepth, int currentDepth) {
  if (currentDepth > maxDepth) {
    throw ArgumentError('AST 超过最大深度 $maxDepth');
  }

  if (node is! Map) {
    throw ArgumentError('非法 AST 节点: $node');
  }

  final keys = node.keys.map((k) => k.toString()).toSet();
  if (keys.isEmpty) {
    throw ArgumentError('非法 AST 节点: 空节点');
  }

  final firstKey = keys.first;
  final allowedKeys = {'int', 'num', 'var', 'op', 'floor'};
  if (!allowedKeys.contains(firstKey)) {
    throw ArgumentError('非法 AST 节点: 未知键 $firstKey');
  }

  if (firstKey == 'int') {
    final val = node['int'];
    if (val is! int) {
      throw ArgumentError('int 节点的值必须为整数');
    }
    return val;
  }

  if (firstKey == 'num') {
    final val = node['num'];
    if (val is! num) {
      throw ArgumentError('num 节点的值必须为数值');
    }
    return val;
  }

  if (firstKey == 'var') {
    final name = node['var'];
    if (name is! String) {
      throw ArgumentError('var 节点的值必须为字符串');
    }
    if (!vars.containsKey(name)) {
      throw ArgumentError('未声明变量: $name');
    }
    return vars[name]!;
  }

  if (firstKey == 'floor') {
    final inner = node['floor'];
    final evaluated = _eval(inner, vars, maxDepth, currentDepth + 1);
    return evaluated.floor();
  }

  if (firstKey == 'op') {
    final op = node['op'];
    final allowedOps = {'+', '-', '*', '~/', '%'};
    if (!allowedOps.contains(op)) {
      throw ArgumentError('非法 AST 节点: 未知/禁用操作符: $op');
    }

    final aNode = node['a'];
    final bNode = node['b'];
    if (aNode == null || bNode == null) {
      throw ArgumentError('op 节点必须包含 a 和 b 子节点');
    }

    final a = _eval(aNode, vars, maxDepth, currentDepth + 1);
    final b = _eval(bNode, vars, maxDepth, currentDepth + 1);

    switch (op) {
      case '+':
        return a + b;
      case '-':
        return a - b;
      case '*':
        return a * b;
      case '~/':
        return a ~/ b;
      case '%':
        return a % b;
      default:
        throw ArgumentError('未知操作符: $op');
    }
  }

  throw ArgumentError('无法识别的 AST 节点: $node');
}
