; ==============================================================================
; npc.asm
; Contains all NPC AI, movement, and animation logic.
; ==============================================================================

; ==============================================================================
; Routine:      update_npcs
; Description:  AI chases player at 1/3rd speed. Updates X coordinate every 
;               3 frames, but keeps animation running smoothly.
; Destroys:     AF, C, HL
; ==============================================================================
update_npcs:
  ; 1. AI Movement Logic
  ld a, (sprite0_x)          
  ld hl, sprite1_x           
  cp (hl)                    
  jr z, .npc1_stop_moving    

  jr c, .npc1_set_left       
  
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
  
  ; 3. Handle 1/3 Speed Delay
  ld hl, npc1_move_timer
  inc (hl)
  ld a, (hl)
  cp 3
  jr c, .npc1_update_anim    
  
  xor a
  ld (hl), a                 
  
  ld a, (npc1_direction)
  or a                       
  ld hl, sprite1_x
  jr nz, .npc1_do_move_left

.npc1_do_move_right:
  inc (hl)                   
  jr .npc1_update_anim

.npc1_do_move_left:
  dec (hl)                   
  jr .npc1_update_anim

.npc1_stop_moving:
  xor a
  ld (npc1_is_walking), a
  ld (npc1_move_timer), a    

  ; 5. NPC Animation Logic 
.npc1_update_anim:
  ld a, (npc1_is_walking)
  or a                       
  jr z, .npc1_set_idle_state      

  ld hl, npc1_anim_timer
  inc (hl)
  ld a, (hl)
  cp 24                      
  jr c, .npc1_apply_anim          

  xor a
  ld (hl), a                 

  ld hl, npc1_anim_frame
  inc (hl)                   
  ld a, (hl)
  and 3                      
  ld (hl), a

.npc1_apply_anim:
  ld a, (npc1_anim_frame)
  ld c, 4                    
  cp 3                       
  jr z, .npc1_got_offset          
  
  add a, a
  add a, a                   
  ld c, a                    

.npc1_got_offset:
  ld a, (npc1_direction)
  cp PLAYER_DIRECTION_RIGHT
  jr z, .npc1_base_right

  ld a, 0                    
  jr .npc1_calc_pat
  
.npc1_base_right:
  ld a, 12                   

.npc1_calc_pat:
  add a, c                   
  ld (sprite1_pat), a        
  ret                        

.npc1_set_idle_state:
  xor a
  ld (npc1_anim_timer), a
  ld (npc1_anim_frame), a  

  ld a, (npc1_direction)
  cp PLAYER_DIRECTION_RIGHT  
  jr nz, .npc1_idle_left

  ld a, 16                   
  ld (sprite1_pat), a
  ret

.npc1_idle_left:
  ld a, 4                    
  ld (sprite1_pat), a
  ret

