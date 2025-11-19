// ========================================
// RLVa Collar Script v1.0.0-alpha
// ========================================
// A comprehensive RLV collar similar to Peanut RLV collars
// Features: Owner control, RLV restrictions, force commands,
// leash, relay, and menu system
// ========================================

// ========================================
// CONFIGURATION
// ========================================
string COLLAR_NAME = "RLVa Collar";
string VERSION = "1.0.0-alpha";
integer LISTEN_CHANNEL = 0;        // Public chat channel
integer MENU_CHANNEL = -8675309;    // Random negative channel for menus
integer RELAY_CHANNEL = -1812221819; // Standard RLV relay channel
integer RLV_CHECK_CHANNEL = 9999;   // Channel for RLV version responses

// ========================================
// GLOBAL VARIABLES
// ========================================
key g_kOwner = NULL_KEY;           // Collar owner
list g_lTrusted = [];              // Trusted users list
integer g_iListenHandle = 0;       // Listen handle
integer g_iMenuHandle = 0;         // Menu listen handle
key g_kMenuUser = NULL_KEY;        // Current menu user
integer g_iRLVEnabled = FALSE;     // RLV status
integer g_iRLVCheckHandle = 0;     // RLV check listen handle
integer g_iLocked = FALSE;         // Lock status
integer g_iRelayEnabled = TRUE;    // Relay status
key g_kLeashHolder = NULL_KEY;     // Current leash holder
integer g_iLeashActive = FALSE;    // Leash active status
list g_lNearbyAvatars = [];        // List of nearby avatar keys
list g_lNearbyNames = [];          // List of nearby avatar names
integer g_iAwaitingAccessAdd = FALSE; // Flag for access menu state

// Current restrictions (bitfield)
integer RESTRICT_DETACH = 0x001;
integer RESTRICT_SIT = 0x002;
integer RESTRICT_STAND = 0x004;
integer RESTRICT_IM = 0x008;
integer RESTRICT_CHAT = 0x010;
integer RESTRICT_TP = 0x020;
integer RESTRICT_TOUCH = 0x040;
integer RESTRICT_INV = 0x080;
integer RESTRICT_EDIT = 0x100;
integer RESTRICT_FLY = 0x200;

integer g_iRestrictions = 0;

// ========================================
// RLV COMMAND FUNCTIONS
// ========================================

// Send RLV command to wearer
SendRLV(string command)
{
    if (g_iRLVEnabled)
    {
        llOwnerSay("@" + command);
    }
}

// Check if wearer has RLV enabled
CheckRLV()
{
    // Set up listener for RLV response BEFORE sending command
    if (g_iRLVCheckHandle != 0)
    {
        llListenRemove(g_iRLVCheckHandle);
    }
    g_iRLVCheckHandle = llListen(RLV_CHECK_CHANNEL, "", llGetOwner(), "");

    // Send RLV version query - viewer will respond on RLV_CHECK_CHANNEL if enabled
    llOwnerSay("@versionnew=" + (string)RLV_CHECK_CHANNEL);
}

// Apply restriction
ApplyRestriction(integer restriction)
{
    if (!(g_iRestrictions & restriction))
    {
        g_iRestrictions = g_iRestrictions | restriction;

        if (restriction == RESTRICT_DETACH)
            SendRLV("detach=n");
        else if (restriction == RESTRICT_SIT)
            SendRLV("sit=n");
        else if (restriction == RESTRICT_STAND)
            SendRLV("unsit=n");
        else if (restriction == RESTRICT_IM)
            SendRLV("sendim=n");
        else if (restriction == RESTRICT_CHAT)
            SendRLV("sendchat=n");
        else if (restriction == RESTRICT_TP)
            SendRLV("tplure=n,tplm=n,tplocal=n");
        else if (restriction == RESTRICT_TOUCH)
            SendRLV("touchall=n,touchworld=n");
        else if (restriction == RESTRICT_INV)
            SendRLV("showinv=n,viewnote=n,viewscript=n,viewtexture=n");
        else if (restriction == RESTRICT_EDIT)
            SendRLV("edit=n,rez=n");
        else if (restriction == RESTRICT_FLY)
            SendRLV("fly=n");
    }
}

