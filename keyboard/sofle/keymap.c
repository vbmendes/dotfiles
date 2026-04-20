// Copyright 2024 vbmendes
// SPDX-License-Identifier: GPL-2.0-or-later
#include QMK_KEYBOARD_H
#include "transactions.h"
#include <string.h>

enum sofle_layers {
    _QWERTY,
    _SYMBOLS,
    _NUMPAD,
    _FUNCTION,
    _NAV,
};

enum custom_keycodes {
    CIRCSPC = QK_USER,
    QUOTSPC,
    TILDSPC,
    GRAVSPC,
    CEDILLA,
};

#define MEH_KEY LCTL(LALT(KC_LSFT))
#define LOCK_SCR LGUI(KC_L)

// ── Combos ────────────────────────────────────────────────────────────────────

const uint16_t PROGMEM combo_df[]    = {KC_D,    KC_F,    COMBO_END};
const uint16_t PROGMEM combo_xc[]    = {KC_X,    KC_C,    COMBO_END};
const uint16_t PROGMEM combo_cv[]    = {KC_C,    KC_V,    COMBO_END};
const uint16_t PROGMEM combo_zv[]    = {KC_Z,    KC_V,    COMBO_END};
const uint16_t PROGMEM combo_jk[]    = {KC_J,    KC_K,    COMBO_END};
const uint16_t PROGMEM combo_dt_cm[] = {KC_DOT,  KC_COMM, COMBO_END};
const uint16_t PROGMEM combo_m_cm[]  = {KC_M,    KC_COMM, COMBO_END};
const uint16_t PROGMEM combo_m_sl[]  = {KC_M,    KC_SLSH, COMBO_END};

combo_t key_combos[] = {
    COMBO(combo_df,    KC_LSFT),
    COMBO(combo_xc,    KC_LCTL),
    COMBO(combo_cv,    KC_LGUI),
    COMBO(combo_zv,    KC_LALT),
    COMBO(combo_jk,    KC_RSFT),
    COMBO(combo_dt_cm, KC_RCTL),
    COMBO(combo_m_cm,  KC_RGUI),
    COMBO(combo_m_sl,  KC_RALT),
};

layer_state_t layer_state_set_user(layer_state_t state) {
    if (state & ((layer_state_t)1 << _NAV)) {
        combo_disable();
    } else {
        combo_enable();
    }
    return state;
}

// ── Custom keycodes ───────────────────────────────────────────────────────────

bool process_record_user(uint16_t keycode, keyrecord_t *record) {
    if (!record->event.pressed) return true;
    switch (keycode) {
        case CIRCSPC:
            tap_code16(LSFT(KC_6));
            tap_code(KC_SPC);
            return false;
        case QUOTSPC:
            tap_code(KC_QUOT);
            tap_code(KC_SPC);
            return false;
        case TILDSPC:
            tap_code16(LSFT(KC_GRV));
            tap_code(KC_SPC);
            return false;
        case GRAVSPC:
            tap_code(KC_GRV);
            tap_code(KC_SPC);
            return false;
        case CEDILLA:
            tap_code16(RALT(KC_C));
            return false;
    }
    return true;
}

// ── Keymaps ───────────────────────────────────────────────────────────────────

