; game.asm - ゲーム
;

; モジュールの宣言
;
    module  game


; ファイルの参照
;
    include "xcs.inc"
    include "app.inc"
    include "title.inc"
    include "game.inc"
    include "var.inc"
    include "cf.inc"


; コードの定義
;
    section app

; プログラムのエントリポイント
;
_game_entry:

    ; タイルセットの読み込み
    ld      de, game_entry_sketchz_filename
    ld      hl, APP_PTR_SKETCHZ
    call    _xcs_bload
    ld      de, game_entry_cfmisc_filename
    ld      hl, APP_PTR_CFMISC
    call    _xcs_bload
    ld      de, game_entry_lbolt_filename
    ld      hl, APP_PTR_LBOLT
    call    _xcs_bload
    ld      de, game_entry_badbreath_filename
    ld      hl, APP_PTR_BADBREATH
    call    _xcs_bload

;   ; テキストのクリア
;   ld      d, $20
;   call    _xcs_clear_text_vram_0

;   ; グラフィックのクリア
;   ld      d, $00
;   call    _xcs_clear_graphic_vram

    ; ディスプレイモードの初期化
    xor     a
    ld      (game_display), a

    ; テキストの初期化
    xor     a
    ld      (game_text_htab), a
    ld      (game_text_vtab), a
    ld      (game_text_font), a

    ; CF の開始
.game_entry_loop
    call    _cf_setup

    ; タイトルの開始
    jp      _title_entry

; タイルセット
.game_entry_sketchz_filename
    defb    "sketchz      ts ", $00
.game_entry_cfmisc_filename
    defb    "cfmisc       ts ", $00
.game_entry_lbolt_filename
    defb    "lbolt        ts ", $00
.game_entry_badbreath_filename
    defb    "badbreath    ts ", $00

; ディスプレイモードを設定する
;
_game_set_display:

    ; IN
    ;   a = ディスプレイモード

    ; ディスプレイモードの保存
    ld  (game_display), a
    cp      GAME_DISPLAY_TEXT
    jr      z, game_set_display_text

    ; グラフィックの設定
    call    _xcs_set_priority_front
    ld      bc, XCS_IO_PALETTE_BLUE
    ld      a, %10001010
    out     (c), a
    inc     b
    ld      a, %11001100
    out     (c), a
    inc     b
    ld      a, %11010000
    out     (c), a
    jr      game_set_display_end

    ; テキストの設定
.game_set_display_text
    call    _xcs_set_priority_back
    ld      bc, XCS_IO_PALETTE_BLUE
    xor     a
    out     (c), a
    inc     b
    out     (c), a
    inc     b
    out     (c), a

    ; 終了
.game_set_display_end
    ret

; テキストモードに設定する
;
_game_text:

    ;  ディスプレイモードの設定
    ld      a, GAME_DISPLAY_TEXT
    call    _game_set_display

    ; 終了
    ret

; ミックスモードに設定する
;
_game_mix:

    ;  ディスプレイモードの設定
    ld      a, GAME_DISPLAY_MIX
    call    _game_set_display

    ; 終了
    ret

; ハイレゾモードに設定する
;
_game_hires:

    ;  ディスプレイモードの設定
    ld      a, GAME_DISPLAY_HIRES
    call    _game_set_display

    ; 終了
    ret

; テキスト画面をクリアする
;
_game_home:

    ; レジスタの保存
    push    bc
    push    de

    ; テキスト画面のクリア
    ld      d, ' '
    call    _xcs_clear_text_vram_0

    ; カーソル位置の設定
    xor     a
    ld      (game_text_htab), a
    ld      (game_text_vtab), a

    ; レジスタの復帰
    pop     de
    pop     bc

    ; 終了
    ret

; 通常のフォントを設定する
;
_game_normal:

    ; フォントの設定
    xor     a
    ld      (game_text_font), a

    ; 終了
    ret

; 反転のフォントを設定する
;
_game_inverse:

    ; フォントの設定
    ld      a, GAME_TEXT_FONT_INVERSE
    ld      (game_text_font), a

    ; 終了
    ret

; 指定された長さの空白を出力する
;
_game_spc:

    ; IN
    ;   a = 空白の長さ

    ; 空白の出力
    push    bc
    ld      b, a
