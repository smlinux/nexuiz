../../data/progs.dat: *.nc *.qc bot/*.qc bot/maps/*.qc Makefile progs.src
	frikqcc /O2 -warn 2 || true

clean:
	rm -f ../../data/progs.dat progdefs.h error.log
