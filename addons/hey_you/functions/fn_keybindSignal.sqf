/*
 * Author: GoonSix
 * Handles keybind-triggered signals
 * Checks if player is looking at a valid group member and sends the signal
 *
 * Arguments:
 * 0: Signal index in HEYU_signals array <NUMBER>
 *
 * Return Value: None
 *
 * Example:
 * [0] call HEYU_fnc_keybindSignal  // Sends first signal type (Click Tongue)
 */

params [["_signalIndex", 0, [0]]];

// Validate signal index
if (_signalIndex < 0 || _signalIndex >= count HEYU_signals) exitWith {
    diag_log format ["[HEYU] keybindSignal failed: invalid signal index %1", _signalIndex];
};

// Silent fail if the sender is dead or unconscious (ACE hides the menu then,
// but keybinds still fire)
if !([ACE_player] call ace_common_fnc_isAwake) exitWith {};

// Get the object the player is looking at.
// cursorObject is used instead of cursorTarget, which depends on the game's
// target knowledge and can lag behind or stick to a previous target.
private _target = cursorObject;

// Silent fail if no target
if (isNull _target) exitWith {};

// Looking at a vehicle: resolve it to the nearest valid crew member
// (human player in our group, alive, not ourselves) instead of the vehicle.
if !(_target isKindOf "CAManBase") then {
    private _crew = (crew _target) select {
        _x != ACE_player &&
        isPlayer _x &&
        alive _x &&
        group _x == group ACE_player
    };
    _target = objNull;
    if (_crew isNotEqualTo []) then {
        _crew = [_crew, [], {ACE_player distance _x}, "ASCEND"] call BIS_fnc_sortBy;
        _target = _crew select 0;
    };
};

// Silent fail if no valid unit was found
if (isNull _target) exitWith {};

// Silent fail if target is not a player
if (!isPlayer _target) exitWith {};

// Silent fail if target is not in our group
if (group _target != group ACE_player) exitWith {};

// Silent fail if target is too far away
if ((ACE_player distance _target) > HEYU_maxDistance) exitWith {};

// Silent fail if target is the player themselves
if (_target == ACE_player) exitWith {};

// Silent fail if target is dead
if (!alive _target) exitWith {};

// Get signal data
private _signalData = HEYU_signals select _signalIndex;
_signalData params ["_id", "_displayName", "_messageFormat", "_soundPath"];

// Send the signal
[_target, _id] call HEYU_fnc_sendAttention;

if (HEYU_debugMode) then {
    diag_log format ["[HEYU] Keybind signal sent: %1 to %2", _displayName, name _target];
};
