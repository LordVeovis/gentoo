#include "config.h"
#include "struct.h"
#include "common.h"
#include "sys.h"
#include "numeric.h"
#include "msg.h"
#include "channel.h"
#include <time.h>
#include <sys/stat.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#ifdef _WIN32
#include <io.h>
#endif
#include <fcntl.h>
#include "h.h"
#ifdef STRIPBADWORDS
#include "badwords.h"
#endif
#ifdef _WIN32
#include "version.h"
#endif

#define DelOverride(cmd, ovr)	if (ovr && CommandExists(cmd)) CmdoverrideDel(ovr); ovr = NULL

static int ovr_ircop_only(Cmdoverride *ovr, aClient *cptr, aClient *sptr, int parc, char *parv[]);
static Cmdoverride		*OvrMap, *OvrLinks;

static ModuleInfo	*MyModInfo;

ModuleHeader MOD_HEADER(p_ircoponly)
  = {
	"p_ircoponly",
	"$Id: p_ircoponly.c,v 1.1 2007/06/30 Veovis Exp $",
	"prevents non ircop to user map/links commands",
	"3.2-b8-1",
	NULL 
    };

DLLFUNC int MOD_INIT(p_ircoponly)(ModuleInfo *modinfo)
{
	MyModInfo = modinfo;

	return MOD_SUCCESS;
}

DLLFUNC int MOD_LOAD(p_ircoponly)(int module_load)
{
	OvrMap = CmdoverrideAdd(MyModInfo->handle, "map", ovr_ircop_only);
	OvrLinks = CmdoverrideAdd(MyModInfo->handle, "links", ovr_ircop_only);

	if (!OvrMap || !OvrLinks)
		return MOD_FAILED;

	return MOD_SUCCESS;
}

DLLFUNC int MOD_UNLOAD(p_ircoponly)(int module_unload)
{
	DelOverride("map", OvrMap);
	DelOverride("links", OvrLinks);

	return MOD_SUCCESS;
}

static int ovr_ircop_only(Cmdoverride *ovr, aClient *cptr, aClient *sptr, int parc, char *parv[]) {
	if (IsPerson(sptr) && !IsOper(sptr)) {
		sendto_one(sptr, err_str(ERR_NOPRIVILEGES), me.name, sptr->name);
		return -1;
	}

	return CallCmdoverride(ovr, cptr, sptr, parc, parv);
}
