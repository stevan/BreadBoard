# This Makefile is for the Bread::Board extension to perl.
#
# It was generated automatically by MakeMaker version
# 6.17 (Revision: 1.133) from the contents of
# Makefile.PL. Don't edit this file, edit Makefile.PL instead.
#
#       ANY CHANGES MADE HERE WILL BE LOST!
#
#   MakeMaker ARGV: ()
#
#   MakeMaker Parameters:

#     ABSTRACT => q[A solderless way to wire up you application components]
#     AUTHOR => q[Stevan Little <stevan@iinteractive.com>]
#     DIR => []
#     DISTNAME => q[Bread-Board]
#     NAME => q[Bread::Board]
#     NO_META => q[1]
#     PL_FILES => {  }
#     PREREQ_PM => { Test::More=>q[0.62], MooseX::AttributeHelpers=>q[0.07], Test::Exception=>q[0.21], Sub::Current=>q[0.02], MooseX::Param=>q[0.02], Sub::Exporter=>q[0.972], Moose=>q[0.33] }
#     VERSION => q[0.01]
#     dist => { PREOP=>q[$(PERL) -I. "-MModule::Install::Admin" -e "dist_preop(q($(DISTVNAME)))"] }
#     test => { TESTS=>q[t/*.t] }

# --- MakeMaker post_initialize section:


# --- MakeMaker const_config section:

# These definitions are from config.sh (via /System/Library/Perl/5.8.6/darwin-thread-multi-2level/Config.pm)

# They may have been overridden via Makefile.PL or on the command line
AR = ar
CC = cc
CCCDLFLAGS =  
CCDLFLAGS =  
DLEXT = bundle
DLSRC = dl_dlopen.xs
LD = env MACOSX_DEPLOYMENT_TARGET=10.3 cc
LDDLFLAGS = -bundle -undefined dynamic_lookup -L/usr/local/lib
LDFLAGS = -L/usr/local/lib
LIBC = /usr/lib/libc.dylib
LIB_EXT = .a
OBJ_EXT = .o
OSNAME = darwin
OSVERS = 8.0
RANLIB = /usr/bin/ar ts
SITELIBEXP = /Library/Perl/5.8.6
SITEARCHEXP = /Library/Perl/5.8.6/darwin-thread-multi-2level
SO = dylib
EXE_EXT = 
FULL_AR = /usr/bin/ar
VENDORARCHEXP = /Network/Library/Perl/5.8.6/darwin-thread-multi-2level
VENDORLIBEXP = /Network/Library/Perl/5.8.6


# --- MakeMaker constants section:
AR_STATIC_ARGS = cr
DIRFILESEP = /
NAME = Bread::Board
NAME_SYM = Bread_Board
VERSION = 0.01
VERSION_MACRO = VERSION
VERSION_SYM = 0_01
DEFINE_VERSION = -D$(VERSION_MACRO)=\"$(VERSION)\"
XS_VERSION = 0.01
XS_VERSION_MACRO = XS_VERSION
XS_DEFINE_VERSION = -D$(XS_VERSION_MACRO)=\"$(XS_VERSION)\"
INST_ARCHLIB = blib/arch
INST_SCRIPT = blib/script
INST_BIN = blib/bin
INST_LIB = blib/lib
INST_MAN1DIR = blib/man1
INST_MAN3DIR = blib/man3
MAN1EXT = 1
MAN3EXT = 3pm
INSTALLDIRS = site
DESTDIR = 
PREFIX = 
PERLPREFIX = /
SITEPREFIX = /usr/local
VENDORPREFIX = /usr/local
INSTALLPRIVLIB = $(PERLPREFIX)/System/Library/Perl/5.8.6
DESTINSTALLPRIVLIB = $(DESTDIR)$(INSTALLPRIVLIB)
INSTALLSITELIB = /Library/Perl/5.8.6
DESTINSTALLSITELIB = $(DESTDIR)$(INSTALLSITELIB)
INSTALLVENDORLIB = /Network/Library/Perl/5.8.6
DESTINSTALLVENDORLIB = $(DESTDIR)$(INSTALLVENDORLIB)
INSTALLARCHLIB = $(PERLPREFIX)/System/Library/Perl/5.8.6/darwin-thread-multi-2level
DESTINSTALLARCHLIB = $(DESTDIR)$(INSTALLARCHLIB)
INSTALLSITEARCH = /Library/Perl/5.8.6/darwin-thread-multi-2level
DESTINSTALLSITEARCH = $(DESTDIR)$(INSTALLSITEARCH)
INSTALLVENDORARCH = /Network/Library/Perl/5.8.6/darwin-thread-multi-2level
DESTINSTALLVENDORARCH = $(DESTDIR)$(INSTALLVENDORARCH)
INSTALLBIN = $(PERLPREFIX)/usr/bin
DESTINSTALLBIN = $(DESTDIR)$(INSTALLBIN)
INSTALLSITEBIN = $(SITEPREFIX)/bin
DESTINSTALLSITEBIN = $(DESTDIR)$(INSTALLSITEBIN)
INSTALLVENDORBIN = $(VENDORPREFIX)/bin
DESTINSTALLVENDORBIN = $(DESTDIR)$(INSTALLVENDORBIN)
INSTALLSCRIPT = $(PERLPREFIX)/usr/bin
DESTINSTALLSCRIPT = $(DESTDIR)$(INSTALLSCRIPT)
INSTALLMAN1DIR = $(PERLPREFIX)/usr/share/man/man1
DESTINSTALLMAN1DIR = $(DESTDIR)$(INSTALLMAN1DIR)
INSTALLSITEMAN1DIR = $(SITEPREFIX)/man/man1
DESTINSTALLSITEMAN1DIR = $(DESTDIR)$(INSTALLSITEMAN1DIR)
INSTALLVENDORMAN1DIR = $(VENDORPREFIX)/man/man1
DESTINSTALLVENDORMAN1DIR = $(DESTDIR)$(INSTALLVENDORMAN1DIR)
INSTALLMAN3DIR = $(PERLPREFIX)/usr/share/man/man3
DESTINSTALLMAN3DIR = $(DESTDIR)$(INSTALLMAN3DIR)
INSTALLSITEMAN3DIR = $(SITEPREFIX)/man/man3
DESTINSTALLSITEMAN3DIR = $(DESTDIR)$(INSTALLSITEMAN3DIR)
INSTALLVENDORMAN3DIR = $(VENDORPREFIX)/man/man3
DESTINSTALLVENDORMAN3DIR = $(DESTDIR)$(INSTALLVENDORMAN3DIR)
PERL_LIB =
PERL_ARCHLIB = /System/Library/Perl/5.8.6/darwin-thread-multi-2level
LIBPERL_A = libperl.a
FIRST_MAKEFILE = Makefile
MAKEFILE_OLD = $(FIRST_MAKEFILE).old
MAKE_APERL_FILE = $(FIRST_MAKEFILE).aperl
PERLMAINCC = $(CC)
PERL_INC = /System/Library/Perl/5.8.6/darwin-thread-multi-2level/CORE
PERL = /usr/bin/perl "-Iinc"
FULLPERL = /usr/bin/perl "-Iinc"
ABSPERL = $(PERL)
PERLRUN = $(PERL)
FULLPERLRUN = $(FULLPERL)
ABSPERLRUN = $(ABSPERL)
PERLRUNINST = $(PERLRUN) "-I$(INST_ARCHLIB)" "-Iinc" "-I$(INST_LIB)"
FULLPERLRUNINST = $(FULLPERLRUN) "-I$(INST_ARCHLIB)" "-Iinc" "-I$(INST_LIB)"
ABSPERLRUNINST = $(ABSPERLRUN) "-I$(INST_ARCHLIB)" "-Iinc" "-I$(INST_LIB)"
PERL_CORE = 0
PERM_RW = 644
PERM_RWX = 755