// clang-format off
const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {

/*
 * QWERTY
 * ,---------------------------------------------.                    ,---------------------------------------------.
 * | ESC  |  F1  |  F2  |  F3  |  F4  |  F5  |                    |  F6  |  F7  |  F8  |  F9  | F10  |C+G+Q |
 * |------+------+------+------+------+------|                    |------+------+------+------+------+------|
 * | TAB  |   Q  |   W  |   E  |   R  |   T  |                    |   Y  |   U  |   I  |   O  |   P  | ENT  |
 * |------+------+------+------+------+------|                    |------+------+------+------+------+------|
 * | MEH  |   A  |   S  |   D  |   F  |   G  |-------.    ,-------|   H  |   J  |   K  |   L  |   ;  | MEH  |
 * |------+------+------+------+------+------|  MUTE |    |H(F5) |------+------+------+------+------+------|
 * | LGUI |   Z  |   X  |   C  |   V  |   B  |-------|    |-------|   N  |   M  |   ,  |   .  |   /  | LGUI |
 * `---------------------------------------------/       /     \      \---------------------------------------------'
 *            | LCTL | NUMP | NAV  | LSFT | LGUI |/       /         \      \ | LGUI | SPC  | SYMB | BSPC | LALT |
 *            `------------------------------------------'           '------''----------------------------------'
 */
[_QWERTY] = LAYOUT(
    KC_ESC,  KC_F1,        KC_F2,        KC_F3,   KC_F4,   KC_F5,                         KC_F6,   KC_F7,        KC_F8,   KC_F9,   KC_F10,  LCTL(LGUI(KC_Q)),
    KC_TAB,  KC_Q,         KC_W,         KC_E,    KC_R,    KC_T,                           KC_Y,    KC_U,         KC_I,    KC_O,    KC_P,    KC_ENT,
    MEH_KEY, KC_A,         KC_S,         KC_D,    KC_F,    KC_G,                           KC_H,    KC_J,         KC_K,    KC_L,    KC_SCLN, MEH_KEY,
    KC_LGUI, KC_Z,         KC_X,         KC_C,    KC_V,    KC_B,    KC_MUTE, HYPR(KC_F5),  KC_N,    KC_M,         KC_COMM, KC_DOT,  KC_SLSH, KC_LGUI,
             KC_LCTL,      MO(_NUMPAD),  MO(_NAV), KC_LSFT, KC_LGUI,          KC_LGUI,     KC_SPC,  MO(_SYMBOLS), KC_BSPC, KC_LALT
),

/*
 * SYMBOLS
 * ,---------------------------------------------.                    ,---------------------------------------------.
 * | QWRT |  F1  |  F2  |  F3  |  F4  |  F5  |                    |  F6  |  F7  |  F8  |  F9  | F10  |C+G+Q |
 * |------+------+------+------+------+------|                    |------+------+------+------+------+------|
 * | TAB  |   !  |   @  |   #  |   $  |   %  |                    |   *  |      |      |      |   =  |      |
 * |------+------+------+------+------+------|                    |------+------+------+------+------+------|
 * | NUMP |      |      |   (  |   )  |   _  |-------.    ,-------|   ^  |   '  |   `  |   ç  | BSPC | NUMP |
 * |------+------+------+------+------+------|  MUTE |    |H(F5) |------+------+------+------+------+------|
 * | FUNC |   \  |C+G+SP|   [  |   ]  |   &  |-------|    |-------|circ' |quot' |grav' |Alt+0 |Alt+9 | FUNC |
 * `---------------------------------------------/       /     \      \---------------------------------------------'
 *            | LCTL | FUNC |      |      | LGUI |/       /         \      \ | LGUI | NAV  |      |      | LALT |
 *            `------------------------------------------'           '------''----------------------------------'
 */
[_SYMBOLS] = LAYOUT(
    TO(_QWERTY),   KC_1,    KC_2,                KC_3,    KC_4,    KC_5,                           KC_6,    KC_7,     KC_8,    KC_9,       KC_0,       LCTL(LGUI(KC_Q)),
    KC_TAB,        KC_EXLM, KC_AT,               KC_HASH, KC_DLR,  KC_PERC,                         KC_ASTR, _______,  _______, _______,    KC_EQL,     _______,
    TO(_NUMPAD),   _______, _______,             KC_LPRN, KC_RPRN, KC_UNDS,                         KC_CIRC, KC_QUOT,  KC_GRV,  CEDILLA,    KC_BSPC,    TO(_NUMPAD),
    TO(_FUNCTION), KC_BSLS, LCTL(LGUI(KC_SPC)), KC_LBRC, KC_RBRC, KC_AMPR, KC_MUTE, HYPR(KC_F5),  CIRCSPC, QUOTSPC,  GRAVSPC, LALT(KC_0), LALT(KC_9), TO(_FUNCTION),
             KC_LCTL, MO(_FUNCTION), _______, _______, KC_LGUI,                                     KC_LGUI, MO(_NAV), _______, _______,    KC_LALT
),

/*
 * NUMPAD
 * ,---------------------------------------------.                    ,---------------------------------------------.
 * | QWRT |  F1  |  F2  |  F3  |  F4  |  F5  |                    |  F6  |  F7  |  F8  |  F9  | F10  |C+G+Q |
 * |------+------+------+------+------+------|                    |------+------+------+------+------+------|
 * | TAB  |   !  |   @  |   #  |   $  |   %  |                    |   *  |   7  |   8  |   9  |   =  |      |
 * |------+------+------+------+------+------|                    |------+------+------+------+------+------|
 * | SYMB |   {  |   }  |   (  |   )  |   _  |-------.    ,-------|   -  |   4  |   5  |   6  | BSPC | SYMB |
 * |------+------+------+------+------+------|  MUTE |    |H(F5) |------+------+------+------+------+------|
 * | FUNC |   \  |C+G+SP|   [  |   ]  |   &  |-------|    |-------|   +  |   1  |   2  |   3  |   .  | FUNC |
 * `---------------------------------------------/       /     \      \---------------------------------------------'
 *            | LCTL | FUNC |      |      | LGUI |/       /         \      \ | LGUI |      |   0  |      | LALT |
 *            `------------------------------------------'           '------''----------------------------------'
 */
[_NUMPAD] = LAYOUT(
    TO(_QWERTY),   KC_1,    KC_2,                KC_3,    KC_4,    KC_5,                           KC_6,    KC_7,    KC_8,  KC_9,    KC_0,    LCTL(LGUI(KC_Q)),
    KC_TAB,        KC_EXLM, KC_AT,               KC_HASH, KC_DLR,  KC_PERC,                         KC_ASTR, KC_7,    KC_8,  KC_9,    KC_EQL,  _______,
    TO(_SYMBOLS),  KC_LCBR, KC_RCBR,             KC_LPRN, KC_RPRN, KC_UNDS,                         KC_MINS, KC_4,    KC_5,  KC_6,    KC_BSPC, TO(_SYMBOLS),
    TO(_FUNCTION), KC_BSLS, LCTL(LGUI(KC_SPC)), KC_LBRC, KC_RBRC, KC_AMPR, KC_MUTE, HYPR(KC_F5),  KC_PLUS, KC_1,    KC_2,  KC_3,    KC_DOT,  TO(_FUNCTION),
             KC_LCTL, MO(_FUNCTION), _______, _______, KC_LGUI,                                     KC_LGUI, _______, KC_0,  _______, KC_LALT
),

/*
 * FUNCTION
 * ,---------------------------------------------.                    ,---------------------------------------------.
 * | QWRT |  F1  |  F2  |  F3  |  F4  |  F5  |                    |  F6  |  F7  |  F8  |  F9  | F10  |C+G+Q |
 * |------+------+------+------+------+------|                    |------+------+------+------+------+------|
 * | TAB  |  F1  |  F2  |  F3  |  F4  |  F5  |                    |  F6  |  F7  |  F8  |  F9  | F10  | BRIU |
 * |------+------+------+------+------+------|                    |------+------+------+------+------+------|
 * |CpWrd |C+UP  | CAPS |SG+3  |SG+4  |  F11 |-------.    ,-------|  F12 | PREV | PLAY | NEXT | STOP | BRID |
 * |------+------+------+------+------+------|  MUTE |    |H(F5) |------+------+------+------+------+------|
 * | BOOT |      |      |      |      |      |-------|    |-------|      | MUTE |VOL-  |VOL+  | LOCK |H+GRV |
 * `---------------------------------------------/       /     \      \---------------------------------------------'
 *            | LCTL |      |      |      | LGUI |/       /         \      \ | LGUI |      |      |      | LALT |
 *            `------------------------------------------'           '------''----------------------------------'
 */
[_FUNCTION] = LAYOUT(
    TO(_QWERTY),   KC_1,        KC_2,    KC_3,                KC_4,                KC_5,                           KC_6,    KC_7,    KC_8,    KC_9,    KC_0,    LCTL(LGUI(KC_Q)),
    KC_TAB,        KC_F1,       KC_F2,   KC_F3,               KC_F4,               KC_F5,                          KC_F6,   KC_F7,   KC_F8,   KC_F9,   KC_F10,  KC_BRIU,
    CW_TOGG,       LCTL(KC_UP), KC_CAPS, LSFT(LGUI(KC_3)),   LSFT(LGUI(KC_4)),   KC_F11,                          KC_F12,  KC_MPRV, KC_MPLY, KC_MNXT, KC_MSTP, KC_BRID,
    QK_BOOT,       KC_NO,       KC_NO,   KC_NO,               KC_NO,               KC_NO,   KC_MUTE, HYPR(KC_F5),  _______, KC_MUTE, KC_VOLD, KC_VOLU, LOCK_SCR, HYPR(KC_GRV),
             KC_LCTL, _______, _______, _______, KC_LGUI,                                                           KC_LGUI, _______, _______, _______, KC_LALT
),

/*
 * NAV (combos disabled)
 * ,---------------------------------------------.                    ,---------------------------------------------.
 * | QWRT |  F1  |  F2  |  F3  |  F4  |  F5  |                    |  F6  |  F7  |  F8  |  F9  | F10  |C+G+Q |
 * |------+------+------+------+------+------|                    |------+------+------+------+------+------|
 * | TAB  | ESC  | HOME | PGDN | PGUP | END  |                    | HOME | PGDN | PGUP | END  |   =  |      |
 * |------+------+------+------+------+------|                    |------+------+------+------+------+------|
 * | NUMP | DEL  | LEFT | DOWN |  UP  | RGHT |-------.    ,-------| LEFT | DOWN |  UP  | RGHT | BSPC | NUMP |
 * |------+------+------+------+------+------|  MUTE |    |H(F5) |------+------+------+------+------+------|
 * | FUNC | LSFT | LCTL | LALT | LGUI | MEH  |-------|    |-------| MEH  | LGUI | LALT | LCTL | LSFT | FUNC |
 * `---------------------------------------------/       /     \      \---------------------------------------------'
 *            | LCTL |      |      | LGUI | LGUI |/       /         \      \ | LGUI |  =   |      |      | LALT |
 *            `------------------------------------------'           '------''----------------------------------'
 */
[_NAV] = LAYOUT(
    TO(_QWERTY),   KC_1,    KC_2,    KC_3,    KC_4,    KC_5,                           KC_6,    KC_7,    KC_8,    KC_9,    KC_0,    LCTL(LGUI(KC_Q)),
    KC_TAB,        KC_ESC,  KC_HOME, KC_PGDN, KC_PGUP, KC_END,                          KC_HOME, KC_PGDN, KC_PGUP, KC_END,  KC_EQL,  _______,
    TO(_NUMPAD),   KC_DEL,  KC_LEFT, KC_DOWN, KC_UP,   KC_RGHT,                         KC_LEFT, KC_DOWN, KC_UP,   KC_RGHT, KC_BSPC, TO(_NUMPAD),
    TO(_FUNCTION), KC_LSFT, KC_LCTL, KC_LALT, KC_LGUI, MEH_KEY, KC_MUTE, HYPR(KC_F5),  MEH_KEY, KC_LGUI, KC_LALT, KC_LCTL, KC_LSFT, TO(_FUNCTION),
             KC_LCTL, _______, _______, KC_LGUI, KC_LGUI,                                KC_LGUI, KC_EQL,  _______, _______, KC_LALT
),

};
// clang-format on

