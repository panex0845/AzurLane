;@Ahk2Exe-SetName ColorFinder
;@Ahk2Exe-SetDescription ColorFinder
;@Ahk2Exe-SetVersion 1.0.0.1
;@Ahk2Exe-SetMainIcon 01.ico

if not A_IsAdmin { ;強制用管理員開啟
Run *RunAs "%A_ScriptFullPath%"
Exitapp
}

#SingleInstance, force
Coordmode, pixel, window
Coordmode, mouse, window
SetBatchLines, 500ms
SetControlDelay, -1
pToken := Gdip_Startup()


guif:
Gui, Add, Text, x20 y10 w200 h20 vtitle1 +cEE0011 ,  按下F10鎖定視窗 
Gui, Add, Text, x230 y10 w350 h20 vtitle999 +c1100EE ,  按下F2啟動找圖函數

Gui Add, Text, x20 y54 w10 h15,  X:
Gui Add, Edit, x40 y50 w40 h20 vPosX, 
Gui Add, Text, x100 y54 w10 h15, Y:
Gui Add, Edit, x120 y50 w40 h20 vPosY, 

Gui Add, Text, x20 y90 w120 h15, 抓取滑鼠位置

F10X := 0
F10Y := 0
ccolor := 0
ccolor2 := 0
ARGB := 0

Gui, Add, Text, x140 y90 w60 h20 vF10X , X： %F10X% 
Gui, Add, Text, x200 y90 w60 h20 vF10Y, Y： %F10Y% 
Gui, Add, Text, x260 y60 w160 h20 vF10ccolor , color： %ccolor% 。
Gui, Add, Text, x260 y80 w160 h20 vF10ccolorARGB , ARGB： %ARGB% 。
Gui, Add, Text, x260 y100 w160 h20 vF10EventcountRGB , RGB： %RGB% 。

Gui Add, Text, x20 y130 w180 h15, 座標位置(user32)　　Color：
Gui, Add, Edit, x180 y126 w100 h20 ReadOnly vF11color
Gui Add, Button, x300 y125 w80 h20 gCopyUser32, 複製
;Gui, Add, Text, x180 y110 w150 h20 vF11color , color： %ccolor2% 。


Gui Add, Text, x20 y170 w180 h15, 座標位置(GDIP)　　ARGB：
Gui, Add, Edit, x180 y166 w100 h20 ReadOnly vEventcount1
UpdateText("Eventcount1", %ARGB%)
Gui Add, Button, x300 y165 w80 h20 gCopyGDIP, 複製
;~ Gui, Add, Text, x140 y130 w180 h20 vEventcount1 , ARGB： %ARGB% 。

Gui Add, Text, x20 y210 w180 h15, 座標位置(RGB)　 　RGB：
Gui, Add, Edit, x180 y206 w100 h20 ReadOnly vEventcountRGB
UpdateText("Eventcount1", %RGB%)
;~ Gui, Add, Text, x140 y130 w180 h20 vEventcount1 , ARGB： %ARGB% 。

Gui 1:Show, w450 h250, ColorFinder
Gui,+AlwaysOnTop


Return




GuiClose:
ExitApp
return

F10::
F10Function := 1
MouseGetPos X1, Y1, A
WinGetTitle, title, ahk_id %A%
WinActivate, %title%
GuiControlget, title
UniqueID := WinExist("A")
MouseGetPos X, Y, A
WinGetTitle, title, ahk_id %A%
ccolor := DwmGetPixel( x, y, UniqueID)
;~ MsgBox ,,, x%X% y%y% color:%ccolor% 
GuiControl, , F10X, X： %x% 
GuiControl, , F10Y, Y： %y%
GuiControl, , F10ccolor, color： %ccolor% 。
pBitmap:= Gdip_BitmapFromHWND(UniqueID)
ARGB := GDIP_GetPixel(pBitmap, x, y)
GDIP_DisposeImage(pBitMap)
GuiControl, , F10ccolorARGB, ARGB： %ARGB% 。
GuiControl, , title1, 視窗標題： %title%  
PixelGetColor RGB, %X%, %Y%, RGB
GuiControl, , F10EventcountRGB, RGB： %RGB% 。

settimer, test2, 500
settimer, test, 500
settimer, testRGB, 500
return


F11::
MouseGetPos X1, Y1, A
WinGetTitle, title, ahk_id %A%
UniqueID := WinExist("A")
return
#if F2Func!=1
f2::
F2Func := 1
; The line of code below loads a cursor from the system set (specifically, the wait cursor - 32514).
if (F10Function=1)
{
	Gui, 1:Hide
	MsgBox, 16, 錯誤, 使用F2功能請勿按下F10`n`n按下確認後自動重啟
	Reload
}
Gui, 1:Hide
MouseGetPos X1, Y1, A
WinGetTitle, title, ahk_id %A%
WinActivate, %title%
MouseGetPos X1, Y1, A
hCursor := DllCall("LoadImage", "Uint", 0, "Uint", 32515, "Uint", 2, "Uint", 0, "Uint", 0, "Uint", 0x8000)
Cursors = 32650,32512,32515,32649,32651,32513,32648,32646,32643,32645,32642,32644,32516,32514
Loop, Parse, Cursors, `,
{
	DllCall("SetSystemCursor", "Uint", DllCall("CopyImage", "Uint", hCursor, "Uint", 2, "Int", 0, "Int", 0, "Uint", 0), "Uint", A_LoopField)
}
Loop,
{
	MouseGetPos X2, Y2, A
	tooltip, Wintitle: %title% `nx1: %x1% y1: %y1%`nx2: %x2% y2: %y2%`n`n等待按下滑鼠右鍵後繼續
	sleep 10
	if GetKeyState("RButton", "P")
		break
}
Global A
DllCall("SystemParametersInfo", "Uint", 0x0057, "Uint", 0, "Uint", 0, "Uint", 0)
Tooltip
;拍照選取範圍
FileCreateDir, TempImg
InputBox, FileName , 設定精靈, `n`n　　　　　　　請輸入檔案名稱,, , ,,,,, 123
if (FileName="") or Errorlevel
{
	Msgbox, ,設定精靈, 未輸入檔案名稱
	Gui, 1:Show
	return
}
pBitmap := Gdip_BitmapFromHWND(A)
Xx2:=X2-X1, Yy2:=Y2-Y1 ;把Y1 Y2改成W H
pBitmap_part := Gdip_CloneBitmapArea(pBitmap, X1, Y1, Xx2, Yy2)
Gdip_SaveBitmapToFile(pBitmap_part, "TempImg/" . "" . "" . FileName . ".png", 100)
Gdip_SaveBitmapToFile(pBitmap_part, "TempImg/" . "" . "" . "TestTemp" . ".png", 100)
Gdip_DisposeImage(pBitmap)
Gdip_DisposeImage(pBitmap_part)
 ; 創建照片預覽GUI
ThisXX := Xx2+30
ThisYY :=  Yy2+220
Gui_w := if (xx2>600) ? ThisXX : 600
Gui_H := if (Yy2>500) ? ThisYY : 500 
Gui, Image: Add, Picture, x10 y10  ,TempImg\%FileName%.png
Pos_X := 10
Pos_Y := Gui_H-120
Gui, Image: Add, text, x%Pos_X% y%Pos_Y%, 搜尋設定：
Pos_Y += 30
Gui, Image: Add, text, x%Pos_X% y%Pos_Y%, X1：
Pos_X += 30
Pos_Y -= 3
Search_X1num := if (x1-5>1) ? x1-5 : 0
Gui, Image: Add, edit, x%Pos_X% y%Pos_Y% w50 h20 vSearch_X1 number, %Search_X1num%
Pos_X += 60
Pos_Y += 3
Gui, Image: Add, text, x%Pos_X% y%Pos_Y%, Y1：
Pos_X += 30
Pos_Y -= 3
Search_Y1num := y1-5
Gui, Image: Add, edit, x%Pos_X% y%Pos_Y% w50 h20 vSearch_Y1 number, %Search_Y1num%
Pos_X += 60
Pos_Y += 3
Gui, Image: Add, text, x%Pos_X% y%Pos_Y%, X2：
Pos_X += 30
Pos_Y -= 3
Search_x2num := x2+5
Gui, Image: Add, edit, x%Pos_X% y%Pos_Y% w50 h20 vSearch_X2 number, %Search_x2num%
Pos_X += 60
Pos_Y += 3
Gui, Image: Add, text, x%Pos_X% y%Pos_Y%, Y2：
Pos_X += 30
Pos_Y -= 3
Search_y2num := if (y2+5>768) ? 768 : y2+5
Gui, Image: Add, edit, x%Pos_X% y%Pos_Y% w50 h20 vSearch_Y2 number, %Search_y2num%
Pos_X += 60
Pos_Y += 3
Gui, Image: Add, text, x%Pos_X% y%Pos_Y%, 容許值：
Pos_X += 50
Pos_Y -= 3
Gui, Image: Add, edit, x%Pos_X% y%Pos_Y% w50 h20 vSearch_Variation number, 100
Pos_X += 60
Pos_Y += 3
Gui, Image: Add, text, x%Pos_X% y%Pos_Y%, 方向：
Pos_X += 40
Pos_Y -= 3
Gui, Image: Add, edit, x%Pos_X% y%Pos_Y% w50 h20 vSearch_direction number, 8

BTNConfrim_X := 10
BTNConfrim_Y := Gui_H-30
Gui, Image: Add, Button, x%BTNConfrim_X% y%BTNConfrim_Y% w100 h20 vPictureOK gPictureOKSub, 複製函數
BTNConfrim_Y -= 30
Gui, Image: Add, Checkbox, x%BTNConfrim_X% y%BTNConfrim_Y% w100 h20 vClickPicture , 點擊該圖片
BTNConfrim_X += 120
BTNConfrim_Y += 30
Gui, Image: Add, Button, x%BTNConfrim_X% y%BTNConfrim_Y% w100 h20 vBTNText gBTNTextSub, 測試函數
BTNConfrim_X += 120
BTNConfrim_Y += 3
Gui, Image: Add, text,x%BTNConfrim_X% y%BTNConfrim_Y% w150 h20 vTestText +cEE0011, 
Gui, Image: -sysmenu +AlwaysOnTop
Gui, Image: Show, w%Gui_w% h%Gui_H%, %FileName%.Png
return
; And finally, when the action is over, we call the code below to revert the default set of cursors back to its original state.

PictureOKSub:
F2Func := 0
Gui, 1:Show
GuicontrolGet, Search_X1
GuicontrolGet, Search_Y1
GuicontrolGet, Search_X2
GuicontrolGet, Search_Y2
GuicontrolGet, Search_Variation
GuicontrolGet, Search_direction
Text = `GdipImageSearch(x, y, `"`img/%FileName%.png`"`, %Search_Variation%, %Search_direction%, %Search_X1%, %Search_Y1%, %Search_X2%, %Search_Y2%)
clipboard = %text%`n`{`n    C_Click(x, y)`n`}
ToolTip, 函數：`n`n%text%`n`n已複製到剪貼簿
Gui, Image: Destroy
sleep 2000
FileDelete TestTemp.png
Tooltip
return

BTNTextSub:
GuicontrolGet, Search_X1
GuicontrolGet, Search_Y1
GuicontrolGet, Search_X2
GuicontrolGet, Search_Y2
GuicontrolGet, Search_Variation
GuicontrolGet, Search_direction
GuicontrolGet, ClickPicture
if (GdipImageSearch(x, y, "TempImg/TestTemp.png", Search_Variation, Search_direction, Search_X1, Search_Y1, Search_X2, Search_Y2))
{
	GuiControl,, TestText, 圖片位於`: x%x% y%y%
	if (ClickPicture)
	{
		ControlClick, x%x% y%y%, %title%,,,2 , NA 
	}
} else {
	GuiControl,, TestText, 圖片位於: NotFound
}
return


test2:
;GuiControlget, title
GuiControlget, PosX
GuiControlget, PosY
;~ MsgBox  % DwmGetPixel( PosX, PosY, UniqueID2)
if (PosX="" or PosY="")
{
ccolor2 := DwmGetPixel( X, Y, UniqueID)   
GuiControl, , F11color, %ccolor2%   
Loop
{
MouseGetPos,,, A
WinGetTitle, title2, ahk_id %A%
if (title2!="ColorFinder")
{
   break   
}
}
}
else
{
ccolor2 := DwmGetPixel( PosX, PosY, UniqueID)   
GuiControl, , F11color, %ccolor2%   
Loop
{
MouseGetPos,,, A
WinGetTitle, title2, ahk_id %A%
if (title2!="ColorFinder")
{
   break   
}
}
}
return

CopyUser32:
clipboard = DwmCheckcolor(%x%, %y%, %ccolor2%)
return

test:
;GuiControlget, title
GuiControlget, PosX
GuiControlget, PosY
pBitmap:= Gdip_BitmapFromHWND(UniqueID)
if (PosX="" or PosY="")
{
ARGB := GDIP_GetPixel(pBitmap, x, y)
GDIP_DisposeImage(pBitMap)
GuiControl, , Eventcount1, %ARGB%
   Loop
   {
   MouseGetPos,,, A
   WinGetTitle, title2, ahk_id %A%
      if (title2!="ColorFinder")
      {
         break   
      }
   }
}
else
{
ARGB := GDIP_GetPixel(pBitmap, PosX, PosY)
GDIP_DisposeImage(pBitMap)
GuiControl, , Eventcount1, %ARGB%
Loop
{
MouseGetPos,,, A
WinGetTitle, title2, ahk_id %A%
if (title2!="ColorFinder")
{
   break   
}
}
}
return

CopyGDIP:
clipboard = %ARGB%

testRGB:
;GuiControlget, title
GuiControlget, PosX
GuiControlget, PosY
if (PosX="" or PosY="")
{
PixelGetColor RGB2, %X%, %Y%, RGB
GuiControl, , EventcountRGB, %RGB2%
Loop
{
MouseGetPos,,, A
WinGetTitle, title2, ahk_id %A%
if (title2!="ColorFinder")
{
   break   
}
}
}
else
{
PixelGetColor RGB2, %X%, %Y%, RGB
GuiControl, , EventcountRGB, %RGB2%
Loop
{
MouseGetPos,,, A
WinGetTitle, title2, ahk_id %A%
if (title2!="ColorFinder")
{
   break   
}
}
}
return







>^F12::
RELOAD

return



UpdateText(ControlID, NewText)
{
	; Unlike using a pure GuiControl, this function causes the text of the
	; controls to be updated only when the text has changed, preventing periodic
	; flickering (especially on older systems).
	static OldText := {}
	global hGui
	if (OldText[ControlID] != NewText)
	{
		GuiControl, %hGui%:, % ControlID, % NewText
		OldText[ControlID] := NewText
	}
}



DwmGetPixel(x, y, UniqueID)
{
   hDC := DllCall("user32.dll\GetDCEx", "UInt", UniqueID, "UInt", 0, "UInt", 1|2)
   pix := DllCall("gdi32.dll\GetPixel", "UInt", hDC, "Int", x, "Int", y, "UInt")
   DllCall("user32.dll\ReleaseDC", "UInt", UniqueID, "UInt", hDC)
   pix := ConvertColor(pix)
   return pix
}

DecToHex(dec)
{
   oldfrmt := A_FormatInteger
   hex := dec
   SetFormat, IntegerFast, hex
   hex += 0
   hex .= ""
   SetFormat, IntegerFast, %oldfrmt%
   return hex
}

ConvertColor( BGRValue )
{
	BlueByte := ( BGRValue & 0xFF0000 ) >> 16
	GreenByte := BGRValue & 0x00FF00
	RedByte := ( BGRValue & 0x0000FF ) << 16
	return RedByte | GreenByte | BlueByte
}



; Gdip standard library v1.54 on 11/15/2017
; Gdip standard library v1.53 on 6/19/2017
; Gdip standard library v1.52 on 6/11/2017
; Gdip standard library v1.51 on 1/27/2017
; Gdip standard library v1.50 on 11/20/16
; Gdip standard library v1.45 by tic (Tariq Porter) 07/09/11
; Modifed by Rseding91 using fincs 64 bit compatible Gdip library 5/1/2013
; Supports: Basic, _L ANSi, _L Unicode x86 and _L Unicode x64
;
; Updated 11/15/2017 - compatibility with both AHK v2 and v1, restored by nnnik
; Updated 6/19/2017 - Fixed few bugs from old syntax by Bartlomiej Uliasz
; Updated 6/11/2017 - made code compatible with new AHK v2.0-a079-be5df98 by Bartlomiej Uliasz
; Updated 1/27/2017 - fixed some bugs and made #Warn All compatible by Bartlomiej Uliasz
; Updated 11/20/2016 - fixed Gdip_BitmapFromBRA() by 'just me'
; Updated 11/18/2016 - backward compatible support for both AHK v1.1 and AHK v2
; Updated 11/15/2016 - initial AHK v2 support by guest3456
; Updated 2/20/2014 - fixed Gdip_CreateRegion() and Gdip_GetClipRegion() on AHK Unicode x86
; Updated 5/13/2013 - fixed Gdip_SetBitmapToClipboard() on AHK Unicode x64
;
;#####################################################################################
;#####################################################################################
; STATUS ENUMERATION
; Return values for functions specified to have status enumerated return type
;#####################################################################################
;
; Ok =						= 0
; GenericError				= 1
; InvalidParameter			= 2
; OutOfMemory				= 3
; ObjectBusy				= 4
; InsufficientBuffer		= 5
; NotImplemented			= 6
; Win32Error				= 7
; WrongState				= 8
; Aborted					= 9
; FileNotFound				= 10
; ValueOverflow				= 11
; AccessDenied				= 12
; UnknownImageFormat		= 13
; FontFamilyNotFound		= 14
; FontStyleNotFound			= 15
; NotTrueTypeFont			= 16
; UnsupportedGdiplusVersion	= 17
; GdiplusNotInitialized		= 18
; PropertyNotFound			= 19
; PropertyNotSupported		= 20
; ProfileNotFound			= 21
;
;#####################################################################################
;#####################################################################################
; FUNCTIONS
;#####################################################################################
;
; UpdateLayeredWindow(hwnd, hdc, x:="", y:="", w:="", h:="", Alpha:=255)
; BitBlt(ddc, dx, dy, dw, dh, sdc, sx, sy, Raster:="")
; StretchBlt(dDC, dx, dy, dw, dh, sDC, sx, sy, sw, sh, Raster:="")
; SetImage(hwnd, hBitmap)
; Gdip_BitmapFromScreen(Screen:=0, Raster:="")
; CreateRectF(ByRef RectF, x, y, w, h)
; CreateSizeF(ByRef SizeF, w, h)
; CreateDIBSection
;
;#####################################################################################

; Function:					UpdateLayeredWindow
; Description:				Updates a layered window with the handle to the DC of a gdi bitmap
;
; hwnd						Handle of the layered window to update
; hdc						Handle to the DC of the GDI bitmap to update the window with
; Layeredx					x position to place the window
; Layeredy					y position to place the window
; Layeredw					Width of the window
; Layeredh					Height of the window
; Alpha						Default = 255 : The transparency (0-255) to set the window transparency
;
; return					If the function succeeds, the return value is nonzero
;
; notes						If x or y omitted, then layered window will use its current coordinates
;							If w or h omitted then current width and height will be used

UpdateLayeredWindow(hwnd, hdc, x:="", y:="", w:="", h:="", Alpha:=255)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"

	if ((x != "") && (y != ""))
		VarSetCapacity(pt, 8), NumPut(x, pt, 0, "UInt"), NumPut(y, pt, 4, "UInt")

	if (w = "") || (h = "")
	{
		CreateRect( winRect, 0, 0, 0, 0 ) ;is 16 on both 32 and 64
		DllCall( "GetWindowRect", Ptr, hwnd, Ptr, &winRect )
		w := NumGet(winRect, 8, "UInt")  - NumGet(winRect, 0, "UInt")
		h := NumGet(winRect, 12, "UInt") - NumGet(winRect, 4, "UInt")
	}

	return DllCall("UpdateLayeredWindow"
	, Ptr, hwnd
	, Ptr, 0
	, Ptr, ((x = "") && (y = "")) ? 0 : &pt
	, "int64*", w|h<<32
	, Ptr, hdc
	, "int64*", 0
	, "uint", 0
	, "UInt*", Alpha<<16|1<<24
	, "uint", 2)
}

;#####################################################################################

; Function				BitBlt
; Description			The BitBlt function performs a bit-block transfer of the color data corresponding to a rectangle
;						of pixels from the specified source device context into a destination device context.
;
; dDC					handle to destination DC
; dx					x-coord of destination upper-left corner
; dy					y-coord of destination upper-left corner
; dw					width of the area to copy
; dh					height of the area to copy
; sDC					handle to source DC
; sx					x-coordinate of source upper-left corner
; sy					y-coordinate of source upper-left corner
; Raster				raster operation code
;
; return				If the function succeeds, the return value is nonzero
;
; notes					If no raster operation is specified, then SRCCOPY is used, which copies the source directly to the destination rectangle
;
; BLACKNESS				= 0x00000042
; NOTSRCERASE			= 0x001100A6
; NOTSRCCOPY			= 0x00330008
; SRCERASE				= 0x00440328
; DSTINVERT				= 0x00550009
; PATINVERT				= 0x005A0049
; SRCINVERT				= 0x00660046
; SRCAND				= 0x008800C6
; MERGEPAINT			= 0x00BB0226
; MERGECOPY				= 0x00C000CA
; SRCCOPY				= 0x00CC0020
; SRCPAINT				= 0x00EE0086
; PATCOPY				= 0x00F00021
; PATPAINT				= 0x00FB0A09
; WHITENESS				= 0x00FF0062
; CAPTUREBLT			= 0x40000000
; NOMIRRORBITMAP		= 0x80000000

BitBlt(ddc, dx, dy, dw, dh, sdc, sx, sy, Raster:="")
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"

	return DllCall("gdi32\BitBlt"
					, Ptr, dDC
					, "int", dx
					, "int", dy
					, "int", dw
					, "int", dh
					, Ptr, sDC
					, "int", sx
					, "int", sy
					, "uint", Raster ? Raster : 0x00CC0020)
}

;#####################################################################################

