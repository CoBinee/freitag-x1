; cfobj.inc - サブルーチン
;


; キーコマンド
;
    defc    CFOBJ_KEYVAL_NULL                           =   $00
    defc    CFOBJ_KEYVAL_MOVE                           =   $10
    defc    CFOBJ_KEYVAL_MOVE_UP                        =   $10
    defc    CFOBJ_KEYVAL_MOVE_DOWN                      =   $11
    defc    CFOBJ_KEYVAL_MOVE_LEFT                      =   $12
    defc    CFOBJ_KEYVAL_MOVE_RIGHT                     =   $13
    defc    CFOBJ_KEYVAL_MOVE_UP_LEFT                   =   $14
    defc    CFOBJ_KEYVAL_MOVE_UP_RIGHT                  =   $15
    defc    CFOBJ_KEYVAL_MOVE_DOWN_LEFT                 =   $16
    defc    CFOBJ_KEYVAL_MOVE_DOWN_RIGHT                =   $17
    defc    CFOBJ_KEYVAL_ATTACK                         =   $20
    defc    CFOBJ_KEYVAL_ATTACK_UP                      =   $20
    defc    CFOBJ_KEYVAL_ATTACK_DOWN                    =   $21
    defc    CFOBJ_KEYVAL_ATTACK_LEFT                    =   $22
    defc    CFOBJ_KEYVAL_ATTACK_RIGHT                   =   $23
    defc    CFOBJ_KEYVAL_ATTACK_UP_LEFT                 =   $24
    defc    CFOBJ_KEYVAL_ATTACK_UP_RIGHT                =   $25
    defc    CFOBJ_KEYVAL_ATTACK_DOWN_LEFT               =   $26
    defc    CFOBJ_KEYVAL_ATTACK_DOWN_RIGHT              =   $27
    defc    CFOBJ_KEYVAL_OTHER                          =   $40
    defc    CFOBJ_KEYVAL_PASS                           =   $40
    defc    CFOBJ_KEYVAL_TOGGLE_BIRD                    =   $41
    defc    CFOBJ_KEYVAL_TOGGLE_WEAPON                  =   $42
    defc    CFOBJ_KEYVAL_TOGGLE_MESSAGE                 =   $43
    defc    CFOBJ_KEYVAL_CENTER_SCREEN                  =   $44
    defc    CFOBJ_KEYVAL_BUY_HP                         =   $45
    defc    CFOBJ_KEYVAL_BUY_ARROWS                     =   $46
    defc    CFOBJ_KEYVAL_VIEW_HIRES                     =   $47
    defc    CFOBJ_KEYVAL_VIEW_TEXT                      =   $48
    defc    CFOBJ_KEYVAL_VIEW_MAP                       =   $49


; 関数の宣言
;
    extern  _cfobj_draw_hires
    extern  _cfobj_draw_minimap
    extern  _cfobj_draw_textmap
    extern  _cfobj_update_one_tile
    extern  _cfobj_wait_for_key
    extern  _cfobj_move_monsters
    extern  _cfobj_create_monsters
    extern  _cfobj_play_funeral
    extern  _cfobj_play_indexed_tone
    extern  _cfobj_play_indexed_dual_tone
    extern  _cfobj_find_monster_index


; 変数の宣言
;
