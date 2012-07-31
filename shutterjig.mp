
Area                               Addr   Size   Decimal Bytes (Attributes)
--------------------------------   ----   ----   ------- ----- ------------
                            text   E000   163D =   5693. bytes (rel,con,rom)

       Addr  Global Symbol
      -----  --------------------------------
       E000  __start
       E02D  _exit
       E02F  _main
       E197  _sc_init
       E1A4  _sc_acquire_buttons
       E1B1  _sc_get_buttons
       E1C6  _sc_set_driver
       E1FA  _sc_get_driver
       E208  _TimerInit
       E236  _TimerTOC2Isr
       E371  _TimerSleep
       E3BE  __HC11Setup
       E44A  _OptrexInit
       E466  _OptrexWriteString
       E490  _OptrexClear
       E497  _OptrexClearEOL
       E508  _OptrexHome
       E50F  _OptrexEntryMode
       E527  _OptrexSetBlink
       E545  _OptrexSetCursor
       E564  _OptrexSetDisplay
       E584  _OptrexSetDisplayControl
       E59F  _OptrexSetAddress
       E5B5  _OptrexGetAddress
       E5BC  _OptrexWrite
       E5D2  _OptrexGotoXY
       E621  _OptrexCommand
       E637  _OptrexBusy
       E643  __print
       EC6C  __divu
       EC74  __divi
       EC9F  __modu
       ECA6  __modi
       ECCB  __muli
       ECCB  __mulu
       ED04  __enterb
       ED2B  __movspb
       ED4D  _itoa
       EDDB  _ltoa
       EEB4  __ly2reg
       EECB  __ly2reg_x
       EEDA  __ly2reg2
       EEF1  __lreg2y
       EF08  __lreg22y
       EF1F  __lregmov
       EF34  __d2lreg
       EF4D  __d2lreg2
       EF66  __ud2lreg
       EF79  __ud2lreg2
       EF8C  __lreg2d
       EF99  __lret
       EFB9  __pshlr1
       EFD7  __pshlr2
       EFF5  __pullr1
       F013  __pullr2
       F031  __ladd
       F04C  __lsub
       F067  __lmul
       F12F  __ldiv
       F14C  __ludiv
       F16A  __lmod
       F18B  __lumod
       F1AC  __llsh
       F1CB  __lilsh
       F1E4  __lrsh
       F203  __lirsh
       F21C  __lursh
       F23B  __luirsh
       F254  __land
       F271  __lor
       F28E  __lxor
       F2AB  __lneg
       F2C8  __lneg2
       F30F  __lcom
       F320  __lcmp
       F348  _strcpy
       F383  _sprintf
       F3CE  __va_start
       F3F1  _toupper
       F416  _strlen
       F445  __ctype
       F546  _isspace
       F563  _isdigit
       F580  _islower
       F59D  _atoi
       F63D  __text_end

Area                               Addr   Size   Decimal Bytes (Attributes)
--------------------------------   ----   ----   ------- ----- ------------
                           idata   F63D   0001 =      1. bytes (rel,con,rom)

       Addr  Global Symbol
      -----  --------------------------------
       F63D  __idata_start
       F63E  __idata_end

Area                               Addr   Size   Decimal Bytes (Attributes)
--------------------------------   ----   ----   ------- ----- ------------
                            data   2000   0001 =      1. bytes (rel,con,rom)

       Addr  Global Symbol
      -----  --------------------------------
       2000  __data_start
       2001  __data_end

Area                               Addr   Size   Decimal Bytes (Attributes)
--------------------------------   ----   ----   ------- ----- ------------
                             bss   2001   001E =     30. bytes (rel,con,rom)

       Addr  Global Symbol
      -----  --------------------------------
       2001  __bss_start
       2001  _old_buttons
       2002  _new_buttons
       2003  _g_flipside
       2004  _gTimerTicks
       2008  _gPulseTarget
       200C  _gFlipTarget
       2010  _g_etime_secs
       2011  _g_etime_mins
       2012  _g_etime_hours
       2014  _gTimerSeconds
       2018  _g_scycles
       201C  _g_dispmode
       201F  __bss_end

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

