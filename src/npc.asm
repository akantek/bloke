; ==============================================================================
; npc.asm
; Contains all NPC AI, movement, and animation logic.
; ==============================================================================

; --- NPC Movement Constants ---
NPC_SPEED_DELAY:        equ 3    ; Update X coordinate every 3 frames (1/3 speed)
NPC_ANIM_SPEED:         equ 24   ; Delay animation to match slow walk (8 * 3)

; ==============================================================================
; Routine:      update_npcs
; Description:  AI chases player at 1/3rd speed. Updates X coordinate every 
;               3 frames, but keeps animation running smoothly.
; Destroys:     AF, C, HL
; ==============================================================================
update_npcs:
  ; ==========================================================================
  ; Phase 1: AI Logic (Determine Intended Direction)
  ; ==========================================================================
  ld a, (sprite0_x)          
  ld hl, sprite1_x           
  cp (hl)                    
  jr z, .npc1_stop_moving    ; If Player X == NPC X, stop moving

  jr c, .npc1_set_left       ; If Player X < NPC X (carry set), move left
  
.npc1_set_right:
  ld a, PLAYER_DIRECTION_RIGHT
  ld (npc1_direction), a
  jr .npc1_check_timer

.npc1_set_left:
  ld a, PLAYER_DIRECTION_LEFT
  ld (npc1_direction), a

.npc1_check_timer:
  ld a, 1
  ld (npc1_is_walking), a
  
  ; ==========================================================================
  ; Phase 2: Apply Movement (With 1/3 Speed Delay)
  ; ==========================================================================
  ld hl, npc1_move_timer
  inc (hl)
  ld a, (hl)
  cp NPC_SPEED_DELAY
  jr c, .npc1_update_anim    ; If timer < delay, skip actual X movement
  
  ; Timer reached delay limit: Reset timer and move
  xor a
  ld (hl), a                 
  
  ld a, (npc1_direction)
  or a                       ; Check if facing Right (0) or Left (1)
  ld hl, sprite1_x
  jr nz, .npc1_do_move_left

.npc1_do_move_right:
  inc (hl)                   
  jr .npc1_update_anim

.npc1_do_move_left:
  dec (hl)                   
  jr .npc1_update_anim

  ; --- Stopped State ---
.npc1_stop_moving:
  xor a
  ld (npc1_is_walking), a
  ld (npc1_move_timer), a    

  ; ==========================================================================
  ; Phase 3: Animation State (Walk Cycle or Idle Snap)
  ; ==========================================================================
.npc1_update_anim:
  ld a, (npc1_is_walking)
  or a                       
  jr z, .npc1_set_idle_state      

  ; --- WALKING ANIMATION ---
  ld hl, npc1_anim_timer
  inc (hl)
  ld a, (hl)
  cp NPC_ANIM_SPEED          ; Slower animation limit (24 frames)
  jr c, .npc1_apply_anim          

  ; Reset Timer
  xor a
  ld (hl), a                 

  ; Advance Animation Frame
  ld hl, npc1_anim_frame
  inc (hl)                   
  ld a, (hl)
  and 3                      ; Keep frame bounded between 0 and 3
  ld (hl), a

.npc1_apply_anim:
  ; --- Calculate Ping-Pong Offset ---
  ld a, (npc1_anim_frame)
  ld c, ANIM_OFFSET_PINGPONG 
  cp ANIM_PHASE_PINGPONG     ; Are we on the final ping-pong return stride (3)?
  jr z, .npc1_got_offset          
  
  ; Multiply frame (0, 1, or 2) by 4 to get pattern offset (0, 4, or 8)
  add a, a                   
  add a, a                   
  ld c, a                    

.npc1_got_offset:
  ; --- Determine Directional Base Pattern ---
  ld a, (npc1_direction)
  cp PLAYER_DIRECTION_RIGHT
  jr z, .npc1_base_right

  ; Facing Left
  ld a, PLAYER_PAT_BASE_LEFT
  jr .npc1_calc_pat
  
.npc1_base_right:
  ld a, PLAYER_PAT_BASE_RIGHT

.npc1_calc_pat:
  ; --- Apply Offset and Save ---
  add a, c                   ; Final Pattern = Base (A) + Offset (C)
  ld (sprite1_pat), a        
  ret                        

  ; ==========================================================================
  ; Phase 4: Idle State (Snapped when stopped)
  ; ==========================================================================
.npc1_set_idle_state:
  ; Reset animation counters so the next walk cycle starts cleanly
  xor a
  ld (npc1_anim_timer), a
  ld (npc1_anim_frame), a  

  ; Snap the sprite to the correct directional idle frame
  ld a, (npc1_direction)
  cp PLAYER_DIRECTION_RIGHT  
  jr nz, .npc1_idle_left

  ; Snap to Idle Right
  ld a, PLAYER_PAT_IDLE_RIGHT
  ld (sprite1_pat), a
  ret

.npc1_idle_left:
  ; Snap to Idle Left
  ld a, PLAYER_PAT_IDLE_LEFT
  ld (sprite1_pat), a
  ret

