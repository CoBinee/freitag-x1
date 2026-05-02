; cf.asm - メインルーチン
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
    include "cf.inc"
    include "cfobj.inc"
    include "sb2.inc"


; コードの定義
;
    section app

;;; 1 - 59
; setup.
;
_cf_setup:

    ;  変数の初期化
    call    _var_initialize

    ; マップの読み込み
    ld      de, cf_setup_map_filename
    ld      hl, APP_PTR_ML
    call    _xcs_bload

    ; query game parameters (skill in SL%, speed-1 in 793 ($319)).
    call    cf_initial_setup

    ; set player start position (44081=$AC31 -> X=1 Y=39), set under-tile to Inn.
    xor     a
;;  ld      a, 70
    ld      (_var_cf + VAR_CF_CX), a
    ld      a, 35
;;  ld      a, 71
    ld      (_var_cf + VAR_CF_CY), a
    ld      a, 1
;;  ld      a, 7
    ld      (_var_cf + VAR_CF_AX), a
    ld      a, 4
;;  ld      a, 6
    ld      (_var_cf + VAR_CF_AY), a
    ld      de, (39 << 8) | 1
;;  ld      de, (77 << 8) | 77
    ld      a, 2
    call    _game_set_ml
    ld      a, VAR_CF_C0_CONST + 2
    ld      (_var_cf + VAR_CF_T0), a

    ; poke in the dragon parts (30-35).
    ; adress 40960 + 80*71 + 75 = 46715 ($B67B).
    ld      de, (71 << 8) | 75
    ld      a, 30
    call    _game_set_ml
    inc     e
    ld      a, 31
    call    _game_set_ml
    inc     e
    ld      a, 34
    call    _game_set_ml
    ld      de, (72 << 8) | 75
    ld      a, 32
    call    _game_set_ml
    inc     e
    ld      a, 33
    call    _game_set_ml
    inc     e
    ld      a, 35
    call    _game_set_ml

    ; TB is 32704 ($7FC0); 34048 is $8500.
;   ld      hl, $0000
;   ld      (_var_cf + VAR_CF_EP), hl
    ld      a, 1
    ld      (_var_cf + VAR_CF_EL), a
    ld      hl, 125
    ld      (_var_cf + VAR_CF_HP), hl
    ld      (_var_cf + VAR_CF_BH), hl
    ld      a, 12
    ld      (_var_cf + VAR_CF_AR), a
    ld      a, (_var_cf + VAR_CF_SL)
    ld      l, a
    ld      h, $00
    add     hl, hl
    add     hl, hl
    add     hl, hl
    ld      e, l
    ld      d, h
    add     hl, hl
    add     hl, de
    ld      e, a
    ld      d, $00
    add     hl, de
    ld      (_var_cf + VAR_CF_EN), hl
    ld      a, 1
    ld      (_var_cf + VAR_CF_DP), a
    ld      (_var_cf + VAR_CF_HW), a
;   xor     a
;   ld      (_var_cf + VAR_CF_SM), a
;   ld      (_var_cf + VAR_CF_RR), a
    
    ; set BX/BY to pointers to monster data initially 110 monsters created on map.
    ld      a, 110
    ld      (_var_cf + VAR_CF_NM), a

    ; set $31A = skill level + 4 (5-13).
    ld      a, (_var_cf + VAR_CF_SL)
    add     a, 4
    ld      (_var_cfobj + VAR_CFOBJ_SKILL_LEVEL_PLUS_4), a
    
    ; $300=$03, $301=110 call $6D12 (create serpents?); set $4E to random.
    ld      a, $03
    ld      (_var_cfobj + VAR_CFOBJ_WIN_LEFT), a
    ld      a, (_var_cf + VAR_CF_NM)
    ld      (_var_cfobj + VAR_CFOBJ_WIN_TOP), a
    call    _cfobj_create_monsters
    
    ; call $6D12 (create 62 chests?).
    ld      a, VAR_CF_C0_CONST + 1
    ld      (_var_cfobj + VAR_CFOBJ_WIN_LEFT), a
    ld      a, 62
    ld      (_var_cfobj + VAR_CFOBJ_WIN_TOP), a
    call    _cfobj_create_monsters

    ; etc
    ld      a, 2
    ld      (_var_cf + VAR_CF_ZW), a
    xor     a
    ld      (cf_state), a

    ; 次の処理へ
    jp      cf_initialization

; マップ
.cf_setup_map_filename
    defb    "map          bin", $00

; generate a random number between 1 and N.
;
cf_r:

    ; レジスタの保存
    push    de

    ; 乱数の生成
    ld      d, a
    call    _xcs_get_random_number
.cf_r_loop
    sub     d
    jr      nc, cf_r_loop
    add     a, d
    inc     a

    ; レジスタの復帰
    pop     de

    ; 終了
    ret

;;; 60 - 61
; find random empty map location, return in ZX/ZY/ZL.
; ZX,ZY = random number between 0 and 79.
; ZL = $A000 + 80 * ZY + ZX.
;
cf_find_random_empty_map_location:

    ; レジスタの保存
    push    hl
    push    de

    ; マップの検索
.cf_find_random_empty_map_location_loop
    ld      a, 80
    call    cf_r
    dec     a
    ld      e, a
    ld      a, 80
    call    cf_r
    dec     a
    ld      d, a
    call    _game_get_ml
    or      a
    jr      nz, cf_find_random_empty_map_location_loop
    ld      (_var_cf + VAR_CF_ZX), de
    ld      (_var_cf + VAR_CF_ZL), hl

    ; レジスタの復帰
    pop     de
    pop     hl

    ; 終了
    ret

;;; 63 - 95
; initialization, continued.
;
cf_initialization:

    ; 775=$307.
    xor     a
    ld      (_var_cfobj + VAR_CFOBJ_TURN_TIMER), a
    
    ; generate 110 monsters; this is repeated below (line 63 can be replaced with a REM).
    ld      bc, $0001
.cf_initialization_generate_monster_loop
    ld      hl, _var_cf_bx
    add     hl, bc
    ld      e, (hl)
    ld      hl, _var_cf_by
    add     hl, bc
    ld      d, (hl)
    call    _game_get_ml
    ld      hl, _var_cf_bt
    add     hl, bc
    ld      (hl), a
    ld      l, a
    ld      h, b
    add     hl, hl
    ld      de, _var_cf_hh
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ld      hl, _var_cf_mh
    add     hl, bc
    add     hl, bc
    ld      (hl), e
    inc     hl
    ld      (hl), d
    inc     c
    ld      a, (_var_cf + VAR_CF_NM)
    cp      c
    jr      nc, cf_initialization_generate_monster_loop

    ; update display, enable hi=res; 800=$320.
    call    cf_redraw_hires_screen
    call    cf_draw_character_sheet
    call    _game_hires
    xor     a
    ld      (_var_cfobj + VAR_CFOBJ_DRAGON_BREATH_READY), a
    
    ; monster slot 0 doesn't get populated; used for dragon (which is on the map but not included in BX/BY/BT).
    ld      hl, 350
    ld      (_var_cf_mh + $0000 * $0002), hl

    ; 終了
    jp      cf_main_loop

;;; 100 - 120
; main loop.
;
cf_main_loop:

    ; main loop
.cf_main_loop_loop
    call    cf_update_display_and_wait
    ld      a, (cf_state)
    or      a
    jr      nz, cf_done
    ld      a, (_var_cf + VAR_CF_RR)
    and     %00000001
    jr      nz, cf_main_loop_loop
    or      a
    jr      nz, cf_main_loop_loop
    xor     a
    ld      (_var_cfobj + VAR_CFOBJ_TURN_TIMER), a
    call    cf_move_monsters
    ld      a, (cf_state)
    or      a
    jr      z, cf_main_loop_loop

    ; done
.cf_done
    ret

;;; 10000 - 10010
; redraw hi-res screen.
;
cf_redraw_hires_screen:
    
    ; set $300/301 to the map center.
    ; if in hi-res mode, call 27904=$6D00.
    ld      de, (_var_cf + VAR_CF_CX)
    ld      (_var_cfobj + VAR_CFOBJ_WIN_LEFT), de
    ld      a, (_var_cf + VAR_CF_DP)
    cp      1 + $01
    call    c, _cfobj_draw_hires

    ; 終了
    ret

;;; 10100 - 10190
; draw character sheet.
;
cf_draw_character_sheet:
    
    ; print sheet.
    call    _game_home
    ld      hl, _var_cf_nn
    call    _game_print_without_linebreak
    ld      a, 29
    call    _game_htab
    ld      hl, cf_draw_character_sheet_frame_h_string
    call    _game_print_without_linebreak
    ld      b, 9
    ld      hl, cf_draw_character_sheet_frame_v_string
.cf_draw_character_sheet_frame_loop
    ld      a, 29
    call    _game_htab
    call    _game_print_without_linebreak
    djnz    cf_draw_character_sheet_frame_loop
    ld      a, 29
    call    _game_htab
    ld      hl, cf_draw_character_sheet_frame_h_string
    call    _game_print_without_linebreak
    ld      a, 3
    call    _game_vtab
    ld      hl, cf_draw_character_sheet_rank_string
    call    _game_print_without_linebreak
    ld      a, (_var_cf + VAR_CF_EL)
    ld      d, $00
    add     a, a
    rl      d
    add     a, a
    rl      d
    add     a, a
    rl      d
    add     a, a
    rl      d
    ld      e, a
    ld      hl, _var_cf_rn
    add     hl, de
    call    _game_print
    ld      hl, cf_draw_character_sheet_hits_string
    call    _game_print_without_linebreak
    ld      de, (_var_cf + VAR_CF_HP)
    call    _xcs_get_decimal_string
    call    _game_print_without_linebreak
    ld      a, '/'
    call    _game_putchar
    ld      de, (_var_cf + VAR_CF_BH)
    call    _xcs_get_decimal_string
    call    _game_print
    ld      hl, cf_draw_character_sheet_arrows_string
    call    _game_print_without_linebreak
    ld      a, (_var_cf + VAR_CF_AR)
    ld      e, a
    ld      d, $00
    call    _xcs_get_decimal_string
    call    _game_print
    ld      hl, cf_draw_character_sheet_gold_string
    call    _game_print_without_linebreak
    ld      de, (_var_cf + VAR_CF_GP)
    call    _xcs_get_decimal_string
    call    _game_print
    ld      hl, cf_draw_character_sheet_exp_string
    call    _game_print_without_linebreak
    ld      de, (_var_cf + VAR_CF_EP)
    call    _xcs_get_decimal_string
    call    _game_print
    ld      a, (_var_cf + VAR_CF_MS)
    or      a
    jr      z, cf_draw_character_sheet_sword
    ld      hl, cf_draw_character_sheet_sword_string
    call    _game_print_without_linebreak
    ld      a, (_var_cf + VAR_CF_MS)
    ld      e, a
    ld      d, $00
    call    _xcs_get_decimal_string
    call    _game_print
.cf_draw_character_sheet_sword
    ld      a, (_var_cf + VAR_CF_SH)
    or      a
    jr      z, cf_draw_character_sheet_shield
    ld      hl, cf_draw_character_sheet_shield_string
    call    _game_print_without_linebreak
    ld      a, (_var_cf + VAR_CF_SH)
    ld      e, a
    ld      d, $00
    call    _xcs_get_decimal_string
    call    _game_print
.cf_draw_character_sheet_shield
    call    cf_draw_text_minimap
    call    cf_update_wield

    ; 終了
    ret

.cf_draw_character_sheet_frame_h_string
    defb    "+----------+", $00
.cf_draw_character_sheet_frame_v_string
    defb    "!          !", $00
.cf_draw_character_sheet_rank_string
    defb    "RANK:   ", $00
.cf_draw_character_sheet_hits_string
    defb    "HITS:   ", $00
.cf_draw_character_sheet_arrows_string
    defb    "ARROWS: ", $00
.cf_draw_character_sheet_gold_string
    defb    "GOLD:   ", $00
.cf_draw_character_sheet_exp_string
    defb    "EXP:    ", $00
.cf_draw_character_sheet_sword_string
    defb    "MAGIC SWORD +", $00
.cf_draw_character_sheet_shield_string
    defb    "MAGIC SHIELD +", $00

;;; 10200 - 10210
; draw the text mini-map (unless showing map).
;
cf_draw_text_minimap:

    ld      a, (_var_cf + VAR_CF_DP)
    cp      3
    ret     z
    ld      de, (_var_cf + VAR_CF_CX)
    ld      (_var_cfobj + VAR_CFOBJ_WIN_LEFT), de
    call    _cfobj_draw_minimap
    ret
        
;;; 10300 - 10320
; update wield (unless showing map).
;
cf_update_wield:

    ld      a, (_var_cf + VAR_CF_DP)
    cp      3
    ret     z
    ld      a, 8
    call    _game_vtab
    ld      a, 1
    call    _game_htab
    ld      hl, cf_update_wield_sword_string
    ld      a, (_var_cf + VAR_CF_HW)
    cp      1
    jr      z, cf_update_wield_print
    ld      hl, cf_update_wield_shield_string
.cf_update_wield_print
    call    _game_print
    ret

.cf_update_wield_sword_string
    defb    "HOLDING: SWORD ", $00
.cf_update_wield_shield_string
    defb    "HOLDING: SHIELD", $00

