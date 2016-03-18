# Michael Hirsch 2014

FC = gfortran
#---- What the EXE filename should be ---------------------------------
TARGET_CMPL = fesprit
TARGET_REAL= fesprit_realsp
TARGET_C = cesprit
#----Sources (in order of dependency) ---------------------------------
FSRC_CMPL = comm.f90 perf.f90 subspace.f90 signals.f90 
FMAIN_CMPL = RunSubspace.f90

# yes, we should be using data polymorphism instead
FSRC_REAL = comm.f90 perf.f90 subspace_realsp.f90 signals_realsp.f90 
FMAIN_REAL = RunSubspace_realsp.f90

CSOURCES = cSubspace.c 
#----- libs you need --------------------------------------------------
FLIBS = -lblas -llapack -lpthread
CLIBS = -lm -lgfortran
#----- suffix patterns ------------------------------------------------
%.o: %.c
	$(CC) $(CFLAGS) -c  -o $@ $<
%.o: %.f90
	$(FC) $(FFLAGS) -c  -o $@ $<
#------------- FORTRAN ------------------------------------------------
FFLAGS = -Wall -Wpedantic -Wextra -mtune=native -fexternal-blas -ffast-math -O3

DBGFLAGS = -O0  -fbacktrace -fbounds-check

FOBJS_CMPL =     $(FSRC_CMPL:.f90=.o)
FOBJMAIN_CMPL = $(FMAIN_CMPL:.f90=.o)

FOBJS_REAL =     $(FSRC_REAL:.f90=.o)
FOBJMAIN_REAL = $(FMAIN_REAL:.f90=.o)

MODS = $(wildcard *.mod)
#------ C ----------------- -------------------------------------------
CFLAGS = -Wall -Wpedantic -Wextra -mtune=native -ffast-math -O3
COBJS = $(CSOURCES:.c=.o)
#------ targeting a Fortran Program--------------------------------
all: $(TARGET_CMPL) $(TARGET_REAL) $(TARGET_C)

debug: FFLAGS += -g $(DBGFLAGS)
debug: $(TARGET_CMPL) $(TARGET_REAL) $(TARGET_C)

real: $(TARGET_REAL)

cmpl: $(TARGET_CMPL)

c: $(TARGET_C)

$(TARGET_C): $(COBJS) $(FOBJS_REAL)
	$(CC) -o $@ $(CFLAGS) $(COBJS) $(FOBJS_REAL) $(FLIBS) $(CLIBS) $(LDFLAGS) 
    
$(TARGET_CMPL): $(FOBJS_CMPL) $(FOBJMAIN_CMPL)
	$(FC) -o $@ $(FFLAGS) $(FOBJS_CMPL) $(FOBJMAIN_CMPL) $(FLIBS) $(LDFLAGS)

$(TARGET_REAL): $(FOBJS_REAL) $(FOBJMAIN_REAL)
	$(FC) -o $@ $(FFLAGS) $(FOBJS_REAL) $(FOBJMAIN_REAL) $(FLIBS) $(LDFLAGS)
#----------- CLEAN ----------------------------
clean:
	$(RM) $(FOBJS_REAL) $(FOBJMAIN_REAL) $(FOBJS_CMPL) $(FOBJMAIN_CMPL) $(COBJS) $(MODS)
