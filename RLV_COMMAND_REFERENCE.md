# RLV Command Quick Reference

A comprehensive reference for RLV/RLVa commands you can use with the collar's direct command feature (prefix with `*` in chat when wearing the collar).

## 📋 Command Syntax

- **Restriction**: `@command=n` (apply) or `@command=y` (remove)
- **Force**: `@command=force`
- **Query**: `@command=<channel>` (get info)

## 🚫 Restriction Commands

### Movement & Navigation

| Command | Description |
|---------|-------------|
| `@sit=n` | Prevent sitting |
| `@unsit=n` | Prevent standing up |
| `@sittp=n` | Block sit teleports |
| `@tplm=n` | Block landmark teleports |
| `@tploc=n` | Block location teleports |
| `@tplure=n` | Block teleport lures |
| `@tplocal=n` | Block local teleports |
| `@fly=n` | Prevent flying |

### Communication

| Command | Description |
|---------|-------------|
| `@sendchat=n` | Block chat messages |
| `@recvchat=n` | Block receiving chat |
| `@sendim=n` | Block sending IMs |
| `@recvim=n` | Block receiving IMs |
| `@sendchannel:<channel>=n` | Block specific channel |
| `@emote=n` | Block emotes |
| `@chatshout=n` | Block shouting |
| `@chatwhisper=n` | Block whispering |
| `@chatnormal=n` | Block normal chat range |

### Attachments & Inventory

| Command | Description |
|---------|-------------|
| `@detach=n` | Prevent detaching all |
| `@detach:<item>=n` | Prevent detaching specific item |
| `@addattach=n` | Prevent attaching |
| `@remattach=n` | Prevent removing attachments |
| `@addoutfit=n` | Prevent adding outfit items |
| `@remoutfit=n` | Prevent removing outfit items |
| `@defaultwear=n` | Prevent wearing new items |
| `@attach:<folder>=n` | Prevent attaching from folder |

### Inventory Access

| Command | Description |
|---------|-------------|
| `@showinv=n` | Hide inventory window |
| `@viewnote=n` | Prevent viewing notecards |
| `@viewscript=n` | Prevent viewing scripts |
| `@viewtexture=n` | Prevent viewing textures |
| `@edit=n` | Prevent editing objects |
| `@rez=n` | Prevent rezzing objects |

### World Interaction

| Command | Description |
|---------|-------------|
| `@touchall=n` | Prevent touching everything |
| `@touchworld=n` | Prevent touching world objects |
| `@touchattach=n` | Prevent touching attachments |
| `@touchthis=n` | Prevent touching this object |
| `@touchfar=n` | Prevent far touching |
| `@fartouch=n` | Block far touch (>1.5m) |
| `@interact=n` | Block all interaction |
| `@touchme=n` | Block touching self |

### Camera & View

| Command | Description |
|---------|-------------|
| `@camunlock=n` | Lock camera position |
| `@camdrawmin:<dist>=n` | Set min camera distance |
| `@camdrawmax:<dist>=n` | Set max camera distance |
| `@camzoommin:<dist>=n` | Set min zoom distance |
| `@camzoommax:<dist>=n` | Set max zoom distance |
| `@camdrawalphamin:<alpha>=n` | Set min alpha on zoom |
| `@camdrawalphamax:<alpha>=n` | Set max alpha on zoom |
| `@showworldmap=n` | Hide world map |
| `@showminimap=n` | Hide minimap |
| `@showloc=n` | Hide location display |
| `@shownames=n` | Hide name tags |
| `@showhovertext=n` | Hide hover text |

### Building & Creation

| Command | Description |
|---------|-------------|
| `@edit=n` | Prevent editing objects |
| `@editobj=n` | Prevent editing objects |
| `@editworld=n` | Prevent editing world |
| `@rez=n` | Prevent rezzing objects |
| `@build=n` | Prevent building |

## ⚡ Force Commands

### Forced Actions

| Command | Description |
|---------|-------------|
| `@unsit=force` | Force avatar to stand up |
| `@sit:<uuid>=force` | Force sit on object/avatar |
| `@remattach=force` | Force remove all attachments |
| `@detachme=force` | Force detach this object |
| `@detachall=force` | Force detach everything |
| `@detach:<item>=force` | Force detach specific item |

### Forced Teleport

| Command | Description |
|---------|-------------|
| `@tpto:<x>/<y>/<z>=force` | Teleport to coordinates |
| `@tpto:<region>/<x>/<y>/<z>=force` | TP to region coordinates |

### Forced Attachments

| Command | Description |
|---------|-------------|
| `@attach:<folder>=force` | Force attach from folder |
| `@attachover:<folder>=force` | Force attach (replace) |
| `@attachall:<folder>=force` | Attach all from folder |
| `@detachall:<folder>=force` | Detach all from folder |

### Forced Outfit

| Command | Description |
|---------|-------------|
| `@addoutfit:<folder>=force` | Force wear outfit |
| `@remoutfit:<folder>=force` | Force remove outfit |
| `@getoutfit:<channel>=force` | Get current outfit |

