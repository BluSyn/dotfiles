#include QMK_KEYBOARD_H
#include "version.h"
#define MOON_LED_LEVEL LED_LEVEL
#define ML_SAFE_RANGE SAFE_RANGE

enum custom_keycodes {
    RGB_SLD = ML_SAFE_RANGE,
    ST_MACRO_0,
    ST_MACRO_1,
    ST_MACRO_2,
    ST_MACRO_3,
    MAC_LOCK,
};

const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {
  [0] = LAYOUT_voyager(
    KC_MEDIA_PLAY_PAUSE,KC_EXLM,        KC_AT,          KC_HASH,        KC_DLR,         KC_PERC,                                        KC_CIRC,        KC_AMPR,        KC_ASTR,        KC_LPRN,        KC_RPRN,        MAC_LOCK,       
    KC_GRAVE,       KC_Q,           KC_W,           KC_E,           KC_R,           KC_T,                                           KC_Y,           KC_U,           KC_I,           KC_O,           KC_SCLN,        KC_BSLS,        
    LT(2,KC_TAB),   MT(MOD_LSFT, KC_A),MT(MOD_LCTL, KC_S),MT(MOD_LALT, KC_D),MT(MOD_LGUI, KC_F),KC_G,                                           KC_H,           MT(MOD_RGUI, KC_J),MT(MOD_RALT, KC_K),MT(MOD_RCTL, KC_L),MT(MOD_RSFT, KC_P),KC_QUOTE,       
    KC_MINUS,       KC_Z,           KC_X,           KC_C,           KC_V,           KC_B,                                           KC_N,           KC_M,           KC_COMMA,       KC_DOT,         KC_SLASH,       KC_EQUAL,       
                                                    LT(1,KC_SPACE), ALL_T(KC_ESCAPE),                                KC_ENTER,       KC_BSPC
  ),
  [1] = LAYOUT_voyager(
    KC_MEDIA_PREV_TRACK,KC_MEDIA_NEXT_TRACK,RGB_MODE_FORWARD,TOGGLE_LAYER_COLOR,KC_AUDIO_VOL_DOWN,KC_AUDIO_VOL_UP,                                LGUI(LSFT(KC_4)),KC_BRIGHTNESS_DOWN,KC_BRIGHTNESS_UP,RGB_VAD,        RGB_VAI,        RGUI(KC_GRAVE), 
    KC_TILD,        KC_UNDS,        KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT,                                 KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT, KC_COLN,        KC_PIPE,        
    LSFT(KC_ENTER), KC_LBRC,        KC_RBRC,        KC_LCBR,        KC_RCBR,        KC_COLN,                                        KC_LEFT,        KC_DOWN,        KC_UP,          KC_RIGHT,       CW_TOGG,        KC_DQUO,        
    KC_UNDS,        ST_MACRO_0,     ST_MACRO_1,     LGUI(KC_C),     LGUI(KC_V),     ST_MACRO_2,                                     ST_MACRO_3,     KC_AUDIO_MUTE,  LALT(KC_LEFT),  LALT(KC_RIGHT), KC_QUES,        KC_PLUS,        
                                                    KC_TRANSPARENT, KC_TRANSPARENT,                                 RSFT(KC_ENTER), LALT(KC_BSPC)
  ),
  [2] = LAYOUT_voyager(
    KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT,                                 KC_TRANSPARENT, KC_7,           KC_8,           KC_9,           KC_0,           KC_TRANSPARENT, 
    KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT,                                 KC_TRANSPARENT, KC_4,           KC_5,           KC_6,           KC_ASTR,        KC_MINUS,       
    KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT,                                 KC_TRANSPARENT, KC_1,           KC_2,           KC_3,           KC_PLUS,        KC_AMPR,        
    KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT,                                 KC_TRANSPARENT, KC_0,           KC_TRANSPARENT, KC_TRANSPARENT, KC_SLASH,       KC_EQUAL,       
                                                    KC_TRANSPARENT, QK_LLCK,                                        KC_TRANSPARENT, KC_TRANSPARENT
  ),
};


