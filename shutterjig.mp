
Area                               Addr   Size   Decimal Bytes (Attributes)
--------------------------------   ----   ----   ------- ----- ------------
                            text   E000   180C =   6156. bytes (rel,con,rom)

       Addr  Global Symbol
      -----  --------------------------------
       E000  __start
       E02D  _exit
       E02F  _main
       E2C0  _sc_init
       E2CD  _sc_get_buttons
       E2E2  _sc_set_driver
       E316  _sc_get_driver
       E324  _TimerInit
       E352  _TimerTOC2Isr
       E511  _TimerSleep
       E55E  __HC11Setup
       E619  _OptrexInit
       E635  _OptrexWriteString
       E65F  _OptrexClear
       E666  _OptrexClearEOL
       E6D7  _OptrexHome
       E6DE  _OptrexEntryMode
       E6F6  _OptrexSetBlink
       E714  _OptrexSetCursor
       E733  _OptrexSetDisplay
       E753  _OptrexSetDisplayControl
       E76E  _OptrexSetAddress
       E784  _OptrexGetAddress
       E78B  _OptrexWrite
       E7A1  _OptrexGotoXY
       E7F0  _OptrexCommand
       E806  _OptrexBusy
       E812  __print
       EE3B  __divu
       EE43  __divi
       EE6E  __modu
       EE75  __modi
       EE9A  __muli
       EE9A  __mulu
       EED3  __enterb
       EEFA  __movspb
       EF1C  _itoa
       EFAA  _ltoa
       F083  __ly2reg
       F09A  __ly2reg_x
       F0A9  __ly2reg2
       F0C0  __lreg2y
       F0D7  __lreg22y
       F0EE  __lregmov
       F103  __d2lreg
       F11C  __d2lreg2
       F135  __ud2lreg
       F148  __ud2lreg2
       F15B  __lreg2d
       F168  __lret
       F188  __pshlr1
       F1A6  __pshlr2
       F1C4  __pullr1
       F1E2  __pullr2
       F200  __ladd
       F21B  __lsub
       F236  __lmul
       F2FE  __ldiv
       F31B  __ludiv
       F339  __lmod
       F35A  __lumod
       F37B  __llsh
       F39A  __lilsh
       F3B3  __lrsh
       F3D2  __lirsh
       F3EB  __lursh
       F40A  __luirsh
       F423  __land
       F440  __lor
       F45D  __lxor
       F47A  __lneg
       F497  __lneg2
       F4DE  __lcom
       F4EF  __lcmp
       F517  _strcpy
       F552  _sprintf
       F59D  __va_start
       F5C0  _toupper
       F5E5  _strlen
       F614  __ctype
       F715  _isspace
       F732  _isdigit
       F74F  _islower
       F76C  _atoi
       F80C  __text_end

Area                               Addr   Size   Decimal Bytes (Attributes)
--------------------------------   ----   ----   ------- ----- ------------
                           idata   F80C   0001 =      1. bytes (rel,con,rom)

       Addr  Global Symbol
      -----  --------------------------------
       F80C  __idata_start
       F80D  __idata_end

Area                               Addr   Size   Decimal Bytes (Attributes)
--------------------------------   ----   ----   ------- ----- ------------
                            data   2000   0001 =      1. bytes (rel,con,rom)

       Addr  Global Symbol
      -----  --------------------------------
       2000  __data_start
       2001  __data_end

Area                               Addr   Size   Decimal Bytes (Attributes)
--------------------------------   ----   ----   ------- ----- ------------
                             bss   2001   0028 =     40. bytes (rel,con,rom)

       Addr  Global Symbol
      -----  --------------------------------
       2001  _close_shutter
       2001  __bss_start
       2003  _open_shutter
       2005  _shutter_close
       2007  _shutter_open
       2009  _shutter_closed
       200B  _shutter_opened
       200D  _g_flipside
       200E  _gTimerTicks
       2012  _gPulseTarget
       2016  _gFlipTarget
       201A  _g_etime_secs
       201B  _g_etime_mins
       201C  _g_etime_hours
       201E  _gTimerSeconds
       2022  _g_scycles
       2026  _g_dispmode
       2029  __bss_end

Area                               Addr   Size   Decimal Bytes (Attributes)
--------------------------------   ----   ----   ------- ----- ------------
                          memory   0000   10000 =  65536. bytes (abs,ovr,rom)

       Addr  Global Symbol
      -----  --------------------------------
       FFD6  _interrupt_vectors

Files Linked      [ module(s) ]

C:\icc\lib\crt11.o	[ crt11.s ]
shutterjig.o	[ shutterjig.c ]
lib_optrex.o	[ lib_optrex.c ]
<library>	[ stdio.s, div.s, mod.s, mul.s, byte.s, itoa.s, ltoa.s, long.s, longarth.s, strcpy.s, sprintf.s, stdarg.s ]
[ toupper.s, strlen.s, ctype.s, isspace.s, isdigit.s, islower.s, atoi.s ]

User Global Definitions

init_sp = 0x3fff

User Base Address Definitions

text = 0xe000
data = 0x2000

