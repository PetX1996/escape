P_BLACKSCREEN( 1 )

#define MAIN_MAP_X 0
#define MAIN_MAP_Y 0
#define MAIN_MAP_W 640
#define MAIN_MAP_H 18
#define MAIN_MAP_SPACE 4

#define MAIN_GAME_X 0
#define MAIN_GAME_Y (MAIN_MAP_Y+MAIN_MAP_H)
#define MAIN_GAME_W 640
#define MAIN_GAME_H 45

#define MAIN_MOD_W 640
#define MAIN_MOD_H 18
#define MAIN_MOD_SPACE 4
#define MAIN_MOD_X 0
#define MAIN_MOD_Y (480-MAIN_MOD_H)

#define MAIN_BOTTOM_W 640
#define MAIN_BOTTOM_H 30
#define MAIN_BOTTOM_X 0
#define MAIN_BOTTOM_Y (480-MAIN_MOD_H-MAIN_BOTTOM_H)
#define MAIN_BOTTOM_ITEM_C 9
#define MAIN_BOTTOM_ITEM_W (MAIN_BOTTOM_W/MAIN_BOTTOM_ITEM_C)

#define MAIN_X 0
#define MAIN_Y (MAIN_MAP_H+MAIN_GAME_H)
#define MAIN_W 640
#define MAIN_H (480-(MAIN_MAP_H+MAIN_GAME_H+MAIN_BOTTOM_H+MAIN_MOD_H))

// ================================================================================================================================================================================================= //
// MAP & GAMETYPE
P_BACKGROUND( MAIN_MAP_X, MAIN_MAP_Y, MAIN_MAP_W, MAIN_MAP_H, 1 ) // bg
P_BACKGROUND( MAIN_MAP_X, MAIN_MAP_Y, MAIN_MAP_W, MAIN_MAP_H, 1 ) // bg
T_DYNAMIC( (MAIN_MAP_X+MAIN_MAP_SPACE), MAIN_MAP_Y, MAIN_MAP_W, MAIN_MAP_H, DvarString( "ui_mapFullName" ), FONTSCALE_14, C_TEXT, ITEM_ALIGN_MIDDLE_LEFT, 1 ) // map name
T_DYNAMIC( MAIN_MAP_X, MAIN_MAP_Y, (MAIN_MAP_W-MAIN_MAP_SPACE), MAIN_MAP_H, DvarString( "ui_gameTypeFullName" ), FONTSCALE_14, C_TEXT, ITEM_ALIGN_MIDDLE_RIGHT, 1 ) // gametype name


// ================================================================================================================================================================================================= //
// PLAY & SPECTATOR
P_BACKGROUND( MAIN_GAME_X, MAIN_GAME_Y, MAIN_GAME_W, MAIN_GAME_H, 1 ) // bg
P_BORDER( MAIN_GAME_X, ((MAIN_GAME_Y+MAIN_GAME_H)-INI_LINE_SIZE), MAIN_GAME_W, INI_LINE_SIZE, 1 ) // bottom line

P_BORDER( MAIN_GAME_X, MAIN_GAME_Y, (MAIN_GAME_W*0.5), (MAIN_GAME_H-INI_LINE_SIZE), when( team( name ) != "TEAM_SPECTATOR" ) ) // play highlight
P_BORDER( (MAIN_GAME_X+(MAIN_GAME_W*0.5)), MAIN_GAME_Y, (MAIN_GAME_W*0.5), (MAIN_GAME_H-INI_LINE_SIZE), when( team( name ) == "TEAM_SPECTATOR" ) ) // sepcator highlight

BTN_T_CENTER_STATIC( MAIN_GAME_X, MAIN_GAME_Y, (MAIN_GAME_W*0.5), (MAIN_GAME_H-INI_LINE_SIZE), "Play", FONTSCALE_40, scriptMenuResponse "play"; close self;, ;, ;, 1 )
BTN_T_CENTER_STATIC( (MAIN_GAME_X+(MAIN_GAME_W*0.5)), MAIN_GAME_Y, (MAIN_GAME_W*0.5), (MAIN_GAME_H-INI_LINE_SIZE), "Spectator", FONTSCALE_40, scriptMenuResponse "spectator"; close self;, ;, ;, 1 )


// ================================================================================================================================================================================================= //
// BOTTOM PANEL
P_BACKGROUND( MAIN_BOTTOM_X, MAIN_BOTTOM_Y, MAIN_BOTTOM_W, MAIN_BOTTOM_H, 1 ) // bg
P_BORDER( MAIN_BOTTOM_X, MAIN_BOTTOM_Y, MAIN_BOTTOM_W, INI_LINE_SIZE, 1 ) // bg

itemDef // pointer
{
	rect			0 (MAIN_BOTTOM_Y+INI_LINE_SIZE) MAIN_BOTTOM_ITEM_W (MAIN_BOTTOM_H-INI_LINE_SIZE) 0 0
	exp				rect X( MAIN_BOTTOM_X + MAIN_BOTTOM_ITEM_W * DvarInt( "MAIN_sel" ) );
	style			WINDOW_STYLE_FILLED
	backcolor		C_HIGHLIGHT
	visible			1
}
#define MAIN_BOTTOM_BUTTON( num, num_s, T, onClick ) \
	BTN_T_CENTER_STATIC( (MAIN_BOTTOM_X+(MAIN_BOTTOM_ITEM_W*num)), (MAIN_BOTTOM_Y+INI_LINE_SIZE), MAIN_BOTTOM_ITEM_W, (MAIN_BOTTOM_H-INI_LINE_SIZE), T, FONTSCALE_22, execNow "set MAIN_visInfo 0; set MAIN_sel "num_s; onClick, ;, ;, 1 ) \

MAIN_BOTTOM_BUTTON( 0, "0", "Rank", ; )
MAIN_BOTTOM_BUTTON( 1, "1", "Class", scriptMenuResponse "c_open_allies"; )

MAIN_BOTTOM_BUTTON( 3, "3", "Voting", ; )
MAIN_BOTTOM_BUTTON( 4, "4", "Controls", open main_controls; close self; )
MAIN_BOTTOM_BUTTON( 5, "5", "Options", open main_options; execnow "set ui_allow_graphic_change 0"; close self; )

MAIN_BOTTOM_BUTTON( 7, "7", "About", execNow "exec client_cfg/mainAbout.cfg; set MAIN_infoP 0; set MAIN_visInfo 1"; )
MAIN_BOTTOM_BUTTON( 8, "8", "Quit", open popup_quit; )


// ================================================================================================================================================================================================= //
// ESCAPE & 4GF
P_BACKGROUND( MAIN_MOD_X, MAIN_MOD_Y, MAIN_MOD_W, MAIN_MOD_H, 1 ) // bg
P_BACKGROUND( MAIN_MOD_X, MAIN_MOD_Y, MAIN_MOD_W, MAIN_MOD_H, 1 ) // bg
T_DYNAMIC( (MAIN_MOD_X+MAIN_MOD_SPACE), MAIN_MOD_Y, MAIN_MOD_W, MAIN_MOD_H, DvarString( "ui_modVerFull" ), FONTSCALE_14, C_TEXT, ITEM_ALIGN_MIDDLE_LEFT, 1 ) // mod version
T_STATIC( MAIN_MOD_X, MAIN_MOD_Y, (MAIN_MOD_W-MAIN_MOD_SPACE), MAIN_MOD_H, "www.4GF.cz", FONTSCALE_14, C_TEXT, ITEM_ALIGN_MIDDLE_RIGHT, 1 ) // 4gf