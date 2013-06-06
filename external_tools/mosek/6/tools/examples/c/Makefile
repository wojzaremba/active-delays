#Gnu Make / Linux AMD64 / GCC

LIBMOSEKPATH=../../platform/linux64x86/bin
IPATHMOSEK=../../platform/linux64x86/h
LIBMOSEK=mosek64
LIBPATHS=../../platform/linux64x86/bin
CC = gcc
LD = gcc

EXAMPLES1=lo1 lo2 milo1 qo1 \
	  cqo1 qcqo1 \
	  concurrent1 concurrent2 \
	  dw dyn1 dyn2 \
	  solvebasis solvelinear

ALLEXAMPLES=$(EXAMPLES1) mskscopt mskexpopt
ALLOBJS=$(patsubst %,%.o,$(ALLEXAMPLES)) scopt.o expopt.o dgopt.o 

# COMPILING:
#  The path of <mosek.h> is required to compile.
%.o: %.c
	$(CC) -c -o $@ $< -I$(IPATHMOSEK) -I. -pthread

# LINKING:
#  The following rule links the binary from the corresponding object file for
#  all binaries mentioned in EXAMPLES1, for example:
#   lo1.o -> lo1
#  We set LD_LIBRARY_PATH to point at the libraries which libmosek depends on.
$(filter %,$(EXAMPLES1)): %: %.o
	LD_LIBRARY_PATH=$(LIBPATHS) \
		$(LD) -o $@ $^ -L$(LIBMOSEKPATH) -l$(LIBMOSEK) -pthread

msktsp: msktsp.o
	LD_LIBRARY_PATH=$(LIBPATHS) \
		$(LD) -o $@ $^ -L$(LIBMOSEKPATH) -l$(LIBMOSEK) -pthread -lm
	

mskscopt: scopt.o mskscopt.o
	LD_LIBRARY_PATH=$(LIBPATHS) \
		$(LD) -o $@ $^ -L$(LIBMOSEKPATH) -l$(LIBMOSEK) -pthread -lm


mskexpopt: mskexpopt.o expopt.o dgopt.o scopt.o
	LD_LIBRARY_PATH=$(LIBPATHS) \
		$(LD) -o $@ $^ -L$(LIBMOSEKPATH) -l$(LIBMOSEK) -pthread -lm
.PHONY: clean cleanall
clean: 
	rm -f $(ALLOBJS)
cleanall:
	rm -f $(ALLOBJS) $(ALLEXAMPLES)

all: $(ALLEXAMPLES) 