; Function				StretchBlt
; Description			The StretchBlt function copies a bitmap from a source rectangle into a destination rectangle,
;						stretching or compressing the bitmap to fit the dimensions of the destination rectangle, if necessary.
;						The system stretches or compresses the bitmap according to the stretching mode currently set in the destination device context.
;
; ddc					handle to destination DC
; dx					x-coord of destination upper-left corner
; dy					y-coord of destination upper-left corner
; dw					width of destination rectangle
; dh					height of destination rectangle
; sdc					handle to source DC
; sx					x-coordinate of source upper-left corner
; sy					y-coordinate of source upper-left corner
; sw					width of source rectangle
; sh					height of source rectangle
; Raster				raster operation code
;
; return				If the function succeeds, the return value is nonzero
;
; notes					If no raster operation is specified, then SRCCOPY is used. It uses the same raster operations as BitBlt

StretchBlt(ddc, dx, dy, dw, dh, sdc, sx, sy, sw, sh, Raster:="")
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"

	return DllCall("gdi32\StretchBlt"
					, Ptr, ddc
					, "int", dx
					, "int", dy
					, "int", dw
					, "int", dh
					, Ptr, sdc
					, "int", sx
					, "int", sy
					, "int", sw
					, "int", sh
					, "uint", Raster ? Raster : 0x00CC0020)
}

;#####################################################################################

; Function				SetStretchBltMode
; Description			The SetStretchBltMode function sets the bitmap stretching mode in the specified device context
;
; hdc					handle to the DC
; iStretchMode			The stretching mode, describing how the target will be stretched
;
; return				If the function succeeds, the return value is the previous stretching mode. If it fails it will return 0
;
; STRETCH_ANDSCANS 		= 0x01
; STRETCH_ORSCANS 		= 0x02
; STRETCH_DELETESCANS 	= 0x03
; STRETCH_HALFTONE 		= 0x04

SetStretchBltMode(hdc, iStretchMode:=4)
{
	return DllCall("gdi32\SetStretchBltMode"
					, A_PtrSize ? "UPtr" : "UInt", hdc
					, "int", iStretchMode)
}

;#####################################################################################

; Function				SetImage
; Description			Associates a new image with a static control
;
; hwnd					handle of the control to update
; hBitmap				a gdi bitmap to associate the static control with
;
; return				If the function succeeds, the return value is nonzero

SetImage(hwnd, hBitmap)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	E := DllCall( "SendMessage", Ptr, hwnd, "UInt", 0x172, "UInt", 0x0, Ptr, hBitmap )
	DeleteObject(E)
	return E
}

;#####################################################################################

; Function				SetSysColorToControl
; Description			Sets a solid colour to a control
;
; hwnd					handle of the control to update
; SysColor				A system colour to set to the control
;
; return				If the function succeeds, the return value is zero
;
; notes					A control must have the 0xE style set to it so it is recognised as a bitmap
;						By default SysColor=15 is used which is COLOR_3DFACE. This is the standard background for a control
;
; COLOR_3DDKSHADOW				= 21
; COLOR_3DFACE					= 15
; COLOR_3DHIGHLIGHT				= 20
; COLOR_3DHILIGHT				= 20
; COLOR_3DLIGHT					= 22
; COLOR_3DSHADOW				= 16
; COLOR_ACTIVEBORDER			= 10
; COLOR_ACTIVECAPTION			= 2
; COLOR_APPWORKSPACE			= 12
; COLOR_BACKGROUND				= 1
; COLOR_BTNFACE					= 15
; COLOR_BTNHIGHLIGHT			= 20
; COLOR_BTNHILIGHT				= 20
; COLOR_BTNSHADOW				= 16
; COLOR_BTNTEXT					= 18
; COLOR_CAPTIONTEXT				= 9
; COLOR_DESKTOP					= 1
; COLOR_GRADIENTACTIVECAPTION	= 27
; COLOR_GRADIENTINACTIVECAPTION	= 28
; COLOR_GRAYTEXT				= 17
; COLOR_HIGHLIGHT				= 13
; COLOR_HIGHLIGHTTEXT			= 14
; COLOR_HOTLIGHT				= 26
; COLOR_INACTIVEBORDER			= 11
; COLOR_INACTIVECAPTION			= 3
; COLOR_INACTIVECAPTIONTEXT		= 19
; COLOR_INFOBK					= 24
; COLOR_INFOTEXT				= 23
; COLOR_MENU					= 4
; COLOR_MENUHILIGHT				= 29
; COLOR_MENUBAR					= 30
; COLOR_MENUTEXT				= 7
; COLOR_SCROLLBAR				= 0
; COLOR_WINDOW					= 5
; COLOR_WINDOWFRAME				= 6
; COLOR_WINDOWTEXT				= 8

SetSysColorToControl(hwnd, SysColor:=15)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	CreateRect( winRect, 0, 0, 0, 0 ) ;is 16 on both 32 and 64
	DllCall( "GetWindowRect", Ptr, hwnd, Ptr, &winRect )
	w := NumGet(winRect, 8, "UInt")  - NumGet(winRect, 0, "UInt")
	h := NumGet(winRect, 12, "UInt") - NumGet(winRect, 4, "UInt")
	bc := DllCall("GetSysColor", "Int", SysColor, "UInt")
	pBrushClear := Gdip_BrushCreateSolid(0xff000000 | (bc >> 16 | bc & 0xff00 | (bc & 0xff) << 16))
	pBitmap := Gdip_CreateBitmap(w, h), G := Gdip_GraphicsFromImage(pBitmap)
	Gdip_FillRectangle(G, pBrushClear, 0, 0, w, h)
	hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap)
	SetImage(hwnd, hBitmap)
	Gdip_DeleteBrush(pBrushClear)
	Gdip_DeleteGraphics(G), Gdip_DisposeImage(pBitmap), DeleteObject(hBitmap)
	return 0
}

;#####################################################################################

; Function				Gdip_BitmapFromScreen
; Description			Gets a gdi+ bitmap from the screen
;
; Screen				0 = All screens
;						Any numerical value = Just that screen
;						x|y|w|h = Take specific coordinates with a width and height
; Raster				raster operation code
;
; return					If the function succeeds, the return value is a pointer to a gdi+ bitmap
;						-1:		one or more of x,y,w,h not passed properly
;
; notes					If no raster operation is specified, then SRCCOPY is used to the returned bitmap

Gdip_BitmapFromScreen(Screen:=0, Raster:="")
{
	hhdc := 0
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	if (Screen = 0)
	{
		_x := DllCall( "GetSystemMetrics", "Int", 76 )
		_y := DllCall( "GetSystemMetrics", "Int", 77 )
		_w := DllCall( "GetSystemMetrics", "Int", 78 )
		_h := DllCall( "GetSystemMetrics", "Int", 79 )
	}
	else if (SubStr(Screen, 1, 5) = "hwnd:")
	{
		Screen := SubStr(Screen, 6)
		if !WinExist("ahk_id " Screen)
			return -2
		CreateRect( winRect, 0, 0, 0, 0 ) ;is 16 on both 32 and 64
		DllCall( "GetWindowRect", Ptr, Screen, Ptr, &winRect )
		_w := NumGet(winRect, 8, "UInt")  - NumGet(winRect, 0, "UInt")
		_h := NumGet(winRect, 12, "UInt") - NumGet(winRect, 4, "UInt")
		_x := _y := 0
		hhdc := GetDCEx(Screen, 3)
	}
	else if IsInteger(Screen)
	{
		M := GetMonitorInfo(Screen)
		_x := M.Left, _y := M.Top, _w := M.Right-M.Left, _h := M.Bottom-M.Top
	}
	else
	{
		S := StrSplit(Screen, "|")
		_x := S[1], _y := S[2], _w := S[3], _h := S[4]
	}

	if (_x = "") || (_y = "") || (_w = "") || (_h = "")
		return -1

	chdc := CreateCompatibleDC(), hbm := CreateDIBSection(_w, _h, chdc), obm := SelectObject(chdc, hbm), hhdc := hhdc ? hhdc : GetDC()
	BitBlt(chdc, 0, 0, _w, _h, hhdc, _x, _y, Raster)
	ReleaseDC(hhdc)

	pBitmap := Gdip_CreateBitmapFromHBITMAP(hbm)
	SelectObject(chdc, obm), DeleteObject(hbm), DeleteDC(hhdc), DeleteDC(chdc)
	return pBitmap
}

;#####################################################################################

; Function				Gdip_BitmapFromHWND
; Description			Uses PrintWindow to get a handle to the specified window and return a bitmap from it
;
; hwnd					handle to the window to get a bitmap from
;
; return				If the function succeeds, the return value is a pointer to a gdi+ bitmap
;
; notes					Window must not be not minimised in order to get a handle to it's client area

Gdip_BitmapFromHWND(hwnd)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	CreateRect( winRect, 0, 0, 0, 0 ) ;is 16 on both 32 and 64
	DllCall( "GetWindowRect", Ptr, hwnd, Ptr, &winRect )
	Width := NumGet(winRect, 8, "UInt") - NumGet(winRect, 0, "UInt")
	Height := NumGet(winRect, 12, "UInt") - NumGet(winRect, 4, "UInt")
	hbm := CreateDIBSection(Width, Height), hdc := CreateCompatibleDC(), obm := SelectObject(hdc, hbm)
	PrintWindow(hwnd, hdc)
	pBitmap := Gdip_CreateBitmapFromHBITMAP(hbm)
	SelectObject(hdc, obm), DeleteObject(hbm), DeleteDC(hdc)
	return pBitmap
}

;#####################################################################################

; Function				CreateRectF
; Description			Creates a RectF object, containing a the coordinates and dimensions of a rectangle
;
; RectF					Name to call the RectF object
; x						x-coordinate of the upper left corner of the rectangle
; y						y-coordinate of the upper left corner of the rectangle
; w						Width of the rectangle
; h						Height of the rectangle
;
; return				No return value

CreateRectF(ByRef RectF, x, y, w, h)
{
	VarSetCapacity(RectF, 16)
	NumPut(x, RectF, 0, "float"), NumPut(y, RectF, 4, "float"), NumPut(w, RectF, 8, "float"), NumPut(h, RectF, 12, "float")
}

;#####################################################################################

; Function				CreateRect
; Description			Creates a Rect object, containing a the coordinates and dimensions of a rectangle
;
; RectF		 			Name to call the RectF object
; x						x-coordinate of the upper left corner of the rectangle
; y						y-coordinate of the upper left corner of the rectangle
; w						Width of the rectangle
; h						Height of the rectangle
;
; return				No return value

CreateRect(ByRef Rect, x, y, w, h)
{
	VarSetCapacity(Rect, 16)
	NumPut(x, Rect, 0, "uint"), NumPut(y, Rect, 4, "uint"), NumPut(w, Rect, 8, "uint"), NumPut(h, Rect, 12, "uint")
}
;#####################################################################################

; Function				CreateSizeF
; Description			Creates a SizeF object, containing an 2 values
;
; SizeF					Name to call the SizeF object
; w						w-value for the SizeF object
; h						h-value for the SizeF object
;
; return				No Return value

CreateSizeF(ByRef SizeF, w, h)
{
	VarSetCapacity(SizeF, 8)
	NumPut(w, SizeF, 0, "float"), NumPut(h, SizeF, 4, "float")
}
;#####################################################################################

; Function				CreatePointF
; Description			Creates a SizeF object, containing an 2 values
;
; SizeF					Name to call the SizeF object
; w						w-value for the SizeF object
; h						h-value for the SizeF object
;
; return				No Return value

CreatePointF(ByRef PointF, x, y)
{
	VarSetCapacity(PointF, 8)
	NumPut(x, PointF, 0, "float"), NumPut(y, PointF, 4, "float")
}
;#####################################################################################

; Function				CreateDIBSection
; Description			The CreateDIBSection function creates a DIB (Device Independent Bitmap) that applications can write to directly
;
; w						width of the bitmap to create
; h						height of the bitmap to create
; hdc					a handle to the device context to use the palette from
; bpp					bits per pixel (32 = ARGB)
; ppvBits				A pointer to a variable that receives a pointer to the location of the DIB bit values
;
; return				returns a DIB. A gdi bitmap
;
; notes					ppvBits will receive the location of the pixels in the DIB

CreateDIBSection(w, h, hdc:="", bpp:=32, ByRef ppvBits:=0)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"

	hdc2 := hdc ? hdc : GetDC()
	VarSetCapacity(bi, 40, 0)

	NumPut(w, bi, 4, "uint")
	, NumPut(h, bi, 8, "uint")
	, NumPut(40, bi, 0, "uint")
	, NumPut(1, bi, 12, "ushort")
	, NumPut(0, bi, 16, "uInt")
	, NumPut(bpp, bi, 14, "ushort")

	hbm := DllCall("CreateDIBSection"
					, Ptr, hdc2
					, Ptr, &bi
					, "uint", 0
					, A_PtrSize ? "UPtr*" : "uint*", ppvBits
					, Ptr, 0
					, "uint", 0, Ptr)

	if !hdc
		ReleaseDC(hdc2)
	return hbm
}

;#####################################################################################

; Function				PrintWindow
; Description			The PrintWindow function copies a visual window into the specified device context (DC), typically a printer DC
;
; hwnd					A handle to the window that will be copied
; hdc					A handle to the device context
; Flags					Drawing options
;
; return				If the function succeeds, it returns a nonzero value
;
; PW_CLIENTONLY			= 1

PrintWindow(hwnd, hdc, Flags:=0)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"

	return DllCall("PrintWindow", Ptr, hwnd, Ptr, hdc, "uint", Flags)
}

;#####################################################################################

; Function				DestroyIcon
; Description			Destroys an icon and frees any memory the icon occupied
;
; hIcon					Handle to the icon to be destroyed. The icon must not be in use
;
; return				If the function succeeds, the return value is nonzero

DestroyIcon(hIcon)
{
	return DllCall("DestroyIcon", A_PtrSize ? "UPtr" : "UInt", hIcon)
}

;#####################################################################################

; Function:				GetIconDimensions
; Description:			Retrieves a given icon/cursor's width and height 
;
; hIcon					Pointer to an icon or cursor
; Width					ByRef variable. This variable is set to the icon's width
; Height				ByRef variable. This variable is set to the icon's height
;
; return				If the function succeeds, the return value is zero, otherwise:
;						-1 = Could not retrieve the icon's info. Check A_LastError for extended information
;						-2 = Could not delete the icon's bitmask bitmap
;						-3 = Could not delete the icon's color bitmap

GetIconDimensions(hIcon, ByRef Width, ByRef Height) {
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	Width := Height := 0

	VarSetCapacity(ICONINFO, size := 16 + 2 * A_PtrSize, 0)

	if !DllCall("user32\GetIconInfo", Ptr, hIcon, Ptr, &ICONINFO)
		return -1
	
	hbmMask := NumGet(&ICONINFO, 16, Ptr)
	hbmColor := NumGet(&ICONINFO, 16 + A_PtrSize, Ptr)
	VarSetCapacity(BITMAP, size, 0)

	if DllCall("gdi32\GetObject", Ptr, hbmColor, "Int", size, Ptr, &BITMAP)
	{
		Width := NumGet(&BITMAP, 4, "Int")
		Height := NumGet(&BITMAP, 8, "Int")
	}

	if !DllCall("gdi32\DeleteObject", Ptr, hbmMask)
		return -2
	
	if !DllCall("gdi32\DeleteObject", Ptr, hbmColor)
		return -3

	return 0
}

;#####################################################################################

PaintDesktop(hdc)
{
	return DllCall("PaintDesktop", A_PtrSize ? "UPtr" : "UInt", hdc)
}

;#####################################################################################

CreateCompatibleBitmap(hdc, w, h)
{
	return DllCall("gdi32\CreateCompatibleBitmap", A_PtrSize ? "UPtr" : "UInt", hdc, "int", w, "int", h)
}

;#####################################################################################

; Function				CreateCompatibleDC
; Description			This function creates a memory device context (DC) compatible with the specified device
;
; hdc					Handle to an existing device context
;
; return				returns the handle to a device context or 0 on failure
;
; notes					If this handle is 0 (by default), the function creates a memory device context compatible with the application's current screen

CreateCompatibleDC(hdc:=0)
{
	return DllCall("CreateCompatibleDC", A_PtrSize ? "UPtr" : "UInt", hdc)
}

;#####################################################################################

; Function				SelectObject
; Description			The SelectObject function selects an object into the specified device context (DC). The new object replaces the previous object of the same type
;
; hdc					Handle to a DC
; hgdiobj				A handle to the object to be selected into the DC
;
; return				If the selected object is not a region and the function succeeds, the return value is a handle to the object being replaced
;
; notes					The specified object must have been created by using one of the following functions
;						Bitmap - CreateBitmap, CreateBitmapIndirect, CreateCompatibleBitmap, CreateDIBitmap, CreateDIBSection (A single bitmap cannot be selected into more than one DC at the same time)
;						Brush - CreateBrushIndirect, CreateDIBPatternBrush, CreateDIBPatternBrushPt, CreateHatchBrush, CreatePatternBrush, CreateSolidBrush
;						Font - CreateFont, CreateFontIndirect
;						Pen - CreatePen, CreatePenIndirect
;						Region - CombineRgn, CreateEllipticRgn, CreateEllipticRgnIndirect, CreatePolygonRgn, CreateRectRgn, CreateRectRgnIndirect
;
; notes					If the selected object is a region and the function succeeds, the return value is one of the following value
;
; SIMPLEREGION			= 2 Region consists of a single rectangle
; COMPLEXREGION			= 3 Region consists of more than one rectangle
; NULLREGION			= 1 Region is empty

SelectObject(hdc, hgdiobj)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"

	return DllCall("SelectObject", Ptr, hdc, Ptr, hgdiobj)
}

;#####################################################################################

; Function				DeleteObject
; Description			This function deletes a logical pen, brush, font, bitmap, region, or palette, freeing all system resources associated with the object
;						After the object is deleted, the specified handle is no longer valid
;
; hObject				Handle to a logical pen, brush, font, bitmap, region, or palette to delete
;
; return				Nonzero indicates success. Zero indicates that the specified handle is not valid or that the handle is currently selected into a device context

DeleteObject(hObject)
{
	return DllCall("DeleteObject", A_PtrSize ? "UPtr" : "UInt", hObject)
}

;#####################################################################################

; Function				GetDC
; Description			This function retrieves a handle to a display device context (DC) for the client area of the specified window.
;						The display device context can be used in subsequent graphics display interface (GDI) functions to draw in the client area of the window.
;
; hwnd					Handle to the window whose device context is to be retrieved. If this value is NULL, GetDC retrieves the device context for the entire screen
;
; return				The handle the device context for the specified window's client area indicates success. NULL indicates failure

GetDC(hwnd:=0)
{
	return DllCall("GetDC", A_PtrSize ? "UPtr" : "UInt", hwnd)
}

;#####################################################################################

; DCX_CACHE = 0x2
; DCX_CLIPCHILDREN = 0x8
; DCX_CLIPSIBLINGS = 0x10
; DCX_EXCLUDERGN = 0x40
; DCX_EXCLUDEUPDATE = 0x100
; DCX_INTERSECTRGN = 0x80
; DCX_INTERSECTUPDATE = 0x200
; DCX_LOCKWINDOWUPDATE = 0x400
; DCX_NORECOMPUTE = 0x100000
; DCX_NORESETATTRS = 0x4
; DCX_PARENTCLIP = 0x20
; DCX_VALIDATE = 0x200000
; DCX_WINDOW = 0x1

GetDCEx(hwnd, flags:=0, hrgnClip:=0)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"

	return DllCall("GetDCEx", Ptr, hwnd, Ptr, hrgnClip, "int", flags)
}

;#####################################################################################

; Function				ReleaseDC
; Description			This function releases a device context (DC), freeing it for use by other applications. The effect of ReleaseDC depends on the type of device context
;
; hdc					Handle to the device context to be released
; hwnd					Handle to the window whose device context is to be released
;
; return				1 = released
;						0 = not released
;
; notes					The application must call the ReleaseDC function for each call to the GetWindowDC function and for each call to the GetDC function that retrieves a common device context
;						An application cannot use the ReleaseDC function to release a device context that was created by calling the CreateDC function; instead, it must use the DeleteDC function.

ReleaseDC(hdc, hwnd:=0)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"

	return DllCall("ReleaseDC", Ptr, hwnd, Ptr, hdc)
}

;#####################################################################################

; Function				DeleteDC
; Description			The DeleteDC function deletes the specified device context (DC)
;
; hdc					A handle to the device context
;
; return				If the function succeeds, the return value is nonzero
;
; notes					An application must not delete a DC whose handle was obtained by calling the GetDC function. Instead, it must call the ReleaseDC function to free the DC

DeleteDC(hdc)
{
	return DllCall("DeleteDC", A_PtrSize ? "UPtr" : "UInt", hdc)
}
;#####################################################################################

; Function				Gdip_LibraryVersion
; Description			Get the current library version
;
; return				the library version
;
; notes					This is useful for non compiled programs to ensure that a person doesn't run an old version when testing your scripts

Gdip_LibraryVersion()
{
	return 1.45
}

;#####################################################################################

; Function				Gdip_LibrarySubVersion
; Description			Get the current library sub version
;
; return				the library sub version
;
; notes					This is the sub-version currently maintained by Rseding91
; 					Updated by guest3456 preliminary AHK v2 support
Gdip_LibrarySubVersion()
{
	return 1.54
}

;#####################################################################################

; Function:				Gdip_BitmapFromBRA
; Description: 			Gets a pointer to a gdi+ bitmap from a BRA file
;
; BRAFromMemIn			The variable for a BRA file read to memory
; File					The name of the file, or its number that you would like (This depends on alternate parameter)
; Alternate				Changes whether the File parameter is the file name or its number
;
; return					If the function succeeds, the return value is a pointer to a gdi+ bitmap
;						-1 = The BRA variable is empty
;						-2 = The BRA has an incorrect header
;						-3 = The BRA has information missing
;						-4 = Could not find file inside the BRA

