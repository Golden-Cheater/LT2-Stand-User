local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local WS_URL = "ws://node19.botkeep.cloud:61476/ws"
local OWNER = getgenv().Owner
local STAND = getgenv().Stand
local MY_ID = tostring(Players.LocalPlayer.UserId)

if not OWNER or not STAND then
    return warn("[stand] set getgenv().Owner and getgenv().Stand first")
end

local role = (MY_ID == tostring(OWNER) and "owner")
          or (MY_ID == tostring(STAND) and "stand")
          or nil

if not role then
    return warn("[stand] your UserId does not match Owner or Stand")
end

local api = { paired = false, role = role }
local active = true

local function handleCommand(cmd, ...)
    print("[stand] cmd:", cmd, ...)
    if cmd == "Ping" then
        getgenv().StandAPI.send_result({ pong = true, at = os.clock() })
    end
end

local ok, ws = pcall(WebSocket.connect, WS_URL)
if not ok then
    return warn("[stand] failed to connect:", ws)
end

local function send(tbl)
    pcall(function() ws:Send(HttpService:JSONEncode(tbl)) end)
end

ws.OnMessage:Connect(function(raw)
    local ok, msg = pcall(HttpService.JSONDecode, HttpService, raw)
    if not ok or type(msg) ~= "table" then return end

    if msg.type == "paired" then
        api.paired = true
        print("[stand] paired as", role)

    elseif msg.type == "rejected" then
        warn("[stand] rejected:", msg.reason)
        pcall(function() ws:Close() end)

    elseif msg.type == "cmd" and role == "stand" then
        local arg = msg.argument
        handleCommand(arg[1], table.unpack(arg, 2))

    elseif msg.type == "result" and role == "owner" then
        print("[stand] result:", msg.data)
    end
end)

ws.OnClose:Connect(function()
    active = false
    api.paired = false
    warn("[stand] disconnected")
end)

send({
    type = "join",
    owner = tostring(OWNER),
    stand = tostring(STAND),
    role = role,
    userid = MY_ID,
})

task.spawn(function()
    while active do
        task.wait(20)
        if active then send({ type = "ping" }) end
    end
end)

getgenv().StandAPI = {
    is_paired = function() return api.paired end,
    send_command = function(...)
        if role ~= "owner" then return warn("only the owner can send commands") end
        if not api.paired then return warn("not paired yet") end
        send({ type = "cmd", argument = { ... } })
    end,
    send_result = function(data)
        if role ~= "stand" then return end
        send({ type = "result", data = data })
    end,
    disconnect = function() pcall(function() ws:Close() end) end,
}