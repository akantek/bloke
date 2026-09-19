; ==============================================================================
; MSX HARDWARE & BIOS DEFINITIONS
; ==============================================================================

; --- MSX BIOS Entry Points ---
BEEP:    equ $00C0  ; Used for debugging only
DISSCR:  equ $0041  ; Disable screen display
ENASCR:  equ $0044  ; Enable screen display
CHGMOD:  equ $005F  ; Change VDP Screen Mode (Input: A)
CHGCLR:  equ $0062  ; Apply Foreground/Background/Border colors
LDIRVM:  equ $005C  ; MSX BIOS routine: Block transfer to VRAM
WRTVRM:  equ $004D  ; MSX BIOS: Write single byte in A to VRAM address HL

; --- MSX System Variables ---
CLIKSW:  equ $F3DB  ; Key Click Switch (0=Off, 1=On)
FORCLR:  equ $F3E9  ; Foreground Color Storage
BAKCLR:  equ $F3EA  ; Background Color Storage
BDRCLR:  equ $F3EB  ; Border Color Storage
HTIMI:   equ $FD9F  ; VBLANK Interrupt Handler
HKEYI:   equ $FD9A  ; HBLANK Interrupt Handler (line interrupt hook)

; --- VDP (Video Display Processor) Ports ---
VDP_DATA_PORT:          equ $98  ; VRAM Data Read/Write
VDP_CONTROL_PORT:       equ $99  ; Register Write / Status Read
VDP_PALETTE_PORT:       equ $9A  ; Palette Register Write
VDP_INDIRECT_PORT:      equ $9B  ; VDP Command Engine / Indirect Register Write

; --- VDP Constants & Shadow RAM ---
RG0SAV:           equ $F3DF   ; Shadow copy of VDP Register 0
RG1SAV:           equ $F3E0   ; Shadow RAM for VDP Register 1
PAGE1_BANK:       equ 1
PAGE2_BANK:       equ 2       ; Logic number for VRAM Page 2 (Hidden)
PAGE0_Y_OFFSET:   equ 0
PAGE1_Y_OFFSET:   equ 256
PAGE2_Y_OFFSET:   equ 512
PAGE2_VRAM_ADDR:  equ PAGE2_Y_OFFSET * 128  ; This equals $10000 (65536)

; --- PSG (Programmable Sound Generator) ---
PSG_REG_PORT:     EQU $A0         ; Select PSG Register
PSG_DATA_PORT:    EQU $A1         ; Write Data to PSG Register

; --- Screen 5 Sprite Tables (Default Locations) ---
; Note: These are standard for Screen 5 but can be moved via registers.
VRAM_SPR_COLORS:   equ $7400       ; Sprite Color Table (SCT)
VRAM_SPR_ATTRIBS:  equ $7600       ; Sprite Attribute Table (SAT)
VRAM_SPR_PATTERNS: equ $7800       ; Sprite Pattern Generator (SPG)

; Standard VRAM address for Sprite Patterns in SCREEN 5
; (Bank 7, Address $0000 -> Physical $1C000)
SPRITE_VRAM_BANK:  equ 1
SPRITE_VRAM_ADDR:  equ $0000

; --- PPI (Programmable Peripheral Interface) ---
; Used for Keyboard scanning, Memory mapping, etc.
PPI_PORT_B:       equ $A9         ; Read: Keyboard Column Status
PPI_PORT_C:       equ $AA         ; Write: Select Keyboard Row

; --- MSX Colors ---
TRANSPARENT:  equ 0
BLACK:        equ 1
DARK_GREEN:   equ 2
LIGHT_GREEN:  equ 3
DARK_BLUE:    equ 4
CYAN:         equ 5
RED:          equ 6
LIGHT_BLUE:   equ 7
DARK_RED:     equ 8
LIGHT_RED:    equ 9
YELLOW:       equ 10
LIGHT_YELLOW: equ 11
GREEN:        equ 12
MAGENTA:      equ 13
GRAY:         equ 14
WHITE:        equ 15