.game_spc_loop:
    ld      a, ' '
    call    _game_putchar
    djnz    game_spc_loop
    pop     bc

    ; 終了
    ret

; テキストの X 位置を設定する
;
_game_htab:

    ; IN
    ;   a = X 位置（1..40）

    ; カーソル位置の設定
    dec     a
    ld      (game_text_htab), a

    ; 終了
    ret

; テキストの Y 位置を設定する
;
_game_vtab:

    ; IN
    ;   a = X 位置（1..25）

    ; カーソル位置の設定
    dec     a
    ld      (game_text_vtab), a

    ; 終了
    ret

; テキストに 1 文字出力する
;
_game_putchar:

    ; IN
    ;   a = 文字

    ; レジスタの保存
    push    hl
    push    bc
    push    de

    ; 文字の出力
    push    af
    ld      de, (game_text_htab)
    call    _xcs_calc_text_vram_0
    pop     af
    ld      hl, game_text_font
    add     a, (hl)
    out     (c), a

    ; 位置の更新
    inc     e
    ld      a, e
    ld      (game_text_htab), a
    cp      GAME_TEXT_SIZE_X
    call    nc, _game_linebreak

    ; レジスタの復帰
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

; テキストを 1 文字戻す
;
_game_backspace:

    ; レジスタの保存
    push    bc
    push    de

    ; 空白の出力
    ld      de, (game_text_htab)
    call    _xcs_calc_text_vram_0
    ld      a, ' '
    out     (c), a

    ; 位置の更新
    dec     e
    ld      a, e
    ld      (game_text_htab), a

    ; レジスタの復帰
    pop     de
    pop     bc

    ; 終了
    ret

; テキストを改行する
;
_game_linebreak:

    ; レジスタの保存
    push    bc
    push    de

    ; 位置の更新
    xor     a
    ld      (game_text_htab), a
    ld      a, (game_text_vtab)
    cp      GAME_TEXT_SIZE_Y - $01
    jr      nc, game_linebreak_scrollup
    inc     a
    ld      (game_text_vtab), a
    jr      game_linebreak_end

    ; スクロールアップ
.game_linebreak_scrollup
    ld      de, ((GAME_TEXT_SCROLL_TOP + $01) << 8) | $00
    call    _xcs_calc_text_vram_0
    exx
    ld      de, ((GAME_TEXT_SCROLL_TOP + $00) << 8) | $00
    call    _xcs_calc_text_vram_0
    ld      de, (GAME_TEXT_SIZE_Y - GAME_TEXT_SCROLL_TOP - $01) * GAME_TEXT_SIZE_X
.game_linebreak_scrollup_loop
    exx
    in      a, (c)
    inc     bc
    exx
    out     (c), a
    inc     bc
    dec     de
    ld      a, d
    or      e
    jr      nz, game_linebreak_scrollup_loop

    ; 最下行のクリア
    ld      a, ' '
    ld      e, GAME_TEXT_SIZE_X
.game_linebreak_blank_loop
    out     (c), a
    inc     bc
    dec     e
    jr      nz, game_linebreak_blank_loop
    exx

    ; レジスタの復帰
.game_linebreak_end
    pop     de
    pop     bc

    ; 終了
    ret

; 改行なしで文字列を出力する
;
_game_print_without_linebreak:

    ; IN
    ;   hl = 文字列

    ; レジスタの保存
    push    hl
    push    bc
    push    de

    ; 文字列の出力
    ld      de, (game_text_htab)
    call    _xcs_calc_text_vram_0
.game_print_start
    ld      de, (game_text_htab)
.game_print_loop
    ld      a, (hl)
    or      a
    jr      z, game_print_done
    ld      a, (game_text_font)
    add     a, (hl)
    out     (c), a
    inc     hl
    inc     bc
    inc     e
    ld      a, e
    cp      GAME_TEXT_SIZE_X
    jr      c, game_print_loop
    call    _game_linebreak
    jr      game_print_start

    ; 出力の完了
.game_print_done
    ld      (game_text_htab), de

    ; レジスタの復帰
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

; 改行ありで文字列を出力する
;
_game_print:

    ; IN
    ;   hl = 文字列

    ; 文字列の出力
    call    _game_print_without_linebreak
    call    _game_linebreak

    ; 終了
    ret

