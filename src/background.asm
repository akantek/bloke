; ==============================================================================
; background.asm - Two independent, evenly spaced lines across rows 18..23 (Bank 2)
; Gray background across rows 18..23; rows 0..17 stay black (tile 0).
; Cycles 48 frames (0..47) every 5 VBlank ticks (12 Hz at 60 Hz):
;   Bits 5..3 = row offset (0..5 -> rows 18..23, $1A40..$1AE0)
;   Bits 2..0 = line tile  (0..7 -> _A.._H)
;   Line 1 (Yellow): starts at frame 0  (Row 18, $1A40), uses
;       TILE_BACKGROUND_LINE_A..H
;   Line 2 (Green):  starts at frame 24 (Row 21, $1AA0), uses
;       cloned tiles 248..255
; ==============================================================================

BG_TICK_DELAY:       equ 5    ; Advance every 5 frames (12 Hz at 60 Hz)
BG_START_ROW_LO:     equ $40  ; Row 18 VRAM low byte ($1A40)
BG_END_ROW_LO:       equ $E0  ; Row 23 VRAM low byte ($1AE0)
BG_TOTAL_FRAMES:     equ 48   ; 6 rows (18..23) * 8 sub-frames
BG_LINE2_START:      equ 24   ; Half of 48-frame cycle (Row 21, _A)

BG_COLOR_YELLOW:     equ $AE  ; Dark Yellow on Gray ($BE = Light Yellow on Gray)
BG_COLOR_GREEN:      equ $2E  ; Medium Green on Gray ($CE = Dark Green on Gray)
BG_GREEN_TILE_BASE:  equ 248  ; 8 cloned Bank 2 tile IDs (248..255) for green line
BG_PATT_BOT:         equ VRAM_SCR2_COLOR_BOT - $2000  ; Bank 2 Pattern Table ($1000)

; Expected RAM variables (already defined in ram.asm):
; bg_timer:          equ $C000
; bg_frame1:         equ $C001
; bg_frame2:         equ $C002


background_init:
  ; Wipe CHGMOD's default 0..255 Name Table to tile 0 (_blank_pattern)
  ; Note: clear_screen2 ends with ei
  call clear_screen2

  di

  ; --- Clone BACKGROUND_LINE_A..H patterns (64 bytes) to tiles
  ;         248..255 in Bank 2 ---
  ld hl, BG_PATT_BOT + (TILE_BACKGROUND_LINE_A * 8)
  ld de, BG_PATT_BOT + (BG_GREEN_TILE_BASE * 8)
  ld b, 8 * 8                 ; 64 bytes (8 tiles)
  call copy_vram_bytes

  ; --- Paint Yellow on Gray for SPACE
  ;         + BACKGROUND_LINE_A..H (9 tiles = 72 bytes) ---
  ld a, BG_COLOR_YELLOW
  ld hl, VRAM_SCR2_COLOR_BOT + (TILE_SPACE * 8)
  ld b, 9 * 8                 ; 72 bytes
  call draw_tile_row

  ; --- Paint Green on Gray for cloned tiles 248..255 (8 tiles = 64 bytes) ---
  ld a, BG_COLOR_GREEN
  ld hl, VRAM_SCR2_COLOR_BOT + (BG_GREEN_TILE_BASE * 8)
  ld b, 8 * 8                 ; 64 bytes
  call draw_tile_row

  ; --- Fill rows 18..23 ($1A40..$1AFF) with TILE_SPACE so the region starts Gray ---
  ld a, TILE_SPACE
  ld hl, $1A40                ; Row 18 VRAM Name Table address
  ld b, 6 * 32                ; 192 tiles (rows 18..23)
  call draw_tile_row

  ; --- Initialize timer and both independent line counters ---
  ld a, BG_TICK_DELAY
  ld (bg_timer), a

  xor a                       ; Line 1 (Yellow) = frame 0 (Row 18)
  ld (bg_frame1), a
  ld d, TILE_BACKGROUND_LINE_A
  call draw_line_frame

  ld a, BG_LINE2_START        ; Line 2 (Green) = frame 24 (Row 21)
  ld (bg_frame2), a
  ld d, BG_GREEN_TILE_BASE
  call draw_line_frame

  ei                          ; Leave interrupts enabled for wait_vsync
  ret


