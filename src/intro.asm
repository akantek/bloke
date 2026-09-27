intro:
  di
  call init_tiles

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
  ld de, $0000          
  call ldirvm_8
  ; MIDDLE area
  ld hl, tile0_ram_buffer 
  ld de, $0800          
  call ldirvm_8
  ; BOTTOM area
  ld hl, tile0_ram_buffer
  ld de, $1000
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
  jp .intro_loop

