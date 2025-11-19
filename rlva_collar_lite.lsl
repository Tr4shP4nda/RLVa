// ========================================
// RLVa Collar Lite v1.0.0-alpha
// ========================================
// A simplified RLV collar for basic use
// Features: Owner control, basic restrictions, simple menu
// ========================================

string COLLAR_NAME = "RLVa Collar Lite";
integer MENU_CHANNEL = -8675310;
integer RLV_CHECK_CHANNEL = 9998;   // Channel for RLV version responses

key g_kOwner;
integer g_iMenuHandle;
integer g_iRLVEnabled = FALSE;
integer g_iRLVCheckHandle = 0;      // RLV check listen handle
float g_fNextRLVCheck = 0.0;        // Timestamp for next RLV check

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
    // Set up listener for RLV response BEFORE sending command
    if (g_iRLVCheckHandle != 0)
    {
        llListenRemove(g_iRLVCheckHandle);
    }
    g_iRLVCheckHandle = llListen(RLV_CHECK_CHANNEL, "", llGetOwner(), "");

    // Send RLV version query - viewer will respond on RLV_CHECK_CHANNEL if enabled
    llOwnerSay("@versionnew=" + (string)RLV_CHECK_CHANNEL);

    // Schedule next check in 45 seconds
    g_fNextRLVCheck = llGetTime() + 45.0;
}

// Show main menu
ShowMenu(key id)
{
    if (id != g_kOwner)
    {
        llInstantMessage(id, "Only the owner can use this collar.");
        return;
    }

	string g_bRestrictDetachText;
	string g_bRestrictSitText;
	string g_bRestrictTPText;
	string g_bRestrictIMText;

	if (g_bRestrictDetach)
	{
		g_bRestrictDetachText = "☑";
	}else{
		g_bRestrictDetachText = "☐";
	}

	if (g_bRestrictSit)
	{
		g_bRestrictSitText = "☑";
	}else{
		g_bRestrictSitText = "☐";
	}

	if (g_bRestrictTP)
	{
		g_bRestrictTPText = "☑";
	}else{
		g_bRestrictTPText = "☐";
	}

	if (g_bRestrictIM)
	{
		g_bRestrictIMText = "☑";
	}else{
		g_bRestrictIMText = "☐";
	}
    list buttons = [
        g_bRestrictDetachText  + " Detach",
        g_bRestrictSitText  + " Sit",
        g_bRestrictTPText + " TP",
        g_bRestrictIMText + " IM",
        "Force Stand",
        "Release All",
        "Check RLV"
    ];

    string prompt = COLLAR_NAME + "\n";
	if (g_iRLVEnabled)
	{
		prompt += "RLV: Active\n";
	} else {
		prompt += "RLV: Inactive\n";
	}
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

        // Start periodic RLV check
        CheckRLV();
        llSetTimerEvent(1.0); // Timer for periodic checks
    }

    touch_start(integer num)
    {
        ShowMenu(llDetectedKey(0));
    }

    listen(integer channel, string name, key id, string msg)
    {
        if (channel == RLV_CHECK_CHANNEL && id == g_kOwner)
        {
            // RLV version response received - RLV is enabled!
            g_iRLVEnabled = TRUE;
            llOwnerSay("✓ RLV Enabled - Version: " + msg);

            // Clean up listener
            if (g_iRLVCheckHandle != 0)
            {
                llListenRemove(g_iRLVCheckHandle);
                g_iRLVCheckHandle = 0;
            }
        }
        else if (channel == MENU_CHANNEL && id == g_kOwner)
        {
            // Toggle restrictions
            if (llSubStringIndex(msg, "Detach") != -1)
            {
                g_bRestrictDetach = !g_bRestrictDetach;
				if (g_bRestrictDetach)
				{
					SendRLV("detach=n");
				} else {
					SendRLV("detach=y");
				}
            }
            else if (llSubStringIndex(msg, "Sit") != -1)
            {
                g_bRestrictSit = !g_bRestrictSit;
				if (g_bRestrictSit)
				{
					SendRLV("sit=n");
				} else {
					SendRLV("sit=y");
				}
            }
            else if (llSubStringIndex(msg, "TP") != -1)
            {
                g_bRestrictTP = !g_bRestrictTP;
				if (g_bRestrictTP)
				{
					SendRLV("tplure=n");
				} else {
					SendRLV("tplure=y");
				}

				if (g_bRestrictTP)
				{
					SendRLV("tplm=n");
				} else {
					SendRLV("tplm=y");
				}
            }
            else if (llSubStringIndex(msg, "IM") != -1)
            {
                g_bRestrictIM = !g_bRestrictIM;
				if (g_bRestrictIM)
				{
					SendRLV("sendim=n");
				} else {
					SendRLV("sendim=y");
				}
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
        // Check if it's time for periodic RLV check
        if (llGetTime() >= g_fNextRLVCheck)
        {
            CheckRLV();
        }

        // Menu timeout
        if (g_iMenuHandle)
        {
            llListenRemove(g_iMenuHandle);
            g_iMenuHandle = 0;
        }

        // Keep timer running for periodic RLV checks
        llSetTimerEvent(1.0);
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
