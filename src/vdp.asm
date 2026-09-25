; ==============================================================================
; Routine:      draw_tile_row
; Description:  Fills a sequence of VRAM addresses with a single Tile ID.
;               Extremely fast (24 T-states/byte), ideal for drawing floors or 
;               walls while the screen display is disabled.
;
; [!] WARNING:  Interrupts MUST be disabled (execute 'di') before calling this
;               routine. If a VBlank interrupt fires during the VDP address setup,
;               the internal latch will corrupt and write data to the wrong VRAM
;               location.
;
; Inputs:
;   A  = Tile ID to draw
;   HL = VRAM Start Address (e.g., $1800 for top-left of SCREEN 2 Name Table)
;   B  = Number of sequential tiles to draw (1 to 256, where 0 = 256 tiles)
;
; Destroys:
;   A, B, D
; ==============================================================================
draw_tile_row:
  ; 1. Temporarily backup the Tile ID into D so we can use A for VDP setup
  ld d, a

  ; 2. Set up VDP VRAM Write Address
  ld a, l
  out (VDP_CONTROL_PORT), a   ; Send Low Byte of VRAM Address

  ld a, h
  and $3F                     ; Clear VDP command bits (6/7) to isolate the
                              ; 14-bit VRAM address
  or $40                      ; Set Bit 6 to enable VDP "Write VRAM" mode
  out (VDP_CONTROL_PORT), a   ; Send High Byte and Latch Address

  ; 3. Restore Tile ID to A for the fast loop
  ld a, d

  ; 4. Blast the data to the VDP
.fill_loop:
  out (VDP_DATA_PORT), a      ; Write Tile ID to VDP (11 T-states)
  djnz .fill_loop             ; Decrement B, jump if not zero (13 T-states)

  ret


; ==============================================================================
; enable_8x8_sprites
; One-time VDP initialization to set Sprite Size to 8x8 pixels.
;
; NOTES:
;   - Modifies VDP Register 1.
;   - Updates the RG1SAV BIOS mirror.
;   - Should be called during startup (boot) sequence.
;   - Assumes interrupts are disabled (DI) or no VDP activity is occurring.
; ==============================================================================
enable_8x8_sprites:
  ld a, (RG1SAV)             ; Get current Register 1 value from BIOS mirror
  and $FD                    ; Set Bit 1 to Enable 8x8 sprites (0=8x8,1=16x16)
  ld (RG1SAV), a             ; Update mirror so BIOS remembers the change

  out (VDP_CONTROL_PORT), a  ; Step 1: Send the DATA (latches it in VDP)
  ld a, 1 + 128              ; Prep Command: Register Index (1) + Write Flag ($80)
                             ;   Bit 7 (write flag) is 1,
                             ;     and bit 1 (R#1) is also 1 = %81
  out (VDP_CONTROL_PORT), a  ; Step 2: Send COMMAND to move latched data into Reg 1
  ret


; ===================================================================
; Rotate 8 bytes left (sprite or tile patterns)
;
; Parameters:
; HL = Source address of the 8-byte pattern data in RAM
; ===================================================================
shift_pattern_left:
  ld b, 8
.shift_loop:
  rlc (hl)
  inc hl
  djnz .shift_loop
  ret


; ===================================================================
; Slow write 8 bytes to VDP
;
; Parameters:
; HL = Source address of the 8-byte pattern data in RAM
; DE = Target VRAM address
; ===================================================================
ldirvm_8:
  ld bc, 8            ; Set BC to 8 (number of bytes to copy for one tile)
  call LDIRVM         ; Call BIOS to execute the transfer
  ret                 ; Return to the calling code


; ==============================================================================
; write_vram_large (MSX1 VERSION)
; Transfers a block of data from RAM to VRAM using a 16-bit counter.
;
; INPUTS:
;   HL = Source Address (RAM)
;   DE = Destination Address (VRAM)
;   BC = Length (Bytes)
;
; [!] CRITICAL WARNING:
;   You MUST execute DI (Disable Interrupts) before calling this function.
;   If an interrupt fires during the VDP address setup, the VDP latch 
;   will be corrupted, writing data to the wrong address.
; ==============================================================================
write_vram_large:
  ; --- 1. Set VRAM Address ---
  ld  a, e
  out (VDP_CONTROL_PORT), a  ; Send Low Byte (A0-A7)

  ld  a, d
  and $3f                    ; Safety: Mask to valid 14-bit address range
  or  $40                    ; Set Bit 6: Enable "Write" Mode
  out (VDP_CONTROL_PORT), a  ; Send High Byte (A8-A13) + Latch Address

  ; --- 2. Transfer Data ---
  ld  a, b
  or  c
  ret z                      ; Return immediately if BC (Size) is 0

.write_vram_large_loop:
  ld  a, (hl)                ; Read byte from RAM (7 T-states)
  out (VDP_DATA_PORT), a     ; Write byte to VDP (11 T-states)
  inc hl                     ; Next RAM address (6 T-states)
  dec bc                     ; Decrement 16-bit counter (6 T-states)
  ld  a, b                   ; (4 T-states)
  or  c                      ; Check if BC == 0 (4 T-states)
  jr  nz, .write_vram_large_loop ; (12 T-states) -> Total: 50 T-states
  
  ret