Gdip_BitmapFromBRA(ByRef BRAFromMemIn, File, Alternate := 0) {
	pBitmap := ""

	If !(BRAFromMemIn)
		Return -1
	Headers := StrSplit(StrGet(&BRAFromMemIn, 256, "CP0"), "`n")
	Header := StrSplit(Headers.1, "|")
	If (Header.Length() != 4) || (Header.2 != "BRA!")
		Return -2
	_Info := StrSplit(Headers.2, "|")
	If (_Info.Length() != 3)
		Return -3
	OffsetTOC := StrPut(Headers.1, "CP0") + StrPut(Headers.2, "CP0") ;  + 2
	OffsetData := _Info.2
	SearchIndex := Alternate ? 1 : 2
	TOC := StrGet(&BRAFromMemIn + OffsetTOC, OffsetData - OffsetTOC - 1, "CP0")
	RX1 := A_AhkVersion < "2" ? "mi`nO)^" : "mi`n)^"
	Offset := Size := 0
	If RegExMatch(TOC, RX1 . (Alternate ? File "\|.+?" : "\d+\|" . File) . "\|(\d+)\|(\d+)$", FileInfo) {
		Offset := OffsetData + FileInfo.1
		Size := FileInfo.2
	}
	If (Size = 0)
		Return -4
	hData := DllCall("GlobalAlloc", "UInt", 2, "UInt", Size, "UPtr")
	pData := DllCall("GlobalLock", "Ptr", hData, "UPtr")
	DllCall("RtlMoveMemory", "Ptr", pData, "Ptr", &BRAFromMemIn + Offset, "Ptr", Size)
	DllCall("GlobalUnlock", "Ptr", hData)
	DllCall("Ole32.dll\CreateStreamOnHGlobal", "Ptr", hData, "Int", 1, "PtrP", pStream)
	DllCall("Gdiplus.dll\GdipCreateBitmapFromStream", "Ptr", pStream, "PtrP", pBitmap)
	ObjRelease(pStream)
	Return pBitmap
}

;#####################################################################################

; Function:				Gdip_BitmapFromBase64
; Description:			Creates a bitmap from a Base64 encoded string
;
; Base64				ByRef variable. Base64 encoded string. Immutable, ByRef to avoid performance overhead of passing long strings.
;
; return				If the function succeeds, the return value is a pointer to a bitmap, otherwise:
;						-1 = Could not calculate the length of the required buffer
;						-2 = Could not decode the Base64 encoded string
;						-3 = Could not create a memory stream

Gdip_BitmapFromBase64(ByRef Base64)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"

	; calculate the length of the buffer needed
	if !(DllCall("crypt32\CryptStringToBinary", Ptr, &Base64, "UInt", 0, "UInt", 0x01, Ptr, 0, "UIntP", DecLen, Ptr, 0, Ptr, 0))
		return -1

	VarSetCapacity(Dec, DecLen, 0)

	; decode the Base64 encoded string
	if !(DllCall("crypt32\CryptStringToBinary", Ptr, &Base64, "UInt", 0, "UInt", 0x01, Ptr, &Dec, "UIntP", DecLen, Ptr, 0, Ptr, 0))
		return -2

	; create a memory stream
	if !(pStream := DllCall("shlwapi\SHCreateMemStream", Ptr, &Dec, "UInt", DecLen, "UPtr"))
		return -3

	DllCall("gdiplus\GdipCreateBitmapFromStreamICM", Ptr, pStream, "PtrP", pBitmap)
	ObjRelease(pStream)

	return pBitmap
}

;#####################################################################################

; Function				Gdip_DrawRectangle
; Description			This function uses a pen to draw the outline of a rectangle into the Graphics of a bitmap
;
; pGraphics				Pointer to the Graphics of a bitmap
; pPen					Pointer to a pen
; x						x-coordinate of the top left of the rectangle
; y						y-coordinate of the top left of the rectangle
; w						width of the rectanlge
; h						height of the rectangle
;
; return				status enumeration. 0 = success
;
; notes					as all coordinates are taken from the top left of each pixel, then the entire width/height should be specified as subtracting the pen width

Gdip_DrawRectangle(pGraphics, pPen, x, y, w, h)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"

	return DllCall("gdiplus\GdipDrawRectangle", Ptr, pGraphics, Ptr, pPen, "float", x, "float", y, "float", w, "float", h)
}

;#####################################################################################

; Function				Gdip_DrawRoundedRectangle
; Description			This function uses a pen to draw the outline of a rounded rectangle into the Graphics of a bitmap
;
; pGraphics				Pointer to the Graphics of a bitmap
; pPen					Pointer to a pen
; x						x-coordinate of the top left of the rounded rectangle
; y						y-coordinate of the top left of the rounded rectangle
; w						width of the rectanlge
; h						height of the rectangle
; r						radius of the rounded corners
;
; return				status enumeration. 0 = success
;
; notes					as all coordinates are taken from the top left of each pixel, then the entire width/height should be specified as subtracting the pen width

Gdip_DrawRoundedRectangle(pGraphics, pPen, x, y, w, h, r)
{
	Gdip_SetClipRect(pGraphics, x-r, y-r, 2*r, 2*r, 4)
	Gdip_SetClipRect(pGraphics, x+w-r, y-r, 2*r, 2*r, 4)
	Gdip_SetClipRect(pGraphics, x-r, y+h-r, 2*r, 2*r, 4)
	Gdip_SetClipRect(pGraphics, x+w-r, y+h-r, 2*r, 2*r, 4)
	_E := Gdip_DrawRectangle(pGraphics, pPen, x, y, w, h)
	Gdip_ResetClip(pGraphics)
	Gdip_SetClipRect(pGraphics, x-(2*r), y+r, w+(4*r), h-(2*r), 4)
	Gdip_SetClipRect(pGraphics, x+r, y-(2*r), w-(2*r), h+(4*r), 4)
	Gdip_DrawEllipse(pGraphics, pPen, x, y, 2*r, 2*r)
	Gdip_DrawEllipse(pGraphics, pPen, x+w-(2*r), y, 2*r, 2*r)
	Gdip_DrawEllipse(pGraphics, pPen, x, y+h-(2*r), 2*r, 2*r)
	Gdip_DrawEllipse(pGraphics, pPen, x+w-(2*r), y+h-(2*r), 2*r, 2*r)
	Gdip_ResetClip(pGraphics)
	return _E
}

;#####################################################################################

; Function				Gdip_DrawEllipse
; Description			This function uses a pen to draw the outline of an ellipse into the Graphics of a bitmap
;
; pGraphics				Pointer to the Graphics of a bitmap
; pPen					Pointer to a pen
; x						x-coordinate of the top left of the rectangle the ellipse will be drawn into
; y						y-coordinate of the top left of the rectangle the ellipse will be drawn into
; w						width of the ellipse
; h						height of the ellipse
;
; return				status enumeration. 0 = success
;
; notes					as all coordinates are taken from the top left of each pixel, then the entire width/height should be specified as subtracting the pen width

Gdip_DrawEllipse(pGraphics, pPen, x, y, w, h)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"

	return DllCall("gdiplus\GdipDrawEllipse", Ptr, pGraphics, Ptr, pPen, "float", x, "float", y, "float", w, "float", h)
}

;#####################################################################################

; Function				Gdip_DrawBezier
; Description			This function uses a pen to draw the outline of a bezier (a weighted curve) into the Graphics of a bitmap
;
; pGraphics				Pointer to the Graphics of a bitmap
; pPen					Pointer to a pen
; x1					x-coordinate of the start of the bezier
; y1					y-coordinate of the start of the bezier
; x2					x-coordinate of the first arc of the bezier
; y2					y-coordinate of the first arc of the bezier
; x3					x-coordinate of the second arc of the bezier
; y3					y-coordinate of the second arc of the bezier
; x4					x-coordinate of the end of the bezier
; y4					y-coordinate of the end of the bezier
;
; return				status enumeration. 0 = success
;
; notes					as all coordinates are taken from the top left of each pixel, then the entire width/height should be specified as subtracting the pen width

Gdip_DrawBezier(pGraphics, pPen, x1, y1, x2, y2, x3, y3, x4, y4)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"

	return DllCall("gdiplus\GdipDrawBezier"
					, Ptr, pgraphics
					, Ptr, pPen
					, "float", x1
					, "float", y1
					, "float", x2
					, "float", y2
					, "float", x3
					, "float", y3
					, "float", x4
					, "float", y4)
}

;#####################################################################################

; Function				Gdip_DrawArc
; Description			This function uses a pen to draw the outline of an arc into the Graphics of a bitmap
;
; pGraphics				Pointer to the Graphics of a bitmap
; pPen					Pointer to a pen
; x						x-coordinate of the start of the arc
; y						y-coordinate of the start of the arc
; w						width of the arc
; h						height of the arc
; StartAngle			specifies the angle between the x-axis and the starting point of the arc
; SweepAngle			specifies the angle between the starting and ending points of the arc
;
; return				status enumeration. 0 = success
;
; notes					as all coordinates are taken from the top left of each pixel, then the entire width/height should be specified as subtracting the pen width

Gdip_DrawArc(pGraphics, pPen, x, y, w, h, StartAngle, SweepAngle)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"

	return DllCall("gdiplus\GdipDrawArc"
					, Ptr, pGraphics
					, Ptr, pPen
					, "float", x
					, "float", y
					, "float", w
					, "float", h
					, "float", StartAngle
					, "float", SweepAngle)
}

;#####################################################################################

; Function				Gdip_DrawPie
; Description			This function uses a pen to draw the outline of a pie into the Graphics of a bitmap
;
; pGraphics				Pointer to the Graphics of a bitmap
; pPen					Pointer to a pen
; x						x-coordinate of the start of the pie
; y						y-coordinate of the start of the pie
; w						width of the pie
; h						height of the pie
; StartAngle			specifies the angle between the x-axis and the starting point of the pie
; SweepAngle			specifies the angle between the starting and ending points of the pie
;
; return				status enumeration. 0 = success
;
; notes					as all coordinates are taken from the top left of each pixel, then the entire width/height should be specified as subtracting the pen width

Gdip_DrawPie(pGraphics, pPen, x, y, w, h, StartAngle, SweepAngle)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"

	return DllCall("gdiplus\GdipDrawPie", Ptr, pGraphics, Ptr, pPen, "float", x, "float", y, "float", w, "float", h, "float", StartAngle, "float", SweepAngle)
}

;#####################################################################################

; Function				Gdip_DrawLine
; Description			This function uses a pen to draw a line into the Graphics of a bitmap
;
; pGraphics				Pointer to the Graphics of a bitmap
; pPen					Pointer to a pen
; x1					x-coordinate of the start of the line
; y1					y-coordinate of the start of the line
; x2					x-coordinate of the end of the line
; y2					y-coordinate of the end of the line
;
; return				status enumeration. 0 = success

Gdip_DrawLine(pGraphics, pPen, x1, y1, x2, y2)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"

	return DllCall("gdiplus\GdipDrawLine"
					, Ptr, pGraphics
					, Ptr, pPen
					, "float", x1
					, "float", y1
					, "float", x2
					, "float", y2)
}

;#####################################################################################

; Function				Gdip_DrawLines
; Description			This function uses a pen to draw a series of joined lines into the Graphics of a bitmap
;
; pGraphics				Pointer to the Graphics of a bitmap
; pPen					Pointer to a pen
; Points				the coordinates of all the points passed as x1,y1|x2,y2|x3,y3.....
;
; return				status enumeration. 0 = success

Gdip_DrawLines(pGraphics, pPen, Points)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	Points := StrSplit(Points, "|")
	VarSetCapacity(PointF, 8*Points.Length())
	for eachPoint, Point in Points
	{
		Coord := StrSplit(Point, ",")
		NumPut(Coord[1], PointF, 8*(A_Index-1), "float"), NumPut(Coord[2], PointF, (8*(A_Index-1))+4, "float")
	}
	return DllCall("gdiplus\GdipDrawLines", Ptr, pGraphics, Ptr, pPen, Ptr, &PointF, "int", Points.Length())
}

;#####################################################################################

; Function				Gdip_FillRectangle
; Description			This function uses a brush to fill a rectangle in the Graphics of a bitmap
;
; pGraphics				Pointer to the Graphics of a bitmap
; pBrush				Pointer to a brush
; x						x-coordinate of the top left of the rectangle
; y						y-coordinate of the top left of the rectangle
; w						width of the rectanlge
; h						height of the rectangle
;
; return				status enumeration. 0 = success

Gdip_FillRectangle(pGraphics, pBrush, x, y, w, h)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"

	return DllCall("gdiplus\GdipFillRectangle"
					, Ptr, pGraphics
					, Ptr, pBrush
					, "float", x
					, "float", y
					, "float", w
					, "float", h)
}

;#####################################################################################

; Function				Gdip_FillRoundedRectangle
; Description			This function uses a brush to fill a rounded rectangle in the Graphics of a bitmap
;
; pGraphics				Pointer to the Graphics of a bitmap
; pBrush				Pointer to a brush
; x						x-coordinate of the top left of the rounded rectangle
; y						y-coordinate of the top left of the rounded rectangle
; w						width of the rectanlge
; h						height of the rectangle
; r						radius of the rounded corners
;
; return				status enumeration. 0 = success

Gdip_FillRoundedRectangle(pGraphics, pBrush, x, y, w, h, r)
{
	Region := Gdip_GetClipRegion(pGraphics)
	Gdip_SetClipRect(pGraphics, x-r, y-r, 2*r, 2*r, 4)
	Gdip_SetClipRect(pGraphics, x+w-r, y-r, 2*r, 2*r, 4)
	Gdip_SetClipRect(pGraphics, x-r, y+h-r, 2*r, 2*r, 4)
	Gdip_SetClipRect(pGraphics, x+w-r, y+h-r, 2*r, 2*r, 4)
	_E := Gdip_FillRectangle(pGraphics, pBrush, x, y, w, h)
	Gdip_SetClipRegion(pGraphics, Region, 0)
	Gdip_SetClipRect(pGraphics, x-(2*r), y+r, w+(4*r), h-(2*r), 4)
	Gdip_SetClipRect(pGraphics, x+r, y-(2*r), w-(2*r), h+(4*r), 4)
	Gdip_FillEllipse(pGraphics, pBrush, x, y, 2*r, 2*r)
	Gdip_FillEllipse(pGraphics, pBrush, x+w-(2*r), y, 2*r, 2*r)
	Gdip_FillEllipse(pGraphics, pBrush, x, y+h-(2*r), 2*r, 2*r)
	Gdip_FillEllipse(pGraphics, pBrush, x+w-(2*r), y+h-(2*r), 2*r, 2*r)
	Gdip_SetClipRegion(pGraphics, Region, 0)
	Gdip_DeleteRegion(Region)
	return _E
}

;#####################################################################################

; Function				Gdip_FillPolygon
; Description			This function uses a brush to fill a polygon in the Graphics of a bitmap
;
; pGraphics				Pointer to the Graphics of a bitmap
; pBrush				Pointer to a brush
; Points				the coordinates of all the points passed as x1,y1|x2,y2|x3,y3.....
;
; return				status enumeration. 0 = success
;
; notes					Alternate will fill the polygon as a whole, wheras winding will fill each new "segment"
; Alternate 			= 0
; Winding 				= 1

Gdip_FillPolygon(pGraphics, pBrush, Points, FillMode:=0)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"

	Points := StrSplit(Points, "|")
	VarSetCapacity(PointF, 8*Points.Length())
	For eachPoint, Point in Points
	{
		Coord := StrSplit(Point, ",")
		NumPut(Coord[1], PointF, 8*(A_Index-1), "float"), NumPut(Coord[2], PointF, (8*(A_Index-1))+4, "float")
	}
	return DllCall("gdiplus\GdipFillPolygon", Ptr, pGraphics, Ptr, pBrush, Ptr, &PointF, "int", Points.Length(), "int", FillMode)
}

;#####################################################################################

; Function				Gdip_FillPie
; Description			This function uses a brush to fill a pie in the Graphics of a bitmap
;
; pGraphics				Pointer to the Graphics of a bitmap
; pBrush				Pointer to a brush
; x						x-coordinate of the top left of the pie
; y						y-coordinate of the top left of the pie
; w						width of the pie
; h						height of the pie
; StartAngle			specifies the angle between the x-axis and the starting point of the pie
; SweepAngle			specifies the angle between the starting and ending points of the pie
;
; return				status enumeration. 0 = success

Gdip_FillPie(pGraphics, pBrush, x, y, w, h, StartAngle, SweepAngle)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"

	return DllCall("gdiplus\GdipFillPie"
					, Ptr, pGraphics
					, Ptr, pBrush
					, "float", x
					, "float", y
					, "float", w
					, "float", h
					, "float", StartAngle
					, "float", SweepAngle)
}

;#####################################################################################

; Function				Gdip_FillEllipse
; Description			This function uses a brush to fill an ellipse in the Graphics of a bitmap
;
; pGraphics				Pointer to the Graphics of a bitmap
; pBrush				Pointer to a brush
; x						x-coordinate of the top left of the ellipse
; y						y-coordinate of the top left of the ellipse
; w						width of the ellipse
; h						height of the ellipse
;
; return				status enumeration. 0 = success

Gdip_FillEllipse(pGraphics, pBrush, x, y, w, h)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"

	return DllCall("gdiplus\GdipFillEllipse", Ptr, pGraphics, Ptr, pBrush, "float", x, "float", y, "float", w, "float", h)
}

;#####################################################################################

; Function				Gdip_FillRegion
; Description			This function uses a brush to fill a region in the Graphics of a bitmap
;
; pGraphics				Pointer to the Graphics of a bitmap
; pBrush				Pointer to a brush
; Region				Pointer to a Region
;
; return				status enumeration. 0 = success
;
; notes					You can create a region Gdip_CreateRegion() and then add to this

Gdip_FillRegion(pGraphics, pBrush, Region)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"

	return DllCall("gdiplus\GdipFillRegion", Ptr, pGraphics, Ptr, pBrush, Ptr, Region)
}

;#####################################################################################

; Function				Gdip_FillPath
; Description			This function uses a brush to fill a path in the Graphics of a bitmap
;
; pGraphics				Pointer to the Graphics of a bitmap
; pBrush				Pointer to a brush
; Region				Pointer to a Path
;
; return				status enumeration. 0 = success

Gdip_FillPath(pGraphics, pBrush, pPath)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"

	return DllCall("gdiplus\GdipFillPath", Ptr, pGraphics, Ptr, pBrush, Ptr, pPath)
}

;#####################################################################################

; Function				Gdip_DrawImagePointsRect
; Description			This function draws a bitmap into the Graphics of another bitmap and skews it
;
; pGraphics				Pointer to the Graphics of a bitmap
; pBitmap				Pointer to a bitmap to be drawn
; Points				Points passed as x1,y1|x2,y2|x3,y3 (3 points: top left, top right, bottom left) describing the drawing of the bitmap
; sx					x-coordinate of source upper-left corner
; sy					y-coordinate of source upper-left corner
; sw					width of source rectangle
; sh					height of source rectangle
; Matrix				a matrix used to alter image attributes when drawing
;
; return				status enumeration. 0 = success
;
; notes					if sx,sy,sw,sh are missed then the entire source bitmap will be used
;						Matrix can be omitted to just draw with no alteration to ARGB
;						Matrix may be passed as a digit from 0 - 1 to change just transparency
;						Matrix can be passed as a matrix with any delimiter

Gdip_DrawImagePointsRect(pGraphics, pBitmap, Points, sx:="", sy:="", sw:="", sh:="", Matrix:=1)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"

	Points := StrSplit(Points, "|")
	VarSetCapacity(PointF, 8*Points.Length())
	For eachPoint, Point in Points
	{
		Coord := StrSplit(Point, ",")
		NumPut(Coord[1], PointF, 8*(A_Index-1), "float"), NumPut(Coord[2], PointF, (8*(A_Index-1))+4, "float")
	}

	if !IsNumber(Matrix)
		ImageAttr := Gdip_SetImageAttributesColorMatrix(Matrix)
	else if (Matrix != 1)
		ImageAttr := Gdip_SetImageAttributesColorMatrix("1|0|0|0|0|0|1|0|0|0|0|0|1|0|0|0|0|0|" Matrix "|0|0|0|0|0|1")

	if (sx = "" && sy = "" && sw = "" && sh = "")
	{
		sx := 0, sy := 0
		sw := Gdip_GetImageWidth(pBitmap)
		sh := Gdip_GetImageHeight(pBitmap)
	}

	_E := DllCall("gdiplus\GdipDrawImagePointsRect"
				, Ptr, pGraphics
				, Ptr, pBitmap
				, Ptr, &PointF
				, "int", Points.Length()
				, "float", sx
				, "float", sy
				, "float", sw
				, "float", sh
				, "int", 2
				, Ptr, ImageAttr
				, Ptr, 0
				, Ptr, 0)
	if ImageAttr
		Gdip_DisposeImageAttributes(ImageAttr)
	return _E
}

;#####################################################################################

; Function				Gdip_DrawImage
; Description			This function draws a bitmap into the Graphics of another bitmap
;
; pGraphics				Pointer to the Graphics of a bitmap
; pBitmap				Pointer to a bitmap to be drawn
; dx					x-coord of destination upper-left corner
; dy					y-coord of destination upper-left corner
; dw					width of destination image
; dh					height of destination image
; sx					x-coordinate of source upper-left corner
; sy					y-coordinate of source upper-left corner
; sw					width of source image
; sh					height of source image
; Matrix				a matrix used to alter image attributes when drawing
;
; return				status enumeration. 0 = success
;
; notes					if sx,sy,sw,sh are missed then the entire source bitmap will be used
;						Gdip_DrawImage performs faster
;						Matrix can be omitted to just draw with no alteration to ARGB
;						Matrix may be passed as a digit from 0 - 1 to change just transparency
;						Matrix can be passed as a matrix with any delimiter. For example:
;						MatrixBright=
;						(
;						1.5		|0		|0		|0		|0
;						0		|1.5	|0		|0		|0
;						0		|0		|1.5	|0		|0
;						0		|0		|0		|1		|0
;						0.05	|0.05	|0.05	|0		|1
;						)
;
; notes					MatrixBright = 1.5|0|0|0|0|0|1.5|0|0|0|0|0|1.5|0|0|0|0|0|1|0|0.05|0.05|0.05|0|1
;						MatrixGreyScale = 0.299|0.299|0.299|0|0|0.587|0.587|0.587|0|0|0.114|0.114|0.114|0|0|0|0|0|1|0|0|0|0|0|1
;						MatrixNegative = -1|0|0|0|0|0|-1|0|0|0|0|0|-1|0|0|0|0|0|1|0|1|1|1|0|1