;;; 10400 - 10410
; update gold (unless showing map).
;
cf_update_gold:

    ld      a, (_var_cf + VAR_CF_DP)
    cp      3
    ret     z
    ld      a, 6
    call    _game_vtab
    ld      a, 9
    call    _game_htab
    ld      hl, cf_update_gold_blank_string
    call    _game_print
    ld      a, 6
    call    _game_vtab
    ld      a, 9
    call    _game_htab
    ld      de, (_var_cf + VAR_CF_GP)
    call    _xcs_get_decimal_string
    call    _game_print
    ret

.cf_update_gold_blank_string
    defb    "     ", $00

;;; 10500 - 10510
; update arrows (unless showing map).
;
cf_update_arrows:

    ld      a, (_var_cf + VAR_CF_DP)
    cp      3
    ret     z
    ld      a, 5
    call    _game_vtab
    ld      a, 9
    call    _game_htab
    ld      a, (_var_cf + VAR_CF_AR)
    ld      e, a
    ld      d, $00
    call    _xcs_get_decimal_string
    call    _game_print_without_linebreak
    ld      hl, cf_update_arrows_blank_string
    call    _game_print
    ret

.cf_update_arrows_blank_string
    defb    "  ", $00

;;; 10600 - 10610
;
cf_update_hp:

    ld      a, (_var_cf + VAR_CF_DP)
    cp      3
    ret     z
    ld      a, 4
    call    _game_vtab
    ld      a, 9
    call    _game_htab
    ld      de, (_var_cf + VAR_CF_HP)
    call    _xcs_get_decimal_string
    call    _game_print_without_linebreak
    ld      a, '/'
    call    _game_putchar
    ld      de, (_var_cf + VAR_CF_BH)
    call    _xcs_get_decimal_string
    call    _game_print_without_linebreak
    ld      hl, cf_update_hp_blank_string
    call    _game_print
    ret

.cf_update_hp_blank_string
    defb    "     ", $00

;;; 10700 - 10710
; update experience rank (unless showing map).
;
cf_update_experience_rank:

    ld      a, (_var_cf + VAR_CF_DP)
    cp      3
    ret     z
    ld      a, 3
    call    _game_vtab
    ld      a, 9
    call    _game_htab
    ld      a, (_var_cf + VAR_CF_EL)
    ld      d, $00
    add     a, a
    rl      d
    add     a, a
    rl      d
    add     a, a
    rl      d
    add     a, a
    rl      d
    ld      e, a
    ld      hl, _var_cf_rn
    add     hl, de
    call    _game_print_without_linebreak
    ld      hl, cf_update_experience_rank_blank_string
    call    _game_print
    ret

.cf_update_experience_rank_blank_string
    defb    "     ", $00

;;; 11000 - 11000
; draw map.
;
cf_draw_map:

    ld      de, (_var_cf + VAR_CF_AX)
    ld      (_var_cfobj + VAR_CFOBJ_PLAYER_WIN_X), de
    ld      de, (_var_cf + VAR_CF_CX)
    ld      (_var_cfobj + VAR_CFOBJ_WIN_LEFT), de
    call    _cfobj_draw_textmap
    ret

;;; 12000 - 12000
; redraw a single tile.
;
cf_redraw_single_tile:
    
    ; $305=X, $306=Y, $304=DP, call $6D09.
    ld      de, (_var_cf + VAR_CF_X)
    ld      (_var_cfobj + VAR_CFOBJ_MONSTER_MAP_X), de
    ld      a, (_var_cf + VAR_CF_DP)
    ld      (_var_cfobj + VAR_CFOBJ_DISPLAY_MODE), a
    call    _cfobj_update_one_tile
    ret

;;; 13000 - 13050
; print message.
;
cf_print_message:
    
    ; no messages in map mode, ever; clear urgent flag and return.
    ld      a, (_var_cf + VAR_CF_DP)
    cp      3
    jr      nz, cf_print_message_no_message_end
    xor     a
    ld      (_var_cf + VAR_CF_O9), a
    ret
.cf_print_message_no_message_end

    ; double-space it.
    ld      a, (_var_cf + VAR_CF_H9)
    or      a
    jr      nz, cf_print_message_double_space_end
    ld      a, 24
    call    _game_vtab
    call    _game_linebreak
    call    _game_linebreak
    ld      a, 23
    call    _game_vtab
    ld      a, 1
    ld      (_var_cf + VAR_CF_H9), a
.cf_print_message_double_space_end
        
    ; if the message ends in '!' or '.' we flash it when messages are on.
    ld      hl, (_var_cf + VAR_CF_M)
    call    _game_print_without_linebreak
    ld      hl, (_var_cf + VAR_CF_M)
.cf_print_message_right_loop
    ld      a, (hl)
    inc     hl
    or      a
    jr      nz, cf_print_message_right_loop
    dec     hl
    dec     hl
    ld      a, (hl)
    cp      '!'
    jr      z, cf_print_message_right_end
    cp      '.'
    ret     nz
.cf_print_message_right_end
        
    ; if hi-res, and messages are enabled or this is urgent, show it briefly.
    xor     a
    ld      (_var_cf + VAR_CF_H9), a
    ld      a, (_var_cf + VAR_CF_DP)
    cp      1
    jr      nz, cf_print_message_mix_end
    ld      a, (_var_cf + VAR_CF_SM)
    cp      1
    jr      z, cf_print_message_mix
    ld      a, (_var_cf + VAR_CF_O9)
    cp      1
    jr      nz, cf_print_message_mix_end
.cf_print_message_mix
    ld      d, 21
.cf_print_message_mix_on_loop_y
    ld      e, 0
.cf_print_message_mix_on_loop_x
    push    de
    xor     a
    call    _xcs_fill_8x8_tile
    pop     de
    inc     e
    ld      a, e
    cp      XCS_IO_TEXT_VRAM_SIZE_X
    jr      c, cf_print_message_mix_on_loop_x
    inc     d
    ld      a, d
    cp      XCS_IO_TEXT_VRAM_SIZE_Y
    jr      c, cf_print_message_mix_on_loop_y
    ld      a, GAME_WAIT_MESSAGE
    call    _game_wait

    ld      a, (_var_cf + VAR_CF_CY)
    add     a, 7
    ld      d, a
    ld      b, 20
.cf_print_message_mix_off_loop_y
    ld      a, (_var_cf + VAR_CF_CX)
    ld      e, a
    ld      c, 0
.cf_print_message_mix_off_loop_x
    call    _game_draw_ml_tile
    inc     e
    inc     c
    inc     c
    inc     c
    inc     c
    ld      a, c
    cp      XCS_IO_TEXT_VRAM_SIZE_X
    jr      c, cf_print_message_mix_off_loop_x
    inc     d
    inc     b
    inc     b
    inc     b
    ld      a, b
    cp      XCS_IO_TEXT_VRAM_SIZE_Y
    jr      c, cf_print_message_mix_off_loop_y
.cf_print_message_mix_end
    xor     a
    ld      (_var_cf + VAR_CF_O9), a

    ret

;;; 14000 - 14300
; arrow animation.
;
cf_arrow_animation:
    
    ; pass in ZX/ZY to indicate direction and SX/SY to indicate position.
    ld      de, (_var_cf + VAR_CF_SX)
    ld      a, e
    add     a, a
    add     a, a
    ld      e, a
    ld      a, d
    add     a, a
    add     a, d
    dec     a
    ld      d, a
    ld      (_var_cf + VAR_CF_SX), de
    ld      bc, (_var_cf + VAR_CF_X1)
    ld      a, c
    add     a, a
    add     a, a
    ld      c, a
    ld      a, b
    add     a, a
    add     a, b
    dec     a
    ld      b, a
    ld      (_var_cf + VAR_CF_X1), bc
.cf_arrow_animation_right
    ld      a, (_var_cf + VAR_CF_ZX)
    cp      1
    jr      nz, cf_arrow_animation_left
    dec     c
.cf_arrow_animation_right_loop
    xor     a
    call    _game_draw_misc
    ld      a, GAME_WAIT_ARROW
    call    _game_wait
    call    _game_erase_misc
    inc     e
    ld      a, e
    cp      c
    jr      nz, cf_arrow_animation_right_loop
    jr      cf_arrow_animation_end
.cf_arrow_animation_left
    cp      -1
    jr      nz, cf_arrow_animation_down
    inc     e
    inc     e
    inc     c
    inc     c
    inc     c
.cf_arrow_animation_left_loop
    ld      a, 1
    call    _game_draw_misc
    ld      a, GAME_WAIT_ARROW
    call    _game_wait
    call    _game_erase_misc
    dec     e
    ld      a, e
    cp      c
    jr      nz, cf_arrow_animation_left_loop
    jr      cf_arrow_animation_end
.cf_arrow_animation_down
    ld      a, (_var_cf + VAR_CF_ZY)
    cp      1
    jr      nz, cf_arrow_animation_up
    inc     e
    inc     c
    inc     d
    dec     d
    dec     b
    dec     b
.cf_arrow_animation_down_loop
    ld      a, 4
    call    _game_draw_misc
    ld      a, GAME_WAIT_ARROW
    call    _game_wait
    call    _game_erase_misc
    inc     d
    ld      a, d
    cp      b
    jr      nz, cf_arrow_animation_down_loop
    jr      cf_arrow_animation_end
.cf_arrow_animation_up
    inc     e
    inc     c
    inc     d
    inc     b
    inc     b
.cf_arrow_animation_up_loop
    ld      a, 3
    call    _game_draw_misc
    ld      a, GAME_WAIT_ARROW
    call    _game_wait
    call    _game_erase_misc
    dec     d
    ld      a, d
    cp      b
    jr      nz, cf_arrow_animation_up_loop
;   jr      cf_arrow_animation_end
.cf_arrow_animation_end
    ret

;;; 15000 - 15000
; draw "hit" graphic; data set is at 7935 ($1EFF, CF.MISC).
;
cf_draw_hit_graphic:
    call    cf_calc_hit_graphic
    ld      a, 2
    call    _game_draw_misc
    ret
cf_erase_hit_graphic:
    call    cf_calc_hit_graphic
    call    _game_erase_misc
    ret
cf_calc_hit_graphic:
    ld      de, (_var_cf + VAR_CF_X)
    ld      bc, (_var_cf + VAR_CF_CX)
    ld      a, e
    sub     c
    add     a, a
    add     a, a
    inc     a
    ld      e, a
    ld      a, d
    sub     b
    ld      d, a
    add     a, a
    add     a, d
    dec     a
    ld      d, a
    ret

;;; 15500 - 15500
; update player bitmap when RR <> 0.
;
cf_update_player_bitmap_when_rr:

    ld      a, (_var_cf + VAR_CF_RR)
    cp      -4
    jr      nz, cf_update_player_bitmap_when_rr_run
    ld      a, (_var_cf + VAR_CF_HW)
    add     a, 17
    jr      cf_update_player_bitmap_when_rr_zw
.cf_update_player_bitmap_when_rr_run
    ld      a, 25
.cf_update_player_bitmap_when_rr_zw
    ld      (_var_cf + VAR_CF_ZW), a
;   call    cf_update_player_bitmap
;   ret

;;; 16000 - 16000
; update player bitmap (val in ZW).
;
cf_update_player_bitmap:
    
    ; TB is $7FC0 (SKETCHZ); 168 is 84*2 == item #2 (the player).
    ; ZW is icon source (18=sword, 16/17/19/20=bow, 25=bird, 36=blank).
    ; set destination and source.
    ; call 27925=$6D15 to copy 84 bytes from $08/09 to $06/07.
    
    ; update X/Y to current position.
    ld      de, (_var_cf + VAR_CF_CX)
    ld      bc, (_var_cf + VAR_CF_AX)
    ld      a, e
    add     a, c
    ld      e, a
    ld      a, d
    add     a, b
    ld      d, a
    ld      (_var_cf + VAR_CF_X), de
    
    ; redraw tile.
    call    cf_redraw_single_tile

    ret

;;; 20000 - 20045
; update display and wait for input or timeout.
;
cf_update_display_and_wait:
    
    ; set $304 to display mode and call $6D0C.
    ; if $308 is nonzero (input pending), head to 20050 to handle it.
    ld      a, (_var_cf + VAR_CF_DP)
    ld      (_var_cfobj + VAR_CFOBJ_DISPLAY_MODE), a
    call    _cfobj_wait_for_key

    ; if we're in the post-run cooldown, update RR.
    ld      a, (_var_cf + VAR_CF_RR)
    cp      $80
    jr      c, cf_update_display_and_wait_handle
    inc     a
    ld      (_var_cf + VAR_CF_RR), a
    jr      cf_update_display_and_wait_end
    
    ; handle user input
.cf_update_display_and_wait_handle
    ld      a, (_var_cfobj + VAR_CFOBJ_KEYVAL_OR_ATK)
    or      a
    call    nz, cf_handle_user_input

    ; 20040
.cf_update_display_and_wait_end
    ret

;;; 20050 - 20190
; handle user input.
;
cf_handle_user_input:
    
    ; get the input, see if it's a display mode (1-3).
    ; always in mode 1 (hi-res) while running.
    ld      a, (_var_cf + VAR_CF_RR)
    or      a
    jr      nz, cf_handle_user_input_display_mode_end
