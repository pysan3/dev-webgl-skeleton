import sys
from pathlib import Path

if len(sys.argv) < 2:
    print('Usage: $ python outputFormatter.py <dirname>', file=sys.stderr)
    exit(1)

KEYPHRASE = r'/* harmony default export */ const __WEBPACK_DEFAULT_EXPORT__ = ("#version 300 es'


def main(filename: Path):
    if not filename.exists():
        print(f'Cannot find {filename}.', file=sys.stderr)
        return False
    output = []
    with filename.open('r') as f:
        lines = f.read().split('\n')
    for line in lines:
        if KEYPHRASE not in line:
            output.append(line)
        else:
            output.append(KEYPHRASE.replace('"', '`'))
            glsl = line[len(KEYPHRASE):-3].replace('\\n', '\n').replace('\\t', '\t')
            output.append(glsl + '\n')
            output.append('`);')
    with filename.open('w') as f:
        f.write('\n'.join(output))


if __name__ == "__main__":
    outDir = Path(sys.argv[1])
    main(outDir / 'index.html')
