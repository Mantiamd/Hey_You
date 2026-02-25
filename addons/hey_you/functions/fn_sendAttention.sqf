/*
 * Author: YourName
 * Sends an attention signal to a target player
 * Plays 3D sound at sender's position and sends notification to receiver
 *
 * Arguments:
 * 0: Target player <OBJECT>
 * 1: Message format string <STRING>
 * 2: Sound file path <STRING> (optional)
 *
 * Return Value: None
 *
 * Example:
 * [targetPlayer, "%1 throws a twig at you", "\hey_you\sounds\Twig_Crack.ogg"] call HEYU_fnc_sendAttention
 */

params [
    ["_target", objNull, [objNull]],
    ["_messageFormat", "%1 is trying to get your attention", [""]],
    ["_soundPath", "", [""]]
];

// Validate
if (isNull _target) exitWith {
    diag_log "[HEYU] sendAttention failed: null target";
};

if (!isPlayer _target) exitWith {
    diag_log "[HEYU] sendAttention failed: target is not a player";
};

// Check distance one more time (uses HEYU_maxDistance from CBA settings)
if ((player distance _target) > HEYU_maxDistance) exitWith {
    hint format ["Too far away! Must be within %1m", HEYU_maxDistance];
};

private _senderName = name player;
private _message = format [_messageFormat, _senderName];

diag_log format ["[HEYU] %1 sending attention signal to %2: %3", _senderName, name _target, _message];

// Play 3D sound at sender's position (audible within 50m)
// Uses HEYU_soundVolume from CBA settings, fixed 50m audible range
if (_soundPath != "") then {
    // playSound3D: [sound, source, isInside, position, volume, pitch, maxDistance]
    playSound3D [_soundPath, player, false, getPosASL player, HEYU_soundVolume, 1, 50];
    diag_log format ["[HEYU] Playing sound: %1", _soundPath];
};

// Send notification to the target player
// Pass sender object and message
[player, _message] remoteExec ["HEYU_fnc_receiveAttention", _target];
