; cf.inc - メインルーチン
;


; 状態
;
    defc    CF_STATE_PLAY                               =   $00
    defc    CF_STATE_OVER                               =   $ff
    defc    CF_STATE_VICTORY                            =   $01


; 関数の宣言
;
    extern  _cf_setup


; 変数の宣言
;
