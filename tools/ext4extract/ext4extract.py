#!/usr/bin/env python3

"""
    ext4extract - Ext4 data extracting tool
    Copyright (C) 2017, HexEdit (IFProject)

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

import sys
from app import Application


def exception_handler(exception_type, exception, traceback):
    del traceback
    sys.stderr.write("{}: {}\n".format(exception_type.__name__, exception))


if __name__ == '__main__':
    sys.excepthook = exception_handler
    Application().run()
