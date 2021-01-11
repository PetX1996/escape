#include "ui/menudef.h"
#include "ui_mp/styles.inc"

#define PANEL_STATIC(x, y, w, h, color, visInfo) \
	itemDef \
	{ \
		type			ITEM_TYPE_BUTTON \
		rect			x y w h HORIZONTAL_ALIGN_SUBLEFT VERTICAL_ALIGN_SUBTOP \
		style			WINDOW_STYLE_FILLED \
		backcolor		color \
		visible			when(visInfo) \
	} \
	
#define PANEL_DYNAMIC_X(x, y, w, h, color, visInfo) \
	itemDef \
	{ \
		type			ITEM_TYPE_BUTTON \
		rect			0 y w h HORIZONTAL_ALIGN_SUBLEFT VERTICAL_ALIGN_SUBTOP \
		exp				rect X(x); \
		style			WINDOW_STYLE_FILLED \
		backcolor		color \
		visible			when(visInfo) \
	} \
	
#define PANEL_DYNAMIC_Y(x, y, w, h, color, visInfo) \
	itemDef \
	{ \
		type			ITEM_TYPE_BUTTON \
		rect			x 0 w h HORIZONTAL_ALIGN_SUBLEFT VERTICAL_ALIGN_SUBTOP \
		exp				rect Y(y); \
		style			WINDOW_STYLE_FILLED \
		backcolor		color \
		visible			when(visInfo) \
	} \
	
#define PANEL_DYNAMIC_XY(x, y, w, h, color, visInfo) \
	itemDef \
	{ \
		type			ITEM_TYPE_BUTTON \
		rect			0 0 w h HORIZONTAL_ALIGN_SUBLEFT VERTICAL_ALIGN_SUBTOP \
		exp				rect X(x); \
		exp				rect Y(y); \
		style			WINDOW_STYLE_FILLED \
		backcolor		color \
		visible			when(visInfo) \
	} \

#define PANEL_DYNAMIC_W(x, y, w, h, color, visInfo) \
	itemDef \
	{ \
		type			ITEM_TYPE_BUTTON \
		rect			x y 0 h HORIZONTAL_ALIGN_SUBLEFT VERTICAL_ALIGN_SUBTOP \
		exp				rect W(w); \
		style			WINDOW_STYLE_FILLED \
		backcolor		color \
		visible			when(visInfo) \
	} \
	
#define PANEL_DYNAMIC_H(x, y, w, h, color, visInfo) \
	itemDef \
	{ \
		type			ITEM_TYPE_BUTTON \
		rect			x y w 0 HORIZONTAL_ALIGN_SUBLEFT VERTICAL_ALIGN_SUBTOP \
		exp				rect H(h); \
		style			WINDOW_STYLE_FILLED \
		backcolor		color \
		visible			when(visInfo) \
	} \
	
#define PANEL_DYNAMIC_XW(x, y, w, h, color, visInfo) \
	itemDef \
	{ \
		type			ITEM_TYPE_BUTTON \
		rect			0 y 0 h HORIZONTAL_ALIGN_SUBLEFT VERTICAL_ALIGN_SUBTOP \
		exp				rect X(x); \
		exp				rect W(w); \
		style			WINDOW_STYLE_FILLED \
		backcolor		color \
		visible			when(visInfo) \
	} \

#define TEXTPANEL_STATIC(x, y, w, h, t, tScale, bgColor, tColor, tAlign, visInfo) \
	itemDef \
	{ \
		rect			x y w h HORIZONTAL_ALIGN_SUBLEFT VERTICAL_ALIGN_SUBTOP \
		style			WINDOW_STYLE_FILLED \
		backcolor		bgColor \
		forecolor		tColor \
		text			t \
		textalign		tAlign \
		textscale		tScale \
		visible			when(visInfo) \
		decoration \
	} \
	
#define TEXT_STATIC(x, y, w, h, t, tScale, tColor, tAlign, visInfo) \
	itemDef \
	{ \
		rect			x y w h HORIZONTAL_ALIGN_SUBLEFT VERTICAL_ALIGN_SUBTOP \
		style			WINDOW_STYLE_EMPTY \
		forecolor		tColor \
		text			t \
		textalign		tAlign \
		textscale		tScale \
		visible			when(visInfo) \
		decoration \
	} \

