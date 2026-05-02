; cfobj.asm - サブルーチン
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
    include "cfobj.inc"
    include "resources/sounds/song.inc"


; コードの定義
;
    section app

; draws the mode 1 hi-res tiles.
; on entry:
;   $300: CX (map center X coord)
;   $301: CY (map center Y coord)
;
_cfobj_draw_hires:

    push    bc
    push    de
    ld      a, (_var_cfobj + VAR_CFOBJ_WIN_TOP)
    ld      d, a
    ld      b, $ff
.cfobj_draw_hires_loop_y
    ld      a, (_var_cfobj + VAR_CFOBJ_WIN_LEFT)
    ld      e, a
    ld      c, $00
.cfobj_draw_hires_loop_x
    call    _game_draw_ml_tile
    inc     e
    inc     c
    inc     c
    inc     c
    inc     c
    ld      a, c
    cp      XCS_IO_TEXT_VRAM_SIZE_X
    jr      c, cfobj_draw_hires_loop_x
    inc     d
    inc     b
    inc     b
    inc     b
    ld      a, b
    cp      XCS_IO_TEXT_VRAM_SIZE_Y
    jr      c, cfobj_draw_hires_loop_y
    pop     de
    pop     bc
    ret

; draws the mode 2 text mini-map.
; on entry:
;   $300: CX (map center X coord)
;   $301: CY (map center Y coord) 
;
_cfobj_draw_minimap:

    push    hl
    push    bc
    push    de
    ld      de, $011d
    call    _xcs_calc_text_vram_0
    ld      de, (_var_cfobj + VAR_CFOBJ_WIN_LEFT)
    ld      h, 9
.cfobj_draw_minimap_loop_y
    ld      l, 10
.cfobj_draw_minimap_loop_x
    push    hl
    call    _game_get_ml
    push    de
    ld      e, a
    ld      d, $00
    ld      hl, cfobj_minimap_chars
    add     hl, de
    pop     de
    cp      1
    jr      z, cfobj_draw_minimap_inverse
    cp      36
    jr      z, cfobj_draw_minimap_inverse
    cp      38
    jr      z, cfobj_draw_minimap_inverse
    cp      39
    jr      z, cfobj_draw_minimap_inverse
    xor     a
    jr      cfobj_draw_minimap_putchar
.cfobj_draw_minimap_inverse
    ld      a, $80
.cfobj_draw_minimap_putchar
    add     a, (hl)
    out     (c), a
    pop     hl
    inc     bc
    inc     e
    dec     l
    jr      nz, cfobj_draw_minimap_loop_x
    push    hl
    ld      hl, 40 - 10
    add     hl, bc
    ld      c, l
    ld      b, h
    pop     hl
    ld      a, e
    sub     10
    ld      e, a
    inc     d
    dec     h
    jr      nz, cfobj_draw_minimap_loop_y
    pop     de
    pop     bc
    pop     hl
    ret

; draws the mode 3 full-screen text map.
; on entry:
;   $300: CX (map center X coord)
;   $301: CY (map center Y coord)
;
_cfobj_draw_textmap:

    push    hl
    push    bc
    push    de
    ld      de, (_var_cfobj + VAR_CFOBJ_PLAYER_WIN_X)
    ld      a, (_var_cfobj + VAR_CFOBJ_WIN_LEFT)
    add     a, e
    sub     20
    jr      c, cfobj_draw_textmap_xc_min
    cp      40
    jr      c, cfobj_draw_textmap_xc
    ld      a, 40
    jr      cfobj_draw_textmap_xc
.cfobj_draw_textmap_xc_min
    xor     a
.cfobj_draw_textmap_xc
    ld      (_var_cfobj + VAR_CFOBJ_PLAYER_XC), a
    ld      a, (_var_cfobj + VAR_CFOBJ_WIN_TOP)
    add     a, d
    sub     12
    jr      c, cfobj_draw_textmap_yc_min
    cp      55
    jr      c, cfobj_draw_textmap_yc
    ld      a, 55
    jr      cfobj_draw_textmap_yc
.cfobj_draw_textmap_yc_min
    xor     a
.cfobj_draw_textmap_yc
;   ld      (_var_cfobj + VAR_CFOBJ_PLAYER_YC), a
    ld      d, a
    ld      bc, XCS_IO_TEXT_VRAM_0
    ld      h, 25
.cfobj_draw_textmap_loop_y
    ld      a, (_var_cfobj + VAR_CFOBJ_PLAYER_XC)
    ld      e, a
    ld      l, 40
.cfobj_draw_textmap_loop_x
    push    hl
    push    bc
    call    _game_get_ml
    ld      c, a
    ld      b, $00
    ld      hl, cfobj_textmap_chars
    add     hl, bc
    ld      b, (hl)
    ld      a, c
    cp      1
    ld      a, b
    jr      nz, cfobj_draw_textmap_putchar
    add     a, $80
.cfobj_draw_textmap_putchar
    pop     bc
    out     (c), a
    pop     hl
    inc     bc
    inc     e
    dec     l
    jr      nz, cfobj_draw_textmap_loop_x
    inc     d
    dec     h
    jr      nz, cfobj_draw_textmap_loop_y
    pop     de
    pop     bc
    pop     hl
    ret

; updates a single tile on the mode 1 (hi-res) and mode 2 (text minimap) displays.                                                                    *
; on entry:
;   $304: display mode (1-3)
;   $305: tile X position (0-79)
;   $306: tile Y position (0-79)
;
_cfobj_update_one_tile:

    push    hl
    push    bc
    push    de
    ld      de, (_var_cfobj + VAR_CFOBJ_MONSTER_MAP_X)
    ld      bc, (_var_cfobj + VAR_CFOBJ_WIN_LEFT)
    ld      a, e
    sub     c
    cp      10
    jr      nc, cfobj_update_one_tile_end
    ld      c, a
    ld      a, d
    sub     b
    cp      9
    jr      nc, cfobj_update_one_tile_end
    ld      b, a
    push    bc
    sla     c
    sla     c
    add     a, a
    add     a, b
    ld      b, a
    dec     b
    call    _game_draw_ml_tile
    pop     bc
    ld      a, (_var_cfobj + VAR_CFOBJ_DISPLAY_MODE)
    cp      3
    jr      z, cfobj_update_one_tile_end
    push    de
    ld      a, c
    add     a, 29
    ld      e, a
    ld      a, b
    add     a, 1
    ld      d, a
    call    _xcs_calc_text_vram_0
    pop     de
    call    _game_get_ml
    ld      e, a
    ld      d, $00
    ld      hl, cfobj_minimap_chars
    add     hl, de
    cp      1
    jr      z, cfobj_update_one_tile_inverse
    cp      36
    jr      z, cfobj_update_one_tile_inverse
    cp      38
    jr      z, cfobj_update_one_tile_inverse
    cp      39
    jr      z, cfobj_update_one_tile_inverse
    xor     a
    jr      cfobj_update_one_tile_putchar
