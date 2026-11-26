BG_TICK_DELAY: equ 30         ; Advance every 30 ticks (0.5s at 60 Hz)

; ==============================================================================
; background.asm - Animated bottom-third background (rows 16..22, Bank 2)
; Cycles frames A..H (0..7) at 60 Hz using frame_count from the VBlank ISR.
; ==============================================================================

background_init:
xor a
  ld (bg_frame), a            ; Start at frame 0 (_A)

  ; Wipe CHGMOD's default 0..255 Name Table to tile 0 (_blank_pattern)
  ; Note: clear_screen2 ends with ei
  call clear_screen2

  ; --- Paint Colors in Bank 2 (Yellow on Black) for all 56 bg tiles (1_A..7_H) ---
  di

  ld a, $A1
  ld hl, VRAM_SCR2_COLOR_BOT + (TILE_BACKGROUND1_A * 8)
  ld b, 0                     ; 256 bytes (32 tiles: 1_A..4_H)
  call draw_tile_row

  ld a, $A1
  ld hl, VRAM_SCR2_COLOR_BOT + (TILE_BACKGROUND1_A * 8) + 256
  ld b, 192                   ; 192 bytes (24 tiles: 5_A..7_H)
  call draw_tile_row

  ei                          ; Leave interrupts enabled for wait_vsync
  ret


background:
  call background_init

.background_loop:
  call wait_vsync             ; Spin until 60 Hz VBlank fires
.background_trace_start:
ld hl, bg_timer
  dec (hl)                    ; Count down 30 -> 0
  jr nz, .background_trace_end

  ; 30 ticks elapsed: reload timer and advance frame (0..7)
  ld (hl), BG_TICK_DELAY

  ld a, (bg_frame)
  inc a
  and $07                     ; 0 = _A .. 7 = _H (wraps automatically)
  ld (bg_frame), a



  call draw_background_frame
.background_trace_end:
  jp .background_loop


; ==============================================================================
; draw_background_frame
; Draws rows 16..22 ($1A00..$1AC0) for a given animation frame.
; Input:  A = frame index (0 = _A, 1 = _B, ..., 7 = _H)
; ==============================================================================
draw_background_frame:
  add a, TILE_BACKGROUND1_A   ; Start at row 16's tile ID for this frame
  ld hl, $1A00                ; Row 16 VRAM Name Table address
  ld c, 7                     ; 7 rows (rows 16..22)

.row_loop:
  push af
  push bc                     ; Preserve row counter C in case draw_tile_row uses it
  push hl
  ld b, 32
  call draw_tile_row
  pop hl
  pop bc
  ld de, 32
  add hl, de                  ; Advance to next row (+32 bytes)
  pop af
  add a, 8                    ; Advance to next background group (+8 tile IDs)
  dec c
  jr nz, .row_loop

  ret