#define TEXTPANEL_DYNAMIC(x, y, w, h, t, tScale, bgColor, tColor, tAlign, visInfo) \
	itemDef \
	{ \
		rect			x y w h HORIZONTAL_ALIGN_SUBLEFT VERTICAL_ALIGN_SUBTOP \
		style			WINDOW_STYLE_FILLED \
		backcolor		bgColor \
		forecolor		tColor \
		exp				text( t ); \
		textalign		tAlign \
		textscale		tScale \
		visible			when(visInfo) \
		decoration \
	} \
	
#define TEXT_DYNAMIC(x, y, w, h, t, tScale, tColor, tAlign, visInfo) \
	itemDef \
	{ \
		rect			x y w h HORIZONTAL_ALIGN_SUBLEFT VERTICAL_ALIGN_SUBTOP \
		style			WINDOW_STYLE_EMPTY \
		forecolor		tColor \
		exp				text( t ); \
		textalign		tAlign \
		textscale		tScale \
		visible			when(visInfo) \
		decoration \
	} \
	
#define TEXTPANEL_EDITABLE(x, y, w, h, tScale, bgColor, tColor, tAlign, sDvar, iMaxChars, iMaxPaintChars, visInfo) \
	itemDef \
	{ \
		type			ITEM_TYPE_EDITFIELD \
		rect			x y w h HORIZONTAL_ALIGN_SUBLEFT VERTICAL_ALIGN_SUBTOP \
		style			WINDOW_STYLE_FILLED \
		backcolor		bgColor \
		forecolor		tColor \
		dvar			sDvar \
		maxChars		iMaxChars \
		maxPaintChars	iMaxPaintChars \
		text			" " \
		textalign		tAlign \
		textscale		tScale \
		visible			when(visInfo) \
	} \
	
#define TEXT_EDITABLE(x, y, w, h, sT, tScale, tColor, tAlign, sDvar, iMaxChars, iMaxPaintChars, sName, sGroup, visInfo) \
	itemDef \
	{ \
		name			sName \
		group			sGroup \
		type			ITEM_TYPE_EDITFIELD \
		rect			x y w h HORIZONTAL_ALIGN_SUBLEFT VERTICAL_ALIGN_SUBTOP \
		style			WINDOW_STYLE_EMPTY \
		forecolor		tColor \
		dvar			sDvar \
		maxChars		iMaxChars \
		maxPaintChars	iMaxPaintChars \
		text			t \
		textalign		tAlign \
		textscale		tScale \
		visible			when(visInfo) \
		decoration \
	} \
	
#define SHADER_STATIC(x, y, w, h, s, sColor, visInfo) \
	itemDef \
	{ \
		rect			x y w h HORIZONTAL_ALIGN_SUBLEFT VERTICAL_ALIGN_SUBTOP \
		style			WINDOW_STYLE_SHADER \
		background		s \
		forecolor		sColor \
		visible			when(visInfo) \
	} \
	
#define SHADER_STATIC_BTN(x, y, w, h, s, onClick, onEnter, onExit, visInfo) \
	itemDef \
	{ \
		type			ITEM_TYPE_BUTTON \
		rect			x y w h HORIZONTAL_ALIGN_SUBLEFT VERTICAL_ALIGN_SUBTOP \
		style			WINDOW_STYLE_SHADER \
		background		s \
		forecolor		COLOR_SHADER_OFF \
		visible			when(visInfo) \
		mouseEnter		{ setColor forecolor COLOR_SHADER_HIGHLIGHT; onEnter; } \
		mouseExit		{ setColor forecolor COLOR_SHADER_OFF; onExit; } \
		action			{ onClick } \
	} \
	
#define SHADER_STATIC_BTN_SELECTABLE(x, y, w, h, s, onClick, onEnter, onExit, isSelected, visInfo) \
	itemDef \
	{ \
		type			ITEM_TYPE_BUTTON \
		rect			x y w h HORIZONTAL_ALIGN_SUBLEFT VERTICAL_ALIGN_SUBTOP \
		style			WINDOW_STYLE_SHADER \
		background		s \
		forecolor		COLOR_SHADER_SELECTED \
		visible			when(visInfo && isSelected) \
		mouseEnter		{ setColor forecolor COLOR_SHADER_HIGHLIGHT; onEnter; } \
		mouseExit		{ setColor forecolor COLOR_SHADER_SELECTED; onExit; } \
		action			{ onClick } \
	} \
	itemDef \
	{ \
		type			ITEM_TYPE_BUTTON \
		rect			x y w h HORIZONTAL_ALIGN_SUBLEFT VERTICAL_ALIGN_SUBTOP \
		style			WINDOW_STYLE_SHADER \
		background		s \
		forecolor		COLOR_SHADER_OFF \
		visible			when(visInfo && !isSelected) \
		mouseEnter		{ setColor forecolor COLOR_SHADER_HIGHLIGHT; onEnter; } \
		mouseExit		{ setColor forecolor COLOR_SHADER_OFF; onExit; } \
		action			{ onClick } \
	} \
	
