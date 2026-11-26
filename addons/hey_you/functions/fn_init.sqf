/*
 * Author: YourName
 * Initializes the Hey You system
 * Adds ACE self-interaction menu, CBA keybinds, and CBA settings
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

// Only run the rest on clients with interface (not dedicated server or headless)
if (!hasInterface) exitWith {};

// ============================================
// DEBUG MODE - Set to false for release!
// ============================================
HEYU_debugMode = false;

// Sound volume (hardcoded, not configurable)
HEYU_soundVolume = 3;

// Cooldown / hint bookkeeping
HEYU_lastSignalTime = -1e6;  // diag_tickTime of this client's last signal
HEYU_hintToken = 0;          // Incremented per hint so stale clear-timers can be ignored

// Available attention signals
// Format: [id, display name, message format, sound file path]
// %1 will be replaced with sender's name
HEYU_signals = [
    ["click", "Click Tongue", "%1 clicks their tongue to get your attention", "\hey_you\sounds\TongueClick2x.ogg"],
    ["twig", "Throw a Twig", "%1 throws a twig at you to get your attention", "\hey_you\sounds\Twig_Crack.ogg"],
    ["lizard", "Lizard Squeak", "%1 makes a lizard squeak sound towards you to get your attention", "\hey_you\sounds\Lizard_Squeak.ogg"]
];

// ============================================
// CBA KEYBINDS SETUP
// ============================================

diag_log "[HEYU] Registering CBA keybinds...";

// Keybind: Tongue Click (Ctrl + L)
[
    "HeyYou",                                    // Addon name (for keybind category)
    "HEYU_Key_Click",                            // Action ID
    "Signal: Tongue Click",                      // Display name
    {
        // Down code - when key is pressed
        [0] call HEYU_fnc_keybindSignal;         // Index 0 = Click Tongue
    },
    {},                                          // Up code (not used)
    [0x26, [false, true, false]]                 // Ctrl + L (CBA modifier order: [shift, ctrl, alt]) (DIK code for L = 0x26)
] call CBA_fnc_addKeybind;

// Keybind: Twig Throw (Ctrl + ;)
[
    "HeyYou",
    "HEYU_Key_Twig",
    "Signal: Throw a Twig",
    {
        [1] call HEYU_fnc_keybindSignal;         // Index 1 = Throw a Twig
    },
    {},
    [0x27, [false, true, false]]                 // Ctrl + ; (DIK code for ; = 0x27)
] call CBA_fnc_addKeybind;

// Keybind: Lizard Squeak (Ctrl + ')
[
    "HeyYou",
    "HEYU_Key_Lizard",
    "Signal: Lizard Squeak",
    {
        [2] call HEYU_fnc_keybindSignal;         // Index 2 = Lizard Squeak
    },
    {},
    [0x28, [false, true, false]]                 // Ctrl + ' (DIK code for ' = 0x28)
] call CBA_fnc_addKeybind;

diag_log "[HEYU] CBA keybinds registered";

// ============================================
// ACE SELF-INTERACTION SETUP
// ============================================

diag_log "[HEYU] Initializing Hey You system...";

// No need to wait for the player: actions are added to the unit class (below),
// so there is nothing to block on during postInit.

// Create main "Hey You!" action - always visible
private _mainAction = [
    "HEYU_GetAttention",                     // Action ID
    "Hey You!",                              // Display name
    "",                                      // Icon (empty = default)
    {},                                      // Statement (nothing - just opens submenu)
    {true},                                  // Always show (General Signal is always available)
    {
        // Children: General Signal + Dynamic list of group members
        call HEYU_fnc_getGroupActions
    },
    [],                                      // Action parameters
    [0, 0, 0],                              // Position offset
    2                                        // Priority
] call ace_interact_menu_fnc_createAction;

// Add to ACE self-interaction menu for every infantry unit class (with inheritance),
// so the action survives respawn, team switch, and Zeus remote control
["CAManBase", 1, ["ACE_SelfActions"], _mainAction, true] call ace_interact_menu_fnc_addActionToClass;

// ============================================
// DEBUG: Self-signal for solo testing
// Only active when HEYU_debugMode = true
// ============================================
if (HEYU_debugMode) then {
    diag_log "[HEYU] DEBUG MODE ENABLED - Remember to disable for release!";
    
    private _debugAction = [
        "HEYU_Debug_Self",
        "[DEBUG] Signal Self",
        "",
        {
            params ["_target", "_player"];
            [_player, "DEBUG: You signaled yourself!"] call HEYU_fnc_receiveAttention;
        },
        {true}
    ] call ace_interact_menu_fnc_createAction;

    ["CAManBase", 1, ["ACE_SelfActions"], _debugAction, true] call ace_interact_menu_fnc_addActionToClass;
};

diag_log "[HEYU] Hey You system initialized successfully";
