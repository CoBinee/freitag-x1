; var.asm - 変数
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


; コードの定義
;
    section app

; 変数を初期化する
;
_var_initialize:

    ; 変数を 0 クリアする
    ld      hl, var_head + $0000
    ld      de, var_head + $0001
    ld      bc, var_tail - var_head - $0001
    ld      (hl), $00
    ldir

    ; 終了
    ret

; 定数
;

; monster attack damage (actual is (random 1-N) * 0.7)
_var_cf_aa:
    defb      0,   0,   0,  20,  15,  30,  45, 100,  70,  20
    defb    150,   8, 150, 200,   1,  20,   0,   0,   0,   0
    defb      0,   0,   0,   0,   0,   0,   0,   0,   0,   0
    defb      0,   0,   0,   0,   0, 120,   0,   0,   0,   0

; monster hit points (also experience points).
_var_cf_hh:
    defw        0,     0,     0,    30,    15,    50,    75, 150, 100,  20
    defw        5,   300,   200,    88,     1,    65,     0,   0,   0,   0
    defw        0,     0,     0,     0,     0,     0,     0,   0,   0,   0
    defw        0,     0,     0,     0,     0, 10000,     0,   0,   0,   0

; monster names.
_var_cf_mm:
    defs    $10, ""
    defs    $10, ""
    defs    $10, ""
    defs    $10, "SERPENT"
    defs    $10, "ELECTRIC MOTH"
    defs    $10, "MAD ROBOT"
    defs    $10, "BURBLEBLORT"
    defs    $10, "GRIFFIN"
    defs    $10, "FLAMEBAT"
    defs    $10, "INVISOID"
    defs    $10, "THUNDERBUG"
    defs    $10, "COLDCRYSTAL"
    defs    $10, "PHOENIX"
    defs    $10, "MIMIC"
    defs    $10, "HEALER"
    defs    $10, "WIZARD"
    defs    $10, ""
    defs    $10, ""
    defs    $10, ""
    defs    $10, ""
    defs    $10, ""
    defs    $10, ""
    defs    $10, ""
    defs    $10, ""
    defs    $10, ""
    defs    $10, ""
    defs    $10, ""
    defs    $10, ""
    defs    $10, ""
    defs    $10, ""
    defs    $10, "DWAGON"
    defs    $10, "DWAGON"
    defs    $10, "DWAGON"
    defs    $10, "DWAGON"
    defs    $10, "DWAGON"
    defs    $10, "DWAGON"
    defs    $10, ""
    defs    $10, ""
    defs    $10, ""
    defs    $10, ""

; rank names, displayed on the text screen Cannon Fodder, Stable Boy, etc.
_var_cf_rn:
    defs    $10, ""
    defs    $10, "CANNON FODDER"
    defs    $10, "STABLE BOY"
    defs    $10, "NOVICE"
    defs    $10, "ADVENTURER"
    defs    $10, "SWORDSMAN"
    defs    $10, "VETERAN"
    defs    $10, "MIGHTY WARRIOR"
    defs    $10, "LORD       "
    defs    $10, "DRAGON SLAYER"

; max particle
_var_sb2_max_particle_counts:
    defb    $1e, $1e, $1e, $1e, $3c

; every M iterations we move the particles in set N (0-4).
; this determines how often they move.
_var_sb2_move_cadences:
    defb    $05, $07, $0a, $0b, $0e 

; five sets of 6 addresses, all pointing into $9xxx.
; these hold x0, y0, deltaX, deltaY, color, and something that isn't used.
; each address is +62 or +124 bytes from the previous, suggesting 5 sets with up to 62 particles per set.
_var_sb2_addr0:
    defw    $9000 - $9000 + APP_PTR_STORAGE
    defw    $9174 - $9000 + APP_PTR_STORAGE
    defw    $92e8 - $9000 + APP_PTR_STORAGE
    defw    $945c - $9000 + APP_PTR_STORAGE
    defw    $95d0 - $9000 + APP_PTR_STORAGE
