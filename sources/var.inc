; var.inc - 変数
;


; Basic の定数
;
    defc    VAR_CF_C0_CONST                             =   36      ; highest object number for monster.
    defc    VAR_CF_C2_CONST                             =   256     ; (never used)
    defc    VAR_CF_C9_CONST                             =   9       ; (never used)
    defc    VAR_CF_K9_CONST                             =   79 + 1  ; map width.
    defc    VAR_CF_MX_CONST                             =   79      ; max map X coordinate.
    defc    VAR_CF_MY_CONST                             =   79      ; max map Y coordinate.
    defc    VAR_CF_XL_CONST                             =   1       ; lowest AX value for local display (must scroll if lower).
    defc    VAR_CF_YL_CONST                             =   1       ; lowest AY value for local display (must scroll if lower).
    defc    VAR_CF_XR_CONST                             =   8       ; highest AX value for local display (must scroll if higher).
    defc    VAR_CF_YR_CONST                             =   7       ; highest AY value for local display (must scroll if higher).

; Basic の変数
;
    defc    VAR_CF_AR                                   =   $00     ; number of arrows.
    defc    VAR_CF_AX                                   =   $01     ; player position within window, X coord (0-9).
    defc    VAR_CF_AY                                   =   $02     ; player position within window, Y coord (0-8).
    defc    VAR_CF_BH                                   =   $03     ; base (max) hit points.
    defc    VAR_CF_BH_L                                 =   $03
    defc    VAR_CF_BH_H                                 =   $04
    defc    VAR_CF_CX                                   =   $05     ; window position X coord (left 0-70).
    defc    VAR_CF_CY                                   =   $06     ; window position Y coord (top 0-71).
    defc    VAR_CF_DP                                   =   $07     ; display mode: 0=hi-res, 1=text, 2=map.
    defc    VAR_CF_EL                                   =   $08     ; experience Level: 1-9.
    defc    VAR_CF_EN                                   =   $09     ; experience required for next level. doubles every time you level up.
    defc    VAR_CF_EN_L                                 =   $09
    defc    VAR_CF_EN_H                                 =   $0a
    defc    VAR_CF_EP                                   =   $0b     ; experience points.
    defc    VAR_CF_EP_L                                 =   $0b
    defc    VAR_CF_EP_H                                 =   $0c
    defc    VAR_CF_GP                                   =   $0d     ; gold pieces.
    defc    VAR_CF_GP_L                                 =   $0d
    defc    VAR_CF_GP_H                                 =   $0e
    defc    VAR_CF_H4                                   =   $0f     ; low health warning (0-2); used to avoid repeating "you're dying" messages.
    defc    VAR_CF_H9                                   =   $10     ; print message var.
    defc    VAR_CF_HP                                   =   $11     ; current hit points.
    defc    VAR_CF_HP_L                                 =   $11
    defc    VAR_CF_HP_H                                 =   $12
    defc    VAR_CF_HW                                   =   $13     ; current weapon: 1=sword, 2=bow.
    defc    VAR_CF_KL                                   =   $14     ; total kills (not used).
    defc    VAR_CF_M                                    =   $15     ; message to show.
    defc    VAR_CF_M_L                                  =   $15
    defc    VAR_CF_M_H                                  =   $16
    defc    VAR_CF_MS                                   =   $17     ; magic sword (1-3), value indicates bonus.
    defc    VAR_CF_MT                                   =   $18     ; attacked monster
    defc    VAR_CF_N4                                   =   $19     ; line 52005
    defc    VAR_CF_NM                                   =   $1a     ; number of active monsters (max 169).
    defc    VAR_CF_O9                                   =   $1b     ; bool: set for important messages (dying, teleported, etc) that should appear on hi-res screen even when messages are disabled.
    defc    VAR_CF_RR                                   =   $1c     ; run-away counter. you get (24 - SL%) steps, after which the speed wears off and enemies get a 4-move burst.
    defc    VAR_CF_S2                                   =   $1d     ; bool: set to 1 when stuck to a mimic.
    defc    VAR_CF_SH                                   =   $1e     ; magic shield (1-3), value indicates bonus.
    defc    VAR_CF_SL                                   =   $1f     ; skill level (1-9), selected by player.
    defc    VAR_CF_SM                                   =   $20     ; bool: Show Messages (when in hi-res mode).
    defc    VAR_CF_SX                                   =   $21     ; arrow x-coord
    defc    VAR_CF_SY                                   =   $22     ; arrow y-coord
    defc    VAR_CF_T0                                   =   $23     ; previous contents of square we're standing on; holds C0+2 if we're standing on the Inn, otherwise 0.
    defc    VAR_CF_TB                                   =   $24     ; TB is 32704 ($7FC0); 34048 is $8500
    defc    VAR_CF_TN                                   =   $25     ; total number of turns taken (not used).
    defc    VAR_CF_U2                                   =   $26     ; open chest; U2 is set to 1 if it's a teleport trap
    defc    VAR_CF_X                                    =   $27     ; player position, map X coordinate (CX+AX) (0-79).
    defc    VAR_CF_Y                                    =   $28     ; player position, map Y coordinate (CY+AY) (0-79).
    defc    VAR_CF_X1                                   =   $29     ; arrow x distance
    defc    VAR_CF_Y1                                   =   $2a     ; arrow y distance
    defc    VAR_CF_Z5                                   =   $2b     ; commonly-used temp variable.
    defc    VAR_CF_Z7                                   =   $2c     ; wizard coord.
    defc    VAR_CF_Z8                                   =   $2d     ; commonly-used temp variable.
    defc    VAR_CF_Z9                                   =   $2e     ; commonly-used temp variable.
    defc    VAR_CF_ZA                                   =   $2f     ; commonly-used temp variable.
    defc    VAR_CF_ZB                                   =   $30     ; commonly-used temp variable.
    defc    VAR_CF_ZC                                   =   $31     ; commonly-used temp variable.
    defc    VAR_CF_ZD                                   =   $32     ; commonly-used temp variable.
    defc    VAR_CF_ZD_L                                 =   $32
    defc    VAR_CF_ZD_H                                 =   $33
    defc    VAR_CF_ZE                                   =   $34     ; commonly-used temp variable.
    defc    VAR_CF_ZF                                   =   $35     ; commonly-used temp variable.
    defc    VAR_CF_ZG                                   =   $36     ; commonly-used temp variable.
    defc    VAR_CF_ZH                                   =   $37     ; commonly-used temp variable.
    defc    VAR_CF_ZJ                                   =   $38     ; commonly-used temp variable.
    defc    VAR_CF_ZL                                   =   $39     ; commonly-used temp variable.
    defc    VAR_CF_ZL_L                                 =   $39
    defc    VAR_CF_ZL_H                                 =   $3a
    defc    VAR_CF_ZP                                   =   $3b     ; commonly-used temp variable.
    defc    VAR_CF_ZQ                                   =   $3c     ; commonly-used temp variable.
    defc    VAR_CF_ZT                                   =   $3d     ; commonly-used temp variable.
    defc    VAR_CF_ZW                                   =   $3e     ; player icon index (18=sword, 16/17/19/20=bow, 25=bird).
    defc    VAR_CF_ZX                                   =   $3f     ; commonly-used temp variable.
    defc    VAR_CF_ZY                                   =   $40     ; commonly-used temp variable.
    defc    VAR_CF_ZZ                                   =   $41     ; commonly-used temp variable.
    defc    VAR_CF_SIZE                                 =   $42