uint16_t get_tapping_term(uint16_t keycode, keyrecord_t *record) {
    switch (keycode) {
        case MT(MOD_LSFT, KC_A):
            return TAPPING_TERM + 50;
        case MT(MOD_LCTL, KC_S):
            return TAPPING_TERM + 100;
        case MT(MOD_LALT, KC_D):
            return TAPPING_TERM + 100;
        case MT(MOD_LGUI, KC_F):
            return TAPPING_TERM + 100;
        case KC_MINUS:
            return TAPPING_TERM -25;
        case LT(1,KC_SPACE):
            return TAPPING_TERM + 30;
        case ALL_T(KC_ESCAPE):
            return TAPPING_TERM + 50;
        case MT(MOD_RGUI, KC_J):
            return TAPPING_TERM + 100;
        case MT(MOD_RALT, KC_K):
            return TAPPING_TERM + 100;
        case MT(MOD_RCTL, KC_L):
            return TAPPING_TERM + 100;
        case MT(MOD_RSFT, KC_P):
            return TAPPING_TERM + 50;
        case KC_QUOTE:
            return TAPPING_TERM -25;
        case KC_ENTER:
            return 0;
        default:
            return TAPPING_TERM;
    }
}

extern rgb_config_t rgb_matrix_config;

void keyboard_post_init_user(void) {
    rgb_matrix_enable();
}