Gdip_DrawImage(pGraphics, pBitmap, dx:="", dy:="", dw:="", dh:="", sx:="", sy:="", sw:="", sh:="", Matrix:=1)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"

	if !IsNumber(Matrix)
		ImageAttr := Gdip_SetImageAttributesColorMatrix(Matrix)
	else if (Matrix != 1)
		ImageAttr := Gdip_SetImageAttributesColorMatrix("1|0|0|0|0|0|1|0|0|0|0|0|1|0|0|0|0|0|" Matrix "|0|0|0|0|0|1")

	if (sx = "" && sy = "" && sw = "" && sh = "")
	{
		if (dx = "" && dy = "" && dw = "" && dh = "")
		{
			sx := dx := 0, sy := dy := 0
			sw := dw := Gdip_GetImageWidth(pBitmap)
			sh := dh := Gdip_GetImageHeight(pBitmap)
		}
		else
		{
			sx := sy := 0
			sw := Gdip_GetImageWidth(pBitmap)
			sh := Gdip_GetImageHeight(pBitmap)
		}
	}

	_E := DllCall("gdiplus\GdipDrawImageRectRect"
				, Ptr, pGraphics
				, Ptr, pBitmap
				, "float", dx
				, "float", dy
				, "float", dw
				, "float", dh
				, "float", sx
				, "float", sy
				, "float", sw
				, "float", sh
				, "int", 2
				, Ptr, ImageAttr
				, Ptr, 0
				, Ptr, 0)
	if ImageAttr
		Gdip_DisposeImageAttributes(ImageAttr)
	return _E
}

;#####################################################################################

; Function				Gdip_SetImageAttributesColorMatrix
; Description			This function creates an image matrix ready for drawing
;
; Matrix				a matrix used to alter image attributes when drawing
;						passed with any delimeter
;
; return				returns an image matrix on sucess or 0 if it fails
;
; notes					MatrixBright = 1.5|0|0|0|0|0|1.5|0|0|0|0|0|1.5|0|0|0|0|0|1|0|0.05|0.05|0.05|0|1
;						MatrixGreyScale = 0.299|0.299|0.299|0|0|0.587|0.587|0.587|0|0|0.114|0.114|0.114|0|0|0|0|0|1|0|0|0|0|0|1
;						MatrixNegative = -1|0|0|0|0|0|-1|0|0|0|0|0|-1|0|0|0|0|0|1|0|1|1|1|0|1

Gdip_SetImageAttributesColorMatrix(Matrix)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"

	VarSetCapacity(ColourMatrix, 100, 0)
	Matrix := RegExReplace(RegExReplace(Matrix, "^[^\d-\.]+([\d\.])", "$1", , 1), "[^\d-\.]+", "|")
	Matrix := StrSplit(Matrix, "|")
	Loop 25
	{
		M := (Matrix[A_Index] != "") ? Matrix[A_Index] : Mod(A_Index-1, 6) ? 0 : 1
		NumPut(M, ColourMatrix, (A_Index-1)*4, "float")
	}
	DllCall("gdiplus\GdipCreateImageAttributes", A_PtrSize ? "UPtr*" : "uint*", ImageAttr)
	DllCall("gdiplus\GdipSetImageAttributesColorMatrix", Ptr, ImageAttr, "int", 1, "int", 1, Ptr, &ColourMatrix, Ptr, 0, "int", 0)
	return ImageAttr
}

;#####################################################################################

; Function				Gdip_GraphicsFromImage
; Description			This function gets the graphics for a bitmap used for drawing functions
;
; pBitmap				Pointer to a bitmap to get the pointer to its graphics
;
; return				returns a pointer to the graphics of a bitmap
;
; notes					a bitmap can be drawn into the graphics of another bitmap

Gdip_GraphicsFromImage(pBitmap)
{
	DllCall("gdiplus\GdipGetImageGraphicsContext", A_PtrSize ? "UPtr" : "UInt", pBitmap, A_PtrSize ? "UPtr*" : "UInt*", pGraphics)
	return pGraphics
}

;#####################################################################################

; Function				Gdip_GraphicsFromHDC
; Description			This function gets the graphics from the handle to a device context
;
; hdc					This is the handle to the device context
;
; return				returns a pointer to the graphics of a bitmap
;
; notes					You can draw a bitmap into the graphics of another bitmap

Gdip_GraphicsFromHDC(hdc)
{
	pGraphics := ""

	DllCall("gdiplus\GdipCreateFromHDC", A_PtrSize ? "UPtr" : "UInt", hdc, A_PtrSize ? "UPtr*" : "UInt*", pGraphics)
	return pGraphics
}

;#####################################################################################

; Function				Gdip_GetDC
; Description			This function gets the device context of the passed Graphics
;
; hdc					This is the handle to the device context
;
; return				returns the device context for the graphics of a bitmap

Gdip_GetDC(pGraphics)
{
	DllCall("gdiplus\GdipGetDC", A_PtrSize ? "UPtr" : "UInt", pGraphics, A_PtrSize ? "UPtr*" : "UInt*", hdc)
	return hdc
}

;#####################################################################################

; Function				Gdip_ReleaseDC
; Description			This function releases a device context from use for further use
;
; pGraphics				Pointer to the graphics of a bitmap
; hdc					This is the handle to the device context
;
; return				status enumeration. 0 = success

Gdip_ReleaseDC(pGraphics, hdc)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"

	return DllCall("gdiplus\GdipReleaseDC", Ptr, pGraphics, Ptr, hdc)
}

;#####################################################################################

; Function				Gdip_GraphicsClear
; Description			Clears the graphics of a bitmap ready for further drawing
;
; pGraphics				Pointer to the graphics of a bitmap
; ARGB					The colour to clear the graphics to
;
; return				status enumeration. 0 = success
;
; notes					By default this will make the background invisible
;						Using clipping regions you can clear a particular area on the graphics rather than clearing the entire graphics

Gdip_GraphicsClear(pGraphics, ARGB:=0x00ffffff)
{
	return DllCall("gdiplus\GdipGraphicsClear", A_PtrSize ? "UPtr" : "UInt", pGraphics, "int", ARGB)
}

;#####################################################################################

; Function				Gdip_BlurBitmap
; Description			Gives a pointer to a blurred bitmap from a pointer to a bitmap
;
; pBitmap				Pointer to a bitmap to be blurred
; Blur					The Amount to blur a bitmap by from 1 (least blur) to 100 (most blur)
;
; return				If the function succeeds, the return value is a pointer to the new blurred bitmap
;						-1 = The blur parameter is outside the range 1-100
;
; notes					This function will not dispose of the original bitmap

Gdip_BlurBitmap(pBitmap, Blur)
{
	if (Blur > 100) || (Blur < 1)
		return -1

	sWidth := Gdip_GetImageWidth(pBitmap), sHeight := Gdip_GetImageHeight(pBitmap)
	dWidth := sWidth//Blur, dHeight := sHeight//Blur

	pBitmap1 := Gdip_CreateBitmap(dWidth, dHeight)
	G1 := Gdip_GraphicsFromImage(pBitmap1)
	Gdip_SetInterpolationMode(G1, 7)
	Gdip_DrawImage(G1, pBitmap, 0, 0, dWidth, dHeight, 0, 0, sWidth, sHeight)

	Gdip_DeleteGraphics(G1)

	pBitmap2 := Gdip_CreateBitmap(sWidth, sHeight)
	G2 := Gdip_GraphicsFromImage(pBitmap2)
	Gdip_SetInterpolationMode(G2, 7)
	Gdip_DrawImage(G2, pBitmap1, 0, 0, sWidth, sHeight, 0, 0, dWidth, dHeight)

	Gdip_DeleteGraphics(G2)
	Gdip_DisposeImage(pBitmap1)
	return pBitmap2
}

;#####################################################################################

; Function:				Gdip_SaveBitmapToFile
; Description:			Saves a bitmap to a file in any supported format onto disk
;
; pBitmap				Pointer to a bitmap
; sOutput				The name of the file that the bitmap will be saved to. Supported extensions are: .BMP,.DIB,.RLE,.JPG,.JPEG,.JPE,.JFIF,.GIF,.TIF,.TIFF,.PNG
; Quality				If saving as jpg (.JPG,.JPEG,.JPE,.JFIF) then quality can be 1-100 with default at maximum quality
;
; return				If the function succeeds, the return value is zero, otherwise:
;						-1 = Extension supplied is not a supported file format
;						-2 = Could not get a list of encoders on system
;						-3 = Could not find matching encoder for specified file format
;						-4 = Could not get WideChar name of output file
;						-5 = Could not save file to disk
;
; notes					This function will use the extension supplied from the sOutput parameter to determine the output format

Gdip_SaveBitmapToFile(pBitmap, sOutput, Quality:=75)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	nCount := 0
	nSize := 0
	_p := 0

	SplitPath sOutput,,, Extension
	if !RegExMatch(Extension, "^(?i:BMP|DIB|RLE|JPG|JPEG|JPE|JFIF|GIF|TIF|TIFF|PNG)$")
		return -1
	Extension := "." Extension

	DllCall("gdiplus\GdipGetImageEncodersSize", "uint*", nCount, "uint*", nSize)
	VarSetCapacity(ci, nSize)
	DllCall("gdiplus\GdipGetImageEncoders", "uint", nCount, "uint", nSize, Ptr, &ci)
	if !(nCount && nSize)
		return -2

	If (A_IsUnicode){
		StrGet_Name := "StrGet"

		N := (A_AhkVersion < 2) ? nCount : "nCount"
		Loop %N%
		{
			sString := %StrGet_Name%(NumGet(ci, (idx := (48+7*A_PtrSize)*(A_Index-1))+32+3*A_PtrSize), "UTF-16")
			if !InStr(sString, "*" Extension)
				continue

			pCodec := &ci+idx
			break
		}
	} else {
		N := (A_AhkVersion < 2) ? nCount : "nCount"
		Loop %N%
		{
			Location := NumGet(ci, 76*(A_Index-1)+44)
			nSize := DllCall("WideCharToMultiByte", "uint", 0, "uint", 0, "uint", Location, "int", -1, "uint", 0, "int",  0, "uint", 0, "uint", 0)
			VarSetCapacity(sString, nSize)
			DllCall("WideCharToMultiByte", "uint", 0, "uint", 0, "uint", Location, "int", -1, "str", sString, "int", nSize, "uint", 0, "uint", 0)
			if !InStr(sString, "*" Extension)
				continue

			pCodec := &ci+76*(A_Index-1)
			break
		}
	}

	if !pCodec
		return -3

	if (Quality != 75)
	{
		Quality := (Quality < 0) ? 0 : (Quality > 100) ? 100 : Quality
		if RegExMatch(Extension, "^\.(?i:JPG|JPEG|JPE|JFIF)$")
		{
			DllCall("gdiplus\GdipGetEncoderParameterListSize", Ptr, pBitmap, Ptr, pCodec, "uint*", nSize)
			VarSetCapacity(EncoderParameters, nSize, 0)
			DllCall("gdiplus\GdipGetEncoderParameterList", Ptr, pBitmap, Ptr, pCodec, "uint", nSize, Ptr, &EncoderParameters)
			nCount := NumGet(EncoderParameters, "UInt")
			N := (A_AhkVersion < 2) ? nCount : "nCount"
			Loop %N%
			{
				elem := (24+(A_PtrSize ? A_PtrSize : 4))*(A_Index-1) + 4 + (pad := A_PtrSize = 8 ? 4 : 0)
				if (NumGet(EncoderParameters, elem+16, "UInt") = 1) && (NumGet(EncoderParameters, elem+20, "UInt") = 6)
				{
					_p := elem+&EncoderParameters-pad-4
					NumPut(Quality, NumGet(NumPut(4, NumPut(1, _p+0)+20, "UInt")), "UInt")
					break
				}
			}
		}
	}

	if (!A_IsUnicode)
	{
		nSize := DllCall("MultiByteToWideChar", "uint", 0, "uint", 0, Ptr, &sOutput, "int", -1, Ptr, 0, "int", 0)
		VarSetCapacity(wOutput, nSize*2)
		DllCall("MultiByteToWideChar", "uint", 0, "uint", 0, Ptr, &sOutput, "int", -1, Ptr, &wOutput, "int", nSize)
		VarSetCapacity(wOutput, -1)
		if !VarSetCapacity(wOutput)
			return -4
		_E := DllCall("gdiplus\GdipSaveImageToFile", Ptr, pBitmap, Ptr, &wOutput, Ptr, pCodec, "uint", _p ? _p : 0)
	}
	else
		_E := DllCall("gdiplus\GdipSaveImageToFile", Ptr, pBitmap, Ptr, &sOutput, Ptr, pCodec, "uint", _p ? _p : 0)
	return _E ? -5 : 0
}

;#####################################################################################

; Function				Gdip_GetPixel
; Description			Gets the ARGB of a pixel in a bitmap
;
; pBitmap				Pointer to a bitmap
; x						x-coordinate of the pixel
; y						y-coordinate of the pixel
;
; return				Returns the ARGB value of the pixel

Gdip_GetPixel(pBitmap, x, y)
{
	ARGB := 0

	DllCall("gdiplus\GdipBitmapGetPixel", A_PtrSize ? "UPtr" : "UInt", pBitmap, "int", x, "int", y, "uint*", ARGB)
	return ARGB
}

;#####################################################################################

; Function				Gdip_SetPixel
; Description			Sets the ARGB of a pixel in a bitmap
;
; pBitmap				Pointer to a bitmap
; x						x-coordinate of the pixel
; y						y-coordinate of the pixel
;
; return				status enumeration. 0 = success

Gdip_SetPixel(pBitmap, x, y, ARGB)
{
	return DllCall("gdiplus\GdipBitmapSetPixel", A_PtrSize ? "UPtr" : "UInt", pBitmap, "int", x, "int", y, "int", ARGB)
}

;#####################################################################################

; Function				Gdip_GetImageWidth
; Description			Gives the width of a bitmap
;
; pBitmap				Pointer to a bitmap
;
; return				Returns the width in pixels of the supplied bitmap

Gdip_GetImageWidth(pBitmap)
{
	DllCall("gdiplus\GdipGetImageWidth", A_PtrSize ? "UPtr" : "UInt", pBitmap, "uint*", Width)
	return Width
}

;#####################################################################################

; Function				Gdip_GetImageHeight
; Description			Gives the height of a bitmap
;
; pBitmap				Pointer to a bitmap
;
; return				Returns the height in pixels of the supplied bitmap

Gdip_GetImageHeight(pBitmap)
{
	DllCall("gdiplus\GdipGetImageHeight", A_PtrSize ? "UPtr" : "UInt", pBitmap, "uint*", Height)
	return Height
}

;#####################################################################################

; Function				Gdip_GetDimensions
; Description			Gives the width and height of a bitmap
;
; pBitmap				Pointer to a bitmap
; Width					ByRef variable. This variable will be set to the width of the bitmap
; Height				ByRef variable. This variable will be set to the height of the bitmap
;
; return				No return value
;						Gdip_GetDimensions(pBitmap, ThisWidth, ThisHeight) will set ThisWidth to the width and ThisHeight to the height

Gdip_GetImageDimensions(pBitmap, ByRef Width, ByRef Height)
{
	Width := 0
	Height := 0
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	DllCall("gdiplus\GdipGetImageWidth", Ptr, pBitmap, "uint*", Width)
	DllCall("gdiplus\GdipGetImageHeight", Ptr, pBitmap, "uint*", Height)
}

;#####################################################################################

Gdip_GetDimensions(pBitmap, ByRef Width, ByRef Height)
{
	Gdip_GetImageDimensions(pBitmap, Width, Height)
}

;#####################################################################################

Gdip_GetImagePixelFormat(pBitmap)
{
	DllCall("gdiplus\GdipGetImagePixelFormat", A_PtrSize ? "UPtr" : "UInt", pBitmap, A_PtrSize ? "UPtr*" : "UInt*", Format)
	return Format
}

;#####################################################################################

; Function				Gdip_GetDpiX
; Description			Gives the horizontal dots per inch of the graphics of a bitmap
;
; pBitmap				Pointer to a bitmap
; Width					ByRef variable. This variable will be set to the width of the bitmap
; Height				ByRef variable. This variable will be set to the height of the bitmap
;
; return				No return value
;						Gdip_GetDimensions(pBitmap, ThisWidth, ThisHeight) will set ThisWidth to the width and ThisHeight to the height

Gdip_GetDpiX(pGraphics)
{
	DllCall("gdiplus\GdipGetDpiX", A_PtrSize ? "UPtr" : "uint", pGraphics, "float*", dpix)
	return Round(dpix)
}

;#####################################################################################

Gdip_GetDpiY(pGraphics)
{
	DllCall("gdiplus\GdipGetDpiY", A_PtrSize ? "UPtr" : "uint", pGraphics, "float*", dpiy)
	return Round(dpiy)
}

;#####################################################################################

Gdip_GetImageHorizontalResolution(pBitmap)
{
	DllCall("gdiplus\GdipGetImageHorizontalResolution", A_PtrSize ? "UPtr" : "uint", pBitmap, "float*", dpix)
	return Round(dpix)
}

;#####################################################################################

Gdip_GetImageVerticalResolution(pBitmap)
{
	DllCall("gdiplus\GdipGetImageVerticalResolution", A_PtrSize ? "UPtr" : "uint", pBitmap, "float*", dpiy)
	return Round(dpiy)
}

;#####################################################################################

Gdip_BitmapSetResolution(pBitmap, dpix, dpiy)
{
	return DllCall("gdiplus\GdipBitmapSetResolution", A_PtrSize ? "UPtr" : "uint", pBitmap, "float", dpix, "float", dpiy)
}

;#####################################################################################

Gdip_CreateBitmapFromFile(sFile, IconNumber:=1, IconSize:="")
{
	pBitmap := ""
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	, PtrA := A_PtrSize ? "UPtr*" : "UInt*"

	SplitPath sFile,,, Extension
	if RegExMatch(Extension, "^(?i:exe|dll)$")
	{
		Sizes := IconSize ? IconSize : 256 "|" 128 "|" 64 "|" 48 "|" 32 "|" 16
		BufSize := 16 + (2*(A_PtrSize ? A_PtrSize : 4))

		VarSetCapacity(buf, BufSize, 0)
		For eachSize, Size in StrSplit( Sizes, "|" )
		{
			DllCall("PrivateExtractIcons", "str", sFile, "int", IconNumber-1, "int", Size, "int", Size, PtrA, hIcon, PtrA, 0, "uint", 1, "uint", 0)

			if !hIcon
				continue

			if !DllCall("GetIconInfo", Ptr, hIcon, Ptr, &buf)
			{
				DestroyIcon(hIcon)
				continue
			}

			hbmMask  := NumGet(buf, 12 + ((A_PtrSize ? A_PtrSize : 4) - 4))
			hbmColor := NumGet(buf, 12 + ((A_PtrSize ? A_PtrSize : 4) - 4) + (A_PtrSize ? A_PtrSize : 4))
			if !(hbmColor && DllCall("GetObject", Ptr, hbmColor, "int", BufSize, Ptr, &buf))
			{
				DestroyIcon(hIcon)
				continue
			}
			break
		}
		if !hIcon
			return -1

		Width := NumGet(buf, 4, "int"), Height := NumGet(buf, 8, "int")
		hbm := CreateDIBSection(Width, -Height), hdc := CreateCompatibleDC(), obm := SelectObject(hdc, hbm)
		if !DllCall("DrawIconEx", Ptr, hdc, "int", 0, "int", 0, Ptr, hIcon, "uint", Width, "uint", Height, "uint", 0, Ptr, 0, "uint", 3)
		{
			DestroyIcon(hIcon)
			return -2
		}

		VarSetCapacity(dib, 104)
		DllCall("GetObject", Ptr, hbm, "int", A_PtrSize = 8 ? 104 : 84, Ptr, &dib) ; sizeof(DIBSECTION) = 76+2*(A_PtrSize=8?4:0)+2*A_PtrSize
		Stride := NumGet(dib, 12, "Int"), Bits := NumGet(dib, 20 + (A_PtrSize = 8 ? 4 : 0)) ; padding
		DllCall("gdiplus\GdipCreateBitmapFromScan0", "int", Width, "int", Height, "int", Stride, "int", 0x26200A, Ptr, Bits, PtrA, pBitmapOld)
		pBitmap := Gdip_CreateBitmap(Width, Height)
		_G := Gdip_GraphicsFromImage(pBitmap)
		, Gdip_DrawImage(_G, pBitmapOld, 0, 0, Width, Height, 0, 0, Width, Height)
		SelectObject(hdc, obm), DeleteObject(hbm), DeleteDC(hdc)
		Gdip_DeleteGraphics(_G), Gdip_DisposeImage(pBitmapOld)
		DestroyIcon(hIcon)
	}
	else
	{
		if (!A_IsUnicode)
		{
			VarSetCapacity(wFile, 1024)
			DllCall("kernel32\MultiByteToWideChar", "uint", 0, "uint", 0, Ptr, &sFile, "int", -1, Ptr, &wFile, "int", 512)
			DllCall("gdiplus\GdipCreateBitmapFromFile", Ptr, &wFile, PtrA, pBitmap)
		}
		else
			DllCall("gdiplus\GdipCreateBitmapFromFile", Ptr, &sFile, PtrA, pBitmap)
	}

	return pBitmap
}

;#####################################################################################

Gdip_CreateBitmapFromHBITMAP(hBitmap, Palette:=0)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	pBitmap := ""

	DllCall("gdiplus\GdipCreateBitmapFromHBITMAP", Ptr, hBitmap, Ptr, Palette, A_PtrSize ? "UPtr*" : "uint*", pBitmap)
	return pBitmap
}

;#####################################################################################

Gdip_CreateHBITMAPFromBitmap(pBitmap, Background:=0xffffffff)
{
	DllCall("gdiplus\GdipCreateHBITMAPFromBitmap", A_PtrSize ? "UPtr" : "UInt", pBitmap, A_PtrSize ? "UPtr*" : "uint*", hbm, "int", Background)
	return hbm
}

;#####################################################################################

Gdip_CreateBitmapFromHICON(hIcon)
{
	pBitmap := ""

	DllCall("gdiplus\GdipCreateBitmapFromHICON", A_PtrSize ? "UPtr" : "UInt", hIcon, A_PtrSize ? "UPtr*" : "uint*", pBitmap)
	return pBitmap
}

;#####################################################################################

Gdip_CreateHICONFromBitmap(pBitmap)
{
	pBitmap := ""
	hIcon := 0

	DllCall("gdiplus\GdipCreateHICONFromBitmap", A_PtrSize ? "UPtr" : "UInt", pBitmap, A_PtrSize ? "UPtr*" : "uint*", hIcon)
	return hIcon
}

;#####################################################################################

