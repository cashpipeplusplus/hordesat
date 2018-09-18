WSPACE = 	..

CXXFLAGS =	-O3 -g -Wall -fmessage-length=0 -I$(WSPACE)/submodules/minisat -I$(WSPACE)/submodules/lingeling -D __STDC_LIMIT_MACROS -D __STDC_FORMAT_MACROS

OBJS =		hordesat.o utilities/ClauseFilter.o solvers/MiniSat.o solvers/Lingeling.o utilities/ClauseDatabase.o \
			utilities/SatUtils.o utilities/Logger.o sharing/AllToAllSharingManager.o \
			sharing/LogSharingManager.o

LIBS =		-lz -L$(WSPACE)/submodules/minisat/build/release/lib -lminisat -L$(WSPACE)/submodules/lingeling/ -llgl

TARGET =	hordesat

CXX = 		mpic++

$(TARGET):	$(OBJS)
	$(CXX) -o $(TARGET) $(OBJS) $(LIBS)

all:	$(TARGET)

clean:
	rm -f $(OBJS) $(TARGET)
