; sb2.asm - クリア演出
;

; モジュールの宣言
;
    module  game


; ファイルの参照
;
    include "xcs.inc"
    include "app.inc"
    include "game.inc"
    include "var.inc"
    include "sb2.inc"


; コードの定義
;
    section app

; firworks
;
_sb2:

    ; enable hi-res graphics, mixed-mode.
    ld      d, $00
    call    _xcs_clear_graphic_vram
    call    _game_hires
    
    ; init data area ($9000-99ff) to zeroes.
    xor     a
    ld      hl, APP_PTR_STORAGE + $0000
    ld      de, APP_PTR_STORAGE + $0001
    ld      bc, $0a00 - $0001
    ld      (hl), a
    ldir
    ld      hl, _var_sb2 + $0000
    ld      de, _var_sb2 + $0001
    ld      bc, VAR_SB2_SIZE - $0001
    ld      (hl), a
    ldir
    ld      a, $01
    ld      (_var_sb2 + VAR_SB2_CUR_DELTA_X), a
    ld      a, $fe
    ld      (_var_sb2 + VAR_SB2_CUR_DELTA_Y), a

    ; copy data from 7E4C-7E51 to $363-367.
    ld      hl, _var_sb2_move_cadences
    ld      de, _var_sb2 + VAR_SB2_UPDATE_CADENCE
    ld      bc, $0005
    ldir

    ; it works like this:
    ;  - pick a random center point and a color for the explosion.
    ;  - start generating particles from that center point.
    ;  - every M cycles, move particles (M varies by particle set).
    ;  - after N cycles, start a new firework.
    ;
    ; existing particles continue to move until the explosion gets overwritten by a new one.
    ; they disappear when something else occupies their slot.
    ; the CDOT code performs clipping at screen boundaries.
    ;
    ; there are five particle sets.
    ; new particles pick a number from 0-23, then get a movement vector and a set number from a 24-entry table.
.sb2_loop

    ; pick random values for firework position and inter-explosion delay.
    ld      a, (_var_sb2 + VAR_SB2_ALWAYS_ONE)
    or      a
    jr      nz, sb2_firework

    call    _xcs_get_random_number
.sb2_random_explosion
    sub     96
    jr      nc, sb2_random_explosion
    add     a, 96
    or      $23
    ld      (_var_sb2 + VAR_SB2_NEXT_EXPLOSION_CTR), a
    call    _xcs_get_random_number
    and     $7f
    add     a, 16
    ld      (_var_sb2 + VAR_SB2_CENTER_X), a
    call    _xcs_get_random_number
    and     $3f
    add     a, 8
    ld      (_var_sb2 + VAR_SB2_CENTER_Y), a

    ; change color.
.sb2_change_color
    call    _xcs_get_random_number
    and     $07
    jr      z, sb2_change_color
    cp      $05
    jr      z, sb2_change_color
    ld      (_var_sb2 + VAR_SB2_NEXT_COLOR), a

    ld      a, 1
    ld      (_var_sb2 + VAR_SB2_ALWAYS_ONE), a

    ; firework loop.
.sb2_firework
    ld      bc, $0004
.sb2_firework_loop
    ld      hl, _var_sb2 + VAR_SB2_UPDATE_CADENCE
    add     hl, bc
    dec     (hl)
    jr      nz, sb2_firework_next
    push    bc
    call    sb2_update_particles
    pop     bc
    ld      hl, _var_sb2_move_cadences
    add     hl, bc
    ld      a, (hl)
    ld      hl, _var_sb2 + VAR_SB2_UPDATE_CADENCE
    add     hl, bc
    ld      (hl), a
.sb2_firework_next
    dec     c
    ld      a, c
    cp      -1
    jr      nz, sb2_firework_loop

    ; increment 24-bit counter.
    ld      hl, _var_sb2 + VAR_SB2_COUNTER_24BIT_0
    inc     (hl)
    jr      nz, sb2_increment_24_end
    inc     hl
    inc     (hl)
    jr      nz, sb2_increment_24_end
    inc     hl
    inc     (hl)
.sb2_increment_24_end
    ld      a, (_var_sb2 + VAR_SB2_NEXT_EXPLOSION_CTR)
    sub     1
    ld      (_var_sb2 + VAR_SB2_NEXT_EXPLOSION_CTR), a
    jr      nc, sb2_create
    ld      hl, _var_sb2 + VAR_SB2_ALWAYS_ONE
    dec     (hl)
    jr      sb2_next
.sb2_create
    call    sb2_create_particle

.sb2_next
    call    _app_update
    ld      a, (_xcs_key_code_edge)
    or      a
    jp      z, sb2_loop

    ret