; CF.OBJ の変数
;
    defc    VAR_CFOBJ_WIN_LEFT                          =   $00     ; $0300 CX
    defc    VAR_CFOBJ_WIN_TOP                           =   $01     ; $0301
    defc    VAR_CFOBJ_PLAYER_WIN_X                      =   $02     ; $0302 position within window (AX) (0-9)
    defc    VAR_CFOBJ_PLAYER_WIN_Y                      =   $03     ; $0303 position within window (AY) (0-8)
    defc    VAR_CFOBJ_DISPLAY_MODE                      =   $04     ; $0304
    defc    VAR_CFOBJ_MONSTER_MAP_X                     =   $05     ; $0305
    defc    VAR_CFOBJ_MONSTER_MAP_Y                     =   $06     ; $0306
    defc    VAR_CFOBJ_TURN_TIMER                        =   $07     ; $0307
    defc    VAR_CFOBJ_KEYVAL_OR_ATK                     =   $08     ; $0308 key hit -or- monster attack flag
    defc    VAR_CFOBJ_PLAYER_MAP_X                      =   $09     ; $0309 (0-79)
    defc    VAR_CFOBJ_PLAYER_MAP_Y                      =   $0a     ; $030a (0-79)
    defc    VAR_CFOBJ_MONSTER_MOVE_X                    =   $0b     ; $030b
    defc    VAR_CFOBJ_MONSTER_MOVE_Y                    =   $0c     ; $030c
    defc    VAR_CFOBJ_MONSTER_COUNT                     =   $0d     ; $030d
    defc    VAR_CFOBJ_MON_ATTACK_COUNT                  =   $0e     ; $030e number of monsters that attacked player (0-4)
    defc    VAR_CFOBJ_MON_ATTACK_ID0                    =   $0f     ; $030f
    defc    VAR_CFOBJ_MON_ATTACK_ID1                    =   $10     ; $0310
    defc    VAR_CFOBJ_MON_ATTACK_ID2                    =   $11     ; $0311
    defc    VAR_CFOBJ_MON_ATTACK_ID3                    =   $12     ; $0312
    defc    VAR_CFOBJ_SOUND_PITCH                       =   $13     ; $0313 {addr/2}
    defc    VAR_CFOBJ_SOUND_DURATION                    =   $15     ; $0315 {addr/2}
    defc    VAR_CFOBJ_SOUND_PITCH_ADJ                   =   $17     ; $0317 {addr/2}
    defc    VAR_CFOBJ_TURN_SPEED                        =   $19     ; $0319 speed - 1 (0-49)
    defc    VAR_CFOBJ_SKILL_LEVEL_PLUS_4                =   $1a     ; $031a skill level + 4 (5-13)
    defc    VAR_CFOBJ_ATK_WIZ1_X                        =   $1b     ; $031b window X coord of 1st attacking wizard
    defc    VAR_CFOBJ_ATK_WIZ1_Y                        =   $1c     ; $031c window Y coord of 1st attacking wizard
    defc    VAR_CFOBJ_ATK_WIZ2_X                        =   $1d     ; $031d window X coord of 2nd attacking wizard
    defc    VAR_CFOBJ_ATK_WIZ2_Y                        =   $1e     ; $031e window Y coord of 2nd attacking wizard
    defc    VAR_CFOBJ_HIT_BY_FLAME                      =   $1f     ; $031f
    defc    VAR_CFOBJ_DRAGON_BREATH_READY               =   $20     ; $0320 zero when dragon ready to breathe
    defc    VAR_CFOBJ_COL_COUNTER                       =   $23     ; $0323 {addr/1}
    defc    VAR_CFOBJ_ROW_COUNTER                       =   $24     ; $0324
    defc    VAR_CFOBJ_MAP_ROW_ADDR                      =   $25     ; $0325 {addr/2}
    defc    VAR_CFOBJ_ROW_TMP                           =   $27     ; $0327 {addr/2}
    defc    VAR_CFOBJ_COL_TMP                           =   $28     ; $0328
    defc    VAR_CFOBJ_PLAYER_XC                         =   $29     ; $0329
    defc    VAR_CFOBJ_PLAYER_YC                         =   $2a     ; $032a
    defc    VAR_CFOBJ_MONSTER_MOVE_TMP                  =   $2b     ; $032b
    defc    VAR_CFOBJ_MON_TAXICAB_DIST                  =   $2d     ; $032d
    defc    VAR_CFOBJ_TONE_WALK                         =   $2e
    defc    VAR_CFOBJ_SIZE                              =   $2f

