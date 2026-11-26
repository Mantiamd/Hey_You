/*
 * Author: YourName
 * Sends an attention signal to a target player
 * Plays 3D sound at sender's position and sends the signal id to the receiver.
 * The receiver builds the message text itself (see HEYU_fnc_receiveAttention),
 * so no free-form text is sent over the network.
 *
 * Arguments:
 * 0: Target player <OBJECT>
 * 1: Signal id from HEYU_signals, e.g. "twig" <STRING>
 *
 * Return Value: None
 *
 * Example:
 * [targetPlayer, "twig"] call HEYU_fnc_sendAttention
 */

params [
    ["_target", objNull, [objNull]],
    ["_signalId", "", [""]]
];

// Validate
if (isNull _target) exitWith {
    diag_log "[HEYU] sendAttention failed: null target";
};

if (!isPlayer _target) exitWith {
    diag_log "[HEYU] sendAttention failed: target is not a player";
};

private _signalIndex = HEYU_signals findIf {(_x select 0) == _signalId};
if (_signalIndex < 0) exitWith {
    diag_log format ["[HEYU] sendAttention failed: unknown signal id %1", _signalId];
};
(HEYU_signals select _signalIndex) params ["", "", "", "_soundPath"];

// Check distance one more time (uses HEYU_maxDistance from CBA settings)
if ((ACE_player distance _target) > HEYU_maxDistance) exitWith {
    hintSilent format ["Too far away! Must be within %1m", HEYU_maxDistance];
};

// Cooldown - silently ignore signals sent too quickly (HEYU_signalCooldown CBA setting)
if (diag_tickTime - HEYU_lastSignalTime < HEYU_signalCooldown) exitWith {};
HEYU_lastSignalTime = diag_tickTime;

diag_log format ["[HEYU] %1 sending attention signal '%2' to %3", name ACE_player, _signalId, name _target];

// Play 3D sound at sender's position (audible within 50m)
// Uses hardcoded HEYU_soundVolume, fixed 50m audible range
if (_soundPath != "") then {
    // playSound3D: [sound, source, isInside, position, volume, pitch, maxDistance]
    playSound3D [_soundPath, ACE_player, false, getPosASL ACE_player, HEYU_soundVolume, 1, 50];
    diag_log format ["[HEYU] Playing sound: %1", _soundPath];
};

// Send notification to the target player: sender object + signal id only
[ACE_player, _signalId] remoteExec ["HEYU_fnc_receiveAttention", _target];