Gdip_CreateBitmap(Width, Height, Format:=0x26200A)
{
	pBitmap := ""

	DllCall("gdiplus\GdipCreateBitmapFromScan0", "int", Width, "int", Height, "int", 0, "int", Format, A_PtrSize ? "UPtr" : "UInt", 0, A_PtrSize ? "UPtr*" : "uint*", pBitmap)
	Return pBitmap
}

;#####################################################################################

Gdip_CreateBitmapFromClipboard()
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"

	if !DllCall("OpenClipboard", Ptr, 0)
		return -1
	if !DllCall("IsClipboardFormatAvailable", "uint", 8)
		return -2
	if !hBitmap := DllCall("GetClipboardData", "uint", 2, Ptr)
		return -3
	if !pBitmap := Gdip_CreateBitmapFromHBITMAP(hBitmap)
		return -4
	if !DllCall("CloseClipboard")
		return -5
	DeleteObject(hBitmap)
	return pBitmap
}

;#####################################################################################

Gdip_SetBitmapToClipboard(pBitmap)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	off1 := A_PtrSize = 8 ? 52 : 44, off2 := A_PtrSize = 8 ? 32 : 24
	hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap)
	DllCall("GetObject", Ptr, hBitmap, "int", VarSetCapacity(oi, A_PtrSize = 8 ? 104 : 84, 0), Ptr, &oi)
	hdib := DllCall("GlobalAlloc", "uint", 2, Ptr, 40+NumGet(oi, off1, "UInt"), Ptr)
	pdib := DllCall("GlobalLock", Ptr, hdib, Ptr)
	DllCall("RtlMoveMemory", Ptr, pdib, Ptr, &oi+off2, Ptr, 40)
	DllCall("RtlMoveMemory", Ptr, pdib+40, Ptr, NumGet(oi, off2 - (A_PtrSize ? A_PtrSize : 4), Ptr), Ptr, NumGet(oi, off1, "UInt"))
	DllCall("GlobalUnlock", Ptr, hdib)
	DllCall("DeleteObject", Ptr, hBitmap)
	DllCall("OpenClipboard", Ptr, 0)
	DllCall("EmptyClipboard")
	DllCall("SetClipboardData", "uint", 8, Ptr, hdib)
	DllCall("CloseClipboard")
}

;#####################################################################################

Gdip_CloneBitmapArea(pBitmap, x, y, w, h, Format:=0x26200A)
{
	DllCall("gdiplus\GdipCloneBitmapArea"
					, "float", x
					, "float", y
					, "float", w
					, "float", h
					, "int", Format
					, A_PtrSize ? "UPtr" : "UInt", pBitmap
					, A_PtrSize ? "UPtr*" : "UInt*", pBitmapDest)
	return pBitmapDest
}

;#####################################################################################
; Create resources
;#####################################################################################

Gdip_CreatePen(ARGB, w)
{
	DllCall("gdiplus\GdipCreatePen1", "UInt", ARGB, "float", w, "int", 2, A_PtrSize ? "UPtr*" : "UInt*", pPen)
	return pPen
}

;#####################################################################################

Gdip_CreatePenFromBrush(pBrush, w)
{
	pPen := ""

	DllCall("gdiplus\GdipCreatePen2", A_PtrSize ? "UPtr" : "UInt", pBrush, "float", w, "int", 2, A_PtrSize ? "UPtr*" : "UInt*", pPen)
	return pPen
}

;#####################################################################################

Gdip_BrushCreateSolid(ARGB:=0xff000000)
{
	pBrush := ""

	DllCall("gdiplus\GdipCreateSolidFill", "UInt", ARGB, A_PtrSize ? "UPtr*" : "UInt*", pBrush)
	return pBrush
}

;#####################################################################################

; HatchStyleHorizontal = 0
; HatchStyleVertical = 1
; HatchStyleForwardDiagonal = 2
; HatchStyleBackwardDiagonal = 3
; HatchStyleCross = 4
; HatchStyleDiagonalCross = 5
; HatchStyle05Percent = 6
; HatchStyle10Percent = 7
; HatchStyle20Percent = 8
; HatchStyle25Percent = 9
; HatchStyle30Percent = 10
; HatchStyle40Percent = 11
; HatchStyle50Percent = 12
; HatchStyle60Percent = 13
; HatchStyle70Percent = 14
; HatchStyle75Percent = 15
; HatchStyle80Percent = 16
; HatchStyle90Percent = 17
; HatchStyleLightDownwardDiagonal = 18
; HatchStyleLightUpwardDiagonal = 19
; HatchStyleDarkDownwardDiagonal = 20
; HatchStyleDarkUpwardDiagonal = 21
; HatchStyleWideDownwardDiagonal = 22
; HatchStyleWideUpwardDiagonal = 23
; HatchStyleLightVertical = 24
; HatchStyleLightHorizontal = 25
; HatchStyleNarrowVertical = 26
; HatchStyleNarrowHorizontal = 27
; HatchStyleDarkVertical = 28
; HatchStyleDarkHorizontal = 29
; HatchStyleDashedDownwardDiagonal = 30
; HatchStyleDashedUpwardDiagonal = 31
; HatchStyleDashedHorizontal = 32
; HatchStyleDashedVertical = 33
; HatchStyleSmallConfetti = 34
; HatchStyleLargeConfetti = 35
; HatchStyleZigZag = 36
; HatchStyleWave = 37
; HatchStyleDiagonalBrick = 38
; HatchStyleHorizontalBrick = 39
; HatchStyleWeave = 40
; HatchStylePlaid = 41
; HatchStyleDivot = 42
; HatchStyleDottedGrid = 43
; HatchStyleDottedDiamond = 44
; HatchStyleShingle = 45
; HatchStyleTrellis = 46
; HatchStyleSphere = 47
; HatchStyleSmallGrid = 48
; HatchStyleSmallCheckerBoard = 49
; HatchStyleLargeCheckerBoard = 50
; HatchStyleOutlinedDiamond = 51
; HatchStyleSolidDiamond = 52
; HatchStyleTotal = 53
Gdip_BrushCreateHatch(ARGBfront, ARGBback, HatchStyle:=0)
{
	pBrush := ""

	DllCall("gdiplus\GdipCreateHatchBrush", "int", HatchStyle, "UInt", ARGBfront, "UInt", ARGBback, A_PtrSize ? "UPtr*" : "UInt*", pBrush)
	return pBrush
}

;#####################################################################################

Gdip_CreateTextureBrush(pBitmap, WrapMode:=1, x:=0, y:=0, w:="", h:="")
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	, PtrA := A_PtrSize ? "UPtr*" : "UInt*"

	if !(w && h)
		DllCall("gdiplus\GdipCreateTexture", Ptr, pBitmap, "int", WrapMode, PtrA, pBrush)
	else
		DllCall("gdiplus\GdipCreateTexture2", Ptr, pBitmap, "int", WrapMode, "float", x, "float", y, "float", w, "float", h, PtrA, pBrush)
	return pBrush
}

;#####################################################################################

; WrapModeTile = 0
; WrapModeTileFlipX = 1
; WrapModeTileFlipY = 2
; WrapModeTileFlipXY = 3
; WrapModeClamp = 4
Gdip_CreateLineBrush(x1, y1, x2, y2, ARGB1, ARGB2, WrapMode:=1)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"

	CreatePointF(PointF1, x1, y1), CreatePointF(PointF2, x2, y2)
	DllCall("gdiplus\GdipCreateLineBrush", Ptr, &PointF1, Ptr, &PointF2, "Uint", ARGB1, "Uint", ARGB2, "int", WrapMode, A_PtrSize ? "UPtr*" : "UInt*", LGpBrush)
	return LGpBrush
}

;#####################################################################################

; LinearGradientModeHorizontal = 0
; LinearGradientModeVertical = 1
; LinearGradientModeForwardDiagonal = 2
; LinearGradientModeBackwardDiagonal = 3
Gdip_CreateLineBrushFromRect(x, y, w, h, ARGB1, ARGB2, LinearGradientMode:=1, WrapMode:=1)
{
	CreateRectF(RectF, x, y, w, h)
	DllCall("gdiplus\GdipCreateLineBrushFromRect", A_PtrSize ? "UPtr" : "UInt", &RectF, "int", ARGB1, "int", ARGB2, "int", LinearGradientMode, "int", WrapMode, A_PtrSize ? "UPtr*" : "UInt*", LGpBrush)
	return LGpBrush
}

;#####################################################################################

Gdip_CloneBrush(pBrush)
{
	DllCall("gdiplus\GdipCloneBrush", A_PtrSize ? "UPtr" : "UInt", pBrush, A_PtrSize ? "UPtr*" : "UInt*", pBrushClone)
	return pBrushClone
}

;#####################################################################################
; Delete resources
;#####################################################################################

Gdip_DeletePen(pPen)
{
	return DllCall("gdiplus\GdipDeletePen", A_PtrSize ? "UPtr" : "UInt", pPen)
}

;#####################################################################################

Gdip_DeleteBrush(pBrush)
{
	return DllCall("gdiplus\GdipDeleteBrush", A_PtrSize ? "UPtr" : "UInt", pBrush)
}

;#####################################################################################

Gdip_DisposeImage(pBitmap)
{
	return DllCall("gdiplus\GdipDisposeImage", A_PtrSize ? "UPtr" : "UInt", pBitmap)
}

;#####################################################################################

Gdip_DeleteGraphics(pGraphics)
{
	return DllCall("gdiplus\GdipDeleteGraphics", A_PtrSize ? "UPtr" : "UInt", pGraphics)
}

;#####################################################################################

Gdip_DisposeImageAttributes(ImageAttr)
{
	return DllCall("gdiplus\GdipDisposeImageAttributes", A_PtrSize ? "UPtr" : "UInt", ImageAttr)
}

;#####################################################################################

Gdip_DeleteFont(hFont)
{
	return DllCall("gdiplus\GdipDeleteFont", A_PtrSize ? "UPtr" : "UInt", hFont)
}

;#####################################################################################

Gdip_DeleteStringFormat(hFormat)
{
	return DllCall("gdiplus\GdipDeleteStringFormat", A_PtrSize ? "UPtr" : "UInt", hFormat)
}

;#####################################################################################

Gdip_DeleteFontFamily(hFamily)
{
	return DllCall("gdiplus\GdipDeleteFontFamily", A_PtrSize ? "UPtr" : "UInt", hFamily)
}

;#####################################################################################

Gdip_DeleteMatrix(Matrix)
{
	return DllCall("gdiplus\GdipDeleteMatrix", A_PtrSize ? "UPtr" : "UInt", Matrix)
}

;#####################################################################################
; Text functions
;#####################################################################################

Gdip_TextToGraphics(pGraphics, Text, Options, Font:="Arial", Width:="", Height:="", Measure:=0)
{
	IWidth := Width, IHeight:= Height

	pattern_opts := (A_AhkVersion < "2") ? "iO)" : "i)"
	RegExMatch(Options, pattern_opts "X([\-\d\.]+)(p*)", xpos)
	RegExMatch(Options, pattern_opts "Y([\-\d\.]+)(p*)", ypos)
	RegExMatch(Options, pattern_opts "W([\-\d\.]+)(p*)", Width)
	RegExMatch(Options, pattern_opts "H([\-\d\.]+)(p*)", Height)
	RegExMatch(Options, pattern_opts "C(?!(entre|enter))([a-f\d]+)", Colour)
	RegExMatch(Options, pattern_opts "Top|Up|Bottom|Down|vCentre|vCenter", vPos)
	RegExMatch(Options, pattern_opts "NoWrap", NoWrap)
	RegExMatch(Options, pattern_opts "R(\d)", Rendering)
	RegExMatch(Options, pattern_opts "S(\d+)(p*)", Size)

	if Colour && !Gdip_DeleteBrush(Gdip_CloneBrush(Colour[2]))
		PassBrush := 1, pBrush := Colour[2]

	if !(IWidth && IHeight) && ((xpos && xpos[2]) || (ypos && ypos[2]) || (Width && Width[2]) || (Height && Height[2]) || (Size && Size[2]))
		return -1

	Style := 0, Styles := "Regular|Bold|Italic|BoldItalic|Underline|Strikeout"
	For eachStyle, valStyle in StrSplit( Styles, "|" )
	{
		if RegExMatch(Options, "\b" valStyle)
			Style |= (valStyle != "StrikeOut") ? (A_Index-1) : 8
	}

	Align := 0, Alignments := "Near|Left|Centre|Center|Far|Right"
	For eachAlignment, valAlignment in StrSplit( Alignments, "|" )
	{
		if RegExMatch(Options, "\b" valAlignment)
			Align |= A_Index//2.1	; 0|0|1|1|2|2
	}

	xpos := (xpos && (xpos[1] != "")) ? xpos[2] ? IWidth*(xpos[1]/100) : xpos[1] : 0
	ypos := (ypos && (ypos[1] != "")) ? ypos[2] ? IHeight*(ypos[1]/100) : ypos[1] : 0
	Width := (Width && Width[1]) ? Width[2] ? IWidth*(Width[1]/100) : Width[1] : IWidth
	Height := (Height && Height[1]) ? Height[2] ? IHeight*(Height[1]/100) : Height[1] : IHeight
	if !PassBrush
		Colour := "0x" (Colour && Colour[2] ? Colour[2] : "ff000000")
	Rendering := (Rendering && (Rendering[1] >= 0) && (Rendering[1] <= 5)) ? Rendering[1] : 4
	Size := (Size && (Size[1] > 0)) ? Size[2] ? IHeight*(Size[1]/100) : Size[1] : 12

	hFamily := Gdip_FontFamilyCreate(Font)
	hFont := Gdip_FontCreate(hFamily, Size, Style)
	FormatStyle := NoWrap ? 0x4000 | 0x1000 : 0x4000
	hFormat := Gdip_StringFormatCreate(FormatStyle)
	pBrush := PassBrush ? pBrush : Gdip_BrushCreateSolid(Colour)
	if !(hFamily && hFont && hFormat && pBrush && pGraphics)
		return !pGraphics ? -2 : !hFamily ? -3 : !hFont ? -4 : !hFormat ? -5 : !pBrush ? -6 : 0

	CreateRectF(RC, xpos, ypos, Width, Height)
	Gdip_SetStringFormatAlign(hFormat, Align)
	Gdip_SetTextRenderingHint(pGraphics, Rendering)
	ReturnRC := Gdip_MeasureString(pGraphics, Text, hFont, hFormat, RC)

	if vPos
	{
		ReturnRC := StrSplit(ReturnRC, "|")

		if (vPos[0] = "vCentre") || (vPos[0] = "vCenter")
			ypos += (Height-ReturnRC[4])//2
		else if (vPos[0] = "Top") || (vPos[0] = "Up")
			ypos := 0
		else if (vPos[0] = "Bottom") || (vPos[0] = "Down")
			ypos := Height-ReturnRC[4]

		CreateRectF(RC, xpos, ypos, Width, ReturnRC[4])
		ReturnRC := Gdip_MeasureString(pGraphics, Text, hFont, hFormat, RC)
	}

	if !Measure
		_E := Gdip_DrawString(pGraphics, Text, hFont, hFormat, pBrush, RC)

	if !PassBrush
		Gdip_DeleteBrush(pBrush)
	Gdip_DeleteStringFormat(hFormat)
	Gdip_DeleteFont(hFont)
	Gdip_DeleteFontFamily(hFamily)
	return _E ? _E : ReturnRC
}

;#####################################################################################

Gdip_DrawString(pGraphics, sString, hFont, hFormat, pBrush, ByRef RectF)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"

	if (!A_IsUnicode)
	{
		nSize := DllCall("MultiByteToWideChar", "uint", 0, "uint", 0, Ptr, &sString, "int", -1, Ptr, 0, "int", 0)
		VarSetCapacity(wString, nSize*2)
		DllCall("MultiByteToWideChar", "uint", 0, "uint", 0, Ptr, &sString, "int", -1, Ptr, &wString, "int", nSize)
	}

	return DllCall("gdiplus\GdipDrawString"
					, Ptr, pGraphics
					, Ptr, A_IsUnicode ? &sString : &wString
					, "int", -1
					, Ptr, hFont
					, Ptr, &RectF
					, Ptr, hFormat
					, Ptr, pBrush)
}

;#####################################################################################

Gdip_MeasureString(pGraphics, sString, hFont, hFormat, ByRef RectF)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"

	VarSetCapacity(RC, 16)
	if !A_IsUnicode
	{
		nSize := DllCall("MultiByteToWideChar", "uint", 0, "uint", 0, Ptr, &sString, "int", -1, "uint", 0, "int", 0)
		VarSetCapacity(wString, nSize*2)
		DllCall("MultiByteToWideChar", "uint", 0, "uint", 0, Ptr, &sString, "int", -1, Ptr, &wString, "int", nSize)
	}

	DllCall("gdiplus\GdipMeasureString"
					, Ptr, pGraphics
					, Ptr, A_IsUnicode ? &sString : &wString
					, "int", -1
					, Ptr, hFont
					, Ptr, &RectF
					, Ptr, hFormat
					, Ptr, &RC
					, "uint*", Chars
					, "uint*", Lines)

	return &RC ? NumGet(RC, 0, "float") "|" NumGet(RC, 4, "float") "|" NumGet(RC, 8, "float") "|" NumGet(RC, 12, "float") "|" Chars "|" Lines : 0
}

; Near = 0
; Center = 1
; Far = 2
Gdip_SetStringFormatAlign(hFormat, Align)
{
	return DllCall("gdiplus\GdipSetStringFormatAlign", A_PtrSize ? "UPtr" : "UInt", hFormat, "int", Align)
}

; StringFormatFlagsDirectionRightToLeft    = 0x00000001
; StringFormatFlagsDirectionVertical       = 0x00000002
; StringFormatFlagsNoFitBlackBox           = 0x00000004
; StringFormatFlagsDisplayFormatControl    = 0x00000020
; StringFormatFlagsNoFontFallback          = 0x00000400
; StringFormatFlagsMeasureTrailingSpaces   = 0x00000800
; StringFormatFlagsNoWrap                  = 0x00001000
; StringFormatFlagsLineLimit               = 0x00002000
; StringFormatFlagsNoClip                  = 0x00004000
Gdip_StringFormatCreate(Format:=0, Lang:=0)
{
	DllCall("gdiplus\GdipCreateStringFormat", "int", Format, "int", Lang, A_PtrSize ? "UPtr*" : "UInt*", hFormat)
	return hFormat
}

; Regular = 0
; Bold = 1
; Italic = 2
; BoldItalic = 3
; Underline = 4
; Strikeout = 8
Gdip_FontCreate(hFamily, Size, Style:=0)
{
	DllCall("gdiplus\GdipCreateFont", A_PtrSize ? "UPtr" : "UInt", hFamily, "float", Size, "int", Style, "int", 0, A_PtrSize ? "UPtr*" : "UInt*", hFont)
	return hFont
}

Gdip_FontFamilyCreate(Font)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"

	if (!A_IsUnicode)
	{
		nSize := DllCall("MultiByteToWideChar", "uint", 0, "uint", 0, Ptr, &Font, "int", -1, "uint", 0, "int", 0)
		VarSetCapacity(wFont, nSize*2)
		DllCall("MultiByteToWideChar", "uint", 0, "uint", 0, Ptr, &Font, "int", -1, Ptr, &wFont, "int", nSize)
	}

	DllCall("gdiplus\GdipCreateFontFamilyFromName"
					, Ptr, A_IsUnicode ? &Font : &wFont
					, "uint", 0
					, A_PtrSize ? "UPtr*" : "UInt*", hFamily)

	return hFamily
}

;#####################################################################################
; Matrix functions
;#####################################################################################

Gdip_CreateAffineMatrix(m11, m12, m21, m22, x, y)
{
	DllCall("gdiplus\GdipCreateMatrix2", "float", m11, "float", m12, "float", m21, "float", m22, "float", x, "float", y, A_PtrSize ? "UPtr*" : "UInt*", Matrix)
	return Matrix
}

Gdip_CreateMatrix()
{
	DllCall("gdiplus\GdipCreateMatrix", A_PtrSize ? "UPtr*" : "UInt*", Matrix)
	return Matrix
}

;#####################################################################################
; GraphicsPath functions
;#####################################################################################

; Alternate = 0
; Winding = 1
Gdip_CreatePath(BrushMode:=0)
{
	DllCall("gdiplus\GdipCreatePath", "int", BrushMode, A_PtrSize ? "UPtr*" : "UInt*", pPath)
	return pPath
}

Gdip_AddPathEllipse(pPath, x, y, w, h)
{
	return DllCall("gdiplus\GdipAddPathEllipse", A_PtrSize ? "UPtr" : "UInt", pPath, "float", x, "float", y, "float", w, "float", h)
}

Gdip_AddPathPolygon(pPath, Points)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"

	Points := StrSplit(Points, "|")
	VarSetCapacity(PointF, 8*Points.Length())
	for eachPoint, Point in Points
	{
		Coord := StrSplit(Point, ",")
		NumPut(Coord[1], PointF, 8*(A_Index-1), "float"), NumPut(Coord[2], PointF, (8*(A_Index-1))+4, "float")
	}

	return DllCall("gdiplus\GdipAddPathPolygon", Ptr, pPath, Ptr, &PointF, "int", Points.Length())
}

Gdip_DeletePath(pPath)
{
	return DllCall("gdiplus\GdipDeletePath", A_PtrSize ? "UPtr" : "UInt", pPath)
}

;#####################################################################################
; Quality functions
;#####################################################################################

; SystemDefault = 0
; SingleBitPerPixelGridFit = 1
; SingleBitPerPixel = 2
; AntiAliasGridFit = 3
; AntiAlias = 4
Gdip_SetTextRenderingHint(pGraphics, RenderingHint)
{
	return DllCall("gdiplus\GdipSetTextRenderingHint", A_PtrSize ? "UPtr" : "UInt", pGraphics, "int", RenderingHint)
}

; Default = 0
; LowQuality = 1
; HighQuality = 2
; Bilinear = 3
; Bicubic = 4
; NearestNeighbor = 5
; HighQualityBilinear = 6
; HighQualityBicubic = 7
Gdip_SetInterpolationMode(pGraphics, InterpolationMode)
{
	return DllCall("gdiplus\GdipSetInterpolationMode", A_PtrSize ? "UPtr" : "UInt", pGraphics, "int", InterpolationMode)
}

; Default = 0
; HighSpeed = 1
; HighQuality = 2
; None = 3
; AntiAlias = 4
Gdip_SetSmoothingMode(pGraphics, SmoothingMode)
{
	return DllCall("gdiplus\GdipSetSmoothingMode", A_PtrSize ? "UPtr" : "UInt", pGraphics, "int", SmoothingMode)
}

