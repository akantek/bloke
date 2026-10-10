; ==============================================================================
; Routine:      play_start_sound
; Description:  Plays a high pitch, medium fade sound (Arcade Coin-up style).
;               Translated from: 
;               SOUND 7,190: SOUND 0,60: SOUND 1,0: SOUND 8,16: SOUND 11,0: SOUND 12,20: SOUND 13,0
; Destroys:     A, E
; ==============================================================================
play_start_sound:
  ; SOUND 0,60 - Tone A Period (Fine)
  ld a, 0
  ld e, 60              ; $3C
  call write_psg
  
  ; SOUND 1,0 - Tone A Period (Coarse)
  ld a, 1
  ld e, 0
  call write_psg

  ; SOUND 8,16 - Channel A Volume (Bit 4 set = use hardware envelope)
  ld a, 8
  ld e, 16              ; $10
  call write_psg

  ; SOUND 11,0 - Envelope Period (Fine)
  ld a, 11
  ld e, 0
  call write_psg
  
  ; SOUND 12,8 - Envelope Period (Coarse)
  ld a, 12
  ld e, 8              ; $14
  call write_psg

  ; SOUND 13,0 - Envelope Shape (Single fade out and stop)
  ld a, 13
  ld e, 0
  call write_psg

  ; SOUND 7,190 - Mixer Control (Tone A enabled, others off)
  ld a, 7
  ld e, 190             ; $BE or %10111110
  call write_psg
  
  ret

