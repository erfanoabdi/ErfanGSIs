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

from collections import namedtuple
from struct import unpack


__SUPERBLOCK_PACK__ = "<IIIIIIIIIIIIIHHHHHHIIIIHHIHHIII16s16s64sIBBH16sIII16sBBH"
__GROUP_DESCRIPTOR_PACK__ = "<IIIHHHHIHHHH"
__INODE_PACK__ = "<HHIIIIIHHII4s60sIIII12s"
__EXTENT_HEADER_PACK__ = "<HHHHI"
__EXTENT_INDEX_PACK__ = "<IIHH"
__EXTENT_ENTRY_PACK__ = "<IHHI"
__DIR_ENTRY_PACK__ = "<IHH"
__DIR_ENTRY_V2_PACK__ = "<IHBB"

__SuperBlock__ = namedtuple('Ext4SuperBlock', """
    s_inodes_count
    s_blocks_count_lo
    s_r_blocks_count_lo
    s_free_blocks_count_lo
    s_free_inodes_count
    s_first_data_block
    s_log_block_size
    s_log_cluster_size
    s_blocks_per_group
    s_clusters_per_group
    s_inodes_per_group
    s_mtime
    s_wtime
    s_mnt_count
    s_max_mnt_count
    s_magic
    s_state
    s_errors
    s_minor_rev_level
    s_lastcheck
    s_checkinterval
    s_creator_os
    s_rev_level
    s_def_resuid
    s_def_resgid
    s_first_ino
    s_inode_size
    s_block_group_nr
    s_feature_compat
    s_feature_incompat
    s_feature_ro_compat
    s_uuid
    s_volume_name
    s_last_mounted
    s_algorithm_usage_bitmap
    s_prealloc_blocks
    s_prealloc_dir_blocks
    s_reserved_gdt_blocks
    s_journal_uuid
    s_journal_inum
    s_journal_dev
    s_last_orphan
    s_hash_seed
    s_def_hash_version
    s_jnl_backup_type
    s_desc_size
""")

__GroupDescriptor__ = namedtuple('Ext4GroupDescriptor', """
    bg_block_bitmap_lo
    bg_inode_bitmap_lo
    bg_inode_table_lo
    bg_free_blocks_count_lo
    bg_free_inodes_count_lo
    bg_used_dirs_count_lo
    bg_flags
    bg_exclude_bitmap_lo
    bg_block_bitmap_csum_lo
    bg_inode_bitmap_csum_lo
    bg_itable_unused_lo
    bg_checksum
""")

__Inode__ = namedtuple('Ext4Inode', """
    i_mode
    i_uid
    i_size_lo
    i_atime
    i_ctime
    i_mtime
    i_dtime
    i_gid
    i_links_count
    i_blocks_lo
    i_flags
    i_osd1
    i_block
    i_generation
    i_file_acl_lo
    i_size_high
    i_obso_faddr
    i_osd2
""")

__ExtentHeader__ = namedtuple('Ext4ExtentHeader', """
    eh_magic
    eh_entries
    eh_max
    eh_depth
    eh_generation
""")

__ExtentIndex__ = namedtuple('Ext4ExtentIndex', """
    ei_block
    ei_leaf_lo
    ei_leaf_hi
    ei_unused
""")

__ExtentEntry__ = namedtuple('Ext4ExtentEntry', """
    ee_block
    ee_len
    ee_start_hi
    ee_start_lo
""")

__DirEntry__ = namedtuple('Ext4DirEntry', """
    inode
    rec_len
    name_len
""")

__DirEntryV2__ = namedtuple('Ext4DirEntryV2', """
    inode
    rec_len
    name_len
    file_type
""")


def make_superblock(data):
    return __SuperBlock__._make(unpack(__SUPERBLOCK_PACK__, data))


def make_group_descriptor(data):
    return __GroupDescriptor__._make(unpack(__GROUP_DESCRIPTOR_PACK__, data))


def make_inode(data):
    return __Inode__._make(unpack(__INODE_PACK__, data))


def make_extent_header(data):
    return __ExtentHeader__._make(unpack(__EXTENT_HEADER_PACK__, data))


def make_extent_index(data):
    return __ExtentIndex__._make(unpack(__EXTENT_INDEX_PACK__, data))


def make_extent_entry(data):
    return __ExtentEntry__._make(unpack(__EXTENT_ENTRY_PACK__, data))


def make_dir_entry(data):
    return __DirEntry__._make(unpack(__DIR_ENTRY_PACK__, data))


def make_dir_entry_v2(data):
    return __DirEntryV2__._make(unpack(__DIR_ENTRY_V2_PACK__, data))
