/*
 * Author: GoonSix
 * Registers the Hey You CBA settings.
 * Runs at preInit on every machine (server, clients, headless) via
 * Extended_PreInit_EventHandlers in config.cpp, as CBA requires.
 *
 * Arguments: None
 * Return Value: None
 */

// ============================================
// CBA SETTINGS - Server-synced configuration
// These run on all machines including server
// ============================================

// Max Signal Distance (2-15m, default 12m)
[
    "HEYU_maxDistance",
    "SLIDER",
    [localize "STR_HEYU_Set_MaxDistance", localize "STR_HEYU_Set_MaxDistance_Tip"],
    localize "STR_HEYU_Category",
    [2, 15, 12, 0],
    1,  // 1 = Server setting (synced to clients)
    {}
] call CBA_fnc_addSetting;

// 3D Text Duration (1-15s, default 5s)
[
    "HEYU_3dTextDuration",
    "SLIDER",
    [localize "STR_HEYU_Set_3dTextDuration", localize "STR_HEYU_Set_3dTextDuration_Tip"],
    localize "STR_HEYU_Category",
    [1, 15, 5, 0],
    1,
    {}
] call CBA_fnc_addSetting;

// Hint Duration (1-30s, default 10s)
[
    "HEYU_hintDuration",
    "SLIDER",
    [localize "STR_HEYU_Set_HintDuration", localize "STR_HEYU_Set_HintDuration_Tip"],
    localize "STR_HEYU_Category",
    [1, 30, 10, 0],
    1,
    {}
] call CBA_fnc_addSetting;

// Enable 3D Text (default: true)
[
    "HEYU_enable3dText",
    "CHECKBOX",
    [localize "STR_HEYU_Set_Enable3dText", localize "STR_HEYU_Set_Enable3dText_Tip"],
    localize "STR_HEYU_Category",
    true,
    0,  // 0 = Client setting (each player chooses; admins can still force it)
    {}
] call CBA_fnc_addSetting;

// Enable Hints (default: true)
[
    "HEYU_enableHints",
    "CHECKBOX",
    [localize "STR_HEYU_Set_EnableHints", localize "STR_HEYU_Set_EnableHints_Tip"],
    localize "STR_HEYU_Category",
    true,
    0,
    {}
] call CBA_fnc_addSetting;

// 3D Text Size (0.01-0.05, default 0.025)
[
    "HEYU_3dTextSize",
    "SLIDER",
    [localize "STR_HEYU_Set_3dTextSize", localize "STR_HEYU_Set_3dTextSize_Tip"],
    localize "STR_HEYU_Category",
    [0.01, 0.05, 0.025, 3],
    0,
    {}
] call CBA_fnc_addSetting;

// Signal Cooldown (0-10s, default 2s)
[
    "HEYU_signalCooldown",
    "SLIDER",
    [localize "STR_HEYU_Set_SignalCooldown", localize "STR_HEYU_Set_SignalCooldown_Tip"],
    localize "STR_HEYU_Category",
    [0, 10, 2, 1],
    1,
    {}
] call CBA_fnc_addSetting;