; moves particles in one firework set.
; on entry:
;   X-reg: firework set (0-4)
;
sb2_update_particles:

    ; IN
    ;   c = firework set (0-4)

    ; extract pointers into DP.
    sla     c
    ld      b, $00
    ld      hl, _var_sb2_addr0
    add     hl, bc
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ld      (_var_sb2 + VAR_SB2_PTR_X0), de
    ld      hl, _var_sb2_addr1
    add     hl, bc
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ld      (_var_sb2 + VAR_SB2_PTR_Y0), de
    ld      hl, _var_sb2_addr2
    add     hl, bc
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ld      (_var_sb2 + VAR_SB2_PTR_DELTAX), de
    ld      hl, _var_sb2_addr3
    add     hl, bc
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ld      (_var_sb2 + VAR_SB2_PTR_DELTAY), de
    ld      hl, _var_sb2_addr4
    add     hl, bc
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ld      (_var_sb2 + VAR_SB2_STATE_PTR48), de
    ld      hl, _var_sb2_addr5
    add     hl, bc
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ld      (_var_sb2 + VAR_SB2_PTR_COLOR), de
    srl     c
    ld      hl, _var_sb2_max_particle_counts
    add     hl, bc
    ld      a, (hl)
    ld      (_var_sb2 + VAR_SB2_MAX_PARTICLE_COUNT), a
    ld      e, a
    ld      hl, _var_sb2 + VAR_SB2_NEXT_PARTICLE_INDEX
    add     hl, bc
    ld      a, (hl)
    inc     a
    cp      e
    jr      c, sb2_update_particles_start
    xor     a
.sb2_update_particles_start
    ld      (_var_sb2 + VAR_SB2_PARTICLE_INDEX), a

.sb2_update_particles_loop
    ld      hl, _var_sb2 + VAR_SB2_NEXT_PARTICLE_INDEX
    add     hl, bc
    ld      a, (_var_sb2 + VAR_SB2_PARTICLE_INDEX)
    cp      (hl)
    jr      z, sb2_update_particles_end
    push    bc
    ld      c, a
    ld      b, $00

    ; erase dot.
    ld      hl, (_var_sb2 + VAR_SB2_PTR_X0)
    add     hl, bc
    ld      e, (hl)
    ld      hl, (_var_sb2 + VAR_SB2_PTR_Y0)
    add     hl, bc
    ld      d, (hl)
    xor     a
    call    _game_draw_dot

    ; update X0 position.
    ld      hl, (_var_sb2 + VAR_SB2_PTR_DELTAX)
    add     hl, bc
    ld      a, (hl)
    ld      hl, (_var_sb2 + VAR_SB2_PTR_X0)
    add     hl, bc
    add     a, (hl)
    ld      (hl), a

    ; update Y0 position.
    ld      hl, (_var_sb2 + VAR_SB2_PTR_DELTAY)
    add     hl, bc
    ld      a, (hl)
    ld      hl, (_var_sb2 + VAR_SB2_PTR_Y0)
    add     hl, bc
    add     a, (hl)
    ld      (hl), a
            
    ; draw dot.
    ld      hl, (_var_sb2 + VAR_SB2_PTR_X0)
    add     hl, bc
    ld      e, (hl)
    ld      hl, (_var_sb2 + VAR_SB2_PTR_Y0)
    add     hl, bc
    ld      d, (hl)
    ld      hl, (_var_sb2 + VAR_SB2_PTR_COLOR)
    add     hl, bc
    ld      a, (hl)
    call    _game_draw_dot

    ; increment counter.
    pop     bc
    inc     c
    ld      a, (_var_sb2 + VAR_SB2_MAX_PARTICLE_COUNT)
    ld      e, a
    ld      a, c
    cp      e
    jr      c, sb2_update_particles_next
    xor     a
.sb2_update_particles_next
    ld      (_var_sb2 + VAR_SB2_PARTICLE_INDEX), a
    jr      sb2_update_particles_loop

.sb2_update_particles_end
    ret

; creates a new particle, with random velocity, from the current explosion center.
;
sb2_create_particle:

    call    _xcs_get_random_number
    and     $7f