.cfobj_update_one_tile_inverse
    ld      a, $80
.cfobj_update_one_tile_putchar
    add     a, (hl)
    out     (c), a
.cfobj_update_one_tile_end
    pop     de
    pop     bc
    pop     hl
    ret

; waits for the player to hit a key.
; on entry:
;   $304: display mode (1-3)
;   $307: zero (turn timer)
;   $319: turn speed (0-49)
; on exit:
;   $308: key hit, or 0 if timeout
_cfobj_wait_for_key:

    push    hl
    push    bc
    push    de

    call    cfobj_draw_turn_timer
.cfobj_wait_for_key_loop
    call    _app_update
    ld      a, (_var_cfobj + VAR_CFOBJ_TURN_TIMER)
    and     $07
    cp      $07
    call    z, cfobj_erase_turn_timer
    ld      a, (_var_cfobj + VAR_CFOBJ_TURN_SPEED)
    sub     50
    neg
    ld      c, a
    ld      a, (_var_cfobj + VAR_CFOBJ_TURN_TIMER)
    add     a, c
    ld      (_var_cfobj + VAR_CFOBJ_TURN_TIMER), a
    and     $07
    call    z, cfobj_draw_turn_timer
    xor     a
    ld      (_var_cfobj + VAR_CFOBJ_KEYVAL_OR_ATK), a
    ld      a, (_xcs_key_function_push)
    ld      b, a
    ld      a, (_xcs_key_code_push)
;;  ld      a, (_xcs_key_code_edge)
    cp      'a'
    jr      c, cfobj_wait_for_key_push_uppercase
    cp      'z' + $01
    jr      nc, cfobj_wait_for_key_push_uppercase
    sub     'a' - 'A'
.cfobj_wait_for_key_push_uppercase
    cp      'Y'
    jp      z, cfobj_wait_for_key_move_up
    cp      $1e
    jp      z, cfobj_wait_for_key_move_up
    cp      'N'
    jp      z, cfobj_wait_for_key_move_down
    cp      $1f
    jp      z, cfobj_wait_for_key_move_down
    cp      'G'
    jp      z, cfobj_wait_for_key_move_left
    cp      $1d
    jp      z, cfobj_wait_for_key_move_left
    cp      'J'
    jp      z, cfobj_wait_for_key_move_right
    cp      $1c
    jp      z, cfobj_wait_for_key_move_right
    cp      'T'
    jp      z, cfobj_wait_for_key_move_up_left
    cp      'U'
    jp      z, cfobj_wait_for_key_move_up_right
    cp      'B'
    jp      z, cfobj_wait_for_key_move_down_left
    cp      'M'
    jp      z, cfobj_wait_for_key_move_down_right
    bit     XCS_IO_80C49_KEY_FUNCTION_10KEY_BIT, b
    jr      z, cfobj_wait_for_key_edge
    cp      '8'
    jp      z, cfobj_wait_for_key_move_up
    cp      '2'
    jp      z, cfobj_wait_for_key_move_down
    cp      '4'
    jp      z, cfobj_wait_for_key_move_left
    cp      '6'
    jp      z, cfobj_wait_for_key_move_right
    cp      '7'
    jp      z, cfobj_wait_for_key_move_up_left
    cp      '9'
    jp      z, cfobj_wait_for_key_move_up_right
    cp      '1'
    jp      z, cfobj_wait_for_key_move_down_left
    cp      '3'
    jp      z, cfobj_wait_for_key_move_down_right
.cfobj_wait_for_key_edge
    ld      a, (_xcs_key_code_edge)
    cp      'a'
    jr      c, cfobj_wait_for_key_edge_uppercase
    cp      'z' + $01
    jr      nc, cfobj_wait_for_key_edge_uppercase
    sub     'a' - 'A'
.cfobj_wait_for_key_edge_uppercase
    cp      'H'
    jp      z, cfobj_wait_for_key_pass
    cp      '5'
    jp      z, cfobj_wait_for_key_pass
    cp      $1b
    jp      z, cfobj_wait_for_key_toggle_bird
    cp      ' '
    jp      z, cfobj_wait_for_key_toggle_weapon
    cp      'O'
    jp      z, cfobj_wait_for_key_toggle_message
    cp      ':'
    jp      z, cfobj_wait_for_key_center_screen
    cp      'P'
    jp      z, cfobj_wait_for_key_buy_hp
    cp      'A'
    jp      z, cfobj_wait_for_key_buy_arrows
    cp      '1'
    jp      z, cfobj_wait_for_key_view_hires
    cp      '2'
    jp      z, cfobj_wait_for_key_view_text
    cp      '3'
    jp      z, cfobj_wait_for_key_view_map
    ld      a, (_xcs_stick_push)
    and     (XCS_CONTROLLER_UP | XCS_CONTROLLER_DOWN | XCS_CONTROLLER_LEFT | XCS_CONTROLLER_RIGHT)
    cp      XCS_CONTROLLER_UP
    jr      z, cfobj_wait_for_key_move_up
    cp      XCS_CONTROLLER_DOWN
    jr      z, cfobj_wait_for_key_move_down
    cp      XCS_CONTROLLER_LEFT
    jr      z, cfobj_wait_for_key_move_left
    cp      XCS_CONTROLLER_RIGHT
    jr      z, cfobj_wait_for_key_move_right
    cp      XCS_CONTROLLER_UP | XCS_CONTROLLER_LEFT
    jr      z, cfobj_wait_for_key_move_up_left
    cp      XCS_CONTROLLER_UP | XCS_CONTROLLER_RIGHT
    jr      z, cfobj_wait_for_key_move_up_right
    cp      XCS_CONTROLLER_DOWN | XCS_CONTROLLER_LEFT
    jr      z, cfobj_wait_for_key_move_down_left
    cp      XCS_CONTROLLER_DOWN | XCS_CONTROLLER_RIGHT
    jr      z, cfobj_wait_for_key_move_down_right
    ld      a, (_xcs_stick_edge)
    and     XCS_CONTROLLER_B
    jr      nz, cfobj_wait_for_key_toggle_weapon
    ld      a, (_var_cfobj + VAR_CFOBJ_TURN_TIMER)
    cp      192
    jp      c, cfobj_wait_for_key_loop
    xor     a
    jr      cfobj_wait_for_key_done
