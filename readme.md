# Star Platinum 
Multiplayer stand system for Lumber Tycoon 2. One player (the "owner")
controls another account (the "stand") through WebSocket commands.

## Requirements
- Two Roblox accounts (owner + stand)
- An executor with `WebSocket.connect` support (test: `print(WebSocket.connect)`)  

## Setup
1. Get both account UserIds
2. On **both** accounts, paste this in the executor:
   ```lua
   getgenv().Owner = "<owner_userid>" -- put your ID or the ID of the other person.
   getgenv().Stand = "<stand_userid>" 
   loadstring(game:HttpGet("https://raw.githubusercontent.com/Golden-Cheater/LT2-Stand-User/refs/heads/main/Star%20Platinum"))()
   ```
3. Wait for `[Star Platinum]: Paired As owner` (or `stand`).
4. From the **owner** account, send commands