; CompositingModeSourceOver = 0 (blended)
; CompositingModeSourceCopy = 1 (overwrite)
Gdip_SetCompositingMode(pGraphics, CompositingMode:=0)
{
	return DllCall("gdiplus\GdipSetCompositingMode", A_PtrSize ? "UPtr" : "UInt", pGraphics, "int", CompositingMode)
}

;#####################################################################################
; Extra functions
;#####################################################################################

Gdip_Startup()
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	pToken := 0

	if !DllCall("GetModuleHandle", "str", "gdiplus", Ptr)
		DllCall("LoadLibrary", "str", "gdiplus")
	VarSetCapacity(si, A_PtrSize = 8 ? 24 : 16, 0), si := Chr(1)
	DllCall("gdiplus\GdiplusStartup", A_PtrSize ? "UPtr*" : "uint*", pToken, Ptr, &si, Ptr, 0)
	return pToken
}

Gdip_Shutdown(pToken)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"

	DllCall("gdiplus\GdiplusShutdown", Ptr, pToken)
	if hModule := DllCall("GetModuleHandle", "str", "gdiplus", Ptr)
		DllCall("FreeLibrary", Ptr, hModule)
	return 0
}

; Prepend = 0; The new operation is applied before the old operation.
; Append = 1; The new operation is applied after the old operation.
Gdip_RotateWorldTransform(pGraphics, Angle, MatrixOrder:=0)
{
	return DllCall("gdiplus\GdipRotateWorldTransform", A_PtrSize ? "UPtr" : "UInt", pGraphics, "float", Angle, "int", MatrixOrder)
}

Gdip_ScaleWorldTransform(pGraphics, x, y, MatrixOrder:=0)
{
	return DllCall("gdiplus\GdipScaleWorldTransform", A_PtrSize ? "UPtr" : "UInt", pGraphics, "float", x, "float", y, "int", MatrixOrder)
}

Gdip_TranslateWorldTransform(pGraphics, x, y, MatrixOrder:=0)
{
	return DllCall("gdiplus\GdipTranslateWorldTransform", A_PtrSize ? "UPtr" : "UInt", pGraphics, "float", x, "float", y, "int", MatrixOrder)
}

Gdip_ResetWorldTransform(pGraphics)
{
	return DllCall("gdiplus\GdipResetWorldTransform", A_PtrSize ? "UPtr" : "UInt", pGraphics)
}

Gdip_GetRotatedTranslation(Width, Height, Angle, ByRef xTranslation, ByRef yTranslation)
{
	pi := 3.14159, TAngle := Angle*(pi/180)

	Bound := (Angle >= 0) ? Mod(Angle, 360) : 360-Mod(-Angle, -360)
	if ((Bound >= 0) && (Bound <= 90))
		xTranslation := Height*Sin(TAngle), yTranslation := 0
	else if ((Bound > 90) && (Bound <= 180))
		xTranslation := (Height*Sin(TAngle))-(Width*Cos(TAngle)), yTranslation := -Height*Cos(TAngle)
	else if ((Bound > 180) && (Bound <= 270))
		xTranslation := -(Width*Cos(TAngle)), yTranslation := -(Height*Cos(TAngle))-(Width*Sin(TAngle))
	else if ((Bound > 270) && (Bound <= 360))
		xTranslation := 0, yTranslation := -Width*Sin(TAngle)
}

Gdip_GetRotatedDimensions(Width, Height, Angle, ByRef RWidth, ByRef RHeight)
{
	pi := 3.14159, TAngle := Angle*(pi/180)
	if !(Width && Height)
		return -1
	RWidth := Ceil(Abs(Width*Cos(TAngle))+Abs(Height*Sin(TAngle)))
	RHeight := Ceil(Abs(Width*Sin(TAngle))+Abs(Height*Cos(Tangle)))
}

; RotateNoneFlipNone   = 0
; Rotate90FlipNone     = 1
; Rotate180FlipNone    = 2
; Rotate270FlipNone    = 3
; RotateNoneFlipX      = 4
; Rotate90FlipX        = 5
; Rotate180FlipX       = 6
; Rotate270FlipX       = 7
; RotateNoneFlipY      = Rotate180FlipX
; Rotate90FlipY        = Rotate270FlipX
; Rotate180FlipY       = RotateNoneFlipX
; Rotate270FlipY       = Rotate90FlipX
; RotateNoneFlipXY     = Rotate180FlipNone
; Rotate90FlipXY       = Rotate270FlipNone
; Rotate180FlipXY      = RotateNoneFlipNone
; Rotate270FlipXY      = Rotate90FlipNone

Gdip_ImageRotateFlip(pBitmap, RotateFlipType:=1)
{
	return DllCall("gdiplus\GdipImageRotateFlip", A_PtrSize ? "UPtr" : "UInt", pBitmap, "int", RotateFlipType)
}

; Replace = 0
; Intersect = 1
; Union = 2
; Xor = 3
; Exclude = 4
; Complement = 5
Gdip_SetClipRect(pGraphics, x, y, w, h, CombineMode:=0)
{
	return DllCall("gdiplus\GdipSetClipRect",  A_PtrSize ? "UPtr" : "UInt", pGraphics, "float", x, "float", y, "float", w, "float", h, "int", CombineMode)
}

Gdip_SetClipPath(pGraphics, pPath, CombineMode:=0)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	return DllCall("gdiplus\GdipSetClipPath", Ptr, pGraphics, Ptr, pPath, "int", CombineMode)
}

Gdip_ResetClip(pGraphics)
{
	return DllCall("gdiplus\GdipResetClip", A_PtrSize ? "UPtr" : "UInt", pGraphics)
}

Gdip_GetClipRegion(pGraphics)
{
	Region := Gdip_CreateRegion()
	DllCall("gdiplus\GdipGetClip", A_PtrSize ? "UPtr" : "UInt", pGraphics, "UInt", Region)
	return Region
}

Gdip_SetClipRegion(pGraphics, Region, CombineMode:=0)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"

	return DllCall("gdiplus\GdipSetClipRegion", Ptr, pGraphics, Ptr, Region, "int", CombineMode)
}

Gdip_CreateRegion()
{
	DllCall("gdiplus\GdipCreateRegion", "UInt*", Region)
	return Region
}

Gdip_DeleteRegion(Region)
{
	return DllCall("gdiplus\GdipDeleteRegion", A_PtrSize ? "UPtr" : "UInt", Region)
}

;#####################################################################################
; BitmapLockBits
;#####################################################################################

Gdip_LockBits(pBitmap, x, y, w, h, ByRef Stride, ByRef Scan0, ByRef BitmapData, LockMode := 3, PixelFormat := 0x26200a)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"

	CreateRect(_Rect, x, y, w, h)
	VarSetCapacity(BitmapData, 16+2*(A_PtrSize ? A_PtrSize : 4), 0)
	_E := DllCall("Gdiplus\GdipBitmapLockBits", Ptr, pBitmap, Ptr, &_Rect, "uint", LockMode, "int", PixelFormat, Ptr, &BitmapData)
	Stride := NumGet(BitmapData, 8, "Int")
	Scan0 := NumGet(BitmapData, 16, Ptr)
	return _E
}

;#####################################################################################

Gdip_UnlockBits(pBitmap, ByRef BitmapData)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"

	return DllCall("Gdiplus\GdipBitmapUnlockBits", Ptr, pBitmap, Ptr, &BitmapData)
}

;#####################################################################################

Gdip_SetLockBitPixel(ARGB, Scan0, x, y, Stride)
{
	Numput(ARGB, Scan0+0, (x*4)+(y*Stride), "UInt")
}

;#####################################################################################

Gdip_GetLockBitPixel(Scan0, x, y, Stride)
{
	return NumGet(Scan0+0, (x*4)+(y*Stride), "UInt")
}

;#####################################################################################

