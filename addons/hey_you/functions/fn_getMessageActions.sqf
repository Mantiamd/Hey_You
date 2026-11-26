/*
 * Author: YourName
 * Returns ACE actions for each signal type (twig, click, lizard)
 * Called when selecting a specific player
 *
 * Arguments:
 * 0: Target unit to signal <OBJECT>
 *
 * Return Value: Array of ACE actions
 */

params [["_targetUnit", objNull, [objNull]]];

private _actions = [];

// Validate target
if (isNull _targetUnit) exitWith {_actions};

// Create an action for each signal type
{
    _x params ["_id", "_displayName", "_messageFormat", "_soundPath"];
    
    private _actionId = format ["HEYU_Signal_%1", _id];
    
    // Create the statement code - target unit and signal id are passed via the params array
    private _statement = {
        params ["_target", "_player", "_params"];
        _params params ["_signalTarget", "_signalId"];
        [_signalTarget, _signalId] call HEYU_fnc_sendAttention;
    };
    
    private _action = [
        _actionId,
        _displayName,
        "",
        _statement,
        {true},
        {},
        [_targetUnit, _id]  // Pass target and signal id as params
    ] call ace_interact_menu_fnc_createAction;
    
    _actions pushBack [_action, [], _targetUnit];
} forEach HEYU_signals;

_actions