MAKEMAKER   = /System/Library/Perl/5.8.6/ExtUtils/MakeMaker.pm
MM_VERSION  = 6.17
MM_REVISION = 1.133

# FULLEXT = Pathname for extension directory (eg Foo/Bar/Oracle).
# BASEEXT = Basename part of FULLEXT. May be just equal FULLEXT. (eg Oracle)
# PARENT_NAME = NAME without BASEEXT and no trailing :: (eg Foo::Bar)
# DLBASE  = Basename part of dynamic library. May be just equal BASEEXT.
FULLEXT = Bread/Board
BASEEXT = Board
PARENT_NAME = Bread
DLBASE = $(BASEEXT)
VERSION_FROM = 
OBJECT = 
LDFROM = $(OBJECT)
LINKTYPE = dynamic

# Handy lists of source code files:
XS_FILES = 
C_FILES  = 
O_FILES  = 
H_FILES  = 
MAN1PODS = 
MAN3PODS = lib/Bread/Board.pm \
	lib/Bread/Board/BlockInjection.pm \
	lib/Bread/Board/ConstructorInjection.pm \
	lib/Bread/Board/Container.pm \
	lib/Bread/Board/Dependency.pm \
	lib/Bread/Board/LifeCycle.pm \
	lib/Bread/Board/LifeCycle/Singleton.pm \
	lib/Bread/Board/Literal.pm \
	lib/Bread/Board/Service.pm \
	lib/Bread/Board/Service/Deferred.pm \
	lib/Bread/Board/Service/WithClass.pm \
	lib/Bread/Board/Service/WithDependencies.pm \
	lib/Bread/Board/Service/WithParameters.pm \
	lib/Bread/Board/SetterInjection.pm \
	lib/Bread/Board/Traversable.pm \
	lib/Bread/Board/Types.pm

# Where is the Config information that we are using/depend on
CONFIGDEP = $(PERL_ARCHLIB)$(DIRFILESEP)Config.pm $(PERL_INC)$(DIRFILESEP)config.h

# Where to build things
INST_LIBDIR      = $(INST_LIB)/Bread
INST_ARCHLIBDIR  = $(INST_ARCHLIB)/Bread

INST_AUTODIR     = $(INST_LIB)/auto/$(FULLEXT)
INST_ARCHAUTODIR = $(INST_ARCHLIB)/auto/$(FULLEXT)

INST_STATIC      = 
INST_DYNAMIC     = 
INST_BOOT        = 

# Extra linker info
EXPORT_LIST        = 
PERL_ARCHIVE       = 
PERL_ARCHIVE_AFTER = 


TO_INST_PM = lib/Bread/Board.pm \
	lib/Bread/Board/BlockInjection.pm \
	lib/Bread/Board/ConstructorInjection.pm \
	lib/Bread/Board/Container.pm \
	lib/Bread/Board/Dependency.pm \
	lib/Bread/Board/LifeCycle.pm \
	lib/Bread/Board/LifeCycle/Singleton.pm \
	lib/Bread/Board/Literal.pm \
	lib/Bread/Board/Service.pm \
	lib/Bread/Board/Service/Deferred.pm \
	lib/Bread/Board/Service/WithClass.pm \
	lib/Bread/Board/Service/WithDependencies.pm \
	lib/Bread/Board/Service/WithParameters.pm \
	lib/Bread/Board/SetterInjection.pm \
	lib/Bread/Board/Traversable.pm \
	lib/Bread/Board/Types.pm

