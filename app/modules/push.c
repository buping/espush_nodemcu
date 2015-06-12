#include "push.h"
#include "lualib.h"
#include "lauxlib.h"
#include "auxmods.h"
#include "lrotable.h"

#include <c_types.h>
#include <osapi.h>

/*
 * push.regist(appid, appkey, function(msg));
 * push.unregist();
 * push.get_status();
 * push.pushmsg(msg);
 *
 */


static int push_data_recved = LUA_NOREF;
static lua_State* gL = NULL;

void msg_recv(uint8* pdata, uint32 len)
{
	if(push_data_recved == LUA_NOREF) {
		return;
	}

	lua_rawgeti(gL, LUA_REGISTRYINDEX, push_data_recved);

	lua_pushlstring(gL, (const char*)pdata, len);
	lua_call(gL, 1, 0);
}


static int regist(lua_State* L)
{
	uint32 appid = luaL_checkinteger(L, 1);
	const char* appkey = luaL_checkstring(L, 2);
	if(!appkey || os_strlen(appkey) != 32) {
		return luaL_error(L, "appkey arguments error");
	}

	if(push_server_connect_status() == STATUS_CONNECTED) {
		return luaL_error(L, "connected.");
	}

	gL = L;
	if (lua_type(L, 3) == LUA_TFUNCTION || lua_type(L, 3) == LUA_TLIGHTFUNCTION) {
		lua_pushvalue(L, 3);
		if(push_data_recved != LUA_NOREF) {
			luaL_unref(L, LUA_REGISTRYINDEX, push_data_recved);
		}

		push_data_recved = luaL_ref(L, LUA_REGISTRYINDEX);
	}

	push_register(appid, (char*)appkey, msg_recv);

	lua_pushinteger(L, 0);
	return 1;
}


static int unregist(lua_State* L)
{
	push_unregister();
	return 0;
}


static int get_status(lua_State* L)
{
	lua_pushinteger(L, push_server_connect_status());
	return 1;
}


static int pushmsg(lua_State* L)
{
	size_t msg_length = 0;
	const char* msg = luaL_checklstring(L, 1, &msg_length);
	sint8 iRet = push_msg((uint8*)msg, msg_length);

	lua_pushinteger(L, iRet);
	return 1;
}


#define MIN_OPT_LEVEL 2
#include "lrodefs.h"


const LUA_REG_TYPE push_map[] = {
	{LSTRKEY("regist"), LFUNCVAL(regist)},
	{LSTRKEY("unregist"), LFUNCVAL(unregist)},
	{LSTRKEY("get_status"), LFUNCVAL(get_status)},
	{LSTRKEY("pushmsg"), LFUNCVAL(pushmsg)},

	{LSTRKEY("CONNECTING"), LNUMVAL(STATUS_CONNECTING)},
	{LSTRKEY("DNS_LOOKUP"), LNUMVAL(STATUS_DNS_LOOKUP)},
	{LSTRKEY("CONNECTED"), LNUMVAL(STATUS_CONNECTED)},
	{LSTRKEY("DISCONNECTED"), LNUMVAL(STATUS_DISCONNECTED)},

	{LSTRKEY("__metatable"), LROVAL(push_map)},
	{ LNILKEY, LNILVAL }
};


LUALIB_API int luaopen_push( lua_State *L )
{
	return 0;
}

/*
 * TODO:
 * [√] 加入常量
 * [√] 加入错误判断，加入重复regist的判断
 */