; 0 ページの変数
    defc    VAR_ARG_DIST                                =   $00     ; $19          LINESET distance
    defc    VAR_ARG_RADIUS                              =   $01     ; $1b          CIRCLE radius
    defc    VAR_ARG_DRAW_MODE                           =   $02     ; $1c          0=draw, 1=erase, 2=invert
    defc    VAR_ARG_ANGLE                               =   $03     ; $1d          LINESET angle arg
    defc    VAR_ARG_ITEM_INDEX                          =   $04     ; $1e          LINESET/CHARSET item index
    defc    VAR_ARG_COLOR                               =   $05     ; $1f          0=green, 1=orange, 2=purple, 3=blue
    defc    VAR_ARG_MON_RNDL                            =   $06     ; $4e          low byte of KEYIN "random" value
    defc    VAR_ARG_BAS_FAC                             =   $07     ; $9d {addr/6} floating point accumulator (6b)
    defc    VAR_ARG_BAS_FAC_0                           =   $07
    defc    VAR_ARG_BAS_FAC_1                           =   $08
    defc    VAR_ARG_BAS_FAC_2                           =   $09
    defc    VAR_ARG_BAS_FAC_3                           =   $0a
    defc    VAR_ARG_BAS_FAC_4                           =   $0b
    defc    VAR_ARG_BAS_FAC_5                           =   $0c
    defc    VAR_ARG_BAS_TXTPTR                          =   $0d     ; $b8 {addr/2} points at next char or token (2b)
    defc    VAR_ARG_BAS_TXTPTR_L                        =   $0d
    defc    VAR_ARG_BAS_TXTPTR_H                        =   $0e
    defc    VAR_ARG_EXT_PTR                             =   $0f     ; $e8 {addr/2} pointer to external data
    defc    VAR_ARG_EXT_PTR_L                           =   $0f
    defc    VAR_ARG_EXT_PTR_H                           =   $10
    defc    VAR_ARG_X0                                  =   $11     ; $f9 {addr/2} X coord #0 (0-255 or 0-139)
    defc    VAR_ARG_Y0                                  =   $12     ; $fb          Y coord #0 (0-191)
    defc    VAR_ARG_X1                                  =   $13     ; $fc {addr/2} X coord #1 (0-255 or 0-139)
    defc    VAR_ARG_Y1                                  =   $14     ; $fe          Y coord #1 (0-191)
    defc    VAR_ARG_FF                                  =   $15     ; $ff          shape fill flag -or- CLR color
    defc    VAR_ARG_SIZE                                =   $16

