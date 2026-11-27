/*
    Hey You! end-to-end probe for RW_2's tools\test-run.ps1 -Mode probe -Dedicated.

    Runs scheduled on the server. The server checks its own side, then sends one block of code to the test
    player's machine (RWT_tp), which runs every client check and reports each result back to the server RPT
    through RWT_fnc_logServer. Every result line looks like:
        RWT PROBE HEYU TEST: <check> PASS|FAIL|SKIP|INFO <detail>
    and the probe ends with a "HEYU TEST: SUMMARY" line.

    Checks:
      1. LOAD     - addon, functions, signals, stringtable text, CBA settings (values + registration),
                    CfgRemoteExec entry, removed CfgSounds (server and client).
      2. KEYBIND  - CBA keybinds under "Hey You!" default to Ctrl+L / Ctrl+; / Ctrl+' ; old "HeyYou" category gone.
      3. ACE      - "HEYU_GetAttention" self-action in ACE's class data before and after a respawn (forceRespawn),
                    not attached per object; the action's child code runs (General Signal + player list).
      4. SIGNAL   - AI stand-ins: menu lists no AI, sending to AI is refused, AI as sender is dropped.
                    Positive path as a SELF-LOOP stand-in (one real client): the client signals its own unit,
                    which goes through remoteExec and every receiver check; a screenshot is taken.
      5. COOLDOWN - sender cooldown, receiver rate limit, receiver + sender range checks.
                    The receiver's group check needs a second real client (reported as such).

    Notes for the runner:
      - The runner rewrites the word "player" to RWT_tp outside strings/comments, including in the client block.
        The client block therefore never uses it and works with ACE_player (the client's current unit, which also
        follows the respawn), so it stays correct after RWT_tp points at the old body.
      - HEYU_debugMode is switched on on the client, so the mod's own "[HEYU] ..." lines (e.g. "receiveAttention
        dropped: ... rate limited") appear in client.rpt as corroboration.
      - Screenshot: heyu_signal.png in the client's Screenshots folder.
*/

private _log = { diag_log text ("RWT PROBE HEYU TEST: " + _this) };
private _res = {
    params ["_name", "_status", ["_detail", ""]];
    format ["%1 %2 %3", _name, _status, _detail] call _log;
};
private _pf = { if (_this) then {"PASS"} else {"FAIL"} };

format ["INFO multiplayer %1, dedicated %2, test player %3", isMultiplayer, isDedicated, name player] call _log;

// ============================================================ server side
["SERVER addon loaded", isClass (configFile >> "CfgPatches" >> "HEYU_Attention") call _pf] call _res;
private _srvSettings = ["HEYU_maxDistance", "HEYU_3dTextDuration", "HEYU_hintDuration", "HEYU_signalCooldown",
    "HEYU_enable3dText", "HEYU_enableHints", "HEYU_3dTextSize"];
private _srvMissing = _srvSettings select { isNil _x };
["SERVER CBA settings registered (preInit)", (_srvMissing isEqualTo []) call _pf,
    format ["missing %1; maxDistance %2, cooldown %3", _srvMissing,
        missionNamespace getVariable ["HEYU_maxDistance", "nil"], missionNamespace getVariable ["HEYU_signalCooldown", "nil"]]] call _res;
["SERVER client-only init skipped", (isNil "HEYU_signals") call _pf, "HEYU_signals should be nil on a dedicated server"] call _res;
["SERVER receiveAttention compiled", (!isNil "HEYU_fnc_receiveAttention") call _pf] call _res;

