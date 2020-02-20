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


class DirEntry:
    def __init__(self, inode=0, name=None, entry_type=0):
        self._inode = inode
        self._name = name
        self._type = entry_type

    def __str__(self):
        entry_type = [
            "Unknown",
            "Regular file",
            "Directory",
            "Character device file",
            "Block device file",
            "FIFO",
            "Socket",
            "Symbolic link"
        ][self._type]
        return "{name:24} ({type}, inode {inode})".format(inode=self._inode, name=self._name, type=entry_type)

    @property
    def inode(self):
        return self._inode

    @property
    def name(self):
        return self._name

    @property
    def type(self):
        return self._type

    @inode.setter
    def inode(self, x):
        self._inode = x

    @name.setter
    def name(self, x):
        self._name = x

    @type.setter
    def type(self, x):
        self._type = x