; SB2 の変数
;
    defc    VAR_SB2_CENTER_X                            =   $00     ; $035c
    defc    VAR_SB2_CENTER_Y                            =   $01     ; $035d
    defc    VAR_SB2_SAVED_XREG                          =   $02     ; $035e
    defc    VAR_SB2_PARTICLE_INDEX                      =   $03     ; $035f
    defc    VAR_SB2_COUNTER_24BIT                       =   $04     ; $0360  {addr/3}
    defc    VAR_SB2_COUNTER_24BIT_0                     =   $04
    defc    VAR_SB2_COUNTER_24BIT_1                     =   $05
    defc    VAR_SB2_COUNTER_24BIT_2                     =   $06
    defc    VAR_SB2_UPDATE_CADENCE                      =   $07     ; $0363  {addr/5}
    defc    VAR_SB2_UPDATE_CADENCE_0                    =   $07
    defc    VAR_SB2_UPDATE_CADENCE_1                    =   $08
    defc    VAR_SB2_UPDATE_CADENCE_2                    =   $09
    defc    VAR_SB2_UPDATE_CADENCE_3                    =   $0a
    defc    VAR_SB2_UPDATE_CADENCE_4                    =   $0b
    defc    VAR_SB2_MAX_PARTICLE_COUNT                  =   $0c     ; $0368
    defc    VAR_SB2_NEXT_PARTICLE_INDEX                 =   $0d     ; $0369  {addr/5}
    defc    VAR_SB2_NEXT_PARTICLE_INDEX_0               =   $0d
    defc    VAR_SB2_NEXT_PARTICLE_INDEX_1               =   $0e
    defc    VAR_SB2_NEXT_PARTICLE_INDEX_2               =   $0f
    defc    VAR_SB2_NEXT_PARTICLE_INDEX_3               =   $10
    defc    VAR_SB2_NEXT_PARTICLE_INDEX_4               =   $11
    defc    VAR_SB2_NEXT_EXPLOSION_CTR                  =   $12     ; $036e
    defc    VAR_SB2_ALWAYS_ONE                          =   $13     ; $036f
    defc    VAR_SB2_CUR_DELTA_X                         =   $14
    defc    VAR_SB2_CUR_DELTA_Y                         =   $15
    defc    VAR_SB2_NEXT_COLOR                          =   $16     ; (0-3)
    defc    VAR_SB2_NINE_COUNT                          =   $17     ; 0-9
    defc    VAR_SB2_PTR_X0                              =   $18
    defc    VAR_SB2_PTR_X0_L                            =   $18
    defc    VAR_SB2_PTR_X0_H                            =   $19
    defc    VAR_SB2_PTR_Y0                              =   $1a
    defc    VAR_SB2_PTR_Y0_L                            =   $1a
    defc    VAR_SB2_PTR_Y0_H                            =   $1b
    defc    VAR_SB2_PTR_DELTAX                          =   $1c
    defc    VAR_SB2_PTR_DELTAX_L                        =   $1c
    defc    VAR_SB2_PTR_DELTAX_H                        =   $1d
    defc    VAR_SB2_PTR_DELTAY                          =   $1e
    defc    VAR_SB2_PTR_DELTAY_L                        =   $1e
    defc    VAR_SB2_PTR_DELTAY_H                        =   $1f
    defc    VAR_SB2_STATE_PTR48                         =   $20
    defc    VAR_SB2_STATE_PTR48_L                       =   $20
    defc    VAR_SB2_STATE_PTR48_H                       =   $21
    defc    VAR_SB2_PTR_COLOR                           =   $22
    defc    VAR_SB2_PTR_COLOR_L                         =   $22
    defc    VAR_SB2_PTR_COLOR_H                         =   $23
    defc    VAR_SB2_VELOCITY                            =   $24
    defc    VAR_SB2_I_24                                =   $25
    defc    VAR_SB2_SIZE                                =   $26


