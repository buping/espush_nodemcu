[[
wifi.setmode(wifi.STATION)         --Step1: Connect to Wifi
wifi.sta.config("SSID","Password")

dht = require("dht_lib")           --Step2: "Require" the libs
espush = require("espush")

espush.regist(appid, "app key here", function(msg)  --Step3: Register the callback function
    print("MSG RECV: " .. msg)
end)

-- do something
tmr.alarm(1, 600000, 0, function()
    espush.unregist()
end)

print("ESPUSH status: " .. espush.get_status())
espush.pushmsg("HELLO,PUSH MSG FROM ESPUSH LUA CLIENT")
]]


local moduleName = ...
local M = {}
_G[moduleName] = M


local dns = "0.0.0.0"
local debug = true

local CONN_STATUS = {
    STATUS_CONNECTING = 0,
    STATUS_DNS_LOOKUP = 1,
    STATUS_CONNECTED = 2,
    STATUS_DISCONNECTED = 3
};

local ESP_DBG = function(msg)
    if debug then
        print(msg)
    end
end


local function M:regist(appid, appkey, cbfunc)
    self.appid, self.appkey, self.cbfunc = appid, appkey, cbfunc
    -- check appid, appkey
    -- create tcp connection
    self.sk = net.createConnection(net.TCP, 0)
    -- declare event cbfunc
    self.sk:on("receive", function(sck, c) end)
    self.sk:on("connection", function(sck) end)
    self.sk:on("reconnection", function(sck) end)
    self.sk:on("disconnection", function(sck) end)
    self.sk:on("sent", function(sck) end)
    ESP_DBG(appid .. ' ' .. appkey)
end


local function M:unregist()
    ESP_DBG('unregist')
    self.sk:close()
end


local function M:get_status()
    ESP_DBG("get_status")
    return self.conn_status
end


local function M:build_msg(msg)
    return "HELLO"
end


local function M:pushmsg(msg)
    ESP_DBG("PUSH MSG, " .. msg)
    self.sk:send(self.build_msg(msg))
    return 0
end


return M
