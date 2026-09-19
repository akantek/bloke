intro:
  ; Initialize intro

  ; Set the colors for tile 0 (Pattern Color Table at $2000)
  ld hl, tile0_color
  ld de, $2000
  call ldirvm_8

  ; Set the tile pattern for tile 0 (Pattern Generator Table at $0000)
  ld hl, tile0_pattern 
  ld de, $0000          
  call ldirvm_8

  ; Set the tile name for screen position 0 (Pattern Name Table at $1800)
  ld hl, $1800        ; Target VRAM address: Start of Name Table (Top-left of the screen)
  ld a, 0             ; The ID of the tile to draw (tile 0)
  call WRTVRM         ; Call BIOS to write the single byte in A to VRAM address in HL

  ei
.loop:
  call wait_vsync        ; Spin until vblank is fired
.vblank_trace_start:
.vblank_trace_end:
  jp .loop

