//===========================================================================
//
//      File:       LIB_OPTREX.H
//
//      Purpose:    Axiom 68HC11 LCD Function Prototypes for Optrex Displays
//
//      Version:    1.20
//
//      Date:       2012-06-19
//
//      Author:     Corey Davyduke
//
//      Compiler:   ImageCraft C
//
//---------------------------------------------------------------------------
//
//      History:    1.0    2012-06-19    Genesis
//
//===========================================================================



//#include <stdio.h>
//#include "lib_optrex.h"


//----------------------------------------------
//  LCD is memory mapped on the CMD/CMM boards
//----------------------------------------------

//#define OPTREX_CMDREG  *(unsigned char volatile *)(0xB5F0)
//#define OPTREX_DATAREG *(unsigned char volatile *)(0xB5F1)


//---------------
//  local globs
//---------------

//unsigned char g_dispmode;


//-----------------------------
//  Local Function Prototypes
//-----------------------------

//void OptrexBusy(void);



//---------------------------------------------------------------------------
//  LCD Initialization
//---------------------------------------------------------------------------

void OptrexInit(void);
void OptrexWriteString(char *);
void OptrexClear(void);
void OptrexClearEOL(void);
void OptrexHome(void);
void OptrexEntryMode(char);
void OptrexSetBlink(char);
void OptrexSetCursor(char);
void OptrexSetDisplay(char);
void OptrexSetDisplayControl(char);
void OptrexSetAddress(unsigned char);
unsigned char OptrexGetAddress(void);
void OptrexWrite(char);
void OptrexGotoXY(char, char);
void OptrexCommand(unsigned char);
//void OptrexBusy(void);
