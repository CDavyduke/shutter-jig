CC = icc11w
CFLAGS =  -IC:\icc\include\ -Iinclude\ -e  -l 
ASFLAGS = $(CFLAGS) 
LFLAGS =  -LC:\icc\lib\ -btext:0xe000 -bdata:0x2000 -dinit_sp:0x3fff -fmots19
FILES = shutterjig.o lib_optrex.o 

shutterjig:	$(FILES)
	$(CC) -o shutterjig $(LFLAGS) @shutterjig.lk   -llp11
shutterjig.o: C:/icc/include/hc11.h include/lib_optrex.h include/lib_timer.h
shutterjig.o:	C:\Projects\ShutterJig\shutterjig.c
	$(CC) -c $(CFLAGS) C:\Projects\ShutterJig\shutterjig.c
lib_optrex.o: C:/icc/include/stdio.h C:/icc/include/stdarg.h C:/icc/include/_const.h include/lib_optrex.h
lib_optrex.o:	C:\Projects\ShutterJig\lib_optrex.c
	$(CC) -c $(CFLAGS) C:\Projects\ShutterJig\lib_optrex.c
