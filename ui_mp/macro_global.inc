#include "ui/menudef.h"
#include "ui_mp/style.inc"

#define P_BLACKSCREEN( visInfo ) \
	itemDef \
	{ \
		type			ITEM_TYPE_BUTTON \
		rect			0 0 640 480 0 0 \
		style			WINDOW_STYLE_FILLED \
		backcolor		C_BLACKSCREEN \
		visible			visInfo \
	} \

#define P_BACKGROUND( x, y, w, h, visInfo ) \
	itemDef \
	{ \
		rect			x y w h 0 0 \
		type			ITEM_TYPE_BUTTON \
		style			WINDOW_STYLE_FILLED \
		backcolor		C_BACKGROUND \
		visible			visInfo \
	} \

#define P_BORDER( x, y, w, h, visInfo ) \
	itemDef \
	{ \
		rect			x y w h 0 0 \
		style			WINDOW_STYLE_FILLED \
		backcolor		C_HIGHLIGHT \
		visible			visInfo \
	} \

#define T_STATIC( x, y, w, h, T, Tscale, Tcolor, Talign, visInfo ) \
	itemDef \
	{ \
		rect			x y w h 0 0 \
		style			WINDOW_STYLE_EMPTY \
		forecolor		Tcolor \
		text			T \
		textalign		Talign \
		textscale		Tscale \
		visible			visInfo \
		decoration \
	} \
	
#define T_DYNAMIC( x, y, w, h, T, Tscale, Tcolor, Talign, visInfo ) \
	itemDef \
	{ \
		rect			x y w h 0 0 \
		style			WINDOW_STYLE_EMPTY \
		forecolor		Tcolor \
		exp				text( T ); \
		textalign		Talign \
		textscale		Tscale \
		visible			visInfo \
		decoration \
	} \
	
#define M_STATIC( x, y, w, h, I, Icolor, visInfo ) \
	itemDef \
	{ \
		rect			x y w h 0 0 \
		style			WINDOW_STYLE_SHADER \
		background		I \
		forecolor		Icolor \
		visible			visInfo \
	} \
	
#define M_DYNAMIC( x, y, w, h, I, Icolor, visInfo ) \
	itemDef \
	{ \
		rect			x y w h 0 0 \
		style			WINDOW_STYLE_SHADER \
		exp				material( I ); \
		forecolor		Icolor \
		visible			visInfo \
	} \
	
#define BTN_T_CENTER_STATIC( x, y, w, h, T, Tscale, onClick, onEnter, onExit, visInfo ) \
	itemDef \
	{ \
		type			ITEM_TYPE_BUTTON \
		rect			x y w h 0 0 \
		style			WINDOW_STYLE_FILLED \
		backcolor		C_TRANSPARENT \
		forecolor		C_TEXT \
		text			T \
		textscale		Tscale \
		textalign		ITEM_ALIGN_MIDDLE_CENTER \
		visible			visInfo \
		mouseEnter		{ play "mouse_over"; setcolor backcolor C_HIGHLIGHT; onEnter } \
		mouseExit		{ setcolor backcolor C_TRANSPARENT; onExit } \
		action			{ play "mouse_click"; onClick } \
	} \
	
#define BTN_T_CENTER_DYNAMIC( x, y, w, h, T, Tscale, onClick, onEnter, onExit, visInfo ) \
	itemDef \
	{ \
		type			ITEM_TYPE_BUTTON \
		rect			x y w h 0 0 \
		style			WINDOW_STYLE_FILLED \
		backcolor		C_TRANSPARENT \
		forecolor		C_TEXT \
		exp				text( T ); \
		textscale		Tscale \
		textalign		ITEM_ALIGN_MIDDLE_CENTER \
		visible			visInfo \
		mouseEnter		{ play "mouse_over"; setcolor backcolor C_HIGHLIGHT; onEnter } \
		mouseExit		{ setcolor backcolor C_TRANSPARENT; onExit } \
		action			{ play "mouse_click"; onClick } \
	} \

	
#define TAB_ORIENT_HORIZONTAL 0
#define TAB_ORIENT_VERTICAL 1
	
#define TAB_BORDER_NONE 0
#define TAB_BORDER_FULL 1
#define TAB_BORDER_LEFT 2
#define TAB_BORDER_TOP 3
#define TAB_BORDER_RIGHT 4
#define TAB_BORDER_BOTTOM 5
	
#define TAB_SEPARATOR_FRACTION 0.15
	
#define TAB_SEPARATOR( itemNum ) // empty space
#define TAB_BUTTON( itemNum, itemNumS, T, Tscale, onClick, onEnter, onExit, visInfo ) \
	BTN_T_CENTER_DYNAMIC( TAB_ITEM_X( itemNum ), TAB_ITEM_Y( itemNum ), TAB_ITEM_W, TAB_ITEM_H, T, Tscale, TAB_SELECTED_ARG( itemNumS ); onClick, onEnter, onExit, when( (TAB_VIS && visInfo) ) ) \