background:
  call background_init
  call draw_stars

.background_loop:
  call wait_vsync             ; Spin until 60 Hz VBlank fires
.background_trace_start:
  ld hl, bg_timer
  dec (hl)                    ; Count down BG_TICK_DELAY -> 0
  jr nz, .background_trace_end

  ; Reload timer and advance both independent lines (0..47)
  ld (hl), BG_TICK_DELAY

  ld hl, bg_frame1
  call advance_line_frame

  ld hl, bg_frame2
  call advance_line_frame

  di                          ; Protect VDP address latch during VRAM writes
  ld a, (bg_frame1)
  ld d, TILE_BACKGROUND_LINE_A    ; Yellow line
  call draw_line_frame

  ld a, (bg_frame2)
  ld d, BG_GREEN_TILE_BASE    ; Green line
  call draw_line_frame
  ei                          ; Re-enable interrupts for the next wait_vsync
.background_trace_end:
  jp .background_loop


; ==============================================================================
; advance_line_frame
; Increments a line counter at (HL) and wraps 48 -> 0.
; Input:  HL = pointer to line frame variable (bg_frame1 or bg_frame2)
; ==============================================================================
advance_line_frame:
  ld a, (hl)
  inc a
  cp BG_TOTAL_FRAMES
  jr c, .advance_store
  xor a                       ; Wrap back to 0 (Row 18, _A)
.advance_store:
  ld (hl), a
  ret


; ==============================================================================
; draw_line_frame
; Draws a line on its active row (18..23) using base tile ID in D, and clears
; the previous row with TILE_SPACE whenever the line enters a new row.
; Input:  A = frame index (0..47)
;         D = base tile ID (TILE_BACKGROUND_LINE_A or BG_GREEN_TILE_BASE)
; ==============================================================================
draw_line_frame:
  ; Compute active row VRAM address: $1A40 + ((frame & $38) << 2)
  ld c, a                     ; Save full frame index (0..47)
  and $38                     ; Isolate row offset * 8 (bits 5..3 -> 0..40)
  add a, a                    ; * 16
  add a, a                    ; * 32 ($00, $20, $40, $60, $80, $A0)
  add a, BG_START_ROW_LO      ; Shift to rows 18..23 ($40, $60, $80, $A0, $C0, $E0)
  ld l, a
  ld h, $1A                   ; HL = active row ($1A40..$1AE0)

  ; Compute sub-frame (0..7)
  ld a, c
  and $07
  push af                     ; Save sub-frame for transition check
  push hl                     ; Save active row address

  ; Draw active row with base tile ID + sub-frame (_A.._H)
  add a, d
  ld b, 32
  call draw_tile_row

  ; Only clear the previous row when entering a new row (sub-frame == 0)
  pop hl                      ; Restore active row address
  pop af                      ; Restore sub-frame (0..7)
  or a
  ret nz

  ; Previous row: Row 23 ($1AE0) if we just wrapped to Row 18 ($1A40), else L - $20
  ld a, l
  cp BG_START_ROW_LO
  jr nz, .prev_row
  ld l, BG_END_ROW_LO
  jr .clear_prev
.prev_row:
  sub $20
  ld l, a
.clear_prev:
  ld a, TILE_SPACE
  ld b, 32
  jp draw_tile_row


; ==============================================================================
; copy_vram_bytes
; Copies B bytes within VRAM from HL (source) to DE (destination).
; Respects TMS9918A active-display timing (>= 29 T-states). Call with DI.
; ==============================================================================
copy_vram_bytes:
.copy_loop:
  ; Set VRAM read address (HL)
  ld a, l
  out ($99), a
  ld a, h
  and $3F                     ; Bit 6 = 0 (VRAM read)
  out ($99), a
  inc hl                      ; 6 T + 20 T (nops) + 11 T (in) = 37 T-states
  nop
  nop
  nop
  nop
  nop
  in a, ($98)                 ; Read pattern byte
  ld c, a

  ; Set VRAM write address (DE)
  ld a, e
  out ($99), a
  ld a, d
  or $40                      ; Bit 6 = 1 (VRAM write)
  out ($99), a
  ld a, c
  out ($98), a                ; Write pattern byte

  inc de
  djnz .copy_loop
  ret
