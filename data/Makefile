all: qc

.PHONY: qc
qc: menu.dat progs.dat

.PHONY: skin
skin: gfx/menu/default/skinvalues.txt

clean:
	rm -f progs.dat menu.dat csprogs.dat

csprogs.dat: qcsrc/client/* qcsrc/common/*
	( cd qcsrc/client; fteqcc )

progs.dat: qcsrc/server/* qcsrc/common/*
	( cd qcsrc/server; fteqcc )

menu.dat: qcsrc/menu/* qcsrc/common/*
	( cd qcsrc/menu; fteqcc )

gfx/menu/default/skinvalues.txt: qcsrc/menu/skin-customizables.inc
	perl qcsrc/menu/skin-customizables.inc > gfx/menu/default/skinvalues.txt
