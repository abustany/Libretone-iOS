#!/usr/bin/env python3

import json
import os
import subprocess
import sys

INKSCAPE_PATH = "/Applications/Inkscape.app/Contents/MacOS/inkscape"

def icon_path(iconset_path, size):
    return os.path.join(iconset_path, 'icon-%d.png' % size)

def main():
    if len(sys.argv) != 3:
        print("Usage: %s ICONSET_FILE.appiconset ICON.svg" % sys.argv[0])
        sys.exit(1)

    [iconset_path, source_icon_path] = sys.argv[1:]

    if not os.path.isdir(iconset_path):
        print("%s is not a directory" % iconset_path)
        sys.exit(1)

    contents_json_path = os.path.join(iconset_path, 'Contents.json')

    with open(contents_json_path) as fd:
        contents = json.load(fd)

    converted_sizes = set()

    for (i, icon) in enumerate(contents['images']):
        scale = icon['scale']
        if not scale.endswith('x'):
            raise Exception('invalid scale: ' + scale)

        scale = int(scale[:len(scale)-1])

        [w, h] = [float(x) for x in icon['size'].split('x')]
        w = int(w * scale)
        h = int(h * scale)

        if w != h:
            raise Exception('width and height are not equal (%d != %d)' % (w, h))

        resized_icon_path = icon_path(iconset_path, w)

        if w not in converted_sizes:
            print('Generating %s...' % resized_icon_path)
            subprocess.check_call([INKSCAPE_PATH, '--export-area-page', '-w', str(w), '-h', str(h), '-o', resized_icon_path, source_icon_path])
            converted_sizes.add(w)

        contents['images'][i]['filename'] = os.path.basename(resized_icon_path)

    with open(contents_json_path, 'w') as fd:
        print('Writing %s' % contents_json_path)
        json.dump(contents, fd, indent='  ')


if __name__ == '__main__':
    main()
