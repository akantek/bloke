; ========================================================
; --- RAM VARIABLES ---
; ========================================================
OLD_HTIMI:     equ $C000  ; 5 Bytes ($C000-$C004)
vsync_flag:    equ $C00A  ; 1 Byte
frame_count:   equ $C00B  ; 1 Byte

; ========================================================
; RAM area to store tiles and sprites
; ========================================================
tile0_ram_buffer: equ $C00C  ; 8 bytes

; ========================================================
; Shadow Sprite Attribute Table (SAT) in RAM
; 1 Sprite = 4 Bytes, 32 Sprites Max (128 Bytes Total)
; Start Address: $C120
; End Address:   $C19F
; ========================================================
shadow_sat:      equ $C120

; Sprite 0
sprite0_y:       equ $C120   ; Byte 0: Y Coordinate
sprite0_x:       equ $C121   ; Byte 1: X Coordinate
sprite0_pat:     equ $C122   ; Byte 2: Pattern Number
sprite0_color:   equ $C123   ; Byte 3: Color (Bits 0-3) & Early Clock (Bit 7)

; Sprite 1
sprite1_y:       equ $C124   ; Byte 0: Y Coordinate
sprite1_x:       equ $C125   ; Byte 1: X Coordinate
sprite1_pat:     equ $C126   ; Byte 2: Pattern Number
sprite1_color:   equ $C127   ; Byte 3: Color (Bits 0-3) & Early Clock (Bit 7)

; Sprite 2
sprite2_y:       equ $C128   ; Byte 0: Y Coordinate
sprite2_x:       equ $C129   ; Byte 1: X Coordinate
sprite2_pat:     equ $C12A   ; Byte 2: Pattern Number
sprite2_color:   equ $C12B   ; Byte 3: Color (Bits 0-3) & Early Clock (Bit 7)

; Sprite 3
sprite3_y:       equ $C12C   ; Byte 0: Y Coordinate
sprite3_x:       equ $C12D   ; Byte 1: X Coordinate
sprite3_pat:     equ $C12E   ; Byte 2: Pattern Number
sprite3_color:   equ $C12F   ; Byte 3: Color (Bits 0-3) & Early Clock (Bit 7)

; Sprite 4
sprite4_y:       equ $C130   ; Byte 0: Y Coordinate
sprite4_x:       equ $C131   ; Byte 1: X Coordinate
sprite4_pat:     equ $C132   ; Byte 2: Pattern Number
sprite4_color:   equ $C133   ; Byte 3: Color (Bits 0-3) & Early Clock (Bit 7)

; Sprite 5
sprite5_y:       equ $C134   ; Byte 0: Y Coordinate
sprite5_x:       equ $C135   ; Byte 1: X Coordinate
sprite5_pat:     equ $C136   ; Byte 2: Pattern Number
sprite5_color:   equ $C137   ; Byte 3: Color (Bits 0-3) & Early Clock (Bit 7)

; Sprite 6
sprite6_y:       equ $C138   ; Byte 0: Y Coordinate
sprite6_x:       equ $C139   ; Byte 1: X Coordinate
sprite6_pat:     equ $C13A   ; Byte 2: Pattern Number
sprite6_color:   equ $C13B   ; Byte 3: Color (Bits 0-3) & Early Clock (Bit 7)

; Sprite 7
sprite7_y:       equ $C13C   ; Byte 0: Y Coordinate
sprite7_x:       equ $C13D   ; Byte 1: X Coordinate
sprite7_pat:     equ $C13E   ; Byte 2: Pattern Number
sprite7_color:   equ $C13F   ; Byte 3: Color (Bits 0-3) & Early Clock (Bit 7)

; Sprite 8
sprite8_y:       equ $C140   ; Byte 0: Y Coordinate
sprite8_x:       equ $C141   ; Byte 1: X Coordinate
sprite8_pat:     equ $C142   ; Byte 2: Pattern Number
sprite8_color:   equ $C143   ; Byte 3: Color (Bits 0-3) & Early Clock (Bit 7)

