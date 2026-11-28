; ==============================================================================
; Tile ID Constants (SCREEN 2)
; Total: 96 tiles (0..95 / $00..$5F), 768 bytes ($0300) per pattern bank
; ==============================================================================

; --- Blank & Digits ---
TILE_BLANK:          equ 0       ; $00 (offset $0000)
TILE_0:              equ 1       ; $01 (offset $0008)
TILE_1:              equ 2       ; $02 (offset $0010)
TILE_2:              equ 3       ; $03 (offset $0018)
TILE_3:              equ 4       ; $04 (offset $0020)
TILE_4:              equ 5       ; $05 (offset $0028)
TILE_5:              equ 6       ; $06 (offset $0030)
TILE_6:              equ 7       ; $07 (offset $0038)
TILE_7:              equ 8       ; $08 (offset $0040)
TILE_8:              equ 9       ; $09 (offset $0048)
TILE_9:              equ 10      ; $0A (offset $0050)

; --- Alphabet ---
TILE_A:              equ 11      ; $0B (offset $0058)
TILE_B:              equ 12      ; $0C (offset $0060)
TILE_C:              equ 13      ; $0D (offset $0068)
TILE_D:              equ 14      ; $0E (offset $0070)
TILE_E:              equ 15      ; $0F (offset $0078)
TILE_F:              equ 16      ; $10 (offset $0080)
TILE_G:              equ 17      ; $11 (offset $0088)
TILE_H:              equ 18      ; $12 (offset $0090)
TILE_I:              equ 19      ; $13 (offset $0098)
TILE_J:              equ 20      ; $14 (offset $00A0)
TILE_K:              equ 21      ; $15 (offset $00A8)
TILE_L:              equ 22      ; $16 (offset $00B0)
TILE_M:              equ 23      ; $17 (offset $00B8)
TILE_N:              equ 24      ; $18 (offset $00C0)
TILE_O:              equ 25      ; $19 (offset $00C8)
TILE_P:              equ 26      ; $1A (offset $00D0)
TILE_Q:              equ 27      ; $1B (offset $00D8)
TILE_R:              equ 28      ; $1C (offset $00E0)
TILE_S:              equ 29      ; $1D (offset $00E8)
TILE_T:              equ 30      ; $1E (offset $00F0)
TILE_U:              equ 31      ; $1F (offset $00F8)
TILE_V:              equ 32      ; $20 (offset $0100)
TILE_W:              equ 33      ; $21 (offset $0108)
TILE_X:              equ 34      ; $22 (offset $0110)
TILE_Y:              equ 35      ; $23 (offset $0118)
TILE_Z:              equ 36      ; $24 (offset $0120)

; --- Punctuation ---
TILE_EXCLAMATION:    equ 37      ; $25 (offset $0128)
TILE_SEMI_COLON:     equ 38      ; $26 (offset $0130)
TILE_SPACE:          equ 39      ; $27 (offset $0138)

; --- Background Lines (1-line strips) ---
TILE_BACKGROUND_LINE_A:  equ 40      ; $28 (offset $0140)
TILE_BACKGROUND_LINE_B:  equ 41      ; $29 (offset $0148)
TILE_BACKGROUND_LINE_C:  equ 42      ; $2A (offset $0150)
TILE_BACKGROUND_LINE_D:  equ 43      ; $2B (offset $0158)
TILE_BACKGROUND_LINE_E:  equ 44      ; $2C (offset $0160)
TILE_BACKGROUND_LINE_F:  equ 45      ; $2D (offset $0168)
TILE_BACKGROUND_LINE_G:  equ 46      ; $2E (offset $0170)
TILE_BACKGROUND_LINE_H:  equ 47      ; $2F (offset $0178)

; --- Stars ---
TILE_STARS_0:  equ 48       ; $30 (offset $0180) 

; --- Title Graphics ---
TILE_TITLE_DIAG_TOP_RIGHT:    equ 49    ; $31 (offset $0188)
TILE_TITLE_DIAG_TOP_LEFT:     equ 50    ; $32 (offset $0190)
TILE_TITLE_DIAG_BOTTOM_RIGHT: equ 51    ; $33 (offset $0198)
TILE_TITLE_LINE:              equ 52    ; $34 (offset $01A0)

