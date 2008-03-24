FTEQCC ?= fteqcc
PERL ?= perl
PK3NAME ?= `date +../data%Y%m%d.pk3`
ZIP ?= 7za a -tzip -mx=9

all: qc

.PHONY: qc
qc: menu.dat progs.dat

.PHONY: skin
skin: gfx/menu/default/skinvalues.txt

.PHONY: pk3
pk3: $(PK3NAME)

.PHONY: clean
clean:
	rm -f progs.dat menu.dat csprogs.dat

csprogs.dat: qcsrc/client/*.* qcsrc/common/*.*
	( cd qcsrc/client; $(FTEQCC) )

progs.dat: qcsrc/server/*.* qcsrc/common/*.*
	( cd qcsrc/server; $(FTEQCC) )

menu.dat: qcsrc/menu/*.* qcsrc/menu/*/*.* qcsrc/common/*.*
	( cd qcsrc/menu; $(FTEQCC) )

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
		svn export --force . $$TDIR; \
		cd $$TDIR; \
		$(RM) -r qcsrc common-spog.pk3 \
		$(ZIP) $$ABSPK3NAME .
