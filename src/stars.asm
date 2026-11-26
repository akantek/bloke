STAR_COLOR:  equ (LIGHT_BLUE << 4) | BLACK   ; $51 (Light Blue star on Black bg)


; Bank 1 star offsets: ((row - 8) * 32) + col  (rows 8..15 -> $1900..$19FF)
star_positions:
  ; Row 8 ($1900..$191F)
  defb (0 * 32) + 5           ; Row 8,  Col 5  ($1905)
  defb (0 * 32) + 19          ; Row 8,  Col 19 ($1913)
  defb (0 * 32) + 28          ; Row 8,  Col 28 ($191C)

  ; Row 9 ($1920..$193F)
  defb (1 * 32) + 2           ; Row 9,  Col 2  ($1922)
  defb (1 * 32) + 13          ; Row 9,  Col 13 ($192D)
  defb (1 * 32) + 22          ; Row 9,  Col 22 ($1936)

  ; Row 10 ($1940..$195F)
  defb (2 * 32) + 8           ; Row 10, Col 8  ($1948)
  defb (2 * 32) + 24          ; Row 10, Col 24 ($1958)

  ; Row 11 ($1960..$197F)
  defb (3 * 32) + 1           ; Row 11, Col 1  ($1961)
  defb (3 * 32) + 11          ; Row 11, Col 11 ($196B)
  defb (3 * 32) + 30          ; Row 11, Col 30 ($197E)

  ; Row 12 ($1980..$199F)
  defb (4 * 32) + 6           ; Row 12, Col 6  ($1986)
  defb (4 * 32) + 16          ; Row 12, Col 16 ($1990) - center
  defb (4 * 32) + 27          ; Row 12, Col 27 ($199B)

  ; Row 13 ($19A0..$19BF)
  defb (5 * 32) + 13          ; Row 13, Col 13 ($19AD)
  defb (5 * 32) + 21          ; Row 13, Col 21 ($19B5)

  ; Row 14 ($19C0..$19DF)
  defb (6 * 32) + 4           ; Row 14, Col 4  ($19C4)
  defb (6 * 32) + 10          ; Row 14, Col 10 ($19CA)

  ; Row 15 ($19E0..$19FF)
  defb (7 * 32) + 18          ; Row 15, Col 18 ($19F2)
  defb (7 * 32) + 29          ; Row 15, Col 29 ($19FD)
STAR_COUNT: equ $ - star_positions


; ==============================================================================
; draw_stars
; Loads/colors TILE_STARS_0 in Bank 1 only and plots all stars in star_positions.
; Call with DI (e.g., from background_init before EI).
; ==============================================================================
draw_stars:
  ; 1. Upload pattern to Bank 1 ($0980)
  ld hl, _star_0_pattern
  ld de, VRAM_SCR2_PATTERN_MID + (TILE_STARS_0 * 8)
  ld bc, 8
  call write_vram_large

  ; 2. Paint TILE_STARS_0 Blue on Black in Bank 1 ($2980)
  ld a, STAR_COLOR
  ld hl, VRAM_SCR2_COLOR_MID + (TILE_STARS_0 * 8)
  ld b, 8
  call draw_tile_row

  ; 3. Plot each star in Bank 1 Name Table ($1900..$19FF)
  ld hl, star_positions
  ld c, STAR_COUNT            ; draw_tile_row destroys A, B, D (preserves C)
.star_loop:
  push hl                     ; Save table pointer
  ld l, (hl)                  ; Low byte = star offset ($00..$FF)
  ld h, $19                   ; High byte = Bank 1 Name Table
  ld a, TILE_STARS_0
  ld b, 1
  call draw_tile_row
  pop hl                      ; Restore table pointer
  inc hl
  dec c
  jr nz, .star_loop
  ret

