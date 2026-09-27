
main:
  ; ROM standard SP initialization (move to top-of-RAM)
  ld sp, $f380

  di
  call boot
  jp intro

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

