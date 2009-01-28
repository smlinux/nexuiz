FTEQCC ?= fteqcc
PERL ?= perl
PK3NAME ?= `date +../data%Y%m%d.pk3`
ZIP ?= 7za a -tzip -mx=9
ZIPEXCLUDE ?= -x\!*.pk3 -xr\!\.svn -x\!qcsrc

FTEQCCFLAGS ?= -Wall -Wno-mundane -O3 -Ono-c -Ono-cs -flo
FTEQCCFLAGS_PROGS ?= 
FTEQCCFLAGS_MENU ?= 

# NOTE: use -DUSE_FTE instead of -TFTE here!
# It will automagically add an engine check with -TID and then change back to -TFTE
FTEQCCFLAGS_CSPROGS ?= 

all: qc

.PHONY: update-cvarcount
update-cvarcount:
	DO_NOT_RUN_MAKE=1 sh update-cvarcount.sh

.PHONY: qc
qc: menu.dat progs.dat csprogs.dat

.PHONY: skin
skin: gfx/menu/default/skinvalues.txt

.PHONY: pk3
pk3: $(PK3NAME)

.PHONY: pk3here
pk3here: qc
	$(RM) $(PK3NAME); \
	set -ex; \
		ABSPK3NAME=$(PK3NAME); \
		case $$ABSPK3NAME in \
			/*) \
				;; \
			*) \
				ABSPK3NAME=$$PWD/$$ABSPK3NAME; \
				;; \
		esac; \
		$(ZIP) $(ZIPEXCLUDE) $$ABSPK3NAME .

.PHONY: clean
clean:
	rm -f progs.dat menu.dat csprogs.dat

csprogs.dat: qcsrc/client/*.* qcsrc/common/*.* update-cvarcount
	cd qcsrc/client && $(FTEQCC) $(FTEQCCFLAGS) $(QCFLAGS_CSPROGS)

progs.dat: qcsrc/server/*.* qcsrc/common/*.* update-cvarcount
	cd qcsrc/server && $(FTEQCC) $(FTEQCCFLAGS) $(QCFLAGS_PROGS)

menu.dat: qcsrc/menu/*.* qcsrc/menu/*/*.* qcsrc/common/*.* update-cvarcount
	cd qcsrc/menu && $(FTEQCC) $(FTEQCCFLAGS) $(FTEQCCFLAGS_MENU)

gfx/menu/default/skinvalues.txt: qcsrc/menu/skin-customizables.inc
	$(PERL) qcsrc/menu/skin-customizables.inc > gfx/menu/default/skinvalues.txt

$(PK3NAME): qc
	$(RM) $(PK3NAME)
	set -ex; \
		ABSPK3NAME=$(PK3NAME); \
		case $$ABSPK3NAME in \
			/*) \
				;; \
			*) \
				ABSPK3NAME=$$PWD/$$ABSPK3NAME; \
				;; \
		esac; \
		TDIR=`mktemp -d -t nexuizpk3.XXXXXX`; \
		cp -v progs.dat csprogs.dat menu.dat $$TDIR/; \
		svn export --force . $$TDIR; \
		cd $$TDIR; \
		$(RM) -r qcsrc common-spog.pk3; \
		$(ZIP) $$ABSPK3NAME .

.PHONY: log
log:
	cd .. && svn log -r HEAD:BASE

.PHONY: logv
logv:
	cd .. && svn log -r HEAD:BASE -v

.PHONY: update
update:
	cd .. && svn up

.PHONY: logupdate
logupdate:
	cd .. && svn log -r HEAD:BASE && svn up

.PHONY: logvupdate
logvupdate:
	cd .. && svn log -r HEAD:BASE -v && svn up
