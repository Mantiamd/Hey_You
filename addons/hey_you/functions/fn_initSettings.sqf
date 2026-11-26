/*
 * Author: YourName
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
    ["Max Signal Distance", "Maximum distance in meters to signal a teammate (Min: 2m, Max: 15m)"],
    "Hey You!",
    [2, 15, 12, 0],
    1,  // 1 = Server setting (synced to clients)
    {}
] call CBA_fnc_addSetting;

// 3D Text Duration (1-15s, default 5s)
[
    "HEYU_3dTextDuration",
    "SLIDER",
    ["3D Text Duration", "How long the floating text stays above the sender in seconds (Min: 1s, Max: 15s)"],
    "Hey You!",
    [1, 15, 5, 0],
    1,
    {}
] call CBA_fnc_addSetting;

// Hint Duration (1-30s, default 10s)
[
    "HEYU_hintDuration",
    "SLIDER",
    ["Hint Duration", "How long the hint notification stays on screen in seconds (Min: 1s, Max: 30s)"],
    "Hey You!",
    [1, 30, 10, 0],
    1,
    {}
] call CBA_fnc_addSetting;

// Enable 3D Text (default: true)
[
    "HEYU_enable3dText",
    "CHECKBOX",
    ["Enable 3D Text", "Show floating text above the sender's head"],
    "Hey You!",
    true,
    1,
    {}
] call CBA_fnc_addSetting;

// Enable Hints (default: true)
[
    "HEYU_enableHints",
    "CHECKBOX",
    ["Enable Hints", "Show hint notification at bottom of screen"],
    "Hey You!",
    true,
    1,
    {}
] call CBA_fnc_addSetting;

// 3D Text Size (0.01-0.05, default 0.025)
[
    "HEYU_3dTextSize",
    "SLIDER",
    ["3D Text Size", "Size of the floating text above sender (Min: 0.01, Max: 0.05)"],
    "Hey You!",
    [0.01, 0.05, 0.025, 3],
    1,
    {}
] call CBA_fnc_addSetting;

// Signal Cooldown (0-10s, default 2s)
[
    "HEYU_signalCooldown",
    "SLIDER",
    ["Signal Cooldown", "Minimum time in seconds between signals from the same player (Min: 0s, Max: 10s)"],
    "Hey You!",
    [0, 10, 2, 1],
    1,
    {}
] call CBA_fnc_addSetting;
