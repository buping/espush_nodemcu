#include "push.h"
#include "lualib.h"
#include "lauxlib.h"
#include "auxmods.h"
#include "lrotable.h"

#include <osapi.h>

/*
 * push.regist(appid, appkey, function(msg));
 * push.unregist();
 * push.get_status();
 * push.pushmsg(msg);
 *
 */

static int push_regist( lua_State* L )
{
	return 0;
}

#define MIN_OPT_LEVEL 2
#include "lrodefs.h"


const LUA_REG_TYPE push_map[] = {
    {LSTRKEY("regist"), LFUNCVAL(push_regist)},
	{ LNILKEY, LNILVAL }
};


LUALIB_API int luaopen_push( lua_State *L )
{
	os_printf("OK\n");
	return 0;
}
