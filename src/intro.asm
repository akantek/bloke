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

  ; Also set row[1] col[0] with tile 0: $1800 + $20 = $1820
  ld hl, $1820
  ld a, 0
  call WRTVRM

  ; Also set row[0] col[1] with tile 0: $1801
  ld hl, $1801
  ld a, 0
  call WRTVRM

  ; Set row[0] col[31] with tile 0: $181F
  ld hl, $181F
  ld a, 0
  call WRTVRM

;Top Third (Rows 0 to 7):
;
;  Name Table: $1800 to $18FF (256 bytes)
;  Pattern Table: $0000 to $07FF
;  Color Table: $2000 to $27FF
;
;Middle Third (Rows 8 to 15):
;  Name Table: $1900 to $19FF (256 bytes)
;  Pattern Table: $0800 to $0FFF
;  Color Table: $2800 to $2FFF
;
;Bottom Third (Rows 16 to 23):
;  Name Table: $1A00 to $1AFF (256 bytes)
;  Pattern Table: $1000 to $17FF
;  Color Table: $3000 to $37FF

; Set the pattern table for middle and bottom
  ld hl, tile0_ram_buffer
  ld de, $0800        ; Middle third PGT base
  call ldirvm_8
  
  ld hl, tile0_ram_buffer
  ld de, $1000        ; Bottom third PGT base
  call ldirvm_8

; and color
  ld hl, tile0_color
  ld de, $2800        ; Middle third Color base
  call ldirvm_8
  
  ld hl, tile0_color
  ld de, $3000        ; Bottom third Color base
  call ldirvm_8

; first col on MIDDLE is pattern id 0
; first col on BOTTOM is pattern id 0
; no need to set

  ei
.loop:
  call wait_vsync        ; Spin until vblank is fired
.vblank_trace_start:

  ; -------------------------------------------------------------
  ; 1. VDP UPDATES FIRST (Critical for OTIR on MSX1)
  ; -------------------------------------------------------------
  ; Update sprites immediately while the VDP is guaranteed to be blanking
  ld a, INIT_NUM_SPRITES 
  call loadSpriteAttributes

  ; -------------------------------------------------------------
  ; 2. GAME LOGIC & TILE SHIFTING 
  ; -------------------------------------------------------------
  ld a, (frame_count)
  cp 5
  jr nz, .skip_if

  ; shift tile in RAM
  ld hl, tile0_ram_buffer
  call shift_pattern_left

  ; update VDP with shifted tile
  ; (It is safe if this spills out of VBlank because LDIRVM is slow and safe)
  ; TOP area
  ld hl, tile0_ram_buffer 
  ld de, $0000          
  call ldirvm_8
  ; MIDDLE area
  ld hl, tile0_ram_buffer 
  ld de, $0800          
  call ldirvm_8
  ; BOTTOM area
  ld hl, tile0_ram_buffer
  ld de, $1000
  call ldirvm_8  

  ; frame_count = 0
  ld hl, frame_count
  ld (hl), 0
  jr .vblank_trace_end

.skip_if:
  ld hl, frame_count
  inc (hl)

.vblank_trace_end:
  ; -------------------------------------------------------------
  ; 3. KEYBOARD & MOVEMENT
  ; -------------------------------------------------------------
  call scan_keypad
  ld e, a

  ; if right
  bit KEY_RIGHT_BIT, e
  jr nz, .not_right_key

  ld hl, sprite0_x
  inc (hl)  

.not_right_key:
  jp .loop

