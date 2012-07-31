 
//===========================================================================
//
//      File:       OPTREX_LIB.C
//
//      Purpose:    Axiom 68HC11 LCD Routines for Optrex Displays
//
//      Version:    1.20
//
//      Date:       March 13, 2001
//
//      Author:     Wayne Mah
//
//      Compiler:   ImageCraft C
//
//---------------------------------------------------------------------------
//
//      History:    0.90    99/01/31    Genesis
//                  1.00    00/12/10    Update
//                  1.10    01/02/17    Update
//                  1.11    01/03/11    Renamed to OPTREX_LIB.C
//                  1.20    01/03/12    Update
//
//===========================================================================

#include <stdio.h>
#include <lib_optrex.h>

//----------------------------------------------
//  LCD is memory mapped on the CMD/CMM boards
//----------------------------------------------

#define OPTREX_CMDREG  *(unsigned char volatile *)(0xB5F0)
#define OPTREX_DATAREG *(unsigned char volatile *)(0xB5F1)


//---------------
//  local globs
//---------------

unsigned char g_dispmode;


//-----------------------------
//  Local Function Prototypes
//-----------------------------

void OptrexBusy(void);



//---------------------------------------------------------------------------
//  LCD Initialization
//---------------------------------------------------------------------------

void OptrexInit(void)
{
    g_dispmode = 0x0c;

    OptrexCommand(0x3C);                   // initialize command
    OptrexCommand(g_dispmode);             // display on, cursor off
    OptrexCommand(0x06);

    OptrexClear();
}


void OptrexWriteString(char *sptr)
{
	while(*sptr)
		OptrexWrite(*sptr++);
}



//-----------------------------------------------------------------------
//
//  OptrexClear()
//
//  Writes the space code 0x20 into all addresses of DDRAM.  Returns
//  display to its original position if it was shifted.  In other words,
//  the display clears and the cursor or blink moves to the upper left
//  edge of the display.  The execution of clear display set entry mode
//  to incremental mode.
//
//-----------------------------------------------------------------------

void OptrexClear(void)
{
    OptrexCommand(0x01);
}

void OptrexClearEOL(void)
{
    unsigned char start_addr, end_addr, i;

    start_addr = OptrexGetAddress();

    if (start_addr >= 0x00 && start_addr <= 0x13)
    {
        end_addr = 0x13;
    }
    else if (start_addr >= 0x40 && start_addr <= 0x53)
    {
        end_addr = 0x53;
    }
    else if (start_addr >= 0x14 && start_addr <= 0x27)
    {
        end_addr = 0x27;
    }
    if (start_addr >= 0x54 && start_addr <= 0x67)
    {
        end_addr = 0x67;
    }

    for (i = start_addr; i <= end_addr; i++)
    {
        OptrexWrite(' ');
    }

    OptrexSetAddress(start_addr);
}




//-----------------------------------------------------------------------
//
//  OptrexHome()
//
//  Set the DDRAM address "0" in address counter.  Return display to its
//  original position if it was shifted.  DDRAM contents do not change.
//
//  The cursor or the blink moves to teh upper left edge of the display.
//  Text on the display remains unchanged.
//
//-----------------------------------------------------------------------

void OptrexHome(void)
{
    OptrexCommand(0x02);
}


//-----------------------------------------------------------------------
//
//  OptrexEntryMode()
//
//  Sets the INC/DEC and shift modes to the desired settings.
//
//  Bit 1 = 1 increments, Bit1 = 0 decrements the DDRAM address by 1
//  when a character code is written into or read from the DDRAM
//
//-----------------------------------------------------------------------
 void OptrexEntryMode(char mode)
{
    OptrexCommand(0x04|(0x03&mode));
}


void OptrexSetBlink(char val)
{
    OptrexSetDisplayControl((g_dispmode & ~0x01) | (val & 1));
}

void OptrexSetCursor(char val)
{
    OptrexSetDisplayControl((g_dispmode & ~0x02) | ((val & 1) << 1));
}

void OptrexSetDisplay(char val)
{
    OptrexSetDisplayControl((g_dispmode & ~0x04) | ((val & 1) << 2));
}

void OptrexSetDisplayControl(char val)
{
    OptrexCommand(0x08|val);
    
    g_dispmode = val;
}

void OptrexSetAddress(unsigned char addr)
{
    OptrexCommand(0x80|addr);              // set DDRAM address
}

unsigned char OptrexGetAddress(void)
{
   return (OPTREX_CMDREG & 0x7f);
}

void OptrexWrite(char dval)
{
    OptrexBusy();                          // wait for busy to clear
    OPTREX_DATAREG = dval;                 // ouptut data
}


void OptrexGotoXY(char x, char y)
{
    char addr;

    switch (y)
    {
        case 0 : addr = 0x00; break;
        case 1 : addr = 0x40; break;
        case 2 : addr = 0x14; break;
        case 3 : addr = 0x54; break;
    }

    addr += x;

    OptrexSetAddress(addr);
}


void OptrexCommand(unsigned char cval)
{
    OptrexBusy();                          // wait for busy to clear
    OPTREX_CMDREG = cval;                  // output command
}


//
//               ***************************************
//               *   local functions after this point  *
//               ***************************************
//


//---------------------------------------------------------------------------
//  Wait for the LCD busy pin to clear
//---------------------------------------------------------------------------

void OptrexBusy(void)
{
    while (OPTREX_CMDREG & 0x80);
}
