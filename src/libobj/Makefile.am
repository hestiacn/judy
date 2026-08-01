AM_CFLAGS = @WARN_CFLAGS@

CLEANFILES = libJudy.la

include_HEADERS = ../Judy.h

lib_LTLIBRARIES = libJudy.la

libJudy_la_SOURCES =

libJudy_la_LIBADD = $(top_builddir)/src/JudyCommon/*.lo \
					$(top_builddir)/src/JudyL/*.lo \
					$(top_builddir)/src/Judy1/*.lo \
					$(top_builddir)/src/JudyHS/*.lo \
					$(top_builddir)/src/JudySL/*.lo

libJudy_la_LDFLAGS = @VERSION_INFO@

DISTCLEANFILES = .deps Makefile