.sb2_create_particle_velocity
    sub     24
    jr      nc, sb2_create_particle_velocity
    add     24
    ld      (_var_sb2 + VAR_SB2_VELOCITY), a
    ld      c, a
    ld      b, $00

    ; get randomly selected deltaX/deltaY and particle sets.
    ;
    ; particle movement is not purely random.
    ; the possible movements are defined in tables, but the table entry is chosen at random.
    ;
    ; one consequence is that particles in certain sets move in certain ways.
    ; for example, particles in set 0 move vertically or horizontally.
    ; this is why setting 7A81:00 limits particle movement: we're only moving the particles in set 0.
    ld      hl, _var_sb2_delta_x_24
    add     hl, bc
    ld      a, (hl)
    ld      (_var_sb2 + VAR_SB2_CUR_DELTA_X), a
    ld      hl, _var_sb2_delta_y_24
    add     hl, bc
    ld      a, (hl)
    ld      (_var_sb2 + VAR_SB2_CUR_DELTA_Y), a

    ; particle set (0-4).
    ld      hl, _var_sb2_setindex_24
    add     hl, bc
    ld      a, (hl)
    ld      (_var_sb2 + VAR_SB2_I_24), a
    ld      c, a
    ld      b, $00

    ; set up pointers based on state index (0-4).
    sla     c
    ld      hl, _var_sb2_addr0
    add     hl, bc
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ld      (_var_sb2 + VAR_SB2_PTR_X0), de
    ld      hl, _var_sb2_addr1
    add     hl, bc
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ld      (_var_sb2 + VAR_SB2_PTR_Y0), de
    ld      hl, _var_sb2_addr2
    add     hl, bc
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ld      (_var_sb2 + VAR_SB2_PTR_DELTAX), de
    ld      hl, _var_sb2_addr3
    add     hl, bc
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ld      (_var_sb2 + VAR_SB2_PTR_DELTAY), de
    ld      hl, _var_sb2_addr4
    add     hl, bc
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ld      (_var_sb2 + VAR_SB2_STATE_PTR48), de
    ld      hl, _var_sb2_addr5
    add     hl, bc
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ld      (_var_sb2 + VAR_SB2_PTR_COLOR), de
    srl     c
    ld      hl, _var_sb2_max_particle_counts
    add     hl, bc
    ld      a, (hl)
    ld      (_var_sb2 + VAR_SB2_MAX_PARTICLE_COUNT), a
    ld      hl, _var_sb2 + VAR_SB2_NEXT_PARTICLE_INDEX
    add     hl, bc
    ld      a, (hl)
    ld      (_var_sb2 + VAR_SB2_PARTICLE_INDEX), a
    ld      c, a
    ld      b, $00

    ; erase the dot we're replacing.
    ld      hl, (_var_sb2 + VAR_SB2_PTR_X0)
    add     hl, bc
    ld      e, (hl)
    ld      hl, (_var_sb2 + VAR_SB2_PTR_Y0)
    add     hl, bc
    ld      d, (hl)
    xor     a
    call    _game_draw_dot

    ; set up deltaX/deltaY.
    ld      hl, (_var_sb2 + VAR_SB2_PTR_DELTAX)
    add     hl, bc
    ld      a, (_var_sb2 + VAR_SB2_CUR_DELTA_X)
    ld      (hl), a
    ld      hl, (_var_sb2 + VAR_SB2_PTR_DELTAY)
    add     hl, bc
    ld      a, (_var_sb2 + VAR_SB2_CUR_DELTA_Y)
    ld      (hl), a

    ; set color.
    ld      hl, (_var_sb2 + VAR_SB2_PTR_COLOR)
    add     hl, bc
    ld      a, (_var_sb2 + VAR_SB2_NEXT_COLOR)
    ld      (hl), a

    ld      a, (_var_sb2 + VAR_SB2_NINE_COUNT)
    or      a
    jr      nz, sb2_create_particle_nine_count
    ld      a, 9
.sb2_create_particle_nine_count
    dec     a
    ld      (_var_sb2 + VAR_SB2_NINE_COUNT), a
    ld      e, a
    ld      d, $00

    ; set X0/Y0 to center + value from delta_x_tab/delta_y_tab.
    ; the initial positions are offset in a 9-point diamond pattern.
    ld      hl, _var_sb2_delta_x_tab
    add     hl, de
    ld      a, (_var_sb2 + VAR_SB2_CENTER_X)
    add     a, (hl)
    ld      hl, (_var_sb2 + VAR_SB2_PTR_X0)
    add     hl, bc
    ld      (hl), a
    ld      hl, _var_sb2_delta_y_tab
    add     hl, de
    ld      a, (_var_sb2 + VAR_SB2_CENTER_Y)
    add     a, (hl)
    ld      hl, (_var_sb2 + VAR_SB2_PTR_Y0)
    add     hl, bc
    ld      (hl), a

    ; draw dot.
    ld      hl, (_var_sb2 + VAR_SB2_PTR_X0)
    add     hl, bc
    ld      e, (hl)
    ld      hl, (_var_sb2 + VAR_SB2_PTR_Y0)
    add     hl, bc
    ld      d, (hl)
    ld      hl, (_var_sb2 + VAR_SB2_PTR_COLOR)
    add     hl, bc
    ld      a, (hl)
    call    _game_draw_dot

    ; update particle index.
    ld      a, (_var_sb2 + VAR_SB2_I_24)
    ld      c, a
    ld      b, $00
    ld      hl, _var_sb2 + VAR_SB2_NEXT_PARTICLE_INDEX
    add     hl, bc
    ld      a, (_var_sb2 + VAR_SB2_MAX_PARTICLE_COUNT)
    ld      e, a
    ld      a, (hl)
    inc     a
    cp      e
    jr      c, sb2_create_particle_next_index
    xor     a
.sb2_create_particle_next_index
    ld      (hl), a

    ret
