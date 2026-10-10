; ==============================================================================
; Routine:      write_psg
; Description:  Helper to write data to a specific PSG register.
; Inputs:       A = Register Number (0-13)
;               E = Data to write
; ==============================================================================
write_psg:
  out (PSG_REG_PORT), a
  ld a, e
  out (PSG_DATA_PORT), a
  ret