// Remove restriction
RemoveRestriction(integer restriction)
{
    if (g_iRestrictions & restriction)
    {
        g_iRestrictions = g_iRestrictions & ~restriction;

        if (restriction == RESTRICT_DETACH)
            SendRLV("detach=y");
        else if (restriction == RESTRICT_SIT)
            SendRLV("sit=y");
        else if (restriction == RESTRICT_STAND)
            SendRLV("unsit=y");
        else if (restriction == RESTRICT_IM)
            SendRLV("sendim=y");
        else if (restriction == RESTRICT_CHAT)
            SendRLV("sendchat=y");
        else if (restriction == RESTRICT_TP)
            SendRLV("tplure=y,tplm=y,tplocal=y");
        else if (restriction == RESTRICT_TOUCH)
            SendRLV("touchall=y,touchworld=y");
        else if (restriction == RESTRICT_INV)
            SendRLV("showinv=y,viewnote=y,viewscript=y,viewtexture=y");
        else if (restriction == RESTRICT_EDIT)
            SendRLV("edit=y,rez=y");
        else if (restriction == RESTRICT_FLY)
            SendRLV("fly=y");
    }
}

// Remove all restrictions
RemoveAllRestrictions()
{
    SendRLV("clear");
    g_iRestrictions = 0;
}

// Force commands
ForceStand()
{
    SendRLV("unsit=force");
}

ForceSit(key target)
{
    SendRLV("sit:" + (string)target + "=force");
}

ForceTeleport(vector pos)
{
    SendRLV("tpto:" + (string)pos + "=force");
}

// ========================================
// LEASH FUNCTIONS
// ========================================

StartLeash(key holder)
{
    g_kLeashHolder = holder;
    g_iLeashActive = TRUE;
    llSetTimerEvent(0.5); // Update leash every 0.5 seconds
    llOwnerSay("Leash attached to " + llKey2Name(holder));
}

StopLeash()
{
    g_iLeashActive = FALSE;
    g_kLeashHolder = NULL_KEY;
    llOwnerSay("Leash released");
}

UpdateLeash()
{
    if (!g_iLeashActive || g_kLeashHolder == NULL_KEY) return;

    list details = llGetObjectDetails(g_kLeashHolder, [OBJECT_POS]);
    if (details == [])
    {
        StopLeash();
        return;
    }

    vector targetPos = llList2Vector(details, 0);
    vector myPos = llGetPos();
    float distance = llVecDist(targetPos, myPos);

    // If beyond 3 meters, pull closer
    if (distance > 3.0)
    {
        vector pullPos = targetPos + llVecNorm(myPos - targetPos) * 2.0;
        ForceTeleport(pullPos);
    }
}

// ========================================
// ACCESS CONTROL
// ========================================

integer HasAccess(key id)
{
    if (id == g_kOwner) return TRUE;
    if (llListFindList(g_lTrusted, [id]) != -1) return TRUE;
    return FALSE;
}

integer IsOwner(key id)
{
    return (id == g_kOwner);
}

// ========================================
// MENU SYSTEM
// ========================================

ShowMainMenu(key id)
{
    if (!HasAccess(id))
    {
        llInstantMessage(id, "You do not have access to this collar.");
        return;
    }

    list buttons = [
        "Restrictions",
        "Force",
        "Leash",
        "Access",
        "Settings",
        "Release All"
    ];

    string prompt = COLLAR_NAME + " v" + VERSION + "\n";
    prompt += "Owner: " + llKey2Name(g_kOwner) + "\n";
    prompt += "RLV: " + (string)g_iRLVEnabled + " | Locked: " + (string)g_iLocked + "\n";
    prompt += "Select an option:";

    g_kMenuUser = id;
    if (g_iMenuHandle != 0) llListenRemove(g_iMenuHandle);
    g_iMenuHandle = llListen(MENU_CHANNEL, "", id, "");
    llDialog(id, prompt, buttons, MENU_CHANNEL);
    llSetTimerEvent(30.0); // Menu timeout
}

ShowRestrictionsMenu(key id)
{
    list buttons = [
        "Detach",
        "Sit",
        "Stand",
        "IM",
        "Chat",
        "TP",
        "Touch",
        "Inventory",
        "Edit",
        "Fly",
        "Clear All",
        "« Back"
    ];

    string prompt = "Restrictions Menu\nCurrent: " + GetRestrictionsList();

    g_kMenuUser = id;
    if (g_iMenuHandle != 0) llListenRemove(g_iMenuHandle);
    g_iMenuHandle = llListen(MENU_CHANNEL, "", id, "");
    llDialog(id, prompt, buttons, MENU_CHANNEL);
}