PM_TO_BLIB = lib/Bread/Board/Service/Deferred.pm \
	blib/lib/Bread/Board/Service/Deferred.pm \
	lib/Bread/Board/Traversable.pm \
	blib/lib/Bread/Board/Traversable.pm \
	lib/Bread/Board/ConstructorInjection.pm \
	blib/lib/Bread/Board/ConstructorInjection.pm \
	lib/Bread/Board/LifeCycle/Singleton.pm \
	blib/lib/Bread/Board/LifeCycle/Singleton.pm \
	lib/Bread/Board/Literal.pm \
	blib/lib/Bread/Board/Literal.pm \
	lib/Bread/Board/Service/WithDependencies.pm \
	blib/lib/Bread/Board/Service/WithDependencies.pm \
	lib/Bread/Board/LifeCycle.pm \
	blib/lib/Bread/Board/LifeCycle.pm \
	lib/Bread/Board/Container.pm \
	blib/lib/Bread/Board/Container.pm \
	lib/Bread/Board/Service/WithClass.pm \
	blib/lib/Bread/Board/Service/WithClass.pm \
	lib/Bread/Board/Service.pm \
	blib/lib/Bread/Board/Service.pm \
	lib/Bread/Board/Types.pm \
	blib/lib/Bread/Board/Types.pm \
	lib/Bread/Board/SetterInjection.pm \
	blib/lib/Bread/Board/SetterInjection.pm \
	lib/Bread/Board.pm \
	blib/lib/Bread/Board.pm \
	lib/Bread/Board/BlockInjection.pm \
	blib/lib/Bread/Board/BlockInjection.pm \
	lib/Bread/Board/Service/WithParameters.pm \
	blib/lib/Bread/Board/Service/WithParameters.pm \
	lib/Bread/Board/Dependency.pm \
	blib/lib/Bread/Board/Dependency.pm


# --- MakeMaker platform_constants section:
MM_Unix_VERSION = 1.42
PERL_MALLOC_DEF = -DPERL_EXTMALLOC_DEF -Dmalloc=Perl_malloc -Dfree=Perl_mfree -Drealloc=Perl_realloc -Dcalloc=Perl_calloc


# --- MakeMaker tool_autosplit section:
# Usage: $(AUTOSPLITFILE) FileToSplit AutoDirToSplitInto
AUTOSPLITFILE = $(PERLRUN)  -e 'use AutoSplit;  autosplit($$ARGV[0], $$ARGV[1], 0, 1, 1)'



# --- MakeMaker tool_xsubpp section:


# --- MakeMaker tools_other section:
SHELL = /bin/sh
CHMOD = chmod
CP = cp
MV = mv
NOOP = $(SHELL) -c true
NOECHO = @
RM_F = rm -f
RM_RF = rm -rf
TEST_F = test -f
TOUCH = touch
UMASK_NULL = umask 0
DEV_NULL = > /dev/null 2>&1
MKPATH = $(PERLRUN) "-MExtUtils::Command" -e mkpath
EQUALIZE_TIMESTAMP = $(PERLRUN) "-MExtUtils::Command" -e eqtime
ECHO = echo
ECHO_N = echo -n
UNINST = 0
VERBINST = 0
MOD_INSTALL = $(PERLRUN) -MExtUtils::Install -e 'install({@ARGV}, '\''$(VERBINST)'\'', 0, '\''$(UNINST)'\'');'
DOC_INSTALL = $(PERLRUN) "-MExtUtils::Command::MM" -e perllocal_install
UNINSTALL = $(PERLRUN) "-MExtUtils::Command::MM" -e uninstall
WARN_IF_OLD_PACKLIST = $(PERLRUN) "-MExtUtils::Command::MM" -e warn_if_old_packlist


# --- MakeMaker makemakerdflt section:
makemakerdflt: all
	$(NOECHO) $(NOOP)


# --- MakeMaker dist section:
TAR = tar
TARFLAGS = cvf
ZIP = zip
ZIPFLAGS = -r
COMPRESS = gzip --best
SUFFIX = .gz
SHAR = shar
PREOP = $(PERL) -I. "-MModule::Install::Admin" -e "dist_preop(q($(DISTVNAME)))"
POSTOP = $(NOECHO) $(NOOP)
TO_UNIX = $(NOECHO) $(NOOP)
CI = ci -u
RCS_LABEL = rcs -Nv$(VERSION_SYM): -q
DIST_CP = best
DIST_DEFAULT = tardist
DISTNAME = Bread-Board
DISTVNAME = Bread-Board-0.01


# --- MakeMaker macro section:


# --- MakeMaker depend section:


# --- MakeMaker cflags section:


# --- MakeMaker const_loadlibs section:


# --- MakeMaker const_cccmd section:


# --- MakeMaker post_constants section:


# --- MakeMaker pasthru section:

PASTHRU = LIB="$(LIB)"\
	LIBPERL_A="$(LIBPERL_A)"\
	LINKTYPE="$(LINKTYPE)"\
	PREFIX="$(PREFIX)"\
	OPTIMIZE="$(OPTIMIZE)"\
	PASTHRU_DEFINE="$(PASTHRU_DEFINE)"\
	PASTHRU_INC="$(PASTHRU_INC)"