#define SHADER_DYNAMIC(x, y, w, h, s, sColor, visInfo) \
	itemDef \
	{ \
		rect			x y w h HORIZONTAL_ALIGN_SUBLEFT VERTICAL_ALIGN_SUBTOP \
		style			WINDOW_STYLE_SHADER \
		exp				material(s); \
		forecolor		sColor \
		visible			when(visInfo) \
	} \
	
#define SHADER_DYNAMIC_BTN(x, y, w, h, s, onClick, onEnter, onExit, visInfo) \
	itemDef \
	{ \
		type			ITEM_TYPE_BUTTON \
		rect			x y w h HORIZONTAL_ALIGN_SUBLEFT VERTICAL_ALIGN_SUBTOP \
		style			WINDOW_STYLE_SHADER \
		exp				material(s); \
		forecolor		COLOR_SHADER_OFF \
		visible			when(visInfo) \
		mouseEnter		{ setColor forecolor COLOR_SHADER_HIGHLIGHT; onEnter; } \
		mouseExit		{ setColor forecolor COLOR_SHADER_OFF; onExit; } \
		action			{ onClick } \
	} \
	
#define SHADER_DYNAMIC_BTN_SELECTABLE(x, y, w, h, s, onClick, onEnter, onExit, isSelected, visInfo) \
	itemDef \
	{ \
		rect			x y w h HORIZONTAL_ALIGN_SUBLEFT VERTICAL_ALIGN_SUBTOP \
		style			WINDOW_STYLE_SHADER \
		exp				material(s); \
		forecolor		COLOR_SHADER_SELECTED \
		visible			when(visInfo && isSelected) \
	} \
	itemDef \
	{ \
		type			ITEM_TYPE_BUTTON \
		rect			x y w h HORIZONTAL_ALIGN_SUBLEFT VERTICAL_ALIGN_SUBTOP \
		style			WINDOW_STYLE_SHADER \
		exp				material(s); \
		forecolor		COLOR_SHADER_OFF \
		visible			when(visInfo && isSelected == 0) \
		mouseEnter		{ setColor forecolor COLOR_SHADER_HIGHLIGHT; onEnter; } \
		mouseExit		{ setColor forecolor COLOR_SHADER_OFF; onExit; } \
		action			{ onClick } \
	} \
	
#define BTN_STATIC(btnId, x, y, w, h, t, tScale, tAlign, onClick, onEnter, onExit, visInfo) \
	itemDef \
	{ \
		name			"btn_stat_"btnId \
		type			ITEM_TYPE_BUTTON \
		rect			x y w h HORIZONTAL_ALIGN_SUBLEFT VERTICAL_ALIGN_SUBTOP \
		style			WINDOW_STYLE_FILLED \
		backcolor		COLOR_TRANSPARENT \
		forecolor		COLOR_WHITE \
		text			t \
		textscale		tScale \
		textalign		tAlign \
		visible			when(visInfo) \
		decoration \
	} \
	itemDef \
	{ \
		type			ITEM_TYPE_BUTTON \
		rect			x y w h HORIZONTAL_ALIGN_SUBLEFT VERTICAL_ALIGN_SUBTOP \
		style			WINDOW_STYLE_EMPTY \
		visible			when(visInfo) \
		mouseEnter		{ play "mouse_over"; setitemcolor "btn_stat_"btnId backcolor COLOR_FG_HIGHLIGHT; onEnter } \
		mouseExit		{ setitemcolor "btn_stat_"btnId backcolor COLOR_TRANSPARENT; onExit } \
		action			{ play "mouse_click"; onClick } \
	} \
	
