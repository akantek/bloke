INIT_NUM_SPRITES: equ 1

NUM_SPRITES:  equ 1

sprite0_attributes_data:
  ;  Y,  X, Pat, Color
  db 150, 10,   0,   4

tile_colors_start:
_tile0_color:
  db $11, $11, $11, $11, $11, $11, $11, $11

_tile1_color:
  db $F4, $F4, $F4, $F4, $F4, $F4, $F4, $F4

tile2_color:
  db $F4, $F4, $F4, $F4, $F4, $F4, $F4, $F4
tile_colors_end:

