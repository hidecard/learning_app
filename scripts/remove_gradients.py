from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def matching_close(text: str, opening: int) -> int:
    depth = 0
    in_string = None
    escaped = False
    for i in range(opening, len(text)):
        ch = text[i]
        if in_string:
            if escaped:
                escaped = False
            elif ch == '\\':
                escaped = True
            elif ch == in_string:
                in_string = None
            continue
        if ch in "'\"":
            in_string = ch
        elif ch == '(':
            depth += 1
        elif ch == ')':
            depth -= 1
            if depth == 0:
                return i
    raise ValueError('Unclosed LinearGradient')

for path in (ROOT / 'lib').rglob('*.dart'):
    text = path.read_text()
    out = []
    cursor = 0
    changed = False
    needle = 'gradient: LinearGradient('
    while True:
        start = text.find(needle, cursor)
        if start < 0:
            out.append(text[cursor:])
            break
        out.append(text[cursor:start])
        close = matching_close(text, start + len('gradient: '))
        # A solid blue is intentionally used in place of decorative gradients.
        out.append('color: const Color(0xFF2F6FED)')
        cursor = close + 1
        changed = True
    if changed:
        path.write_text(''.join(out))
        print(path.relative_to(ROOT))