.cf_handle_user_input_display_mode_hires
    ld      a, (_var_cfobj + VAR_CFOBJ_KEYVAL_OR_ATK)
    cp      CFOBJ_KEYVAL_VIEW_HIRES
    jr      nz, cf_handle_user_input_display_mode_text
    ld      a, 1
    ld      (_var_cf + VAR_CF_DP), a
    call    cf_redraw_hires_screen
    call    _game_hires
    call    cf_draw_character_sheet
    ret
.cf_handle_user_input_display_mode_text
    cp      CFOBJ_KEYVAL_VIEW_TEXT
    jr      nz, cf_handle_user_input_display_mode_map
    ld      a, (_var_cf + VAR_CF_DP)
    ld      c, a
    ld      a, 2
    ld      (_var_cf + VAR_CF_DP), a
    ld      a, c
    cp      3
    call    z, cf_draw_character_sheet
    call    _game_text
    ret
.cf_handle_user_input_display_mode_map
    cp      CFOBJ_KEYVAL_VIEW_MAP
    jr      nz, cf_handle_user_input_display_mode_end
    ld      a, 3
    ld      (_var_cf + VAR_CF_DP), a
    call    cf_draw_map
    call    _game_text
    ret
.cf_handle_user_input_display_mode_end

    ; check movement, unless we're stick to a mimic (S2).
    ld      a, (_var_cfobj + VAR_CFOBJ_KEYVAL_OR_ATK)
    cp      CFOBJ_KEYVAL_MOVE + $10
    jr      c, cf_handle_user_input_check_move
    cp      CFOBJ_KEYVAL_PASS
    jr      z, cf_handle_user_input_pass
    call    cf_other_than_move
    ret
.cf_handle_user_input_pass
    xor     a
    ld      (_var_cfobj + VAR_CFOBJ_KEYVAL_OR_ATK), a
    ret
.cf_handle_user_input_check_move
    sub     CFOBJ_KEYVAL_MOVE
    add     a, a
    ld      e, a
    ld      d, $00
    ld      hl, cf_handle_user_input_move_vector
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)

    ; move.
    ld      (_var_cf + VAR_CF_ZX), de
    ld      hl, (_var_cf + VAR_CF_CX)
    ld      bc, (_var_cf + VAR_CF_AX)
    ld      a, l
    add     a, c
    ld      l, a
    add     a, e
    ld      e, a
    ld      a, h
    add     a, b
    ld      h, a
    add     a, d
    ld      d, a
    ld      (_var_cf + VAR_CF_X), hl
    call    _game_get_ml
    ld      (_var_cf + VAR_CF_ZZ), a
    or      a
    jr      z, cf_handle_user_input_movable
    cp      14
    jr      z, cf_handle_user_input_movable
    cp      VAR_CF_C0_CONST + 1
    jr      nc, cf_handle_user_input_movable
        
    ; run into a wall? 1-3 HP dam.
    cp      1
    jr      nz, cf_handle_user_input_block
    ld      a, 2
    call    _cfobj_play_indexed_dual_tone
    ld      hl, cf_handle_user_input_hit_wall_string
    ld      (_var_cf + VAR_CF_M), hl
    call    cf_print_message
    ld      a, 3
    call    cf_r
    ld      l, a
    ld      h, $00
    ld      (_var_cf + VAR_CF_ZD), hl
    call    cf_handle_player_being_hit
    xor     a
    ld      (_var_cfobj + VAR_CFOBJ_KEYVAL_OR_ATK), a
    ret

    ; 27946=$6D2A.
.cf_handle_user_input_block
    ld      a, 2
    call    _cfobj_play_indexed_dual_tone
    ld      hl, cf_handle_user_input_block_string
    call    _game_strcpy
    ld      a, (_var_cf + VAR_CF_ZZ)
    ld      d, $00
    add     a, a
    rl      d
    add     a, a
    rl      d
    add     a, a
    rl      d
    add     a, a
    rl      d
    ld      e, a
    ld      hl, _var_cf_mm
    add     hl, de
    call    _game_strcat
    ld      hl, cf_handle_user_input_block_end_string
    call    _game_strcat
    ld      (_var_cf + VAR_CF_M), hl
    call    cf_print_message
    xor     a
    ld      (_var_cfobj + VAR_CFOBJ_KEYVAL_OR_ATK), a
    ret

    ; set Z9 to the thing we moved onto (empty, healer, chest, Inn).
.cf_handle_user_input_movable
    ld      a, (_var_cf + VAR_CF_ZZ)
    ld      (_var_cf + VAR_CF_Z9), a
    ld      de, (_var_cf + VAR_CF_X)
    ld      a, (_var_cf + VAR_CF_T0)
    call    _game_set_ml
    call    cf_redraw_single_tile
    ld      bc, (_var_cf + VAR_CF_ZX)
    ld      de, (_var_cf + VAR_CF_AX)
    ld      a, e
    add     a, c
    ld      e, a
    ld      a, d
    add     a, b
    ld      d, a
    ld      (_var_cf + VAR_CF_AX), de
    ld      de, (_var_cf + VAR_CF_X)
    ld      a, e
    add     a, c
    ld      e, a
    ld      a, d
    add     a, b
    ld      d, a
    ld      (_var_cf + VAR_CF_X), de
    ld      a, 2
    call    _game_set_ml
    xor     a
    ld      (_var_cf + VAR_CF_T0), a
    ld      a, (_var_cf + VAR_CF_DP)
    cp      3
    call    z, cf_draw_map

    ; something special about column 74?
    ; have we reached the edge of the display?
.cf_handle_user_input_edge
    ld      bc, (_var_cf + VAR_CF_AX)
    ld      de, (_var_cf + VAR_CF_ZX)
    ld      hl, (_var_cf + VAR_CF_CX)
    ld      a, l
    add     a, c
    cp      74
    jr      nz, cf_handle_user_input_edge_xl
    ld      a, l
    cp      70
    jr      z, cf_handle_user_input_edge_xl
    ld      a, (_var_cf + VAR_CF_ZX)
    or      a
    jr      z, cf_handle_user_input_edge_xl
    ld      a, 70
    ld      (_var_cf + VAR_CF_CX), a
    jr      cf_handle_user_input_edge_redraw
.cf_handle_user_input_edge_xl
    ld      a, c
    cp      VAR_CF_XL_CONST + 1
    jr      nc, cf_handle_user_input_edge_xr
    ld      a, e
    cp      -1
    jr      nz, cf_handle_user_input_edge_xr
    ld      a, l
    or      a
    jr      z, cf_handle_user_input_edge_xr
    jr      cf_handle_user_input_edge_redraw
.cf_handle_user_input_edge_xr
    ld      a, c
    cp      VAR_CF_XR_CONST
    jr      c, cf_handle_user_input_edge_yl
    ld      a, e
    cp      1
    jr      nz, cf_handle_user_input_edge_yl
    ld      a, l
    cp      70
    jr      nc, cf_handle_user_input_edge_yl
    jr      cf_handle_user_input_edge_redraw
.cf_handle_user_input_edge_yl
    ld      a, b
    cp      VAR_CF_YL_CONST + 1
    jr      nc, cf_handle_user_input_edge_yr
    ld      a, d
    cp      -1
    jr      nz, cf_handle_user_input_edge_yr
    ld      a, h
    or      a
    jr      z, cf_handle_user_input_edge_yr
    jr      cf_handle_user_input_edge_redraw
.cf_handle_user_input_edge_yr
    ld      a, b
    cp      VAR_CF_YR_CONST
    jr      c, cf_handle_user_input_edge_end
    ld      a, d
    cp      1
    jr      nz, cf_handle_user_input_edge_end
    ld      a, h
    cp      71
    jr      nc, cf_handle_user_input_edge_end
.cf_handle_user_input_edge_redraw
    call    cf_redraw_on_handle_user_input
.cf_handle_user_input_edge_end
    call    cf_redraw_single_tile

    ; call $6D2A; if we moved onto something other than empty space, branch.
    ld      a, (_var_cf + VAR_CF_RR)
    or      a
    ld      a, 1
    jr      nz, cf_handle_user_input_move_tone
    xor     a
.cf_handle_user_input_move_tone
    call    _cfobj_play_indexed_dual_tone
    ld      a, (_var_cf + VAR_CF_Z9)
    or      a
    jr      nz, cf_handle_user_input_chest

    ; if run mode is active, decrement it.
    ld      a, (_var_cf + VAR_CF_RR)
    or      a
    ret     z
    dec     a
    ld      (_var_cf + VAR_CF_RR), a
    jr      nz, cf_handle_user_input_wearing_off
    ld      a, -4
    ld      (_var_cf + VAR_CF_RR), a
    call    cf_update_player_bitmap_when_rr
    ret
.cf_handle_user_input_wearing_off
    cp      4
    jr      nz, cf_handle_user_input_move_twice
    ld      a, 1
    ld      (_var_cf + VAR_CF_O9), a
    ld      hl, cf_handle_user_input_wearing_off_string
    ld      (_var_cf + VAR_CF_M), hl
    call    cf_print_message

    ; on even counts, player moves twice.
.cf_handle_user_input_move_twice
    ret
.cf_handle_user_input_move_empty_end

    ; handle movement onto something (chest, healer, Inn).
.cf_handle_user_input_chest
    ld      a, (_var_cf + VAR_CF_Z9)
    cp      VAR_CF_C0_CONST + 1
    jr      nz, cf_handle_user_input_inn
    
    ; open chest; U2 is set to 1 if it's a teleport trap.
    call    cf_open_chest
    ld      a, (_var_cf + VAR_CF_U2)
    or      a
    call    nz, cf_redraw_on_handle_user_input
    xor     a
    ld      (_var_cfobj + VAR_CFOBJ_KEYVAL_OR_ATK), a
    ret

    ; if it's the Inn then handle that.
.cf_handle_user_input_inn
    ld      a, (_var_cf + VAR_CF_Z9)
    cp      VAR_CF_C0_CONST + 2
    jr      nz, cf_handle_user_input_healer
    call    cf_move_onto_inn
    xor     a
    ld      (_var_cfobj + VAR_CFOBJ_KEYVAL_OR_ATK), a
    ret

    ; if it's a healer then do that.
.cf_handle_user_input_healer
    ld      a, (_var_cf + VAR_CF_Z9)
    cp      14
    jr      nz, cf_handle_user_input_error
    call    cf_touched_healer
    xor     a
    ld      (_var_cfobj + VAR_CFOBJ_KEYVAL_OR_ATK), a
    ret
    
    ; shouldn't fall through here.
.cf_handle_user_input_error
    xor     a
    ld      (_var_cfobj + VAR_CFOBJ_KEYVAL_OR_ATK), a
    ret

.cf_handle_user_input_move_vector
.cf_other_than_move_attack_vector
    defb    $00, $ff
    defb    $00, $01
    defb    $ff, $00
    defb    $01, $00
    defb    $ff, $ff
    defb    $01, $ff
    defb    $ff, $01
    defb    $01, $01

.cf_handle_user_input_hit_wall_string
    defb    "OOF!  HIT A WALL, ", $00
.cf_handle_user_input_block_string
    defb    "BLOCKED BY ", $00
.cf_handle_user_input_block_end_string
    defb    "!", $00
.cf_handle_user_input_wearing_off_string
    defb    "THE SPELL IS WEARING OFF.", $00

;;; 20152 - 20156
;
cf_redraw_on_handle_user_input:

    ; yes, recenter map on our current position.
    ; don't push past edges of map.
    ld      de, (_var_cf + VAR_CF_X)
    ld      bc, (_var_cf + VAR_CF_CX)
    ld      a, e
    sub     c
    sub     2
    cp      6
    jr      c, cf_redraw_on_handle_user_input_cx_skip
    ld      a, e
    sub     4
    jr      c, cf_redraw_on_handle_user_input_cx_0
    cp      VAR_CF_MX_CONST - 9
    jr      c, cf_redraw_on_handle_user_input_cx_end
    ld      a, VAR_CF_MX_CONST - 9
    jr      cf_redraw_on_handle_user_input_cx_end
.cf_redraw_on_handle_user_input_cx_0
    xor     a
    jr      cf_redraw_on_handle_user_input_cx_end
.cf_redraw_on_handle_user_input_cx_skip
    ld      a, c
.cf_redraw_on_handle_user_input_cx_end
    ld      e, a
    ld      a, d
    sub     b
    sub     2
    cp      5
    jr      c, cf_redraw_on_handle_user_input_cy_skip
    ld      a, d
    sub     4
    jr      c, cf_redraw_on_handle_user_input_cy_0
    cp      VAR_CF_MY_CONST - 8
    jr      c, cf_redraw_on_handle_user_input_cy_end
    ld      a, VAR_CF_MY_CONST - 8
    jr      cf_redraw_on_handle_user_input_cy_end
.cf_redraw_on_handle_user_input_cy_0
    xor     a
    jr      cf_redraw_on_handle_user_input_cy_end
.cf_redraw_on_handle_user_input_cy_skip
    ld      a, b
.cf_redraw_on_handle_user_input_cy_end
    ld      d, a
    ld      (_var_cf + VAR_CF_CX), de

    ; update AX/AY.
    ld      bc, (_var_cf + VAR_CF_X)
    ld      a, c
    sub     e
    ld      c, a
    ld      a, b
    sub     d
    ld      b, a
    ld      (_var_cf + VAR_CF_AX), bc
    call    cf_draw_text_minimap
    call    cf_redraw_hires_screen
.cf_redraw_on_handle_user_input_end
    ret