# --- MakeMaker special_targets section:
.SUFFIXES: .xs .c .C .cpp .i .s .cxx .cc $(OBJ_EXT)

.PHONY: all config static dynamic test linkext manifest



# --- MakeMaker c_o section:


# --- MakeMaker xs_c section:


# --- MakeMaker xs_o section:


# --- MakeMaker top_targets section:
all :: pure_all manifypods
	$(NOECHO) $(NOOP)


pure_all :: config pm_to_blib subdirs linkext
	$(NOECHO) $(NOOP)

subdirs :: $(MYEXTLIB)
	$(NOECHO) $(NOOP)

config :: $(FIRST_MAKEFILE) $(INST_LIBDIR)$(DIRFILESEP).exists
	$(NOECHO) $(NOOP)

config :: $(INST_ARCHAUTODIR)$(DIRFILESEP).exists
	$(NOECHO) $(NOOP)

config :: $(INST_AUTODIR)$(DIRFILESEP).exists
	$(NOECHO) $(NOOP)

$(INST_AUTODIR)/.exists :: /System/Library/Perl/5.8.6/darwin-thread-multi-2level/CORE/perl.h
	$(NOECHO) $(MKPATH) $(INST_AUTODIR)
	$(NOECHO) $(EQUALIZE_TIMESTAMP) /System/Library/Perl/5.8.6/darwin-thread-multi-2level/CORE/perl.h $(INST_AUTODIR)/.exists

	-$(NOECHO) $(CHMOD) $(PERM_RWX) $(INST_AUTODIR)

$(INST_LIBDIR)/.exists :: /System/Library/Perl/5.8.6/darwin-thread-multi-2level/CORE/perl.h
	$(NOECHO) $(MKPATH) $(INST_LIBDIR)
	$(NOECHO) $(EQUALIZE_TIMESTAMP) /System/Library/Perl/5.8.6/darwin-thread-multi-2level/CORE/perl.h $(INST_LIBDIR)/.exists

	-$(NOECHO) $(CHMOD) $(PERM_RWX) $(INST_LIBDIR)

$(INST_ARCHAUTODIR)/.exists :: /System/Library/Perl/5.8.6/darwin-thread-multi-2level/CORE/perl.h
	$(NOECHO) $(MKPATH) $(INST_ARCHAUTODIR)
	$(NOECHO) $(EQUALIZE_TIMESTAMP) /System/Library/Perl/5.8.6/darwin-thread-multi-2level/CORE/perl.h $(INST_ARCHAUTODIR)/.exists

	-$(NOECHO) $(CHMOD) $(PERM_RWX) $(INST_ARCHAUTODIR)

config :: $(INST_MAN3DIR)$(DIRFILESEP).exists
	$(NOECHO) $(NOOP)


$(INST_MAN3DIR)/.exists :: /System/Library/Perl/5.8.6/darwin-thread-multi-2level/CORE/perl.h
	$(NOECHO) $(MKPATH) $(INST_MAN3DIR)
	$(NOECHO) $(EQUALIZE_TIMESTAMP) /System/Library/Perl/5.8.6/darwin-thread-multi-2level/CORE/perl.h $(INST_MAN3DIR)/.exists

	-$(NOECHO) $(CHMOD) $(PERM_RWX) $(INST_MAN3DIR)

help:
	perldoc ExtUtils::MakeMaker


# --- MakeMaker linkext section:

linkext :: $(LINKTYPE)
	$(NOECHO) $(NOOP)


# --- MakeMaker dlsyms section:


# --- MakeMaker dynamic section:

dynamic :: $(FIRST_MAKEFILE) $(INST_DYNAMIC) $(INST_BOOT)
	$(NOECHO) $(NOOP)


# --- MakeMaker dynamic_bs section:

BOOTSTRAP =


# --- MakeMaker dynamic_lib section:


# --- MakeMaker static section:

## $(INST_PM) has been moved to the all: target.
## It remains here for awhile to allow for old usage: "make static"
static :: $(FIRST_MAKEFILE) $(INST_STATIC)
	$(NOECHO) $(NOOP)


# --- MakeMaker static_lib section:


# --- MakeMaker manifypods section:

POD2MAN_EXE = $(PERLRUN) "-MExtUtils::Command::MM" -e pod2man "--"
POD2MAN = $(POD2MAN_EXE)


