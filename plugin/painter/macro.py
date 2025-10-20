import re

from .path import Path


class Macro:
    @staticmethod
    def process(code: str, macros: dict = {}, remove_comments: bool = True, path = "", included: list = None):
        included = [] if not included else included

        for macro in macros.keys():
            macros[macro] = str(macros[macro])
        condition_stack = []

        def eval_expr(expr: str) -> bool:
            expr = re.sub(r'!(\w+)', r' not \1', expr)
            expr = expr.replace('||', ' or ')
            expr = expr.replace('&&', ' and ')

            try:
                return eval(expr)
            except:
                return False

        def current_level():
            return len(condition_stack)

        def current_branch():
            return condition_stack[-1] if current_level() > 0 else [True]

        def skipping():
            for branch in condition_stack:
                if not branch[-1]:
                    return True
            return False
            
        processed_lines = []
        for line in code.split("\n"):
            if not line.startswith("//:"):
                if remove_comments:
                    line = line.split("//")[0]
                for macro in macros.keys():
                    keys = sorted(macros.keys(), key=len, reverse=True)
                    pattern = re.compile(r'(?<!\w)(' + '|'.join(map(re.escape, keys)) + r')(?!\w)', flags=re.UNICODE)
                    line = pattern.sub(lambda m: macros[m.group(1)], line)

                line = line.strip()

                #include
                if line.startswith("#include"):
                    match = re.match(r'\s*"([^"]+)"', line[8:])
                    assert match, "Invalid include directive"
                    inc = Path.join(Path.to(path), match.group(1))
                    if not inc in included:
                        included.append(inc)
                        processed_lines += Macro.process(Path.read(inc), macros, remove_comments, inc, included).split("\n")
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
                    condition_stack.append([cond])
                    continue

                #if
                elif line.startswith("#if"):
                    cond = eval_expr(line[3:].strip())
                    condition_stack.append([cond])
                    continue

                #elif
                elif line.startswith("#elif"):
                    cond = not any(current_branch()) and eval_expr(line[5:].strip())
                    condition_stack[-1].append(cond)
                    continue

                #else
                elif line.startswith("#else"):
                    cond = not any(current_branch())
                    condition_stack[-1].append(cond)
                    continue

                #endif
                elif line.startswith("#endif"):
                    condition_stack.pop()
                    continue

            if not skipping() and line != "":
                processed_lines.append(line)

        assert current_level() == 0, "Missing #endif"

        return "\n".join(processed_lines)
    