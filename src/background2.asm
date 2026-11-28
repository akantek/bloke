; ==============================================================================
; background.asm
;   - Bank 0 (rows 4..7) & Bank 1 (rows 8..15): Light Blue stars on Black
;   - Bank 2 (rows 18..23): Gray background with two evenly spaced scrolling
;     lines (Yellow and Green), advancing every 5 VBlank ticks (12 Hz at 60 Hz)
; ==============================================================================

; --- Scroll Timing & Geometry (Rows 18..23 in Bank 2) ---
BG_TICK_DELAY:       equ 5    ; Advance every 5 frames (12 Hz at 60 Hz)
BG_TOTAL_FRAMES:     equ 48   ; 6 rows (18..23) * 8 sub-frames
BG_LINE2_START:      equ 24   ; Half of 48-frame cycle (Row 21, _A)

BG_BANK0_NT_HI:      equ VRAM_SCR2_NAME_TABLE >> 8                   ; $18 (rows 0..7)
BG_BANK1_NT_HI:      equ (VRAM_SCR2_NAME_TABLE + $0100) >> 8         ; $19 (rows 8..15)
BG_BANK2_NT_HI:      equ (VRAM_SCR2_NAME_TABLE + $0200) >> 8         ; $1A (rows 16..23)

BG_START_ROW_VRAM:   equ VRAM_SCR2_NAME_TABLE + (18 * 32)            ; $1A40 (Row 18)
BG_START_ROW_LO:     equ BG_START_ROW_VRAM & $FF                     ; $40
BG_END_ROW_LO:       equ (VRAM_SCR2_NAME_TABLE + (23 * 32)) & $FF    ; $E0 (Row 23)

; --- Tile & Packed Color Constants (High Nibble = FG, Low Nibble = BG) ---
BG_GREEN_TILE_BASE:  equ 248  ; 8 cloned Bank 2 tile IDs (248..255) for green line

BG_COLOR_YELLOW:     equ (YELLOW << 4) | GRAY        ; $AE - Yellow on Gray
BG_COLOR_GREEN:      equ (GREEN << 4) | GRAY         ; $CE - Green on Gray (or DARK_GREEN for $2E)
STAR_COLOR:          equ (LIGHT_BLUE << 4) | BLACK   ; $71 - Light Blue on Black (or CYAN for $51)

; Expected RAM variables (defined in ram.asm):
; bg_timer:          equ $C000
; bg_frame1:         equ $C001
; bg_frame2:         equ $C002


background_init:
  ; Wipe CHGMOD's default 0..255 Name Table to tile 0 (_blank_pattern)
  ; Note: clear_screen2 ends with ei
  call clear_screen2

  di

  ; --- Draw Stars in Bank 0 (rows 4..7) and Bank 1 (rows 8..15) ---
  call draw_stars

  ; --- Copy BACKGROUND_LINE_A..H patterns (64 bytes) to tiles 248..255 in Bank 2 ---
  ; ld hl, tile_patterns + (TILE_BACKGROUND_LINE_A * 8)  ; Replace with your ROM pattern label
  ld hl, _background_line_a_pattern
  ld de, VRAM_SCR2_PATTERN_BOT + (BG_GREEN_TILE_BASE * 8)
  ld bc, 8 * 8                 ; 64 bytes (8 tiles)
  call write_vram_large

  ; --- Paint Yellow on Gray for SPACE + BACKGROUND_LINE_A..H (9 tiles = 72 bytes) ---
  ld a, BG_COLOR_YELLOW
  ld hl, VRAM_SCR2_COLOR_BOT + (TILE_SPACE * 8)
  ld b, 9 * 8                  ; 72 bytes
  call draw_tile_row

  ; --- Paint Green on Gray for cloned tiles 248..255 (8 tiles = 64 bytes) ---
  ld a, BG_COLOR_GREEN
  ld hl, VRAM_SCR2_COLOR_BOT + (BG_GREEN_TILE_BASE * 8)
  ld b, 8 * 8                  ; 64 bytes
  call draw_tile_row

  ; --- Fill rows 18..23 ($1A40..$1AFF) with TILE_SPACE so the region starts Gray ---
  ld a, TILE_SPACE
  ld hl, BG_START_ROW_VRAM
  ld b, 6 * 32                 ; 192 tiles (rows 18..23)
  call draw_tile_row

  ; --- Initialize timer and both independent line counters ---
  ld a, BG_TICK_DELAY
  ld (bg_timer), a

  xor a                        ; Line 1 (Yellow) = frame 0 (Row 18)
  ld (bg_frame1), a
  ld d, TILE_BACKGROUND_LINE_A
  call draw_line_frame

  ld a, BG_LINE2_START         ; Line 2 (Green) = frame 24 (Row 21)
  ld (bg_frame2), a
  ld d, BG_GREEN_TILE_BASE
  call draw_line_frame

  ei                           ; Leave interrupts enabled for wait_vsync
  ret


