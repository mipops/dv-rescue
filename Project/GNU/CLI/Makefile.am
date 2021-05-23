AUTOMAKE_OPTIONS = foreign

bin_PROGRAMS = dvrescue
dvrescue_SOURCES = \
    ../../../Source/CLI/CLI_Help.cpp \
    ../../../Source/CLI/CLI_Main.cpp \
    ../../../Source/CLI/CommandLine_Parser.cpp \
    ../../../Source/Common/Core.cpp \
    ../../../Source/Common/Merge.cpp \
    ../../../Source/Common/Output.cpp \
    ../../../Source/Common/Output_Captions_Decode.cpp \
    ../../../Source/Common/Output_Captions_Scc.cpp \
    ../../../Source/Common/Output_Xml.cpp \
    ../../../Source/Common/Output_Webvtt.cpp \
    ../../../Source/Common/ProcessFile.cpp \
    ../../../Source/ThirdParty/ccdecoder/ccdecoder_internal.c \
    ../../../Source/ThirdParty/ccdecoder/ccdecoder_line21.c \
    ../../../Source/ThirdParty/ccdecoder/ccdecoder_line21field.c \
    ../../../Source/ThirdParty/ccdecoder/ccdecoder_onscreen.c \
    ../../../Source/ThirdParty/ccdecoder/ccdecoder_subrip.c \
    ../../../Source/ThirdParty/TimeCode/TimeCode.cpp

INCLUDES = -I../../../Source \
           -I../../../Source/ThirdParty/ccdecoder \
           -I../../../Source/ThirdParty/TimeCode \
           -I../../../../MediaInfoLib/Source \
           -I../../../../ZenLib/Source
AM_CXXFLAGS = -std=c++11

bin_SCRIPTS = \
    ../../../tools/dvloupe \
    ../../../tools/dvmap \
    ../../../tools/dvpackager \
    ../../../tools/dvplay \
    ../../../tools/dvsampler

if BUILD_AVFCTL
    dvrescue_SOURCES += \
        ../../../Source/Common/AvfCtl.m \
        ../../../Source/Common/AvfCtlWrapper.mm \
        ../../../Source/Common/ProcessFileWrapper.cpp
    dvrescue_LDFLAGS = -framework IOKit -framework Foundation -framework AVFoundation -framework CoreMedia

    AVFCTL = ../../../tools/avfctl/avfctl
    $(AVFCTL):
	$(MAKE) -C ../../../tools/avfctl
    all: $(AVFCTL)

    bin_SCRIPTS += ../../../tools/avfctl/avfctl
endif

# man1_MANS = ../../../Source/CLI/dvrescue.1

AM_TESTS_FD_REDIRECT = 9>&2

TESTS = test/simple.sh test/xml.sh test/webvtt.sh test/captions.sh test/framediscontinuity.sh

TESTING_DIR = test/TestingFiles

clone_testing_files: $(TESTING_DIR)

$(TESTING_DIR):
	git clone https://github.com/MediaArea/dvrescue-sample-data.git test/TestingFiles