ShowForceMenu(key id)
{
    list buttons = [
        "Stand",
        "Sit Here",
        "TP Here",
        "« Back"
    ];

    string prompt = "Force Commands\nSelect action to force on wearer:";

    g_kMenuUser = id;
    if (g_iMenuHandle != 0) llListenRemove(g_iMenuHandle);
    g_iMenuHandle = llListen(MENU_CHANNEL, "", id, "");
    llDialog(id, prompt, buttons, MENU_CHANNEL);
}

ShowLeashMenu(key id)
{
    list buttons;

    if (g_iLeashActive)
    {
        buttons = ["Release", "« Back"];
    }
    else
    {
        buttons = ["Grab Leash", "« Back"];
    }

	 
    string prompt = "Leash Menu\nStatus: ";
    
	if (g_iLeashActive)
	{
		prompt += "Active";
	} else 
	{
		prompt += "Inactive";
	}

	if (g_iLeashActive)
    {
        prompt += "\nHolder: " + llKey2Name(g_kLeashHolder);
    }

    g_kMenuUser = id;
    if (g_iMenuHandle != 0) llListenRemove(g_iMenuHandle);
    g_iMenuHandle = llListen(MENU_CHANNEL, "", id, "");
    llDialog(id, prompt, buttons, MENU_CHANNEL);
}

ShowAccessMenu(key id)
{
    if (!IsOwner(id))
    {
        llInstantMessage(id, "Only the owner can modify access.");
        return;
    }

    list buttons = [
        "Add Trusted",
        "Remove Trusted",
        "List Trusted",
        "« Back"
    ];

    string prompt = "Access Control\nManage who can control this collar.";

    g_kMenuUser = id;
    if (g_iMenuHandle != 0) llListenRemove(g_iMenuHandle);
    g_iMenuHandle = llListen(MENU_CHANNEL, "", id, "");
    llDialog(id, prompt, buttons, MENU_CHANNEL);
}

ShowNearbyUsersMenu(key id)
{
    if (llGetListLength(g_lNearbyNames) == 0)
    {
        llInstantMessage(id, "No nearby users found within 10 meters.");
        ShowAccessMenu(id);
        return;
    }

    // Build button list from nearby names (max 12 for dialog)
    list buttons = [];
    integer i;
    integer count = llGetListLength(g_lNearbyNames);
    if (count > 11) count = 11; // Leave room for Back button

    for (i = 0; i < count; i++)
    {
        string name = llList2String(g_lNearbyNames, i);
        buttons += [name];
    }
    buttons += ["« Back"];

    string prompt = "Select a user to add to trusted list:\n";
    prompt += "(" + (string)llGetListLength(g_lNearbyNames) + " users found)";

    g_kMenuUser = id;
    if (g_iMenuHandle != 0) llListenRemove(g_iMenuHandle);
    g_iMenuHandle = llListen(MENU_CHANNEL, "", id, "");
    llDialog(id, prompt, buttons, MENU_CHANNEL);
}

ShowSettingsMenu(key id)
{
    if (!IsOwner(id))
    {
        llInstantMessage(id, "Only the owner can modify settings.");
        return;
    }

	string g_iLockedText;
    string g_iRelayEnabledText;
    
    if (g_iLocked)
	{
		g_iLockedText = "ON";
	} else 
	{
		g_iLockedText = "OFF";
	}

	if (g_iRelayEnabled)
	{
		g_iRelayEnabledText = "ON";
	} else 
	{
		g_iRelayEnabledText = "OFF";
	}

    list buttons = [
        "Lock: " + g_iLockedText,
        "Relay: " + g_iRelayEnabledText,
        "Check RLV",
        "« Back"
    ];

    string prompt = "Settings Menu\nConfigure collar settings.";

    g_kMenuUser = id;
    if (g_iMenuHandle != 0) llListenRemove(g_iMenuHandle);
    g_iMenuHandle = llListen(MENU_CHANNEL, "", id, "");
    llDialog(id, prompt, buttons, MENU_CHANNEL);
}

