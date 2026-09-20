INIT_NUM_SPRITES: equ 1

main:
  ; ROM standard SP initialization (move to top-of-RAM)
  ld sp, $f380

  di
  call boot
  jr intro

boot:
  ; COLOR 15,1,1
  ld a, WHITE
  ld (FORCLR), a  ; Store in Foreground system variable ($F3E9)
  ld a, BLACK
  ld (BAKCLR), a  ; Store in Background system variable ($F3EA)
  ld (BDRCLR), a  ; Store in Border system variable ($F3EB)
  call CHGCLR     ; BIOS Call ($0062): Update VDP registers with new colors

  ; SCREEN 2
  ld a, 2
  call CHGMOD

  ; Initialize VDP
  call enable_8x8_sprites

  ; Load assets
  call load_sprite_patterns 
  call init_sprite_attributes

  ; Install VBlank hook
  xor a
  ld (frame_count), a
  call install_vblank_hook
  ret


load_sprite_patterns:
  ld hl, sprite_patterns_start
  ld de, VRAM_SCR2_SPR_PATTERNS
  ld bc, sprite_patterns_end - sprite_patterns_start
  call write_vram_large
  ret


; ==============================================================================
; Routine:      loadSpriteAttributes
; Description:  Transfers Shadow RAM to VRAM for a specific number of sprites.
; Inputs:       A = Number of sprites to transfer (0 to 32)
; Destroys:     A, B, C, HL
; ==============================================================================
loadSpriteAttributes:
  or a                           ; Fast way to check if A is 0
  ret z                          ; If 0 sprites, exit immediately

  ; Multiply A by 4 (4 bytes per sprite)
  add a, a                       
  add a, a                       
  ld b, a                        ; Store total byte count in B for OTIR

  ld hl, shadow_sat              ; Source RAM
  ld c, VDP_DATA_PORT            ; VDP data port

  di                             ; Disable interrupts for VDP setup AND transfer

  ; Set VRAM address: low byte 
  ld a, VRAM_SCR2_SPR_ATTRIBS & $FF  
  out (VDP_CONTROL_PORT), a

  ; Set VRAM address: high byte 
  ld a, VRAM_SCR2_SPR_ATTRIBS >> 8   
  and $3f                        ; Clear top 2 bits (safety mask)
  or $40                         ; Set bit 6 to enable VDP WRITE mode
  out (VDP_CONTROL_PORT), a

  ; Transfer data
  otir                           ; Output (HL) -> PORT C, HL++, B--
  ei                             ; Re-enable interrupts AFTER transfer
  ret


init_sprite_attributes:
  ; 1. Copy the initial sprite attributes into the RAM shadow area
  ld hl, sprite0_attributes_data
  ld de, shadow_sat
  ld bc, INIT_NUM_SPRITES * 4
  ldir

  ; 2. Send it to VDP
  ld hl, shadow_sat
  ld de, $1B00                      ; VRAM Address for SCREEN 2 Sprite Attribute Table
  ld bc, INIT_NUM_SPRITES * 4       ; We are copying 4 bytes (1 sprite)
  call write_vram_large
  ret


sprite0_attributes_data:
  ;  Y,  X, Pat, Color
  db 10, 10,   0,   15              ; Layer 1 (White = 15)

