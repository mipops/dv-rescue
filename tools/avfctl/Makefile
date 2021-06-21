all: avfctl

clean:
		rm *.o

avfctl: ../../Source/Common/AvfCtl.o main.o
		gcc -Wall -framework IOKit -framework Foundation -framework AVFoundation -framework CoreMedia -o $@ $(LDFLAGS) $^

%.o: %.m
		gcc -Wall -I../../Source -c -fobjc-arc -I. -o $@ $(CFLAGS) $<
