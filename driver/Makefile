all: ArcusPerformaxDriver.so

clean:
	rm -f *.o *~ *.so

ArcusPerformaxDriver.o: ArcusPerformaxDriver.c ArcusPerformaxDriver.h
	$(CC) -Wall -O2 -fPIC -I. `pkg-config libusb-1.0 --cflags` -c $< -o $@

ArcusPerformaxDriver.so: ArcusPerformaxDriver.o
	$(CC) -shared $< -o $@ `pkg-config libusb-1.0 --libs`

.PHONY: clean all
