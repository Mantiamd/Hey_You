/*
 * Author: YourName
 * Receives and displays an attention signal
 * Shows 3D text above sender and hint notification
 * Uses CBA settings for duration and text size
 *
 * Arguments:
 * 0: Sender player <OBJECT>
 * 1: Message to display <STRING>
 *
 * Return Value: None
 *
 * Example:
 * [senderPlayer, "PlayerName throws a twig at you"] call HEYU_fnc_receiveAttention
 */

params [
    ["_sender", objNull, [objNull]],
    ["_message", "", [""]]
];

// Validate
if (isNull _sender) exitWith {
    diag_log "[HEYU] receiveAttention failed: null sender";
};

diag_log format ["[HEYU] Received attention signal from %1: %2", name _sender, _message];

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
            
            // Get position above unit's head
            private _pos = (ASLToAGL getPosASL _unit) vectorAdd [0, 0, 2.2];
            
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
    hint _message;
    
    // Clear hint after specified duration (uses HEYU_hintDuration from CBA settings)
    [HEYU_hintDuration] spawn {
        params ["_delay"];
        sleep _delay;
        hintSilent "";  // Clears the hint silently
    };
};