; 文字列を入力する
;
_game_input:

    ; IN
    ;   hl = 出力する文字列
    ;   e  = 入力可能な最小の文字
    ;   d  = 入力可能な最大の文字 + 1
    ; OUT
    ;   hl = 入力された文字列（game_input_buffer）

    ; レジスタの保存
    push    bc
    push    de

    ; 文字列の出力
    call    _game_print_without_linebreak

    ; 入力バッファの初期化
    ld      hl, game_input_buffer
    ld      (hl), $00

    ; カーソルの表示
    call    game_print_cursor

    ; 文字列の入力
    ld      b, $00
.game_input_loop:

    ; アプリケーションの更新
    push    hl
    push    bc
    push    de
    call    _app_update
    pop     de
    pop     bc
    pop     hl

    ; キー入力
    ld      a, (_xcs_key_code_edge)
    cp      $0d
    jr      z, game_input_done
    cp      $08
    jr      z, game_input_backspace
    cp      e
    jr      c, game_input_loop
    cp      d
    jr      nc, game_input_loop
    ld      c, a
    ld      a, b
    cp      GAME_INPUT_LENGTH
    jr      nc, game_input_loop
    ld      (hl), c
    inc     hl
    ld      (hl), $00
    inc     b
    ld      a, c
    call    _game_putchar
    call    game_print_cursor
    jr      game_input_loop

    ; 1 文字の削除
.game_input_backspace
    ld      a, b
    or      a
    jr      z, game_input_loop
    ld      (hl), $00
    dec     hl
    dec     b
    call    game_erase_cursor
    call    _game_backspace
    call    game_print_cursor
    jr      game_input_loop

    ; 入力の完了
.game_input_done
    call    game_erase_cursor
    ld      hl, game_input_buffer

    ; レジスタの復帰
    pop     de
    pop     bc

    ; 終了
    ret

; 入力された文字列をコピーする
;
_game_copy_input_buffer:

    ; IN
    ;   hl = コピー先

    ; レジスタの保存
    push    hl
    push    de

    ; 文字列のコピー
    ld      de, game_input_buffer
.game_copy_input_buffer_loop
    ld      a, (de)
    ld      (hl), a
    inc     de
    inc     hl
    or      a
    jr      nz, game_copy_input_buffer_loop

    ; レジスタの復帰
    pop     de
    pop     hl

    ; 終了
    ret

; 文字を入力する
;
_game_inkey:

    ; IN
    ;   hl = 出力する文字列
    ;   e  = 入力可能な最小の文字
    ;   d  = 入力可能な最大の文字 + 1
    ; OUT
    ;   a  = 入力された文字

    ; レジスタの保存
    push    hl
    push    bc

    ; 文字列の出力
    call    _game_print_without_linebreak

    ; カーソルの表示
    call    game_print_cursor

    ; 文字の入力
.game_inkey_loop:

    ; アプリケーションの更新
    push    de
    call    _app_update
    pop     de

    ; キー入力
    ld      a, (_xcs_key_code_edge)
    cp      e
    jr      c, game_inkey_loop
    cp      d
    jr      nc, game_inkey_loop
    push    af
    call    _game_putchar
    pop     af

    ; レジスタの復帰
    pop     bc
    pop     hl

    ; 終了
    ret

; カーソルを表示する
;
game_print_cursor:

    ; レジスタの保存
    push    bc
    push    de

    ; 反転した空白の出力
    ld      de, (game_text_htab)
    call    _xcs_calc_text_vram_0
    ld      a, ' ' + $80
    out     (c), a

    ; レジスタの復帰
    pop     de
    pop     bc

    ; 終了
    ret

; カーソルを消去する
;
game_erase_cursor:

    ; レジスタの保存
    push    bc
    push    de

    ; 空白の出力
    ld      de, (game_text_htab)
    call    _xcs_calc_text_vram_0
    ld      a, ' '
    out     (c), a

    ; レジスタの復帰
    pop     de
    pop     bc

    ; 終了
    ret

