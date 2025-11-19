// ========================================
// RLVa Collar Lite v1.0
// ========================================
// A simplified RLV collar for basic use
// Features: Owner control, basic restrictions, simple menu
// ========================================

string COLLAR_NAME = "RLVa Collar Lite";
integer MENU_CHANNEL = -8675310;

key g_kOwner;
integer g_iMenuHandle;
integer g_iRLVEnabled = FALSE;

// Quick restriction flags
integer g_bRestrictDetach = FALSE;
integer g_bRestrictSit = FALSE;
integer g_bRestrictTP = FALSE;
integer g_bRestrictIM = FALSE;

// Send RLV command
SendRLV(string cmd)
{
    if (g_iRLVEnabled)
    {
        llOwnerSay("@" + cmd);
    }
}

// Check RLV
CheckRLV()
{
    llOwnerSay("@versionnew=9999");
    llSetTimerEvent(2.0);
}

// Show main menu
ShowMenu(key id)
{
    if (id != g_kOwner)
    {
        llInstantMessage(id, "Only the owner can use this collar.");
        return;
    }

    list buttons = [
        (g_bRestrictDetach ? "☑" : "☐") + " Detach",
        (g_bRestrictSit ? "☑" : "☐") + " Sit",
        (g_bRestrictTP ? "☑" : "☐") + " TP",
        (g_bRestrictIM ? "☑" : "☐") + " IM",
        "Force Stand",
        "Release All",
        "Check RLV"
    ];

    string prompt = COLLAR_NAME + "\n";
    prompt += "RLV: " + (g_iRLVEnabled ? "Active" : "Inactive") + "\n";
    prompt += "Toggle restrictions or use force commands:";

    if (g_iMenuHandle) llListenRemove(g_iMenuHandle);
    g_iMenuHandle = llListen(MENU_CHANNEL, "", id, "");
    llDialog(id, prompt, buttons, MENU_CHANNEL);
    llSetTimerEvent(30.0);
}

default
{
    state_entry()
    {
        g_kOwner = llGetOwner();
        llOwnerSay(COLLAR_NAME + " ready. Touch to open menu.");
        CheckRLV();
    }

    touch_start(integer num)
    {
        ShowMenu(llDetectedKey(0));
    }

    listen(integer channel, string name, key id, string msg)
    {
        if (channel == MENU_CHANNEL && id == g_kOwner)
        {
            // Toggle restrictions
            if (llSubStringIndex(msg, "Detach") != -1)
            {
                g_bRestrictDetach = !g_bRestrictDetach;
                SendRLV("detach=" + (g_bRestrictDetach ? "n" : "y"));
            }
            else if (llSubStringIndex(msg, "Sit") != -1)
            {
                g_bRestrictSit = !g_bRestrictSit;
                SendRLV("sit=" + (g_bRestrictSit ? "n" : "y"));
            }
            else if (llSubStringIndex(msg, "TP") != -1)
            {
                g_bRestrictTP = !g_bRestrictTP;
                SendRLV("tplure=" + (g_bRestrictTP ? "n" : "y"));
                SendRLV("tplm=" + (g_bRestrictTP ? "n" : "y"));
            }
            else if (llSubStringIndex(msg, "IM") != -1)
            {
                g_bRestrictIM = !g_bRestrictIM;
                SendRLV("sendim=" + (g_bRestrictIM ? "n" : "y"));
            }
            // Force commands
            else if (msg == "Force Stand")
            {
                SendRLV("unsit=force");
            }
            else if (msg == "Release All")
            {
                SendRLV("clear");
                g_bRestrictDetach = FALSE;
                g_bRestrictSit = FALSE;
                g_bRestrictTP = FALSE;
                g_bRestrictIM = FALSE;
                llOwnerSay("All restrictions released.");
            }
            else if (msg == "Check RLV")
            {
                CheckRLV();
            }

            ShowMenu(id);
        }
    }

    timer()
    {
        if (g_iMenuHandle)
        {
            llListenRemove(g_iMenuHandle);
            g_iMenuHandle = 0;
        }
        llSetTimerEvent(0.0);
    }

    on_rez(integer param)
    {
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