## 📊 Query Commands

### Information Queries

| Command | Description |
|---------|-------------|
| `@versionnew=<channel>` | Get RLV version (new format) |
| `@version=<channel>` | Get RLV version (old format) |
| `@versionnum=<channel>` | Get numeric version |
| `@getstatus=<channel>` | Get all active restrictions |
| `@getstatusall=<channel>` | Get all restrictions (verbose) |

### Attachment Queries

| Command | Description |
|---------|-------------|
| `@getattach=<channel>` | List all attachments |
| `@getattach:<point>=<channel>` | Get attachment at point |
| `@getoutfit=<channel>` | List current outfit |

### Position & Environment

| Command | Description |
|---------|-------------|
| `@getgroup=<channel>` | Get active group |
| `@getenv_<param>=<channel>` | Get environment setting |

## 🎯 Camera Control

### Camera Position

| Command | Description |
|---------|-------------|
| `@setcam_origin:<coords>=force` | Set camera origin |
| `@setcam_focus:<uuid>=force` | Set camera focus on object |
| `@setcam_fov:<angle>=force` | Set field of view |

### Camera Movement

| Command | Description |
|---------|-------------|
| `@camavdist:<min>/<max>=force` | Set avatar distance range |
| `@camunlock=force` | Unlock camera |
| `@setcam=force` | Reset camera |

## 🎭 Avatar Customization

### Appearance

| Command | Description |
|---------|-------------|
| `@setenv_<param>:<value>=force` | Set environment parameter |
| `@adjustheight:<value>=force` | Adjust avatar height |

## 📁 Folder & Item Management

### Folder Naming Conventions

RLV uses special folder naming for organization:

- `.()` - Hidden folder
- `~<name>` - Locked folder (can't add/remove)
- `#RLV` - Root RLV folder (usually in Objects)

### Common Folder Structures

```
#RLV/
├── Outfits/
│   ├── Casual
│   ├── Formal
│   └── .locked
├── Restraints/
│   ├── Cuffs
│   └── Collar
└── Accessories/
```

## 🔗 Combined Commands

You can combine multiple commands with commas:

```lsl
@sit=n,unsit=n,fly=n          // Restrict sit, stand, and fly
@tplure=n,tplm=n,tplocal=n   // Block all teleports
@sendchat=n,sendim=n         // Block all communication
```

## 🆓 Removing Restrictions

To remove a restriction, change `=n` to `=y`:

```lsl
@sit=n    // Apply restriction
@sit=y    // Remove restriction
```

To remove all restrictions:

```lsl
@clear    // Clear all RLV restrictions
```

## 💡 Practical Examples

### Lock Collar

```lsl
@detach=n                           // Prevent detaching
@detach:collar=n                    // Prevent detaching collar specifically
```

### Silent Avatar

```lsl
@sendchat=n,sendim=n,emote=n       // Block all communication
```

### Forced Sitting

```lsl
@sit:<uuid>=force                   // Force sit on object
@unsit=n                            // Prevent standing
```

### Teleport Restriction

```lsl
@tplure=n,tplm=n,tplocal=n,tploc=n // Block all TP methods
```

### Camera Lock

```lsl
@camzoommin:3=force                 // Min zoom 3m
@camzoommax:3=force                 // Max zoom 3m (locked distance)
@setcam_focus:<uuid>=force          // Lock focus on object
```

### Inventory Blindness

```lsl
@showinv=n,viewnote=n,viewscript=n,viewtexture=n
```

### Movement Restriction

```lsl
@sit=n,fly=n,tplm=n,tplure=n       // Restrict movement options
```

## 🎮 Using with the Collar

To use these commands with your collar:

1. Say in local chat: `*<command>` (owner only)
2. Example: `*sit=n` to prevent sitting
3. Example: `*unsit=force` to force stand
4. Example: `*clear` to remove all restrictions

## 📱 Testing Commands

Safe commands to test (easily reversible):

```lsl
@showminimap=n    // Hide minimap (harmless)
@fly=n            // Prevent flying
@emote=n          // Block emotes
@chatshout=n      // Block shouting
```

Always test in a safe environment before using in serious play!

## ⚠️ Safety Reminders

1. **@clear** removes all restrictions - memorize this!
2. Test restrictions in private before public use
3. Some regions may block certain RLV commands
4. Relog can clear most restrictions in emergencies
5. Disable RLV in viewer to bypass all restrictions
6. Keep the "Release All" button accessible

## 🔍 Finding RLV Folders

The RLV folder is typically at:
- `#RLV` in your main inventory (Objects folder)
- Some viewers use `.()` for hidden folders
- Check viewer documentation for exact location

---

**Note**: Not all viewers implement all commands. Firestorm has the most complete RLVa implementation.

For the most up-to-date command list, visit:
- http://wiki.secondlife.com/wiki/LSL_Protocol/RestrainedLoveAPI
