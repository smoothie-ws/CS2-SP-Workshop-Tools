import re

from .log import Log

def preprocess(code: str, macros: dict={}):
    for macro in macros.keys():
        macros[macro] = str(macros[macro])
    condition_stack = []

    def eval_expr(expr: str) -> bool:
        expr = re.sub(r'!(\w+)', r' not \1', expr)
        expr = expr.replace('||', ' or ')
        expr = expr.replace('&&', ' and ')

        try:
            return eval(expr)
        except Exception as e:
           Log.error(f'Failed to evaluate preprocessing expression `{expr}`: {e}')
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
            for macro in macros.keys():
                line = line.replace(macro, macros[macro])
                
        stripped_line = line.split("//")[0].strip()

        #define
        if stripped_line.startswith("#define"):
            if current_level() == 0:
                match = re.match(r"^\s*#\s*define\s+(\w+)\s*(.*)", stripped_line)
                if match:
                    macros[match.group(1)] = match.group(2).strip()
            continue

        #undef
        elif stripped_line.startswith("#undef"):
            if current_level() == 0:
                match = re.match(r"^\s*#\s*undef\s+(\w+)", stripped_line)
                if match:
                    macro_name = match.group(1)
                    if macro_name in macros:
                        macros.pop(macro_name)
            continue

        #ifdef
        elif stripped_line.startswith("#ifdef"):
            macro = stripped_line[7:].strip()
            condition_stack.append([macro in macros])
            continue

        #if
        elif stripped_line.startswith("#if"):
            condition_stack.append([eval_expr(stripped_line[3:].strip())])
            continue

        #elif
        elif stripped_line.startswith("#elif"):
            condition_stack[-1].append(not any(current_branch()) and eval_expr(stripped_line[5:].strip()))
            continue

        #else
        elif stripped_line.startswith("#else"):
            condition_stack[-1].append(not any(current_branch()))
            continue

        #endif
        elif stripped_line.startswith("#endif"):
            condition_stack.pop()
            continue

        if not skipping():
            if line.startswith("//:") or stripped_line != "":
                processed_lines.append(line)

    assert current_level() == 0, "Missing #endif"

    return "\n".join(processed_lines)