;;; 20200 - 20300 / 20350 - 20430
;
cf_other_than_move:

    ; can't attack, change modes, or various other things or while running.
    ld      a, (_var_cf + VAR_CF_RR)
    or      a
    jr      z, cf_other_than_move_check_attack
    ld      a, (_var_cfobj + VAR_CFOBJ_KEYVAL_OR_ATK)
    cp      CFOBJ_KEYVAL_TOGGLE_BIRD
    jr      z, cf_other_than_move_check_attack
    ret

    ; check for attack key.
    ; sets XZ/ZY to {-1,0,1} based on direction; sets ZF>0 on match.
.cf_other_than_move_check_attack
    ld      a, (_var_cfobj + VAR_CFOBJ_KEYVAL_OR_ATK)
    cp      CFOBJ_KEYVAL_ATTACK + $10
    jr      c, cf_other_than_move_compute_xy
    call    cf_continue_checking_keys
    ret

.cf_other_than_move_compute_xy
;   ld      a, (_var_cfobj + VAR_CFOBJ_KEYVAL_OR_ATK)
    sub     CFOBJ_KEYVAL_ATTACK
    add     a, a
    ld      e, a
    ld      d, $00
    ld      hl, cf_other_than_move_attack_vector
    add     hl, de
    ld      c, (hl)
    inc     hl
    ld      b, (hl)
    ld      (_var_cf + VAR_CF_ZX), bc
    ld      hl, (_var_cf + VAR_CF_CX)
    ld      de, (_var_cf + VAR_CF_AX)
    ld      a, l
    add     a, e
    add     a, c
    ld      e, a
    ld      a, h
    add     a, d
    add     a, b
    ld      d, a
    ld      (_var_cf + VAR_CF_X), de
    call    _game_get_ml
    ld      (_var_cf + VAR_CF_ZZ), a

    ; ZZ is type of object at target location.
    ld      a, (_var_cf + VAR_CF_HW)
    cp      1
    jr      nz, cf_other_than_move_shoot_arrow

    ; swing sword; if attacked a monster, branch.
    ld      a, (_var_cf + VAR_CF_ZZ)
    cp      1 + 1
    jr      c, cf_other_than_move_swish
    cp      VAR_CF_C0_CONST + 1
    jr      c, cf_other_than_move_swing_damage
.cf_other_than_move_swish
    cp      1
    jr      nz, cf_other_than_move_clunk
    ld      hl, cf_other_than_move_swish_string
    jr      cf_other_than_move_swish_clunk
.cf_other_than_move_clunk
    ld      hl, cf_other_than_move_clunk_string
.cf_other_than_move_swish_clunk
    ld      (_var_cf + VAR_CF_M), hl
    xor     a
    call    _cfobj_play_indexed_tone
    call    cf_print_message
    xor     a
    ld      (_var_cfobj + VAR_CFOBJ_KEYVAL_OR_ATK), a
    ret
    
    ; damage is 1-10 * level, plus bonus for a magic sword.
.cf_other_than_move_swing_damage
    ld      a, 10
    call    cf_r
    ld      c, a
    ld      a, (_var_cf + VAR_CF_EL)
    ld      b, a
    xor     a
.cf_other_than_move_swing_damage_x_el
    add     a, c
    djnz    cf_other_than_move_swing_damage_x_el
    ld      c, a
    ld      a, (_var_cf + VAR_CF_MS)
    add     a, c
    ld      e, a
    ld      d, $00
    ld      (_var_cf + VAR_CF_ZD), de
    jp      cf_other_than_move_figure_out

    ; shoot arrow.
.cf_other_than_move_shoot_arrow

    ; ZX/ZY are {-1,0,1} indicating direction of shot; player cannot shoot diagonally, so one should be zero.
    ld      de, (_var_cf + VAR_CF_ZX)
    ld      a, d
    or      a
    jr      z, cf_other_than_move_update_tile
    ld      a, e
    or      a
    jr      z, cf_other_than_move_update_tile
    ret

    ; update player tile with direction-specific bow image.
.cf_other_than_move_update_tile
    ld      a, d
    add     a, a
    add     a, e
    add     a, 18
    ld      (_var_cf + VAR_CF_ZW), a
    call    cf_update_player_bitmap
    ld      hl, (_var_cf + VAR_CF_CX)
    ld      bc, (_var_cf + VAR_CF_AX)
    ld      de, (_var_cf + VAR_CF_ZX)
    ld      a, h
    add     a, b
    add     a, d
    ld      d, a
    ld      a, l
    add     a, c
    add     a, e
    ld      e, a
    ld      (_var_cf + VAR_CF_X), de
    ld      a, (_var_cf + VAR_CF_AR)
    or      a
    jr      nz, cf_other_than_move_reduce_arrow
    ld      hl, cf_other_than_move_out_arrows_string
    ld      (_var_cf + VAR_CF_M), hl
    call    cf_print_message
    ret

    ; reduce arrow count.
.cf_other_than_move_reduce_arrow
    ld      hl, _var_cf + VAR_CF_AR
    dec     (hl)
    ld      a, (_var_cf + VAR_CF_DP)
    cp      3
    jr      z, cf_other_than_move_check_see
    ld      a, 5
    call    _game_vtab
    ld      a, 9
    call    _game_htab
    ld      a, 3
    call    _game_spc
    ld      a, 5
    call    _game_vtab
    ld      a, 9
    call    _game_htab
    ld      a, (_var_cf + VAR_CF_AR)
    ld      e, a
    ld      d, $00
    call    _game_numcpy
    call    _game_print

    ; check to see if the adjacent tile in the firing direction is occupied.
.cf_other_than_move_check_see
    ld      a, (_var_cf + VAR_CF_ZZ)
    or      a
    jr      z, cf_other_than_move_check_see_do
    ld      hl, cf_other_than_move_too_close_string
    ld      (_var_cf + VAR_CF_M), hl
    call    cf_print_message
    xor     a
    ld      (_var_cfobj + VAR_CFOBJ_KEYVAL_OR_ATK), a
    ret
.cf_other_than_move_check_see_do
    ld      de, (_var_cf + VAR_CF_X)
    ld      bc, (_var_cf + VAR_CF_CX)
    ld      a, e
    sub     c
    ld      l, a
    ld      a, d
    sub     b
    ld      h, a
    ld      (_var_cf + VAR_CF_SX), hl

    ; loop to figure out what we hit:
    xor     a
    ld      (_var_cf + VAR_CF_ZZ), a
.cf_other_than_move_arrow_loop
    ld      hl, (_var_cf + VAR_CF_X)
    ld      bc, (_var_cf + VAR_CF_CX)
    ld      a, h
    sub     b
    ld      d, a
    ld      a, l
    sub     c
    ld      e, a
    ld      (_var_cf + VAR_CF_X1), de
    ld      a, e
    cp      10
    jr      nc, cf_other_than_move_arrow_miss
    ld      a, d
    cp      9
    jr      nc, cf_other_than_move_arrow_miss
    ex      de, hl
    call    _game_get_ml
    ld      (_var_cf + VAR_CF_ZZ), a
    cp      1
    jr      z, cf_other_than_move_arrow_miss
    cp      VAR_CF_C0_CONST + 1
    jr      z, cf_other_than_move_arrow_miss
    cp      VAR_CF_C0_CONST + 2
    jr      z, cf_other_than_move_arrow_miss
    or      a
    jr      nz, cf_other_than_move_arrow_hit
    ld      de, (_var_cf + VAR_CF_X)
    ld      bc, (_var_cf + VAR_CF_ZX)
    ld      a, d
    add     a, b
    ld      d, a
    ld      a, e
    add     a, c
    ld      e, a
    ld      (_var_cf + VAR_CF_X), de
    jr      cf_other_than_move_arrow_loop
.cf_other_than_move_arrow_miss
    call    cf_arrow_animation
    ld      hl, cf_other_than_move_missed_string
    ld      (_var_cf + VAR_CF_M), hl
    call    cf_print_message
    xor     a
    ld      (_var_cfobj + VAR_CFOBJ_KEYVAL_OR_ATK), a
    ret
.cf_other_than_move_arrow_hit
    call    cf_arrow_animation

    ; hit something that isn't a wall, chest, or Inn; compute arrow damage.
    ld      a, 6
    call    cf_r
    ld      c, a
    ld      a, (_var_cf + VAR_CF_EL)
    add     a, 2
    ld      b, a
    xor     a
