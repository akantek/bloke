include "header.asm"

org $8000

header:
  db "AB"
  dw main
  dw 0, 0, 0
  dw 0, 0, 0

include "main.asm"
include "assets.asm"
include "intro.asm"
include "intro_map.asm"
include "stage1.asm"
include "demo.asm"
include "ram.asm"
include "constants.asm"
include "fx.asm"
include "vblank.asm"
include "vdp.asm"
include "psg.asm"
include "keypad.asm"
include "maps.asm"
include "tilesheet.asm"
include "spritesheet.asm"

  ds $c000 - $, 0

