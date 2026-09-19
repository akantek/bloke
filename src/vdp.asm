; -------------------------------------------------------------------
; Rotate 8 bytes left (sprite or tile patterns)
;
; Parameters:
; HL = Source address of the 8-byte pattern data in RAM
; -------------------------------------------------------------------
shift_pattern_left:
  ld b, 8
.shift_loop:
  rlc (hl)
  inc hl
  djnz .shift_loop
  ret


; -------------------------------------------------------------------
; Slow write 8 bytes to VDP
;
; Parameters:
; HL = Source address of the 8-byte pattern data in RAM
; DE = Target VRAM address
; -------------------------------------------------------------------
ldirvm_8:
  ld bc, 8            ; Set BC to 8 (number of bytes to copy for one tile)
  call LDIRVM         ; Call BIOS to execute the transfer
  ret                 ; Return to the calling code

