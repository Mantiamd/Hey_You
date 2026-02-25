/*
 * Hey You Mod
 * Author: YourName
 * 
 * Adds ACE self-interaction to silently signal teammates
 * Requires: ACE3, CBA_A3
 */

class CfgPatches {
    class HEYU_Attention {
        name = "Hey You";
        author = "YourName";
        url = "";
        requiredVersion = 2.00;
        requiredAddons[] = {
            "A3_Functions_F",
            "ace_interact_menu",
            "cba_main",
            "cba_keybinding",
            "cba_settings"
        };
        units[] = {};
        weapons[] = {};
    };
};

class CfgSounds {
    class HEYU_Click {
        name = "HEYU_Click";
        sound[] = {"\hey_you\sounds\TongueClick2x.ogg", 1, 1, 10};
        titles[] = {};
    };
    class HEYU_Twig {
        name = "HEYU_Twig";
        sound[] = {"\hey_you\sounds\Twig_Crack.ogg", 1, 1, 10};
        titles[] = {};
    };
    class HEYU_Lizard {
        name = "HEYU_Lizard";
        sound[] = {"\hey_you\sounds\Lizard_Squeak.ogg", 1, 1, 10};
        titles[] = {};
    };
};

class CfgFunctions {
    class HEYU {
        tag = "HEYU";
        
        class Hey_You {
            file = "\hey_you\functions";
            
            // Initialization
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
