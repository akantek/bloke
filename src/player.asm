; ==============================================================================
; player.asm
; Contains all player input, movement, and animation logic.
; ==============================================================================

; --- Player Animation Constants ---
PLAYER_PAT_BASE_LEFT:  equ 0    ; Walk cycle left starts at pattern 0
PLAYER_PAT_IDLE_LEFT:  equ 4    ; Idle left is pattern 4
PLAYER_PAT_BASE_RIGHT: equ 12   ; Walk cycle right starts at pattern 12
PLAYER_PAT_IDLE_RIGHT: equ 16   ; Idle right is pattern 16

; --- Animation Timing & Math ---
ANIM_SPEED:            equ 8    ; Number of VBlanks per frame
ANIM_PHASE_PINGPONG:   equ 3    ; The 4th phase of the walk cycle (the return stride)
ANIM_OFFSET_PINGPONG:  equ 4    ; Pattern offset to reuse the middle stride frame

; ==============================================================================
; Routine:      update_player_movement
; Description:  Scans the keyboard, updates sprite0 X/Y coordinates, sets the 
;               player_direction flag, and toggles the player_is_walking state.
;               Includes early-exit optimization if no keys are pressed.
;
; Inputs:       None
; Outputs:      Updates RAM: sprite0_x, sprite0_y, player_direction, 
;               player_is_walking
; Destroys:     AF, C (from scan_keypad), E, HL
; ==============================================================================
update_player_movement:
  ; 1. Reset walking flag at the start of every frame
  xor a
  ld (player_is_walking), a

  ; 2. Read Keyboard
  call scan_keypad
  cp $F7                     
  ret z                      

  ld e, a                    

  ; --- RIGHT CHECK ---
  bit KEY_RIGHT_BIT, e
  jr nz, .not_right_key
  
  ; 1. Move Player RIGHT
  ld hl, sprite0_x
  inc (hl)                   
  
  ; 2. Update State
  ld a, PLAYER_DIRECTION_RIGHT
  ld (player_direction), a   
  
  ld a, 1
  ld (player_is_walking), a

  jr .not_left_key           

.not_right_key:
  ; --- LEFT CHECK ---
  bit KEY_LEFT_BIT, e
  jr nz, .not_left_key
  
  ; 1. Move Player LEFT
  ld hl, sprite0_x
  dec (hl)                   

  ; 2. Update State
  ld a, PLAYER_DIRECTION_LEFT
  ld (player_direction), a   

  ld a, 1
  ld (player_is_walking), a  

.not_left_key:
  ; --- UP CHECK ---
  bit KEY_UP_BIT, e
  jr nz, .not_up_key

  ; 1. Move Player UP
  ld hl, sprite0_y
  dec (hl)
           
.not_up_key:

  ; --- DOWN CHECK ---
  bit KEY_DOWN_BIT, e
  jr nz, .not_down_key

  ; 1. Move Player DOWN
  ld hl, sprite0_y
  inc (hl)                   
.not_down_key:  
  ret

; ==============================================================================
; Routine:      update_player_animation
; Description:  Reads the player_is_walking flag to determine if the player 
;               should be animated. Calculates the ping-pong walking animation 
;               frames (0->4->8->4 offsets) every 8 VBlanks. If stopped, snaps 
;               the sprite to the correct directional Idle Pattern.
;
; Inputs:       None (Reads RAM: player_is_walking, player_direction)
; Outputs:      Updates RAM: sprite0_pat, player_anim_timer, player_anim_frame
; Destroys:     AF, C, HL
; ==============================================================================
update_player_animation:
  ld a, (player_is_walking)
  or a                       
  jr z, .set_idle_state      

  ; --- WALKING ANIMATION ---
  ld hl, player_anim_timer
  inc (hl)
  ld a, (hl)
  cp ANIM_SPEED                  
  jr c, .apply_anim          

  ; --- 1. Reset Timer ---
  xor a
  ld (hl), a                

  ; --- 2. Advance Animation Frame ---
  ld hl, player_anim_frame
  inc (hl)                   
  ld a, (hl)
  and 3                      ; Keep frame bounded between 0 and 3
  ld (hl), a

.apply_anim:
  ld a, (player_anim_frame)
  ld c, ANIM_OFFSET_PINGPONG ; Pre-load C with the return stride offset (4)
  cp ANIM_PHASE_PINGPONG     ; Are we on the final ping-pong phase (3)?
  jr z, .got_offset          ; If yes, skip the math! C is already correct.       
  
  ; Multiply frame (0, 1, or 2) by 4 to get pattern offset (0, 4, or 8)
  add a, a                   ; x 2
  add a, a                   ; x 4
  ld c, a                    ; C now holds the offset                

.got_offset:
  ; --- 4. Determine Directional Base Pattern ---
  ld a, (player_direction)
  cp PLAYER_DIRECTION_RIGHT
  jr z, .base_right

  ; Facing Left
  ld a, PLAYER_PAT_BASE_LEFT         ; Base pattern for Left (0)
  jr .calc_pat
  
.base_right:
  ld a, PLAYER_PAT_BASE_RIGHT        ; Base pattern for Right (12)

.calc_pat:
  ; --- 5. Apply Offset and Save ---
  add a, c                           ; Final Pattern = Base Pattern (A) + Anim Offset (C)
  ld (sprite0_pat), a                ; Save to the Sprite Attribute Table shadow RAM
  ret                        

  ; ==========================================================================
  ; IDLE STATE (Player is stopped)
  ; ==========================================================================
.set_idle_state:
  ; 1. Reset animation counters so the next walk cycle starts cleanly at frame 0
  xor a
  ld (player_anim_timer), a
  ld (player_anim_frame), a  

  ; 2. Snap the sprite to the correct directional idle frame
  ld a, (player_direction)
  cp PLAYER_DIRECTION_RIGHT  
  jr nz, .idle_left

  ; Snap to Idle Right
  ld a, PLAYER_PAT_IDLE_RIGHT        ; (16)
  ld (sprite0_pat), a
  ret

.idle_left:
  ; Snap to Idle Left
  ld a, PLAYER_PAT_IDLE_LEFT         ; (4)
  ld (sprite0_pat), a
  ret

