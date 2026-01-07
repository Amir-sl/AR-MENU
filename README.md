🌵 AR_Menu: Advanced Journal & Smart Discord Live Status
AR_Menu is a professional, high-performance utility designed specifically for RedDead Redemption 2 (VORP Core). It features an immersive in-game "Journal" menu for players and a robust, self-managing Discord live status system.

✨ Key Features
📖 1. Immersive In-Game Journal
Authentic UI: A clean interface designed to match the Red Dead Redemption aesthetic.

Live Statistics: Instant access to server population and active-duty counts.

Character Identity: Displays the player's full character name and server ID.

Player Directory: Includes a dedicated tab to view all online citizens and their real-time Ping.

📡 2. Smart Discord Live Status (Self-Healing System)
Auto-Edit Logic: The script automatically edits its existing message every minute to keep your Discord channels clean.

Automated ID Management: No manual configuration needed. The script generates and saves its own Message ID automatically.

Startup Resilience: Features "Smart Wait" logic to ensure the server networking and VORP Core are fully stable before syncing.

🚀 Usage & Controls
⌨️ In-Game Hotkey: Press F6 to open/close the Journal menu.

💬 Chat Command: Type /journal in the chat to toggle the menu.

📢 Discord Status: Once the server starts, the script will automatically create and maintain a live status embed in your designated channel.

🛠️ Configuration & Installation
1. Initial Setup
Place the ARMENU folder into your server's resources directory.

Ensure an empty log_id.txt file exists in the resource folder.

Add ensure AR-MENU to your server.cfg.

2. Discord Integration
Open server/server.lua and locate the configuration at the top:

Lua

local DISCORD_WEBHOOK = "YOUR_WEBHOOK_HERE" -- Insert your Webhook URL
🎨 Customization Guide
Discord Title: Open server/server.lua and edit ["title"] = "🌵 SERVER LIVE STATUS 🌵".

In-Game UI: Open html/index.html to rename headers like "Population" or "Law Enforcement".

Keybind: Open client/client.lua if you wish to change the default F6 key.

📦 Requirements
Framework: VORP Core

Platform: RedM (RDR3)

Developed with precision for the RDR3 Roleplay Community. 🤠🔥