string GetRestrictionsList()
{
    string result = "";
    if (g_iRestrictions & RESTRICT_DETACH) result += "Detach, ";
    if (g_iRestrictions & RESTRICT_SIT) result += "Sit, ";
    if (g_iRestrictions & RESTRICT_STAND) result += "Stand, ";
    if (g_iRestrictions & RESTRICT_IM) result += "IM, ";
    if (g_iRestrictions & RESTRICT_CHAT) result += "Chat, ";
    if (g_iRestrictions & RESTRICT_TP) result += "TP, ";
    if (g_iRestrictions & RESTRICT_TOUCH) result += "Touch, ";
    if (g_iRestrictions & RESTRICT_INV) result += "Inv, ";
    if (g_iRestrictions & RESTRICT_EDIT) result += "Edit, ";
    if (g_iRestrictions & RESTRICT_FLY) result += "Fly, ";

    if (result == "") return "None";
    return llGetSubString(result, 0, -3); // Remove trailing ", "
}

// ========================================
// RELAY FUNCTIONS
// ========================================

HandleRelayCommand(string message, key source)
{
    if (!g_iRelayEnabled) return;

    // Basic relay protocol: object,uuid,command
    list parts = llParseString2List(message, [","], []);
    if (llGetListLength(parts) < 3) return;

    string object = llList2String(parts, 0);
    string uuid = llList2String(parts, 1);
    string command = llList2String(parts, 2);

    // Send relay command
    SendRLV(command);

    // Acknowledge
    llRegionSayTo(source, RELAY_CHANNEL, object + "," + uuid + ",ok");
}

// ========================================
// MAIN SCRIPT
// ========================================