.cfobj_wait_for_key_move_up
    ld      c, CFOBJ_KEYVAL_MOVE_UP
    jr      cfobj_wait_for_key_move
.cfobj_wait_for_key_move_down
    ld      c, CFOBJ_KEYVAL_MOVE_DOWN
    jr      cfobj_wait_for_key_move
.cfobj_wait_for_key_move_left
    ld      c, CFOBJ_KEYVAL_MOVE_LEFT
    jr      cfobj_wait_for_key_move
.cfobj_wait_for_key_move_right
    ld      c, CFOBJ_KEYVAL_MOVE_RIGHT
    jr      cfobj_wait_for_key_move
.cfobj_wait_for_key_move_up_left
    ld      c, CFOBJ_KEYVAL_MOVE_UP_LEFT
    jr      cfobj_wait_for_key_move
.cfobj_wait_for_key_move_up_right
    ld      c, CFOBJ_KEYVAL_MOVE_UP_RIGHT
    jr      cfobj_wait_for_key_move
.cfobj_wait_for_key_move_down_left
    ld      c, CFOBJ_KEYVAL_MOVE_DOWN_LEFT
    jr      cfobj_wait_for_key_move
.cfobj_wait_for_key_move_down_right
    ld      c, CFOBJ_KEYVAL_MOVE_DOWN_RIGHT
;   jr      cfobj_wait_for_key_move
.cfobj_wait_for_key_move
    ld      a, b
    and     XCS_IO_80C49_KEY_FUNCTION_SHIFT | XCS_IO_80C49_KEY_FUNCTION_CTRL
    jr      nz, cfobj_wait_for_key_attack
    ld      a, (_xcs_stick_push)
    and     XCS_CONTROLLER_A
    jr      nz, cfobj_wait_for_key_attack
    ld      a, c
    jr      cfobj_wait_for_key_done
.cfobj_wait_for_key_attack
    ld      a, c
    add     a, $10
    jr      cfobj_wait_for_key_done
.cfobj_wait_for_key_pass
    ld      a, CFOBJ_KEYVAL_PASS
    jr      cfobj_wait_for_key_done
.cfobj_wait_for_key_toggle_bird
    ld      a, CFOBJ_KEYVAL_TOGGLE_BIRD
    jr      cfobj_wait_for_key_done
.cfobj_wait_for_key_toggle_weapon
    ld      a, CFOBJ_KEYVAL_TOGGLE_WEAPON
    jr      cfobj_wait_for_key_done
.cfobj_wait_for_key_toggle_message
    ld      a, CFOBJ_KEYVAL_TOGGLE_MESSAGE
    jr      cfobj_wait_for_key_done
.cfobj_wait_for_key_center_screen
    ld      a, CFOBJ_KEYVAL_CENTER_SCREEN
    jr      cfobj_wait_for_key_done
.cfobj_wait_for_key_buy_hp
    ld      a, CFOBJ_KEYVAL_BUY_HP
    jr      cfobj_wait_for_key_done
.cfobj_wait_for_key_buy_arrows
    ld      a, CFOBJ_KEYVAL_BUY_ARROWS
    jr      cfobj_wait_for_key_done
.cfobj_wait_for_key_view_hires
    ld      a, CFOBJ_KEYVAL_VIEW_HIRES
    jr      cfobj_wait_for_key_done
.cfobj_wait_for_key_view_text
    ld      a, CFOBJ_KEYVAL_VIEW_TEXT
    jr      cfobj_wait_for_key_done
.cfobj_wait_for_key_view_map
    ld      a, CFOBJ_KEYVAL_VIEW_MAP
;   jr      cfobj_wait_for_key_done
.cfobj_wait_for_key_done
    ld      (_var_cfobj + VAR_CFOBJ_KEYVAL_OR_ATK), a
    call    cfobj_erase_turn_timer
    pop     de
    pop     bc
    pop     hl
    ret

; draws the turn-timer box on the hi-res screen, and an asterisk on the text screen.
; on entry:
;   $1C: draw mode (0 for draw, 1 for erase)
;
cfobj_draw_turn_timer:

    push    hl
    push    bc
    push    de
    ld      a, (_var_cfobj + VAR_CFOBJ_DISPLAY_MODE)
    cp      3
    jr      z, cfobj_draw_turn_timer_end
    ld      a, (_var_cfobj + VAR_CFOBJ_TURN_TIMER)
    srl     a
    srl     a
    srl     a
    ld      e, a
    ld      d, 24
    push    de
    call    _xcs_calc_text_vram_0
    ld      a, '*'
    out     (c), a
    pop     de
    ld      a, %00000110
    call    _xcs_fill_8x8_tile
.cfobj_draw_turn_timer_end
    pop     de
    pop     bc
    pop     hl
    ret

cfobj_erase_turn_timer:

    push    hl
    push    bc
    push    de
    ld      a, (_var_cfobj + VAR_CFOBJ_DISPLAY_MODE)
    cp      3
    jr      z, cfobj_erase_turn_timer_end
    ld      a, (_var_cfobj + VAR_CFOBJ_TURN_TIMER)
    srl     a
    srl     a
    srl     a
    ld      e, a
    ld      d, 24
    push    de
    call    _xcs_calc_text_vram_0
    ld      a, ' '
    out     (c), a
    pop     de
    call    _game_erase_misc
.cfobj_erase_turn_timer_end
    pop     de
    pop     bc
    pop     hl
    ret

