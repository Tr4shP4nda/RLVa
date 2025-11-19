# RLVa Collar Scripts for Second Life

A comprehensive set of RLV collar scripts for Second Life, similar to popular collars like Peanut RLV collars. These scripts work with RLVa-enabled viewers (Firestorm, Catznip, Alchemy, etc.) to provide restraint and control functionality.

## 📦 What's Included

### 1. **rlva_collar.lsl** - Full-Featured Collar
The complete collar solution with all features:
- ✅ Owner and trusted user access control
- ✅ Comprehensive RLV restrictions (detach, sit, TP, IM, chat, touch, inventory, edit, fly)
- ✅ Force commands (stand, sit, teleport)
- ✅ Leash system with automatic following
- ✅ RLV relay support
- ✅ Interactive menu system
- ✅ Lock/unlock functionality
- ✅ Direct RLV command support

### 2. **rlva_collar_lite.lsl** - Simplified Collar
A lightweight version for basic use:
- ✅ Owner-only control
- ✅ Basic restrictions (detach, sit, TP, IM)
- ✅ Simple menu interface
- ✅ Force stand command
- ✅ Quick release all

## 🚀 Installation

### Step 1: Create a Collar Object
1. In Second Life, rez a primitive (cube, sphere, etc.) that will be your collar
2. Edit the object and resize it to fit around your avatar's neck
3. Position it properly on your avatar

### Step 2: Add the Script
1. Right-click the collar object and select **Edit**
2. Go to the **Contents** tab
3. Click **New Script** and delete the default script
4. Open the script you just created
5. Copy the contents of either `rlva_collar.lsl` (full version) or `rlva_collar_lite.lsl` (lite version)
6. Paste it into the script editor in Second Life
7. Click **Save**

### Step 3: Wear the Collar
1. Right-click the collar and select **Wear** or **Add**
2. The collar will attach to your avatar
3. You should see initialization messages in local chat

### Step 4: Verify RLV is Enabled
1. Make sure you're using an RLVa-enabled viewer (Firestorm, Catznip, etc.)
2. Enable RLV in your viewer:
   - **Firestorm**: Preferences → Firestorm → General → Allow Remote Scripted Viewer Controls (RLVa)
   - **Catznip**: Preferences → RLVa → Enable RLVa
3. Touch your collar and select **Settings** → **Check RLV** to verify

## 📖 Usage Guide

### Full Collar (rlva_collar.lsl)

#### Opening the Menu
- **Touch** the collar
- Or say **"menu"** in local chat (if you have access)

#### Main Menu Options

**1. Restrictions**
- Toggle various RLV restrictions on/off
- Available restrictions:
  - **Detach**: Prevent removing attachments
  - **Sit**: Prevent sitting down
  - **Stand**: Prevent standing up
  - **IM**: Block sending instant messages
  - **Chat**: Block sending chat messages
  - **TP**: Block teleporting
  - **Touch**: Prevent touching objects
  - **Inventory**: Hide inventory access
  - **Edit**: Prevent editing/building
  - **Fly**: Prevent flying
- Click any restriction to toggle it on/off
- Click **Clear All** to remove all restrictions

**2. Force**
- Execute force commands on the wearer:
  - **Stand**: Force wearer to stand up immediately
  - **Sit Here**: Force wearer to sit on the user
  - **TP Here**: Teleport wearer to user's location

**3. Leash**
- **Grab Leash**: Take control of the leash
  - Wearer will automatically follow you within 3 meters
  - Move around and the wearer will be pulled to follow
- **Release**: Release the leash

**4. Access** (Owner only)
- **Add Trusted**: Add users who can control the collar
- **Remove Trusted**: Remove trusted users
- **List Trusted**: Show all trusted users

**5. Settings** (Owner only)
- **Lock**: Toggle collar lock (prevents detaching)
- **Relay**: Enable/disable RLV relay functionality
- **Check RLV**: Verify RLV is working

**6. Release All**
- Immediately remove all restrictions and release leash
- Emergency release function

#### Advanced Features

**Direct RLV Commands** (Owner only)
- Say `*<command>` in chat to send direct RLV commands
- Example: `*tpto:128/128/25=force` to teleport to coordinates
- Useful for advanced users who know RLV syntax

**RLV Relay**
- Allows compatible furniture and devices to control the collar
- Uses standard relay protocol on channel -1812221819
- Can be toggled on/off in Settings menu

### Lite Collar (rlva_collar_lite.lsl)

#### Simple Menu
- Touch the collar to open the menu
- Check/uncheck restrictions to toggle them
- ☐ = Off, ☑ = On

#### Available Features
- Toggle Detach restriction
- Toggle Sit restriction
- Toggle TP restriction
- Toggle IM restriction
- Force Stand command
- Release All restrictions
- Check RLV status

## 🔧 Customization

### Changing the Collar Name
Edit the `COLLAR_NAME` variable at the top of the script:
```lsl
string COLLAR_NAME = "Your Custom Name";
```

### Changing Menu Channel
If you experience menu conflicts, change the `MENU_CHANNEL`:
```lsl
integer MENU_CHANNEL = -8675309; // Change to any negative number
```