; 文字列をバッファにコピーする
;
_game_strcpy:

    ; IN
    ;   hl = 文字列
    ; OUT
    ;   hl = 文字列バッファ

    ; レジスタの保存
    push    de

    ; 文字列のコピー
    ld      de, game_string_buffer
.game_strcpy_loop
    ld      a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    or      a
    jr      nz, game_strcpy_loop
    ld      hl, game_string_buffer

    ; レジスタの復帰
    pop     de

    ; 終了
    ret

; 数値をバッファにコピーする
;
_game_numcpy:

    ; IN
    ;   de = 数値
    ; OUT
    ;   hl = 文字列バッファ

    ; 数値を文字列化してコピー
    call    _xcs_get_decimal_string
    call    _game_strcpy

    ; 終了
    ret

; 文字列をバッファに連結する
;
_game_strcat:

    ; IN
    ;   hl = 文字列
    ; OUT
    ;   hl = 文字列バッファ

    ; レジスタの保存
    push    de

    ; 文字列の終端の取得
    ld      de, game_string_buffer
.game_strcat_null_loop
    ld      a, (de)
    inc     de
    or      a
    jr      nz, game_strcat_null_loop
    dec     de

    ; 文字列のコピー
.game_strcat_copy_loop
    ld      a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    or      a
    jr      nz, game_strcat_copy_loop
    ld      hl, game_string_buffer

    ; レジスタの復帰
    pop     de

    ; 終了
    ret

; 数値をバッファに連結する
;
_game_numcat:

    ; IN
    ;   de = 数値
    ; OUT
    ;   hl = 文字列バッファ

    ; 数値を文字列化してコピー
    call    _xcs_get_decimal_string
    call    _game_strcat

    ; 終了
    ret

; マップのアドレスを計算する
;
_game_calc_ml:

    ; IN
    ;   de  = マップ Y/X 位置
    ; OUT
    ;   hl = マップのアドレス

    ; レジスタの保存
    push    bc
    push    de

    ; hl = APP_PTR_ML + d * 80 + e
    ld      l, d
    ld      h, $00
    add     hl, hl
    add     hl, hl
    add     hl, hl
    add     hl, hl
    ld      c, l
    ld      b, h
    add     hl, hl
    add     hl, hl
    add     hl, bc
    ld      d, $00
    add     hl, de
    ld      de, APP_PTR_ML
    add     hl, de

    ; レジスタの復帰
    pop     de
    pop     bc

    ; 終了
    ret

; マップの値を取得する
;
_game_get_ml:

    ; IN
    ;   de = マップ Y/X 位置
    ; OUT
    ;   a  = マップの値
    ;   hl = マップのアドレス

    ; マップの取得
    call    _game_calc_ml
    ld      a, (hl)

    ; 終了
    ret

; マップに値を設定する
;
_game_set_ml:

    ; IN
    ;   de = マップ Y/X 位置
    ;   a  = マップの値
    ; OUT
    ;   hl = マップのアドレス

    ; マップの設定
    push    af
    call    _game_calc_ml
    pop     af
    ld      (hl), a

    ; 終了
    ret

; マップのタイルセットを取得する
;
game_get_ml_tileset:

    ; IN
    ;   de = マップ Y/X 位置
    ; OUT
    ;   hl = タイルセットのアドレス

    ; レジスタの保存
    push    de

    ; マップの取得
    call    _game_get_ml
    ld      h, a

    ; 壁の色
    cp      1
    jr      nz, game_get_ml_tileset_wallcolor_end
    ld      a, (_var_cf + VAR_CF_CX)
    cp      50
    jr      c, game_get_ml_tileset_wallcolor_end
    ld      a, (_var_cf + VAR_CF_CY)
    cp      51
    jr      c, game_get_ml_tileset_wallcolor_end
    ld      h, 40
.game_get_ml_tileset_wallcolor_end

    ; プレイヤーの種類
    ld      a, h
    cp      2
    jr      nz, game_get_ml_tileset_player_end
    ld      a, (_var_cf + VAR_CF_ZW)
    ld      h, a
.game_get_ml_tileset_player_end

    ; タイルセットの取得
    ld      l, $00
    ld      e, l
    ld      a, h
    or      a
    rra
    rr      e
    rra
    rr      e
    rra
    rr      e
    ld      d, a
    add     hl, de
    ld      de, APP_PTR_SKETCHZ
    add     hl, de

    ; レジスタの復帰
    pop     de

    ; 終了
    ret

