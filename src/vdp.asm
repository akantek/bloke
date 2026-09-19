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

