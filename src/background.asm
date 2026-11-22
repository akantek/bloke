background:
; Wipe CHGMOD's default 0..255 Name Table to tile 0 (_blank_pattern)
  call clear_screen2

di

  ; --- Draw Rows 16 to 22 ---
  ld a, TILE_BACKGROUND1_A
  ld hl, $1A00              ; Row 16
  ld b, 32
  call draw_tile_row

  ld a, TILE_BACKGROUND2_A
  ld hl, $1A20              ; Row 17
  ld b, 32
  call draw_tile_row

  ld a, TILE_BACKGROUND3_A
  ld hl, $1A40              ; Row 18
  ld b, 32
  call draw_tile_row

  ld a, TILE_BACKGROUND4_A
  ld hl, $1A60              ; Row 19
  ld b, 32
  call draw_tile_row

  ld a, TILE_BACKGROUND5_A
  ld hl, $1A80              ; Row 20
  ld b, 32
  call draw_tile_row

  ld a, TILE_BACKGROUND6_A
  ld hl, $1AA0              ; Row 21
  ld b, 32
  call draw_tile_row

  ld a, TILE_BACKGROUND7_A
  ld hl, $1AC0              ; Row 22
  ld b, 32
  call draw_tile_row

  ; --- Paint Colors in Bank 2 (Yellow on Black) ---
  ld a, $A1
  ld hl, VRAM_SCR2_COLOR_BOT + (TILE_BACKGROUND1_A * 8)
  ld b, 8
  call draw_tile_row

  ld a, $A1
  ld hl, VRAM_SCR2_COLOR_BOT + (TILE_BACKGROUND2_A * 8)
  ld b, 8
  call draw_tile_row

  ld a, $A1
  ld hl, VRAM_SCR2_COLOR_BOT + (TILE_BACKGROUND3_A * 8)
  ld b, 8
  call draw_tile_row

  ld a, $A1
  ld hl, VRAM_SCR2_COLOR_BOT + (TILE_BACKGROUND4_A * 8)
  ld b, 8
  call draw_tile_row

  ld a, $A1
  ld hl, VRAM_SCR2_COLOR_BOT + (TILE_BACKGROUND5_A * 8)
  ld b, 8
  call draw_tile_row

  ld a, $A1
  ld hl, VRAM_SCR2_COLOR_BOT + (TILE_BACKGROUND6_A * 8)
  ld b, 8
  call draw_tile_row

  ld a, $A1
  ld hl, VRAM_SCR2_COLOR_BOT + (TILE_BACKGROUND7_A * 8)
  ld b, 8
  call draw_tile_row

  ei

loop_background:
  jp loop_background