Gdip_PixelateBitmap(pBitmap, ByRef pBitmapOut, BlockSize)
{
	static PixelateBitmap

	Ptr := A_PtrSize ? "UPtr" : "UInt"

	if (!PixelateBitmap)
	{
		if A_PtrSize != 8 ; x86 machine code
		MCode_PixelateBitmap := "
		(LTrim Join
		558BEC83EC3C8B4514538B5D1C99F7FB56578BC88955EC894DD885C90F8E830200008B451099F7FB8365DC008365E000894DC88955F08945E833FF897DD4
		397DE80F8E160100008BCB0FAFCB894DCC33C08945F88945FC89451C8945143BD87E608B45088D50028BC82BCA8BF02BF2418945F48B45E02955F4894DC4
		8D0CB80FAFCB03CA895DD08BD1895DE40FB64416030145140FB60201451C8B45C40FB604100145FC8B45F40FB604020145F883C204FF4DE475D6034D18FF
		4DD075C98B4DCC8B451499F7F98945148B451C99F7F989451C8B45FC99F7F98945FC8B45F899F7F98945F885DB7E648B450C8D50028BC82BCA83C103894D
		C48BC82BCA41894DF48B4DD48945E48B45E02955E48D0C880FAFCB03CA895DD08BD18BF38A45148B7DC48804178A451C8B7DF488028A45FC8804178A45F8
		8B7DE488043A83C2044E75DA034D18FF4DD075CE8B4DCC8B7DD447897DD43B7DE80F8CF2FEFFFF837DF0000F842C01000033C08945F88945FC89451C8945
		148945E43BD87E65837DF0007E578B4DDC034DE48B75E80FAF4D180FAFF38B45088D500203CA8D0CB18BF08BF88945F48B45F02BF22BFA2955F48945CC0F
		B6440E030145140FB60101451C0FB6440F010145FC8B45F40FB604010145F883C104FF4DCC75D8FF45E4395DE47C9B8B4DF00FAFCB85C9740B8B451499F7
		F9894514EB048365140033F63BCE740B8B451C99F7F989451CEB0389751C3BCE740B8B45FC99F7F98945FCEB038975FC3BCE740B8B45F899F7F98945F8EB
		038975F88975E43BDE7E5A837DF0007E4C8B4DDC034DE48B75E80FAF4D180FAFF38B450C8D500203CA8D0CB18BF08BF82BF22BFA2BC28B55F08955CC8A55
		1488540E038A551C88118A55FC88540F018A55F888140183C104FF4DCC75DFFF45E4395DE47CA68B45180145E0015DDCFF4DC80F8594FDFFFF8B451099F7
		FB8955F08945E885C00F8E450100008B45EC0FAFC38365DC008945D48B45E88945CC33C08945F88945FC89451C8945148945103945EC7E6085DB7E518B4D
		D88B45080FAFCB034D108D50020FAF4D18034DDC8BF08BF88945F403CA2BF22BFA2955F4895DC80FB6440E030145140FB60101451C0FB6440F010145FC8B
		45F40FB604080145F883C104FF4DC875D8FF45108B45103B45EC7CA08B4DD485C9740B8B451499F7F9894514EB048365140033F63BCE740B8B451C99F7F9
		89451CEB0389751C3BCE740B8B45FC99F7F98945FCEB038975FC3BCE740B8B45F899F7F98945F8EB038975F88975103975EC7E5585DB7E468B4DD88B450C
		0FAFCB034D108D50020FAF4D18034DDC8BF08BF803CA2BF22BFA2BC2895DC88A551488540E038A551C88118A55FC88540F018A55F888140183C104FF4DC8
		75DFFF45108B45103B45EC7CAB8BC3C1E0020145DCFF4DCC0F85CEFEFFFF8B4DEC33C08945F88945FC89451C8945148945103BC87E6C3945F07E5C8B4DD8
		8B75E80FAFCB034D100FAFF30FAF4D188B45088D500203CA8D0CB18BF08BF88945F48B45F02BF22BFA2955F48945C80FB6440E030145140FB60101451C0F
		B6440F010145FC8B45F40FB604010145F883C104FF4DC875D833C0FF45108B4DEC394D107C940FAF4DF03BC874068B451499F7F933F68945143BCE740B8B
		451C99F7F989451CEB0389751C3BCE740B8B45FC99F7F98945FCEB038975FC3BCE740B8B45F899F7F98945F8EB038975F88975083975EC7E63EB0233F639
		75F07E4F8B4DD88B75E80FAFCB034D080FAFF30FAF4D188B450C8D500203CA8D0CB18BF08BF82BF22BFA2BC28B55F08955108A551488540E038A551C8811
		8A55FC88540F018A55F888140883C104FF4D1075DFFF45088B45083B45EC7C9F5F5E33C05BC9C21800
		)"
		else ; x64 machine code
		MCode_PixelateBitmap := "
		(LTrim Join
		4489442418488954241048894C24085355565741544155415641574883EC28418BC1448B8C24980000004C8BDA99488BD941F7F9448BD0448BFA8954240C
		448994248800000085C00F8E9D020000418BC04533E4458BF299448924244C8954241041F7F933C9898C24980000008BEA89542404448BE889442408EB05
		4C8B5C24784585ED0F8E1A010000458BF1418BFD48897C2418450FAFF14533D233F633ED4533E44533ED4585C97E5B4C63BC2490000000418D040A410FAF
		C148984C8D441802498BD9498BD04D8BD90FB642010FB64AFF4403E80FB60203E90FB64AFE4883C2044403E003F149FFCB75DE4D03C748FFCB75D0488B7C
		24188B8C24980000004C8B5C2478418BC59941F7FE448BE8418BC49941F7FE448BE08BC59941F7FE8BE88BC69941F7FE8BF04585C97E4048639C24900000
		004103CA4D8BC1410FAFC94863C94A8D541902488BCA498BC144886901448821408869FF408871FE4883C10448FFC875E84803D349FFC875DA8B8C249800
		0000488B5C24704C8B5C24784183C20448FFCF48897C24180F850AFFFFFF8B6C2404448B2424448B6C24084C8B74241085ED0F840A01000033FF33DB4533
		DB4533D24533C04585C97E53488B74247085ED7E42438D0C04418BC50FAF8C2490000000410FAFC18D04814863C8488D5431028BCD0FB642014403D00FB6
		024883C2044403D80FB642FB03D80FB642FA03F848FFC975DE41FFC0453BC17CB28BCD410FAFC985C9740A418BC299F7F98BF0EB0233F685C9740B418BC3
		99F7F9448BD8EB034533DB85C9740A8BC399F7F9448BD0EB034533D285C9740A8BC799F7F9448BC0EB034533C033D24585C97E4D4C8B74247885ED7E3841
		8D0C14418BC50FAF8C2490000000410FAFC18D04814863C84A8D4431028BCD40887001448818448850FF448840FE4883C00448FFC975E8FFC2413BD17CBD
		4C8B7424108B8C2498000000038C2490000000488B5C24704503E149FFCE44892424898C24980000004C897424100F859EFDFFFF448B7C240C448B842480
		000000418BC09941F7F98BE8448BEA89942498000000896C240C85C00F8E3B010000448BAC2488000000418BCF448BF5410FAFC9898C248000000033FF33
		ED33F64533DB4533D24533C04585FF7E524585C97E40418BC5410FAFC14103C00FAF84249000000003C74898488D541802498BD90FB642014403D00FB602
		4883C2044403D80FB642FB03F00FB642FA03E848FFCB75DE488B5C247041FFC0453BC77CAE85C9740B418BC299F7F9448BE0EB034533E485C9740A418BC3
		99F7F98BD8EB0233DB85C9740A8BC699F7F9448BD8EB034533DB85C9740A8BC599F7F9448BD0EB034533D24533C04585FF7E4E488B4C24784585C97E3541
		8BC5410FAFC14103C00FAF84249000000003C74898488D540802498BC144886201881A44885AFF448852FE4883C20448FFC875E941FFC0453BC77CBE8B8C
		2480000000488B5C2470418BC1C1E00203F849FFCE0F85ECFEFFFF448BAC24980000008B6C240C448BA4248800000033FF33DB4533DB4533D24533C04585
		FF7E5A488B7424704585ED7E48418BCC8BC5410FAFC94103C80FAF8C2490000000410FAFC18D04814863C8488D543102418BCD0FB642014403D00FB60248
		83C2044403D80FB642FB03D80FB642FA03F848FFC975DE41FFC0453BC77CAB418BCF410FAFCD85C9740A418BC299F7F98BF0EB0233F685C9740B418BC399
		F7F9448BD8EB034533DB85C9740A8BC399F7F9448BD0EB034533D285C9740A8BC799F7F9448BC0EB034533C033D24585FF7E4E4585ED7E42418BCC8BC541
		0FAFC903CA0FAF8C2490000000410FAFC18D04814863C8488B442478488D440102418BCD40887001448818448850FF448840FE4883C00448FFC975E8FFC2
		413BD77CB233C04883C428415F415E415D415C5F5E5D5BC3
		)"

		VarSetCapacity(PixelateBitmap, StrLen(MCode_PixelateBitmap)//2)
		nCount := StrLen(MCode_PixelateBitmap)//2
		N := (A_AhkVersion < 2) ? nCount : "nCount"
		Loop %N%
			NumPut("0x" SubStr(MCode_PixelateBitmap, (2*A_Index)-1, 2), PixelateBitmap, A_Index-1, "UChar")
		DllCall("VirtualProtect", Ptr, &PixelateBitmap, Ptr, VarSetCapacity(PixelateBitmap), "uint", 0x40, A_PtrSize ? "UPtr*" : "UInt*", 0)
	}

	Gdip_GetImageDimensions(pBitmap, Width, Height)

	if (Width != Gdip_GetImageWidth(pBitmapOut) || Height != Gdip_GetImageHeight(pBitmapOut))
		return -1
	if (BlockSize > Width || BlockSize > Height)
		return -2

	E1 := Gdip_LockBits(pBitmap, 0, 0, Width, Height, Stride1, Scan01, BitmapData1)
	E2 := Gdip_LockBits(pBitmapOut, 0, 0, Width, Height, Stride2, Scan02, BitmapData2)
	if (E1 || E2)
		return -3

	; E := - unused exit code
	DllCall(&PixelateBitmap, Ptr, Scan01, Ptr, Scan02, "int", Width, "int", Height, "int", Stride1, "int", BlockSize)

	Gdip_UnlockBits(pBitmap, BitmapData1), Gdip_UnlockBits(pBitmapOut, BitmapData2)
	return 0
}

;#####################################################################################

Gdip_ToARGB(A, R, G, B)
{
	return (A << 24) | (R << 16) | (G << 8) | B
}

;#####################################################################################

Gdip_FromARGB(ARGB, ByRef A, ByRef R, ByRef G, ByRef B)
{
	A := (0xff000000 & ARGB) >> 24
	R := (0x00ff0000 & ARGB) >> 16
	G := (0x0000ff00 & ARGB) >> 8
	B := 0x000000ff & ARGB
}

;#####################################################################################

Gdip_AFromARGB(ARGB)
{
	return (0xff000000 & ARGB) >> 24
}

;#####################################################################################

Gdip_RFromARGB(ARGB)
{
	return (0x00ff0000 & ARGB) >> 16
}

;#####################################################################################

Gdip_GFromARGB(ARGB)
{
	return (0x0000ff00 & ARGB) >> 8
}

;#####################################################################################

Gdip_BFromARGB(ARGB)
{
	return 0x000000ff & ARGB
}

;#####################################################################################

StrGetB(Address, Length:=-1, Encoding:=0)
{
	; Flexible parameter handling:
	if !IsInteger(Length)
		Encoding := Length,  Length := -1

	; Check for obvious errors.
	if (Address+0 < 1024)
		return

	; Ensure 'Encoding' contains a numeric identifier.
	if (Encoding = "UTF-16")
		Encoding := 1200
	else if (Encoding = "UTF-8")
		Encoding := 65001
	else if SubStr(Encoding,1,2)="CP"
		Encoding := SubStr(Encoding,3)

	if !Encoding ; "" or 0
	{
		; No conversion necessary, but we might not want the whole string.
		if (Length == -1)
			Length := DllCall("lstrlen", "uint", Address)
		VarSetCapacity(String, Length)
		DllCall("lstrcpyn", "str", String, "uint", Address, "int", Length + 1)
	}
	else if (Encoding = 1200) ; UTF-16
	{
		char_count := DllCall("WideCharToMultiByte", "uint", 0, "uint", 0x400, "uint", Address, "int", Length, "uint", 0, "uint", 0, "uint", 0, "uint", 0)
		VarSetCapacity(String, char_count)
		DllCall("WideCharToMultiByte", "uint", 0, "uint", 0x400, "uint", Address, "int", Length, "str", String, "int", char_count, "uint", 0, "uint", 0)
	}
	else if IsInteger(Encoding)
	{
		; Convert from target encoding to UTF-16 then to the active code page.
		char_count := DllCall("MultiByteToWideChar", "uint", Encoding, "uint", 0, "uint", Address, "int", Length, "uint", 0, "int", 0)
		VarSetCapacity(String, char_count * 2)
		char_count := DllCall("MultiByteToWideChar", "uint", Encoding, "uint", 0, "uint", Address, "int", Length, "uint", &String, "int", char_count * 2)
		String := StrGetB(&String, char_count, 1200)
	}

	return String
}


;#####################################################################################
; in AHK v1: uses normal 'if var is' command
; in AHK v2: all if's are expression-if, so the Integer variable is dereferenced to the string
;#####################################################################################
IsInteger(Var) {
	Static Integer := "Integer"
	If Var Is Integer
		Return True
	Return False
}

IsNumber(Var) {
	Static number := "number"
	If Var Is number
		Return True
	Return False
}



; ======================================================================================================================
; Multiple Display Monitors Functions -> msdn.microsoft.com/en-us/library/dd145072(v=vs.85).aspx
; by 'just me'
; https://autohotkey.com/boards/viewtopic.php?f=6&t=4606
; ======================================================================================================================
GetMonitorCount()
{
	Monitors := MDMF_Enum()
	for k,v in Monitors
		count := A_Index
	return count
}

GetMonitorInfo(MonitorNum)
{
	Monitors := MDMF_Enum()
	for k,v in Monitors
		if (v.Num = MonitorNum)
			return v
}

GetPrimaryMonitor()
{
	Monitors := MDMF_Enum()
	for k,v in Monitors
		If (v.Primary)
			return v.Num
}
; ======================================================================================================================
; Enumerates display monitors and returns an object containing the properties of all monitors or the specified monitor.
; ======================================================================================================================
MDMF_Enum(HMON := "") {
	Static CbFunc := (A_AhkVersion < "2") ? Func("RegisterCallback") : Func("CallbackCreate")
	Static EnumProc := %CbFunc%("MDMF_EnumProc") 
	Static Monitors := {}
	If (HMON = "") ; new enumeration
		Monitors := {}
	If (Monitors.MaxIndex() = "") ; enumerate
		If !DllCall("User32.dll\EnumDisplayMonitors", "Ptr", 0, "Ptr", 0, "Ptr", EnumProc, "Ptr", &Monitors, "UInt")
			Return False
	Return (HMON = "") ? Monitors : Monitors.HasKey(HMON) ? Monitors[HMON] : False
}
; ======================================================================================================================
;  Callback function that is called by the MDMF_Enum function.
; ======================================================================================================================
MDMF_EnumProc(HMON, HDC, PRECT, ObjectAddr) {
	Monitors := Object(ObjectAddr)
	Monitors[HMON] := MDMF_GetInfo(HMON)
	Return True
}
; ======================================================================================================================
;  Retrieves the display monitor that has the largest area of intersection with a specified window.
; ======================================================================================================================
MDMF_FromHWND(HWND) {
	Return DllCall("User32.dll\MonitorFromWindow", "Ptr", HWND, "UInt", 0, "UPtr")
}
; ======================================================================================================================
; Retrieves the display monitor that contains a specified point.
; If either X or Y is empty, the function will use the current cursor position for this value.
; ======================================================================================================================
MDMF_FromPoint(X := "", Y := "") {
	VarSetCapacity(PT, 8, 0)
	If (X = "") || (Y = "") {
		DllCall("User32.dll\GetCursorPos", "Ptr", &PT)
		If (X = "")
			X := NumGet(PT, 0, "Int")
		If (Y = "")
			Y := NumGet(PT, 4, "Int")
	}
	Return DllCall("User32.dll\MonitorFromPoint", "Int64", (X & 0xFFFFFFFF) | (Y << 32), "UInt", 0, "UPtr")
}
; ======================================================================================================================
; Retrieves the display monitor that has the largest area of intersection with a specified rectangle.
; Parameters are consistent with the common AHK definition of a rectangle, which is X, Y, W, H instead of
; Left, Top, Right, Bottom.
; ======================================================================================================================
MDMF_FromRect(X, Y, W, H) {
	VarSetCapacity(RC, 16, 0)
	NumPut(X, RC, 0, "Int"), NumPut(Y, RC, 4, Int), NumPut(X + W, RC, 8, "Int"), NumPut(Y + H, RC, 12, "Int")
	Return DllCall("User32.dll\MonitorFromRect", "Ptr", &RC, "UInt", 0, "UPtr")
}
; ======================================================================================================================
; Retrieves information about a display monitor.
; ======================================================================================================================
MDMF_GetInfo(HMON) {
	NumPut(VarSetCapacity(MIEX, 40 + (32 << !!A_IsUnicode)), MIEX, 0, "UInt")
	If DllCall("User32.dll\GetMonitorInfo", "Ptr", HMON, "Ptr", &MIEX) {
		MonName := StrGet(&MIEX + 40, 32)	; CCHDEVICENAME = 32
		MonNum := RegExReplace(MonName, ".*(\d+)$", "$1")
		Return {	Name:		(Name := StrGet(&MIEX + 40, 32))
				,	Num:		RegExReplace(Name, ".*(\d+)$", "$1")
				,	Left:		NumGet(MIEX, 4, "Int")		; display rectangle
				,	Top:		NumGet(MIEX, 8, "Int")		; "
				,	Right:		NumGet(MIEX, 12, "Int")		; "
				,	Bottom:		NumGet(MIEX, 16, "Int")		; "
				,	WALeft:		NumGet(MIEX, 20, "Int")		; work area
				,	WATop:		NumGet(MIEX, 24, "Int")		; "
				,	WARight:	NumGet(MIEX, 28, "Int")		; "
				,	WABottom:	NumGet(MIEX, 32, "Int")		; "
				,	Primary:	NumGet(MIEX, 36, "UInt")}	; contains a non-zero value for the primary monitor.
	}
	Return False
}


;**********************************************************************************
;
; Gdip_ImageSearch()
; by MasterFocus - 02/APRIL/2013 00:30h BRT
; Thanks to guest3456 for helping me ponder some ideas
; Requires GDIP, Gdip_SetBitmapTransColor() and Gdip_MultiLockedBitsSearch()
; http://www.autohotkey.com/board/topic/71100-gdip-imagesearch/
;
; Licensed under CC BY-SA 3.0 -> http://creativecommons.org/licenses/by-sa/3.0/
; I waive compliance with the "Share Alike" condition of the license EXCLUSIVELY
; for these users: tic , Rseding91 , guest3456
;
;==================================================================================
;
; This function searches for pBitmapNeedle within pBitmapHaystack
; The returned value is the number of instances found (negative = error)
;
; ++ PARAMETERS ++
;
; pBitmapHaystack and pBitmapNeedle
;   Self-explanatory bitmap pointers, are the only required parameters
;
; OutputList
;   ByRef variable to store the list of coordinates where a match was found
;
; OuterX1, OuterY1, OuterX2, OuterY2
;   Equivalent to ImageSearch's X1,Y1,X2,Y2
;   Default: 0 for all (which searches the whole haystack area)
;
; Variation
;   Just like ImageSearch, a value from 0 to 255
;   Default: 0
;
; Trans
;   Needle RGB transparent color, should be a numerical value from 0 to 0xFFFFFF
;   Default: blank (does not use transparency)
;
; SearchDirection
;   Haystack search direction
;     Vertical preference:
;       1 = top->left->right->bottom [default]
;       2 = bottom->left->right->top
;       3 = bottom->right->left->top
;       4 = top->right->left->bottom
;     Horizontal preference:
;       5 = left->top->bottom->right
;       6 = left->bottom->top->right
;       7 = right->bottom->top->left
;       8 = right->top->bottom->left
;
; Instances
;   Maximum number of instances to find when searching (0 = find all)
;   Default: 1 (stops after one match is found)
;
; LineDelim and CoordDelim
;   Outer and inner delimiters for the list of coordinates (OutputList)
;   Defaults: "`n" and ","
;
; ++ RETURN VALUES ++
;
; -1001 ==> invalid haystack and/or needle bitmap pointer
; -1002 ==> invalid variation value
; -1003 ==> X1 and Y1 cannot be negative
; -1004 ==> unable to lock haystack bitmap bits
; -1005 ==> unable to lock needle bitmap bits
; any non-negative value ==> the number of instances found
;
;==================================================================================
;
;**********************************************************************************

Gdip_ImageSearch(pBitmapHaystack,pBitmapNeedle,ByRef OutputList=""
,OuterX1=0,OuterY1=0,OuterX2=0,OuterY2=0,Variation=0,Trans=""
,SearchDirection=1,Instances=1,LineDelim="`n",CoordDelim=",") {

    ; Some validations that can be done before proceeding any further
    If !( pBitmapHaystack && pBitmapNeedle )
        Return -1001
    If Variation not between 0 and 255
        return -1002
    If ( ( OuterX1 < 0 ) || ( OuterY1 < 0 ) )
        return -1003
    If SearchDirection not between 1 and 8
        SearchDirection := 1
    If ( Instances < 0 )
        Instances := 0

    ; Getting the dimensions and locking the bits [haystack]
    Gdip_GetImageDimensions(pBitmapHaystack,hWidth,hHeight)
    ; Last parameter being 1 says the LockMode flag is "READ only"
    If Gdip_LockBits(pBitmapHaystack,0,0,hWidth,hHeight,hStride,hScan,hBitmapData,1)
    OR !(hWidth := NumGet(hBitmapData,0,"UInt"))
    OR !(hHeight := NumGet(hBitmapData,4,"UInt"))
        Return -1004

    ; Careful! From this point on, we must do the following before returning:
    ; - unlock haystack bits

    ; Getting the dimensions and locking the bits [needle]
    Gdip_GetImageDimensions(pBitmapNeedle,nWidth,nHeight)
    ; If Trans is correctly specified, create a backup of the original needle bitmap
    ; and modify the current one, setting the desired color as transparent.
    ; Also, since a copy is created, we must remember to dispose the new bitmap later.
    ; This whole thing has to be done before locking the bits.
    If Trans between 0 and 0xFFFFFF
    {
        pOriginalBmpNeedle := pBitmapNeedle
        pBitmapNeedle := Gdip_CloneBitmapArea(pOriginalBmpNeedle,0,0,nWidth,nHeight)
        Gdip_SetBitmapTransColor(pBitmapNeedle,Trans)
        DumpCurrentNeedle := true
    }

    ; Careful! From this point on, we must do the following before returning:
    ; - unlock haystack bits
    ; - dispose current needle bitmap (if necessary)

    If Gdip_LockBits(pBitmapNeedle,0,0,nWidth,nHeight,nStride,nScan,nBitmapData)
    OR !(nWidth := NumGet(nBitmapData,0,"UInt"))
    OR !(nHeight := NumGet(nBitmapData,4,"UInt"))
    {
        If ( DumpCurrentNeedle )
            Gdip_DisposeImage(pBitmapNeedle)
        Gdip_UnlockBits(pBitmapHaystack,hBitmapData)
        Return -1005
    }
    
    ; Careful! From this point on, we must do the following before returning:
    ; - unlock haystack bits
    ; - unlock needle bits
    ; - dispose current needle bitmap (if necessary)

    ; Adjust the search box. "OuterX2,OuterY2" will be the last pixel evaluated
    ; as possibly matching with the needle's first pixel. So, we must avoid going
    ; beyond this maximum final coordinate.
    OuterX2 := ( !OuterX2 ? hWidth-nWidth+1 : OuterX2-nWidth+1 )
    OuterY2 := ( !OuterY2 ? hHeight-nHeight+1 : OuterY2-nHeight+1 )

    OutputCount := Gdip_MultiLockedBitsSearch(hStride,hScan,hWidth,hHeight
    ,nStride,nScan,nWidth,nHeight,OutputList,OuterX1,OuterY1,OuterX2,OuterY2
    ,Variation,SearchDirection,Instances,LineDelim,CoordDelim)

    Gdip_UnlockBits(pBitmapHaystack,hBitmapData)
    Gdip_UnlockBits(pBitmapNeedle,nBitmapData)
    If ( DumpCurrentNeedle )
        Gdip_DisposeImage(pBitmapNeedle)

    Return OutputCount
}

;///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
;///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
;///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

;**********************************************************************************
;
; Gdip_SetBitmapTransColor()
; by MasterFocus - 02/APRIL/2013 00:30h BRT
; Requires GDIP
; http://www.autohotkey.com/board/topic/71100-gdip-imagesearch/
;
; Licensed under CC BY-SA 3.0 -> http://creativecommons.org/licenses/by-sa/3.0/
; I waive compliance with the "Share Alike" condition of the license EXCLUSIVELY
; for these users: tic , Rseding91 , guest3456
;
;**********************************************************************************

;==================================================================================
;
; This function modifies the Alpha component for all pixels of a certain color to 0
; The returned value is 0 in case of success, or a negative number otherwise
;
; ++ PARAMETERS ++
;
; pBitmap
;   A valid pointer to the bitmap that will be modified
;
; TransColor
;   The color to become transparent
;   Should range from 0 (black) to 0xFFFFFF (white)
;
; ++ RETURN VALUES ++
;
; -2001 ==> invalid bitmap pointer
; -2002 ==> invalid TransColor
; -2003 ==> unable to retrieve bitmap positive dimensions
; -2004 ==> unable to lock bitmap bits
; -2005 ==> DllCall failed (see ErrorLevel)
; any non-negative value ==> the number of pixels modified by this function
;
;==================================================================================

Gdip_SetBitmapTransColor(pBitmap,TransColor) {
    static _SetBmpTrans, Ptr, PtrA
    if !( _SetBmpTrans ) {
        Ptr := A_PtrSize ? "UPtr" : "UInt"
        PtrA := Ptr . "*"
        MCode_SetBmpTrans := "
            (LTrim Join
            8b44240c558b6c241cc745000000000085c07e77538b5c2410568b74242033c9578b7c2414894c24288da424000000
            0085db7e458bc18d1439b9020000008bff8a0c113a4e0275178a4c38013a4e01750e8a0a3a0e7508c644380300ff450083c0
            0483c204b9020000004b75d38b4c24288b44241c8b5c2418034c242048894c24288944241c75a85f5e5b33c05dc3,405
            34c8b5424388bda41c702000000004585c07e6448897c2410458bd84c8b4424304963f94c8d49010f1f800000000085db7e3
            8498bc1488bd3660f1f440000410fb648023848017519410fb6480138087510410fb6083848ff7507c640020041ff024883c
            00448ffca75d44c03cf49ffcb75bc488b7c241033c05bc3
            )"
        if ( A_PtrSize == 8 ) ; x64, after comma
            MCode_SetBmpTrans := SubStr(MCode_SetBmpTrans,InStr(MCode_SetBmpTrans,",")+1)
        else ; x86, before comma
            MCode_SetBmpTrans := SubStr(MCode_SetBmpTrans,1,InStr(MCode_SetBmpTrans,",")-1)
        VarSetCapacity(_SetBmpTrans, LEN := StrLen(MCode_SetBmpTrans)//2, 0)
        Loop, %LEN%
            NumPut("0x" . SubStr(MCode_SetBmpTrans,(2*A_Index)-1,2), _SetBmpTrans, A_Index-1, "uchar")
        MCode_SetBmpTrans := ""
        DllCall("VirtualProtect", Ptr,&_SetBmpTrans, Ptr,VarSetCapacity(_SetBmpTrans), "uint",0x40, PtrA,0)
    }
    If !pBitmap
        Return -2001
    If TransColor not between 0 and 0xFFFFFF
        Return -2002
    Gdip_GetImageDimensions(pBitmap,W,H)
    If !(W && H)
        Return -2003
    If Gdip_LockBits(pBitmap,0,0,W,H,Stride,Scan,BitmapData)
        Return -2004
    ; The following code should be slower than using the MCode approach,
    ; but will the kept here for now, just for reference.
    /*
    Count := 0
    Loop, %H% {
        Y := A_Index-1
        Loop, %W% {
            X := A_Index-1
            CurrentColor := Gdip_GetLockBitPixel(Scan,X,Y,Stride)
            If ( (CurrentColor & 0xFFFFFF) == TransColor )
                Gdip_SetLockBitPixel(TransColor,Scan,X,Y,Stride), Count++
        }
    }
    */
    ; Thanks guest3456 for helping with the initial solution involving NumPut
    Gdip_FromARGB(TransColor,A,R,G,B), VarSetCapacity(TransColor,0), VarSetCapacity(TransColor,3,255)
    NumPut(B,TransColor,0,"UChar"), NumPut(G,TransColor,1,"UChar"), NumPut(R,TransColor,2,"UChar")
    MCount := 0
    E := DllCall(&_SetBmpTrans, Ptr,Scan, "int",W, "int",H, "int",Stride, Ptr,&TransColor, "int*",MCount, "cdecl int")
    Gdip_UnlockBits(pBitmap,BitmapData)
    If ( E != 0 ) {
        ErrorLevel := E
        Return -2005
    }
    Return MCount
}

;///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
;///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
;///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

;**********************************************************************************
;
; Gdip_MultiLockedBitsSearch()
; by MasterFocus - 24/MARCH/2013 06:20h BRT
; Requires GDIP and Gdip_LockedBitsSearch()
; http://www.autohotkey.com/board/topic/71100-gdip-imagesearch/
;
; Licensed under CC BY-SA 3.0 -> http://creativecommons.org/licenses/by-sa/3.0/
; I waive compliance with the "Share Alike" condition of the license EXCLUSIVELY
; for these users: tic , Rseding91 , guest3456
;
;**********************************************************************************

;==================================================================================
;
; This function returns the number of instances found
; The 8 first parameters are the same as in Gdip_LockedBitsSearch()
; The other 10 parameters are the same as in Gdip_ImageSearch()
; Note: the default for the Intances parameter here is 0 (find all matches)
;
;==================================================================================

Gdip_MultiLockedBitsSearch(hStride,hScan,hWidth,hHeight,nStride,nScan,nWidth,nHeight
,ByRef OutputList="",OuterX1=0,OuterY1=0,OuterX2=0,OuterY2=0,Variation=0
,SearchDirection=1,Instances=0,LineDelim="`n",CoordDelim=",")
{
    OutputList := ""
    OutputCount := !Instances
    InnerX1 := OuterX1 , InnerY1 := OuterY1
    InnerX2 := OuterX2 , InnerY2 := OuterY2

    ; The following part is a rather ugly but working hack that I
    ; came up with to adjust the variables and their increments
    ; according to the specified Haystack Search Direction
    /*
    Mod(SD,4) = 0 --> iX = 2 , stepX = +0 , iY = 1 , stepY = +1
    Mod(SD,4) = 1 --> iX = 1 , stepX = +1 , iY = 1 , stepY = +1
    Mod(SD,4) = 2 --> iX = 1 , stepX = +1 , iY = 2 , stepY = +0
    Mod(SD,4) = 3 --> iX = 2 , stepX = +0 , iY = 2 , stepY = +0
    SD <= 4   ------> Vertical preference
    SD > 4    ------> Horizontal preference
    */
    ; Set the index and the step (for both X and Y) to +1
    iX := 1, stepX := 1, iY := 1, stepY := 1
    ; Adjust Y variables if SD is 2, 3, 6 or 7
    Modulo := Mod(SearchDirection,4)
    If ( Modulo > 1 )
        iY := 2, stepY := 0
    ; adjust X variables if SD is 3, 4, 7 or 8
    If !Mod(Modulo,3)
        iX := 2, stepX := 0
    ; Set default Preference to vertical and Nonpreference to horizontal
    P := "Y", N := "X"
    ; adjust Preference and Nonpreference if SD is 5, 6, 7 or 8
    If ( SearchDirection > 4 )
        P := "X", N := "Y"
    ; Set the Preference Index and the Nonpreference Index
    iP := i%P%, iN := i%N%

    While (!(OutputCount == Instances) && (0 == Gdip_LockedBitsSearch(hStride,hScan,hWidth,hHeight,nStride
    ,nScan,nWidth,nHeight,FoundX,FoundY,OuterX1,OuterY1,OuterX2,OuterY2,Variation,SearchDirection)))
    {
        OutputCount++
        OutputList .= LineDelim FoundX CoordDelim FoundY
        Outer%P%%iP% := Found%P%+step%P%
        Inner%N%%iN% := Found%N%+step%N%
        Inner%P%1 := Found%P%
        Inner%P%2 := Found%P%+1
        While (!(OutputCount == Instances) && (0 == Gdip_LockedBitsSearch(hStride,hScan,hWidth,hHeight,nStride
        ,nScan,nWidth,nHeight,FoundX,FoundY,InnerX1,InnerY1,InnerX2,InnerY2,Variation,SearchDirection)))
        {
            OutputCount++
            OutputList .= LineDelim FoundX CoordDelim FoundY
            Inner%N%%iN% := Found%N%+step%N%
        }
    }
    OutputList := SubStr(OutputList,1+StrLen(LineDelim))
    OutputCount -= !Instances
    Return OutputCount
}

;///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
;///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
;///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

;**********************************************************************************
;
; Gdip_LockedBitsSearch()
; by MasterFocus - 24/MARCH/2013 06:20h BRT
; Mostly adapted from previous work by tic and Rseding91
;
; Requires GDIP
; http://www.autohotkey.com/board/topic/71100-gdip-imagesearch/
;
; Licensed under CC BY-SA 3.0 -> http://creativecommons.org/licenses/by-sa/3.0/
; I waive compliance with the "Share Alike" condition of the license EXCLUSIVELY
; for these users: tic , Rseding91 , guest3456
;
;**********************************************************************************

;==================================================================================
;
; This function searches for a single match of nScan within hScan
;
; ++ PARAMETERS ++
;
; hStride, hScan, hWidth and hHeight
;   Haystack stuff, extracted from a BitmapData, extracted from a Bitmap
;
; nStride, nScan, nWidth and nHeight
;   Needle stuff, extracted from a BitmapData, extracted from a Bitmap
;
; x and y
;   ByRef variables to store the X and Y coordinates of the image if it's found
;   Default: "" for both
;
; sx1, sy1, sx2 and sy2
;   These can be used to crop the search area within the haystack
;   Default: "" for all (does not crop)
;
; Variation
;   Same as the builtin ImageSearch command
;   Default: 0
;
; sd
;   Haystack search direction
;     Vertical preference:
;       1 = top->left->right->bottom [default]
;       2 = bottom->left->right->top
;       3 = bottom->right->left->top
;       4 = top->right->left->bottom
;     Horizontal preference:
;       5 = left->top->bottom->right
;       6 = left->bottom->top->right
;       7 = right->bottom->top->left
;       8 = right->top->bottom->left
;   This value is passed to the internal MCoded function
;
; ++ RETURN VALUES ++
;
; -3001 to -3006 ==> search area incorrectly defined
; -3007 ==> DllCall returned blank
; 0 ==> DllCall succeeded and a match was found
; -4001 ==> DllCall succeeded but a match was not found
; anything else ==> the error value returned by the unsuccessful DllCall
;
;==================================================================================

Gdip_LockedBitsSearch(hStride,hScan,hWidth,hHeight,nStride,nScan,nWidth,nHeight
,ByRef x="",ByRef y="",sx1=0,sy1=0,sx2=0,sy2=0,Variation=0,sd=1)
{
    static _ImageSearch, Ptr, PtrA

    ; Initialize all MCode stuff, if necessary
    if !( _ImageSearch ) {
        Ptr := A_PtrSize ? "UPtr" : "UInt"
        PtrA := Ptr . "*"

        MCode_ImageSearch := "
            (LTrim Join
            8b44243883ec205355565783f8010f857a0100008b7c2458897c24143b7c24600f8db50b00008b44244c8b5c245c8b
            4c24448b7424548be80fafef896c242490897424683bf30f8d0a0100008d64240033c033db8bf5896c241c895c2420894424
            183b4424480f8d0401000033c08944241085c90f8e9d0000008b5424688b7c24408beb8d34968b54246403df8d4900b80300
            0000803c18008b442410745e8b44243c0fb67c2f020fb64c06028d04113bf87f792bca3bf97c738b44243c0fb64c06018b44
            24400fb67c28018d04113bf87f5a2bca3bf97c548b44243c0fb63b0fb60c068d04113bf87f422bca3bf97c3c8b4424108b7c
            24408b4c24444083c50483c30483c604894424103bc17c818b5c24208b74241c0374244c8b44241840035c24508974241ce9
            2dffffff8b6c24688b5c245c8b4c244445896c24683beb8b6c24240f8c06ffffff8b44244c8b7c24148b7424544703e8897c
            2414896c24243b7c24600f8cd5feffffe96b0a00008b4424348b4c246889088b4424388b4c24145f5e5d890833c05b83c420
            c383f8020f85870100008b7c24604f897c24103b7c24580f8c310a00008b44244c8b5c245c8b4c24448bef0fafe8f7d88944
            24188b4424548b742418896c24288d4900894424683bc30f8d0a0100008d64240033c033db8bf5896c2420895c241c894424
            243b4424480f8d0401000033c08944241485c90f8e9d0000008b5424688b7c24408beb8d34968b54246403df8d4900b80300
            0000803c03008b442414745e8b44243c0fb67c2f020fb64c06028d04113bf87f792bca3bf97c738b44243c0fb64c06018b44
            24400fb67c28018d04113bf87f5a2bca3bf97c548b44243c0fb63b0fb60c068d04113bf87f422bca3bf97c3c8b4424148b7c
            24408b4c24444083c50483c30483c604894424143bc17c818b5c241c8b7424200374244c8b44242440035c245089742420e9
            2dffffff8b6c24688b5c245c8b4c244445896c24683beb8b6c24280f8c06ffffff8b7c24108b4424548b7424184f03ee897c
            2410896c24283b7c24580f8dd5feffffe9db0800008b4424348b4c246889088b4424388b4c24105f5e5d890833c05b83c420
            c383f8030f85650100008b7c24604f897c24103b7c24580f8ca10800008b44244c8b6c245c8b5c24548b4c24448bf70faff0
            4df7d8896c242c897424188944241c8bff896c24683beb0f8c020100008d64240033c033db89742424895c2420894424283b
            4424480f8d76ffffff33c08944241485c90f8e9f0000008b5424688b7c24408beb8d34968b54246403dfeb038d4900b80300
            0000803c03008b442414745e8b44243c0fb67c2f020fb64c06028d04113bf87f752bca3bf97c6f8b44243c0fb64c06018b44
            24400fb67c28018d04113bf87f562bca3bf97c508b44243c0fb63b0fb60c068d04113bf87f3e2bca3bf97c388b4424148b7c
            24408b4c24444083c50483c30483c604894424143bc17c818b5c24208b7424248b4424280374244c40035c2450e92bffffff
            8b6c24688b5c24548b4c24448b7424184d896c24683beb0f8d0affffff8b7c24108b44241c4f03f0897c2410897424183b7c
            24580f8c580700008b6c242ce9d4feffff83f8040f85670100008b7c2458897c24103b7c24600f8d340700008b44244c8b6c
            245c8b5c24548b4c24444d8bf00faff7896c242c8974241ceb098da424000000008bff896c24683beb0f8c020100008d6424
            0033c033db89742424895c2420894424283b4424480f8d06feffff33c08944241485c90f8e9f0000008b5424688b7c24408b
            eb8d34968b54246403dfeb038d4900b803000000803c03008b442414745e8b44243c0fb67c2f020fb64c06028d04113bf87f
            752bca3bf97c6f8b44243c0fb64c06018b4424400fb67c28018d04113bf87f562bca3bf97c508b44243c0fb63b0fb60c068d
            04113bf87f3e2bca3bf97c388b4424148b7c24408b4c24444083c50483c30483c604894424143bc17c818b5c24208b742424
            8b4424280374244c40035c2450e92bffffff8b6c24688b5c24548b4c24448b74241c4d896c24683beb0f8d0affffff8b4424
            4c8b7c24104703f0897c24108974241c3b7c24600f8de80500008b6c242ce9d4feffff83f8050f85890100008b7c2454897c
            24683b7c245c0f8dc40500008b5c24608b6c24588b44244c8b4c2444eb078da42400000000896c24103beb0f8d200100008b
            e80faf6c2458896c241c33c033db8bf5896c2424895c2420894424283b4424480f8d0d01000033c08944241485c90f8ea600
            00008b5424688b7c24408beb8d34968b54246403dfeb0a8da424000000008d4900b803000000803c03008b442414745e8b44
            243c0fb67c2f020fb64c06028d04113bf87f792bca3bf97c738b44243c0fb64c06018b4424400fb67c28018d04113bf87f5a
            2bca3bf97c548b44243c0fb63b0fb60c068d04113bf87f422bca3bf97c3c8b4424148b7c24408b4c24444083c50483c30483
            c604894424143bc17c818b5c24208b7424240374244c8b44242840035c245089742424e924ffffff8b7c24108b6c241c8b44
            244c8b5c24608b4c24444703e8897c2410896c241c3bfb0f8cf3feffff8b7c24688b6c245847897c24683b7c245c0f8cc5fe
            ffffe96b0400008b4424348b4c24688b74241089088b4424385f89305e5d33c05b83c420c383f8060f85670100008b7c2454
            897c24683b7c245c0f8d320400008b6c24608b5c24588b44244c8b4c24444d896c24188bff896c24103beb0f8c1a0100008b
            f50faff0f7d88974241c8944242ceb038d490033c033db89742424895c2420894424283b4424480f8d06fbffff33c0894424
            1485c90f8e9f0000008b5424688b7c24408beb8d34968b54246403dfeb038d4900b803000000803c03008b442414745e8b44
            243c0fb67c2f020fb64c06028d04113bf87f752bca3bf97c6f8b44243c0fb64c06018b4424400fb67c28018d04113bf87f56
            2bca3bf97c508b44243c0fb63b0fb60c068d04113bf87f3e2bca3bf97c388b4424148b7c24408b4c24444083c50483c30483
            c604894424143bc17c818b5c24208b7424248b4424280374244c40035c2450e92bffffff8b6c24108b74241c0374242c8b5c
            24588b4c24444d896c24108974241c3beb0f8d02ffffff8b44244c8b7c246847897c24683b7c245c0f8de60200008b6c2418
            e9c2feffff83f8070f85670100008b7c245c4f897c24683b7c24540f8cc10200008b6c24608b5c24588b44244c8b4c24444d
            896c241890896c24103beb0f8c1a0100008bf50faff0f7d88974241c8944242ceb038d490033c033db89742424895c242089
            4424283b4424480f8d96f9ffff33c08944241485c90f8e9f0000008b5424688b7c24408beb8d34968b54246403dfeb038d49
            00b803000000803c18008b442414745e8b44243c0fb67c2f020fb64c06028d04113bf87f752bca3bf97c6f8b44243c0fb64c
            06018b4424400fb67c28018d04113bf87f562bca3bf97c508b44243c0fb63b0fb60c068d04113bf87f3e2bca3bf97c388b44
            24148b7c24408b4c24444083c50483c30483c604894424143bc17c818b5c24208b7424248b4424280374244c40035c2450e9
            2bffffff8b6c24108b74241c0374242c8b5c24588b4c24444d896c24108974241c3beb0f8d02ffffff8b44244c8b7c24684f
            897c24683b7c24540f8c760100008b6c2418e9c2feffff83f8080f85640100008b7c245c4f897c24683b7c24540f8c510100
            008b5c24608b6c24588b44244c8b4c24448d9b00000000896c24103beb0f8d200100008be80faf6c2458896c241c33c033db
            8bf5896c2424895c2420894424283b4424480f8d9dfcffff33c08944241485c90f8ea60000008b5424688b7c24408beb8d34
            968b54246403dfeb0a8da424000000008d4900b803000000803c03008b442414745e8b44243c0fb67c2f020fb64c06028d04
            113bf87f792bca3bf97c738b44243c0fb64c06018b4424400fb67c28018d04113bf87f5a2bca3bf97c548b44243c0fb63b0f
            b604068d0c103bf97f422bc23bf87c3c8b4424148b7c24408b4c24444083c50483c30483c604894424143bc17c818b5c2420
            8b7424240374244c8b44242840035c245089742424e924ffffff8b7c24108b6c241c8b44244c8b5c24608b4c24444703e889
            7c2410896c241c3bfb0f8cf3feffff8b7c24688b6c24584f897c24683b7c24540f8dc5feffff8b4424345fc700ffffffff8b
            4424345e5dc700ffffffffb85ff0ffff5b83c420c3,4c894c24204c89442418488954241048894c24085355565741544
            155415641574883ec188b8424c80000004d8bd94d8bd0488bda83f8010f85b3010000448b8c24a800000044890c24443b8c2
            4b80000000f8d66010000448bac24900000008b9424c0000000448b8424b00000008bbc2480000000448b9424a0000000418
            bcd410fafc9894c24040f1f84000000000044899424c8000000453bd00f8dfb000000468d2495000000000f1f80000000003
            3ed448bf933f6660f1f8400000000003bac24880000000f8d1701000033db85ff7e7e458bf4448bce442bf64503f7904d63c
            14d03c34180780300745a450fb65002438d040e4c63d84c035c2470410fb64b028d0411443bd07f572bca443bd17c50410fb
            64b01450fb650018d0411443bd07f3e2bca443bd17c37410fb60b450fb6108d0411443bd07f272bca443bd17c204c8b5c247
            8ffc34183c1043bdf7c8fffc54503fd03b42498000000e95effffff8b8424c8000000448b8424b00000008b4c24044c8b5c2
            478ffc04183c404898424c8000000413bc00f8c20ffffff448b0c24448b9424a000000041ffc14103cd44890c24894c24044
            43b8c24b80000000f8cd8feffff488b5c2468488b4c2460b85ff0ffffc701ffffffffc703ffffffff4883c418415f415e415
            d415c5f5e5d5bc38b8424c8000000e9860b000083f8020f858c010000448b8c24b800000041ffc944890c24443b8c24a8000
            0007cab448bac2490000000448b8424c00000008b9424b00000008bbc2480000000448b9424a0000000418bc9410fafcd418
            bc5894c2404f7d8894424080f1f400044899424c8000000443bd20f8d02010000468d2495000000000f1f80000000004533f
            6448bf933f60f1f840000000000443bb424880000000f8d56ffffff33db85ff0f8e81000000418bec448bd62bee4103ef496
            3d24903d3807a03007460440fb64a02418d042a4c63d84c035c2470410fb64b02428d0401443bc87f5d412bc8443bc97c554
            10fb64b01440fb64a01428d0401443bc87f42412bc8443bc97c3a410fb60b440fb60a428d0401443bc87f29412bc8443bc97
            c214c8b5c2478ffc34183c2043bdf7c8a41ffc64503fd03b42498000000e955ffffff8b8424c80000008b9424b00000008b4
            c24044c8b5c2478ffc04183c404898424c80000003bc20f8c19ffffff448b0c24448b9424a0000000034c240841ffc9894c2
            40444890c24443b8c24a80000000f8dd0feffffe933feffff83f8030f85c4010000448b8c24b800000041ffc944898c24c80
            00000443b8c24a80000000f8c0efeffff8b842490000000448b9c24b0000000448b8424c00000008bbc248000000041ffcb4
            18bc98bd044895c24080fafc8f7da890c24895424048b9424a0000000448b542404458beb443bda0f8c13010000468d249d0
            000000066660f1f84000000000033ed448bf933f6660f1f8400000000003bac24880000000f8d0801000033db85ff0f8e960
            00000488b4c2478458bf4448bd6442bf64503f70f1f8400000000004963d24803d1807a03007460440fb64a02438d04164c6
            3d84c035c2470410fb64b02428d0401443bc87f63412bc8443bc97c5b410fb64b01440fb64a01428d0401443bc87f48412bc
            8443bc97c40410fb60b440fb60a428d0401443bc87f2f412bc8443bc97c27488b4c2478ffc34183c2043bdf7c8a8b8424900
            00000ffc54403f803b42498000000e942ffffff8b9424a00000008b8424900000008b0c2441ffcd4183ec04443bea0f8d11f
            fffff448b8c24c8000000448b542404448b5c240841ffc94103ca44898c24c8000000890c24443b8c24a80000000f8dc2fef
            fffe983fcffff488b4c24608b8424c8000000448929488b4c2468890133c0e981fcffff83f8040f857f010000448b8c24a80
            0000044890c24443b8c24b80000000f8d48fcffff448bac2490000000448b9424b00000008b9424c0000000448b8424a0000
            0008bbc248000000041ffca418bcd4489542408410fafc9894c2404669044899424c8000000453bd00f8cf8000000468d249
            5000000000f1f800000000033ed448bf933f6660f1f8400000000003bac24880000000f8df7fbffff33db85ff7e7e458bf44
            48bce442bf64503f7904d63c14d03c34180780300745a450fb65002438d040e4c63d84c035c2470410fb64b028d0411443bd
            07f572bca443bd17c50410fb64b01450fb650018d0411443bd07f3e2bca443bd17c37410fb60b450fb6108d0411443bd07f2
            72bca443bd17c204c8b5c2478ffc34183c1043bdf7c8fffc54503fd03b42498000000e95effffff8b8424c8000000448b842
            4a00000008b4c24044c8b5c2478ffc84183ec04898424c8000000413bc00f8d20ffffff448b0c24448b54240841ffc14103c
            d44890c24894c2404443b8c24b80000000f8cdbfeffffe9defaffff83f8050f85ab010000448b8424a000000044890424443
            b8424b00000000f8dc0faffff8b9424c0000000448bac2498000000448ba424900000008bbc2480000000448b8c24a800000
            0428d0c8500000000898c24c800000044894c2404443b8c24b80000000f8d09010000418bc4410fafc18944240833ed448bf
            833f6660f1f8400000000003bac24880000000f8d0501000033db85ff0f8e87000000448bf1448bce442bf64503f74d63c14
            d03c34180780300745d438d040e4c63d84d03da450fb65002410fb64b028d0411443bd07f5f2bca443bd17c58410fb64b014
            50fb650018d0411443bd07f462bca443bd17c3f410fb60b450fb6108d0411443bd07f2f2bca443bd17c284c8b5c24784c8b5
            42470ffc34183c1043bdf7c8c8b8c24c8000000ffc54503fc4103f5e955ffffff448b4424048b4424088b8c24c80000004c8
            b5c24784c8b54247041ffc04103c4448944240489442408443b8424b80000000f8c0effffff448b0424448b8c24a80000004
            1ffc083c10444890424898c24c8000000443b8424b00000000f8cc5feffffe946f9ffff488b4c24608b042489018b4424044
            88b4c2468890133c0e945f9ffff83f8060f85aa010000448b8c24a000000044894c2404443b8c24b00000000f8d0bf9ffff8
            b8424b8000000448b8424c0000000448ba424900000008bbc2480000000428d0c8d00000000ffc88944240c898c24c800000
            06666660f1f840000000000448be83b8424a80000000f8c02010000410fafc4418bd4f7da891424894424084533f6448bf83
            3f60f1f840000000000443bb424880000000f8df900000033db85ff0f8e870000008be9448bd62bee4103ef4963d24903d38
            07a03007460440fb64a02418d042a4c63d84c035c2470410fb64b02428d0401443bc87f64412bc8443bc97c5c410fb64b014
            40fb64a01428d0401443bc87f49412bc8443bc97c41410fb60b440fb60a428d0401443bc87f30412bc8443bc97c284c8b5c2
            478ffc34183c2043bdf7c8a8b8c24c800000041ffc64503fc03b42498000000e94fffffff8b4424088b8c24c80000004c8b5
            c247803042441ffcd89442408443bac24a80000000f8d17ffffff448b4c24048b44240c41ffc183c10444894c2404898c24c
            8000000443b8c24b00000000f8ccefeffffe991f7ffff488b4c24608b4424048901488b4c246833c0448929e992f7ffff83f
            8070f858d010000448b8c24b000000041ffc944894c2404443b8c24a00000000f8c55f7ffff8b8424b8000000448b8424c00
            00000448ba424900000008bbc2480000000428d0c8d00000000ffc8890424898c24c8000000660f1f440000448be83b8424a
            80000000f8c02010000410fafc4418bd4f7da8954240c8944240833ed448bf833f60f1f8400000000003bac24880000000f8
            d4affffff33db85ff0f8e89000000448bf1448bd6442bf64503f74963d24903d3807a03007460440fb64a02438d04164c63d
            84c035c2470410fb64b02428d0401443bc87f63412bc8443bc97c5b410fb64b01440fb64a01428d0401443bc87f48412bc84
            43bc97c40410fb60b440fb60a428d0401443bc87f2f412bc8443bc97c274c8b5c2478ffc34183c2043bdf7c8a8b8c24c8000
            000ffc54503fc03b42498000000e94fffffff8b4424088b8c24c80000004c8b5c24780344240c41ffcd89442408443bac24a
            80000000f8d17ffffff448b4c24048b042441ffc983e90444894c2404898c24c8000000443b8c24a00000000f8dcefeffffe
            9e1f5ffff83f8080f85ddf5ffff448b8424b000000041ffc84489442404443b8424a00000000f8cbff5ffff8b9424c000000
            0448bac2498000000448ba424900000008bbc2480000000448b8c24a8000000428d0c8500000000898c24c800000044890c2
            4443b8c24b80000000f8d08010000418bc4410fafc18944240833ed448bf833f6660f1f8400000000003bac24880000000f8
            d0501000033db85ff0f8e87000000448bf1448bce442bf64503f74d63c14d03c34180780300745d438d040e4c63d84d03da4
            50fb65002410fb64b028d0411443bd07f5f2bca443bd17c58410fb64b01450fb650018d0411443bd07f462bca443bd17c3f4
            10fb603450fb6108d0c10443bd17f2f2bc2443bd07c284c8b5c24784c8b542470ffc34183c1043bdf7c8c8b8c24c8000000f
            fc54503fc4103f5e955ffffff448b04248b4424088b8c24c80000004c8b5c24784c8b54247041ffc04103c44489042489442
            408443b8424b80000000f8c10ffffff448b442404448b8c24a800000041ffc883e9044489442404898c24c8000000443b842
            4a00000000f8dc6feffffe946f4ffff8b442404488b4c246089018b0424488b4c2468890133c0e945f4ffff
            )"
        if ( A_PtrSize == 8 ) ; x64, after comma
            MCode_ImageSearch := SubStr(MCode_ImageSearch,InStr(MCode_ImageSearch,",")+1)
        else ; x86, before comma
            MCode_ImageSearch := SubStr(MCode_ImageSearch,1,InStr(MCode_ImageSearch,",")-1)
        VarSetCapacity(_ImageSearch, LEN := StrLen(MCode_ImageSearch)//2, 0)
        Loop, %LEN%
            NumPut("0x" . SubStr(MCode_ImageSearch,(2*A_Index)-1,2), _ImageSearch, A_Index-1, "uchar")
        MCode_ImageSearch := ""
        DllCall("VirtualProtect", Ptr,&_ImageSearch, Ptr,VarSetCapacity(_ImageSearch), "uint",0x40, PtrA,0)
    }

    ; Abort if an initial coordinates is located before a final coordinate
    If ( sx2 < sx1 )
        return -3001
    If ( sy2 < sy1 )
        return -3002

    ; Check the search box. "sx2,sy2" will be the last pixel evaluated
    ; as possibly matching with the needle's first pixel. So, we must
    ; avoid going beyond this maximum final coordinate.
    If ( sx2 > (hWidth-nWidth+1) )
        return -3003
    If ( sy2 > (hHeight-nHeight+1) )
        return -3004

    ; Abort if the width or height of the search box is 0
    If ( sx2-sx1 == 0 )
        return -3005
    If ( sy2-sy1 == 0 )
        return -3006

    ; The DllCall parameters are the same for easier C code modification,
    ; even though they aren't all used on the _ImageSearch version
    x := 0, y := 0
    , E := DllCall( &_ImageSearch, "int*",x, "int*",y, Ptr,hScan, Ptr,nScan, "int",nWidth, "int",nHeight
    , "int",hStride, "int",nStride, "int",sx1, "int",sy1, "int",sx2, "int",sy2, "int",Variation
    , "int",sd, "cdecl int")
    Return ( E == "" ? -3007 : E )
}


Gdip_PixelSearch(pBitmap, ARGB, ByRef x, ByRef y)
{
	static _PixelSearch
	if !_PixelSearch
	{
		MCode_PixelSearch := "8B44241099535583E2035603C233F6C1F80239742418577E388B7C24148B6C24248B5424188D1C85000000008D64240033C085"
		. "D27E108BCF3929743183C00183C1043BC27CF283C60103FB3B74241C7CDF8B4424288B4C242C5F5EC700FFFFFFFF5DC701FFFFFFFF83C8FF5BC38B4C2"
		. "4288B54242C5F890189325E5D33C05BC3"

		VarSetCapacity(_PixelSearch, StrLen(MCode_PixelSearch)//2)
		Loop % StrLen(MCode_PixelSearch)//2      ;%
			NumPut("0x" SubStr(MCode_PixelSearch, (2*A_Index)-1, 2), _PixelSearch, A_Index-1, "char")
	}
	Gdip_GetImageDimensions(pBitmap, Width, Height)
	if !(Width && Height)
		return -1

	if (E1 := Gdip_LockBits(pBitmap, 0, 0, Width, Height, Stride1, Scan01, BitmapData1))
		return -2

	x := y := 0
	E := DllCall(&_PixelSearch, "uint", Scan01, "int", Width, "int", Height, "int", Stride1, "uint", ARGB, "int*", x, "int*", y)
	Gdip_UnlockBits(pBitmap, BitmapData1)
	return (E = "") ? -3 : E
}

MCode(ByRef code, hex) { ; allocate memory and write Machine Code there
   VarSetCapacity(code,StrLen(hex)//2)
   Loop % StrLen(hex)//2
      NumPut("0x" . SubStr(hex,2*A_Index-1,2), code, A_Index-1, "Char")
}

GdipImageSearch(byref x, byref y, imagePath = "img/picturehere.png",  Variation=100, direction = 1, x1=0, y1=0, x2=0, y2=0) 
{
    pBitmap := Gdip_BitmapFromHWND(A)
    LIST = 0
    bmpNeedle := Gdip_CreateBitmapFromFile(imagePath)
    RET := Gdip_ImageSearch(pBitmap, bmpNeedle, LIST, x1, y1, x2, y2, Variation, , direction, 1)
    Gdip_DisposeImage(bmpNeedle)
    Gdip_DisposeImage(pBitmap)
    LISTArray := StrSplit(LIST, ",")
    x := LISTArray[1]
    y := LISTArray[2]
    return List
}