../../data/progs.dat: *.nc *.qc bot/*.qc bot/maps/*.qc
	frikqcc /O2 -warn 10 || true

clean:
	rm -f ../../data/progs.dat progdefs.h
