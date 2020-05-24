#define VOTING_W 200
#define VOTING_H 100
#define VOTING_X (MAIN_X+((MAIN_W-VOTING_W)*0.5))
#define VOTING_Y (MAIN_Y+((MAIN_H-VOTING_H)*0.5))

#include "ui_mp/macro_tab_clean.inc"
#define TAB_X VOTING_X
#define TAB_Y VOTING_Y
#define TAB_W VOTING_W
#define TAB_H VOTING_H
#define TAB_ORIENT TAB_ORIENT_VERTICAL
#define TAB_BORDER TAB_BORDER_FULL
#define TAB_BUTTONS 2
#define TAB_SEPARATORS 0
#define TAB_SELECTED_DVAR "VOTING_sel"
#define TAB_VIS (DvarInt( "MAIN_sel" ) == 3)

#include "ui_mp/macro_tab_process.inc"
TAB_BUTTON( 0, "0", "End Map", FONTSCALE_22, scriptMenuResponse "VOTE_endMap";, ;, ;, 1 )
TAB_BUTTON( 1, "1", "Add Bots", FONTSCALE_22, scriptMenuResponse "VOTE_addBots";, ;, ;, 1 )