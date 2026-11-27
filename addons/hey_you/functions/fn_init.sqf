/*
 * Author: GoonSix
 * Initializes the Hey You system
 * Adds ACE self-interaction menu and CBA keybinds (settings: HEYU_fnc_initSettings)
 *
 * Arguments: None
 * Return Value: None
 */

// Only run on clients with interface (not dedicated server or headless)
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
// %1 will be replaced with sender's name. Text comes from stringtable.xml
HEYU_signals = [
    ["click", localize "STR_HEYU_Signal_Click", localize "STR_HEYU_Message_Click", "\hey_you\sounds\TongueClick2x.ogg"],
    ["twig", localize "STR_HEYU_Signal_Twig", localize "STR_HEYU_Message_Twig", "\hey_you\sounds\Twig_Crack.ogg"],
    ["lizard", localize "STR_HEYU_Signal_Lizard", localize "STR_HEYU_Message_Lizard", "\hey_you\sounds\Lizard_Squeak.ogg"]
];

// ============================================
// CBA KEYBINDS SETUP
// ============================================

// Keybind: Tongue Click (Ctrl + L)
[
    "Hey You!",                                  // Addon name (keybind category). Kept literal, not localized: CBA stores custom binds under it
    "HEYU_Key_Click",                            // Action ID
    localize "STR_HEYU_Key_Click",               // Display name
    {
        // Down code - when key is pressed
        [0] call HEYU_fnc_keybindSignal;         // Index 0 = Click Tongue
    },
    {},                                          // Up code (not used)
    [0x26, [false, true, false]]                 // Ctrl + L (CBA modifier order: [shift, ctrl, alt]) (DIK code for L = 0x26)
] call CBA_fnc_addKeybind;

// Keybind: Twig Throw (Ctrl + ;)
[
    "Hey You!",
    "HEYU_Key_Twig",
    localize "STR_HEYU_Key_Twig",
    {
        [1] call HEYU_fnc_keybindSignal;         // Index 1 = Throw a Twig
    },
    {},
    [0x27, [false, true, false]]                 // Ctrl + ; (DIK code for ; = 0x27)
] call CBA_fnc_addKeybind;

// Keybind: Lizard Squeak (Ctrl + ')
[
    "Hey You!",
    "HEYU_Key_Lizard",
    localize "STR_HEYU_Key_Lizard",
    {
        [2] call HEYU_fnc_keybindSignal;         // Index 2 = Lizard Squeak
    },
    {},
    [0x28, [false, true, false]]                 // Ctrl + ' (DIK code for ' = 0x28)
] call CBA_fnc_addKeybind;

// ============================================
// ACE SELF-INTERACTION SETUP
// ============================================

// No need to wait for the player: actions are added to the unit class (below),
// so there is nothing to block on during postInit.

// Create main "Hey You!" action - always visible
private _mainAction = [
    "HEYU_GetAttention",                     // Action ID
    localize "STR_HEYU_Category",            // Display name
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
            [_player, "click"] call HEYU_fnc_receiveAttention;
        },
        {true}
    ] call ace_interact_menu_fnc_createAction;

    ["CAManBase", 1, ["ACE_SelfActions"], _debugAction, true] call ace_interact_menu_fnc_addActionToClass;
};

diag_log "[HEYU] Hey You system initialized successfully";
