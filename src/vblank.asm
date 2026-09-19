; ==============================================================================
; Routine:      install_vblank_hook
; Description:  Backs up the existing HTIMI (V-Blank) system hook and installs
;               a jump ($C3) to the custom 'vblank_hook' handler.
;               
; Requires:     - Interrupts must be disabled (DI) before calling.
;               - 'OLD_HTIMI' must be defined as a 5-byte buffer.
;               - 'vblank_hook' label must exist.
;
; Inputs:       None
; Outputs:      (HTIMI) modified to jump to vblank_hook
;               (OLD_HTIMI) contains the original 5 bytes of the hook
;
; Destroys:     A, BC, DE, HL
; ==============================================================================
install_vblank_hook:
  ; 1. Save the old hook (5 bytes at $FD9F)
  ld  hl, HTIMI           ; Source: Address of system interrupt hook
  ld  de, OLD_HTIMI       ; Dest: Address of our backup buffer
  ld  bc, 5               ; Count: Hooks are 5 bytes long
  ldir                    ; Copy original hook bytes to backup storage

  ; 2. Write JUMP to our new handler
  ld  a, $C3              ; Load Z80 opcode for 'JP' (Unconditional Jump)
  ld  (HTIMI), a          ; Write JP opcode to the first byte of hook
  ld  hl, vblank_hook     ; Load address of our custom interrupt handler
  ld  (HTIMI + 1), hl     ; Write handler address to next 2 bytes
  ret


; ==============================================================================
; INTERRUPT HANDLER & WAIT
; ==============================================================================
vblank_hook:
  push af
  ld a, 1
  ld (vsync_flag), a
  pop af
  jp OLD_HTIMI


; ==============================================================================
; Routine:      wait_vsync
; Description:  Halts program execution until the next V-Blank occurs. Uses a
;               spin lock (busy-wait) to continuously poll the vsync_flag until
;               it is set by the interrupt. Resets the flag before returning.
; Inputs:       None
; Outputs:      (vsync_flag) reset to 0
; Destroys:     A
; ==============================================================================
wait_vsync:
  ld a, (vsync_flag)      ; Read current flag state
  or a                    ; Check if A is zero
  jr z, wait_vsync        ; Spin lock: busy-wait loop until interrupt fires

  xor a                   ; Fast way to clear A (A = 0)
  ld (vsync_flag), a      ; Reset the flag for the next frame
  ret


