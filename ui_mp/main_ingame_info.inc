#define INFO_SPACE 10
#define INFO_SIDE_W ((MAIN_W*0.5)-(INFO_SPACE*2))
#define INFO_SIDE_H (MAIN_H-(INFO_SPACE*2))

#define INFO_ITEM_W INFO_SIDE_W
#define INFO_ITEM_H 20

#define INFO_X (MAIN_X+INFO_SPACE)
#define INFO_Y (MAIN_Y+INFO_SPACE)

#define INFO_ARROW_SIZE 16

#define INFO_LINE( num, side, page ) \
	T_DYNAMIC( (INFO_X+(side*(INFO_SIDE_W+(INFO_SPACE*2)))), (INFO_Y+(num*INFO_ITEM_H)), INFO_ITEM_W, INFO_ITEM_H, DvarString("MAIN_info_"+page+"_"+side+"_"+num), FONTSCALE_16, C_TEXT, ITEM_ALIGN_MIDDLE_LEFT, when( DvarBool( "MAIN_visInfo" ) && DvarInt( "MAIN_infoP_"+side ) == page ) ) \

#define INFO_MOVEBUTTONS( side, start, end, side_s, start_s, end_s ) \
itemDef \
{ \
	rect			(((INFO_X+(INFO_SIDE_W*0.5))-INFO_ARROW_SIZE-INFO_ARROW_SIZE)+(side*((INFO_SPACE*2)+(INFO_SIDE_W*1)))) ((INFO_Y+INFO_SIDE_H)-(INFO_ARROW_SIZE*0.5)) INFO_ARROW_SIZE INFO_ARROW_SIZE 0 0 \
	type			ITEM_TYPE_BUTTON \
	style 			WINDOW_STYLE_SHADER \
	background		"ui_arrow_left" \
	forecolor		1 1 1 0.75 \
	visible			when( DvarBool( "MAIN_visInfo" ) && DvarInt( "MAIN_infoP_" + side ) == end && DvarInt( "MAIN_infoPC_" + side ) >= end ) \
	mouseEnter		{ setcolor forecolor 0 1 1 1; } \
	mouseExit		{ setcolor forecolor 1 1 1 0.75; } \
	action			{ play "mouse_click"; execNow "set MAIN_infoP_"side_s" "start_s; } \
}	 \
itemDef \
{ \
	rect			(((INFO_X+(INFO_SIDE_W*0.5))+INFO_ARROW_SIZE)+(side*((INFO_SPACE*2)+(INFO_SIDE_W*1)))) ((INFO_Y+INFO_SIDE_H)-(INFO_ARROW_SIZE*0.5)) INFO_ARROW_SIZE INFO_ARROW_SIZE 0 0 \
	type			ITEM_TYPE_BUTTON \
	style 			WINDOW_STYLE_SHADER \
	background		"ui_arrow_right" \
	forecolor		1 1 1 0.75 \
	visible			when( DvarBool( "MAIN_visInfo" ) && DvarInt( "MAIN_infoP_" + side ) == start && DvarInt( "MAIN_infoPC_" + side ) >= end ) \
	mouseEnter		{ setcolor forecolor 0 1 1 1; } \
	mouseExit		{ setcolor forecolor 1 1 1 0.75; } \
	action			{ play "mouse_click"; execNow "set MAIN_infoP_"side_s" "end_s; } \
}	

// left side
//INFO_MOVEBUTTONS( 0, 0, 1, "0", "0", "1" )
//INFO_MOVEBUTTONS( 0, 1, 2, "0", "1", "2" )

// right side
INFO_MOVEBUTTONS( 1, 0, 1, "1", "0", "1" )
INFO_MOVEBUTTONS( 1, 1, 2, "1", "1", "2" )

#define INFO_LINE_LEFTSIDE( page ) \
	INFO_LINE( 0, 0, page ) \
	INFO_LINE( 1, 0, page ) \
	INFO_LINE( 2, 0, page ) \
	INFO_LINE( 3, 0, page ) \
	INFO_LINE( 4, 0, page ) \
	INFO_LINE( 5, 0, page ) \
	INFO_LINE( 6, 0, page ) \
	INFO_LINE( 7, 0, page ) \
	INFO_LINE( 8, 0, page ) \
	INFO_LINE( 9, 0, page ) \
	INFO_LINE( 10, 0, page ) \
	INFO_LINE( 11, 0, page ) \
	INFO_LINE( 12, 0, page ) \
	INFO_LINE( 13, 0, page ) \
	INFO_LINE( 14, 0, page ) \
	INFO_LINE( 15, 0, page ) \
	INFO_LINE( 16, 0, page ) \

#define INFO_LINE_RIGHTSIDE( page ) \
	INFO_LINE( 0, 1, page ) \
	INFO_LINE( 1, 1, page ) \
	INFO_LINE( 2, 1, page ) \
	INFO_LINE( 3, 1, page ) \
	INFO_LINE( 4, 1, page ) \
	INFO_LINE( 5, 1, page ) \
	INFO_LINE( 6, 1, page ) \
	INFO_LINE( 7, 1, page ) \
	INFO_LINE( 8, 1, page ) \
	INFO_LINE( 9, 1, page ) \
	INFO_LINE( 10, 1, page ) \
	INFO_LINE( 11, 1, page ) \
	INFO_LINE( 12, 1, page ) \
	INFO_LINE( 13, 1, page ) \
	INFO_LINE( 14, 1, page ) \
	INFO_LINE( 15, 1, page ) \
	INFO_LINE( 16, 1, page ) \
	
INFO_LINE_LEFTSIDE( 0 )

INFO_LINE_RIGHTSIDE( 0 )
INFO_LINE_RIGHTSIDE( 1 )
INFO_LINE_RIGHTSIDE( 2 )