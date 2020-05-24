/*
// structural vars
#define TAB_X 
#define TAB_Y
#define TAB_W
#define TAB_H

#define when( TAB_VIS )

#define TAB_ORIENT
#define TAB_BORDER

#define TAB_BUTTONS
#define TAB_SEPARATORS

#define TAB_SEP_0
#define TAB_SEP_1
#define TAB_SEP_2
#define TAB_SEP_3
#define TAB_SEP_4

#define TAB_SELECTED_DVAR 

// assistant vars
#define TAB_CONTENT_X
#define TAB_CONTENT_Y
#define TAB_CONTENT_W
#define TAB_CONTENT_H

#define TAB_ITEM_W
#define TAB_ITEM_H

#define TAB_SEP_SIZE

#define TAB_SELECTED_ARG

#define TAB_ITEM_X( itemNum )
#define TAB_ITEM_Y( itemNum )
#define TAB_SEPARATOR_SIZE( itemNum )
#define TAB_ITEM_HORIZONTAL_X( itemNum )
#define TAB_ITEM_HORIZONTAL_Y( itemNum )
#define TAB_ITEM_VERTICAL_X( itemNum )
#define TAB_ITEM_VERTICAL_Y( itemNum )
*/

P_BACKGROUND( TAB_X, TAB_Y, TAB_W, TAB_H, when( TAB_VIS ) )

#ifdef TAB_CONTENT_X
	#undef TAB_CONTENT_X
	#undef TAB_CONTENT_Y
	#undef TAB_CONTENT_W
	#undef TAB_CONTENT_H
	#undef TAB_ITEM_W
	#undef TAB_ITEM_H
	#undef TAB_SEP_SIZE
	#undef TAB_SELECTED_ARG
#endif

#if TAB_BORDER == TAB_BORDER_FULL
	#define TAB_CONTENT_X (TAB_X+INI_LINE_SIZE)
	#define TAB_CONTENT_Y (TAB_Y+INI_LINE_SIZE)
	#define TAB_CONTENT_W (TAB_W-(INI_LINE_SIZE*2))
	#define TAB_CONTENT_H (TAB_H-(INI_LINE_SIZE*2))
	P_BORDER( TAB_X, TAB_Y, INI_LINE_SIZE, TAB_H, when( TAB_VIS ) )
	P_BORDER( (TAB_X+TAB_W-INI_LINE_SIZE), TAB_Y, INI_LINE_SIZE, TAB_H, when( TAB_VIS ) )
	P_BORDER( (TAB_X+INI_LINE_SIZE), TAB_Y, (TAB_W-(INI_LINE_SIZE*2)), INI_LINE_SIZE, when( TAB_VIS ) )
	P_BORDER( (TAB_X+INI_LINE_SIZE), (TAB_Y+TAB_H-INI_LINE_SIZE), (TAB_W-(INI_LINE_SIZE*2)), INI_LINE_SIZE, when( TAB_VIS ) )
#elif TAB_BORDER == TAB_BORDER_LEFT
	#define TAB_CONTENT_X (TAB_X+INI_LINE_SIZE)
	#define TAB_CONTENT_Y TAB_Y
	#define TAB_CONTENT_W (TAB_W-INI_LINE_SIZE)
	#define TAB_CONTENT_H TAB_H
	P_BORDER( TAB_X, TAB_Y, INI_LINE_SIZE, TAB_H, when( TAB_VIS ) )
#elif TAB_BORDER == TAB_BORDER_TOP
	#define TAB_CONTENT_X TAB_X
	#define TAB_CONTENT_Y (TAB_Y+INI_LINE_SIZE)
	#define TAB_CONTENT_W TAB_W
	#define TAB_CONTENT_H (TAB_H-INI_LINE_SIZE)
	P_BORDER( TAB_X, TAB_Y, TAB_W, INI_LINE_SIZE, when( TAB_VIS ) )
#elif TAB_BORDER == TAB_BORDER_RIGHT
	#define TAB_CONTENT_X TAB_X
	#define TAB_CONTENT_Y TAB_Y
	#define TAB_CONTENT_W (TAB_W-INI_LINE_SIZE)
	#define TAB_CONTENT_H TAB_H
	P_BORDER( ((TAB_X+TAB_W)-INI_LINE_SIZE), TAB_Y, INI_LINE_SIZE, TAB_H, when( TAB_VIS ) )
#elif TAB_BORDER == TAB_BORDER_BOTTOM
	#define TAB_CONTENT_X TAB_X
	#define TAB_CONTENT_Y TAB_Y
	#define TAB_CONTENT_W TAB_W
	#define TAB_CONTENT_H (TAB_H-INI_LINE_SIZE)
	P_BORDER( TAB_X, ((TAB_Y+TAB_H)-INI_LINE_SIZE), TAB_W, INI_LINE_SIZE, when( TAB_VIS ) )	
#endif

