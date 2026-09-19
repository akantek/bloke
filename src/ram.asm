; ========================================================
; --- RAM VARIABLES ---
; ========================================================
OLD_HTIMI:     equ $C000  ; 5 Bytes ($C000-$C004)
vsync_flag:    equ $C00A  ; 1 Byte
frame_count:   equ $C00B  ; 1 Byte

; RAM area to store tiles and sprites
tile0_ram_buffer: equ $C00C  ; 8 bytes