// ── Encoders ──────────────────────────────────────────────────────────────────

#ifdef ENCODER_MAP_ENABLE
const uint16_t PROGMEM encoder_map[][NUM_ENCODERS][NUM_DIRECTIONS] = {
    [_QWERTY]   = { ENCODER_CCW_CW(KC_VOLD, KC_VOLU), ENCODER_CCW_CW(KC_PGUP, KC_PGDN) },
    [_SYMBOLS]  = { ENCODER_CCW_CW(_______, _______),  ENCODER_CCW_CW(_______, _______) },
    [_NUMPAD]   = { ENCODER_CCW_CW(_______, _______),  ENCODER_CCW_CW(_______, _______) },
    [_FUNCTION] = { ENCODER_CCW_CW(KC_BRID, KC_BRIU),  ENCODER_CCW_CW(KC_MPRV, KC_MNXT) },
    [_NAV]      = { ENCODER_CCW_CW(_______, _______),  ENCODER_CCW_CW(KC_LEFT, KC_RGHT) },
};
#endif

// ── Split mod sync ────────────────────────────────────────────────────────────

typedef struct { uint8_t mods; } user_mods_t;
static user_mods_t slave_mods = {0};

void user_sync_mods_handler(uint8_t in_buflen, const void *in_data, uint8_t out_buflen, void *out_data) {
    memcpy(&slave_mods, in_data, sizeof(slave_mods));
}

