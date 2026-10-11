stage1_sprite0_attributes_data:
  ;  Y,   X,   Pat, Color
  db 150, 10,  4,   15       ; Pat = 0 (_bloke_right_0), Color = 15 (White)

stage1:
  ; SCREEN OFF
  call DISSCR

  di

  ; clear(SCREEN2)
  call clear_screen2

  call init_sprite_attributes

  ; Init player sprite (sprite0_*)
  xor a
  ld (player_direction), a   ; 0 = Right facing base
  ld (player_anim_frame), a  ; 0 = Frame 0
  ld (player_anim_timer), a  ; 0 = Reset timer
  ld (sprite0_pat), a        ; Set Pattern ID to 0


  ; SCREEN ON
  call ENASCR

  ei

stage1_loop:
  call wait_vsync        ; Spin until vblank is fired
.stage1_vblank_trace_start:
  ; Update sprites immediately while the VDP is guaranteed to be blanking
  ld a, INIT_NUM_SPRITES 
  call loadSpriteAttributes
.stage1_vblank_trace_end:
  ; -------------------------------------------------------------
  ; 3. KEYBOARD & MOVEMENT
  ; -------------------------------------------------------------
  call scan_keypad
  ld e, a
  ; if right
  bit KEY_RIGHT_BIT, e
  jr nz, .not_right_key
  ld hl, sprite0_x
  inc (hl)
  ;ld a, 12
  ; ld a, 16
  ld a, 20
  ld (sprite0_pat), a
.not_right_key:
  ; else if left
  bit KEY_LEFT_BIT, e
  jr nz, .not_left_key
  ld hl, sprite0_x
  dec (hl)
  ; xor a
  ;ld a, 4
  ld a, 8
  ld (sprite0_pat), a
.not_left_key:
  ; if up
  bit KEY_UP_BIT, e
  jr nz, .not_up_key
  ld hl, sprite0_y
  dec (hl)
.not_up_key:
  ; if down
  bit KEY_DOWN_BIT, e
  jr nz, .not_down_key

.skip_movement:
  ld hl, sprite0_y
  inc (hl)
.not_down_key:


  jp stage1_loop

  ret


; ==============================================================================
; Routine:      init_sprite_attributes
; Description:  Initializes the Sprite Attribute Table (SAT) at startup.
;               First, it copies the default sprite configuration data (Y, X, 
;               Pattern, Color) from ROM into the shadow SAT in RAM. Then, it 
;               transfers this freshly initialized shadow memory into the VDP 
;               VRAM so sprites are correctly positioned for the first frame.
;
; [!] WARNING:  Interrupts MUST be disabled (DI) before calling this routine,
;               as it relies on 'write_vram_large' which uses direct VDP port
;               I/O and will corrupt if a VBlank interrupts the address setup.
;
; Inputs:       None (Relies on INIT_NUM_SPRITES constant)
; Outputs:      - Populates 'shadow_sat' buffer in RAM
;               - Writes to VRAM $1B00 (SCREEN 2 Sprite Attribute Table)
; Destroys:     A, BC, DE, HL (from LDIR and write_vram_large)
; ==============================================================================
init_sprite_attributes:
  ; 1. Copy the initial sprite attributes into the RAM shadow area
  ld hl, stage1_sprite0_attributes_data
  ld de, shadow_sat
  ld bc, INIT_NUM_SPRITES * 4
  ldir

  ; 2. Send it to VDP
  ld hl, shadow_sat
  ld de, $1B00                      ; VRAM Address for SCREEN 2 Sprite Attribute Table
  ld bc, INIT_NUM_SPRITES * 4       ; We are copying 4 bytes (1 sprite)
  call write_vram_large
  ret
