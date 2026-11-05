; ==============================================================================
; player.asm
; Contains all player input, movement, and animation logic.
; ==============================================================================

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
  
  ld hl, sprite0_x
  inc (hl)                   
  ld a, PLAYER_DIRECTION_RIGHT
  ld (player_direction), a   
  ld a, 1
  ld (player_is_walking), a  
  jr .not_left_key           

.not_right_key:
  ; --- LEFT CHECK ---
  bit KEY_LEFT_BIT, e
  jr nz, .not_left_key
  
  ld hl, sprite0_x
  dec (hl)                   
  ld a, PLAYER_DIRECTION_LEFT
  ld (player_direction), a   
  ld a, 1
  ld (player_is_walking), a  

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
  cp 8                       
  jr c, .apply_anim          

  xor a
  ld (hl), a                 

  ld hl, player_anim_frame
  inc (hl)                   
  ld a, (hl)
  and 3                      
  ld (hl), a

.apply_anim:
  ld a, (player_anim_frame)
  ld c, 4                    
  cp 3                       
  jr z, .got_offset          
  
  add a, a
  add a, a                   
  ld c, a                    

.got_offset:
  ld a, (player_direction)
  cp PLAYER_DIRECTION_RIGHT
  jr z, .base_right

  ld a, 0                    
  jr .calc_pat
  
.base_right:
  ld a, 12                   

.calc_pat:
  add a, c                   
  ld (sprite0_pat), a        
  ret                        

  ; --- IDLE STATE ---
.set_idle_state:
  xor a
  ld (player_anim_timer), a
  ld (player_anim_frame), a  

  ld a, (player_direction)
  cp PLAYER_DIRECTION_RIGHT  
  jr nz, .idle_left

  ld a, 16                   
  ld (sprite0_pat), a
  ret

.idle_left:
  ld a, 4                    
  ld (sprite0_pat), a
  ret