// ============================================================ client side
private _client = {
    private _log = {
        private _line = "RWT PROBE HEYU TEST: " + _this;
        [_line] remoteExec ["RWT_fnc_logServer", 2];
        diag_log text ("HEYU CLIENT " + _this);
    };
    private _pass = 0; private _fail = 0;
    private _res = {
        params ["_name", "_status", ["_detail", ""]];
        if (_status == "PASS") then { _pass = _pass + 1 };
        if (_status == "FAIL") then { _fail = _fail + 1 };
        format ["%1 %2 %3", _name, _status, _detail] call _log;
    };
    private _pf = { if (_this) then {"PASS"} else {"FAIL"} };
    private _resetCooldowns = {
        HEYU_lastSignalTime = -1e6;
        ACE_player setVariable ["HEYU_lastReceived", nil];
    };

    "INFO client started" call _log;
    waitUntil { !isNil "HEYU_signals" && {!isNull ACE_player} };
    HEYU_debugMode = true;

    // ---------------------------------------------------- 1. LOAD
    ["LOAD addon", isClass (configFile >> "CfgPatches" >> "HEYU_Attention") call _pf] call _res;

    private _fns = ["HEYU_fnc_init", "HEYU_fnc_initSettings", "HEYU_fnc_sendAttention", "HEYU_fnc_receiveAttention",
        "HEYU_fnc_getGroupActions", "HEYU_fnc_getMessageActions", "HEYU_fnc_keybindSignal"];
    private _missingFns = _fns select { isNil _x };
    ["LOAD functions", (_missingFns isEqualTo []) call _pf, format ["missing %1", _missingFns]] call _res;

    private _sigOk = count HEYU_signals == 3 && {(HEYU_signals findIf { (_x select 1) == "" || {(_x select 2) == ""} }) < 0};
    ["LOAD signals", _sigOk call _pf, str (HEYU_signals apply { [_x select 0, _x select 1] })] call _res;

    private _keys = ["STR_HEYU_Category", "STR_HEYU_GeneralSignal", "STR_HEYU_Signal_Click", "STR_HEYU_Signal_Twig",
        "STR_HEYU_Signal_Lizard", "STR_HEYU_Message_Click", "STR_HEYU_Message_Twig", "STR_HEYU_Message_Lizard",
        "STR_HEYU_TooFar", "STR_HEYU_Key_Click", "STR_HEYU_Key_Twig", "STR_HEYU_Key_Lizard",
        "STR_HEYU_Set_MaxDistance", "STR_HEYU_Set_MaxDistance_Tip", "STR_HEYU_Set_3dTextDuration",
        "STR_HEYU_Set_3dTextDuration_Tip", "STR_HEYU_Set_HintDuration", "STR_HEYU_Set_HintDuration_Tip",
        "STR_HEYU_Set_Enable3dText", "STR_HEYU_Set_Enable3dText_Tip", "STR_HEYU_Set_EnableHints",
        "STR_HEYU_Set_EnableHints_Tip", "STR_HEYU_Set_3dTextSize", "STR_HEYU_Set_3dTextSize_Tip",
        "STR_HEYU_Set_SignalCooldown", "STR_HEYU_Set_SignalCooldown_Tip"];
    private _blank = _keys select { (localize _x) == "" };
    ["LOAD stringtable", (_blank isEqualTo [] && {(localize "STR_HEYU_Category") == "Hey You!"}) call _pf,
        format ["%1 keys, blank %2, category '%3'", count _keys, _blank, localize "STR_HEYU_Category"]] call _res;

    private _expected = [["HEYU_maxDistance", 12], ["HEYU_3dTextDuration", 5], ["HEYU_hintDuration", 10],
        ["HEYU_signalCooldown", 2], ["HEYU_enable3dText", true], ["HEYU_enableHints", true], ["HEYU_3dTextSize", 0.025]];
    private _bad = [];
    {
        _x params ["_var", "_want"];
        private _have = missionNamespace getVariable _var;
        private _ok = if (isNil "_have") then {false} else {
            if (_want isEqualType 0) then { (_have isEqualType 0) && {abs (_have - _want) < 0.0001} } else { _have isEqualTo _want }
        };
        if (!_ok) then { _bad pushBack [_var, if (isNil "_have") then {"nil"} else {_have}] };
    } forEach _expected;
    ["LOAD CBA setting values (defaults)", (_bad isEqualTo []) call _pf, format ["mismatched %1", _bad]] call _res;

    if (isNil "cba_settings_allSettings") then {
        ["LOAD CBA settings registered", "SKIP", "cba_settings_allSettings not found (CBA internals)"] call _res;
    } else {
        private _notReg = (_expected apply { _x select 0 }) select { !(_x in cba_settings_allSettings) && {!((toLower _x) in cba_settings_allSettings)} };
        ["LOAD CBA settings registered", (_notReg isEqualTo []) call _pf, format ["not registered %1", _notReg]] call _res;
    };

    private _rex = configFile >> "CfgRemoteExec" >> "Functions" >> "HEYU_fnc_receiveAttention";
    ["LOAD CfgRemoteExec whitelist", (isClass _rex && {getNumber (_rex >> "allowedTargets") == 0}) call _pf,
        format ["class %1, allowedTargets %2", isClass _rex, getNumber (_rex >> "allowedTargets")]] call _res;
    ["LOAD unused CfgSounds removed", (!isClass (configFile >> "CfgSounds" >> "HEYU_Click")) call _pf] call _res;

    // ---------------------------------------------------- 2. KEYBIND
    {
        _x params ["_id", "_dik", "_label"];
        private _kb = ["Hey You!", _id] call CBA_fnc_getKeybind;
        if (isNil "_kb") then { _kb = [] };
        private _binds = _kb select { _x isEqualType [] && {count _x == 2} && {(_x select 0) isEqualType 0} && {(_x select 1) isEqualType []} };
        private _bind = if (_binds isEqualTo []) then {[]} else {_binds select 0};
        private _ok = _bind isEqualTo [_dik, [false, true, false]];
        [format ["KEYBIND %1 default %2", _id, _label], _ok call _pf,
            format ["found %1 (want [%2,[shift=false,ctrl=true,alt=false]]); entry %3", _bind, _dik, _kb select [0, 3]]] call _res;

        private _old = ["HeyYou", _id] call CBA_fnc_getKeybind;
        [format ["KEYBIND %1 old 'HeyYou' category gone", _id], (isNil "_old" || {_old isEqualTo []}) call _pf] call _res;
    } forEach [["HEYU_Key_Click", 0x26, "Ctrl+L"], ["HEYU_Key_Twig", 0x27, "Ctrl+;"], ["HEYU_Key_Lizard", 0x28, "Ctrl+'"]];

    // ---------------------------------------------------- 3a. ACE (before respawn)
    private _aceState = {
        params ["_unit"];
        private _ns = missionNamespace getVariable "ace_interact_menu_ActSelfNamespace";
        private _tree = [];
        if (!isNil "_ns") then {
            _tree = if (_ns isEqualType createHashMap) then { _ns getOrDefault [typeOf _unit, []] } else { _ns getVariable [typeOf _unit, []] };
        };
        [
            "HEYU_GetAttention" in str _tree,                                                                  // in class tree
            "HEYU_GetAttention" in str (missionNamespace getVariable ["ace_interact_menu_inheritedActionsAll", []]), // inheritance list
            "HEYU_GetAttention" in str (_unit getVariable ["ace_interact_menu_selfActions", []]),              // per-object (old way)
            isNil "_ns"
        ]
    };
    private _before = ACE_player;
    (_before call _aceState) params ["_inClass", "_inInh", "_inObj", "_nsMissing"];
    ["ACE self-action on unit class (before respawn)", (_inClass && !_inObj) call _pf,
        format ["unit %1 class %2: classTree %3, inheritedList %4, perObject %5, nsMissing %6", _before, typeOf _before, _inClass, _inInh, _inObj, _nsMissing]] call _res;

    // ---------------------------------------------------- AI stand-ins
    private _grp = group ACE_player;
    private _ai = _grp createUnit [typeOf ACE_player, ACE_player getPos [3, getDir ACE_player], [], 0, "CAN_COLLIDE"];
    private _grp2 = createGroup [west, true];
    private _ai2 = _grp2 createUnit [typeOf ACE_player, ACE_player getPos [3, (getDir ACE_player) + 90], [], 0, "CAN_COLLIDE"];
    { _x allowDamage false; _x disableAI "MOVE"; _x disableAI "PATH" } forEach [_ai, _ai2];
    sleep 1;
    format ["INFO AI stand-ins: same group %1 (%2), other group %3", _ai, group _ai == _grp, _ai2] call _log;

    // ACE child code: General Signal + player list (AI must not be listed)
    private _acts = [ACE_player, ACE_player, []] call HEYU_fnc_getGroupActions;
    private _ids = _acts apply { (_x select 0) select 0 };
    ["ACE action children: General Signal present", ("HEYU_GeneralSignal" in _ids) call _pf, format ["ids %1", _ids]] call _res;
    ["SIGNAL menu excludes AI teammate", ((_ids findIf { (_x select [0, 12]) == "HEYU_Player_" }) < 0) call _pf,
        "only human players should be listed"] call _res;

    // General Signal statement (menu path, shares the cooldown)
    call _resetCooldowns;
    private _gen = (_acts select (_ids find "HEYU_GeneralSignal")) select 0;
    private _soundActs = [ACE_player, ACE_player, _gen select 6] call (_gen select 5);
    private _first = (_soundActs select 0) select 0;
    [ACE_player, ACE_player, _first select 6] call (_first select 3);
    ["SIGNAL General Signal plays + starts cooldown", (HEYU_lastSignalTime > 0) call _pf,
        format ["%1 sound actions, played %2", count _soundActs, _first select 6]] call _res;

    // ---------------------------------------------------- 4. SIGNAL
    call _resetCooldowns;
    [_ai, "twig"] call HEYU_fnc_sendAttention;
    ["SIGNAL send to AI refused", (HEYU_lastSignalTime == -1e6) call _pf, "no sound, no remoteExec, no cooldown stamp"] call _res;

    call _resetCooldowns;
    private _t0 = HEYU_hintToken;
    [_ai, "click"] call HEYU_fnc_receiveAttention;
    sleep 0.5;
    ["SIGNAL AI as sender dropped by receiver", (HEYU_hintToken == _t0) call _pf, "receiver requires a player sender"] call _res;

    // Positive path (SELF-LOOP stand-in), with a camera facing the unit for the screenshot
    private _cam = "camera" camCreate [0, 0, 0];
    private _eye = ACE_player getPos [4, getDir ACE_player];
    _cam camSetPos [_eye select 0, _eye select 1, ((getPosATL ACE_player) select 2) + 2.2];
    _cam camSetTarget (ACE_player modelToWorld [0, 0, 2.2]);
    _cam cameraEffect ["internal", "back"];
    _cam camCommit 0;
    sleep 1;

    call _resetCooldowns;
    _t0 = HEYU_hintToken;
    [ACE_player, "twig"] call HEYU_fnc_sendAttention;
    private _until = time + 3;
    waitUntil { sleep 0.1; HEYU_hintToken > _t0 || {time > _until} };
    private _msg = format [localize "STR_HEYU_Message_Twig", name ACE_player];
    ["SIGNAL full pipeline (SELF-LOOP stand-in: send -> remoteExec -> receive -> hint)", (HEYU_hintToken == _t0 + 1) call _pf,
        format ["hint token %1 -> %2, message '%3'", _t0, HEYU_hintToken, _msg]] call _res;
    sleep 1;
    screenshot "heyu_signal.png";
    sleep 1;
    _cam cameraEffect ["terminate", "back"];
    camDestroy _cam;
    "INFO screenshot heyu_signal.png requested (hint + 3D text above the unit expected)" call _log;

    // ---------------------------------------------------- 5. COOLDOWN
    sleep 2.5;
    call _resetCooldowns;
    _t0 = HEYU_hintToken;
    private _tSend = time;
    [ACE_player, "click"] call HEYU_fnc_sendAttention;
    sleep 0.3;
    [ACE_player, "click"] call HEYU_fnc_sendAttention;   // inside the 2 s cooldown: must be dropped by the sender
    sleep 1.5;
    private _t1 = HEYU_hintToken;
    ["COOLDOWN sender blocks repeat within cooldown", (_t1 == _t0 + 1) call _pf, format ["token %1 -> %2 after 2 sends", _t0, _t1]] call _res;
    waitUntil { sleep 0.1; time - _tSend > 2.6 };
    [ACE_player, "click"] call HEYU_fnc_sendAttention;   // after the cooldown: must go through
    sleep 1;
    ["COOLDOWN sender allows signal after cooldown", (HEYU_hintToken == _t0 + 2) call _pf, format ["token %1 -> %2", _t0, HEYU_hintToken]] call _res;

    sleep 2.5;
    call _resetCooldowns;
    _t0 = HEYU_hintToken;
    [ACE_player, "lizard"] call HEYU_fnc_receiveAttention;
    [ACE_player, "lizard"] call HEYU_fnc_receiveAttention;   // same sender immediately: receiver rate limit
    sleep 0.5;
    ["COOLDOWN receiver rate-limits a sender", (HEYU_hintToken == _t0 + 1) call _pf, format ["token %1 -> %2 after 2 direct receives", _t0, HEYU_hintToken]] call _res;

    // Range branches: with one client the sender is the receiver (distance 0), so the limit is made negative
    // locally to force the out-of-range branch, then restored.
    private _maxDist = HEYU_maxDistance;
    HEYU_maxDistance = -10;
    call _resetCooldowns;
    _t0 = HEYU_hintToken;
    [ACE_player, "click"] call HEYU_fnc_receiveAttention;
    sleep 0.3;
    ["COOLDOWN receiver drops out-of-range sender (forced via negative limit)", (HEYU_hintToken == _t0) call _pf] call _res;
    call _resetCooldowns;
    [ACE_player, "click"] call HEYU_fnc_sendAttention;
    ["COOLDOWN sender refuses out-of-range target (forced via negative limit)", (HEYU_lastSignalTime == -1e6) call _pf] call _res;
    HEYU_maxDistance = _maxDist;
    hintSilent "";

    call _resetCooldowns;
    _t0 = HEYU_hintToken;
    [_ai2, "click"] call HEYU_fnc_receiveAttention;
    sleep 0.3;
    ["COOLDOWN out-of-group AI sender dropped", (HEYU_hintToken == _t0) call _pf,
        "dropped, but by the player check before the group check; the group check itself needs a second real client"] call _res;

    { deleteVehicle _x } forEach [_ai, _ai2];

    // ---------------------------------------------------- 3b. ACE (after respawn)
    "INFO forcing respawn" call _log;
    forceRespawn _before;
    _until = time + 40;
    waitUntil { sleep 0.5; (ACE_player != _before && {alive ACE_player}) || {time > _until} };
    if (ACE_player == _before) then {
        ["ACE self-action after respawn", "FAIL", "no new unit within 40 s"] call _res;
    } else {
        sleep 2;
        (ACE_player call _aceState) params ["_inClass2", "_inInh2", "_inObj2"];
        ["ACE self-action on unit class (after respawn)", (_inClass2 && !_inObj2) call _pf,
            format ["new unit %1 class %2: classTree %3, inheritedList %4, perObject %5", ACE_player, typeOf ACE_player, _inClass2, _inInh2, _inObj2]] call _res;
        private _acts2 = [ACE_player, ACE_player, []] call HEYU_fnc_getGroupActions;
        ["ACE action children work on respawned unit", (count _acts2 >= 1) call _pf, format ["%1 entries", count _acts2]] call _res;
    };

    format ["SUMMARY client checks: %1 PASS, %2 FAIL", _pass, _fail] call _log;
    missionNamespace setVariable ["HEYU_probeDone", true, 2];
};

missionNamespace setVariable ["HEYU_probeDone", false];
[[], _client] remoteExec ["spawn", player];

private _t = time;
waitUntil { sleep 1; (missionNamespace getVariable ["HEYU_probeDone", false]) || {time - _t > 300} };
if (missionNamespace getVariable ["HEYU_probeDone", false]) then {
    format ["INFO client finished after %1 s", round (time - _t)] call _log;
} else {
    "FAIL no answer from the test player's machine after 300 s" call _log;
};
sleep 3;   // let the last client lines arrive
