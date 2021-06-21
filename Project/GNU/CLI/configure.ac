dnl #########################################################################
dnl ### Init
dnl #########################################################################

dnl -------------------------------------------------------------------------
dnl Test if we are at the good place
dnl
AC_INIT(../../../Source/CLI/CLI_Main.cpp)

dnl -------------------------------------------------------------------------
dnl sets build, host, target variables and the same with _alias
dnl
AC_CANONICAL_BUILD
AC_CANONICAL_HOST

dnl -------------------------------------------------------------------------
dnl Name and version
dnl
AM_INIT_AUTOMAKE(dvrescue,0)

dnl -------------------------------------------------------------------------
dnl Autotools init
dnl
CFLAGS="$CFLAGS"
CXXFLAGS="$CXXFLAGS"
AC_PROG_CC
AC_PROG_CXX
AC_PROG_OBJC
AC_PROG_OBJCXX
AC_PROG_LIBTOOL
AC_PROG_INSTALL

dnl #########################################################################
dnl ### Options
dnl #########################################################################

dnl -------------------------------------------------------------------------
dnl Arguments - Enable
dnl
AC_ARG_ENABLE(debug,        AC_HELP_STRING([--enable-debug],        [Enable full debug]),                       , enable_debug=no)
AC_ARG_ENABLE(gprof,        AC_HELP_STRING([--enable-gprof],        [Enable gprof log]),                        , enable_gprof=no)
AC_ARG_ENABLE(universal_binary, AC_HELP_STRING([--enable-universal_binary], [Create Mac PPC/i386 Universal binary]),      , enable_universal_binary=no)
AC_ARG_ENABLE(arch-ppc,         AC_HELP_STRING([--with-arch-ppc],           [Create Mac PPC Universal binary]),           , enable_arch_ppc=no)
AC_ARG_ENABLE(arch-i386,        AC_HELP_STRING([--with-arch-i386],          [Create Mac i386 Universal binary]),          , enable_arch_i386=no)
AC_ARG_ENABLE(arch-x86_64,      AC_HELP_STRING([--enable-arch-x86_64],      [Create Mac x86_64 architecture]),            , enable_arch_x86_64=no)
AC_ARG_ENABLE(staticlibs,   AC_HELP_STRING([--enable-staticlibs],   [Use static libmediainfo and libzen]),      , enable_staticlibs=no)
AC_ARG_ENABLE(avfctl,           AC_HELP_STRING([--enable-avfctl],           [Build avfctl tool (macOS only)]),            , enable_avfctl=yes)

dnl -------------------------------------------------------------------------
dnl Arguments - With
dnl
AC_ARG_WITH(macosx-sdk,         AC_HELP_STRING([--with-macosx-sdk],         [Force the Mac SDK]),                         , with_macosx_sdk=no)
AC_ARG_WITH(macosx-version-min, AC_HELP_STRING([--with-macosx-version-min], [Force the Mac Version]),                     , with_macosx_version_min=no)
AC_ARG_WITH(dll,            AC_HELP_STRING([--with-dll],            [Do not link to libmediainfo, dynamic loading]), , with_dll=no)

dnl #########################################################################
dnl ### Options from elsewhere
dnl #########################################################################

dnl -------------------------------------------------------------------------
dnl Unicode
dnl
if test -e ../../../../ZenLib/Project/GNU/Library/libzen-config; then
	enable_unicode="$(../../../../ZenLib/Project/GNU/Library/libzen-config Unicode)"
else
	if pkg-config --exists libzen; then
		enable_unicode="$(pkg-config --variable=Unicode libzen)"
	else
		AC_MSG_ERROR([libzen configuration is not found])
	fi
fi

dnl #########################################################################
dnl ### Parsing options
dnl #########################################################################

dnl -------------------------------------------------------------------------
dnl avfctl
dnl
host_mac=no
case "${host_os}" in
    darwin*)
        host_mac=yes
        ;;
esac

AM_CONDITIONAL([BUILD_AVFCTL], [test "$host_mac" = "yes" -a "$enable_avfctl" = "yes"])
if test "$host_mac" = "yes" -a "$enable_avfctl" = "yes" ; then
    AC_DEFINE(ENABLE_AVFCTL)