.cf_other_than_move_arrow_damage_x_el
    add     a, c
    djnz    cf_other_than_move_arrow_damage_x_el
    ld      e, a
    ld      d, $00
    ld      (_var_cf + VAR_CF_ZD), de

    ; figure out which monster we hit (781=$30d, 27949=$6D2D).
    ; (returns 0 if nothing found, which indicates it's part of the dragon).
.cf_other_than_move_figure_out
    ld      de, (_var_cf + VAR_CF_X)
    ld      a, (_var_cf + VAR_CF_NM)
    call    _cfobj_find_monster_index
    ld      (_var_cf + VAR_CF_ZF), a

    ; play a sound (27943=$6D27).
    call    cf_draw_hit_graphic
    ld      a, 1
    call    _cfobj_play_indexed_tone
;   ld      a, GAME_WAIT_HIT
;   call    _game_wait
    call    cf_erase_hit_graphic
    ld      a, (_var_cf + VAR_CF_ZF)
    ld      (_var_cf + VAR_CF_Z5), a
    ld      d, $00
    add     a, a
    rl      d
    ld      e, a
    ld      hl, _var_cf_mh
    add     hl, de
    push    hl
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ex      de, hl
    ld      de, (_var_cf + VAR_CF_ZD)
;;  ld      e, l
;;  ld      d, h
;;  ld      (_var_cf + VAR_CF_ZD), de
    or      a
    sbc     hl, de
    jr      nc, cf_other_than_move_calc_hp
    ld      hl, $0000
.cf_other_than_move_calc_hp
    ex      de, hl
    pop     hl
    ld      (hl), e
    inc     hl
    ld      (hl), d
    ld      hl, cf_other_than_move_you_hit_string
    call    _game_strcpy
    ld      a, (_var_cf + VAR_CF_ZZ)
    ld      d, $00
    add     a, a
    rl      d
    add     a, a
    rl      d
    add     a, a
    rl      d
    add     a, a
    rl      d
    ld      e, a
    ld      hl, _var_cf_mm
    add     hl, de
    call    _game_strcat
    ld      hl, cf_other_than_move_for_string
    call    _game_strcat
    ld      de, (_var_cf + VAR_CF_ZD)
    call    _game_numcat
    ld      hl, cf_other_than_move_points_string
    call    _game_strcat
    ld      (_var_cf + VAR_CF_M), hl
    call    cf_print_message

    ; if monster is still alive, branch.
    ld      a, (_var_cf + VAR_CF_ZF)
    ld      d, $00
    add     a, a
    rl      d
    ld      e, a
    ld      hl, _var_cf_mh
    add     hl, de
    ld      a, (hl)
    inc     hl
    or      (hl)
    jr      z, cf_other_than_move_monster_dead
    xor     a
    ld      (_var_cfobj + VAR_CFOBJ_KEYVAL_OR_ATK), a
    ret
        
    ; monster is dead; if Z5 is zero (meaning we didn't find it in the table) then we must've killed the dragon.
.cf_other_than_move_monster_dead
    ld      a, (_var_cf + VAR_CF_Z5)
    or      a
    jr      nz, cf_other_than_move_monster_dead_count
    call    cf_dragon_is_dead
    xor     a
    ld      (_var_cfobj + VAR_CFOBJ_KEYVAL_OR_ATK), a
    ret
.cf_other_than_move_monster_dead_count
    ld      hl, _var_cf + VAR_CF_KL
    inc     (hl)
    
    ; set Z8 to type of monster we just killed; if it was a Mimic, clear "stuck" flag.
    ld      a, (_var_cf + VAR_CF_ZZ)
    ld      (_var_cf + VAR_CF_Z8), a
    cp      13
    jr      nz, cf_other_than_move_draw_poof
    xor     a
    ld      (_var_cf + VAR_CF_S2), a

    ; draw "poof" death (27943=$6D27).
.cf_other_than_move_draw_poof
    ld      de, (_var_cf + VAR_CF_X)
    ld      a, VAR_CF_C0_CONST + 3
    call    _game_set_ml
    call    cf_redraw_single_tile
    ld      a, 4
    call    _cfobj_play_indexed_tone
;   ld      a, GAME_WAIT_POOF
;   call    _game_wait
    ld      de, (_var_cf + VAR_CF_X)
    xor     a
    call    _game_set_ml
    call    cf_redraw_single_tile

    ; pick a new monster type at random (3-15).
    ld      a, 13
    call    cf_r
    add     a, 2
    ld      (_var_cf + VAR_CF_ZT), a
    
    ; update experience points
    ld      a, (_var_cf + VAR_CF_Z8)
    add     a, a
    ld      e, a
    ld      d, $00
    ld      hl, _var_cf_hh
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ld      hl, (_var_cf + VAR_CF_EP)
    add     hl, de
    ld      (_var_cf + VAR_CF_EP), hl
    
    ; find an empty map square, spawn a replacement, and put it in monster table.
    call    cf_find_random_empty_map_location
    ld      a, (_var_cf + VAR_CF_Z5)
    ld      c, a
    ld      b, $00
    ld      de, (_var_cf + VAR_CF_ZX)
    ld      hl, _var_cf_bx
    add     hl, bc
    ld      (hl), e
    ld      hl, _var_cf_by
    add     hl, bc
    ld      (hl), d
    ld      a, (_var_cf + VAR_CF_ZT)
    ld      hl, _var_cf_bt
    add     hl, bc
    ld      (hl), a
    ld      hl, (_var_cf + VAR_CF_ZL)
    ld      (hl), a

    ; if it's on-screen, draw it.
    ld      de, (_var_cf + VAR_CF_ZX)
    ld      (_var_cf + VAR_CF_X), de
    call    cf_redraw_single_tile

    ; set the monster's health according to type, then pick a new type in case we want to expand the set.
    ld      a, (_var_cf + VAR_CF_ZT)
    add     a, a
    ld      e, a
    ld      d, $00
    ld      hl, _var_cf_hh
    add     hl, de
    ld      c, (hl)
    inc     hl
    ld      b, (hl)
    ld      a, (_var_cf + VAR_CF_ZF)
    ld      d, $00
    add     a, a
    rl      d
    ld      e, a
    ld      hl, _var_cf_mh
    add     hl, de
    ld      (hl), c
    inc     hl
    ld      (hl), b
    ld      a, 13
    call    cf_r
    add     a, 2
    ld      (_var_cf + VAR_CF_ZT), a

    ; if there's fewer than 170 monsters, spawn another one.
    ld      a, (_var_cf + VAR_CF_NM)
    cp      169
    jr      nc, cf_other_than_move_print_exp
    inc     a
    ld      (_var_cf + VAR_CF_NM), a

    call    cf_find_random_empty_map_location
    ld      a, (_var_cf + VAR_CF_NM)
    ld      c, a
    ld      b, $00
    ld      de, (_var_cf + VAR_CF_ZX)
    ld      hl, _var_cf_bx
    add     hl, bc
    ld      (hl), e
    ld      hl, _var_cf_by
    add     hl, bc
    ld      (hl), d
    ld      a, (_var_cf + VAR_CF_ZT)
    ld      hl, _var_cf_bt
    add     hl, bc
    ld      (hl), a
    ld      hl, (_var_cf + VAR_CF_ZL)
    ld      (hl), a
    ld      de, (_var_cf + VAR_CF_ZX)
    ld      (_var_cf + VAR_CF_X), de
    call    cf_redraw_single_tile
    ld      a, (_var_cf + VAR_CF_ZT)
    add     a, a
    ld      e, a
    ld      d, $00
    ld      hl, _var_cf_hh
    add     hl, de
    ld      c, (hl)
    inc     hl
    ld      b, (hl)
    ld      a, (_var_cf + VAR_CF_ZF)
    ld      d, $00
    add     a, a
    rl      d
    ld      e, a
    ld      hl, _var_cf_mh
    add     hl, de
    ld      (hl), c
    inc     hl
    ld      (hl), b
.cf_other_than_move_print_exp
    ld      a, (_var_cf + VAR_CF_DP)
    cp      3
    jr      z, cf_other_than_move_done
    ld      a, 7
    call    _game_vtab
    ld      a, 1
    call    _game_htab
    ld      hl, cf_other_than_move_exp_string
    call    _game_strcpy
    ld      de, (_var_cf + VAR_CF_EP)
    call    _game_numcat
    ld      (_var_cf + VAR_CF_M), hl
    call    _game_print

.cf_other_than_move_done
    xor     a
    ld      (_var_cfobj + VAR_CFOBJ_KEYVAL_OR_ATK), a

    ret

.cf_other_than_move_swish_string
    defb    "SWISH...", $00
.cf_other_than_move_clunk_string
    defb    "CLUNK!", $00
.cf_other_than_move_out_arrows_string
    defb    "OUT OF ARROWS!", $00
.cf_other_than_move_too_close_string
    defb    "TOO CLOSE!", $00
.cf_other_than_move_missed_string
    defb    "MISSED...", $00
.cf_other_than_move_you_hit_string
    defb    "YOU HIT THE ", $00
.cf_other_than_move_for_string
    defb    " FOR ", $00
.cf_other_than_move_points_string
    defb    " POINTS.", $00
.cf_other_than_move_exp_string
    defb    "EXP:    ", $00

;;; 20500 - 20920
; continue checking keys.
;
cf_continue_checking_keys:

    ; toggle messages on/off.
.cf_continue_checking_keys_toggle_message
    ld      a, (_var_cfobj + VAR_CFOBJ_KEYVAL_OR_ATK)
    cp      CFOBJ_KEYVAL_TOGGLE_MESSAGE
    jr      nz, cf_continue_checking_keys_recenter_map
    ld      a, (_var_cf + VAR_CF_SM)
    xor     %00000001
    ld      (_var_cf + VAR_CF_ZJ), a
    call    _game_inverse
    ld      a, 1
    ld      (_var_cf + VAR_CF_SM), a
    ld      a, (_var_cf + VAR_CF_ZJ)
    add     a, a
    add     a, a
    add     a, a
    add     a, a
    ld      e, a
    ld      d, $00
    ld      hl, cf_continue_checking_keys_toggle_message_string
    add     hl, de
    ld      (_var_cf + VAR_CF_M), hl
    call    cf_print_message
    call    _game_normal
    ld      a, (_var_cf + VAR_CF_ZJ)
    ld      (_var_cf + VAR_CF_SM), a
    ret

    ; recenter map.
.cf_continue_checking_keys_recenter_map
    cp      CFOBJ_KEYVAL_CENTER_SCREEN
    jr      nz, cf_continue_checking_keys_toggle_weapon
    ld      de, (_var_cf + VAR_CF_CX)
    ld      bc, (_var_cf + VAR_CF_AX)
    ld      a, e
    add     a, c
    ld      l, a
    ld      a, d
    add     a, b
    ld      h, a
    ld      (_var_cf + VAR_CF_X), hl
    ld      a, l
    sub     4
    jr      nc, cf_continue_checking_keys_recenter_map_x_max
    xor     a
    jr      cf_continue_checking_keys_recenter_map_x
.cf_continue_checking_keys_recenter_map_x_max
    cp      VAR_CF_MX_CONST - 9
    jr      c, cf_continue_checking_keys_recenter_map_x
    ld      a, VAR_CF_MX_CONST - 9
.cf_continue_checking_keys_recenter_map_x
    ld      e, a
    ld      a, h
    sub     4
    jr      nc, cf_continue_checking_keys_recenter_map_y_max
    xor     a
    jr      cf_continue_checking_keys_recenter_map_y
.cf_continue_checking_keys_recenter_map_y_max
    cp      VAR_CF_MY_CONST - 8
    jr      c, cf_continue_checking_keys_recenter_map_y
    ld      a, VAR_CF_MY_CONST - 8
.cf_continue_checking_keys_recenter_map_y
    ld      d, a
    ld      (_var_cf + VAR_CF_CX), de
    ld      a, l
    sub     e
    ld      c, a
    ld      a, h
    sub     d
    ld      b, a
    ld      (_var_cf + VAR_CF_AX), bc
    call    cf_redraw_hires_screen
    call    cf_draw_text_minimap
    ret

    ; toggle weapon 1/2.
.cf_continue_checking_keys_toggle_weapon
    cp      CFOBJ_KEYVAL_TOGGLE_WEAPON
    jr      nz, cf_continue_checking_keys_buy_arrows
    ld      a, (_var_cf + VAR_CF_HW)
    sub     3
    neg
    ld      (_var_cf + VAR_CF_HW), a
    call    cf_update_wield
    ld      a, (_var_cf + VAR_CF_HW)
    add     a, 17
    ld      (_var_cf + VAR_CF_ZW), a
    call    cf_update_player_bitmap
    xor     a
    ld      (_var_cfobj + VAR_CFOBJ_KEYVAL_OR_ATK), a
    ret

    ; 10 gold for 5 arrows.
.cf_continue_checking_keys_buy_arrows
    cp      CFOBJ_KEYVAL_BUY_ARROWS
    jr      nz, cf_continue_checking_keys_buy_hp
    ld      a, (_var_cf + VAR_CF_DP)
    cp      3
    ret     z
    ld      a, (_var_cf + VAR_CF_T0)
    or      a
    ret     z
    ld      a, 5
    ld      (_var_cf + VAR_CF_ZA), a
    ld      a, (_var_cf + VAR_CF_AR)
    cp      95
    jr      nc, cf_continue_checking_keys_buy_arrows_cant_carry
    ld      hl, (_var_cf + VAR_CF_GP)
    ld      de, 5 * 2
    or      a
    sbc     hl, de
    jr      c, cf_continue_checking_keys_buy_arrows_more_gold
    ld      (_var_cf + VAR_CF_GP), hl
    ld      a, (_var_cf + VAR_CF_AR)
    add     a, 5
    ld      (_var_cf + VAR_CF_AR), a
    call    cf_update_gold
    call    cf_update_arrows
    jr      cf_continue_checking_keys_buy_arrows_end
.cf_continue_checking_keys_buy_arrows_cant_carry
    ld      hl, cf_continue_checking_keys_buy_arrows_cant_carry_string
    ld      (_var_cf + VAR_CF_M), hl
    call    cf_print_message
    jr      cf_continue_checking_keys_buy_arrows_end
.cf_continue_checking_keys_buy_arrows_more_gold
    ld      hl, cf_continue_checking_keys_buy_arrows_more_gold_string
    ld      (_var_cf + VAR_CF_M), hl
    call    cf_print_message
;   jr      cf_continue_checking_keys_buy_arrows_end
.cf_continue_checking_keys_buy_arrows_end
    xor     a
    ld      (_var_cfobj + VAR_CFOBJ_KEYVAL_OR_ATK), a
    ret

    ; 25 gold for 5 HP.
.cf_continue_checking_keys_buy_hp
    cp      CFOBJ_KEYVAL_BUY_HP
    jr      nz, cf_continue_checking_keys_run
    ld      a, (_var_cf + VAR_CF_DP)
    cp      3
    ret     z
    ld      a, (_var_cf + VAR_CF_T0)
    or      a
    ret     z
    ld      a, 5
    ld      (_var_cf + VAR_CF_ZA), a
    ld      hl, (_var_cf + VAR_CF_GP)
    ld      de, 5 * 5
    or      a
    sbc     hl, de
    jr      c, cf_continue_checking_keys_buy_hp_more_gold
    ld      (_var_cf + VAR_CF_GP), hl
    ld      hl, (_var_cf + VAR_CF_BH)
    ld      de, 5
    add     hl, de
    ld      (_var_cf + VAR_CF_BH), hl
    ld      (_var_cf + VAR_CF_HP), hl
    call    cf_update_gold
    call    cf_update_hp
    jr      cf_continue_checking_keys_buy_hp_end
.cf_continue_checking_keys_buy_hp_more_gold
    ld      hl, cf_continue_checking_keys_buy_hp_more_gold_string
    ld      (_var_cf + VAR_CF_M), hl
    call    cf_print_message
;   jr      cf_continue_checking_keys_buy_hp_end
.cf_continue_checking_keys_buy_hp_end
    xor     a
    ld      (_var_cfobj + VAR_CFOBJ_KEYVAL_OR_ATK), a
    ret

    ; if currently running, cancel run mod.
.cf_continue_checking_keys_run
    cp      CFOBJ_KEYVAL_TOGGLE_BIRD
    jr      nz, cf_continue_checking_keys_end
    ld      a, (_var_cf + VAR_CF_RR)
    or      a
    jr      z, cf_continue_checking_keys_run_0
    jp      m, cf_continue_checking_keys_end
    ld      a, -4
    ld      (_var_cf + VAR_CF_RR), a
    call    cf_update_player_bitmap_when_rr
    jr      cf_continue_checking_keys_run_end
.cf_continue_checking_keys_run_0
    ld      a, (_var_cf + VAR_CF_SL)
    sub     24
    neg
    ld      (_var_cf + VAR_CF_RR), a
    call    cf_update_player_bitmap_when_rr
    ld      hl, cf_continue_checking_keys_run_away_string
    ld      (_var_cf + VAR_CF_M), hl
    call    cf_print_message
    ld      a, 1
    ld      (_var_cf + VAR_CF_ZA), a
;   jr      cf_continue_checking_keys_run_end
.cf_continue_checking_keys_run_end
    xor     a
    ld      (_var_cfobj + VAR_CFOBJ_KEYVAL_OR_ATK), a
    ret

.cf_continue_checking_keys_end
    ret

.cf_continue_checking_keys_toggle_message_string
    defs    $10, "MESSAGES OFF."
    defs    $10, "MESSAGES ON."
.cf_continue_checking_keys_buy_arrows_cant_carry_string
    defb    "CAN'T CARRY ANY MORE!", $00
.cf_continue_checking_keys_buy_arrows_more_gold_string
.cf_continue_checking_keys_buy_hp_more_gold_string
    defb    "YOU NEED MORE GOLD FIRST.", $00
.cf_continue_checking_keys_run_away_string
    defb    "RUN AWAY!", $00

;;; 30000 - 30050
; move monsters.
;
cf_move_monsters:

    ld      a, (_var_cf + VAR_CF_TN)
    inc     a
    ld      (_var_cf + VAR_CF_TN), a
    ld      de, (_var_cf + VAR_CF_CX)
    ld      bc, (_var_cf + VAR_CF_AX)
    ld      a, d
    add     a, b
    ld      h, a
    ld      a, e
    add     a, c
    ld      l, a
    ld      (_var_cfobj + VAR_CFOBJ_PLAYER_MAP_X), hl
    ld      a, (_var_cf + VAR_CF_DP)
    ld      (_var_cfobj + VAR_CFOBJ_DISPLAY_MODE), a
    ld      (_var_cfobj + VAR_CFOBJ_PLAYER_WIN_X), bc
    
    ; 27919=$6D0F.
    ld      a, (_var_cf + VAR_CF_NM)
    ld      (_var_cfobj + VAR_CFOBJ_MONSTER_COUNT), a
    call    _cfobj_move_monsters
    ld      a, (_var_cfobj + VAR_CFOBJ_MON_ATTACK_COUNT)
    or      a
    call    nz, cf_handle_all_monster_attacks

    ; check for zap by wizards -- window X/Y will be other than $ff/$ff.
    ; first wizard's coords in 795/796; second coords in 797/798.
    ld      a, 95
    ld      (_var_cf + VAR_CF_Z7), a
    ld      a, (_var_cfobj + VAR_CFOBJ_ATK_WIZ1_X)
    cp      30
    jr      nc, cf_move_monsters_check_dragon_frame
    call    cf_wizard_ranged_attack
    ld      a, 97
    ld      (_var_cf + VAR_CF_Z7), a
    ld      a, (_var_cfobj + VAR_CFOBJ_ATK_WIZ2_X)
    cp      30
    jr      nc, cf_move_monsters_check_dragon_frame
    call    cf_wizard_ranged_attack
	
    ; check for hit by dragon flame.
.cf_move_monsters_check_dragon_frame
    ld      a, (_var_cfobj + VAR_CFOBJ_HIT_BY_FLAME)
    or      a
    call    nz, cf_hit_by_dragon_frame_attack

    ; if we're next to the dragon, it will attack us.
    ld      de, (_var_cf + VAR_CF_CX)
    ld      bc, (_var_cf + VAR_CF_AX)
    ld      a, e
    add     a, c
    cp      73 + 1
    jr      c, cf_move_monsters_end
    ld      a, d
    add     a, b
    cp      70 + 1
    jr      c, cf_move_monsters_end
    cp      74
    jr      nc, cf_move_monsters_end
    ld      a, (_var_cf + VAR_CF_EL)
    cp      9
    jr      nc, cf_move_monsters_end
    ld      a, 35
    ld      (_var_cf + VAR_CF_MT), a
    call    cf_handle_single_monster_attack_by_mt

.cf_move_monsters_end
    ret

;;; 31000 - 31000
; handle all monster attacks.
;
cf_handle_all_monster_attacks:

    ; 782($30e): number of attacks (0-3).
    ; 783-786($30f-312): attacking monster ID (0-169).
    ld      bc, $0000
.cf_handle_all_monster_attacks_loop
    ld      hl, _var_cfobj + VAR_CFOBJ_MON_ATTACK_ID0
    add     hl, bc
    ld      a, (hl)
    ld      (_var_cf + VAR_CF_ZC), a
    push    bc
    call    cf_handle_single_monster_attack
    pop     bc
    inc     c
    ld      hl, _var_cfobj + VAR_CFOBJ_MON_ATTACK_COUNT
    ld      a, c
    cp      (hl)
    jr      c, cf_handle_all_monster_attacks_loop

    ret

;;; 32000 - 32000
; handle single monster attack (ident 0-169 in ZC).
;
cf_handle_single_monster_attack:

    ld      a, (_var_cf + VAR_CF_ZC)
    ld      c, a
    ld      b, $00
    ld      hl, _var_cf_bt
    add     hl, bc
    ld      a, (hl)
    ld      (_var_cf + VAR_CF_MT), a
    call    cf_handle_single_monster_attack_by_mt

    ret

;;; 32010 - 32030
;
cf_handle_single_monster_attack_by_mt:

    ; check for block (can't block with bow, when running, or when attacked by Invisoid).
    ld      a, (_var_cf + VAR_CF_HW)
    cp      1
    jr      nz, cf_handle_single_monster_attack_by_mt_no_block
    ld      a, (_var_cf + VAR_CF_RR)
    or      a
    jr      nz, cf_handle_single_monster_attack_by_mt_no_block
    ld      a, (_var_cf + VAR_CF_MT)
    cp      9
    jr      z, cf_handle_single_monster_attack_by_mt_no_block
    ld      a, (_var_cf + VAR_CF_SH)
    ld      c, a
    ld      a, (_var_cf + VAR_CF_EL)
    add     a, c
    ld      c, a
    ld      a, 20
    call    cf_r
    dec     a
    cp      c
    jr      nc, cf_handle_single_monster_attack_by_mt_no_block
    ld      a, (_var_cf + VAR_CF_MT)
    ld      d, $00
    add     a, a
    rl      d
    add     a, a
    rl      d
    add     a, a
    rl      d
    add     a, a
    rl      d
    ld      e, a
    ld      hl, _var_cf_mm
    add     hl, de
    call    _game_strcpy
    ld      hl, cf_handle_single_monster_attack_by_mt_block_string
    call    _game_strcat
    ld      (_var_cf + VAR_CF_M), hl
    call    cf_print_message
    ret

.cf_handle_single_monster_attack_by_mt_no_block
    ld      de, (_var_cf + VAR_CF_CX)
    ld      bc, (_var_cf + VAR_CF_AX)
    ld      a, e
    add     a, c
    ld      l, a
    ld      a, d
    add     a, b
    ld      h, a
    ld      (_var_cf + VAR_CF_X), hl
    call    cf_draw_hit_graphic
    ld      a, 2
    call    _cfobj_play_indexed_tone
;   ld      a, GAME_WAIT_HIT
;   call    _game_wait
    call    cf_erase_hit_graphic
    ld      a, (_var_cf + VAR_CF_MT)
    ld      d, $00
    add     a, a
    rl      d
    add     a, a
    rl      d
    add     a, a
    rl      d
    add     a, a
    rl      d
    ld      e, a
    ld      hl, _var_cf_mm
    add     hl, de
    call    _game_strcpy
    ld      hl, cf_handle_single_monster_attack_by_mt_attack_string
    call    _game_strcat
    ld      (_var_cf + VAR_CF_M), hl
    call    cf_print_message

    ; damage is limited to 70% of value in table.
    ld      a, (_var_cf + VAR_CF_MT)
    ld      e, a
    ld      d, $00
    ld      hl, _var_cf_aa
    add     hl, de
    ld      a, (hl)
    srl     a
    srl     a
    sub     (hl)
    neg
    call    cf_r
    ld      l, a
    ld      h, $00
    ld      (_var_cf + VAR_CF_ZD), hl
    call    cf_handle_player_being_hit

    ; successful attack by mimic makes you immobile.
    ld      a, (_var_cf + VAR_CF_MT)
    cp      13
    jr      nz, cf_handle_single_monster_attack_by_mt_end
    ld      a, (_var_cf + VAR_CF_S2)
    or      a
    jr      nz, cf_handle_single_monster_attack_by_mt_end
    ld      hl, cf_handle_single_monster_attack_by_mt_mimic_string
    ld      (_var_cf + VAR_CF_M), hl
    ld      a, 1
    ld      (_var_cf + VAR_CF_S2), a
    ld      (_var_cf + VAR_CF_O9), a
    call    cf_print_message

.cf_handle_single_monster_attack_by_mt_end
    ret

.cf_handle_single_monster_attack_by_mt_block_string
    defb    " BLOCKED WITH SHIELD.", $00
.cf_handle_single_monster_attack_by_mt_attack_string
    defb    " ATTACKS, ", $00
.cf_handle_single_monster_attack_by_mt_mimic_string
    defb    "YOU'RE STUCK TO THE MIMIC!", $00

;;; 33000 - 33060
; wizard ranged attack.
;
cf_wizard_ranged_attack:

    ld      a, (_var_cf + VAR_CF_Z7)
    cp      95
    jr      nz, cf_wizard_ranged_attack_wiz2
    ld      de, (_var_cfobj + VAR_CFOBJ_ATK_WIZ1_X)
    jr      cf_wizard_ranged_attack_select
.cf_wizard_ranged_attack_wiz2
    ld      de, (_var_cfobj + VAR_CFOBJ_ATK_WIZ2_X)
.cf_wizard_ranged_attack_select
    ld      (_var_cf + VAR_CF_ZX), de
    ld      (_var_cf + VAR_CF_ZB), de
;   ld      a, 816
;   ld      (_var_cf + VAR_CF_ZD), a
;   xor     a
;   ld      (_var_cf + VAR_CF_ZG), a
;   ld      a, 2
;   ld      (_var_cf + VAR_CF_ZH), a
    xor     a
    ld      (_var_cf + VAR_CF_ZE), a
    ld      (_var_cf + VAR_CF_ZF), a

    ; vertical attack.
;   ld      de, (_var_cf + VAR_CF_ZX)
    ld      bc, (_var_cf + VAR_CF_AX)
    ld      a, e
    cp      c
    jr      nz, cf_wizard_ranged_attack_horizontal
    ld      h, 3
    ld      a, b
    sub     d
    jr      nc, cf_wizard_ranged_attack_set
    neg
    ld      h, 1
    jr      cf_wizard_ranged_attack_set

    ; horizontal attack.
.cf_wizard_ranged_attack_horizontal
    ld      h, 2
    ld      a, c
    sub     e
    jr      nc, cf_wizard_ranged_attack_set
    neg
    ld      h, 0
;   jr      cf_wizard_ranged_attack_set

.cf_wizard_ranged_attack_set
    ld      (_var_cf + VAR_CF_ZF), a
    ld      a, h
    ld      (_var_cf + VAR_CF_ZE), a

    ; draw twice in "invert" mode (ZH=2); first draws, second erases.
    ;  ZA = colorIndex = 5 (white).
    ;  ZB = screen X coord of wizard.
    ;  ZC = screen Y coord of wizard.
    ;  ZD = data ptr (816/$330).
    ;  ZE = direction (0=left, 1=up, 2=right, 3=down).
    ;  ZF = distance in squares, * 16.
    ;  ZG = angle = 0.
    ;  ZH = drawMode = 2 (invert).
.cf_wizard_ranged_attack_draw
    ld      de, (_var_cf + VAR_CF_ZB)
    ld      a, e
    add     a, a
    add     a, a
    ld      e, a
    ld      a, d
    add     a, a
    add     a, d
    dec     a
    ld      d, a
    ld      bc, (_var_cf + VAR_CF_ZE)
.cf_wizard_ranged_attack_draw_left
    ld      a, c
    or      a
    jr      nz, cf_wizard_ranged_attack_draw_right
    dec     e
    dec     e
    ld      c, -4
    ld      a, b
    dec     a
    jr      z, cf_wizard_ranged_attack_draw_left_1
    ld      hl, $0002
    ld      (_var_cf + VAR_CF_ZD), hl
    jr      cf_wizard_ranged_attack_draw_horizontal
.cf_wizard_ranged_attack_draw_left_1
    ld      hl, $0303
    ld      (_var_cf + VAR_CF_ZD), hl
    jr      cf_wizard_ranged_attack_draw_horizontal
.cf_wizard_ranged_attack_draw_right
    cp      2
    jr      nz, cf_wizard_ranged_attack_draw_up
    inc     e
    inc     e
    ld      c, 4
    ld      a, b
    dec     a
    jr      z, cf_wizard_ranged_attack_draw_right_1
    ld      hl, $0200
    ld      (_var_cf + VAR_CF_ZD), hl
    jr      cf_wizard_ranged_attack_draw_horizontal
.cf_wizard_ranged_attack_draw_right_1
    ld      hl, $0303
    ld      (_var_cf + VAR_CF_ZD), hl
;   jr      cf_wizard_ranged_attack_draw_horizontal
.cf_wizard_ranged_attack_draw_horizontal
    push    bc
    push    de
    ld      a, (_var_cf + VAR_CF_ZD_L)
    call    _game_draw_lbolt
    dec     b
    jr      z, cf_wizard_ranged_attack_draw_horizontal_done
.cf_wizard_ranged_attack_draw_horizontal_loop
    ld      a, e
    add     a, c
    ld      e, a
    dec     b
    jr      z, cf_wizard_ranged_attack_draw_horizontal_tail
    ld      a, 1
    call    _game_draw_lbolt
    jr      cf_wizard_ranged_attack_draw_horizontal_loop
.cf_wizard_ranged_attack_draw_horizontal_tail
    ld      a, (_var_cf + VAR_CF_ZD_H)
    call    _game_draw_lbolt
.cf_wizard_ranged_attack_draw_horizontal_done
    ld      a, 5
    call    _cfobj_play_indexed_tone
;   ld      a, GAME_WAIT_LBOLT
;   call    _game_wait
    pop     de
    pop     bc
.cf_wizard_ranged_attack_erase_horizontal_loop
    call    _game_erase_lbolt
    ld      a, e
    add     a, c
    ld      e, a
    djnz    cf_wizard_ranged_attack_erase_horizontal_loop
    jr      cf_wizard_ranged_attack_damage
.cf_wizard_ranged_attack_draw_up
    cp      1
    jr      nz, cf_wizard_ranged_attack_draw_down
    dec     d
    dec     d
    ld      c, -3
    ld      a, b
    dec     a
    jr      z, cf_wizard_ranged_attack_draw_up_1
    ld      hl, $0406
    ld      (_var_cf + VAR_CF_ZD), hl
    jr      cf_wizard_ranged_attack_draw_vertical
.cf_wizard_ranged_attack_draw_up_1
    ld      hl, $0707
    ld      (_var_cf + VAR_CF_ZD), hl
    jr      cf_wizard_ranged_attack_draw_vertical
.cf_wizard_ranged_attack_draw_down
    inc     d
    inc     d
    ld      c, 3
    ld      a, b
    dec     a
    jr      z, cf_wizard_ranged_attack_draw_down_1
    ld      hl, $0604
    ld      (_var_cf + VAR_CF_ZD), hl
    jr      cf_wizard_ranged_attack_draw_vertical
.cf_wizard_ranged_attack_draw_down_1
    ld      hl, $0707
    ld      (_var_cf + VAR_CF_ZD), hl
;   jr      cf_wizard_ranged_attack_draw_vertical
.cf_wizard_ranged_attack_draw_vertical
    push    bc
    push    de
    ld      a, (_var_cf + VAR_CF_ZD_L)
    call    _game_draw_lbolt
    dec     b
    jr      z, cf_wizard_ranged_attack_draw_vertical_done
.cf_wizard_ranged_attack_draw_vertical_loop
    ld      a, d
    add     a, c
    ld      d, a
    dec     b
    jr      z, cf_wizard_ranged_attack_draw_vertical_tail
    ld      a, 5
    call    _game_draw_lbolt
    jr      cf_wizard_ranged_attack_draw_vertical_loop
.cf_wizard_ranged_attack_draw_vertical_tail
    ld      a, (_var_cf + VAR_CF_ZD_H)
    call    _game_draw_lbolt
.cf_wizard_ranged_attack_draw_vertical_done
    ld      a, 5
    call    _cfobj_play_indexed_tone
;   ld      a, GAME_WAIT_LBOLT
;   call    _game_wait
    pop     de
    pop     bc
.cf_wizard_ranged_attack_erase_vertical_loop
    call    _game_erase_lbolt
    ld      a, d
    add     a, c
    ld      d, a
    djnz    cf_wizard_ranged_attack_erase_vertical_loop
;   jr      cf_wizard_ranged_attack_damage

    ; damage is (1-50)+25 rather than melee monster damage.
.cf_wizard_ranged_attack_damage
    ld      hl, cf_wizard_ranged_attack_zappo_string
    ld      (_var_cf + VAR_CF_M), hl
    call    cf_print_message
    ld      a, 50
    call    cf_r
    add     a, 25
    ld      e, a
    ld      d, $00
    ld      (_var_cf + VAR_CF_ZD), de
    call    cf_handle_player_being_hit

    ret

.cf_wizard_ranged_attack_zappo_string
    defb    "ZAPPO!  ", $00

;;; 40000 - 40030
; dragon is dead.
;
cf_dragon_is_dead:

    ; draw a solid box in "invert" mode on the dragon, and play sound.
    ld      bc, (_var_cf + VAR_CF_CX)
    ld      a, 75
    sub     c
    add     a, a
    add     a, a
    ld      c, a
    ld      a, 71
    sub     b
    ld      b, a
    add     a, a
    add     a, b
    dec     a
    ld      b, a
    ld      d, 71
.cf_dragon_is_dead_invert_y
    ld      a, b
    inc     a
    cp      XCS_IO_TEXT_VRAM_SIZE_Y
    jr      nc, cf_dragon_is_dead_invert_skip_y
    push    bc
    ld      e, 75
.cf_dragon_is_dead_invert_x
    ld      a, c
    cp      XCS_IO_TEXT_VRAM_SIZE_X
    call    c, _game_invert_ml_tile
    inc     e
    inc     c
    inc     c
    inc     c
    inc     c
    ld      a, e
    cp      78
    jr      nz, cf_dragon_is_dead_invert_x
    pop     bc
.cf_dragon_is_dead_invert_skip_y
    inc     d
    inc     b
    inc     b
    inc     b
    ld      a, d
    cp      73
    jr      nz, cf_dragon_is_dead_invert_y

    ; remove all dragon tiles.
    ld      de, (_var_cf + VAR_CF_CX)
    ld      a, 75
    sub     e
    ld      e, a
    ld      a, 71
    sub     d
    ld      d, a
    ld      (_var_cf + VAR_CF_ZX), de
    ld      d, 71
.cf_dragon_is_dead_loop_y
    ld      e, 75
.cf_dragon_is_dead_loop_x
    xor     a
    call    _game_set_ml
    inc     e
    ld      a, e
    cp      78
    jr      nz, cf_dragon_is_dead_loop_x
    inc     d
    ld      a, d
    cp      73
    jr      nz, cf_dragon_is_dead_loop_y
    
    ; draw a solid box in "invert" mode on the dragon, and play sound.
    ld      a, 3
    call    _cfobj_play_indexed_tone
;   ld      a, GAME_WAIT_DRAGON
;   call    _game_wait
    call    cf_redraw_hires_screen
    call    cf_draw_text_minimap

    ; disable dragon breath.
    ld      a, 9
    ld      (_var_cfobj + VAR_CFOBJ_DRAGON_BREATH_READY), a
    
    ; give up to 800 HP.
    ld      a, (_var_cf + VAR_CF_EL)
    sub     9
    neg
    ld      b, a
    ld      de, 100
    ld      hl, 0
.cf_dragon_is_dead_calc_hp
    add     hl, de
    djnz    cf_dragon_is_dead_calc_hp
    ex      de, hl
    ld      hl, (_var_cf + VAR_CF_BH)
    add     hl, de
    ld      (_var_cf + VAR_CF_BH), hl
    ld      hl, (_var_cf + VAR_CF_HP)
    add     hl, de
    ld      (_var_cf + VAR_CF_HP), hl
    ld      a, 9
    ld      (_var_cf + VAR_CF_EL), a
    call    cf_update_hp
    call    cf_update_experience_rank

    ret

;;; 42000 - 42000
; hit by dragon flame attack.
;
cf_hit_by_dragon_frame_attack:

    ld      hl, cf_hit_by_dragon_frame_attack_sizzle_string
    ld      (_var_cf + VAR_CF_M), hl
    ld      a, 250
    ld      (_var_cf + VAR_CF_ZD), a
    call    cf_print_message
    call    cf_handle_player_being_hit

    ret

.cf_hit_by_dragon_frame_attack_sizzle_string
    defb    "SIZZLE! ", $00

;;; 50000 - 50100
; initial setup.
;
cf_initial_setup:

    ; ask player for game parameters.
    call    _game_text
    call    _game_home
    ld      hl, cf_initial_setup_ask_name_string
    ld      de, (('~' + $01) << 8) | ' '
    call    _game_input
    ld      hl, _var_cf_nn
    call    _game_copy_input_buffer
    call    _game_linebreak
    call    _game_linebreak
    ld      hl, cf_initial_setup_ask_skill_level_string
    ld      de, (('9' + $01) << 8) | '1'
    call    _game_inkey
    sub     '0'
    ld      (_var_cf + VAR_CF_SL), a
    call    _game_linebreak
    call    _game_linebreak
    ld      hl, cf_initial_setup_ask_game_speed_string
    ld      de, (('9' + $01) << 8) | '0'
    call    _game_input
    ld      a, (hl)
    sub     '0'
    jr      c, cf_initial_setup_ask_game_speed_default
    ld      d, a
    inc     hl
    ld      a, (hl)
    sub     '0'
    ld      e, a
    ld      a, d
    jr      c, cf_initial_setup_ask_game_speed_range
    add     a, a
    ld      d, a
    add     a, a
    add     a, a
    add     a, d
    add     a, e
.cf_initial_setup_ask_game_speed_range
    or      a
    jr      z, cf_initial_setup_ask_game_speed_default
    cp      50 + $01
    jr      c, cf_initial_setup_ask_game_speed_za
.cf_initial_setup_ask_game_speed_default
    ld      a, 50
.cf_initial_setup_ask_game_speed_za
    ld      (_var_cf + VAR_CF_ZA), a

    ; store speed-1 in $319.
;   ld      a, (_var_cf + VAR_CF_ZA)
    dec     a
    ld      (_var_cfobj + VAR_CFOBJ_TURN_SPEED), a
    ld      a, (_var_cf + VAR_CF_SL)
    cp      $07 + $01
    ld      a, $00
    ccf
    adc     a, $00
    ld      (_var_cf + VAR_CF_ZD), a

    ; for skill levels 8/9 add a couple of walls to make the maze harder to traverse.
    ; (7,39) and (6,42) are visible from starting point.
    ld      de, (39 << 8) | 7
;   ld      a, (_var_cf + VAR_CF_ZD)
    push    af
    call    _game_set_ml
    ld      de, (42 << 8) | 6
    pop     af
    call    _game_set_ml
    call    _game_linebreak
    call    _game_linebreak
    call    _game_linebreak
    call    _game_linebreak
    call    _game_linebreak
    call    _game_inverse
    ld      hl, cf_initial_setup_one_moment_string
    call    _game_print
    call    _game_normal

    ; 終了
.cf_initial_setup_end
    ret

; ask player name
.cf_initial_setup_ask_name_string
    defb    "YOUR NAME, WARRIOR? ", $00
.cf_initial_setup_ask_skill_level_string
    defb    "SKILL LEVEL (1-9)? ", $00
.cf_initial_setup_ask_game_speed_string
    defb    "GAME SPEED (1-50)? ", $00
.cf_initial_setup_one_moment_string
    defb    "ONE MOMENT WHILE I AWAKEN THE MONSTERS.", $00

;;; 51000 - 51080
; handle player being hit.
;
cf_handle_player_being_hit:

    ; is dead ?
    ld      de, (_var_cf + VAR_CF_HP)
    ld      a, d
    or      e
    ret     z

;;  ld      de, 1
;;  ld      (_var_cf + VAR_CF_ZD), de

    ; damage taken is in ZD.
    ld      de, (_var_cf + VAR_CF_ZD)
    call    _game_numcpy
    ld      hl, cf_handle_player_being_hit_hits_string
    call    _game_strcat
    ld      (_var_cf + VAR_CF_M), hl
    call    cf_print_message
    ld      hl, (_var_cf + VAR_CF_HP)
    ld      de, (_var_cf + VAR_CF_ZD)
    or      a
    sbc     hl, de
    jr      nc, cf_handle_player_being_hit_calc_hp
    ld      hl, $0000
.cf_handle_player_being_hit_calc_hp
    ld      (_var_cf + VAR_CF_HP), hl
    call    cf_update_hp
    ld      hl, (_var_cf + VAR_CF_HP)
    ld      a, h
    or      l
    jr      nz, cf_handle_player_being_hit_weak

    ; play funeral song ($6D24).
    call    _cfobj_play_funeral
    ld      a, (_var_cf + VAR_CF_DP)
    cp      3
    jr      nz, cf_handle_player_being_hit_dead_dp
    ld      a, 2
    ld      (_var_cf + VAR_CF_DP), a
    call    cf_draw_character_sheet
.cf_handle_player_being_hit_dead_dp
    call    _game_inverse
    ld      hl, cf_handle_player_being_hit_dead_string
    ld      (_var_cf + VAR_CF_M), hl
    call    cf_print_message
    call    _game_normal
    call    _game_text
    ld      a, 25
    call    _game_vtab
    ld      a, 1
    call    _game_htab
    ld      hl, cf_handle_player_being_hit_play_again_string
    call    _game_print_without_linebreak
.cf_handle_player_being_hit_dead_loop
    call    _app_update
    ld      a, (_xcs_key_code_edge)
    or      a
    jr      z, cf_handle_player_being_hit_dead_loop
    ld      a, CF_STATE_OVER
    ld      (cf_state), a
    ret
.cf_handle_player_being_hit_weak
    ld      a, (_var_cf + VAR_CF_H4)
    or      a
    jr      nz, cf_handle_player_being_hit_lost
    ld      de, (_var_cf + VAR_CF_BH)
    srl     d
    rr      e
    srl     d
    rr      e
    ld      hl, (_var_cf + VAR_CF_HP)
    or      a
    sbc     hl, de
    jr      nc, cf_handle_player_being_hit_lost
    ld      a, 1
    ld      (_var_cf + VAR_CF_H4), a
    ld      (_var_cf + VAR_CF_O9), a
    ld      hl, cf_handle_player_being_hit_weak_string
    ld      (_var_cf + VAR_CF_M), hl
    call    cf_print_message
.cf_handle_player_being_hit_lost
    ld      a, (_var_cf + VAR_CF_H4)
    cp      1
    jr      nz, cf_handle_player_being_hit_end
    ld      de, (_var_cf + VAR_CF_BH)
    srl     d
    rr      e
    srl     d
    rr      e
    srl     d
    rr      e
    ld      hl, (_var_cf + VAR_CF_HP)
    or      a
    sbc     hl, de
    jr      nc, cf_handle_player_being_hit_end
    ld      a, 2
    ld      (_var_cf + VAR_CF_H4), a
    ld      a, 1
    ld      (_var_cf + VAR_CF_O9), a
    ld      hl, cf_handle_player_being_hit_lost_string
    ld      (_var_cf + VAR_CF_M), hl
    call    cf_print_message
.cf_handle_player_being_hit_end
    ret

.cf_handle_player_being_hit_hits_string
    defb    " HITS.", $00
.cf_handle_player_being_hit_dead_string
    defb    "YOU'RE DEAD!", $00
.cf_handle_player_being_hit_play_again_string
    defb    "PRESS ANY KEY TO PLAY AGAIN....", $00
.cf_handle_player_being_hit_weak_string
    defb    "YOU'RE FEELING WEAK.", $00
.cf_handle_player_being_hit_lost_string
    defb    "YOU'VE LOST A LOT OF BLOOD...", $00

;;; 52000 - 52400
; open chest.
;
cf_open_chest:

    ; clear teleport flag, set urgent message flag.
    xor     a
    ld      (_var_cf + VAR_CF_U2), a
    ld      a, 1
    ld      (_var_cf + VAR_CF_O9), a
    
    ; every other time we open a chest, create a new one at a random location.
    ld      a, (_var_cf + VAR_CF_N4)
    xor     %00000001
    ld      (_var_cf + VAR_CF_N4), a
    jr      z, cf_open_chest_newone_end
    call    cf_find_random_empty_map_location
    ld      (hl), VAR_CF_C0_CONST + 1
.cf_open_chest_newone_end
    
    ; 83% chance of 1-50 gold coins, 17% chance of other.
    call    _xcs_get_random_number
    cp      212
    jr      nc, cf_open_chest_gold_end
    ld      a, 5
    call    cf_r
    ld      (_var_cf + VAR_CF_ZG), a
    ld      hl, cf_open_chest_you_found_string
    call    _game_strcpy
    ld      a, (_var_cf + VAR_CF_ZG)
    ld      e, a
    ld      d, $00
    ld      hl, (_var_cf + VAR_CF_GP)
    add     hl, de
    ld      (_var_cf + VAR_CF_GP), hl
    call    _game_numcat
    ld      hl, cf_open_chest_gold_coins_string
    call    _game_strcat
    ld      (_var_cf + VAR_CF_M), hl
    call    cf_print_message
    call    cf_update_gold
    ret
.cf_open_chest_gold_end

    ; other: 20% chance each of arrows, +N magic sword, magic shield, empty, trap.
    ld      a, 5
    call    cf_r
.cf_open_chest_arrow
    cp      1
    jr      nz, cf_open_chest_sword
    ld      a, 30
    call    cf_r
    add     a, 2
    ld      (_var_cf + VAR_CF_ZA), a
    ld      hl, cf_open_chest_you_found_string
    call    _game_strcpy
    ld      a, (_var_cf + VAR_CF_ZA)
    ld      e, a
    ld      d, $00
    call    _game_numcat
    ld      hl, cf_open_chest_arrows_string
    call    _game_strcat
    ld      (_var_cf + VAR_CF_M), hl
    call    cf_print_message
    ld      a, (_var_cf + VAR_CF_AR)
    ld      c, a
    ld      a, (_var_cf + VAR_CF_ZA)
    add     a, c
    cp      99 + 1
    jr      c, cf_open_chest_arrow_99
    ld      a, 99
.cf_open_chest_arrow_99
    ld      (_var_cf + VAR_CF_AR), a
    call    cf_update_arrows
    ret
.cf_open_chest_sword
    cp      2
    jr      nz, cf_open_chest_shield
    ld      a, 3
    call    cf_r
    ld      (_var_cf + VAR_CF_ZP), a
    ld      hl, cf_open_chest_you_found_a_string
    call    _game_strcpy
    ld      a, (_var_cf + VAR_CF_ZP)
    ld      e, a
    ld      d, $00
    call    _game_numcat
    ld      hl, cf_open_chest_magic_sword_string
    call    _game_strcat
    ld      (_var_cf + VAR_CF_M), hl
    call    cf_print_message
    ld      a, (_var_cf + VAR_CF_MS)
    ld      c, a
    ld      a, (_var_cf + VAR_CF_ZP)
    cp      c
    jr      c, cf_open_chest_sword_end
    ld      (_var_cf + VAR_CF_MS), a
    ld      a, (_var_cf + VAR_CF_DP)
    cp      3
    jr      z, cf_open_chest_sword_end
    ld      a, 10
    call    _game_vtab
    ld      a, 1
    call    _game_htab
    ld      hl, cf_open_chest_magic_sword_plus_string
    call    _game_strcpy
    ld      a, (_var_cf + VAR_CF_MS)
    ld      e, a
    ld      d, $00
    call    _game_numcat
    call    _game_print
.cf_open_chest_sword_end
    ret
.cf_open_chest_shield
    cp      3
    jr      nz, cf_open_chest_empty
    ld      a, 3
    call    cf_r
    ld      (_var_cf + VAR_CF_ZP), a
    ld      hl, cf_open_chest_you_found_a_string
    call    _game_strcpy
    ld      a, (_var_cf + VAR_CF_ZP)
    ld      e, a
    ld      d, $00
    call    _game_numcat
    ld      hl, cf_open_chest_magic_shield_string
    call    _game_strcat
    ld      (_var_cf + VAR_CF_M), hl
    call    cf_print_message
    ld      a, (_var_cf + VAR_CF_SH)
    ld      c, a
    ld      a, (_var_cf + VAR_CF_ZP)
    cp      c
    jr      c, cf_open_chest_shield_end
    ld      (_var_cf + VAR_CF_SH), a
    ld      a, (_var_cf + VAR_CF_DP)
    cp      3
    jr      z, cf_open_chest_shield_end
    ld      a, 11
    call    _game_vtab
    ld      a, 1
    call    _game_htab
    ld      hl, cf_open_chest_magic_shield_plus_string
    call    _game_strcpy
    ld      a, (_var_cf + VAR_CF_SH)
    ld      e, a
    ld      d, $00
    call    _game_numcat
    ld      (_var_cf + VAR_CF_M), hl
    call    _game_print
.cf_open_chest_shield_end
    ret
.cf_open_chest_empty
    cp      4
    jr      nz, cf_open_chest_teleport
    ld      hl, cf_open_chest_empty_string
    ld      (_var_cf + VAR_CF_M), hl
    call    cf_print_message
    ret
        
    ; clear the square we were on, then find a random empty square.
    ; play teleportation sound (27943=$6D27).
.cf_open_chest_teleport
    ld      de, (_var_cf + VAR_CF_CX)
    ld      hl, (_var_cf + VAR_CF_AX)
    add     hl, de
    ex      de, hl
    xor     a
    call    _game_set_ml
    ld      hl, cf_open_chest_teleport_string
    ld      (_var_cf + VAR_CF_M), hl
    call    cf_print_message
    call    cf_find_random_empty_map_location
    ld      de, (_var_cf + VAR_CF_ZX)
    ld      (_var_cf + VAR_CF_X), de
    ld      a, 1
    ld      (_var_cf + VAR_CF_U2), a
    ld      hl, (_var_cf + VAR_CF_ZL)
    ld      (hl), 2
    ld      a, 2
    call    _cfobj_play_indexed_tone
    ret

.cf_open_chest_you_found_string
    defb    "YOU FOUND ", $00
.cf_open_chest_gold_coins_string
    defb    " GOLD COINS.", $00
.cf_open_chest_arrows_string
    defb    " ARROWS.", $00
.cf_open_chest_you_found_a_string
    defb    "YOU FOUND A +", $00
.cf_open_chest_magic_sword_string
    defb    " MAGIC SWORD!", $00
.cf_open_chest_magic_sword_plus_string
    defb    "MAGIC SWORD +", $00
.cf_open_chest_magic_shield_string
    defb    " MAGIC SHEILD!", $00
.cf_open_chest_magic_shield_plus_string
    defb    "MAGIC SHEILD +", $00
.cf_open_chest_empty_string
    defb    "THE CHEST IS EMPTY!", $00
.cf_open_chest_teleport_string
    defb    "IT'S A TELEPORT TRAP!", $00

;;; 53000 - 53030
; moved onto Inn.
;
cf_move_onto_inn:
    
    ; if we're a Dragon Slayer, game won.
    ld      a, (_var_cf + VAR_CF_EL)
    cp      9
    jr      nz, cf_move_onto_inn_victory_end
    call    cf_victory
    ret
.cf_move_onto_inn_victory_end
        
    ; set prev tile = Inn.
    ld      a, VAR_CF_C0_CONST + 2
    ld      (_var_cf + VAR_CF_T0), a
    
    ; handle level-up.
    ld      a, (_var_cf + VAR_CF_EL)
    cp      8
    jr      nc, cf_move_onto_inn_levelup_end
    ld      hl, (_var_cf + VAR_CF_EP)
    ld      de, (_var_cf + VAR_CF_EN)
    or      a
    sbc     hl, de
    jr      c, cf_move_onto_inn_levelup_end
    ld      a, 1
    ld      (_var_cf + VAR_CF_O9), a
    ld      hl, (_var_cf + VAR_CF_BH)
    ld      de, 100
    add     hl, de
    ld      (_var_cf + VAR_CF_BH), hl
    ld      a, (_var_cf + VAR_CF_EL)
    inc     a
    ld      (_var_cf + VAR_CF_EL), a
    call    cf_update_experience_rank
    ld      hl, cf_move_onto_inn_levelup_string
    ld      (_var_cf + VAR_CF_M), hl
    call    cf_print_message
    ld      hl, (_var_cf + VAR_CF_EN)
    add     hl, hl
    ld      (_var_cf + VAR_CF_EN), hl
.cf_move_onto_inn_levelup_end

    ; restore hit points to max, reset health warning.
    ld      hl, (_var_cf + VAR_CF_BH)
    ld      (_var_cf + VAR_CF_HP), hl
    call    cf_update_hp
    xor     a
    ld      (_var_cf + VAR_CF_H4), a
    ld      hl, cf_move_onto_inn_buy_string
    ld      (_var_cf + VAR_CF_M), hl
    call    cf_print_message

    ret

.cf_move_onto_inn_levelup_string
    defb    "YOU WENT UP A LEVEL!", $00
.cf_move_onto_inn_buy_string
    defb    "HIT A TO BUY ARROWS, P FOR HIT POINTS.", $00

;;; 54000 - 54030
; touched a healer.
;
cf_touched_healer:

    ld      a, 150
    call    cf_r
    add     a, 25
    ld      e, a
    ld      d, $00
    ld      hl, (_var_cf + VAR_CF_BH)
    ld      bc, (_var_cf + VAR_CF_HP)
    or      a
    sbc     hl, bc
    or      a
    sbc     hl, de
    jr      nc, cf_touched_healer_calc
    add     hl, de
    ld      e, l
    ld      d, h
.cf_touched_healer_calc
    ld      (_var_cf + VAR_CF_ZD), de
    ld      hl, cf_touched_healer_regain_string
    call    _game_strcpy
    call    _game_numcat
    ld      hl, cf_touched_healer_hp_string
    call    _game_strcat
    ld      (_var_cf + VAR_CF_M), hl
    ld      a, 1
    ld      (_var_cf + VAR_CF_O9), a
    ld      a, 4
    call    _cfobj_play_indexed_tone
    call    cf_print_message
    ld      hl, (_var_cf + VAR_CF_HP)
    ld      de, (_var_cf + VAR_CF_ZD)
    add     hl, de
    ld      (_var_cf + VAR_CF_HP), hl
    call    cf_update_hp

    ; remove the healer, and replace it with a randomly-placed wizard.
    ld      hl, (_var_cf + VAR_CF_AX)
    ld      de, (_var_cf + VAR_CF_CX)
    ld      a, l
    add     a, e
    ld      e, a
    ld      a, h
    add     a, d
    ld      d, a
    ld      a, (_var_cf + VAR_CF_NM)
    call    _cfobj_find_monster_index
    ld      (_var_cf + VAR_CF_Z9), a
    ld      e, a
    ld      d, $00
    ld      hl, _var_cf_bt
    add     hl, de
    ld      (hl), 15
    push    de
    call    cf_find_random_empty_map_location
    pop     de
    ld      hl, _var_cf_bx
    add     hl, de
    ld      a, (_var_cf + VAR_CF_ZX)
    ld      (hl), a
    ld      hl, _var_cf_by
    add     hl, de
    ld      a, (_var_cf + VAR_CF_ZY)
    ld      (hl), a
    ld      hl, _var_cf_mh
    add     hl, de
    add     hl, de
    ld      bc, (_var_cf_hh + 15 * $0002)
    ld      (hl), c
    inc     hl
    ld      (hl), b
    ld      hl, (_var_cf + VAR_CF_ZL)
    ld      (hl), 15

    ret

.cf_touched_healer_regain_string
    defb    "YOU REGAIN ", $00
.cf_touched_healer_hp_string
    defb    " HIT POINTS.", $00


;;; 60000 - 60000
; victory.
;
cf_victory:

    ; 31232=$7A00, fireworks display.
    call    _game_home
    call    _game_text
    ld      a, 22
    call    _game_vtab
    ld      hl, cf_victory_slain_string
    call    _game_print
    ld      hl, cf_victory_press_string
    call    _game_print

    ; sb2
    call    _sb2

    ld      a, CF_STATE_VICTORY
    ld      (cf_state), a

    ret

.cf_victory_slain_string
    defb    "THOU HAST SLAIN THE DRAGON AND ESCAPED! ", $00
.cf_victory_press_string
    defb    "PRESS ANY KEY TO PLAY AGAIN...", $00

; 状態
;
cf_state:
    defs    $01