; move all monsters.
; report attacks on player.
; also draws dragon breath and checks for a hit.
; on entry:
;   $302: player X within window (AX) (0-9)
;   $303: player Y within window (AY) (0-8)
;   $304: display mode (1-3)
;   $309: player X coord (CX+AX) (0-79)
;   $30A: player Y coord (CY+AY) (0-79)
;   $30D: number of active monsters (NM)
; on exit:
;   $30E: number of monsters that attacked (0-4)
;   $30F-312: indexes of attacking monsters
;     (scribbles up to $316)
;   $31B/31C: X/Y of 1st zapping wizard ($FF/$FF if none)
;   $31D/31E: X/Y of 2nd zapping wizard ($FF/$FF if none)
_cfobj_move_monsters:

    xor     a
    ld      (_var_cfobj + VAR_CFOBJ_MON_ATTACK_ID0), a
    ld      (_var_cfobj + VAR_CFOBJ_MON_ATTACK_ID1), a
    ld      (_var_cfobj + VAR_CFOBJ_MON_ATTACK_ID2), a
    ld      (_var_cfobj + VAR_CFOBJ_MON_ATTACK_ID3), a
    ld      (_var_cfobj + VAR_CFOBJ_MON_ATTACK_COUNT), a
    
    ; loop
.cfobj_move_monsters_loop
    ld      a, (_var_cfobj + VAR_CFOBJ_MONSTER_COUNT)
    or      a
    jr      z, cfobj_move_monsters_can_attack
    call    cfobj_move_monster
        
    ; thunderbug?
    ld      a, (_var_cfobj + VAR_CFOBJ_MONSTER_COUNT)
    ld      e, a
    ld      d, $00
    ld      hl, _var_cf_bt
    add     hl, de
    ld      a, (hl)
    cp      10

    ; go again: thunderbugs move 2x
    call    z, cfobj_move_monster
            
    ; did monster attack player?
    ld      a, (_var_cfobj + VAR_CFOBJ_KEYVAL_OR_ATK)
    or      a
    jr      z, cfobj_move_monsters_next
    ld      a, (_var_cfobj + VAR_CFOBJ_MON_ATTACK_COUNT)
    cp      4
    jr      nc, cfobj_move_monsters_next
    ld      e, a
    ld      d, $00
    ld      hl, _var_cfobj + VAR_CFOBJ_MON_ATTACK_ID0
    add     hl, de
    ld      a, (_var_cfobj + VAR_CFOBJ_MONSTER_COUNT)
    ld      (hl), a
    inc     e
    ld      a, e
    ld      (_var_cfobj + VAR_CFOBJ_MON_ATTACK_COUNT), a
        
    ; move on to next monster
.cfobj_move_monsters_next
    ld      hl, _var_cfobj + VAR_CFOBJ_MONSTER_COUNT
    dec     (hl)
    jr      cfobj_move_monsters_loop
    
    ; at most 4 monsters can attack
.cfobj_move_monsters_can_attack

    call    cfobj_check_ranged_attack
    xor     a
    ld      (_var_cfobj + VAR_CFOBJ_HIT_BY_FLAME), a
    call    cfobj_check_dragon_breath
    
    ret

; moves a single monster.
; on entry:
;   $30d: monster index
; on exit:
;   $308: nonzero if monster attacked player
;   also, wizard attack values may be updated
cfobj_move_monster:

    ; clear attack flag
    xor     a
    ld      (_var_cfobj + VAR_CFOBJ_KEYVAL_OR_ATK), a

    ; check distance
    ld      a, (_var_cfobj + VAR_CFOBJ_MONSTER_COUNT)
    ld      c, a
    ld      b, $00
    ld      hl, _var_cf_bx
    add     hl, bc
    ld      e, (hl)
    ld      hl, _var_cf_by
    add     hl, bc
    ld      d, (hl)
    ld      (_var_cfobj + VAR_CFOBJ_MONSTER_MAP_X), de
    ld      bc, (_var_cfobj + VAR_CFOBJ_PLAYER_MAP_X)
    ld      a, e
    sub     c
    jr      nc, cfobj_move_monster_check_distance_x
    neg
.cfobj_move_monster_check_distance_x
    ld      l, a
    ld      a, d
    sub     b
    jr      nc, cfobj_move_monster_check_distance_y
    neg
.cfobj_move_monster_check_distance_y
    add     a, l
    ld      (_var_cfobj + VAR_CFOBJ_MON_TAXICAB_DIST), a
    cp      20
    ret     nc

    ; move with purpose
    call    _xcs_get_random_number
    cp      32
    jp      c, cfobj_move_monster_random_move
    ld      de, (_var_cfobj + VAR_CFOBJ_PLAYER_MAP_X)
    ld      bc, (_var_cfobj + VAR_CFOBJ_MONSTER_MAP_X)
    ld      a, e
    sub     c
    jr      z, cfobj_move_monster_purpose_x
    ld      a, 1
    jr      nc, cfobj_move_monster_purpose_x
    neg
.cfobj_move_monster_purpose_x
    ld      e, a
    ld      a, d
    sub     b
    jr      z, cfobj_move_monster_purpose_y
    ld      a, 1
    jr      nc, cfobj_move_monster_purpose_y
    neg
.cfobj_move_monster_purpose_y
    ld      d, a
    ld      (_var_cfobj + VAR_CFOBJ_MONSTER_MOVE_X), de
		
    ; wizard?
    ld      a, (_var_cfobj + VAR_CFOBJ_MONSTER_COUNT)
    ld      e, a
    ld      d, $00
    ld      hl, _var_cf_bt
    add     hl, de
    ld      a, (hl)
    cp      15
    jr      nz, cfobj_move_monster_try
    ld      a, (_var_cfobj + VAR_CFOBJ_MON_TAXICAB_DIST)
    cp      2
    ret     z
    cp      1
    jr      nz, cfobj_move_monster_try
    ld      de, (_var_cfobj + VAR_CFOBJ_MONSTER_MOVE_X)
    ld      a, e
    neg
    ld      e, a
    ld      a, d
    neg
    ld      d, a
    ld      (_var_cfobj + VAR_CFOBJ_MONSTER_MOVE_X), de

    ; try to move or attack
.cfobj_move_monster_try
    ld      de, (_var_cfobj + VAR_CFOBJ_MONSTER_MOVE_X)
    ld      a, e
    or      a
    jr      z, cfobj_move_monster_try_0
    ld      a, d
    or      a
    jr      nz, cfobj_move_monster_diagonal