manifypods : pure_all  \
	lib/Bread/Board/Service/Deferred.pm \
	lib/Bread/Board/Traversable.pm \
	lib/Bread/Board/ConstructorInjection.pm \
	lib/Bread/Board/LifeCycle/Singleton.pm \
	lib/Bread/Board/Literal.pm \
	lib/Bread/Board/Service/WithDependencies.pm \
	lib/Bread/Board/LifeCycle.pm \
	lib/Bread/Board/Container.pm \
	lib/Bread/Board/Service/WithClass.pm \
	lib/Bread/Board/Service.pm \
	lib/Bread/Board/Types.pm \
	lib/Bread/Board/SetterInjection.pm \
	lib/Bread/Board.pm \
	lib/Bread/Board/BlockInjection.pm \
	lib/Bread/Board/Service/WithParameters.pm \
	lib/Bread/Board/Dependency.pm \
	lib/Bread/Board/Service/Deferred.pm \
	lib/Bread/Board/Traversable.pm \
	lib/Bread/Board/ConstructorInjection.pm \
	lib/Bread/Board/LifeCycle/Singleton.pm \
	lib/Bread/Board/Literal.pm \
	lib/Bread/Board/Service/WithDependencies.pm \
	lib/Bread/Board/LifeCycle.pm \
	lib/Bread/Board/Container.pm \
	lib/Bread/Board/Service/WithClass.pm \
	lib/Bread/Board/Service.pm \
	lib/Bread/Board/Types.pm \
	lib/Bread/Board/SetterInjection.pm \
	lib/Bread/Board.pm \
	lib/Bread/Board/BlockInjection.pm \
	lib/Bread/Board/Service/WithParameters.pm \
	lib/Bread/Board/Dependency.pm
	$(NOECHO) $(POD2MAN) --section=3 --perm_rw=$(PERM_RW)\
	  lib/Bread/Board/Service/Deferred.pm $(INST_MAN3DIR)/Bread::Board::Service::Deferred.$(MAN3EXT) \
	  lib/Bread/Board/Traversable.pm $(INST_MAN3DIR)/Bread::Board::Traversable.$(MAN3EXT) \
	  lib/Bread/Board/ConstructorInjection.pm $(INST_MAN3DIR)/Bread::Board::ConstructorInjection.$(MAN3EXT) \
	  lib/Bread/Board/LifeCycle/Singleton.pm $(INST_MAN3DIR)/Bread::Board::LifeCycle::Singleton.$(MAN3EXT) \
	  lib/Bread/Board/Literal.pm $(INST_MAN3DIR)/Bread::Board::Literal.$(MAN3EXT) \
	  lib/Bread/Board/Service/WithDependencies.pm $(INST_MAN3DIR)/Bread::Board::Service::WithDependencies.$(MAN3EXT) \
	  lib/Bread/Board/LifeCycle.pm $(INST_MAN3DIR)/Bread::Board::LifeCycle.$(MAN3EXT) \
	  lib/Bread/Board/Container.pm $(INST_MAN3DIR)/Bread::Board::Container.$(MAN3EXT) \
	  lib/Bread/Board/Service/WithClass.pm $(INST_MAN3DIR)/Bread::Board::Service::WithClass.$(MAN3EXT) \
	  lib/Bread/Board/Service.pm $(INST_MAN3DIR)/Bread::Board::Service.$(MAN3EXT) \
	  lib/Bread/Board/Types.pm $(INST_MAN3DIR)/Bread::Board::Types.$(MAN3EXT) \
	  lib/Bread/Board/SetterInjection.pm $(INST_MAN3DIR)/Bread::Board::SetterInjection.$(MAN3EXT) \
	  lib/Bread/Board.pm $(INST_MAN3DIR)/Bread::Board.$(MAN3EXT) \
	  lib/Bread/Board/BlockInjection.pm $(INST_MAN3DIR)/Bread::Board::BlockInjection.$(MAN3EXT) \
	  lib/Bread/Board/Service/WithParameters.pm $(INST_MAN3DIR)/Bread::Board::Service::WithParameters.$(MAN3EXT) \
	  lib/Bread/Board/Dependency.pm $(INST_MAN3DIR)/Bread::Board::Dependency.$(MAN3EXT) 




# --- MakeMaker processPL section:


# --- MakeMaker installbin section:


# --- MakeMaker subdirs section:

# none

# --- MakeMaker clean_subdirs section:
clean_subdirs :
	$(NOECHO) $(NOOP)


# --- MakeMaker clean section:

# Delete temporary files but do not touch installed files. We don't delete
# the Makefile here so a later make realclean still has a makefile to use.

clean :: clean_subdirs
	-$(RM_RF) ./blib $(MAKE_APERL_FILE) $(INST_ARCHAUTODIR)/extralibs.all $(INST_ARCHAUTODIR)/extralibs.ld perlmain.c tmon.out mon.out so_locations pm_to_blib *$(OBJ_EXT) *$(LIB_EXT) perl.exe perl perl$(EXE_EXT) $(BOOTSTRAP) $(BASEEXT).bso $(BASEEXT).def lib$(BASEEXT).def $(BASEEXT).exp $(BASEEXT).x core core.*perl.*.? *perl.core core.[0-9] core.[0-9][0-9] core.[0-9][0-9][0-9] core.[0-9][0-9][0-9][0-9] core.[0-9][0-9][0-9][0-9][0-9]
	-$(MV) $(FIRST_MAKEFILE) $(MAKEFILE_OLD) $(DEV_NULL)


# --- MakeMaker realclean_subdirs section:
realclean_subdirs :
	$(NOECHO) $(NOOP)


# --- MakeMaker realclean section:

# Delete temporary files (via clean) and also delete installed files
realclean purge ::  clean realclean_subdirs
	$(RM_RF) $(INST_AUTODIR) $(INST_ARCHAUTODIR)
	$(RM_RF) $(DISTVNAME)
	$(RM_F)  blib/lib/Bread/Board/Literal.pm blib/lib/Bread/Board/Service/WithParameters.pm blib/lib/Bread/Board/Types.pm blib/lib/Bread/Board/Service.pm blib/lib/Bread/Board/LifeCycle.pm blib/lib/Bread/Board.pm
	$(RM_F) $(MAKEFILE_OLD) blib/lib/Bread/Board/BlockInjection.pm $(FIRST_MAKEFILE) blib/lib/Bread/Board/Service/WithDependencies.pm blib/lib/Bread/Board/Container.pm blib/lib/Bread/Board/Service/WithClass.pm
	$(RM_F) blib/lib/Bread/Board/SetterInjection.pm blib/lib/Bread/Board/ConstructorInjection.pm blib/lib/Bread/Board/Service/Deferred.pm blib/lib/Bread/Board/Dependency.pm
	$(RM_F) blib/lib/Bread/Board/LifeCycle/Singleton.pm blib/lib/Bread/Board/Traversable.pm


