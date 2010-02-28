SCM := $(shell if [ -d .svn ]; then echo svn; elif [ -d ../.git ]; then echo git; fi)
FTEQCC ?= fteqcc
PERL ?= perl
PK3NAME ?= `date +../data%Y%m%d.pk3`
ZIP ?= 7za a -tzip -mx=9
ZIPEXCLUDE ?= -x\!*.pk3 -xr\!\.svn -x\!qcsrc
DIFF ?= diff

FTEQCCFLAGS ?= -Werror -Wall -Wno-mundane -O3 -Ono-c -Ono-cs -flo
FTEQCCFLAGS_PROGS ?= 
FTEQCCFLAGS_MENU ?= 

# NOTE: use -DUSE_FTE instead of -TFTE here!
# It will automagically add an engine check with -TID and then change back to -TFTE
FTEQCCFLAGS_CSPROGS ?= 

# nexuiz svn build system overrides this by command line argument
NEX_BUILDSYSTEM =

all: qc

.PHONY: update-cvarcount
update-cvarcount:
	[ "$(NEX_BUILDSYSTEM)" = "" ] || [ "$(NEX_BUILDSYSTEM)" = "1" ]
	[ "$(NEX_BUILDSYSTEM)" != "" ] || { ! [ -f ../misc/netradiant-NexuizPack/nexuiz.game/data/entities.def ] || $(DIFF) scripts/entities.def ../misc/netradiant-NexuizPack/nexuiz.game/data/entities.def || { echo entities.def mismatch, please merge ../misc/netradiant-NexuizPack/nexuiz.game/data/entities.def and scripts/entities.def; exit 1; }; }
	[ "$(NEX_BUILDSYSTEM)" != "" ] || { DO_NOT_RUN_MAKE=1 sh update-cvarcount.sh; }

.PHONY: qc
qc: update-cvarcount
	$(MAKE) qc-recursive

.PHONY: qc-recursive
qc-recursive: menu.dat progs.dat csprogs.dat

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

csprogs.dat: qcsrc/client/*.* qcsrc/common/*.* qcsrc/warpzonelib/*.*
	cd qcsrc/client && $(FTEQCC) $(FTEQCCFLAGS) $(FTEQCCFLAGS_CSPROGS)

progs.dat: qcsrc/server/*.* qcsrc/common/*.* qcsrc/server/*/*.* qcsrc/server/*/*/*.* qcsrc/warpzonelib/*.*
	cd qcsrc/server && $(FTEQCC) $(FTEQCCFLAGS) $(FTEQCCFLAGS_PROGS)

menu.dat: qcsrc/menu/*.* qcsrc/menu/*/*.* qcsrc/common/*.*
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
		$(ZIP) $$ABSPK3NAME .

.PHONY: testcase
testcase:
	cd qcsrc/testcase && $(FTEQCC) $(FTEQCCFLAGS) $(FTEQCCFLAGS_CSPROGS) -DTESTCASE="$$TESTCASE"

.PHONY: update commit diff log logv logupdate logvupdate revert
update: $(SCM)-update
commit: $(SCM)-commit
diff: $(SCM)-diff
log: $(SCM)-log
logv: $(SCM)-logv
revert: $(SCM)-revert
logupdate: log update
logvupdate: logv update

.PHONY: svn-update
svn-update:
	cd .. && svn update

.PHONY: svn-commit
svn-commit:
	cd .. && svn commit

.PHONY: svn-diff
svn-diff:
	cd .. && svn diff

.PHONY: svn-log
svn-log:
	cd .. && svn log -r HEAD:BASE

.PHONY: svn-logv
svn-logv:
	cd .. && svn log -r HEAD:BASE -v

.PHONY: svn-revert
svn-revert:
	svn revert -- $(FILE)

.PHONY: git-update
git-update:
	git pull origin

.PHONY: git-commit
git-commit:
	git commit -a || true
	if echo -n 'Also send to server? Hit Enter for yes, ^C for no. '; read -r L; then \
		git config svn-remote.svn.url svn://svn.icculus.org/nexuiz; \
		git config svn-remote.svn.fetch trunk:refs/remotes/origin/master; \
		git svn dcommit; \
	fi

.PHONY: git-diff
git-diff:
	git diff; git diff origin/master..HEAD; true

.PHONY: git-log
git-log:
	git fetch && git log HEAD..origin/master

.PHONY: git-logv
git-logv:
	git fetch && git log -v HEAD..origin/master

.PHONY: git-revert
git-revert:
	git checkout -- $(FILE)
