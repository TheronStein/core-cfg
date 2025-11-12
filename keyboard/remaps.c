enum custom_keycodes {
  R_ALT_MULTI = SAFE_RANGE, // Sends Shift+Ctrl
  R_CTRL_MULTI,             // Sends Alt+Ctrl
  R_SHIFT_MULTI,            // Sends Ctrl+Alt+Shift
};

bool process_record_user(uint16_t keycode, keyrecord_t *record) {
  switch (keycode) {
  case R_ALT_MULTI:
    if (record->event.pressed) {
      register_mods(MOD_BIT(KC_LSFT) | MOD_BIT(KC_LCTL));
    } else {
      unregister_mods(MOD_BIT(KC_LSFT) | MOD_BIT(KC_LCTL));
    }
    return false;

  case R_CTRL_MULTI:
    if (record->event.pressed) {
      register_mods(MOD_BIT(KC_LALT) | MOD_BIT(KC_LCTL));
    } else {
      unregister_mods(MOD_BIT(KC_LALT) | MOD_BIT(KC_LCTL));
    }
    return false;

  case R_SHIFT_MULTI:
    if (record->event.pressed) {
      register_mods(MOD_BIT(KC_LCTL) | MOD_BIT(KC_LALT) | MOD_BIT(KC_LSFT));
    } else {
      unregister_mods(MOD_BIT(KC_LCTL) | MOD_BIT(KC_LALT) | MOD_BIT(KC_LSFT));
    }
    return false;
  }
  return true;
}
