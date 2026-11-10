"""Small, deterministic preprocessor for the bundled shaders."""
import ast
import operator
import re
from functools import lru_cache


_COMPARISONS = {
    ast.Eq: operator.eq, ast.NotEq: operator.ne, ast.Gt: operator.gt,
    ast.GtE: operator.ge, ast.Lt: operator.lt, ast.LtE: operator.le,
}
_DEFINE = re.compile(r"^\s*#\s*define\s+(\w+)\s*(.*)")
_UNDEF = re.compile(r"^\s*#\s*undef\s+(\w+)")
_NOT = re.compile(r"!(?!=)")


@lru_cache(maxsize=128)
def _replacement_pattern(keys):
    return re.compile(r"(?<!\w)(" + "|".join(map(re.escape, keys)) + r")(?!\w)")


def _evaluate(node):
    if isinstance(node, ast.Constant) and type(node.value) in (bool, int, float):
        return node.value
    if isinstance(node, ast.Name):
        return 0
    if isinstance(node, ast.UnaryOp):
        if isinstance(node.op, ast.Not):
            return not _evaluate(node.operand)
        if isinstance(node.op, ast.USub):
            return -_evaluate(node.operand)
    if isinstance(node, ast.BoolOp):
        values = (bool(_evaluate(value)) for value in node.values)
        if isinstance(node.op, ast.And):
            return all(values)
        if isinstance(node.op, ast.Or):
            return any(values)
    if isinstance(node, ast.Compare):
        left = _evaluate(node.left)
        for operation, comparator in zip(node.ops, node.comparators):
            function = _COMPARISONS.get(type(operation))
            if function is None:
                raise ValueError("Unsupported comparison in macro condition")
            right = _evaluate(comparator)
            if not function(left, right):
                return False
            left = right
        return True
    raise ValueError("Unsupported expression in macro condition")


@lru_cache(maxsize=512)
def _condition(expr):
    expression = _NOT.sub(" not ", expr).replace("||", " or ").replace("&&", " and ").strip()
    try:
        return bool(_evaluate(ast.parse(expression, mode="eval").body))
    except SyntaxError as error:
        raise ValueError(f"Invalid macro condition: {expr}") from error


class Macro:
    @staticmethod
    def process(code: str, macros: dict = None, remove_comments: bool = True):
        macros = {} if macros is None else macros
        for key in macros:
            macros[key] = str(macros[key])
        pattern = _replacement_pattern(tuple(sorted(macros, key=len, reverse=True))) if macros else None
        frames, output = [], []
        active = True

        for line in code.split("\n"):
            if line.lstrip().startswith("//:"):
                if active:
                    output.append(line.lstrip())
                continue
            if remove_comments:
                line = line.split("//", 1)[0]
            if pattern is not None:
                # Preserve chained substitutions, including bounded cycles.
                for _ in macros:
                    replaced = pattern.sub(lambda match: macros[match[1]], line)
                    if replaced == line:
                        break
                    line = replaced
            line = line.strip()

            if line.startswith(("#define", "#undef")):
                if not frames:
                    match = (_DEFINE if line.startswith("#define") else _UNDEF).match(line)
                    if match:
                        if line.startswith("#define"):
                            macros[match[1]] = match[2].strip()
                        else:
                            macros.pop(match[1], None)
                        pattern = _replacement_pattern(tuple(sorted(macros, key=len, reverse=True))) if macros else None
                continue
            if line.startswith("#if"):
                condition = line[7:].strip() in macros if line.startswith("#ifdef") else _condition(line[3:].strip())
                # Each frame stores parent visibility, any matched branch, else seen.
                frames.append([active, condition, False])
                active = active and condition
            elif line.startswith(("#elif", "#else")):
                directive = "#elif" if line.startswith("#elif") else "#else"
                if not frames:
                    raise ValueError(f"{directive} without matching #if")
                frame = frames[-1]
                if frame[2]:
                    raise ValueError("#elif after #else" if directive == "#elif" else "Multiple #else directives for one #if")
                condition = not frame[1] and (directive == "#else" or _condition(line[5:].strip()))
                frame[1] = frame[1] or condition
                frame[2] = directive == "#else"
                active = frame[0] and condition
            elif line.startswith("#endif"):
                if not frames:
                    raise ValueError("#endif without matching #if")
                active = frames.pop()[0]
            elif active and line:
                output.append(line)

        if frames:
            raise ValueError("Missing #endif")
        return "\n".join(output)
