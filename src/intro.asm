intro:
  di

  ; 1. Fix the crash: Call the routines, not the data!
  call set_tile0_colors
  call set_numbers_colors
  call set_alphabet_colors
  call set_static_tiles_color

  ; push_space_anim_frame = 0
  ld hl, push_space_anim_frame
  ld (hl), 0

  call init_dynamic_tiles
  ; 2. Initialize your RAM buffer so the shifting loop has data to shift
  ; update VDP with shifted tile
  ; TOP area
  ld hl, tile0_ram_buffer 
  ld de, $0150          ; <-- CHANGED to Tile $2A
  call ldirvm_8
  
  ; MIDDLE area
  ld hl, tile0_ram_buffer 
  ld de, $0950          ; <-- CHANGED to Tile $2A
  call ldirvm_8
  
  ; BOTTOM area
  ld hl, tile0_ram_buffer
  ld de, $1150          ; <-- CHANGED to Tile $2A
  call ldirvm_8

  call set_dynamic_tiles_color

  ; Load the full screen map
  ld hl, intro_map
  call load_stage_map

  ; Init vars
  ld hl, frame_count
  ld (hl), 0

  ei
.intro_loop:
  call wait_vsync
.intro_vblank_trace_start:

  ; update VDP with shifted tile
  ; (It is safe if this spills out of VBlank because LDIRVM is slow and safe)
  ; TOP area
  ld hl, tile0_ram_buffer 
  ld de, $0150          
  call ldirvm_8
  ; MIDDLE area
  ld hl, tile0_ram_buffer 
  ld de, $0950          
  call ldirvm_8
  ; BOTTOM area
  ld hl, tile0_ram_buffer
  ld de, $1150
  call ldirvm_8 

.intro_vblank_trace_end:
  ; Tile shift logic
  ld a, (frame_count)
  cp 5
  jr nz, .intro_tile_skip_if

  ld hl, tile0_ram_buffer
  call shift_pattern_left

  ; frame_count = 0
  ld hl, frame_count
  ld (hl), 0
  jp .end_intro_loop

.intro_tile_skip_if:
  ld hl, frame_count
  inc (hl)
 
.end_intro_loop:





  ; --- Blinking Text Logic ---
  ld hl, push_space_anim_frame
  inc (hl)
  ld a, (hl)
  
  ; Check Bit 5 (00100000). It flips between 0 and 1 every 32 frames.
  and %00100000       
  jr z, .draw_text
  
.draw_spaces:
  ld hl, push_space_clear
  jr .update_text_vram
  
.draw_text:
  ld hl, push_space_text

.update_text_vram:
  ; We still call LDIRVM every frame, but now it creates an animation
  ld de, $1A69                               
  ld bc, 14 
  call LDIRVM


  jp .intro_loop

tile0_color:
  db $11, $11, $11, $11, $11, $11, $11, $11

number_color:
  db $A1, $A1, $A1, $F1, $F1, $A1, $A1, $A1

alphabet_color:
  db $F1, $F1, $F1, $F1, $F1, $F1, $F1, $F1

static_tile_color:
  db $F4, $F4, $F4, $F4, $F4, $F4, $F4, $F4

dynamic_tile_color:
  db $F4, $F4, $F4, $F4, $F4, $F4, $F4, $F4

push_space_text:
  ; "PUSH SPACE KEY" mapped to your specific Tile IDs
  db $1A, $1F, $1D, $12, $27, $1D, $1A, $0B, $0D, $0F, $27, $15, $0F, $23
push_space_text_end:

push_space_clear:
  ; 14 Space characters ($27)
  db $27, $27, $27, $27, $27, $27, $27, $27, $27, $27, $27, $27, $27, $27

set_tile0_colors:
  ; 1. Top Third (Color Table base $2000 + Tile 0 offset $00)
  ld hl, tile0_color
  ld de, $2000
  call ldirvm_8
  
  ; 2. Middle Third (Color Table base $2800 + Tile 0 offset $00)
  ld hl, tile0_color
  ld de, $2800
  call ldirvm_8
  
  ; 3. Bottom Third (Color Table base $3000 + Tile 0 offset $00)
  ld hl, tile0_color
  ld de, $3000
  call ldirvm_8
  
  ret


set_numbers_colors:
  ; --- 1. Top Third ---
  ld de, $2008           ; VRAM Destination for Tile $01 (Offset $08)
  ld b, $0A              ; Loop 10 times (0 through 9)
.top_loop:
  push bc                ; Protect loop counter
  push de                ; Protect VRAM destination address
  ld hl, number_color
  call ldirvm_8
  pop hl                 ; Pop the old DE into HL so we can do math on it
  ld bc, 8               
  add hl, bc             ; Add 8 bytes to the VRAM address
  ex de, hl              ; Move the new address back into DE
  pop bc                 ; Restore loop counter
  djnz .top_loop

  ; --- 2. Middle Third ---
  ld de, $2808
  ld b, $0A
.mid_loop:
  push bc
  push de
  ld hl, number_color
  call ldirvm_8
  pop hl
  ld bc, 8
  add hl, bc
  ex de, hl
  pop bc
  djnz .mid_loop

  ; --- 3. Bottom Third ---
  ld de, $3008
  ld b, $0A