fi

dnl #########################################################################
dnl ### MediaInfo flags
dnl #########################################################################


dnl #########################################################################
dnl ### C/C++ compiler options used to compile
dnl #########################################################################

dnl -------------------------------------------------------------------------
dnl Unicode
dnl
if test "$enable_unicode" = "yes"; then
	AC_DEFINE(UNICODE)
	MediaInfo_CXXFLAGS="$MediaInfo_CXXFLAGS -DUNICODE"
	MediaInfo_Unicode="yes"
else
	MediaInfo_Unicode="no"
fi

dnl -------------------------------------------------------------------------
dnl Use DLL
dnl
if test "$with_dll" = "yes"; then
	AC_DEFINE(MEDIAINFO_DLL)
	LIBS="$LIBS -ldl"
fi

dnl -------------------------------------------------------------------------
dnl GNU compiler
dnl
if test "$GXX" = yes ; then
	if test "$enable_debug" = "yes"; then
		CFLAGS="$CFLAGS -O0 -g -Wall -Wundef"
		CXXFLAGS="$CXXFLAGS -O0 -g -Wall -W -Wundef -Wcast-qual -Wno-ctor-dtor-privacy"
	else
		CFLAGS="$CFLAGS -O2"
		CXXFLAGS="$CXXFLAGS -O2"
	fi
	if test "$enable_gprof" = "yes"; then
		CFLAGS="$CFLAGS -pg -g"
		CXXFLAGS="$CXXFLAGS -pg -g"
	fi
fi

dnl -------------------------------------------------------------------------
dnl Pthreads
dnl
CXXFLAGS="$CXXFLAGS -pthread"
LDFLAGS="$LDFLAGS -lpthread -pthread"

dnl #########################################################################
dnl ### Needed libs
dnl #########################################################################

dnl -------------------------------------------------------------------------
dnl MediaInfoLib
dnl
if test "$with_dll" != "yes"; then
	with_dll="no"
	if test -e ../../../../MediaInfoLib/Project/GNU/Library/libmediainfo.la; then
		CXXFLAGS="$CXXFLAGS $(../../../../MediaInfoLib/Project/GNU/Library/libmediainfo-config CXXFLAGS)"
		if test "$enable_staticlibs" = "yes"; then
			with_mediainfolib="builtin (static)"
			LIBS="$LIBS $(../../../../MediaInfoLib/Project/GNU/Library/libmediainfo-config LIBS_Static)"
		else
			with_mediainfolib="builtin"
			LIBS="$LIBS $(../../../../MediaInfoLib/Project/GNU/Library/libmediainfo-config LIBS)"
		fi
	else
		if pkg-config --exists libmediainfo; then
			CXXFLAGS="$CXXFLAGS $(pkg-config --cflags libmediainfo)"
			if test "$enable_staticlibs" = "yes"; then
				with_mediainfolib="system (static)"
				LIBS="$LIBS $(pkg-config --variable=Libs_Static libmediainfo)"
			else
				with_mediainfolib="system"
				LIBS="$LIBS $(pkg-config --libs libmediainfo)"
			fi
		else
			AC_MSG_ERROR([libmediainfo configuration is not found])
		fi
	fi
else
	with_dll="yes"
	with_mediainfolib="system"
fi

dnl -------------------------------------------------------------------------
dnl ZenLib
dnl
if test -e ../../../../ZenLib/Project/GNU/Library/libzen.la; then
	CXXFLAGS="$CXXFLAGS $(../../../../ZenLib/Project/GNU/Library/libzen-config CXXFLAGS)"
	MediaInfoLib_CXXFLAGS="$MediaInfoLib_CXXFLAGS $(../../../../ZenLib/Project/GNU/Library/libzen-config CXXFLAGS)"
	if test "$enable_staticlibs" = "yes"; then
		with_zenlib="builtin (static)"
		LIBS="$LIBS $(../../../../ZenLib/Project/GNU/Library/libzen-config LIBS_Static)"
	else
		with_zenlib="builtin"
		LIBS="$LIBS $(../../../../ZenLib/Project/GNU/Library/libzen-config LIBS)"
	fi