; マップのタイルを描画する
;
_game_draw_ml_tile:

    ; IN
    ;   de = マップ Y/X 位置
    ;   bc = タイル Y/X 位置

    ; レジスタの保存
    push    hl
    push    bc
    push    de

    ; タイルセットの取得
    call    game_get_ml_tileset

    ; タイルの描画
    ld      e, c
    ld      d, b
    ld      a, d
    cp      XCS_IO_TEXT_VRAM_SIZE_Y
    jr      c, game_draw_ml_tile_row_0
    ld      bc, $0018 * $0004
    add     hl, bc
    jr      game_draw_ml_tile_row_1
.game_draw_ml_tile_row_0
    push    de      ; row 0
    push    de
    call    _xcs_draw_8x8_tile_0
    pop     de
    inc     e
    push    de
    call    _xcs_draw_8x8_tile_0
    pop     de
    inc     e
    push    de
    call    _xcs_draw_8x8_tile_0
    pop     de
    inc     e
    push    de
    call    _xcs_draw_8x8_tile_0
    pop     de
    pop     de
.game_draw_ml_tile_row_1
    inc     d
    push    de      ; row 1
    push    de
    call    _xcs_draw_8x8_tile_0
    pop     de
    inc     e
    push    de
    call    _xcs_draw_8x8_tile_0
    pop     de
    inc     e
    push    de
    call    _xcs_draw_8x8_tile_0
    pop     de
    inc     e
    push    de
    call    _xcs_draw_8x8_tile_0
    pop     de
    pop     de
    inc     d
    ld      a, d
    cp      XCS_IO_TEXT_VRAM_SIZE_Y
    jr      nc, game_draw_ml_tile_done
;   push    de      ; row 2
    push    de
    call    _xcs_draw_8x8_tile_0
    pop     de
    inc     e
    push    de
    call    _xcs_draw_8x8_tile_0
    pop     de
    inc     e
    push    de
    call    _xcs_draw_8x8_tile_0
    pop     de
    inc     e
;   push    de
    call    _xcs_draw_8x8_tile_0
;   pop     de
;   pop     de
;   inc     d
.game_draw_ml_tile_done

    ; レジスタの復帰
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

; マップのタイルを反転描画する
;
_game_invert_ml_tile:

    ; IN
    ;   de = マップ Y/X 位置
    ;   bc = タイル Y/X 位置

    ; レジスタの保存
    push    hl
    push    bc
    push    de

    ; タイルセットの取得
    call    game_get_ml_tileset

    ; タイルの描画
    ld      e, c
    ld      d, b
    ld      a, d
    cp      XCS_IO_TEXT_VRAM_SIZE_Y
    jr      c, game_invert_ml_tile_row_0
    ld      bc, $0018 * $0004
    add     hl, bc
    jr      game_invert_ml_tile_row_1
.game_invert_ml_tile_row_0
    push    de      ; row 0
    push    de
    call    _xcs_invert_8x8_tile_0
    pop     de
    inc     e
    push    de
    call    _xcs_invert_8x8_tile_0
    pop     de
    inc     e
    push    de
    call    _xcs_invert_8x8_tile_0
    pop     de
    inc     e
    push    de
    call    _xcs_invert_8x8_tile_0
    pop     de
    pop     de
.game_invert_ml_tile_row_1
    inc     d
    push    de      ; row 1
    push    de
    call    _xcs_invert_8x8_tile_0
    pop     de
    inc     e
    push    de
    call    _xcs_invert_8x8_tile_0
    pop     de
    inc     e
    push    de
    call    _xcs_invert_8x8_tile_0
    pop     de
    inc     e
    push    de
    call    _xcs_invert_8x8_tile_0
    pop     de
    pop     de
    inc     d
    ld      a, d
    cp      XCS_IO_TEXT_VRAM_SIZE_Y
    jr      nc, game_invert_ml_tile_done
;   push    de      ; row 2
    push    de
    call    _xcs_invert_8x8_tile_0
    pop     de
    inc     e
    push    de
    call    _xcs_invert_8x8_tile_0
    pop     de
    inc     e
    push    de
    call    _xcs_invert_8x8_tile_0
    pop     de
    inc     e
