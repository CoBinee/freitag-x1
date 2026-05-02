; title.asm - タイトル
;

; モジュールの宣言
;
    module  title


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
_title_entry:

    ; テキストのクリア
    ld      d, $20
    call    _xcs_clear_text_vram_0

    ; グラフィックのクリア
    ld      d, $00
    call    _xcs_clear_graphic_vram

    ; グラフィックを前面に設定
    call    _xcs_set_priority_front

    ; パレットの設定
    ld      bc, XCS_IO_PALETTE_BLUE
    ld      a, %10001010
    out     (c), a
    inc     b
    ld      a, %11001100
    out     (c), a
    inc     b
    ld      a, %11010000
    out     (c), a

    ; イメージの読み込み
    ld      de, title_image_filename
    call    _xcs_load_image

    ; キー入力待ち
.title_entry_loop
    call    _app_update
    ld      a, (_xcs_key_code_edge)
    or      a
    jr      z, title_entry_loop

    ; ゲームの開始
    jp      _game_entry

; イメージ
.title_image_filename
    defb    "title        gvr", $00

