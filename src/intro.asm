INTRO_COLOR_WHITE:   equ (WHITE << 4) | BLACK   ; $F1 - White on Black
SCR2_COLOR_PAGES:    equ 24                     ; 3 banks * 2048 bytes / 256 bytes

intro:
  ; SCREEN OFF (Note: BIOS DISSCR enables interrupts internally)
  call DISSCR

  ; clear(SCREEN2) (Note: clear_screen2 ends with EI)
  call clear_screen2

  ; Disable interrupts before direct VDP writes
  di

  ; --- 1. Paint all 3 Color Banks ($2000..$37FF) White on Black ---
  ld hl, VRAM_SCR2_COLOR_TOP
  ld c, SCR2_COLOR_PAGES       ; 24 pages * 256 bytes = 6144 bytes
.paint_color_banks:
  ld a, INTRO_COLOR_WHITE
  ld b, 0                      ; B = 0 writes 256 bytes in draw_tile_row
  call draw_tile_row           ; Destroys A, B, D (preserves C and HL)
  inc h                        ; Next 256-byte page ($2000 -> $2100 ... -> $3700)
  dec c
  jr nz, .paint_color_banks

  ; --- 2. Init vars ---
  xor a
  ld (frame_count), a
  ld (intro_state), a
  ld (push_space_anim_frame), a

  ; --- 3. Load the intro screen Name Table ---
  ld hl, intro_map
  ld de, VRAM_SCR2_NAME_TABLE
  ld bc, SCR2_MAP_SIZE
  call write_vram_large

  ; SCREEN ON
  call ENASCR

  ei

.intro_loop:
  jr .intro_loop