; Sprite 9
sprite9_y:       equ $C144   ; Byte 0: Y Coordinate
sprite9_x:       equ $C145   ; Byte 1: X Coordinate
sprite9_pat:     equ $C146   ; Byte 2: Pattern Number
sprite9_color:   equ $C147   ; Byte 3: Color (Bits 0-3) & Early Clock (Bit 7)

; Sprite 10
sprite10_y:      equ $C148   ; Byte 0: Y Coordinate
sprite10_x:      equ $C149   ; Byte 1: X Coordinate
sprite10_pat:    equ $C14A   ; Byte 2: Pattern Number
sprite10_color:  equ $C14B   ; Byte 3: Color (Bits 0-3) & Early Clock (Bit 7)

; Sprite 11
sprite11_y:      equ $C14C   ; Byte 0: Y Coordinate
sprite11_x:      equ $C14D   ; Byte 1: X Coordinate
sprite11_pat:    equ $C14E   ; Byte 2: Pattern Number
sprite11_color:  equ $C14F   ; Byte 3: Color (Bits 0-3) & Early Clock (Bit 7)

; Sprite 12
sprite12_y:      equ $C150   ; Byte 0: Y Coordinate
sprite12_x:      equ $C151   ; Byte 1: X Coordinate
sprite12_pat:    equ $C152   ; Byte 2: Pattern Number
sprite12_color:  equ $C153   ; Byte 3: Color (Bits 0-3) & Early Clock (Bit 7)

; Sprite 13
sprite13_y:      equ $C154   ; Byte 0: Y Coordinate
sprite13_x:      equ $C155   ; Byte 1: X Coordinate
sprite13_pat:    equ $C156   ; Byte 2: Pattern Number
sprite13_color:  equ $C157   ; Byte 3: Color (Bits 0-3) & Early Clock (Bit 7)

; Sprite 14
sprite14_y:      equ $C158   ; Byte 0: Y Coordinate
sprite14_x:      equ $C159   ; Byte 1: X Coordinate
sprite14_pat:    equ $C15A   ; Byte 2: Pattern Number
sprite14_color:  equ $C15B   ; Byte 3: Color (Bits 0-3) & Early Clock (Bit 7)

; Sprite 15
sprite15_y:      equ $C15C   ; Byte 0: Y Coordinate
sprite15_x:      equ $C15D   ; Byte 1: X Coordinate
sprite15_pat:    equ $C15E   ; Byte 2: Pattern Number
sprite15_color:  equ $C15F   ; Byte 3: Color (Bits 0-3) & Early Clock (Bit 7)

; Sprite 16
sprite16_y:      equ $C160   ; Byte 0: Y Coordinate
sprite16_x:      equ $C161   ; Byte 1: X Coordinate
sprite16_pat:    equ $C162   ; Byte 2: Pattern Number
sprite16_color:  equ $C163   ; Byte 3: Color (Bits 0-3) & Early Clock (Bit 7)

; Sprite 17
sprite17_y:      equ $C164   ; Byte 0: Y Coordinate
sprite17_x:      equ $C165   ; Byte 1: X Coordinate
sprite17_pat:    equ $C166   ; Byte 2: Pattern Number
sprite17_color:  equ $C167   ; Byte 3: Color (Bits 0-3) & Early Clock (Bit 7)

; Sprite 18
sprite18_y:      equ $C168   ; Byte 0: Y Coordinate
sprite18_x:      equ $C169   ; Byte 1: X Coordinate
sprite18_pat:    equ $C16A   ; Byte 2: Pattern Number
sprite18_color:  equ $C16B   ; Byte 3: Color (Bits 0-3) & Early Clock (Bit 7)

; Sprite 19
sprite19_y:      equ $C16C   ; Byte 0: Y Coordinate
sprite19_x:      equ $C16D   ; Byte 1: X Coordinate
sprite19_pat:    equ $C16E   ; Byte 2: Pattern Number
sprite19_color:  equ $C16F   ; Byte 3: Color (Bits 0-3) & Early Clock (Bit 7)

; Sprite 20
sprite20_y:      equ $C170   ; Byte 0: Y Coordinate
sprite20_x:      equ $C171   ; Byte 1: X Coordinate
sprite20_pat:    equ $C172   ; Byte 2: Pattern Number
sprite20_color:  equ $C173   ; Byte 3: Color (Bits 0-3) & Early Clock (Bit 7)