.cfobj_move_monster_try_0
    call    cfobj_move_or_attack
    ret     c

    ; didn't work, reverse axes
    ld      de, (_var_cfobj + VAR_CFOBJ_MONSTER_MOVE_X)
    ld      a, e
    ld      e, d
    ld      d, a
    ld      (_var_cfobj + VAR_CFOBJ_MONSTER_MOVE_X), de

    ; even
    ld      a, (_var_cfobj + VAR_CFOBJ_MONSTER_COUNT)
    ld      e, a
    ld      d, $00
    ld      hl, _var_cf_bt
    add     hl, de
    ld      a, (hl)
    and     $01
    jr      z, cfobj_move_monster_try_1
    ld      de, (_var_cfobj + VAR_CFOBJ_MONSTER_MOVE_X)
    ld      a, e
    neg
    ld      e, a
    ld      a, d
    neg
    ld      d, a
    ld      (_var_cfobj + VAR_CFOBJ_MONSTER_MOVE_X), de

    ; try to move or attack
.cfobj_move_monster_try_1
    call    cfobj_move_or_attack
    ret     c

    ; didn't work, reverse axes
    ld      de, (_var_cfobj + VAR_CFOBJ_MONSTER_MOVE_X)
    ld      a, e
    neg
    ld      e, a
    ld      a, d
    neg
    ld      d, a
    ld      (_var_cfobj + VAR_CFOBJ_MONSTER_MOVE_X), de

    ; try to move or attack
    call    cfobj_move_or_attack
    ret     c
    jp      cfobj_move_monster_random_move

    ; move diagonal
.cfobj_move_monster_diagonal

    ; mad robot, mimic, invisoid, thunderbug
    ld      a, (_var_cfobj + VAR_CFOBJ_MONSTER_COUNT)
    ld      e, a
    ld      d, $00
    ld      hl, _var_cf_bt
    add     hl, de
    ld      a, (hl)
    cp      4
    jr      z, cfobj_move_monster_diagonal_mad
    cp      9
    jr      z, cfobj_move_monster_diagonal_mad
    cp      10
    jr      z, cfobj_move_monster_diagonal_mad
    cp      13
    jr      z, cfobj_move_monster_diagonal_mad
    jr      cfobj_move_monster_diagonal_distance
.cfobj_move_monster_diagonal_mad
    call    cfobj_move_or_attack
    ret

    ; get distance
.cfobj_move_monster_diagonal_distance
    ld      de, (_var_cfobj + VAR_CFOBJ_PLAYER_MAP_X)
    ld      bc, (_var_cfobj + VAR_CFOBJ_MONSTER_MAP_X)
    ld      a, e
    sub     c
    jr      nc, cfobj_move_monster_diagonal_distance_x
    neg
.cfobj_move_monster_diagonal_distance_x
    ld      e, a
    ld      a, d
    sub     b
    jr      nc, cfobj_move_monster_diagonal_distance_y
    neg
.cfobj_move_monster_diagonal_distance_y
    ld      d, a
    ld      (_var_cfobj + VAR_CFOBJ_COL_COUNTER), de

    ; pattern move
;   ld      de, (_var_cfobj + VAR_CFOBJ_COL_COUNTER)
    ld      a, (_var_cfobj + VAR_CFOBJ_MONSTER_COUNT)
    ld      c, a
    ld      b, $00
    ld      hl, _var_cf_bt
    add     hl, bc
    ld      a, (hl)
    and     $02
    jr      z, cfobj_move_monster_diagonal_pattern_row_col
    ld      a, e
    cp      d
    jr      nc, cfobj_move_monster_diagonal_pattern_2
    jr      cfobj_move_monster_diagonal_pattern_1
.cfobj_move_monster_diagonal_pattern_row_col
    ld      a, d
    cp      e
    jr      nc, cfobj_move_monster_diagonal_pattern_2
;   jr      cfobj_move_monster_diagonal_pattern_1
.cfobj_move_monster_diagonal_pattern_1
    ld      a, (_var_cfobj + VAR_CFOBJ_MONSTER_MOVE_Y)
    ld      (_var_cfobj + VAR_CFOBJ_MONSTER_MOVE_TMP), a
    xor     a
    ld      (_var_cfobj + VAR_CFOBJ_MONSTER_MOVE_Y), a
    call    cfobj_move_or_attack
    ret     c
    xor     a
    ld      (_var_cfobj + VAR_CFOBJ_MONSTER_MOVE_X), a
    ld      a, (_var_cfobj + VAR_CFOBJ_MONSTER_MOVE_TMP)
    ld      (_var_cfobj + VAR_CFOBJ_MONSTER_MOVE_Y), a
    call    cfobj_move_or_attack
    ret     c
    ld      a, (_var_cfobj + VAR_CFOBJ_MONSTER_MOVE_Y)
    neg
    ld      (_var_cfobj + VAR_CFOBJ_MONSTER_MOVE_Y), a
    call    cfobj_move_or_attack
    ret     c
    jr      cfobj_move_monster_random_move
.cfobj_move_monster_diagonal_pattern_2
    ld      a, (_var_cfobj + VAR_CFOBJ_MONSTER_MOVE_X)
    ld      (_var_cfobj + VAR_CFOBJ_MONSTER_MOVE_TMP), a
    xor     a
    ld      (_var_cfobj + VAR_CFOBJ_MONSTER_MOVE_X), a
    call    cfobj_move_or_attack
    ret     c
    ld      a, (_var_cfobj + VAR_CFOBJ_MONSTER_MOVE_TMP)
    ld      (_var_cfobj + VAR_CFOBJ_MONSTER_MOVE_X), a
    xor     a
    ld      (_var_cfobj + VAR_CFOBJ_MONSTER_MOVE_Y), a
    call    cfobj_move_or_attack
    ret     c
    ld      a, (_var_cfobj + VAR_CFOBJ_MONSTER_MOVE_X)
    neg
    ld      (_var_cfobj + VAR_CFOBJ_MONSTER_MOVE_X), a
    call    cfobj_move_or_attack
    ret     c
;   jr      cfobj_move_monster_random_move

    ; random move
.cfobj_move_monster_random_move
    call    _xcs_get_random_number
    and     $0f
.cfobj_move_monster_random_move_x
    sub     3
    jr      nc, cfobj_move_monster_random_move_x
    add     a, 2
    ld      e, a
    call    _xcs_get_random_number
    and     $0f
.cfobj_move_monster_random_move_y
    sub     3
    jr      nc, cfobj_move_monster_random_move_y
    add     a, 2
    ld      d, a
    ld      (_var_cfobj + VAR_CFOBJ_MONSTER_MOVE_X), de
    call    cfobj_move_or_attack

    ret

