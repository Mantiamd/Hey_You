/*
 * Author: YourName
 * Returns dynamic ACE actions for "Hey You!" submenu
 * Includes "General Signal" (sound only) and list of nearby players
 *
 * Arguments (passed by ACE):
 * 0: Target (the object the action is attached to) <OBJECT>
 * 1: Player <OBJECT>
 * 2: Action parameters <ANY>
 *
 * Return Value: Array of ACE actions
 */

params ["_target", "_player", "_params"];

private _actions = [];

// ============================================
// GENERAL SIGNAL - Sound only, no target
// ============================================

// Create "General Signal" submenu with sound options
private _generalSignalAction = [
    "HEYU_GeneralSignal",
    "General Signal",
    "",
    {},
    {true},
    {
        // Children: Sound options (no target, just plays sound)
        params ["_target", "_player", "_params"];
        
        private _soundActions = [];
        
        {
            _x params ["_id", "_displayName", "_messageFormat", "_soundPath"];
            
            private _actionId = format ["HEYU_General_%1", _id];
            private _sndPath = _soundPath;
            
            private _statement = {
                params ["_target", "_player", "_params"];
                private _sound = _params;
                // Play 3D sound at player's position (no text notification)
                // Uses HEYU_soundVolume from CBA settings, fixed 50m audible range
                playSound3D [_sound, _player, false, getPosASL _player, HEYU_soundVolume, 1, 50];
                diag_log format ["[HEYU] Playing general signal sound: %1", _sound];
            };
            
            private _action = [
                _actionId,
                _displayName,
                "",
                _statement,
                {true},
                {},
                _sndPath
            ] call ace_interact_menu_fnc_createAction;
            
            _soundActions pushBack [_action, [], _player];
        } forEach HEYU_signals;
        
        _soundActions
    },
    []
] call ace_interact_menu_fnc_createAction;

_actions pushBack [_generalSignalAction, [], _player];

// ============================================
// PLAYER LIST - Targeted signals with notification
// ============================================

// Get all human players in group within range (AI filtered out)
// Uses HEYU_maxDistance from CBA settings
private _nearbyUnits = (units group _player) select {
    _x != _player && 
    isPlayer _x &&
    alive _x && 
    (_player distance _x) <= HEYU_maxDistance
};

// Build actions for each nearby player
{
    private _unit = _x;
    private _unitName = name _unit;
    private _dist = round (_player distance _unit);
    
    // Build strings using format (more reliable than concatenation)
    private _actionId = format ["HEYU_Player_%1", _forEachIndex];
    private _displayText = format ["%1 (%2m)", _unitName, _dist];
    
    // Create child action - statement is empty, children will be the message options
    private _childStatement = {};
    private _childCondition = {true};
    private _childInsertChildren = {
        params ["_target", "_player", "_params"];
        _params call HEYU_fnc_getMessageActions
    };
    
    private _action = [
        _actionId,
        _displayText,
        "",
        _childStatement,
        _childCondition,
        _childInsertChildren,
        _unit  // Pass the unit as params so getMessageActions receives it
    ] call ace_interact_menu_fnc_createAction;
    
    _actions pushBack [_action, [], _player];
} forEach _nearbyUnits;

_actions