void keyboard_post_init_user(void) {
    transaction_register_rpc(USER_SYNC_MODS, user_sync_mods_handler);
}

void housekeeping_task_user(void) {
    if (!is_keyboard_master()) return;
    static user_mods_t last = {0};
    user_mods_t current = { .mods = get_mods() | get_oneshot_mods() };
    if (memcmp(&last, &current, sizeof(current)) != 0) {
        if (transaction_rpc_send(USER_SYNC_MODS, sizeof(current), &current)) {
            last = current;
        }
    }
}

// ── OLED ──────────────────────────────────────────────────────────────────────

#ifdef OLED_ENABLE

static void render_layer_status(void) {
    uint8_t current = get_highest_layer(layer_state);
    oled_write_ln_P(PSTR("     "), false);
    oled_write_ln_P(current == _QWERTY   ? PSTR(">QWRT") : PSTR(" QWRT"), false);
    oled_write_ln_P(current == _SYMBOLS  ? PSTR(">SYMB") : PSTR(" SYMB"), false);
    oled_write_ln_P(current == _NUMPAD   ? PSTR(">NUMP") : PSTR(" NUMP"), false);
    oled_write_ln_P(current == _FUNCTION ? PSTR(">FUNC") : PSTR(" FUNC"), false);
    oled_write_ln_P(current == _NAV      ? PSTR("> NAV") : PSTR("  NAV"), false);
}