; evaluate the monster's movement.  If we tried to move onto the player, register an attack instead.
; if we move or attack, the caller's return address will be popped off, which will short-circut the caller's logic.
; if we don't move, we return to the caller.
;
cfobj_move_or_attack:

    ; OUT
    ;   cf = 行動した

    ld      de, (_var_cfobj + VAR_CFOBJ_MONSTER_MOVE_X)
    ld      a, d
    or      e
    ret     z
	
    ; healer
    ld      a, (_var_cfobj + VAR_CFOBJ_MONSTER_COUNT)
    ld      e, a
    ld      d, $00
    ld      hl, _var_cf_bt
    add     hl, de
    ld      a, (hl)
    cp      14
    jr      nz, cfobj_move_or_attack_update_xy
    ld      de, (_var_cfobj + VAR_CFOBJ_MONSTER_MOVE_X)
    ld      a, e
    neg
    ld      e, a
    ld      a, d
    neg
    ld      d, a
    ld      (_var_cfobj + VAR_CFOBJ_MONSTER_MOVE_X), de
	
	# update monster X/Y
.cfobj_move_or_attack_update_xy
    ld      bc, (_var_cfobj + VAR_CFOBJ_MONSTER_MOVE_X)
    ld      hl, (_var_cfobj + VAR_CFOBJ_MONSTER_MAP_X)
    ld      a, c
    add     a, l
    ld      e, a
    ld      a, b
    add     a, h
    ld      d, a
    ld      (_var_cfobj + VAR_CFOBJ_COL_COUNTER), de
	
    ; attack
    call    _game_get_ml
    cp      2
    jr      nz, cfobj_move_or_attack_move
    ld      a, $7b
    ld      (_var_cfobj + VAR_CFOBJ_KEYVAL_OR_ATK), a
    scf
    ret
		
    ; move
.cfobj_move_or_attack_move
    or      a
    ret     nz
    ld      a, (_var_cfobj + VAR_CFOBJ_MONSTER_COUNT)
    ld      e, a
    ld      d, $00
    ld      hl, _var_cf_bt
    add     hl, de
    ld      a, (hl)
    cp      13
    ret     z
    call    cfobj_move_update_map
    scf
    ret

; update the map for a monster move.
; on entry:
;   $06/07: pointer to map entry for new location
;   $305: old location X
;   $306: old location Y
; important: the caller's return address is popped off before returning.
;
cfobj_move_update_map:
	
    ; erase monster from old position
    ld      de, (_var_cfobj + VAR_CFOBJ_MONSTER_MAP_X)
    xor     a
    call    _game_set_ml
	
    ; store monster in map in new position
    ld      a, (_var_cfobj + VAR_CFOBJ_MONSTER_COUNT)
    ld      c, a
    ld      b, $00
    ld      hl, _var_cf_bt
    add     hl, bc
    ld      a, (hl)
    ld      de, (_var_cfobj + VAR_CFOBJ_COL_COUNTER)
    call    _game_set_ml
    ld      hl, _var_cf_bx
    add     hl, bc
    ld      (hl), e
    ld      hl, _var_cf_by
    add     hl, bc
    ld      (hl), d
    ld      (_var_cfobj + VAR_CFOBJ_PLAYER_XC), de
    call    _cfobj_update_one_tile
    ld      de, (_var_cfobj + VAR_CFOBJ_PLAYER_XC)
    ld      (_var_cfobj + VAR_CFOBJ_MONSTER_MAP_X), de
    call    _cfobj_update_one_tile
    ret

; check ranged attack.
cfobj_check_ranged_attack:

    ; clear wizard attack values
    ld      a, -1
    ld      (_var_cfobj + VAR_CFOBJ_ATK_WIZ1_X), a
    ld      (_var_cfobj + VAR_CFOBJ_ATK_WIZ2_X), a

    ; look for a wizard on the same vertical line
    ld      a, (_var_cfobj + VAR_CFOBJ_PLAYER_WIN_X)
    ld      (_var_arg + VAR_ARG_X0), a
    xor     a
    ld      (_var_arg + VAR_ARG_Y0), a
.cfobj_check_ranged_attack_vertical_loop
    call    cfobj_check_wizard
    ld      a, (_var_arg + VAR_ARG_Y0)
    inc     a
    ld      (_var_arg + VAR_ARG_Y0), a
    cp      9
    jr      c, cfobj_check_ranged_attack_vertical_loop

    ; look for a wizard on the same horizontal line
    xor     a
    ld      (_var_arg + VAR_ARG_X0), a
    ld      a, (_var_cfobj + VAR_CFOBJ_PLAYER_WIN_Y)
    ld      (_var_arg + VAR_ARG_Y0), a
.cfobj_check_ranged_attack_horizontal_loop
    call    cfobj_check_wizard
    ld      a, (_var_arg + VAR_ARG_X0)
    inc     a
    ld      (_var_arg + VAR_ARG_X0), a
    cp      10
    jr      c, cfobj_check_ranged_attack_horizontal_loop

    ret

; try to zap the player with a wizard.
; Must be lined up vertically or horizontally.
; (the code re-uses the storage locations that the sound code uses, so the names are a bit funny)
;
cfobj_check_wizard:

    ; wizard?
    ld      de, (_var_cfobj + VAR_CFOBJ_WIN_LEFT)
    ld      bc, (_var_arg + VAR_ARG_X0)
    ld      a, e
    add     a, c
    ld      e, a
    ld      a, d
    add     a, b
    ld      d, a
    call    _game_get_ml
    cp      15
    ret     nz

    ; assume shooting down/right
    ld      a, 1
    ld      (_var_cfobj + VAR_CFOBJ_SOUND_PITCH_ADJ), a

    ; horizontally
    ld      bc, (_var_arg + VAR_ARG_X0)
    ld      a, (_var_cfobj + VAR_CFOBJ_PLAYER_WIN_Y)
    cp      b
    jr      nz, cfobj_check_wizard_vertically
    ld      a, (_var_cfobj + VAR_CFOBJ_PLAYER_WIN_X)
    cp      c
    jr      nc, cfobj_check_wizard_horizontally_set
    ld      a, -1
    ld      (_var_cfobj + VAR_CFOBJ_SOUND_PITCH_ADJ), a
