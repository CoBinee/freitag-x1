; app.inc - アプリケーション
;


; メモリマップ
;
    defc    APP_PTR_SONG                                =   $8100   ; + $1000
    defc    APP_PTR_STORAGE                             =   $9100   ; + $0a00
    defc    APP_PTR_ML                                  =   $9b00   ; + $1900
    defc    APP_PTR_LBOLT                               =   $b400   ; + $0c00
    defc    APP_PTR_BADBREATH                           =   $c000   ; + $0600
    defc    APP_PTR_CFMISC                              =   $c600   ; + $0400
    defc    APP_PTR_SKETCHZ                             =   $ca00   ; + $3600
    defc    APP_PTR_PCG                                 =   $e800   ; + $1800 / 最初のみ

; デバッグ
;
    defc    APP_DEBUG_SIZE                              =   $08


; 関数の宣言
;
    extern  _app_update


; 変数の宣言
;
    extern  _app_debug
