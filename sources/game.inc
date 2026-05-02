; game.inc - ゲーム
;


; ディスプレイモード
;
    defc    GAME_DISPLAY_TEXT                           =   0
    defc    GAME_DISPLAY_MIX                            =   1
    defc    GAME_DISPLAY_HIRES                          =   2

; テキスト
;
    defc    GAME_TEXT_SIZE_X                            =   40
    defc    GAME_TEXT_SIZE_Y                            =   25
    defc    GAME_TEXT_FONT_NORMAL                       =   $00
    defc    GAME_TEXT_FONT_INVERSE                      =   $80
    defc    GAME_TEXT_SCROLL_TOP                        =   11

; 入力
;
    defc    GAME_INPUT_LENGTH                           =   16

; 文字列
;
    defc    GAME_STRING_LENGTH                          =   64

; 待機
;
    defc    GAME_WAIT_MESSAGE                           =   30
    defc    GAME_WAIT_ARROW                             =   2
    defc    GAME_WAIT_HIT                               =   10
    defc    GAME_WAIT_POOF                              =   15
    defc    GAME_WAIT_LBOLT                             =   30
    defc    GAME_WAIT_BREATH                            =   30
    defc    GAME_WAIT_DRAGON                            =   45


; 関数の宣言
;
    extern  _game_entry
    extern  _game_set_display
    extern  _game_text
    extern  _game_mix
    extern  _game_hires
    extern  _game_home
    extern  _game_normal
    extern  _game_inverse
    extern  _game_spc
    extern  _game_htab
    extern  _game_vtab
    extern  _game_putchar
    extern  _game_backspace
    extern  _game_linebreak
    extern  _game_print_without_linebreak
    extern  _game_print
    extern  _game_input
    extern  _game_copy_input_buffer
    extern  _game_inkey
    extern  _game_strcpy
    extern  _game_numcpy
    extern  _game_strcat
    extern  _game_numcat
    extern  _game_calc_ml
    extern  _game_get_ml
    extern  _game_set_ml
    extern  _game_draw_ml_tile
    extern  _game_invert_ml_tile
    extern  _game_draw_tile_on_ml
    extern  _game_draw_misc
    extern  _game_erase_misc
    extern  _game_draw_lbolt
    extern  _game_erase_lbolt
    extern  _game_draw_breath
    extern  _game_erase_breath
    extern  _game_draw_dot
    extern  _game_wait


; 変数の宣言
;

