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


init_sprite_attributes:
  ld hl, sprite0_attributes_data
  ld de, $1B00                      ; VRAM Address for SCREEN 2 Sprite Attribute Table
  ld bc, 4                          ; We are copying 4 bytes (1 sprite)
  call write_vram_large
  ret


sprite0_attributes_data:
  ;  Y,  X, Pat, Color
  db 10, 10,   0,   15              ; Layer 1 (White = 15)

