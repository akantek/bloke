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
  cp $F7
  jr z, .skip_movement       ; No keys pressed? Jump straight to Idle State

  ld e, a
  ld b, 0                    ; B = walk flag (0=no, 1=yes)

  ; --- RIGHT CHECK ---
  bit KEY_RIGHT_BIT, e
  jr nz, .not_right_key
  
  ld hl, sprite0_x
  inc (hl)                   ; Move right
  ld hl, player_direction
  ld (hl), PLAYER_DIRECTION_RIGHT
  ld b, 1                    ; Set walk flag
  jr .not_left_key           ; Skip left check if moving right!

.not_right_key:
  ; --- LEFT CHECK ---
  bit KEY_LEFT_BIT, e
  jr nz, .not_left_key
  
  ld hl, sprite0_x
  dec (hl)                   ; Move left
  ld hl, player_direction
  ld (hl), PLAYER_DIRECTION_LEFT
  ld b, 1                    ; Set walk flag

.not_left_key:
  ; --- UP CHECK ---
  bit KEY_UP_BIT, e
  jr nz, .not_up_key
  ld hl, sprite0_y
  dec (hl)
.not_up_key:

  ; --- DOWN CHECK ---
  bit KEY_DOWN_BIT, e
  jr nz, .not_down_key
  ld hl, sprite0_y
  inc (hl)
.not_down_key:

  ; -------------------------------------------------------------
  ; 4. ANIMATION UPDATE (Ping-Pong: 0 -> 4 -> 8 -> 4)
  ; -------------------------------------------------------------
  ld a, b                    ; Check walk flag
  or a                       
  jr z, .movement_done       ; If B is 0, we didn't move left/right. Skip animation.

  ; We are moving left or right! Increment the frame timer.
  ld hl, player_anim_timer
  inc (hl)
  ld a, (hl)
  cp 7                       ; Have 8 frames passed?
  jr c, .apply_anim          ; If timer < 8, keep current animation frame

  ; 8 frames passed: reset timer and advance animation phase (0-3)
  xor a
  ld (hl), a                 ; Reset timer to 0

  ld hl, player_anim_frame
  inc (hl)                   ; Next phase
  ld a, (hl)
  and 3                      ; Mask to keep it between 0 and 3 (0, 1, 2, 3, 0...)
  ld (hl), a

.apply_anim:
  ; Convert Phase (0, 1, 2, 3) into Pattern Offset (0, 4, 8, 4)
  ld a, (player_anim_frame)
  ld c, 4                    ; Pre-load C with 4 (Offset for Phase 3)
  cp 3                       ; Is it Phase 3?
  jr z, .got_offset          ; If yes, skip math! C is already 4.
  
  ; For Phases 0, 1, and 2: Multiply by 4
  add a, a
  add a, a                   ; A is now 0, 4, or 8
  ld c, a                    ; Store offset in C

.got_offset:
  ; Calculate final pattern: Base Pattern + Offset (C)
  ld a, (player_direction)
  cp PLAYER_DIRECTION_RIGHT
  jr z, .base_right

  ; Must be left
  ld a, 0                    ; Left Base Pattern = 0
  jr .calc_pat
  
.base_right:
  ld a, 12                   ; Right Base Pattern = 12

.calc_pat:
  add a, c                   ; A = Base (0 or 12) + Offset (C)
  ld (sprite0_pat), a        
  
  jr .movement_done          ; Skip the idle logic

  ; -------------------------------------------------------------
  ; 5. IDLE STATE (Runs if NO keys are pressed)
  ; -------------------------------------------------------------
.skip_movement:
  ; Reset animation state so the player doesn't get stuck mid-stride next time
  xor a
  ld (player_anim_timer), a
  ld (player_anim_frame), a

  ; Check which way they were facing when they stopped
  ld hl, player_direction
  ld a, (hl)
  
  cp PLAYER_DIRECTION_RIGHT  
  jr nz, .idle_left

  ld a, 16                   ; Right Idle Pattern = 16
  ld (sprite0_pat), a
  jr .movement_done

.idle_left:
  ld a, 4                    ; Left Idle Pattern = 4
  ld (sprite0_pat), a

.movement_done:
  jp stage1_loop


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