;   push    de
    call    _xcs_invert_8x8_tile_0
;   pop     de
;   pop     de
;   inc     d
.game_invert_ml_tile_done

    ; レジスタの復帰
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

; 画面に配置されたタイルセットを取得する
;
game_get_placed_ml_tileset:

    ; IN
    ;   de = タイル Y/X 位置
    ; OUT
    ;   hl = タイルセット

    ; レジスタの保存
    push    bc
    push    de

    ; de = マップの位置, bc = タイル内 4x3 の位置
    ld      a, e
    srl     e
    srl     e
    and     $03
    ld      c, a
    inc     d
    ld      a, d
    ld      d, $00
.game_get_placed_ml_tileset_div3
    sub     $03
    jr      c, game_get_placed_ml_tileset_div3_end
    inc     d
    jr      game_get_placed_ml_tileset_div3
.game_get_placed_ml_tileset_div3_end
    add     a, 3
    ld      b, a
    ld      hl, (_var_cf + VAR_CF_CX)
    ld      a, l
    add     a, e
    ld      e, a
    ld      a, h
    add     a, d
    ld      d, a

    ; タイルセットの取得
    call    game_get_ml_tileset
    ex      de, hl
    ld      a, b
    add     a, a
    add     a, a
    add     a, c
    ld      l, a
    ld      h, $00
    add     hl, hl
    add     hl, hl
    add     hl, hl
    ld      c, l
    ld      b, h
    add     hl, hl
    add     hl, bc
    add     hl, de

    ; レジスタの復帰
    pop     de
    pop     bc

    ; 終了
    ret

; タイルを上書きする
;
_game_draw_tile_on_ml:

    ;   de = タイル Y/X 位置
    ;   hl = マスクありのタイルセット
    ;   a  = タイル番号

    ; レジスタの保存
    push    hl
    push    bc
    push    de

    ; クリッピング
    ld      c, a
    ld      a, e
    cp      XCS_IO_TEXT_VRAM_SIZE_X
    jr      nc, game_draw_tile_on_ml_end
    ld      a, d
    cp      XCS_IO_TEXT_VRAM_SIZE_Y
    jr      nc, game_draw_tile_on_ml_end
    ld      a, c

    ; ml のタイルセットの取得
    push    af
    push    hl
    call    game_get_placed_ml_tileset
    ld      c, l
    ld      b, h
    pop     hl
    pop     af

    ; 重ね描き描画
    call    _xcs_overlay_8x8_tile

    ; レジスタの復帰
.game_draw_tile_on_ml_end
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

; CF.MISC を描画する
;
_game_draw_misc:

    ; IN
    ;   de = タイル Y/X 位置
    ;   a  = CF.MISC の種類

    ; レジスタの保存
    push    hl
    push    bc
    push    de

    ; CF.MISC は 2x3 サイズ
    add     a, a
    ld      c, a
    add     a, a
    add     a, c

    ; タイルの重ね書き
    ld      hl, APP_PTR_CFMISC
    ld      b, $03
.game_draw_misc_loop_y
    ld      c, $02
.game_draw_misc_loop_x
    push    af
    call    _game_draw_tile_on_ml
    pop     af
    inc     a
    inc     e
    dec     c
    jr      nz, game_draw_misc_loop_x
    dec     e
    dec     e
    inc     d
    djnz    game_draw_misc_loop_y

    ; レジスタの復帰
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

; CF.MISC を消去する
;
_game_erase_misc:

    ; IN
    ;   de = タイル Y/X 位置

    ; レジスタの保存
    push    hl
    push    bc
    push    de

    ; タイルの復帰
    ld      b, $03
.game_erase_misc_loop_y
    ld      c, $02
.game_erase_misc_loop_x
    push    bc
    push    de
    call    game_get_placed_ml_tileset
    call    _xcs_draw_8x8_tile_0
    pop     de
    pop     bc
    inc     e
    dec     c
    jr      nz, game_erase_misc_loop_x
    dec     e
    dec     e
    inc     d
    djnz    game_erase_misc_loop_y

    ; レジスタの復帰
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