# --- MakeMaker metafile section:
metafile:
	$(NOECHO) $(NOOP)


# --- MakeMaker metafile_addtomanifest section:
metafile_addtomanifest:
	$(NOECHO) $(NOOP)


# --- MakeMaker dist_basics section:
distclean :: realclean distcheck
	$(NOECHO) $(NOOP)

distcheck :
	$(PERLRUN) "-MExtUtils::Manifest=fullcheck" -e fullcheck

skipcheck :
	$(PERLRUN) "-MExtUtils::Manifest=skipcheck" -e skipcheck

manifest :
	$(PERLRUN) "-MExtUtils::Manifest=mkmanifest" -e mkmanifest

veryclean : realclean
	$(RM_F) *~ *.orig */*~ */*.orig



# --- MakeMaker dist_core section:

dist : $(DIST_DEFAULT) $(FIRST_MAKEFILE)
	$(NOECHO) $(PERLRUN) -l -e 'print '\''Warning: Makefile possibly out of date with $(VERSION_FROM)'\''' \
	-e '    if -e '\''$(VERSION_FROM)'\'' and -M '\''$(VERSION_FROM)'\'' < -M '\''$(FIRST_MAKEFILE)'\'';'

tardist : $(DISTVNAME).tar$(SUFFIX)
	$(NOECHO) $(NOOP)

uutardist : $(DISTVNAME).tar$(SUFFIX)
	uuencode $(DISTVNAME).tar$(SUFFIX) $(DISTVNAME).tar$(SUFFIX) > $(DISTVNAME).tar$(SUFFIX)_uu

$(DISTVNAME).tar$(SUFFIX) : distdir
	$(PREOP)
	$(TO_UNIX)
	$(TAR) $(TARFLAGS) $(DISTVNAME).tar $(DISTVNAME)
	$(RM_RF) $(DISTVNAME)
	$(COMPRESS) $(DISTVNAME).tar
	$(POSTOP)

zipdist : $(DISTVNAME).zip
	$(NOECHO) $(NOOP)

$(DISTVNAME).zip : distdir
	$(PREOP)
	$(ZIP) $(ZIPFLAGS) $(DISTVNAME).zip $(DISTVNAME)
	$(RM_RF) $(DISTVNAME)
	$(POSTOP)

shdist : distdir
	$(PREOP)
	$(SHAR) $(DISTVNAME) > $(DISTVNAME).shar
	$(RM_RF) $(DISTVNAME)
	$(POSTOP)


# --- MakeMaker distdir section:
distdir : metafile metafile_addtomanifest
	$(RM_RF) $(DISTVNAME)
	$(PERLRUN) "-MExtUtils::Manifest=manicopy,maniread" \
		-e "manicopy(maniread(),'$(DISTVNAME)', '$(DIST_CP)');"



# --- MakeMaker dist_test section:

disttest : distdir
	cd $(DISTVNAME) && $(ABSPERLRUN) Makefile.PL
	cd $(DISTVNAME) && $(MAKE) $(PASTHRU)
	cd $(DISTVNAME) && $(MAKE) test $(PASTHRU)


# --- MakeMaker dist_ci section:

ci :
	$(PERLRUN) "-MExtUtils::Manifest=maniread" \
	  -e "@all = keys %{ maniread() };" \
	  -e "print(qq{Executing $(CI) @all\n}); system(qq{$(CI) @all});" \
	  -e "print(qq{Executing $(RCS_LABEL) ...\n}); system(qq{$(RCS_LABEL) @all});"


# --- MakeMaker install section:

install :: all pure_install doc_install

install_perl :: all pure_perl_install doc_perl_install

install_site :: all pure_site_install doc_site_install

install_vendor :: all pure_vendor_install doc_vendor_install

pure_install :: pure_$(INSTALLDIRS)_install

doc_install :: doc_$(INSTALLDIRS)_install

pure__install : pure_site_install
	$(NOECHO) $(ECHO) INSTALLDIRS not defined, defaulting to INSTALLDIRS=site

doc__install : doc_site_install
	$(NOECHO) $(ECHO) INSTALLDIRS not defined, defaulting to INSTALLDIRS=site

pure_perl_install ::
	$(NOECHO) $(MOD_INSTALL) \
		read $(PERL_ARCHLIB)/auto/$(FULLEXT)/.packlist \
		write $(DESTINSTALLARCHLIB)/auto/$(FULLEXT)/.packlist \
		$(INST_LIB) $(DESTINSTALLPRIVLIB) \
		$(INST_ARCHLIB) $(DESTINSTALLARCHLIB) \
		$(INST_BIN) $(DESTINSTALLBIN) \
		$(INST_SCRIPT) $(DESTINSTALLSCRIPT) \
		$(INST_MAN1DIR) $(DESTINSTALLMAN1DIR) \
		$(INST_MAN3DIR) $(DESTINSTALLMAN3DIR)
	$(NOECHO) $(WARN_IF_OLD_PACKLIST) \
		$(SITEARCHEXP)/auto/$(FULLEXT)


