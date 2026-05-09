/// 安全表达式解析器——仅支持整数四则运算 + 取模 + 整除
/// 支持的运算符: + - * / % ~/
/// 支持的变量: 由调用方注入的 Map<String, int>
///
/// 安全约束: 无函数调用、无网络访问、无文件读写、仅纯算术
class ExpressionParser {
  static int evaluate(String expr, Map<String, int> variables) {
    String processed = expr;
    for (final entry in variables.entries) {
      processed = processed.replaceAll(entry.key, entry.value.toString());
    }
    return _parseAddSub(processed.trim());
  }

  static int _parseAddSub(String expr) {
    final tokens = _tokenize(expr);
    final first = _parseMulDiv(tokens, 0);
    int result = first.value;
    int i = first.nextIndex;

    while (i < tokens.length) {
      if (tokens[i] == '+') {
        final next = _parseMulDiv(tokens, i + 1);
        result += next.value;
        i = next.nextIndex;
      } else if (tokens[i] == '-') {
        final next = _parseMulDiv(tokens, i + 1);
        result -= next.value;
        i = next.nextIndex;
      } else {
        break;
      }
    }
    return result;
  }

  static _ParseResult _parseMulDiv(List<String> tokens, int index) {
    int value = int.parse(tokens[index]);
    int i = index + 1;

    while (i < tokens.length) {
      final op = tokens[i];
      if (op == '*') {
        value *= int.parse(tokens[i + 1]);
        i += 2;
      } else if (op == '/' || op == '~/') {
        value ~/= int.parse(tokens[i + 1]);
        i += 2;
      } else if (op == '%') {
        value %= int.parse(tokens[i + 1]);
        i += 2;
      } else {
        break;
      }
    }
    return _ParseResult(value, i);
  }

  static List<String> _tokenize(String expr) {
    final tokens = <String>[];
    final buffer = StringBuffer();
    for (int i = 0; i < expr.length; i++) {
      final ch = expr[i];
      if (ch == ' ') continue;
      if ('+-*/%~'.contains(ch)) {
        if (buffer.isNotEmpty) {
          tokens.add(buffer.toString());
          buffer.clear();
        }
        if (ch == '~' && i + 1 < expr.length && expr[i + 1] == '/') {
          tokens.add('~/');
          i++;
        } else {
          tokens.add(ch);
        }
      } else {
        buffer.write(ch);
      }
    }
    if (buffer.isNotEmpty) tokens.add(buffer.toString());
    return tokens;
  }
}

class _ParseResult {
  final int value;
  final int nextIndex;
  const _ParseResult(this.value, this.nextIndex);
}