; LBOLT を描画する
;
_game_draw_lbolt:

    ; IN
    ;   de = タイル Y/X 位置
    ;   a  = LBOLT の種類

    ; レジスタの保存
    push    hl
    push    bc
    push    de

    ; LBOLT は 4x3 サイズ
    add     a, a
    add     a, a
    ld      c, a
    add     a, a
    add     a, c

    ; タイルの重ね書き
    ld      hl, APP_PTR_LBOLT
    ld      b, $03
.game_draw_lbolt_loop_y
    ld      c, $04
.game_draw_lbolt_loop_x
    push    af
    call    _game_draw_tile_on_ml
    pop     af
    inc     a
    inc     e
    dec     c
    jr      nz, game_draw_lbolt_loop_x
    dec     e
    dec     e
    dec     e
    dec     e
    inc     d
    djnz    game_draw_lbolt_loop_y

    ; レジスタの復帰
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

; LBOLT を消去する
;
_game_erase_lbolt:

    ; IN
    ;   de = タイル Y/X 位置

    ; レジスタの保存
    push    hl
    push    bc
    push    de

    ; タイルの復帰
    ld      b, $03
.game_erase_lbolt_loop_y
    ld      a, d
    cp      XCS_IO_TEXT_VRAM_SIZE_Y
    jr      nc, game_erase_lbolt_skip_y
    ld      c, $04
.game_erase_lbolt_loop_x
    ld      a, e
    cp      XCS_IO_TEXT_VRAM_SIZE_X
    jr      nc, game_erase_lbolt_skip_x
    push    bc
    push    de
    call    game_get_placed_ml_tileset
    call    _xcs_draw_8x8_tile_0
    pop     de
    pop     bc
.game_erase_lbolt_skip_x
    inc     e
    dec     c
    jr      nz, game_erase_lbolt_loop_x
    dec     e
    dec     e
    dec     e
    dec     e
.game_erase_lbolt_skip_y
    inc     d
    djnz    game_erase_lbolt_loop_y

    ; レジスタの復帰
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

; BADBREATH を描画する
;
_game_draw_breath:

    ; IN
    ;   de = タイル Y/X 位置

    ; レジスタの保存
    push    hl
    push    bc
    push    de

    ; BADBREATH は 16x3 サイズ
    ; 右から描く
    ld      a, e
    add     a, 15
    ld      e, a
    ld      a, 15

    ; タイルの重ね書き
    ld      hl, APP_PTR_BADBREATH
    ld      c, $10
.game_draw_breath_loop_x
    ld      b, $03
.game_draw_breath_loop_y
    push    af
    call    _game_draw_tile_on_ml
    pop     af
    add     a, 16
    inc     d
    djnz    game_draw_breath_loop_y
    sub     16 * 3 + 1
    dec     d
    dec     d
    dec     d
    dec     e
    dec     c
    jr      nz, game_draw_breath_loop_x

    ; レジスタの復帰
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

; BADBREATH を消去する
;
_game_erase_breath:

    ; IN
    ;   de = タイル Y/X 位置

    ; レジスタの保存
    push    hl
    push    bc
    push    de

    ; BADBREATH は 16x3 サイズ
    ; 右から消す
    ld      a, e
    add     a, 15
    ld      e, a

    ; タイルの重ね書き
    ld      c, $10
.game_erase_breath_loop_x
    ld      a, e
    cp      XCS_IO_TEXT_VRAM_SIZE_X
    jr      nc, game_erase_breath_skip_x
    ld      b, $03
.game_erase_breath_loop_y
    ld      a, d
    cp      XCS_IO_TEXT_VRAM_SIZE_Y
    jr      nc, game_erase_breath_skip_y
    push    bc
    push    de
    call    game_get_placed_ml_tileset
    call    _xcs_draw_8x8_tile_0
    pop     de
    pop     bc
.game_erase_breath_skip_y
    inc     d
    djnz    game_erase_breath_loop_y
    dec     d
    dec     d
    dec     d
.game_erase_breath_skip_x
    dec     e
    dec     c
    jr      nz, game_erase_breath_loop_x

    ; レジスタの復帰
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