_var_sb2_addr1:
    defw    $903e - $9000 + APP_PTR_STORAGE
    defw    $91b2 - $9000 + APP_PTR_STORAGE
    defw    $9326 - $9000 + APP_PTR_STORAGE
    defw    $949a - $9000 + APP_PTR_STORAGE
    defw    $964c - $9000 + APP_PTR_STORAGE
_var_sb2_addr2:
    defw    $907c - $9000 + APP_PTR_STORAGE
    defw    $91f0 - $9000 + APP_PTR_STORAGE
    defw    $9364 - $9000 + APP_PTR_STORAGE
    defw    $94d8 - $9000 + APP_PTR_STORAGE
    defw    $96c8 - $9000 + APP_PTR_STORAGE
_var_sb2_addr3:
    defw    $90ba - $9000 + APP_PTR_STORAGE
    defw    $922e - $9000 + APP_PTR_STORAGE
    defw    $93a2 - $9000 + APP_PTR_STORAGE
    defw    $9516 - $9000 + APP_PTR_STORAGE
    defw    $9744 - $9000 + APP_PTR_STORAGE
_var_sb2_addr4:
    defw    $90f8 - $9000 + APP_PTR_STORAGE
    defw    $926c - $9000 + APP_PTR_STORAGE
    defw    $93e0 - $9000 + APP_PTR_STORAGE
    defw    $9554 - $9000 + APP_PTR_STORAGE
    defw    $97c0 - $9000 + APP_PTR_STORAGE
_var_sb2_addr5:
    defw    $9136 - $9000 + APP_PTR_STORAGE
    defw    $92aa - $9000 + APP_PTR_STORAGE
    defw    $941e - $9000 + APP_PTR_STORAGE
    defw    $9592 - $9000 + APP_PTR_STORAGE
    defw    $983c - $9000 + APP_PTR_STORAGE
_var_sb2_delta_x_24:
    defb    -2, -1,  0,  1,  2, -2, -1,  0
    defb     1,  2, -2, -1,  1,  2, -2, -1
    defb     0,  1,  2, -2, -1,  0,  1,  2
_var_sb2_delta_y_24:
    defb    -2, -2, -2, -2, -2, -1, -1, -1
    defb    -1, -1,  0,  0,  0,  0,  1,  1
    defb     1,  1,  1,  2,  2,  2,  2,  2
_var_sb2_setindex_24:
    defb    $03, $04, $02, $04, $03, $04, $01, $00
    defb    $01, $04, $02, $00, $00, $02, $04, $01
    defb    $00, $01, $04, $03, $04, $02, $04, $03

; this yields 9 dots in a diamond pattern:
;     *
;   *   *
; *   *   *
;   *   *
;     *
_var_sb2_delta_x_tab:
    defb     0, -1,  1, -2,  0,  2, -1,  1,  0
_var_sb2_delta_y_tab:
    defb    -2, -1, -1,  0,  0,  0,  1,  1,  2


; 変数領域の開始
;
var_head:

; Basic の変数
;
_var_cf:
    defs    VAR_CF_SIZE

; Basic の配列
;

; monster data ptr: X coordinate (170 bytes).
_var_cf_bx:
    defs    170

; monster data ptr: Y coordinate (170 bytes).
_var_cf_by:
    defs    170

; mmonster data ptr: type (170 bytes).
_var_cf_bt:
    defs    170

; monster hit points (170 * 2 bytes).
_var_cf_mh:
    defs    170 * 2

; player's character name (16 chars max).
_var_cf_nn:
    defs    17

; CF.OBJ の変数
;
_var_cfobj:
    defs    VAR_CFOBJ_SIZE

; CF.OBJ の配列
;

; $030f - $0316
_var_cfobj_mon_attack_id:
    defs    $08

; 0 ページの変数
;
_var_arg:
    defs    VAR_ARG_SIZE

; SB2 の変数
;
_var_sb2:
    defs    VAR_SB2_SIZE

; 変数領域の終端
;
var_tail:


