NUM_SPRITES:  equ 1

intro:
  ; Initialize intro
  
  ; Copy the initial tile pattern from ROM to RAM
  ld hl, tile0_pattern      ; Source: ROM address
  ld de, tile0_ram_buffer   ; Destination: RAM address (e.g., $C000)
  ld bc, 8                  ; Number of bytes to copy (1 tile)
  ldir                      ; Copy fast!

  ; Set the colors for tile 0 (Pattern Color Table at $2000)
  ld hl, tile0_color
  ld de, $2000
  call ldirvm_8

  ; Set the tile pattern for tile 0 (Pattern Generator Table at $0000)
  ld hl, tile0_ram_buffer
  ld de, $0000          
  call ldirvm_8

  ; Set the tile name for screen position 0 (Pattern Name Table at $1800)
  ld hl, $1800        ; Target VRAM address: Start of Name Table (Top-left of the screen)
  ld a, 0             ; The ID of the tile to draw (tile 0)
  call WRTVRM         ; Call BIOS to write the single byte in A to VRAM address in HL

  ; Also set row[0] col[0] with tile 0: $1800 + $20 = $1820
  ; ld hl, $1820
  ; ld a, 0
  ; call WRTVRM

  ; Also set row[0] col[1] with tile 0: $1801
  ld hl, $1801
  ld a, 0
  call WRTVRM

  ei
.loop:
  call wait_vsync        ; Spin until vblank is fired
.vblank_trace_start:
  ld a, (frame_count)
  cp 5
  jr nz, .skip_if

  ; shift tile in RAM
  ld hl, tile0_ram_buffer
  call shift_pattern_left

  ; upate VDP
  ld hl, tile0_ram_buffer 
  ld de, $0000          
  call ldirvm_8

  ; frame_count = 0
  ld hl, frame_count
  ld (hl), 0

.skip_if
  ld hl, frame_count
  inc (hl)
  
.vblank_trace_end:

  ; Update sprites
  ld a, INIT_NUM_SPRITES 
  call loadSpriteAttributes

  ; scan keyboard
  call scan_keypad
  ld e, a

  ; if right
  bit KEY_RIGHT_BIT, e
  jr nz, .not_right_key

  ld hl, sprite0_x
  inc (hl)  

.not_right_key:
  jp .loop

