/*
 * Author: GoonSix
 * Receives and displays an attention signal
 * Shows 3D text above sender and hint notification
 * Uses CBA settings for duration and text size
 *
 * Arguments:
 * 0: Sender player <OBJECT>
 * 1: Signal id from HEYU_signals, e.g. "twig" <STRING>
 *
 * Return Value: None
 *
 * Example:
 * [senderPlayer, "twig"] call HEYU_fnc_receiveAttention
 *
 * This function is remote-executed by other clients, so it does not trust its
 * arguments: the message is built locally from the signal id, and signals from
 * senders that are out of group, out of range, or too frequent are dropped.
 */

params [
    ["_sender", objNull, [objNull]],
    ["_signalId", "", [""]]
];

// Init has not run yet on this machine (e.g. still loading)
if (isNil "HEYU_signals") exitWith {};

// ============================================
// VALIDATION - silently drop anything invalid
// ============================================

if (isNull _sender || {!alive _sender} || {!isPlayer _sender}) exitWith {
    if (HEYU_debugMode) then {diag_log "[HEYU] receiveAttention dropped: invalid sender"};
};

// Sender must be in our group
if (group _sender != group player) exitWith {
    if (HEYU_debugMode) then {diag_log format ["[HEYU] receiveAttention dropped: %1 not in group", name _sender]};
};

// Sender must be within range (+5m slack for movement during network delay)
if ((player distance _sender) > (HEYU_maxDistance + 5)) exitWith {
    if (HEYU_debugMode) then {diag_log format ["[HEYU] receiveAttention dropped: %1 out of range", name _sender]};
};

// Rate limit per sender (cooldown minus 0.5s slack for network jitter)
private _lastReceived = _sender getVariable ["HEYU_lastReceived", -1e6];
if (diag_tickTime - _lastReceived < (HEYU_signalCooldown - 0.5)) exitWith {
    if (HEYU_debugMode) then {diag_log format ["[HEYU] receiveAttention dropped: %1 rate limited", name _sender]};
};
_sender setVariable ["HEYU_lastReceived", diag_tickTime];  // Local only

// Build the message locally from the signal id
private _signalIndex = HEYU_signals findIf {(_x select 0) == _signalId};
if (_signalIndex < 0) exitWith {
    if (HEYU_debugMode) then {diag_log format ["[HEYU] receiveAttention dropped: unknown signal id %1", _signalId]};
};
(HEYU_signals select _signalIndex) params ["", "", "_messageFormat"];
private _message = format [_messageFormat, name _sender];

if (HEYU_debugMode) then {diag_log format ["[HEYU] Received attention signal from %1: %2", name _sender, _message]};

// ============================================
// 3D TEXT ABOVE SENDER
// Only if HEYU_enable3dText is true (CBA setting)
// ============================================

if (HEYU_enable3dText) then {
    // Uses HEYU_3dTextDuration and HEYU_3dTextSize from CBA settings
    [_sender, _message, HEYU_3dTextDuration, HEYU_3dTextSize] spawn {
        params ["_unit", "_text", "_duration", "_textSize"];
        
        private _startTime = time;
        
        // Add event handler for drawing (runs every frame)
        private _ehId = addMissionEventHandler ["Draw3D", {
            // _thisArgs contains our custom parameters: [_unit, _text, _startTime, _duration, _textSize]
            _thisArgs params ["_unit", "_text", "_startTime", "_duration", "_textSize"];
            
            private _elapsed = time - _startTime;
            
            // Check if duration exceeded or unit is gone
            if (_elapsed >= _duration || isNull _unit || !alive _unit) exitWith {};
            
            // Calculate fade (1.0 -> 0.0 over duration)
            private _alpha = 1 - (_elapsed / _duration);
            
            // Hide the text when the sender is not visible from the camera
            // (walls, terrain, smoke). The hint still shows if enabled.
            private _visibility = [vehicle player, "VIEW", vehicle _unit] checkVisibility [
                AGLToASL (positionCameraToWorld [0, 0, 0]),
                eyePos _unit
            ];
            if (_visibility < 0.1) exitWith {};
            
            // Get position above unit's head. Uses the visual (render-time) position
            // so the text moves smoothly with the unit instead of jittering.
            private _pos = (ASLToAGL getPosASLVisual _unit) vectorAdd [0, 0, 2.2];
            
            // Draw the 3D text
            drawIcon3D [
                "",                     // Texture (empty = text only)
                [1, 1, 0, _alpha],     // Color: yellow with fading alpha
                _pos,                   // World position
                0,                      // Width
                0,                      // Height
                0,                      // Angle
                _text,                  // Text to display
                2,                      // Shadow (0=none, 1=shadow, 2=outline)
                _textSize,              // Text size from CBA settings
                "PuristaLight"          // Font
            ];
        }, [_unit, _text, _startTime, _duration, _textSize]];
        
        // Wait for duration then remove the event handler
        sleep _duration;
        removeMissionEventHandler ["Draw3D", _ehId];
    };
};

// ============================================
// HINT NOTIFICATION
// Only if HEYU_enableHints is true (CBA setting)
// ============================================

if (HEYU_enableHints) then {
    hintSilent _message;  // hintSilent: no UI beep (the mod is meant to be silent)

    // Tag this hint so only the timer for the most recent Hey You hint clears it.
    // An older timer must not wipe a newer hint.
    HEYU_hintToken = HEYU_hintToken + 1;

    // Clear hint after specified duration (uses HEYU_hintDuration from CBA settings)
    [{
        params ["_token"];
        // Skip if a newer Hey You hint replaced ours
        if (_token != HEYU_hintToken) exitWith {};
        hintSilent "";  // Clears the hint silently
    }, [HEYU_hintToken], HEYU_hintDuration] call CBA_fnc_waitAndExecute;
};
