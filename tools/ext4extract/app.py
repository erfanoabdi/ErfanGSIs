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
import argparse
import os
from ext4 import Ext4


class Application(object):
    def __init__(self):
        self._args = None
        self._ext4 = None

    def _parse_args(self):
        parser = argparse.ArgumentParser()

        parser.add_argument("-v", "--verbose", dest='verbose', help="verbose output",
                            action='store_true')
        parser.add_argument("-D", "--directory", dest='directory', type=str, help="set output directory", default=".")
        parser.add_argument("filename", type=str, help="EXT4 device or image")

        group = parser.add_mutually_exclusive_group()
        group.add_argument("--save-symlinks", help="save symlinks as is (default)", action='store_true')
        group.add_argument("--text-symlinks", help="save symlinks as text file", action='store_true')
        group.add_argument("--empty-symlinks", help="save symlinks as empty file", action='store_true')
        group.add_argument("--skip-symlinks", help="do not save symlinks", action='store_true')

        try:
            self._args = parser.parse_args()
        except SystemExit:
            sys.exit(2)

    def _extract_dir(self, dir_data, path, name=None):
        assert self._ext4 is not None
        if name is not None:
            path = os.path.join(path, name)
        try:
            os.mkdir(path)
        except FileExistsError:
            pass

        for de in dir_data:
            processed = False
            if de.type == 1:  # regular file
                data, atime, mtime = self._ext4.read_file(de.inode)
                file = open(os.path.join(path, de.name), 'w+b')
                file.write(data)
                file.close()
                os.utime(file.name, (atime, mtime))
                processed = True
            elif de.type == 2:  # directory
                if de.name == '.' or de.name == '..':
                    continue
                self._extract_dir(self._ext4.read_dir(de.inode), path, de.name)
            elif de.type == 7:  # symlink
                if self._args.skip_symlinks:
                    continue
                link = os.path.join(path, de.name)
                link_to = self._ext4.read_link(de.inode)
                if self._args.text_symlinks:
                    link = open(link, "w+b")
                    link.write(link_to.encode('utf-8'))
                    link.close()
                elif self._args.empty_symlinks:
                    open(link, "w+").close()
                else:
                    os.symlink(link_to, link + ".tmp")
                    os.rename(link + ".tmp", link)
                processed = True
            if processed and self._args.verbose:
                print(os.path.join(os.path.sep, path.lstrip(self._args.directory), de.name))

    def _do_extract(self):
        self._ext4 = Ext4(self._args.filename)
        self._extract_dir(self._ext4.root, self._args.directory)

    def run(self):
        self._parse_args()
        self._do_extract()
