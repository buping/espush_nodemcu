-- NodeMCU websocket client for espush
local moduleName = ...
local M = {}
_G[moduleName] = M


local gl_timer = 0
local gl_host = 'ota.espush.cn'
local debug = true

local CONN_STATUS = {
    STATUS_CONNECTING = 0,
    STATUS_DNS_LOOKUP = 1,
    STATUS_CONNECTED = 2,
    STATUS_DISCONNECTED = 3,
    STATUS_HANDSHAKE = 4
};

local function ESP_DBG(msg)
    if debug then
        print(msg)
    end
end


local function conn_to_cloud(self, host)
    ESP_DBG("CONN TO CLOUD")
end


local function regist(self, appid, appkey, cbfunc)
    self.appid, self.appkey, self.cbfunc = appid, appkey, cbfunc
    self.conn_status = CONN_STATUS.STATUS_DISCONNECTED
    self.buf = ''
    -- check appid, appkey
    -- prepare dns check.
    tmr.alarm(gl_timer, 1000, 1, function()
        if(wifi.getmode() == wifi.STATION) then
            ESP_DBG("station mode, dns.")
            self.conn_to_cloud(gl_host)
        end
    end)
    -- create tcp connection
    self.sk = net.createConnection(net.TCP, 0)
    -- declare event cbfunc, data receive
    self.sk:on("receive", function(sck, c)
        -- save data to buffer
        self.buf = self.buf + c
        -- if conn status == handshake , parse handshake string
        -- if conn status == connected, parse websocket string
    end)
    
    -- connected
    self.sk:on("connection", function(sck)
        -- sending http handshake
        -- set constatus handshake
    end)
    
    --reconnection
    self.sk:on("reconnection", function(sck)
        -- set conn_status disconnected
        -- setting re connection
    end)
    
    --disconnection
    self.sk:on("disconnection", function(sck)
        -- set conn_status disconnected
        -- setting re connection
    end)
    
    --data sent
    self.sk:on("sent", function(sck)
        ESP_DBG("data sent.")
    end)
    ESP_DBG(appid .. ' ' .. appkey)
end


local function unregist(self)
    ESP_DBG('unregist')
    self.sk:close()
end


local function get_status(self)
    ESP_DBG("get_status")
    return self.conn_status
end


local function build_msg(self, msg)
    return "HELLO"
end


local function pushmsg(self, msg)
    ESP_DBG("PUSH MSG, " .. msg)
    if self.conn_status == STATUS_CONNECTED then
        self.sk:send(self.build_msg(msg))
        return 0
    end
    
    return 1
end


return M