static void render_mod_status(void) {
    uint8_t mods = slave_mods.mods;

    oled_write_P(mods & MOD_BIT(KC_LSFT) ? PSTR("<") : PSTR(" "), false);
    oled_write_P(PSTR(" S "), false);
    oled_write_ln_P(mods & MOD_BIT(KC_RSFT) ? PSTR(">") : PSTR(" "), false);

    oled_write_P(mods & MOD_BIT(KC_LCTL) ? PSTR("<") : PSTR(" "), false);
    oled_write_P(PSTR(" C "), false);
    oled_write_ln_P(mods & MOD_BIT(KC_RCTL) ? PSTR(">") : PSTR(" "), false);

    oled_write_P(mods & MOD_BIT(KC_LALT) ? PSTR("<") : PSTR(" "), false);
    oled_write_P(PSTR(" A "), false);
    oled_write_ln_P(mods & MOD_BIT(KC_RALT) ? PSTR(">") : PSTR(" "), false);

    oled_write_P(mods & MOD_BIT(KC_LGUI) ? PSTR("<") : PSTR(" "), false);
    oled_write_P(PSTR(" G "), false);
    oled_write_ln_P(mods & MOD_BIT(KC_RGUI) ? PSTR(">") : PSTR(" "), false);
}

oled_rotation_t oled_init_user(oled_rotation_t rotation) {
    return OLED_ROTATION_270;
}

bool oled_task_user(void) {
    if (is_keyboard_master()) {
        render_layer_status();
    } else {
        render_mod_status();
    }
    return false;
}

#endif