pure_site_install ::
	$(NOECHO) $(MOD_INSTALL) \
		read $(SITEARCHEXP)/auto/$(FULLEXT)/.packlist \
		write $(DESTINSTALLSITEARCH)/auto/$(FULLEXT)/.packlist \
		$(INST_LIB) $(DESTINSTALLSITELIB) \
		$(INST_ARCHLIB) $(DESTINSTALLSITEARCH) \
		$(INST_BIN) $(DESTINSTALLSITEBIN) \
		$(INST_SCRIPT) $(DESTINSTALLSCRIPT) \
		$(INST_MAN1DIR) $(DESTINSTALLSITEMAN1DIR) \
		$(INST_MAN3DIR) $(DESTINSTALLSITEMAN3DIR)
	$(NOECHO) $(WARN_IF_OLD_PACKLIST) \
		$(PERL_ARCHLIB)/auto/$(FULLEXT)

pure_vendor_install ::
	$(NOECHO) $(MOD_INSTALL) \
		read $(VENDORARCHEXP)/auto/$(FULLEXT)/.packlist \
		write $(DESTINSTALLVENDORARCH)/auto/$(FULLEXT)/.packlist \
		$(INST_LIB) $(DESTINSTALLVENDORLIB) \
		$(INST_ARCHLIB) $(DESTINSTALLVENDORARCH) \
		$(INST_BIN) $(DESTINSTALLVENDORBIN) \
		$(INST_SCRIPT) $(DESTINSTALLSCRIPT) \
		$(INST_MAN1DIR) $(DESTINSTALLVENDORMAN1DIR) \
		$(INST_MAN3DIR) $(DESTINSTALLVENDORMAN3DIR)

doc_perl_install ::
	$(NOECHO) $(ECHO) Appending installation info to $(DESTINSTALLARCHLIB)/perllocal.pod
	-$(NOECHO) $(MKPATH) $(DESTINSTALLARCHLIB)
	-$(NOECHO) $(DOC_INSTALL) \
		"Module" "$(NAME)" \
		"installed into" "$(INSTALLPRIVLIB)" \
		LINKTYPE "$(LINKTYPE)" \
		VERSION "$(VERSION)" \
		EXE_FILES "$(EXE_FILES)" \
		>> $(DESTINSTALLARCHLIB)/perllocal.pod

doc_site_install ::
	$(NOECHO) $(ECHO) Appending installation info to $(DESTINSTALLARCHLIB)/perllocal.pod
	-$(NOECHO) $(MKPATH) $(DESTINSTALLARCHLIB)
	-$(NOECHO) $(DOC_INSTALL) \
		"Module" "$(NAME)" \
		"installed into" "$(INSTALLSITELIB)" \
		LINKTYPE "$(LINKTYPE)" \
		VERSION "$(VERSION)" \
		EXE_FILES "$(EXE_FILES)" \
		>> $(DESTINSTALLARCHLIB)/perllocal.pod

doc_vendor_install ::
	$(NOECHO) $(ECHO) Appending installation info to $(DESTINSTALLARCHLIB)/perllocal.pod
	-$(NOECHO) $(MKPATH) $(DESTINSTALLARCHLIB)
	-$(NOECHO) $(DOC_INSTALL) \
		"Module" "$(NAME)" \
		"installed into" "$(INSTALLVENDORLIB)" \
		LINKTYPE "$(LINKTYPE)" \
		VERSION "$(VERSION)" \
		EXE_FILES "$(EXE_FILES)" \
		>> $(DESTINSTALLARCHLIB)/perllocal.pod


uninstall :: uninstall_from_$(INSTALLDIRS)dirs

uninstall_from_perldirs ::
	$(NOECHO) $(UNINSTALL) $(PERL_ARCHLIB)/auto/$(FULLEXT)/.packlist

uninstall_from_sitedirs ::
	$(NOECHO) $(UNINSTALL) $(SITEARCHEXP)/auto/$(FULLEXT)/.packlist

uninstall_from_vendordirs ::
	$(NOECHO) $(UNINSTALL) $(VENDORARCHEXP)/auto/$(FULLEXT)/.packlist


# --- MakeMaker force section:
# Phony target to force checking subdirectories.
FORCE:
	$(NOECHO) $(NOOP)


# --- MakeMaker perldepend section:


# --- MakeMaker makefile section:

# We take a very conservative approach here, but it's worth it.
# We move Makefile to Makefile.old here to avoid gnu make looping.
$(FIRST_MAKEFILE) : Makefile.PL $(CONFIGDEP)
	$(NOECHO) $(ECHO) "Makefile out-of-date with respect to $?"
	$(NOECHO) $(ECHO) "Cleaning current config before rebuilding Makefile..."
	$(NOECHO) $(RM_F) $(MAKEFILE_OLD)
	$(NOECHO) $(MV)   $(FIRST_MAKEFILE) $(MAKEFILE_OLD)
	-$(MAKE) -f $(MAKEFILE_OLD) clean $(DEV_NULL) || $(NOOP)
	$(PERLRUN) Makefile.PL 
	$(NOECHO) $(ECHO) "==> Your Makefile has been rebuilt. <=="
	$(NOECHO) $(ECHO) "==> Please rerun the make command.  <=="
	false



# --- MakeMaker staticmake section:

# --- MakeMaker makeaperl section ---
MAP_TARGET    = perl
FULLPERL      = /usr/bin/perl

$(MAP_TARGET) :: static $(MAKE_APERL_FILE)
	$(MAKE) -f $(MAKE_APERL_FILE) $@