background:
  call background_init

.background_loop:
  call wait_vsync              ; Spin until 60 Hz VBlank fires
.background_trace_start:
  ld hl, bg_timer
  dec (hl)                     ; Count down BG_TICK_DELAY -> 0
  jr nz, .background_trace_end

  ; Reload timer and advance both independent lines (0..47)
  ld (hl), BG_TICK_DELAY

  ld hl, bg_frame1
  call advance_line_frame

  ld hl, bg_frame2
  call advance_line_frame

  di                           ; Protect VDP address latch during VRAM writes
  ld a, (bg_frame1)
  ld d, TILE_BACKGROUND_LINE_A ; Yellow line
  call draw_line_frame

  ld a, (bg_frame2)
  ld d, BG_GREEN_TILE_BASE     ; Green line
  call draw_line_frame
  ei                           ; Re-enable interrupts for the next wait_vsync
.background_trace_end:
  jp .background_loop


; ==============================================================================
; draw_stars
; Loads/colors TILE_STARS_0 in Bank 0 and Bank 1, then plots stars in rows 4..15.
; Call with DI.
; ==============================================================================
draw_stars:
  ; --- 1. Upload pattern to Bank 0 and Bank 1 ---
  ld hl, _star_0_pattern
  ld de, VRAM_SCR2_PATTERN_TOP + (TILE_STARS_0 * 8)
  ld bc, 8
  call write_vram_large

  ld hl, _star_0_pattern
  ld de, VRAM_SCR2_PATTERN_MID + (TILE_STARS_0 * 8)
  ld bc, 8
  call write_vram_large

  ; --- 2. Paint TILE_STARS_0 Light Blue on Black in Bank 0 and Bank 1 ---
  ld a, STAR_COLOR
  ld hl, VRAM_SCR2_COLOR_TOP + (TILE_STARS_0 * 8)
  ld b, 8
  call draw_tile_row

  ld a, STAR_COLOR
  ld hl, VRAM_SCR2_COLOR_MID + (TILE_STARS_0 * 8)
  ld b, 8
  call draw_tile_row

  ; --- 3. Plot Bank 0 stars (rows 4..7, Name Table $18xx) ---
  ld hl, star_positions_top
  ld c, STAR_TOP_COUNT
  ld e, BG_BANK0_NT_HI
  call plot_star_bank

  ; --- 4. Plot Bank 1 stars (rows 8..15, Name Table $19xx) ---
  ld hl, star_positions_mid
  ld c, STAR_MID_COUNT
  ld e, BG_BANK1_NT_HI
  ; Fall through into plot_star_bank