#if TAB_ORIENT == TAB_ORIENT_HORIZONTAL
	#define TAB_SEP_SIZE (TAB_CONTENT_W*TAB_SEPARATOR_FRACTION)
	#define TAB_ITEM_W ((TAB_CONTENT_W-(TAB_SEP_SIZE*TAB_SEPARATORS))/TAB_BUTTONS)
	#define TAB_ITEM_H TAB_CONTENT_H
	#define TAB_ITEM_X( itemNum ) TAB_ITEM_HORIZONTAL_X(itemNum)
	#define TAB_ITEM_Y( itemNum ) TAB_ITEM_HORIZONTAL_Y(itemNum)
#else
	#define TAB_SEP_SIZE (TAB_CONTENT_H*TAB_SEPARATOR_FRACTION)
	#define TAB_ITEM_W TAB_CONTENT_W
	#define TAB_ITEM_H ((TAB_CONTENT_H-(TAB_SEP_SIZE*TAB_SEPARATORS))/TAB_BUTTONS)
	#define TAB_ITEM_X( itemNum ) TAB_ITEM_VERTICAL_X(itemNum)
	#define TAB_ITEM_Y( itemNum ) TAB_ITEM_VERTICAL_Y(itemNum)
#endif

#if TAB_SEPARATORS == 0
	#define TAB_SEPARATOR_SIZE( itemNum ) 0
#elif TAB_SEPARATORS == 1
	#define TAB_SEPARATOR_SIZE( itemNum ) ((itemNum <= TAB_SEP_0) ? 0 : TAB_SEP_SIZE)
#elif TAB_SEPARATORS == 2
	#define TAB_SEPARATOR_SIZE( itemNum ) ((itemNum <= TAB_SEP_0) ? 0 : (itemNum <= TAB_SEP_1 ? TAB_SEP_SIZE : TAB_SEP_SIZE*2))
#elif TAB_SEPARATORS == 3
	#define TAB_SEPARATOR_SIZE( itemNum ) ((itemNum <= TAB_SEP_0) ? 0 : (itemNum <= TAB_SEP_1 ? TAB_SEP_SIZE : (itemNum <= TAB_SEP_2 ? TAB_SEP_SIZE*2 : TAB_SEP_SIZE*3)))
#elif TAB_SEPARATORS == 4
	#define TAB_SEPARATOR_SIZE( itemNum ) ((itemNum <= TAB_SEP_0) ? 0 : (itemNum <= TAB_SEP_1 ? TAB_SEP_SIZE : (itemNum <= TAB_SEP_2 ? TAB_SEP_SIZE*2 : (itemNum <= TAB_SEP_3 ? TAB_SEP_SIZE*3 : TAB_SEP_SIZE*4))))
#elif TAB_SEPARATORS == 5
	#define TAB_SEPARATOR_SIZE( itemNum ) ((itemNum <= TAB_SEP_0) ? 0 : (itemNum <= TAB_SEP_1 ? TAB_SEP_SIZE : (itemNum <= TAB_SEP_2 ? TAB_SEP_SIZE*2 : (itemNum <= TAB_SEP_3 ? TAB_SEP_SIZE*3 : (itemNum <= TAB_SEP_4 ? TAB_SEP_SIZE*4 : TAB_SEP_SIZE*5)))))
#endif

#define TAB_ITEM_HORIZONTAL_X( itemNum ) (TAB_CONTENT_X+(TAB_ITEM_W*itemNum)+TAB_SEPARATOR_SIZE(itemNum)) 
#define TAB_ITEM_HORIZONTAL_Y( itemNum ) TAB_CONTENT_Y
	
#define TAB_ITEM_VERTICAL_X( itemNum ) TAB_CONTENT_X 
#define TAB_ITEM_VERTICAL_Y( itemNum ) (TAB_CONTENT_Y+(TAB_ITEM_H*itemNum)+TAB_SEPARATOR_SIZE(itemNum))

#ifdef TAB_SELECTED_DVAR
	#define TAB_SELECTED_ARG( itemNumS ) execNow "set "TAB_SELECTED_DVAR" "itemNumS

	#if TAB_ORIENT == TAB_ORIENT_HORIZONTAL
		itemDef // pointer
		{
			rect			0 TAB_CONTENT_Y TAB_ITEM_W TAB_ITEM_H 0 0
			exp				rect X( TAB_ITEM_X( DvarInt( TAB_SELECTED_DVAR ) ) )
			//exp				rect X( 60 )
			style			WINDOW_STYLE_FILLED
			backcolor		C_HIGHLIGHT
			visible			when( TAB_VIS )
		}
	#else
		itemDef // pointer
		{
			rect			TAB_CONTENT_X 0 TAB_ITEM_W TAB_ITEM_H 0 0
			exp				rect Y( TAB_ITEM_Y( DvarInt( TAB_SELECTED_DVAR ) ) )
			style			WINDOW_STYLE_FILLED
			backcolor		C_HIGHLIGHT
			visible			when( TAB_VIS )
		}	
	#endif
#else
	#define TAB_SELECTED_ARG( itemNumS ) ;
#endif