default
{
    state_entry()
    {
        // Initialize
        g_kOwner = llGetOwner();
        llOwnerSay(COLLAR_NAME + " v" + VERSION + " initializing...");

        // Check for RLV
        CheckRLV();

        // Listen on public channel for commands
        if (g_iListenHandle != 0) llListenRemove(g_iListenHandle);
        g_iListenHandle = llListen(LISTEN_CHANNEL, "", NULL_KEY, "");

        // Listen on relay channel
        llListen(RELAY_CHANNEL, "", NULL_KEY, "");

        llOwnerSay("Collar ready. Touch to open menu or say 'menu' in chat.");
        llOwnerSay("Owner: " + llKey2Name(g_kOwner));
    }

    touch_start(integer num_detected)
    {
        key toucher = llDetectedKey(0);

        if (toucher == g_kOwner || HasAccess(toucher))
        {
            ShowMainMenu(toucher);
        }
        else
        {
            llInstantMessage(toucher, "You do not have access to this collar.");
        }
    }

    listen(integer channel, string name, key id, string message)
    {
        if (channel == LISTEN_CHANNEL)
        {
            // Public chat commands
            message = llToLower(llStringTrim(message, STRING_TRIM));

            if (message == "menu" && HasAccess(id))
            {
                ShowMainMenu(id);
            }
            else if (llGetSubString(message, 0, 0) == "*" && IsOwner(id))
            {
                // Direct RLV command from owner
                string cmd = llGetSubString(message, 1, -1);
                SendRLV(cmd);
                llOwnerSay("RLV command sent: @" + cmd);
            }
        }
        else if (channel == RELAY_CHANNEL)
        {
            // Relay commands
            HandleRelayCommand(message, id);
        }
        else if (channel == RLV_CHECK_CHANNEL && id == g_kOwner)
        {
            // RLV version response received - RLV is enabled!
            g_iRLVEnabled = TRUE;
            llOwnerSay("✓ RLV Enabled - Version: " + message);

            // Clean up listener
            if (g_iRLVCheckHandle != 0)
            {
                llListenRemove(g_iRLVCheckHandle);
                g_iRLVCheckHandle = 0;
            }
        }
        else if (channel == MENU_CHANNEL)
        {
            // Menu responses
            if (id != g_kMenuUser) return;

            // Main menu
            if (message == "Restrictions")
            {
                ShowRestrictionsMenu(id);
            }
            else if (message == "Force")
            {
                ShowForceMenu(id);
            }
            else if (message == "Leash")
            {
                ShowLeashMenu(id);
            }
            else if (message == "Access")
            {
                ShowAccessMenu(id);
            }
            else if (message == "Settings")
            {
                ShowSettingsMenu(id);
            }
            else if (message == "Release All")
            {
                RemoveAllRestrictions();
                StopLeash();
                llInstantMessage(id, "All restrictions and leash released.");
                ShowMainMenu(id);
            }
            // Restrictions menu
            else if (message == "Detach")
            {
                if (g_iRestrictions & RESTRICT_DETACH)
                    RemoveRestriction(RESTRICT_DETACH);
                else
                    ApplyRestriction(RESTRICT_DETACH);
                ShowRestrictionsMenu(id);
            }
            else if (message == "Sit")
            {
                if (g_iRestrictions & RESTRICT_SIT)
                    RemoveRestriction(RESTRICT_SIT);
                else
                    ApplyRestriction(RESTRICT_SIT);
                ShowRestrictionsMenu(id);
            }
            else if (message == "Stand")
            {
                if (g_iRestrictions & RESTRICT_STAND)
                    RemoveRestriction(RESTRICT_STAND);
                else
                    ApplyRestriction(RESTRICT_STAND);
                ShowRestrictionsMenu(id);
            }
            else if (message == "IM")
            {
                if (g_iRestrictions & RESTRICT_IM)
                    RemoveRestriction(RESTRICT_IM);
                else
                    ApplyRestriction(RESTRICT_IM);
                ShowRestrictionsMenu(id);
            }
            else if (message == "Chat")
            {
                if (g_iRestrictions & RESTRICT_CHAT)
                    RemoveRestriction(RESTRICT_CHAT);
                else
                    ApplyRestriction(RESTRICT_CHAT);
                ShowRestrictionsMenu(id);
            }
            else if (message == "TP")
            {
                if (g_iRestrictions & RESTRICT_TP)
                    RemoveRestriction(RESTRICT_TP);
                else
                    ApplyRestriction(RESTRICT_TP);
                ShowRestrictionsMenu(id);
            }
            else if (message == "Touch")
            {
                if (g_iRestrictions & RESTRICT_TOUCH)
                    RemoveRestriction(RESTRICT_TOUCH);
                else
                    ApplyRestriction(RESTRICT_TOUCH);
                ShowRestrictionsMenu(id);
            }
            else if (message == "Inventory")
            {
                if (g_iRestrictions & RESTRICT_INV)
                    RemoveRestriction(RESTRICT_INV);
                else
                    ApplyRestriction(RESTRICT_INV);
                ShowRestrictionsMenu(id);
            }
            else if (message == "Edit")
            {
                if (g_iRestrictions & RESTRICT_EDIT)
                    RemoveRestriction(RESTRICT_EDIT);
                else
                    ApplyRestriction(RESTRICT_EDIT);
                ShowRestrictionsMenu(id);
            }
            else if (message == "Fly")
            {
                if (g_iRestrictions & RESTRICT_FLY)
                    RemoveRestriction(RESTRICT_FLY);
                else
                    ApplyRestriction(RESTRICT_FLY);
                ShowRestrictionsMenu(id);
            }
            else if (message == "Clear All")
            {
                RemoveAllRestrictions();
                llInstantMessage(id, "All restrictions cleared.");
                ShowRestrictionsMenu(id);
            }
            // Force menu
            else if (message == "Stand")
            {
                ForceStand();
                llInstantMessage(id, "Forcing wearer to stand.");
                ShowForceMenu(id);
            }
            else if (message == "Sit Here")
            {
                ForceSit(id);
                llInstantMessage(id, "Forcing wearer to sit on you.");
                ShowForceMenu(id);
            }
            else if (message == "TP Here")
            {
                list details = llGetObjectDetails(id, [OBJECT_POS]);
                if (details != [])
                {
                    vector pos = llList2Vector(details, 0);
                    ForceTeleport(pos);
                    llInstantMessage(id, "Teleporting wearer to your location.");
                }
                ShowForceMenu(id);
            }
            // Leash menu
            else if (message == "Grab Leash")
            {
                StartLeash(id);
                llInstantMessage(id, "You have grabbed the leash. Move and the wearer will follow.");
                ShowLeashMenu(id);
            }
            else if (message == "Release")
            {
                if (g_kLeashHolder == id || IsOwner(id))
                {
                    StopLeash();
                    llInstantMessage(id, "Leash released.");
                }
                ShowLeashMenu(id);
            }
            // Access menu
            else if (message == "Add Trusted")
            {
                llInstantMessage(id, "Scanning for nearby users within 10 meters...");
                g_iAwaitingAccessAdd = TRUE;
                g_lNearbyAvatars = [];
                g_lNearbyNames = [];
                llSensor("", NULL_KEY, AGENT, 10.0, PI);
            }
            else if (message == "Remove Trusted")
            {
                if (g_lTrusted == [])
                {
                    llInstantMessage(id, "No trusted users.");
                }
                else
                {
                    // Show list for removal
                    llInstantMessage(id, "Trusted users: " + llList2CSV(g_lTrusted));
                }
                ShowAccessMenu(id);
            }
            else if (message == "List Trusted")
            {
                if (g_lTrusted == [])
                {
                    llInstantMessage(id, "No trusted users.");
                }
                else
                {
                    integer i;
                    for (i = 0; i < llGetListLength(g_lTrusted); i++)
                    {
                        key trusted = llList2Key(g_lTrusted, i);
                        llInstantMessage(id, llKey2Name(trusted));
                    }
                }
                ShowAccessMenu(id);
            }
            // Settings menu
            else if (llGetSubString(message, 0, 4) == "Lock:")
            {
                g_iLocked = !g_iLocked;
                if (g_iLocked)
                {
                    ApplyRestriction(RESTRICT_DETACH);
                    llInstantMessage(id, "Collar locked.");
                }
                else
                {
                    RemoveRestriction(RESTRICT_DETACH);
                    llInstantMessage(id, "Collar unlocked.");
                }
                ShowSettingsMenu(id);
            }
            else if (llGetSubString(message, 0, 5) == "Relay:")
            {
                g_iRelayEnabled = !g_iRelayEnabled;
				if (g_iRelayEnabled)
				{
					llInstantMessage(id, "Relay enabled.");
				} else 
				{
					llInstantMessage(id, "Relay disabled.");
				}
                ShowSettingsMenu(id);
            }
            else if (message == "Check RLV")
            {
                CheckRLV();
                llInstantMessage(id, "Checking RLV status...");
                ShowSettingsMenu(id);
            }
            // Back button
            else if (message == "« Back")
            {
                if (g_iAwaitingAccessAdd)
                {
                    g_iAwaitingAccessAdd = FALSE;
                    ShowAccessMenu(id);
                }
                else
                {
                    ShowMainMenu(id);
                }
            }
            // Check if selecting a user from nearby list
            else if (g_iAwaitingAccessAdd)
            {
                // Check if message matches a nearby user name
                integer idx = llListFindList(g_lNearbyNames, [message]);
                if (idx != -1)
                {
                    key selectedUser = llList2Key(g_lNearbyAvatars, idx);

                    // Check if already trusted
                    if (llListFindList(g_lTrusted, [selectedUser]) != -1)
                    {
                        llInstantMessage(id, llKey2Name(selectedUser) + " is already trusted.");
                    }
                    else if (selectedUser == g_kOwner)
                    {
                        llInstantMessage(id, "The owner always has access.");
                    }
                    else
                    {
                        g_lTrusted += [selectedUser];
                        llInstantMessage(id, "Added " + llKey2Name(selectedUser) + " to trusted list.");
                    }

                    g_iAwaitingAccessAdd = FALSE;
                    ShowAccessMenu(id);
                }
            }
        }
    }

    timer()
    {
        if (g_iLeashActive)
        {
            UpdateLeash();
        }
        else
        {
            // Menu timeout
            if (g_iMenuHandle != 0)
            {
                llListenRemove(g_iMenuHandle);
                g_iMenuHandle = 0;
            }
            llSetTimerEvent(0.0);
        }
    }

    sensor(integer num_detected)
    {
        if (g_iAwaitingAccessAdd)
        {
            // Build lists of nearby avatars (excluding owner)
            integer i;
            for (i = 0; i < num_detected; i++)
            {
                key avatar = llDetectedKey(i);
                if (avatar != g_kOwner)
                {
                    g_lNearbyAvatars += [avatar];
                    g_lNearbyNames += [llDetectedName(i)];
                }
            }

            // Show the menu
            ShowNearbyUsersMenu(g_kMenuUser);
        }
    }

    no_sensor()
    {
        if (g_iAwaitingAccessAdd)
        {
            llInstantMessage(g_kMenuUser, "No nearby users found within 10 meters.");
            g_iAwaitingAccessAdd = FALSE;
            ShowAccessMenu(g_kMenuUser);
        }
    }

    on_rez(integer start_param)
    {
        // Reset on rez to ensure proper owner
        llResetScript();
    }

    changed(integer change)
    {
        if (change & CHANGED_OWNER)
        {
            llResetScript();
        }
    }
}