; ==============================================================================
; plot_star_bank
; Plots C stars from table (HL) into the Name Table page specified in E.
; Inputs: HL = pointer to 1-byte offset table
;         C  = star count (1..255)
;         E  = Name Table high byte (BG_BANK0_NT_HI or BG_BANK1_NT_HI)
; ==============================================================================
plot_star_bank:
.star_loop:
  push hl                      ; Save table pointer
  ld l, (hl)                   ; Low byte = star offset ($00..$FF)
  ld h, e                      ; High byte = Bank Name Table
  ld a, TILE_STARS_0
  ld b, 1
  call draw_tile_row           ; Destroys A, B, D (preserves C and E)
  pop hl                       ; Restore table pointer
  inc hl
  dec c
  jr nz, .star_loop
  ret


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
  xor a                        ; Wrap back to 0 (Row 18, _A)
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
  ld c, a                      ; Save full frame index (0..47)
  and $38                      ; Isolate row offset * 8 (bits 5..3 -> 0..40)
  add a, a                     ; * 16
  add a, a                     ; * 32 ($00, $20, $40, $60, $80, $A0)
  add a, BG_START_ROW_LO       ; Shift to rows 18..23 ($40, $60, $80, $A0, $C0, $E0)
  ld l, a
  ld h, BG_BANK2_NT_HI         ; HL = active row ($1A40..$1AE0)

  ; Compute sub-frame (0..7)
  ld a, c
  and $07
  push af                      ; Save sub-frame for transition check
  push hl                      ; Save active row address

  ; Draw active row with base tile ID + sub-frame (_A.._H)
  add a, d
  ld b, 32
  call draw_tile_row

  ; Only clear the previous row when entering a new row (sub-frame == 0)
  pop hl                       ; Restore active row address
  pop af                       ; Restore sub-frame (0..7)
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
; Star Position Tables
; ==============================================================================

; Bank 0 (Top - bottom half only): rows 4..7 -> $1880..$18FF
star_positions_top:
  defb (4 * 32) + 3            ; Row 4, Col 3
  defb (4 * 32) + 15           ; Row 4, Col 15
  defb (4 * 32) + 26           ; Row 4, Col 26
  defb (5 * 32) + 9            ; Row 5, Col 9
  defb (5 * 32) + 21           ; Row 5, Col 21
  defb (6 * 32) + 4            ; Row 6, Col 4
  defb (6 * 32) + 14           ; Row 6, Col 14
  defb (6 * 32) + 29           ; Row 6, Col 29
  defb (7 * 32) + 11           ; Row 7, Col 11
  defb (7 * 32) + 23           ; Row 7, Col 23
STAR_TOP_COUNT: equ $ - star_positions_top

; Bank 1 (Middle): rows 8..15 -> $1900..$19FF
star_positions_mid:
  defb (0 * 32) + 5            ; Row 8,  Col 5
  defb (0 * 32) + 19           ; Row 8,  Col 19
  defb (0 * 32) + 28           ; Row 8,  Col 28
  defb (1 * 32) + 2            ; Row 9,  Col 2
  defb (1 * 32) + 13           ; Row 9,  Col 13
  defb (1 * 32) + 22           ; Row 9,  Col 22
  defb (2 * 32) + 8            ; Row 10, Col 8
  defb (2 * 32) + 24           ; Row 10, Col 24
  defb (3 * 32) + 1            ; Row 11, Col 1
  defb (3 * 32) + 11           ; Row 11, Col 11
  defb (3 * 32) + 30           ; Row 11, Col 30
  defb (4 * 32) + 6            ; Row 12, Col 6
  defb (4 * 32) + 16           ; Row 12, Col 16 (center)
  defb (4 * 32) + 27           ; Row 12, Col 27
  defb (5 * 32) + 13           ; Row 13, Col 13
  defb (5 * 32) + 21           ; Row 13, Col 21
  defb (6 * 32) + 4            ; Row 14, Col 4
  defb (6 * 32) + 10           ; Row 14, Col 10
  defb (7 * 32) + 18           ; Row 15, Col 18
  defb (7 * 32) + 29           ; Row 15, Col 29
STAR_MID_COUNT: equ $ - star_positions_mid
