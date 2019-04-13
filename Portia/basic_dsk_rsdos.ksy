meta:
  id: basic_dsk_rsdos
  file-extension: dsk
  title: RS-DOS filesystem wrapped in a basic array of sectors disk image
  license: CC0-1.0
  endian: be
  xref: Radio Shack TRS-80 Color Computer Disk System Owners Manual & Programmer guide, p58-59
seq:
  - id: granules1
    size: 9 * 256
    type: granule
    repeat: expr
    repeat-expr: 17 * 2
  - id: reserved1
    size: 256
  - id: fat
    size: 256
    type: file_allocation_table
  - id: files
    type: file
    repeat: expr
    repeat-expr: 72
  - id: reserved2
    size: (9 * 256) - files.size * 32 + (7 * 256)
  - id: granules2
    size: 9 * 256
    type: granule
    repeat: eos
enums:
  file_type:
    0: basic_program
    1: basic_data_file
    2: machine_language_program
    3: text_editor_source_file
  ascii_flag:
    0: binary
    0xff: ascii
types:
  granule:
    seq:
      - id: bytes
        size: 9 * 256
  file_allocation_table:
    seq:
      - id: table
        type: u1
        repeat: expr
        repeat-expr: 68
      - id: reserved
        size: 188
  file:
    seq:
      - id: name
        size: 8
        type: strz
        pad-right: 32
        terminator: 32
        consume: false
        encoding: ASCII
      - id: extension
        size: 3
        type: strz
        pad-right: 32
        terminator: 32
        consume: false
        encoding: ASCII
      - id: file_type
        type: u1
        enum: file_type
      - id: ascii_flag
        type: u1
        enum: ascii_flag
      - id: ofs_granule
        type: granule_ptr
      - id: bytes_in_last_sector
        type: u2
      - id: reserved
        size: 16
  granule_ptr:
    seq:
      - id: current_ptr
        type: u1
    instances:
      body:
        io: "current_ptr < 34 ? _root.granules1[current_ptr]._io : _root.granules2[current_ptr-34]._io"
        pos: 0
        size: "(_root.fat.table[current_ptr] & 0xc0) == 0 ? 9 * 256 : (((_root.fat.table[current_ptr] & 0x3f) - 1) * 256) + _parent.bytes_in_last_sector"
        if: current_ptr < 68
      next:
        io: _root.fat._io
        pos: current_ptr
        type: granule_ptr
        parent: _parent
        if: current_ptr < 68
