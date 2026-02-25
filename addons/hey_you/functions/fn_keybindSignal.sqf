/*
 * Author: YourName
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

// Get the target the player is looking at
private _target = cursorTarget;

// Silent fail if no target
if (isNull _target) exitWith {};

// Silent fail if target is not a player
if (!isPlayer _target) exitWith {};

// Silent fail if target is not in our group
if (group _target != group player) exitWith {};

// Silent fail if target is too far away
if ((player distance _target) > HEYU_maxDistance) exitWith {};

// Silent fail if target is the player themselves
if (_target == player) exitWith {};

// Silent fail if target is dead
if (!alive _target) exitWith {};

// Get signal data
private _signalData = HEYU_signals select _signalIndex;
_signalData params ["_id", "_displayName", "_messageFormat", "_soundPath"];

// Send the signal
[_target, _messageFormat, _soundPath] call HEYU_fnc_sendAttention;

diag_log format ["[HEYU] Keybind signal sent: %1 to %2", _displayName, name _target];
