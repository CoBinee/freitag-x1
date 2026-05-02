; app.asm - アプリケーション
;

; モジュールの宣言
;
    module  app


; ファイルの参照
;
    include "xcs.inc"
    include "app.inc"
    include "title.inc"
    include "game.inc"


; コードの定義
;
    section app

; プログラムのエントリポイント
;
    org     XCS_APP_START

app_entry:

    ; グラフィックを背面に設定
    call    _xcs_set_priority_back

    ; カウンタの初期化
    xor     a
    ld      (app_update_counter), a

    ; フォントの読み込み
    ld      de, app_font_filename
    ld      hl, APP_PTR_PCG
    call    _xcs_bload

    ; PCG の定義
    ld      de, APP_PTR_PCG
    call    _xcs_load_pcg

    ; サウンドの読み込み
    ld      de, app_song_filename
    ld      hl, APP_PTR_SONG
    call    _xcs_bload

    ; サウンドの定義
    ld      de, APP_PTR_SONG
    call    _xcs_load_sound

    ; アプリケーションの開始
    call    _app_update
    jp      _title_entry
;;  jp      _game_entry

; フォント
app_font_filename:
    defb    "font         pcg", $00

; サウンド
app_song_filename:
    defb    "song         snd", $00

; アプリケーションの更新
;
_app_update:

    ; 乱数の更新
    call    _xcs_get_random_number
    ld      (app_update_random), a

    ; カウンタの更新
    ld      a, (app_update_counter)
    add     a, $01
    daa
    cp      $60
    jr      c, app_update_count_store
    xor     a
.app_update_count_store
    ld      (app_update_counter), a

    ; カウンタの表示
;   ld      a, (app_update_counter)
    ld      de, $1800
;   call    _xcs_print_hex_chars

    ; デバッグの表示
    ld      hl, _app_debug
    ld      de, $1802
    ld      b, APP_DEBUG_SIZE
.app_update_print_debug
    ld      a, (hl)
;   call    _xcs_print_hex_chars
    inc     hl
    inc     e
    inc     e
    djnz    app_update_print_debug

    ; 垂直帰線期間の終了待ち
    call    _xcs_wait_v_dsip_off

    ; XCS の更新
    call    _xcs_update

    ; 終了
    ret

; 乱数
.app_update_random
    defs    $01


; カウンタ
;
.app_update_counter
    defs    $01

; デバッグ
;
_app_debug:
    defs    APP_DEBUG_SIZE