#define BTN_DYNAMIC(btnId, x, y, w, h, t, tScale, tAlign, onClick, onEnter, onExit, visInfo) \
	itemDef \
	{ \
		name			"btn_dyn_"btnId \
		type			ITEM_TYPE_BUTTON \
		rect			x y w h HORIZONTAL_ALIGN_SUBLEFT VERTICAL_ALIGN_SUBTOP \
		style			WINDOW_STYLE_FILLED \
		backcolor		COLOR_TRANSPARENT \
		forecolor		COLOR_WHITE \
		exp				text(t); \
		textscale		tScale \
		textalign		ITEM_ALIGN_MIDDLE_CENTER \
		visible			when(visInfo) \
		decoration \
	} \
	itemDef \
	{ \
		type			ITEM_TYPE_BUTTON \
		rect			x y w h HORIZONTAL_ALIGN_SUBLEFT VERTICAL_ALIGN_SUBTOP \
		style			WINDOW_STYLE_EMPTY \
		visible			when(visInfo) \
		mouseEnter		{ play "mouse_over"; setitemcolor "btn_dyn_"btnId backcolor COLOR_FG_HIGHLIGHT; onEnter } \
		mouseExit		{ setitemcolor "btn_dyn_"btnId backcolor COLOR_TRANSPARENT; onExit } \
		action			{ play "mouse_click"; onClick } \
	} \

// CHOICE
// == vars -> default values ==
#undef CHOICE_X
#undef CHOICE_Y
#undef CHOICE_W
#undef CHOICE_H
#undef CHOICE_BTN_SIZE
#undef CHOICE_SEP_SIZE
#undef CHOICE_SEP_0
#undef CHOICE_SEP_1
#undef CHOICE_SEP_2
#undef CHOICE_SEP_3
#undef CHOICE_SEP_4
#undef CHOICE_SEP_5
#undef CHOICE_SEP_6
#undef CHOICE_SEP_7
#undef CHOICE_SEP_8
#undef CHOICE_SEP_9
#undef CHOICE_SELECTOR

#define CHOICE_X 0
#define CHOICE_Y 0
#define CHOICE_W 100
#define CHOICE_H 100

#define CHOICE_BTN_SIZE 20
#define CHOICE_SEP_SIZE 10

#define CHOICE_SEP_0 999
#define CHOICE_SEP_1 999
#define CHOICE_SEP_2 999
#define CHOICE_SEP_3 999
#define CHOICE_SEP_4 999
#define CHOICE_SEP_5 999
#define CHOICE_SEP_6 999
#define CHOICE_SEP_7 999
#define CHOICE_SEP_8 999
#define CHOICE_SEP_9 999

#define CHOICE_SELECTOR 999
// ==========

#define CHOICE_SEP_TOTALSIZE(i) (i <= CHOICE_SEP_0 ? 0 : \
								(i <= CHOICE_SEP_1 ? CHOICE_SEP_SIZE : \
								(i <= CHOICE_SEP_2 ? CHOICE_SEP_SIZE*2 : \
								(i <= CHOICE_SEP_3 ? CHOICE_SEP_SIZE*3 : \
								(i <= CHOICE_SEP_4 ? CHOICE_SEP_SIZE*4 : \
								(i <= CHOICE_SEP_5 ? CHOICE_SEP_SIZE*5 : \
								(i <= CHOICE_SEP_6 ? CHOICE_SEP_SIZE*6 : \
								(i <= CHOICE_SEP_7 ? CHOICE_SEP_SIZE*7 : \
								(i <= CHOICE_SEP_8 ? CHOICE_SEP_SIZE*8 : \
								(i <= CHOICE_SEP_9 ? CHOICE_SEP_SIZE*9 : \
								CHOICE_SEP_SIZE*10)))))))))) \

#define CHOICE_BTN_Y(i) (CHOICE_Y + (CHOICE_BTN_SIZE * i) + CHOICE_SEP_TOTALSIZE(i))

#define CHOICE_BTN_STATIC(btnId, i, t, tScale, tAlign, onClick, onEnter, onExit, visInfo) \
	PANEL_STATIC(CHOICE_X, CHOICE_BTN_Y(i), CHOICE_W, CHOICE_BTN_SIZE, COLOR_FG_HIGHLIGHT, (CHOICE_SELECTOR == i)) \
	BTN_STATIC(btnId, CHOICE_X, CHOICE_BTN_Y(i), CHOICE_W, CHOICE_BTN_SIZE, t, tScale, tAlign, onClick, onEnter, onExit, visInfo) \
	