const uint8_t PROGMEM ledmap[][RGB_MATRIX_LED_COUNT][3] = {
    [0] = { {40,233,255}, {131,255,255}, {131,255,255}, {131,255,255}, {131,255,255}, {131,255,255}, {131,255,255}, {131,255,255}, {131,255,255}, {131,255,255}, {131,255,255}, {131,255,255}, {131,255,255}, {131,255,255}, {131,255,255}, {131,255,255}, {131,255,255}, {131,255,255}, {131,255,255}, {131,255,255}, {131,255,255}, {131,255,255}, {131,255,255}, {131,255,255}, {131,255,255}, {131,255,255}, {131,255,255}, {131,255,255}, {131,255,255}, {131,255,255}, {131,255,255}, {0,218,204}, {131,255,255}, {131,255,255}, {131,255,255}, {131,255,255}, {131,255,255}, {131,255,255}, {131,255,255}, {131,255,255}, {131,255,255}, {131,255,255}, {131,255,255}, {131,255,255}, {131,255,255}, {131,255,255}, {131,255,255}, {131,255,255}, {131,255,255}, {131,255,255}, {131,255,255}, {131,255,255} },

    [1] = { {40,233,255}, {40,233,255}, {220,218,204}, {220,218,204}, {40,233,255}, {40,233,255}, {108,218,204}, {108,218,204}, {131,255,255}, {131,255,255}, {131,255,255}, {131,255,255}, {108,218,204}, {108,218,204}, {108,218,204}, {108,218,204}, {108,218,204}, {108,218,204}, {108,218,204}, {0,0,255}, {0,0,255}, {237,232,255}, {237,232,255}, {0,0,255}, {0,0,0}, {0,0,0}, {0,218,204}, {40,233,255}, {40,233,255}, {40,233,255}, {40,233,255}, {220,218,204}, {131,255,255}, {131,255,255}, {131,255,255}, {131,255,255}, {108,218,204}, {108,218,204}, {0,0,255}, {0,0,255}, {0,0,255}, {0,0,255}, {0,218,204}, {108,218,204}, {0,0,255}, {40,233,255}, {0,0,255}, {0,0,255}, {108,218,204}, {108,218,204}, {0,218,204}, {0,0,255} },

    [2] = { {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {131,255,255}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {131,255,255}, {108,218,204}, {0,0,0}, {40,131,223}, {40,131,223}, {40,131,223}, {40,131,223}, {0,0,0}, {0,0,0}, {40,131,223}, {40,131,223}, {40,131,223}, {40,131,223}, {40,131,223}, {0,0,0}, {40,131,223}, {40,131,223}, {40,131,223}, {40,131,223}, {40,131,223}, {0,0,0}, {40,131,223}, {40,131,223}, {40,131,223}, {40,131,223}, {40,131,223}, {131,255,255}, {131,255,255} },

};

void set_layer_color(int layer) {
    for (int i = 0; i < RGB_MATRIX_LED_COUNT; i++) {
        HSV hsv = {
            .h = pgm_read_byte(&ledmap[layer][i][0]),
            .s = pgm_read_byte(&ledmap[layer][i][1]),
            .v = pgm_read_byte(&ledmap[layer][i][2]),
        };
        if (!hsv.h && !hsv.s && !hsv.v) {
            rgb_matrix_set_color( i, 0, 0, 0 );
        } else {
            RGB rgb = hsv_to_rgb( hsv );
            float f = (float)rgb_matrix_config.hsv.v / UINT8_MAX;
            rgb_matrix_set_color( i, f * rgb.r, f * rgb.g, f * rgb.b );
        }
    }
}

bool rgb_matrix_indicators_user(void) {
    if (rawhid_state.rgb_control) {
        return false;
    }
    if (keyboard_config.disable_layer_led) { return false; }
    switch (biton32(layer_state)) {
        case 0:
            set_layer_color(0);
            break;
        case 1:
            set_layer_color(1);
            break;
        case 2:
            set_layer_color(2);
            break;
        default:
            if (rgb_matrix_get_flags() == LED_FLAG_NONE)
                rgb_matrix_set_color_all(0, 0, 0);
            break;
    }
    return true;
}

bool is_symbol_key(uint16_t keycode) {
    switch(keycode) {
        case KC_EXLM:
        case KC_AT:
        case KC_HASH:
        case KC_DLR:
        case KC_PERC:
        case KC_CIRC:
        case KC_AMPR:
        case KC_ASTR:
        case KC_LPRN:
        case KC_RPRN:
            return true;
        default:
            return false;
    }
}

uint16_t get_number_keycode(uint16_t symbol_keycode) {
    switch(symbol_keycode) {
        case KC_EXLM: return KC_1;
        case KC_AT: return KC_2;
        case KC_HASH: return KC_3;
        case KC_DLR: return KC_4;
        case KC_PERC: return KC_5;
        case KC_CIRC: return KC_6;
        case KC_AMPR: return KC_7;
        case KC_ASTR: return KC_8;
        case KC_LPRN: return KC_9;
        case KC_RPRN: return KC_0;
        default: return KC_NO;
    }
}

bool process_record_user(uint16_t keycode, keyrecord_t *record) {
    switch (keycode) {
        case ST_MACRO_0:
            if (record->event.pressed) {
                SEND_STRING(SS_LCTL(SS_TAP(X_A)) SS_DELAY(100) SS_TAP(X_Z));
            }
            return true;
        case ST_MACRO_1:
            if (record->event.pressed) {
                SEND_STRING(SS_LCTL(SS_TAP(X_A)) SS_DELAY(100) SS_TAP(X_LBRC));
            }
            return true;
        case ST_MACRO_2:
            if (record->event.pressed) {
                SEND_STRING(SS_LCTL(SS_TAP(X_A)) SS_DELAY(100) SS_TAP(X_P));
            }
            return true;
        case ST_MACRO_3:
            if (record->event.pressed) {
                SEND_STRING(SS_LCTL(SS_TAP(X_A)) SS_DELAY(100) SS_TAP(X_N));
            }
            return true;
        case MAC_LOCK:
            HCS(0x19E);
            return true;

        case RGB_SLD:
            if (record->event.pressed) {
                rgblight_mode(1);
            }
            return false;
    }

    if (!record->event.pressed) {
        return true;
    }

    // support custom shift keys
    // TODO: use custom_shift_keys module when zsa voyager upgrades to latest qmk
    // https://getreuer.info/posts/keyboards/custom-shift-keys/#add-custom-shift-keys-to-your-keymap
    // Behavior:
    // symbol key = symbol
    // shift + symbol = number
    // cmd + symbol = cmd + number
    uint8_t mods = get_mods();
    uint8_t cmd_mods = mods & (MOD_BIT(KC_LGUI) | MOD_BIT(KC_RGUI));
    uint8_t shift_mods = mods & MOD_MASK_SHIFT;
    bool is_symbol = is_symbol_key(keycode);
    if (is_symbol && cmd_mods && !shift_mods) {
        // only command is pressed, no shift
        uint16_t number_keycode = get_number_keycode(keycode);
        tap_code(number_keycode);
        return false;
    } else if (is_symbol && !cmd_mods && shift_mods) {
        bool left_shift = shift_mods & MOD_BIT(KC_LSFT);
        bool right_shift = shift_mods & MOD_BIT(KC_RSFT);
        uint16_t number_keycode = get_number_keycode(keycode);

        // Unregister all active Shift modifiers
        if (left_shift) unregister_code(KC_LSFT);
        if (right_shift) unregister_code(KC_RSFT);

        tap_code(number_keycode);

        // Restore the original Shift state after sending the number
        if (left_shift) register_code(KC_LSFT);
        if (right_shift) register_code(KC_RSFT);
        return false;
    }

    return true;
}