.cfobj_check_wizard_horizontally_set
    ld      a, c
    ld      (_var_cfobj + VAR_CFOBJ_SOUND_DURATION), a
.cfobj_check_wizard_horizontally_loop
    ld      a, (_var_cfobj + VAR_CFOBJ_SOUND_PITCH_ADJ)
    add     a, c
    ld      c, a
    ld      (_var_arg + VAR_ARG_X0), a
    ld      a, (_var_cfobj + VAR_CFOBJ_PLAYER_WIN_X)
    cp      c
    jr      nz, cfobj_check_wizard_horizontally_next
    ld      a, (_var_cfobj + VAR_CFOBJ_SOUND_DURATION)
    ld      (_var_arg + VAR_ARG_X0), a
    call    cfobj_zap_player
    ret
.cfobj_check_wizard_horizontally_next
    ld      de, (_var_cfobj + VAR_CFOBJ_WIN_LEFT)
    ld      a, e
    add     a, c
    ld      e, a
    ld      a, d
    add     a, b
    ld      d, a
    call    _game_get_ml
    or      a
    jr      z, cfobj_check_wizard_horizontally_loop
    ld      a, (_var_cfobj + VAR_CFOBJ_SOUND_DURATION)
    ld      (_var_arg + VAR_ARG_X0), a
    ret

    ; vertically
.cfobj_check_wizard_vertically
    ld      bc, (_var_arg + VAR_ARG_X0)
    ld      a, (_var_cfobj + VAR_CFOBJ_PLAYER_WIN_Y)
    cp      b
    jr      nc, cfobj_check_wizard_vertically_set
    ld      a, -1
    ld      (_var_cfobj + VAR_CFOBJ_SOUND_PITCH_ADJ), a
.cfobj_check_wizard_vertically_set
    ld      a, b
    ld      (_var_cfobj + VAR_CFOBJ_SOUND_DURATION), a
.cfobj_check_wizard_vertically_loop
    ld      a, (_var_cfobj + VAR_CFOBJ_SOUND_PITCH_ADJ)
    add     a, b
    ld      b, a
    ld      (_var_arg + VAR_ARG_Y0), a
    ld      a, (_var_cfobj + VAR_CFOBJ_PLAYER_WIN_Y)
    cp      b
    jr      nz, cfobj_check_wizard_vertically_next
    ld      a, (_var_cfobj + VAR_CFOBJ_SOUND_DURATION)
    ld      (_var_arg + VAR_ARG_Y0), a
    call    cfobj_zap_player
    ret
.cfobj_check_wizard_vertically_next
    ld      de, (_var_cfobj + VAR_CFOBJ_WIN_LEFT)
    ld      a, e
    add     a, c
    ld      e, a
    ld      a, d
    add     a, b
    ld      d, a
    call    _game_get_ml
    or      a
    jr      z, cfobj_check_wizard_vertically_loop
    ld      a, (_var_cfobj + VAR_CFOBJ_SOUND_DURATION)
    ld      (_var_arg + VAR_ARG_Y0), a
    ret

cfobj_zap_player:

    ld      de, (_var_arg + VAR_ARG_X0)
    ld      a, (_var_cfobj + VAR_CFOBJ_ATK_WIZ1_X)
    cp      $80
    jr      c, cfobj_zap_player_2
    ld      (_var_cfobj + VAR_CFOBJ_ATK_WIZ1_X), de
    jr      cfobj_zap_player_end
.cfobj_zap_player_2
    ld      (_var_cfobj + VAR_CFOBJ_ATK_WIZ2_X), de

.cfobj_zap_player_end
    ret

; if we're close enough to see the dragon breathe, show it and play the sound effect.
; if we're hit by it, set the flag.
; the dragon breathes every-other turn.
; CF sets the value to zero, and we toggle the low bit on every breath.
; when the dragon dies, CF sets the value to 9 to disable it.
; on exit:
;   $31f: 0 if not hit by flames, $ff if hit
cfobj_check_dragon_breath:

    ; set to 9 on dragon death?
    ld      a, (_var_cfobj + VAR_CFOBJ_DRAGON_BREATH_READY)
    xor     $01
    ld      (_var_cfobj + VAR_CFOBJ_DRAGON_BREATH_READY), a
    ret     nz

    ; are we far enough east to see it?
    ; are we far enough south to see it?
    ld      de, (_var_cfobj + VAR_CFOBJ_WIN_LEFT)
    ld      a, e
    cp      66
    ret     c
    ld      a, d
    cp      63
    ret     c

    ; find screen position; map tiles are 28x21 pixels
;   ld      de, (_var_cfobj + VAR_CFOBJ_WIN_LEFT)
    ld      a, 71
    sub     e
    add     a, a
    add     a, a
    inc     a
    ld      e, a
    ld      a, 71
    sub     d
    ld      d, a
    add     a, a
    add     a, d
    dec     a
    ld      d, a
    call    _game_draw_breath
    ld      a, 6
    call    _cfobj_play_indexed_tone
;   ld      a, 7
;   call    _cfobj_play_indexed_tone
;   ld      a, GAME_WAIT_BREATH
;   call    _game_wait

    call    _game_erase_breath

    ; hit check (71-74 open, 75-77 dragon, 78-79 wall)
    ld      de, (_var_cfobj + VAR_CFOBJ_WIN_LEFT)
    ld      bc, (_var_cfobj + VAR_CFOBJ_PLAYER_WIN_X)
    ld      a, e
    add     a, c
    cp      71
    jr      c, cfobj_check_dragon_breath_end
    ld      a, d
    add     a, b
    cp      71
    jr      nz, cfobj_check_dragon_breath_end
    ld      a, -1
    ld      (_var_cfobj + VAR_CFOBJ_HIT_BY_FLAME), a

.cfobj_check_dragon_breath_end
    ret

; create a set of objects (monsters or chests).
; on entry:
;   $300: 3 or 37 (monsters or chests)
;   $301: number of items to create 
;
_cfobj_create_monsters:

.cfobj_create_monsters_loop

    ; Generate random (X,Y) coordinate.
    ; check to see if cell is empty.