; ドットを描く
;
_game_draw_dot:

    ; IN
    ;   de = Y/X 位置
    ;   a  = 色

    ; 160x96 の画面として 2x2 サイズのドットを描く

    ; クリッピング
    ex      af, af'
    ld      a, e
    cp      160
    ret     nc
    ld      a, d
    cp      96
    ret     nc
    ex      af, af'

    ; レジスタの保存
    push    hl
    push    bc
    push    de

    ; アドレスの計算
    push    af
    ld      a, d
    and     $fc
    ld      h, $00
    add     a, a
    rl      h
    ld      c, a
    ld      b, h
    add     a, a
    rl      h
    add     a, a
    rl      h
    ld      l, a
    add     hl, bc      ; hl  = (y / 4) * 40
    ld      a, d
    and     $03
    add     a, a
    add     a, a
    add     a, a
    add     a, a
    ld      c, $00
    ld      b, a
    add     hl, bc      ; hl += (y % 8) * $1000
    ld      a, e
    and     $fc
    rra
    rra
    ld      c, a
    ld      b, $00
    add     hl, bc      ; hl += x / 4
    ld      c, l
    ld      b, h        ; bc = offset address
    ld      a, e
    and     $03
    ld      e, a
    ld      d, $00
    ld      hl, game_draw_dot_bit
    add     hl, de
    ld      a, (hl)
    ld      e, a        ; e = bit
    cpl
    ld      d, a        ; d = not bit
    pop     af
    ld      l, a        ; l = color

    ; 青の描画
.game_draw_dot_blue
    ld      a, b
    add     a, $40
    ld      b, a
    rr      l
    jr      nc, game_draw_dot_blue_0
    in      a, (c)
    or      e
    out     (c), a
    ld      a, b
    add     a, $08
    ld      b, a
    in      a, (c)
    or      e
    out     (c), a
    jr      game_draw_dot_blue_end
.game_draw_dot_blue_0
    in      a, (c)
    and     d
    out     (c), a
    ld      a, b
    add     a, $08
    ld      b, a
    in      a, (c)
    and     d
    out     (c), a
.game_draw_dot_blue_end

    ; 赤の描画
.game_draw_dot_red
    ld      a, b
    add     a, $40 - $08
    ld      b, a
    rr      l
    jr      nc, game_draw_dot_red_0
    in      a, (c)
    or      e
    out     (c), a
    ld      a, b
    add     a, $08
    ld      b, a
    in      a, (c)
    or      e
    out     (c), a
    jr      game_draw_dot_red_end
.game_draw_dot_red_0
    in      a, (c)
    and     d
    out     (c), a
    ld      a, b
    add     a, $08
    ld      b, a
    in      a, (c)
    and     d
    out     (c), a
.game_draw_dot_red_end

    ; 緑の描画
.game_draw_dot_green
    ld      a, b
    add     a, $40 - $08
    ld      b, a
    rr      l
    jr      nc, game_draw_dot_green_0
    in      a, (c)
    or      e
    out     (c), a
    ld      a, b
    add     a, $08
    ld      b, a
    in      a, (c)
    or      e
    out     (c), a
    jr      game_draw_dot_green_end
.game_draw_dot_green_0
    in      a, (c)
    and     d
    out     (c), a
    ld      a, b
    add     a, $08
    ld      b, a
    in      a, (c)
    and     d
    out     (c), a
.game_draw_dot_green_end

    ; レジスタの復帰
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

.game_draw_dot_bit
    defb    %11000000
    defb    %00110000
    defb    %00001100
    defb    %00000011

; 一定フレームの間待機する
;
_game_wait:

    ; IN
    ;   a = 待機するフレーム数

    ; レジスタの保存
    push    hl
    push    bc
    push    de

    ; 待機
.game_wait_loop
    push    af
    call    _app_update
    pop     af
    dec     a
    jr      nz, game_wait_loop

    ; レジスタの復帰
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

; ディスプレイモード
;
game_display:
    defs    $01

; テキスト
;
game_text_htab:
    defs    $01
game_text_vtab:
    defs    $01
game_text_font:
    defs    $01

; 入力
;
game_input_buffer:
    defs    GAME_INPUT_LENGTH + $01

; 文字列
;
game_string_buffer:
    defs    GAME_STRING_LENGTH + $01

; タイル
;
game_tile_8x8:
    defs    $08 * $03