.bot_loop:
  push bc
  push de
  ld hl, number_color
  call ldirvm_8
  pop hl
  ld bc, 8
  add hl, bc
  ex de, hl
  pop bc
  djnz .bot_loop

  ret


set_alphabet_colors:
  ; --- 1. Top Third ---
  ld de, $2058           ; VRAM Destination for Tile $0B (Offset $58)
  ld b, 26               ; Loop 26 times (A through Z)
.top_alpha_loop:
  push bc
  push de                ; Protect VRAM destination address
  ld hl, alphabet_color 
  call ldirvm_8 
  pop hl                 ; Pop the old DE into HL
  ld bc, 8
  add hl, bc             ; Manually advance to the next tile's VRAM address
  ex de, hl              ; Put it back into DE
  pop bc                 
  djnz .top_alpha_loop

  ; --- 2. Middle Third ---
  ld de, $2858           
  ld b, 26               
.mid_alpha_loop:
  push bc
  push de
  ld hl, alphabet_color
  call ldirvm_8
  pop hl
  ld bc, 8
  add hl, bc
  ex de, hl
  pop bc
  djnz .mid_alpha_loop

  ; --- 3. Bottom Third ---
  ld de, $3058           
  ld b, 26               
.bot_alpha_loop:
  push bc
  push de
  ld hl, alphabet_color
  call ldirvm_8
  pop hl
  ld bc, 8
  add hl, bc
  ex de, hl
  pop bc
  djnz .bot_alpha_loop

  ret


set_static_tiles_color:
  ; --- 1. Top Third ---
  ld de, $2140             ; VRAM Destination for Tile $28 (Offset $0140)
  ld b, 2                  ; Loop 2 times (Tiles $28 and $29)
.top_static_loop:
  push bc
  push de                  ; Protect VRAM destination address
  ld hl, static_tile_color ; Load source color
  call ldirvm_8 
  pop hl                   ; Pop the old DE into HL
  ld bc, 8
  add hl, bc               ; Manually advance to the next tile's VRAM address
  ex de, hl                ; Put it back into DE
  pop bc                 
  djnz .top_static_loop

  ; --- 2. Middle Third ---
  ld de, $2940             ; VRAM Destination for Tile $28 (Offset $0140)
  ld b, 2               
.mid_static_loop:
  push bc
  push de
  ld hl, static_tile_color
  call ldirvm_8
  pop hl
  ld bc, 8
  add hl, bc
  ex de, hl
  pop bc
  djnz .mid_static_loop

  ; --- 3. Bottom Third ---
  ld de, $3140             ; VRAM Destination for Tile $28 (Offset $0140)
  ld b, 2               
.bot_static_loop:
  push bc
  push de
  ld hl, static_tile_color
  call ldirvm_8
  pop hl
  ld bc, 8
  add hl, bc
  ex de, hl
  pop bc
  djnz .bot_static_loop

  ret


set_dynamic_tiles_color:
  ; --- 1. Top Third ---
  ld de, $2150             ; VRAM Destination for Tile $2A (Offset $0150)
  ld b, 2                  ; Loop 2 times (Tiles $2A and $2B)
.top_dynamic_loop:
  push bc
  push de                  ; Protect VRAM destination address
  ld hl, dynamic_tile_color ; Load source color
  call ldirvm_8 
  pop hl                   ; Pop the old DE into HL
  ld bc, 8
  add hl, bc               ; Manually advance to the next tile's VRAM address
  ex de, hl                ; Put it back into DE
  pop bc                 
  djnz .top_dynamic_loop

  ; --- 2. Middle Third ---
  ld de, $2950             ; VRAM Destination for Tile $2A (Offset $0150)
  ld b, 2               
.mid_dynamic_loop:
  push bc
  push de
  ld hl, dynamic_tile_color
  call ldirvm_8
  pop hl
  ld bc, 8
  add hl, bc
  ex de, hl
  pop bc
  djnz .mid_dynamic_loop

  ; --- 3. Bottom Third ---
  ld de, $3150             ; VRAM Destination for Tile $2A (Offset $0150)
  ld b, 2               
.bot_dynamic_loop:
  push bc
  push de
  ld hl, dynamic_tile_color
  call ldirvm_8
  pop hl
  ld bc, 8
  add hl, bc
  ex de, hl
  pop bc
  djnz .bot_dynamic_loop

  ret


init_dynamic_tiles:
  ; 1. Copy the base pattern from ROM to our RAM buffer
  ld hl, _tile0_pattern     ; Source: Pattern in ROM
  ld de, tile0_ram_buffer   ; Dest: RAM Buffer
  ld bc, 8                  ; 8 bytes long
  ldir                      ; Block copy

  ; 2. Top Third: Upload RAM buffer to Tile $2A pattern slot
  ld hl, tile0_ram_buffer
  ld de, $0150              ; Base $0000 + Offset $0150
  call ldirvm_8

  ; 3. Middle Third: Upload RAM buffer to Tile $2A pattern slot
  ld hl, tile0_ram_buffer
  ld de, $0950              ; Base $0800 + Offset $0150
  call ldirvm_8

  ; 4. Bottom Third: Upload RAM buffer to Tile $2A pattern slot
  ld hl, tile0_ram_buffer
  ld de, $1150              ; Base $1000 + Offset $0150
  call ldirvm_8

  ret

