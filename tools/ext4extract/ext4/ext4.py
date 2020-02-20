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

from .structs import *
from .direntry import DirEntry


class Ext4(object):
    def __init__(self, filename=None):
        self._ext4 = None
        self._superblock = None
        self._block_size = 1024

        if filename is not None:
            self.load(filename)

    def __str__(self):
        if self._superblock is None:
            return "Not loaded"
        else:
            volume_name = self._superblock.s_volume_name.decode('utf-8').rstrip('\0')
            mounted_at = self._superblock.s_last_mounted.decode('utf-8').rstrip('\0')
            if not mounted_at:
                mounted_at = "not mounted"
            return "Volume name: {}, last mounted at: {}".format(volume_name, mounted_at)

    def _read_group_descriptor(self, bg_num):
        gd_offset = (self._superblock.s_first_data_block + 1) * self._block_size \
                    + (bg_num * self._superblock.s_desc_size)
        self._ext4.seek(gd_offset)
        return make_group_descriptor(self._ext4.read(32))

    def _read_inode(self, inode_num):
        inode_bg_num = (inode_num - 1) // self._superblock.s_inodes_per_group
        bg_inode_idx = (inode_num - 1) % self._superblock.s_inodes_per_group
        group_desc = self._read_group_descriptor(inode_bg_num)
        inode_offset = \
            (group_desc.bg_inode_table_lo * self._block_size) \
            + (bg_inode_idx * self._superblock.s_inode_size)
        self._ext4.seek(inode_offset)
        return make_inode(self._ext4.read(128))

    def _read_extent(self, data, extent_block):
        hdr = make_extent_header(extent_block[:12])
        if hdr.eh_magic != 0xf30a:
            raise RuntimeError("Bad extent magic")

        for eex in range(0, hdr.eh_entries):
            raw_offset = 12 + (eex * 12)
            entry_raw = extent_block[raw_offset:raw_offset + 12]
            if hdr.eh_depth == 0:
                entry = make_extent_entry(entry_raw)
                _start = entry.ee_block * self._block_size
                _size = entry.ee_len * self._block_size
                self._ext4.seek(entry.ee_start_lo * self._block_size)
                data[_start:_start + _size] = self._ext4.read(_size)
            else:
                index = make_extent_index(entry_raw)
                self._ext4.seek(index.ei_leaf_lo * self._block_size)
                lower_block = self._ext4.read(self._block_size)
                self._read_extent(data, lower_block)

    def _read_data(self, inode):
        data = b''

        if inode.i_size_lo == 0:
            pass
        elif inode.i_flags & 0x10000000 or (inode.i_mode & 0xf000 == 0xa000 and inode.i_size_lo <= 60):
            data = inode.i_block
        elif inode.i_flags & 0x80000:
            data = bytearray(inode.i_size_lo)
            self._read_extent(data, inode.i_block)
        else:
            raise RuntimeError("Mapped Inodes are not supported")

        return data

    def load(self, filename):
        self._ext4 = open(filename, "rb")
        self._ext4.seek(1024)
        self._superblock = make_superblock(self._ext4.read(256))
        if self._superblock.s_magic != 0xef53:
            raise RuntimeError("Bad superblock magic")
        incompat = self._superblock.s_feature_incompat
        for f_id in [0x1, 0x4, 0x10, 0x80, 0x1000, 0x4000, 0x10000]:
            if incompat & f_id:
                raise RuntimeError("Unsupported feature ({:#x})".format(f_id))
        self._block_size = 2 ** (10 + self._superblock.s_log_block_size)

    def read_dir(self, inode_num):
        inode = self._read_inode(inode_num)
        dir_raw = self._read_data(inode)
        dir_data = list()
        offset = 0
        while offset < len(dir_raw):
            entry_raw = dir_raw[offset:offset + 8]
            entry = DirEntry()
            if self._superblock.s_feature_incompat & 0x2:
                dir_entry = make_dir_entry_v2(entry_raw)
                entry.type = dir_entry.file_type
            else:
                dir_entry = make_dir_entry(entry_raw)
                entry_inode = self._read_inode(dir_entry.inode)
                inode_type = entry_inode.i_mode & 0xf000
                if inode_type == 0x1000:
                    entry.type = 5
                elif inode_type == 0x2000:
                    entry.type = 3
                elif inode_type == 0x4000:
                    entry.type = 2
                elif inode_type == 0x6000:
                    entry.type = 4
                elif inode_type == 0x8000:
                    entry.type = 1
                elif inode_type == 0xA000:
                    entry.type = 7
                elif inode_type == 0xC000:
                    entry.type = 6
            entry.inode = dir_entry.inode
            entry.name = dir_raw[offset + 8:offset + 8 + dir_entry.name_len].decode('utf-8')
            dir_data.append(entry)
            offset += dir_entry.rec_len
        return dir_data

    def read_file(self, inode_num):
        inode = self._read_inode(inode_num)
        return self._read_data(inode)[:inode.i_size_lo], inode.i_atime, inode.i_mtime

    def read_link(self, inode_num):
        inode = self._read_inode(inode_num)
        return self._read_data(inode)[:inode.i_size_lo].decode('utf-8')

    @property
    def root(self):
        return self.read_dir(2)
