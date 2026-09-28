; ==============================================================================
; Routine:      load_sprite_patterns
; Description:  Copies all auto-generated sprite graphics from ROM to the 
;               SCREEN 2 Sprite Pattern Generator Table (SPG) in VRAM. It 
;               automatically calculates the byte length based on the 
;               parser-generated start and end labels.
;
; [!] WARNING:  Interrupts MUST be disabled (DI) before calling this routine,
;               as it relies on 'write_vram_large' which uses direct VDP port
;               I/O and will corrupt if a VBlank interrupts the address setup.
;
; Inputs:       None (Relies on hardcoded label addresses)
; Destroys:     A, BC, DE, HL (Propagated from write_vram_large)
; ==============================================================================
load_sprite_patterns:
  ld hl, sprite_patterns_start
  ld de, VRAM_SCR2_SPR_PATTERNS
  ld bc, sprite_patterns_end - sprite_patterns_start
  call write_vram_large
  ret


; ==============================================================================
; Routine:      loadSpriteAttributes
; Description:  Transfers Shadow RAM to VRAM for a specific number of sprites.
; Inputs:       A = Number of sprites to transfer (0 to 32)
; Destroys:     A, B, C, HL
; ==============================================================================
loadSpriteAttributes:
  or a                           ; Fast way to check if A is 0
  ret z                          ; If 0 sprites, exit immediately

  ; Multiply A by 4 (4 bytes per sprite)
  add a, a                       
  add a, a                       
  ld b, a                        ; Store total byte count in B for OTIR

  ld hl, shadow_sat              ; Source RAM
  ld c, VDP_DATA_PORT            ; VDP data port

  di                             ; Disable interrupts for VDP setup AND transfer

  ; Set VRAM address: low byte 
  ld a, VRAM_SCR2_SPR_ATTRIBS & $FF  
  out (VDP_CONTROL_PORT), a

  ; Set VRAM address: high byte 
  ld a, VRAM_SCR2_SPR_ATTRIBS >> 8   
  and $3f                        ; Clear top 2 bits (safety mask)
  or $40                         ; Set bit 6 to enable VDP WRITE mode
  out (VDP_CONTROL_PORT), a

  ; Transfer data
  otir                           ; Output (HL) -> PORT C, HL++, B--
  ei                             ; Re-enable interrupts AFTER transfer
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
  ld hl, sprite0_attributes_data
  ld de, shadow_sat
  ld bc, INIT_NUM_SPRITES * 4
  ldir

  ; 2. Send it to VDP
  ld hl, shadow_sat
  ld de, $1B00                      ; VRAM Address for SCREEN 2 Sprite Attribute Table
  ld bc, INIT_NUM_SPRITES * 4       ; We are copying 4 bytes (1 sprite)
  call write_vram_large
  ret


; ==============================================================================
; Routine:      load_all_tile_patterns
; Description:  Copies all tile graphics to all three thirds of SCREEN 2
; Destroys:     A, BC, DE, HL
; ==============================================================================
load_tile_patterns:
  di
  
  ; --- 1. Top Third (VRAM $0000) ---
  ld hl, tile_patterns_start
  ld de, $0000
  ld bc, tile_patterns_end - tile_patterns_start
  call write_vram_large
  
  ; --- 2. Middle Third (VRAM $0800) ---
  ld hl, tile_patterns_start
  ld de, $0800
  ld bc, tile_patterns_end - tile_patterns_start
  call write_vram_large
  
  ; --- 3. Bottom Third (VRAM $1000) ---
  ld hl, tile_patterns_start
  ld de, $1000
  ld bc, tile_patterns_end - tile_patterns_start
  call write_vram_large
  
  ei
  ret