#define CHOICE_BTN_DYNAMIC(btnId, i, t, tScale, tAlign, onClick, onEnter, onExit, visInfo) \
	PANEL_STATIC(CHOICE_X, CHOICE_BTN_Y(i), CHOICE_W, CHOICE_BTN_SIZE, COLOR_FG_HIGHLIGHT, (CHOICE_SELECTOR == i)) \
	BTN_DYNAMIC(btnId, CHOICE_X, CHOICE_BTN_Y(i), CHOICE_W, CHOICE_BTN_SIZE, t, tScale, tAlign, onClick, onEnter, onExit, visInfo) \
	
// TAB
// == vars -> default values ==
#undef TAB_X
#undef TAB_Y
#undef TAB_W
#undef TAB_H
#undef TAB_BTN_SIZE
#undef TAB_SEP_SIZE
#undef TAB_SEP_0
#undef TAB_SEP_1
#undef TAB_SEP_2
#undef TAB_SEP_3
#undef TAB_SEP_4
#undef TAB_SEP_5
#undef TAB_SEP_6
#undef TAB_SEP_7
#undef TAB_SEP_8
#undef TAB_SEP_9
#undef TAB_SELECTOR

#define TAB_X 0
#define TAB_Y 0
#define TAB_W 100
#define TAB_H 100

#define TAB_BTN_SIZE 20
#define TAB_SEP_SIZE 10

#define TAB_SEP_0 999
#define TAB_SEP_1 999
#define TAB_SEP_2 999
#define TAB_SEP_3 999
#define TAB_SEP_4 999
#define TAB_SEP_5 999
#define TAB_SEP_6 999
#define TAB_SEP_7 999
#define TAB_SEP_8 999
#define TAB_SEP_9 999

#define TAB_SELECTOR 999
// ==========

#define TAB_SEP_TOTALSIZE(i) (i <= TAB_SEP_0 ? 0 : \
								(i <= TAB_SEP_1 ? TAB_SEP_SIZE : \
								(i <= TAB_SEP_2 ? TAB_SEP_SIZE*2 : \
								(i <= TAB_SEP_3 ? TAB_SEP_SIZE*3 : \
								(i <= TAB_SEP_4 ? TAB_SEP_SIZE*4 : \
								(i <= TAB_SEP_5 ? TAB_SEP_SIZE*5 : \
								(i <= TAB_SEP_6 ? TAB_SEP_SIZE*6 : \
								(i <= TAB_SEP_7 ? TAB_SEP_SIZE*7 : \
								(i <= TAB_SEP_8 ? TAB_SEP_SIZE*8 : \
								(i <= TAB_SEP_9 ? TAB_SEP_SIZE*9 : \
								TAB_SEP_SIZE*10)))))))))) \

#define TAB_BTN_X(i) (TAB_X + (TAB_BTN_SIZE * i) + TAB_SEP_TOTALSIZE(i))

#define TAB_BTN_STATIC(btnId, i, t, tScale, tAlign, onClick, onEnter, onExit, visInfo) \
	PANEL_STATIC(TAB_BTN_X(i), TAB_Y, TAB_BTN_SIZE, TAB_H, COLOR_FG_HIGHLIGHT, (TAB_SELECTOR == i)) \
	BTN_STATIC(btnId, TAB_BTN_X(i), TAB_Y, TAB_BTN_SIZE, TAB_H, t, tScale, tAlign, onClick, onEnter, onExit, visInfo) \
	
#define TAB_BTN_DYNAMIC(btnId, i, t, tScale, tAlign, onClick, onEnter, onExit, visInfo) \
	PANEL_STATIC(TAB_BTN_X(i), TAB_Y, TAB_BTN_SIZE, TAB_H, COLOR_FG_HIGHLIGHT, (TAB_SELECTOR == i)) \
	BTN_DYNAMIC(btnId, TAB_BTN_X(i), TAB_Y, TAB_BTN_SIZE, TAB_H, t, tScale, tAlign, onClick, onEnter, onExit, visInfo) \

#define ONOPEN_DEFAULT setDvar cg_drawCrosshair 0; setDvar cg_hudChatPosition "0 0";
#define ONCLOSE_DEFAULT setDvar cg_drawCrosshair 1; setDvar cg_hudChatPosition "5 200";