; 関数の宣言
;
    extern  _var_initialize


; 変数の宣言
;

    ; Basic の定数
    extern  _var_cf_aa
    extern  _var_cf_hh
    extern  _var_cf_mm
    extern  _var_cf_rn

    ; Basic の変数
    extern  _var_cf

    ; Basic の配列
    extern  _var_cf_bx
    extern  _var_cf_by
    extern  _var_cf_bt
    extern  _var_cf_mh
    extern  _var_cf_nn

    ; CF.OBJ の変数
    extern  _var_cfobj

    ; CF.OBJ の配列
    extern  _var_cfobj_mon_attack_id

    ; 0 ページの変数
    extern  _var_arg

    ; SB2 の定数
    extern  _var_sb2_max_particle_counts
    extern  _var_sb2_move_cadences
    extern  _var_sb2_addr0
    extern  _var_sb2_addr1
    extern  _var_sb2_addr2
    extern  _var_sb2_addr3
    extern  _var_sb2_addr4
    extern  _var_sb2_addr5
    extern  _var_sb2_delta_x_24
    extern  _var_sb2_delta_y_24
    extern  _var_sb2_setindex_24
    extern  _var_sb2_delta_x_tab
    extern  _var_sb2_delta_y_tab

    ; SB2 の変数
    extern  _var_sb2

