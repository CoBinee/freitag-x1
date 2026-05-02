#! make -f
#
# makefile - start
#


# directory
#

# source file directory
SRCDIR			=	sources

# include file directory
INCDIR			=	sources

# object file directory
OBJDIR			=	objects

# binary file directory
BINDIR			=	bin

# output file directory
OUTDIR			=	disk

# output file directory
RESDIR			=	resources

# tool directory
TOOLDIR			=	tools

# vpath search directories
VPATH			=	$(SRCDIR):$(INCDIR):$(OBJDIR):$(BINDIR)

# assembler
#

# assembler command
AS				=	z88dk-z80asm

# assembler flags
ASFLAGS			=	-mz80 -I$(SRCDIR) -I$(INCDIR) -I.

# c compiler
#

# c compiler command
CC				=	zcc

# c compiler flags
CFLAGS			=	+x1 -mz80 -lm -I$(SRCDIR) -I$(INCDIR) -I.

# linker
#

# linker command
# LD			=	zcc
LD				=	z88dk-z80asm

# linker flags
# LDFLAGS		=	+x1
LDFLAGS			=	-b -mz80 -split-bin

# suffix rules
#
.SUFFIXES:			.asm .c .o

# assembler source suffix
.asm.o:
	$(AS) $(ASFLAGS) -o=$(OBJDIR)/$@ $<

# c source suffix
.c.o:
	$(CC) $(CFLAGS) -o $(OBJDIR)/$@ -c $<

# project files
#

# target name
TARGET			=	freitag
TARGET_ID		=	ftag

# assembler source files
ASSRCS			=	crt0.asm xcs.asm \
					app.asm \
					title.asm \
					game.asm var.asm cf.asm cfobj.asm sb2.asm

# c source files
CSRCS			=	

# object files
OBJS			=	$(ASSRCS:.asm=.o) $(CSRCS:.c=.o)

# resource files
RESS			=	$(RESDIR)/pcgs/font.pcg \
					$(RESDIR)/tilesets/sketchz.ts $(RESDIR)/tilesets/cfmisc.ts $(RESDIR)/tilesets/lbolt.ts $(RESDIR)/tilesets/badbreath.ts \
					$(RESDIR)/images/title.gvr \
					$(RESDIR)/sounds/song.snd \
					$(RESDIR)/data/map.bin

# build project disk
#
$(TARGET).d88:		$(OBJS)
	$(LD) $(LDFLAGS) -o=$(BINDIR)/$(TARGET_ID).bin -m $(foreach file,$(OBJS),$(OBJDIR)/$(file))
	@mv $(BINDIR)/$(TARGET_ID)_boot.bin $(BINDIR)/$(TARGET_ID)_boot.Sys
	$(TOOLDIR)/hu2d -d88 -o $(OUTDIR)/$(TARGET).d88 $(BINDIR)/$(TARGET_ID)_boot.Sys $(BINDIR)/$(TARGET_ID)_app.bin $(RESS)
	$(TOOLDIR)/hu2d -2d  -o $(OUTDIR)/$(TARGET).2d  $(BINDIR)/$(TARGET_ID)_boot.Sys $(BINDIR)/$(TARGET_ID)_app.bin $(RESS)

# clean project
#
clean:
	@rm -f $(OBJDIR)/*
	@rm -f $(BINDIR)/*
##	@rm -f makefile.depend

# build depend file
#
##	depend:
##	ifneq ($(strip $(CSRCS)),)
##		$(CC) $(CFLAGS) -MM $(foreach file,$(CSRCS),$(SRCDIR)/$(file)) > makefile.depend
##	endif

# build tools
#
tool:
	@g++ -o $(TOOLDIR)/hu2d $(TOOLDIR)/hu2d.cpp
	@g++ -Wno-c++11-narrowing -o $(TOOLDIR)/fmstxt $(TOOLDIR)/fmstxt.cpp

# build resource
#
resource:
	$(TOOLDIR)/fmstxt -h $(RESDIR)/sounds/song.inc -o $(RESDIR)/sounds/song.snd $(RESDIR)/sounds/song.txt

# phony targets
#
##	.PHONY:				clean depend
.PHONY:				clean

# include depend file
#
-include makefile.depend


# makefile - end