; Sprite 21
sprite21_y:      equ $C174   ; Byte 0: Y Coordinate
sprite21_x:      equ $C175   ; Byte 1: X Coordinate
sprite21_pat:    equ $C176   ; Byte 2: Pattern Number
sprite21_color:  equ $C177   ; Byte 3: Color (Bits 0-3) & Early Clock (Bit 7)

; Sprite 22
sprite22_y:      equ $C178   ; Byte 0: Y Coordinate
sprite22_x:      equ $C179   ; Byte 1: X Coordinate
sprite22_pat:    equ $C17A   ; Byte 2: Pattern Number
sprite22_color:  equ $C17B   ; Byte 3: Color (Bits 0-3) & Early Clock (Bit 7)

; Sprite 23
sprite23_y:      equ $C17C   ; Byte 0: Y Coordinate
sprite23_x:      equ $C17D   ; Byte 1: X Coordinate
sprite23_pat:    equ $C17E   ; Byte 2: Pattern Number
sprite23_color:  equ $C17F   ; Byte 3: Color (Bits 0-3) & Early Clock (Bit 7)

; Sprite 24
sprite24_y:      equ $C180   ; Byte 0: Y Coordinate
sprite24_x:      equ $C181   ; Byte 1: X Coordinate
sprite24_pat:    equ $C182   ; Byte 2: Pattern Number
sprite24_color:  equ $C183   ; Byte 3: Color (Bits 0-3) & Early Clock (Bit 7)

; Sprite 25
sprite25_y:      equ $C184   ; Byte 0: Y Coordinate
sprite25_x:      equ $C185   ; Byte 1: X Coordinate
sprite25_pat:    equ $C186   ; Byte 2: Pattern Number
sprite25_color:  equ $C187   ; Byte 3: Color (Bits 0-3) & Early Clock (Bit 7)

; Sprite 26
sprite26_y:      equ $C188   ; Byte 0: Y Coordinate
sprite26_x:      equ $C189   ; Byte 1: X Coordinate
sprite26_pat:    equ $C18A   ; Byte 2: Pattern Number
sprite26_color:  equ $C18B   ; Byte 3: Color (Bits 0-3) & Early Clock (Bit 7)

; Sprite 27
sprite27_y:      equ $C18C   ; Byte 0: Y Coordinate
sprite27_x:      equ $C18D   ; Byte 1: X Coordinate
sprite27_pat:    equ $C18E   ; Byte 2: Pattern Number
sprite27_color:  equ $C18F   ; Byte 3: Color (Bits 0-3) & Early Clock (Bit 7)

; Sprite 28
sprite28_y:      equ $C190   ; Byte 0: Y Coordinate
sprite28_x:      equ $C191   ; Byte 1: X Coordinate
sprite28_pat:    equ $C192   ; Byte 2: Pattern Number
sprite28_color:  equ $C193   ; Byte 3: Color (Bits 0-3) & Early Clock (Bit 7)

; Sprite 29
sprite29_y:      equ $C194   ; Byte 0: Y Coordinate
sprite29_x:      equ $C195   ; Byte 1: X Coordinate
sprite29_pat:    equ $C196   ; Byte 2: Pattern Number
sprite29_color:  equ $C197   ; Byte 3: Color (Bits 0-3) & Early Clock (Bit 7)

; Sprite 30
sprite30_y:      equ $C198   ; Byte 0: Y Coordinate
sprite30_x:      equ $C199   ; Byte 1: X Coordinate
sprite30_pat:    equ $C19A   ; Byte 2: Pattern Number
sprite30_color:  equ $C19B   ; Byte 3: Color (Bits 0-3) & Early Clock (Bit 7)

; Sprite 31
sprite31_y:      equ $C19C   ; Byte 0: Y Coordinate
sprite31_x:      equ $C19D   ; Byte 1: X Coordinate
sprite31_pat:    equ $C19E   ; Byte 2: Pattern Number
sprite31_color:  equ $C19F   ; Byte 3: Color (Bits 0-3) & Early Clock (Bit 7)


