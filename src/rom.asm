include "header.asm"

org $8000

header:
  db "AB"
  dw main
  dw 0, 0, 0
  dw 0, 0, 0

include "main.asm"
include "intro.asm"
include "ram.asm"
include "constants.asm"
include "vblank.asm"
include "vdp.asm"
include "tilesheet.asm"

  ds $c000 - $, 0