$(MAKE_APERL_FILE) : $(FIRST_MAKEFILE)
	$(NOECHO) $(ECHO) Writing \"$(MAKE_APERL_FILE)\" for this $(MAP_TARGET)
	$(NOECHO) $(PERLRUNINST) \
		Makefile.PL DIR= \
		MAKEFILE=$(MAKE_APERL_FILE) LINKTYPE=static \
		MAKEAPERL=1 NORECURS=1 CCCDLFLAGS=


# --- MakeMaker test section:

TEST_VERBOSE=0
TEST_TYPE=test_$(LINKTYPE)
TEST_FILE = test.pl
TEST_FILES = t/*.t
TESTDB_SW = -d

testdb :: testdb_$(LINKTYPE)

test :: $(TEST_TYPE)

test_dynamic :: pure_all
	PERL_DL_NONLAZY=1 $(FULLPERLRUN) "-MExtUtils::Command::MM" "-e" "test_harness($(TEST_VERBOSE), 'inc', '$(INST_LIB)', '$(INST_ARCHLIB)')" $(TEST_FILES)

testdb_dynamic :: pure_all
	PERL_DL_NONLAZY=1 $(FULLPERLRUN) $(TESTDB_SW) "-Iinc" "-I$(INST_LIB)" "-I$(INST_ARCHLIB)" $(TEST_FILE)

test_ : test_dynamic

test_static :: test_dynamic
testdb_static :: testdb_dynamic


# --- MakeMaker ppd section:
# Creates a PPD (Perl Package Description) for a binary distribution.
ppd:
	$(NOECHO) $(ECHO) '<SOFTPKG NAME="$(DISTNAME)" VERSION="0,01,0,0">' > $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '    <TITLE>$(DISTNAME)</TITLE>' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '    <ABSTRACT>A solderless way to wire up you application components</ABSTRACT>' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '    <AUTHOR>Stevan Little &lt;stevan@iinteractive.com&gt;</AUTHOR>' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '    <IMPLEMENTATION>' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <DEPENDENCY NAME="Moose" VERSION="0,33,0,0" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <DEPENDENCY NAME="MooseX-AttributeHelpers" VERSION="0,07,0,0" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <DEPENDENCY NAME="MooseX-Param" VERSION="0,02,0,0" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <DEPENDENCY NAME="Sub-Current" VERSION="0,02,0,0" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <DEPENDENCY NAME="Sub-Exporter" VERSION="0,972,0,0" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <DEPENDENCY NAME="Test-Exception" VERSION="0,21,0,0" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <DEPENDENCY NAME="Test-More" VERSION="0,62,0,0" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <OS NAME="$(OSNAME)" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <ARCHITECTURE NAME="darwin-thread-multi-2level" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <CODEBASE HREF="" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '    </IMPLEMENTATION>' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '</SOFTPKG>' >> $(DISTNAME).ppd


# --- MakeMaker pm_to_blib section:

pm_to_blib: $(TO_INST_PM)
	$(NOECHO) $(PERLRUN) -MExtUtils::Install -e 'pm_to_blib({@ARGV}, '\''$(INST_LIB)/auto'\'', '\''$(PM_FILTER)'\'')'\
	  lib/Bread/Board/Service/Deferred.pm blib/lib/Bread/Board/Service/Deferred.pm \
	  lib/Bread/Board/Traversable.pm blib/lib/Bread/Board/Traversable.pm \
	  lib/Bread/Board/ConstructorInjection.pm blib/lib/Bread/Board/ConstructorInjection.pm \
	  lib/Bread/Board/LifeCycle/Singleton.pm blib/lib/Bread/Board/LifeCycle/Singleton.pm \
	  lib/Bread/Board/Literal.pm blib/lib/Bread/Board/Literal.pm \
	  lib/Bread/Board/Service/WithDependencies.pm blib/lib/Bread/Board/Service/WithDependencies.pm \
	  lib/Bread/Board/LifeCycle.pm blib/lib/Bread/Board/LifeCycle.pm \
	  lib/Bread/Board/Container.pm blib/lib/Bread/Board/Container.pm \
	  lib/Bread/Board/Service/WithClass.pm blib/lib/Bread/Board/Service/WithClass.pm \
	  lib/Bread/Board/Service.pm blib/lib/Bread/Board/Service.pm \
	  lib/Bread/Board/Types.pm blib/lib/Bread/Board/Types.pm \
	  lib/Bread/Board/SetterInjection.pm blib/lib/Bread/Board/SetterInjection.pm \
	  lib/Bread/Board.pm blib/lib/Bread/Board.pm \
	  lib/Bread/Board/BlockInjection.pm blib/lib/Bread/Board/BlockInjection.pm \
	  lib/Bread/Board/Service/WithParameters.pm blib/lib/Bread/Board/Service/WithParameters.pm \
	  lib/Bread/Board/Dependency.pm blib/lib/Bread/Board/Dependency.pm 
	$(NOECHO) $(TOUCH) $@

# --- MakeMaker selfdocument section:


# --- MakeMaker postamble section:


# End.
# Postamble by Module::Install 0.68
# --- Module::Install::Admin::Makefile section:

realclean purge ::
	$(RM_F) $(DISTVNAME).tar$(SUFFIX)
	$(RM_RF) inc MANIFEST.bak _build
	$(PERL) -I. "-MModule::Install::Admin" -e "remove_meta()"

reset :: purge

upload :: test dist
	cpan-upload -verbose $(DISTVNAME).tar$(SUFFIX)

grok ::
	perldoc Module::Install

distsign ::
	cpansign -s