.cfobj_create_monsters_check_empty
    call    cfobj_create_monsters_get_random
    ld      e, a
    call    cfobj_create_monsters_get_random
    ld      d, a
    call    _game_get_ml
    or      a
    jr      nz, cfobj_create_monsters_check_empty

    ; store
    ld      a, (_var_cfobj + VAR_CFOBJ_WIN_LEFT)
    call    _game_set_ml
    ld      a, (_var_cfobj + VAR_CFOBJ_WIN_LEFT)
    cp      $03
    jr      c, cfobj_create_monsters_store_done
    cp      $20
    jr      nc, cfobj_create_monsters_store_done
    ld      a, (_var_cfobj + VAR_CFOBJ_WIN_TOP)
    ld      c, a
    ld      b, $00
    ld      hl, _var_cf_bx
    add     hl, bc
    ld      (hl), e
    ld      hl, _var_cf_by
    add     hl, bc
    ld      (hl), d
    ld      hl, _var_cf_bt
    add     hl, bc
    ld      a, (_var_cfobj + VAR_CFOBJ_WIN_LEFT)
    ld      (hl), a

    ; pick a new monster type
    ld      a, (_var_cfobj + VAR_CFOBJ_SKILL_LEVEL_PLUS_4)
    inc     a
    ld      d, a
.cfobj_create_monsters_pick_new
    call    _xcs_get_random_number
    and     $0f
    cp      $03
    jr      c, cfobj_create_monsters_pick_new
    cp      d
    jr      nc, cfobj_create_monsters_pick_new
    ld      (_var_cfobj + VAR_CFOBJ_WIN_LEFT), a

    ; done yet?
    ld      hl, _var_cfobj + VAR_CFOBJ_WIN_TOP
    dec     (hl)
    jr      nz, cfobj_create_monsters_loop
.cfobj_create_monsters_store_done

    ; 終了
    ret

.cfobj_create_monsters_get_random
    call    _xcs_get_random_number
    cp      240
    jr      nc, cfobj_create_monsters_get_random
.cfobj_create_monsters_get_random_80
    sub     80
    jr      nc, cfobj_create_monsters_get_random_80
    add     a, 80
    ret

; ミニマップ
;
cfobj_minimap_chars:
    defb    "  *SMRBGF TCP$HW                    @$#*"

; テキストマップ
;
cfobj_textmap_chars:
    defb    "  *           H                         "
;   defb    "  *SMRBGF TCP$HW                    @$#*"

; play Chopin's Funeral March when the player dies.
;
_cfobj_play_funeral:

    push    hl
    push    bc
    push    de

    ld      a, SONG_FUNERAL
    ld      c, $00
    call    _xcs_play_bgm

.cfobj_play_funeral_loop
    call    _app_update
    call    _xcs_is_play_bgm
    or      a
    jr      nz, cfobj_play_funeral_loop

    pop     de
    pop     bc
    pop     hl

    ret
    

; play a single tone, determined by index.
; on entry:
;   $06: tone to play (0-7)
; tones used by CF:
;   0: attack with sword
;   1: hit monster with sword
;   2: hit by monster
;   3: dragon killed
;   4: monster killed
;   5: attacked by wizard
; tones used by CF.OBJ:
;   6/7: dragon breath
;
_cfobj_play_indexed_tone:

    push    hl
    push    bc
    push    de

    ld      e, a
    ld      d, $00
    ld      hl, cfobj_play_indexed_tone_song
    add     hl, de
    ld      a, (hl)
    ld      c, $00
    call    _xcs_play_bgm

.cfobj_play_indexed_tone_loop
    call    _app_update
    call    _xcs_is_play_bgm
    or      a
    jr      nz, cfobj_play_indexed_tone_loop

    pop     de
    pop     bc
    pop     hl

    ret

.cfobj_play_indexed_tone_song
    defb    SONG_SWING
    defb    SONG_SWING ; SONG_HITBYPLAYER
    defb    SONG_HITBYMONSTER
    defb    SONG_KILLDRAGON
    defb    SONG_KILLMONSTER
    defb    SONG_LBOLT
    defb    SONG_BREATH
    defb    SONG_BREATH

; play two tones, determined by index.
; on entry:
;   $06: tone to play (0-2)
; tones used by CF:
;   0: moved, regular (20161)
;   1: moved, running (20161)
;   2: "OOF!  HIT A WALL" (20120), "BLOCKED BY <monster>" (20135)
;
_cfobj_play_indexed_dual_tone:

    push    hl
    push    bc
    push    de

.cfobj_play_indexed_dual_tone_walk
    or      a
    jr      nz, cfobj_play_indexed_dual_tone_run
    ld      a, (_var_cfobj + VAR_CFOBJ_TONE_WALK)
    ld      e, a
    xor     $01
    ld      (_var_cfobj + VAR_CFOBJ_TONE_WALK), a
    ld      a, e
    add     a, SONG_WALK1
    jr      cfobj_play_indexed_dual_tone_play
.cfobj_play_indexed_dual_tone_run
    cp      1
    jr      nz, cfobj_play_indexed_dual_tone_block
    ld      a, SONG_RUN
    jr      cfobj_play_indexed_dual_tone_play
.cfobj_play_indexed_dual_tone_block
    ld      a, SONG_BLOCK

.cfobj_play_indexed_dual_tone_play
    ld      c, $00
    call    _xcs_play_bgm

.cfobj_play_indexed_dual_tone_loop
    call    _app_update
    call    _xcs_is_play_bgm
    or      a
    jr      nz, cfobj_play_indexed_dual_tone_loop

    pop     de
    pop     bc
    pop     hl

    ret


; finds the index of the monster at (X,Y).
; called from 20255 to identify which monster the player is swinging at.
; on entry:
;   $06: map X coordinate
;   $07: map Y coordinate
;   $30d: number of monsters
; on exit:
;   $30d: index of monster, or 0 if not found
;
_cfobj_find_monster_index:

    ; IN
    ;   de = マップ Y/X 位置
    ;   a  = モンスターの最大数
    ; OUT
    ;   a  = モンスターの参照

    ld      bc, $0001
    inc     a
.cfobj_find_monster_index_loop
    push    af
    ld      hl, _var_cf_bx
    add     hl, bc
    ld      a, (hl)
    cp      e
    jr      nz, cfobj_find_monster_index_next
    ld      hl, _var_cf_by
    add     hl, bc
    ld      a, (hl)
    cp      d
    jr      nz, cfobj_find_monster_index_next
    pop     af
    ld      a, c
    ret
.cfobj_find_monster_index_next
    pop     af
    inc     bc
    cp      c
    jr      nz, cfobj_find_monster_index_loop
    xor     a
    ret