; ==============================================================================
; Routine:      load_all_tile_colors
; Description:  Copies all tile colors to all three thirds of SCREEN 2
; ==============================================================================
load_tile_colors:
  di
  
  ; --- 1. Top Third Color (VRAM $2000) ---
  ld hl, tile_colors_start
  ld de, $2000
  ld bc, tile_colors_end - tile_colors_start
  call write_vram_large
  
  ; --- 2. Middle Third Color (VRAM $2800) ---
  ld hl, tile_colors_start
  ld de, $2800
  ld bc, tile_colors_end - tile_colors_start
  call write_vram_large
  
  ; --- 3. Bottom Third Color (VRAM $3000) ---
  ld hl, tile_colors_start
  ld de, $3000
  ld bc, tile_colors_end - tile_colors_start
  call write_vram_large
  
  ei
  ret


init_tiles:
  di
  
  ; Note: If load_all_tile_colors exists in your assets.asm, call it here, 
  ; otherwise remove it if you are setting colors manually below.

  ; -------------------------------------------------------------
  ; Setup Tile ID 0x00 (Background/Water)
  ; -------------------------------------------------------------
  ld hl, _blank_pattern      ; Source ROM graphic
  ld de, tile0_ram_buffer    ; Target RAM buffer
  ld a, 0                    ; Tile ID 0
  call setup_dynamic_tile

  ld hl, tile0_color
  ld a, 0
  call load_tile_color

  ; -------------------------------------------------------------
  ; Setup Tile ID 0x01 (Wall 1)
  ; -------------------------------------------------------------
  ld hl, _tile0_pattern      ; Source ROM graphic
  ld de, tile1_ram_buffer    ; Target RAM buffer
  ld a, 1                    ; Tile ID 1
  call setup_dynamic_tile

  ; ld hl, tile1_color
  ; ld a, 1
  ; call load_tile_color

  ; -------------------------------------------------------------
  ; Setup Tile ID 0x02 (Wall 2)
  ; -------------------------------------------------------------
  ld hl, _tile1_pattern      ; Source ROM graphic
  ld de, tile2_ram_buffer    ; Target RAM buffer
  ld a, 2                    ; Tile ID 2
  call setup_dynamic_tile

  ; ld hl, tile2_color
  ; ld a, 2
  ; call load_tile_color

  ; Set the tile name for screen position 0 (Top-left)
  ld hl, $1800        
  ld a, 0             
  call WRTVRM         
  
  ret


; ==============================================================================
; Routine:      setup_dynamic_tile
; ==============================================================================
setup_dynamic_tile:
  ; 1. Copy ROM Pattern to RAM Buffer
  push af           
  push de           
  ld bc, 8
  ldir              

  ; 2. Calculate VRAM Offset (Tile ID * 8)
  pop hl            
  pop af            

  ld c, a
  ld b, 0
  sla c             
  rl b
  sla c             
  rl b
  sla c             
  rl b              

  ; 3. Upload to Top Third ($0000 + Offset)
  push hl           
  push bc           
  ld hl, $0000
  add hl, bc
  ex de, hl         
  pop bc
  pop hl
  push hl           
  push bc
  call ldirvm_8     

  ; 4. Upload to Middle Third ($0800 + Offset)
  pop bc
  pop hl
  push hl
  push bc
  ld hl, $0800
  add hl, bc
  ex de, hl         
  call ldirvm_8

  ; 5. Upload to Bottom Third ($1000 + Offset)
  pop bc
  pop hl
  ld hl, $1000
  add hl, bc
  ex de, hl         
  call ldirvm_8
  ret

; ==============================================================================
; Routine:      load_tile_color
; ==============================================================================
load_tile_color:
  ; 1. Calculate VRAM Offset (Tile ID * 8)
  ld c, a
  ld b, 0
  sla c
  rl b
  sla c
  rl b
  sla c
  rl b

  ; 2. Top Third ($2000 + Offset)
  push hl       
  push bc       
  ld hl, $2000
  add hl, bc
  ex de, hl     
  pop bc        
  pop hl        
  push hl       
  push bc
  call ldirvm_8 

  ; 3. Middle Third ($2800 + Offset)
  pop bc
  pop hl
  push hl
  push bc
  ld hl, $2800
  add hl, bc
  ex de, hl     
  call ldirvm_8

  ; 4. Bottom Third ($3000 + Offset)
  pop bc
  pop hl
  ld hl, $3000
  add hl, bc
  ex de, hl     
  call ldirvm_8
  ret

