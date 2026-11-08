import ast
import operator
import re
from functools import lru_cache

from .path import Path


@lru_cache(maxsize=128)
def _replacement_pattern(keys):
    return re.compile(r'(?<!\w)(' + '|'.join(map(re.escape, keys)) + r')(?!\w)')


class Macro:
    @staticmethod
    def process(code: str, macros: dict = None, remove_comments: bool = True, path = "", included: list = None):
        macros = {} if macros is None else macros
        included = [] if included is None else included
        if path:
            path = Path.norm(path)
            if path not in included:
                included.append(path)

        for macro in macros.keys():
            macros[macro] = str(macros[macro])
        condition_stack = []

        def eval_expr(expr: str) -> bool:
            try:
                expression = re.sub(r"!(?!=)", " not ", expr).replace("||", " or ").replace("&&", " and ").strip()
                tree = ast.parse(expression, mode="eval")
                return bool(evaluate(tree.body))
            except SyntaxError as error:
                raise ValueError(f"Invalid macro condition: {expr}") from error

        def evaluate(node):
            if isinstance(node, ast.Constant) and type(node.value) in (bool, int, float):
                return node.value
            if isinstance(node, ast.Name):
                return 0
            if isinstance(node, ast.UnaryOp) and isinstance(node.op, ast.Not):
                return not evaluate(node.operand)
            if isinstance(node, ast.UnaryOp) and isinstance(node.op, ast.USub):
                return -evaluate(node.operand)
            if isinstance(node, ast.BoolOp):
                values = (bool(evaluate(value)) for value in node.values)
                if isinstance(node.op, ast.And):
                    return all(values)
                if isinstance(node.op, ast.Or):
                    return any(values)
            if isinstance(node, ast.Compare):
                operations = {ast.Eq: operator.eq, ast.NotEq: operator.ne, ast.Gt: operator.gt,
                              ast.GtE: operator.ge, ast.Lt: operator.lt, ast.LtE: operator.le}
                left = evaluate(node.left)
                for operation, comparator in zip(node.ops, node.comparators):
                    function = operations.get(type(operation))
                    if function is None:
                        raise ValueError("Unsupported comparison in macro condition")
                    right = evaluate(comparator)
                    if not function(left, right):
                        return False
                    left = right
                return True
            raise ValueError("Unsupported expression in macro condition")

        def current_level():
            return len(condition_stack)

        def skipping():
            for frame in condition_stack:
                if not frame["branches"][-1]:
                    return True
            return False

        processed_lines = []
        for line in code.split("\n"):
            if not line.lstrip().startswith("//:"):
                if remove_comments:
                    line = line.split("//")[0]
                if macros:
                    keys = tuple(sorted(macros, key=len, reverse=True))
                    pattern = _replacement_pattern(keys)
                    # Preserve chained substitutions, stopping once stable.
                    for _ in macros:
                        replaced = pattern.sub(lambda match: macros[match.group(1)], line)
                        if replaced == line:
                            break
                        line = replaced

                line = line.strip()

                #include
                if line.startswith("#include"):
                    match = re.match(r'\s*"([^"]+)"', line[8:])
                    if not match:
                        raise ValueError(f"Invalid include directive: {line}")
                    inc = Path.join(Path.to(path), match.group(1))
                    if not inc in included:
                        included.append(inc)
                        try:
                            with open(inc, encoding="utf-8") as source:
                                included_code = source.read()
                        except (OSError, UnicodeError) as error:
                            raise FileNotFoundError(f"Could not read include {inc}: {error}") from error
                        processed_lines += Macro.process(included_code, macros, remove_comments, inc, included).split("\n")
                    continue

                #define
                if line.startswith("#define"):
                    if current_level() == 0:
                        match = re.match(r"^\s*#\s*define\s+(\w+)\s*(.*)", line)
                        if match:
                            macros[match.group(1)] = match.group(2).strip()
                    continue

                #undef
                elif line.startswith("#undef"):
                    if current_level() == 0:
                        match = re.match(r"^\s*#\s*undef\s+(\w+)", line)
                        if match:
                            macro_name = match.group(1)
                            if macro_name in macros:
                                macros.pop(macro_name)
                    continue

                #ifdef
                elif line.startswith("#ifdef"):
                    cond = line[7:].strip() in macros
                    condition_stack.append({"branches": [cond], "else_seen": False})
                    continue

                #if
                elif line.startswith("#if"):
                    cond = eval_expr(line[3:].strip())
                    condition_stack.append({"branches": [cond], "else_seen": False})
                    continue

                #elif
                elif line.startswith("#elif"):
                    if not condition_stack:
                        raise ValueError("#elif without matching #if")
                    frame = condition_stack[-1]
                    if frame["else_seen"]:
                        raise ValueError("#elif after #else")
                    cond = not any(frame["branches"]) and eval_expr(line[5:].strip())
                    frame["branches"].append(cond)
                    continue

                #else
                elif line.startswith("#else"):
                    if not condition_stack:
                        raise ValueError("#else without matching #if")
                    frame = condition_stack[-1]
                    if frame["else_seen"]:
                        raise ValueError("Multiple #else directives for one #if")
                    frame["branches"].append(not any(frame["branches"]))
                    frame["else_seen"] = True
                    continue

                #endif
                elif line.startswith("#endif"):
                    if not condition_stack:
                        raise ValueError("#endif without matching #if")
                    condition_stack.pop()
                    continue
            else:
                line = line.lstrip()

            if not skipping() and line != "":
                processed_lines.append(line)

        if current_level():
            raise ValueError("Missing #endif")

        return "\n".join(processed_lines)

