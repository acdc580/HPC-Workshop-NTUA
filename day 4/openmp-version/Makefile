.PHONY: all clean
.DEFAULT: all

PROGRAMS = cg

all: $(PROGRAMS)

MKDIR_P = mkdir -p
RM 		= /bin/rm
ECHO 	= /bin/echo
CC 		= gcc
LIBS	= -lgomp -lm

MAKE_CPPFLAGS = 
MAKE_CFLAGS = -Wall -O3 -std=c99 -fopenmp 
MAKE_LDFLAGS = 

CPPFLAGS = $(MAKE_CPPFLAGS)
CFLAGS	 = $(MAKE_CFLAGS)
LDFLAGS  = $(MAKE_LDFLAGS)

COMPILE = $(CC) $(CPPFLAGS) $(CFLAGS)
LINK 	= $(CC)

cg_SOURCES = \
	helper.c \
	kernels.c \
	problem.c \
	main.c

cg_OBJECTS = $(cg_SOURCES:%.c=%.o)

DEPDIR = .deps
df = $(DEPDIR)/$(*F)
%.o: %.c
	$(MKDIR_P) $(DEPDIR)
	$(COMPILE) -c -MD -o $@ $<
	@cp $*.d $(df).P; \
	sed -e 's/#.*//' -e 's/^[^:]*: *//' -e 's/ *\\$$//' \
		-e '/^$$/ d' -e 's/$$/ :/' < $*.d >> $(df).P; \
		rm -f $*.d

-include $(cg_SOURCES:%.c=$(DEPDIR)/%.P)

cg: $(cg_OBJECTS)
	$(LINK) $(LDFLAGS) -o $@ $(cg_OBJECTS) $(LIBS)

clean:	
	$(RM) -rf $(DEPDIR)
	$(RM) -f *.o *.s *.d *~ $(PROGRAMS)

help:
	@$(ECHO) -e 'Mini help for using this Makefile:'; \
	$(ECHO) -e '\t* You can also customly set CC, CPPFLAGS, CFLAGS and LDFLAGS as usual.'; \
	$(ECHO) -e 'NOTE: When building release version, results checking is disabled.';
