#!/bin/sh
# -*- python -*-
''':'
unset PYTHONHOME PYTHONPATH
exec python3 "$0" "$@"
'exit'''

import sys


def main(argv):
    print(locals())
    pass


if __name__ == '__main__':
    main(sys.argv)
    pass
