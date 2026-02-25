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

// Only run the rest on clients with interface (not dedicated server or headless)
if (!hasInterface) exitWith {};

// ============================================
// DEBUG MODE - Set to false for release!
// ============================================
HEYU_debugMode = false;

// Sound volume (hardcoded, not configurable)
HEYU_soundVolume = 3;

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

// Keybind: Tongue Click (Left Ctrl + L)
[
    "HeyYou",                                    // Addon name (for keybind category)
    "HEYU_Key_Click",                            // Action ID
    "Signal: Tongue Click",                      // Display name
    {
        // Down code - when key is pressed
        [0] call HEYU_fnc_keybindSignal;         // Index 0 = Click Tongue
    },
    {},                                          // Up code (not used)
    [0x26, [true, false, false]]                 // L key with Left Ctrl (DIK code for L = 0x26)
] call CBA_fnc_addKeybind;

// Keybind: Twig Throw (Left Ctrl + ;)
[
    "HeyYou",
    "HEYU_Key_Twig",
    "Signal: Throw a Twig",
    {
        [1] call HEYU_fnc_keybindSignal;         // Index 1 = Throw a Twig
    },
    {},
    [0x27, [true, false, false]]                 // ; key with Left Ctrl (DIK code for ; = 0x27)
] call CBA_fnc_addKeybind;

// Keybind: Lizard Squeak (Left Ctrl + ')
[
    "HeyYou",
    "HEYU_Key_Lizard",
    "Signal: Lizard Squeak",
    {
        [2] call HEYU_fnc_keybindSignal;         // Index 2 = Lizard Squeak
    },
    {},
    [0x28, [true, false, false]]                 // ' key with Left Ctrl (DIK code for ' = 0x28)
] call CBA_fnc_addKeybind;

diag_log "[HEYU] CBA keybinds registered";

// ============================================
// ACE SELF-INTERACTION SETUP
// ============================================

diag_log "[HEYU] Initializing Hey You system...";

// Wait for player to be ready
waitUntil {!isNull player && {alive player}};

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

// Add to ACE self-interaction menu
[player, 1, ["ACE_SelfActions"], _mainAction] call ace_interact_menu_fnc_addActionToObject;

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
            [player, "DEBUG: You signaled yourself!"] call HEYU_fnc_receiveAttention;
        },
        {true}
    ] call ace_interact_menu_fnc_createAction;

    [player, 1, ["ACE_SelfActions"], _debugAction] call ace_interact_menu_fnc_addActionToObject;
};

diag_log "[HEYU] Hey You system initialized successfully";
