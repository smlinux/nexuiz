FTEQCC ?= fteqcc
PERL ?= perl
PK3NAME ?= `date +../data%Y%m%d.pk3`
ZIP ?= 7za a -tzip -mx=9

# NOTE: use -DUSE_FTE instead of -TFTE here!
# It will automagically add an engine check with -TID and then change back to -TFTE
QCFLAGS_CSQC ?= 

# to be enabled when possible
# QCFLAGS_SVQC ?= -TFTE

all: qc

.PHONY: qc
qc: menu.dat progs.dat csprogs.dat

.PHONY: skin
skin: gfx/menu/default/skinvalues.txt

.PHONY: pk3
pk3: $(PK3NAME)

.PHONY: clean
clean:
	rm -f progs.dat menu.dat csprogs.dat

csprogs.dat: qcsrc/client/*.* qcsrc/common/*.*
	( cd qcsrc/client; $(FTEQCC) $(QCFLAGS_CSQC) )

progs.dat: qcsrc/server/*.* qcsrc/common/*.*
	( cd qcsrc/server; $(FTEQCC) $(QCFLAGS_SVQC) )

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