else
	if pkg-config --exists libzen; then
		CXXFLAGS="$CXXFLAGS $(pkg-config --cflags libzen)"
		MediaInfoLib_CXXFLAGS="$MediaInfoLib_CXXFLAGS $(pkg-config --cflags libzen)"
		if test "$enable_staticlibs" = "yes"; then
			with_zenlib="system (static)"
			LIBS="$LIBS $(pkg-config --variable=Libs_Static libzen)"
		else
			with_zenlib="system"
			LIBS="$LIBS $(pkg-config --libs libzen)"
		fi
	else
		AC_MSG_ERROR([libzen configuration is not found])
	fi
fi

dnl #########################################################################
dnl ### Compiler specific
dnl #########################################################################

dnl -------------------------------------------------------------------------
case "${build}" in
  powerpc-montavista* )
    CFLAGS="$CFLAGS -D__MONTAVISTA__"
    CXXFLAGS="$CXXFLAGS -D__MONTAVISTA__"
  ;;
esac

dnl -------------------------------------------------------------------------
dnl Mac Architecture and SDK
dnl
if test "$enable_universal_binary" = "yes"; then
	enable_arch_ppc=yes
	enable_arch_i386=yes
	if test "$with_macosx_sdk" = no ; then
		with_macosx_sdk="/Developer/SDKs/MacOSX10.5.sdk"
	fi
	if test "$with_macosx_version_min" = no ; then
		with_macosx_version_min="10.5"
	fi
fi
if test "$enable_arch_ppc" = "yes"; then
	CXXFLAGS="$CXXFLAGS -arch ppc"
	CFLAGS="$CFLAGS -arch ppc"
	LDFLAGS="$LDFLAGS -arch ppc"
fi
if test "$enable_arch_i386" = "yes"; then
	CXXFLAGS="$CXXFLAGS -arch i386"
	CFLAGS="$CFLAGS -arch i386"
	LDFLAGS="$LDFLAGS -arch i386"
fi
if test "$enable_arch_x86_64" = "yes"; then
	CXXFLAGS="$CXXFLAGS -arch x86_64"
	CFLAGS="$CFLAGS -arch x86_64"
	LDFLAGS="$LDFLAGS -arch x86_64"
fi
if test "$with_macosx_sdk" = "yes" ; then
	CXXFLAGS="-isysroot /Developer/SDKs/MacOSX10.5.sdk $CXXFLAGS"
	CFLAGS="-isysroot /Developer/SDKs/MacOSX10.5.sdk $CFLAGS"
	LDFLAGS="-isysroot /Developer/SDKs/MacOSX10.5.sdk $LDFLAGS"
elif test "x$with_macosx_sdk" != xno ; then
	CXXFLAGS="-isysroot $with_macosx_sdk $CXXFLAGS"
	CFLAGS="-isysroot $with_macosx_sdk $CFLAGS"
	LDFLAGS="-isysroot $with_macosx_sdk $LDFLAGS"
fi
if test "x$with_macosx_version_min" != xno ; then
	CXXFLAGS="-mmacosx-version-min=$with_macosx_version_min $CXXFLAGS"
	CFLAGS="-mmacosx-version-min=$with_macosx_version_min $CFLAGS"
	LDFLAGS="-mmacosx-version-min=$with_macosx_version_min $LDFLAGS"
fi

dnl #########################################################################
dnl ### Output
dnl #########################################################################

AC_OUTPUT(Makefile)

dnl #########################################################################
dnl ### Report how we have been configured
dnl #########################################################################

echo ""
echo "Configured DVRescue for '$build'"
echo ""
echo "  Unicode?                                                $enable_unicode"
echo "  Using libzen?                                           $with_zenlib"
echo "  Using libmediainfo?                                     $with_mediainfolib"
echo ""
echo "  libmediainfo dynamicly loaded?                          $with_dll"
echo ""
echo "  CXXFLAGS: $CXXFLAGS"
echo "  LIBS: $LIBS"