### Adjusting Leash Distance
In the `UpdateLeash()` function, modify the distance check:
```lsl
if (distance > 3.0) // Change 3.0 to desired meters
```

### Adding Custom Restrictions
You can add your own restrictions by:
1. Defining a new restriction flag: `integer RESTRICT_CUSTOM = 0x400;`
2. Adding apply/remove logic in `ApplyRestriction()` and `RemoveRestriction()`
3. Adding a menu button for it

## 🎯 RLV Command Reference

Here are some useful RLV commands you can use with the `*` prefix:

### Movement
- `unsit=force` - Force stand
- `sit:<uuid>=force` - Force sit on object
- `tpto:<x>/<y>/<z>=force` - Teleport to coordinates

### Restrictions
- `detach=n` - Prevent detaching
- `remoutfit=n` - Prevent removing outfit
- `tplure=n` - Block TP lures
- `sendim=n` - Block IMs
- `sendchat=n` - Block chat

### Camera
- `camzoommin:0.5=force` - Set minimum camera zoom
- `camzoommax:10=force` - Set maximum camera zoom
- `setcam_focus:<uuid>=force` - Force camera focus

### Information
- `versionnew=9999` - Check RLV version
- `getinv=<channel>` - Get inventory list

### Remove Restrictions
- Add `=y` instead of `=n` to remove restrictions
- Example: `detach=y` - Allow detaching again
- `clear` - Remove all restrictions

## 🛡️ Security & Safety

### Built-in Safety Features
- **Owner verification**: Only the collar owner has full control
- **Trusted list**: Limit who can control the collar
- **Release All**: Emergency function to clear all restrictions
- **Auto-reset on transfer**: Collar resets when given to another avatar

### Important Safety Notes
1. **Always test restrictions in a safe environment first**
2. **Know how to use "Release All"** - it's your emergency exit
3. **Trust your access list** - only add people you trust
4. **RLV can be disabled** in your viewer preferences if needed
5. **Relog can clear** some RLV restrictions in emergencies
6. **Safe word**: Consider establishing one with the collar controller

### Removing the Collar
- If unlocked: Right-click → Detach
- If locked: Use "Release All" first, then detach
- Emergency: Disable RLV in viewer preferences, then detach

## 🐛 Troubleshooting

### "RLV commands not working"
- ✅ Verify RLV is enabled in your viewer preferences
- ✅ Touch collar → Settings → Check RLV
- ✅ Restart your viewer if needed
- ✅ Make sure you're using an RLVa-compatible viewer

### "Menu not showing"
- ✅ Check if you have dialog popups blocked
- ✅ Look for the blue dialog box in the top-right corner
- ✅ Click the collar again to re-trigger the menu
- ✅ Try changing the MENU_CHANNEL to a different negative number

### "Leash not working"
- ✅ RLV must be enabled for force teleport
- ✅ Check that you're in a script-enabled area
- ✅ Some regions block force teleport
- ✅ Try using a different force TP method

### "Can't detach collar"
- ✅ Use the "Release All" button first
- ✅ If that doesn't work, disable RLV in viewer preferences
- ✅ Then detach the collar normally
- ✅ As a last resort, clear your cache and relog

### "Script errors on save"
- ✅ Make sure you copied the entire script
- ✅ Check that no characters were corrupted during paste
- ✅ Verify you're using Mono (not LSO) in script properties
- ✅ Make sure the script memory is sufficient

## 📚 Additional Resources

### RLVa Documentation
- [Second Life RLV API Wiki](http://wiki.secondlife.com/wiki/LSL_Protocol/RestrainedLoveAPI)
- [OpenCollar Documentation](https://opencollar.cc/docs/)
- [Firestorm RLVa Guide](https://www.firestormviewer.org/support/rlv/)

### LSL Scripting
- [LSL Portal (Second Life Wiki)](http://wiki.secondlife.com/wiki/LSL_Portal)
- [LSL Scripting Guide](http://wiki.secondlife.com/wiki/Getting_started_with_LSL)

### Viewers with RLVa Support
- [Firestorm Viewer](https://www.firestormviewer.org/) (Most popular)
- [Catznip Viewer](https://catznip.com/)
- [Alchemy Viewer](https://alchemyviewer.org/)

## 📝 Version History

### v1.0 (Initial Release)
- Full-featured collar with all major RLV functions
- Lite version for simplified use
- Complete menu system
- Leash functionality
- Relay support
- Access control system

## 🤝 Contributing

Feel free to modify and improve these scripts! Some ideas for enhancements:
- Add animations for different poses
- Implement a particle leash visual effect
- Add sound effects for locking/unlocking
- Create a matching HUD for remote control
- Add outfit folder management
- Implement safeword functionality

## ⚖️ License

These scripts are provided as-is for use in Second Life. Feel free to modify, distribute, and use them as you see fit.

## ❓ Support

If you encounter issues:
1. Check the Troubleshooting section above
2. Verify your viewer supports RLVa
3. Make sure RLV is enabled in preferences
4. Test with a fresh relog

---

**Enjoy your RLVa collar! Stay safe and have fun in Second Life!** 🎮
