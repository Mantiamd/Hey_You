/*
 * Hey You Mod
 * Author: GoonSix
 * 
 * Adds ACE self-interaction to silently signal teammates
 * Requires: ACE3, CBA_A3
 */

class CfgPatches {
    class HEYU_Attention {
        name = "Hey You";
        author = "GoonSix";
        url = "";
        requiredVersion = 2.00;
        requiredAddons[] = {
            "A3_Functions_F",
            "ace_common",
            "ace_interact_menu",
            "cba_main",
            "cba_keybinding",
            "cba_settings"
        };
        units[] = {};
        weapons[] = {};
    };
};

// Register CBA settings at preInit, as CBA requires
class Extended_PreInit_EventHandlers {
    class HEYU_Attention {
        init = "call HEYU_fnc_initSettings";
    };
};

// Whitelist the remote-executed receiver so signals still work when remote
// execution is restricted. Note: a mission that defines its own CfgRemoteExec
// in description.ext overrides this and must whitelist the function itself.
class CfgRemoteExec {
    class Functions {
        class HEYU_fnc_receiveAttention {
            allowedTargets = 0;  // Any machine: 1 (clients only) would block the host of a player-hosted game
            jip = 0;             // Not JIP-persistent
        };
    };
};

class CfgFunctions {
    class HEYU {
        tag = "HEYU";
        
        class Hey_You {
            file = "\hey_you\functions";
            
            // Initialization
            class initSettings {};         // CBA settings (called at preInit via XEH below)
            class init {
                postInit = 1;  // Auto-initialize on mission start
            };
            
            // ACE menu functions
            class getGroupActions {};      // Returns list of group members
            class getMessageActions {};    // Returns list of message options
            
            // Core functions
            class sendAttention {};        // Sends signal to target
            class receiveAttention {};     // Displays notification to receiver
            class keybindSignal {};        // Handles keybind-triggered signals
        };
    };
};
