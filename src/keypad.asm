; Bit definitions in Register A as returned by the scan_keypad routine.
KEY_SPACE_BIT:	equ 0
KEY_SHIFT_BIT:	equ 1
KEY_CTRL_BIT:	equ 2
KEY_LEFT_BIT:   equ 4
KEY_UP_BIT:     equ 5
KEY_DOWN_BIT:   equ 6
KEY_RIGHT_BIT:  equ 7

;------------------------------------------------------------------------------
; Scans keyboard rows 6 and 8 for game input.
;
; Output: A = 8-bit key state. 0 = pressed, 1 = not pressed.
;   Bit 7: Right Arrow
;   Bit 6: Down Arrow
;   Bit 5: Up Arrow
;   Bit 4: Left Arrow
;   Bit 3: (Unused)
;   Bit 2: CTRL
;   Bit 1: SHIFT
;   Bit 0: Space Bar
;
; Registers modified: A, C
;------------------------------------------------------------------------------
scan_keypad:
  ; Scan directions and space keys
  ld A, 8		; Set the row for the space key
  out (PPI_PORT_C), A	; Select keyboard row 8
  in A, (PPI_PORT_B)	; Read the state of all 8 keys in row 8 from PPI port B
                        ; A pressed returns a 0 for its corresponding bit

  and %11110001		; Clean bits 3,2, and 1. Keep directions and space keys
  ld C, A		; Temporarily store in C

  ; Scan shift and ctrl keys
  ld A, 6		; Set the row for the shift key
  out (PPI_PORT_C), A	; Select keyboard row 6
  in A, (PPI_PORT_B)	; Read the state of all 8 keys in row 6 from PPI port B

  and %00000011		; Keep bits 1, and 0 (CTRL and SHIFT keys).
  rla			; Shift one bit left.
  or C			; Merge with the previous key scan.
  ret

