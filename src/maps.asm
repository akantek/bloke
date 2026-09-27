; ==============================================================================
; Routine:      load_stage_map
; Description:  Copies a 768-byte map array to the SCREEN 2 Name Table ($1800)
; Inputs:       HL = Address of the map array (e.g., stage1_map)
; Destroys:     A, BC, DE, HL
; ==============================================================================
load_stage_map:
  di
  ld de, $1800         ; $1800 is the start of the SCREEN 2 Name Table
  ld bc, 768           ; 32 columns * 24 rows = 768 bytes
  call write_vram_large
  ei
  ret

