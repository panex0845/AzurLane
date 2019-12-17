;@Ahk2Exe-SetMainIcon img\01.ico

if not A_IsAdmin { 
	Run *RunAs "%A_ScriptFullPath%"
	Exitapp
}

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Persistent
#SingleInstance, force
#Include Gdip.dll
pToken := Gdip_Startup()
Coordmode, pixel, window
Coordmode, mouse, window
DetectHiddenWindows, On
DetectHiddenText, On
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_WorkingDir%  ; Ensures a consistent starting directory.
SetControlDelay, -1
SetBatchLines, 1000ms
SetTitleMatchMode, 3
Menu, Tray, NoStandard
Menu, tray, add, &顯示介面, Showsub
Menu, tray, add,  , 
;~ Menu, tray, add, 檢查更新, IsUpdate
;~ Menu, tray, add,  , 
Menu, Tray, Default, &顯示介面
Menu, tray, add, 結束, Exitsub
Menu, Tray, Icon , img\01.ico,,, 1
Gui, font, s12, 新細明體
Run, %comspec% /c powercfg /change /monitor-timeout-ac 0,, Hide ;關閉螢幕省電模式
RegRead, ldplayer, HKEY_CURRENT_USER, Software\XuanZhi\LDPlayer, InstallDir ; Ldplayer 64bit version
if (ldplayer="") {
	MsgBox, 16, 設定精靈, 未能偵測到雷電模擬器的安裝路徑，請嘗試重新安裝。
	;~ Exitapp
}
Global ldplayer
Gui Add, Text,  x10 y40 w100 h20 , 模擬器標題：
IniRead, title, settings.ini, emulator, title, 
if (title="") or (title="ERROR") {
    InputBox, title, 設定精靈, `n`n　　　　　　　請輸入模擬器標題,, 400, 200,,,,, 雷電模擬器
    if ErrorLevel {
        Exitapp
    }
    else if  (title="") {
          Msgbox, 16, 設定精靈, 未輸入任何資訊。
          reload
    }
    else {
		InputBox, emulatoradb, 設定精靈, `n`n　　　　　　　請輸入模擬器編號,, 400, 200,,,,, 0
		if (emulatoradb>15 or emulatoradb<0) {
			msgbox, 請輸入介於0-15的數字
			exitapp
		}
		else {
			Iniwrite, %emulatoradb%, settings.ini, emulator, emulatoradb
			Iniwrite, %title%, settings.ini, emulator, title
			reload
		}
    }
}
IniRead, emulatoradb, settings.ini, emulator, emulatoradb, 0
Gui Add, Text,  x250 y40 w50 h20 , 代號：
Gui, Add, DropDownList, x300 y36 w40 h300 vemulatoradb ginisettings Choose%emulatoradb%, 1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|0||
GuicontrolGet, emulatoradb
Gui, Add, text, x10 y10 w300 h20 vMessageUpdate +cFF0011, Waiting for Start
Gui Add, Edit, x110 y37 w100 h21 vtitle ginisettings, %title%
suptitle = WorldFlipper - %title%
;~ mobileadb = H9AZCY03R082KEZ
;~ Mobile_X := 1080, Mobile_Y := 1920
Winget, UniqueID,, %title%
WinGetPos ,x ,y , , , %title% ;1316 762
Windwos_W := 582, Windows_H := 996, Sup_W := 400, Sup_H := 800 ;模擬器
;~ Windwos_W := 556, Windows_H := 1007, Sup_W := 400, Sup_H := 800 ;手機模式
WinMove,  %title%, , , , Windwos_W, Windows_H
Global UniqueID,  Windwos_W, Windows_H, Mobile_X, Mobile_Y, mobileadb, emulatoradb
Menu, Tray, Icon, %A_WorkingDir%\img\01.ico,,1
Pos_Y := Sup_H-30
Gui, Add, Button, x10 y%Pos_Y%  w100 h23 gstart vstart , 開始
Gui, Add, Button, x130 y%Pos_Y% w100 h23 greload vreload, 停止
Gui, Add, Button, x280 y%Pos_Y% w100 h23 gExitSub vExitSub, 結束
Pos_Y := Sup_H-90
;~ Gui, Add, Button, x10 y%Pos_Y%  w100 h20 gAutoaddfriend, 自動加好友
Gui, Add, Button, x10 y%Pos_Y%  h23 gForEmulator, 降低模擬器CPU占用

Pos_Y := 70
Pos_X := 10
Iniread, AutoShutDownAt_Stage, settings.ini, emulator, AutoShutDownAt_Stage, 0
Gui, Add, Checkbox, x%Pos_X% y%Pos_Y%  h20 ginisettings vAutoShutDownAt_Stage checked%AutoShutDownAt_Stage% , 進關卡自動斷線
Iniread, AutoClickatStage, settings.ini, emulator, AutoClickatStage, 0
Gui, Add, Checkbox, x220 y%Pos_Y%  h20 ginisettings vAutoClickatStage checked%AutoClickatStage% , 關卡自動點擊
Pos_Y += 40
Iniread, Main_Story, settings.ini, emulator, Main_Story, 0
Iniread, Main_MultiPlayer, settings.ini, emulator, Main_MultiPlayer, 0
Iniread, Main_ExpMission, settings.ini, emulator, Main_ExpMission, 0
Iniread, ReRoll, settings.ini, emulator, ReRoll, 0
Gui, Add, Radio,  x%Pos_X% y%Pos_Y%  h20 ginisettings vMain_Story checked%Main_Story% , 執行主線任務
Gui, Add, Radio,  x%Pos_X% y160  h20 ginisettings vMain_MultiPlayer checked%Main_MultiPlayer% , 執行多人模式
Gui, Add, Radio,  x%Pos_X% y285  h20 ginisettings vMain_ExpMission checked%Main_ExpMission% , 執行經驗關卡
Gui, Add, Radio,  x%Pos_X% y365  h20 ginisettings vReRoll checked%ReRoll% , 自動刷首抽
Pos_Y += 50

Pos_Y += 25
Iniread, MultiPlayer_Mission_Open, settings.ini, emulator, MultiPlayer_Mission_Open, 0
Gui, Add, Checkbox, x30 y%Pos_Y%  h20 ginisettings vMultiPlayer_Mission_Open checked%MultiPlayer_Mission_Open% , 自動開房：
Pos_Y -= 2
Iniread, Choose_Mission, settings.ini, emulator, Choose_Mission, 龍
MultiPlayer_Choose_MissionList = 龍|羊|虎|暗|魚|石|帝|鳥|
StringReplace,MultiPlayer_Choose_MissionSR,MultiPlayer_Choose_MissionList,%Choose_Mission%,%Choose_Mission%|
Gui, Add, DropDownList,  x150 y%Pos_Y% w55 ginisettings vMultiPlayer_Choose_Mission, %MultiPlayer_Choose_MissionSR%
Pos_Y += 2
Iniread, MultiPlayer_Mission_higher, settings.ini, emulator, MultiPlayer_Mission_higher, 0
Gui, Add, Checkbox, x220 y%Pos_Y%  h20 ginisettings vMultiPlayer_Mission_higher checked%MultiPlayer_Mission_higher% , 上級
Pos_Y += 25
Iniread, MultiPlayer_InviteAll, settings.ini, emulator, MultiPlayer_InviteAll, 0
Gui, Add, Checkbox, x30 y%Pos_Y%  h20 ginisettings vMultiPlayer_InviteAll checked%MultiPlayer_InviteAll% , 開啟小鈴鐺
Pos_Y += 25
Iniread, MultiPlayer_AutoRestart, settings.ini, emulator, MultiPlayer_AutoRestart, 0
Gui, Add, Checkbox, x30 y%Pos_Y% w50 h20 ginisettings vMultiPlayer_AutoRestart checked%MultiPlayer_AutoRestart% , 每刷
Pos_Y += 2
Iniread, MultiPlayer_AutoRestartNum, settings.ini, emulator, MultiPlayer_AutoRestartNum, 10
Gui Add, Edit, x90 y%Pos_Y% w50 h20 ginisettings vMultiPlayer_AutoRestartNum Number Limit4, %MultiPlayer_AutoRestartNum%
Pos_Y += 1
Gui, Add, text, x150 y%Pos_Y% , 場
Pos_Y -= 3
Iniread, Choose_AutoRestartActionList, settings.ini, emulator, Choose_AutoRestartActionList, 重新啟動遊戲
AutoRestartActionList = 重新啟動遊戲|重新啟動模擬器|
StringReplace,AutoRestartActionSR,AutoRestartActionList,%Choose_AutoRestartActionList%,%Choose_AutoRestartActionList%|
Gui, Add, DropDownList,  x180 y%Pos_Y% w150 ginisettings vAutoRestartAction, %AutoRestartActionSR%

Pos_Y += 50

Pos_Y += 30
Iniread, ExpMission_ChAction, settings.ini, emulator, ExpMission_ChAction, 0
Iniread, ExpMission_ChActionNum, settings.ini, emulator, ExpMission_ChActionNum, 1
Gui, Add, Checkbox, x30 y%Pos_Y%  h20 ginisettings vExpMission_ChAction checked%ExpMission_ChAction% , 執行第
Pos_Y -= 2
Gui, Add, DropDownList, x115 y%Pos_Y% w40 h300 ginisettings vExpMission_ChActionNum  Choose%ExpMission_ChActionNum%, 1|2|3|4|5|
Pos_Y += 5
Gui, Add, text, x165 y%Pos_Y% , 關
Pos_Y -= 3
Pos_Y += 50
Iniread, ReRoll_Loopforever, settings.ini, emulator, ReRoll_Loopforever, 0
Gui, Add, Checkbox, x140 y%Pos_Y%  h20 ginisettings vReRoll_Loopforever checked%ReRoll_Loopforever% , 自體無限循環
Pos_Y += 30
Gui, Add, text, x30 y%Pos_Y% , 取　　名：
Pos_Y -= 3
Gui Add, Edit, x120 y%Pos_Y% w150 h20 vReRoll_Named, Test123
Pos_Y += 3
Pos_Y += 30
Gui, Add, text, x30 y%Pos_Y% , 引繼密碼：
Pos_Y -= 3
Gui Add, Edit, x120 y%Pos_Y% w150 h20 vReRoll_Password, Test456789
Pos_Y += 3
Pos_Y += 50
Iniread, AutoCheck_Vpn, settings.ini, emulator, AutoCheck_Vpn, 0
Iniread, OpenVPN, settings.ini, emulator, OpenVPN, 1
Iniread, WangVPN, settings.ini, emulator, WangVPN, 0
Gui, Add, Checkbox, x10 y%Pos_Y%  h20 ginisettings vAutoCheck_Vpn checked%AutoCheck_Vpn% , VPN斷線重連
Pos_Y += 30
Gui, Add, Radio,  x30 y%Pos_Y%  h20 ginisettings vOpenVPN checked%OpenVPN% , OpenVPN
Gui, Add, Radio,  x140 y%Pos_Y%  h20 ginisettings vWangVPN checked%WangVPN% , 老王VPN

IfWinNotExist %title%
{
	x = %A_ScreenWidth%
	x := x-400,	y := 0
} else {
	x := x+582
}

Gui, Show, x%x% y%y% w%Sup_W% h%Sup_H% , %suptitle%
Gui, -sysmenu +owner%UniqueID% +ToolWindow
Menu, Tray, Tip , World Flipper `(%title%)
;//////////////刪除雷電模擬器的廣告檔案//////////////////
DefaultDir = %A_WorkingDir%
SetWorkingDir, %ldplayer%
OnMessage(0x53, "WM_HELP")
if (FileExist("fyservice.exe") or FileExist("fynews.exe") or FileExist("ldnews.exe")) {
	MsgBox, 24628, 設定精靈, 發現雷電模擬器中的廣告軟體，是否自動刪除？
	IfMsgBox Yes
	{
		while (FileExist("fyservice.exe") or FileExist("fynews.exe") or FileExist("ldnews.exe")) {
			WinClose, ahk_exe fynews.exe
			WinClose, ahk_exe fyservice.exe
			WinClose, ahk_exe ldnews.exe 
			FileDelete, fynews.exe
			FileDelete, fyservice.exe
			FileDelete, ldnews.exe
			LoopCount++
			if LoopCount>100
				break
		}
		SetWorkingDir, %A_temp%
		while (FileExist("fyservice.exe") or FileExist("fynews.exe") or FileExist("ldnews.exe"))
		{
			WinClose, ahk_exe fynews.exe
			WinClose, ahk_exe fyservice.exe
			WinClose, ahk_exe ldnews.exe
			FileDelete, fynews.exe
			FileDelete, fyservice.exe
			FileDelete, ldnews.exe
			LoopCount2++
			if LoopCount2>100
				break
		}
		if LoopCount2>100 or LoopCount>100
			Msgbox , 0, 設定精靈, 廣告檔案刪除失敗
		MsgBox, 0, 設定精靈, 廣告檔案刪除成功
	}
	else IfMsgBox No 
	{
	}
}
SetWorkingDir, %DefaultDir%
return


inisettings: ;一般設定
Guicontrolget, title
Guicontrolget, emulatoradb
Guicontrolget, AutoShutDownAt_Stage
Guicontrolget, AutoClickatStage
Guicontrolget, Main_Story
Guicontrolget, Main_MultiPlayer
Guicontrolget, MultiPlayer_InviteAll
Guicontrolget, Main_ExpMission
Guicontrolget, ExpMission_ChAction
Guicontrolget, ExpMission_ChActionNum
Guicontrolget, MultiPlayer_Mission_Open
Guicontrolget, MultiPlayer_Choose_Mission
Guicontrolget, MultiPlayer_Mission_higher
Guicontrolget, MultiPlayer_AutoRestart
Guicontrolget, MultiPlayer_AutoRestartNum
Guicontrolget, AutoRestartAction
Guicontrolget, ReRoll
Guicontrolget, ReRoll_Loopforever
Guicontrolget, AutoCheck_Vpn
Guicontrolget, OpenVPN
Guicontrolget, WangVPN


Iniwrite, %title%, settings.ini, emulator,  title
Iniwrite, %emulatoradb%, settings.ini, emulator,  emulatoradb
Iniwrite, %AutoShutDownAt_Stage%, settings.ini, emulator, AutoShutDownAt_Stage
Iniwrite, %AutoClickatStage%, settings.ini, emulator, AutoClickatStage
Iniwrite, %Main_Story%, settings.ini, emulator, Main_Story
Iniwrite, %Main_MultiPlayer%, settings.ini, emulator, Main_MultiPlayer
Iniwrite, %MultiPlayer_InviteAll%, settings.ini, emulator, MultiPlayer_InviteAll
Iniwrite, %MultiPlayer_Mission_Open%, settings.ini, emulator, MultiPlayer_Mission_Open
IniWrite,%MultiPlayer_Choose_Mission%, settings.ini, emulator,Choose_Mission
Iniwrite, %MultiPlayer_Mission_higher%, settings.ini, emulator, MultiPlayer_Mission_higher
IniWrite,%MultiPlayer_AutoRestart%, settings.ini, emulator, MultiPlayer_AutoRestart
Iniwrite, %MultiPlayer_AutoRestartNum%, settings.ini, emulator,MultiPlayer_AutoRestartNum
Iniwrite, %AutoRestartAction%, settings.ini, emulator,Choose_AutoRestartActionList

Iniwrite, %Main_ExpMission%, settings.ini, emulator, Main_ExpMission
Iniwrite, %ExpMission_ChAction%, settings.ini, emulator, ExpMission_ChAction
Iniwrite, %ExpMission_ChActionNum%, settings.ini, emulator, ExpMission_ChActionNum
Iniwrite, %ReRoll%, settings.ini, emulator, ReRoll
Iniwrite, %ReRoll_Loopforever%, settings.ini, emulator,ReRoll_Loopforever
;~ Msgbox %MultiPlayer_Mission_Open% . %MultiPlayer_Choose_Mission%
Iniwrite, %AutoCheck_Vpn%, settings.ini, emulator, AutoCheck_Vpn
Iniwrite, %OpenVPN%, settings.ini, emulator, OpenVPN
Iniwrite, %WangVPN%, settings.ini, emulator, WangVPN
Global title, emulatoradb, OpenVPN, WangVPN

return

Showsub:
Gui, show
return

Reload:
Critical
Guicontrol, disable, Reload
Reload
return

Exitsub:
exitapp
return

GuiClose:
ExitApp
return

movewin:
WinGet, Wincheck, MinMax, %title%
if (wincheck=1) ;視窗被最大化
{
	Guicontrol, , MessageUpdate, Win_Maximize_WaitingforRestore
	return
}
else if (wincheck=-1) ;視窗被最小化
{
	WinRestore, %title%
}
else
{
	IfWinActive %title%
	{
		wingetpos, x, y,w,h, %title%
		x := x+582
		winmove, %suptitle%, ,x,y
	}
}
IfWinNotExist %title%
{
	Loop
	{
		Guicontrol, , MessageUpdate, 未偵測到模擬器
		sleep 1000
		IfWinExist %title%
			break
	}
	WatingEmulatorSec := 50
	wingetpos, x, y,w,h, %title%
	x := x+582
	winmove, %suptitle%, ,x,y
	Loop, 50
	{
		WatingEmulatorSec := WatingEmulatorSec-1
		Guicontrol, , MessageUpdate, 已偵測到模擬器，等待 %WatingEmulatorSec% 秒後繼續。
		sleep 1000
	}
	Winget, UniqueID,, %title%
	Global UniqueID
	Goto, Start
}
return

START:
Guicontrol, disable, title
Guicontrol, disable, emulatoradb
Guicontrol, disable, Start
Gosub, inisettings
Guicontrol, , MessageUpdate, Start!
Winget, UniqueID,, %title%
Global UniqueID
WinMove,  %title%, , , , Windwos_W, Windows_H
WinActivate, %title%
wingetpos, x, y,w,h, %title%
x := x+582
winmove, %suptitle%, ,x,y
settimer, movewin, 1500
Loop
{
	Random, direction, 1, 8
	if (GdipImageSearch(x, y, "img/At_Stage_Now.png", 100, 8, 3, 63, 65, 116)) 
	{ ;檢查是否在戰鬥中
		Loop
		{
			if (AutoClickatStage)
			{
				Loop, 60
				{
					Random, x, 100, 500 ;尚未開啟AUTO可以用
					Random, y, 160, 700
					C_Click(x, y)
					Random, Randomsleep, 100, 300
					sleep % Randomsleep
				} until !(GdipImageSearch(x, y, "img/At_Stage_Now.png", 100, 8, 3, 63, 65, 116)) or (GdipImageSearch(x, y, "img/SystemMessage_GameOver.png", 100, 8, 46, 381, 104, 438))
			}	
			
			if (AutoShutDownAt_Stage)
			{
				run, dnconsole.exe killapp --index %emulatoradb% --packagename air.jp.co.cygames.worldflipper, %ldplayer%, Hide
			}
			
			if (Main_Story and GdipImageSearch(x, y, "img/SystemMessage_GameOver.png", 100, 8, 46, 381, 104, 438)) 
			{
			Guicontrol, , MessageUpdate, SystemMessage_GameOver
			Guicontrol, enable, Start
			Break
			}
			sleep 1000
			At_stage_Now_Time++
			Guicontrol, , MessageUpdate, 戰鬥中，經過時間： %At_stage_Now_Time% 秒
			if (At_stage_Now_Time>1801) ;戰鬥超過30分鐘重啟
			{
				Guicontrol, , MessageUpdate, 戰鬥逾時
				KillGame()
				break
			}
		} until !(GdipImageSearch(x, y, "img/At_Stage_Now.png", 100, 8, 3, 63, 65, 116))
		At_stage_Now_Time := 0
	}
	else if (Main_Story) ;如果有勾選進行主線任務
	{
		if (GdipImageSearch(x, y, "img/Main_Story_Btn.png", 100, 8, 225, 796, 320, 853)) {
			Guicontrol, , MessageUpdate, Story_New_challenge Click %x% %y%
			C_Click(x , y)
		}
		else if (GdipImageSearch(x, y, "img/Story_New_challenge.png", 100, 8, 12, 536, 87, 578)) {
			x := x+50, y := y-50
			Guicontrol, , MessageUpdate, Story_New_challenge Click %x% %y%
			C_Click(x , y)
		}
		else if (GdipImageSearch(x, y, "img/Story_New_Action.png", 100, 8, 15, 134, 490, 880)) {
			x := x+30, y := y-20
			Guicontrol, , MessageUpdate, Story_New_Action Click %x% %y%
			C_Click(x , y)
		}
		else if (GdipImageSearch(x, y, "img/Story_New_Story.png", 100, 8, 2, 314, 62, 355)) {
			x := x+30, y := y+15
			Guicontrol, , MessageUpdate, Story_New_Story Click %x% %y%
			C_Click(x , y)
		}
		else if (GdipImageSearch(x, y, "img/Story_a_Story.png", 100, 8, 489, 341, 528, 413)) {
			x := x-150, y := y+5
			Guicontrol, , MessageUpdate, Story_a_Story Click %x% %y%
			C_Click(x , y)
		}
		else if (GdipImageSearch(x, y, "img/Story_Skip_Btn.png", 100, 8, 446, 46, 538, 96)) {
			x := x+20, y := y+5
			Guicontrol, , MessageUpdate, Story_Skip_Btn Click %x% %y%
			C_Click(x , y)
		}
		else if (GdipImageSearch(x, y, "img/Story_Skip_Btn_Confirm.png", 105, 8, 320, 500, 480, 900)) {
			x := x+20, y := y+5
			Guicontrol, , MessageUpdate, Story_Skip_Btn_Confirm Click %x% %y%
			C_Click(x , y)
		}
		else if (GdipImageSearch(x, y, "img/Story_Get_Item.png", 100, 8, 227, 500, 318, 880)) {
			x := x+20, y := y+5
			Guicontrol, , MessageUpdate, Story_Get_Item Click %x% %y%
			C_Click(x , y)
		}
		else if (GdipImageSearch(x, y, "img/Story_Take_Challenge.png", 100, 8, 188, 825, 358, 885)) {
			x := x+20, y := y+5
			Guicontrol, , MessageUpdate, Story_Take_Challenge Click %x% %y%
			C_Click(x , y)
		}
		else if (GdipImageSearch(x, y, "img/Story_Next_Step_Btn.png", 100, 8, 230, 926, 308, 974)) {
			x := x+5, y := y+5
			Guicontrol, , MessageUpdate, Story_Next_Step_Btn Click %x% %y%
			C_Click(x , y)
		}
		else if (GdipImageSearch(x, y, "img/Story_OK_Btn.png", 100, 8, 234, 924, 305, 976)) {
			x := x+5, y := y+5
			Guicontrol, , MessageUpdate, Story_OK_Btn Click %x% %y%
			C_Click(x , y)
		}
		else if (GdipImageSearch(x, y, "img/SystemMessage_NewPartner.png", 100, 8, 25, 703, 178, 758)) {
		Guicontrol, , MessageUpdate, SystemMessage_NewPartner Click x%x% y%y%
		Random, x, 94, 471
		Random, y, 247, 676
		C_Click(x, y)
		}
		else if (GdipImageSearch(x, y, "img/SystemMessage_OldPartner.png", 30, 8, 108, 805, 164, 847)) {
		Guicontrol, , MessageUpdate, SystemMessage_OldPartner Click x%x% y%y%
		Random, x, 94, 471
		Random, y, 247, 676
		C_Click(x, y)
		}
		else if (GdipImageSearch(x, y, "img/Story_Confirm2_Btn.png", 100, 8, 224, 909, 316, 958)) {
		Guicontrol, , MessageUpdate, SystemMessage_OldPartner Click x%x% y%y%
		C_Click(x, y)
		}
	

	} ;//////主線任務結束////////
	
	else If (Main_MultiPlayer) ;////////開始執行多人模式//////
	{
		if (GdipImageSearch(x, y, "img/Main_MultiPlayer_Btn.png", 100, 8, 418, 828, 493, 885)) {
			Random, x, 412, 516
			Random, y, 841, 886
			Guicontrol, , MessageUpdate, SystemMessage_At_Stage_CloseUI Click x%x% y%y%
			C_Click(x, y)
		}
		else if (GdipImageSearch(x, y, "img/MultiPlayer_MultiPlay_Btn.png", 100, 8, 165, 674, 264, 744)) {
			MultiPlayer_FindParty := 0
			Random, x, 58, 471
			Random, y, 638, 819
			Guicontrol, , MessageUpdate, MultiPlayer_MultiPlay_Btn Click x%x% y%y%
			C_Click(x, y)
		}
		else if (GdipImageSearch(x, y, "img/MultiPlayer_Yes_Btn.png", 100, 8, 350, 630, 432, 677)) {
			Guicontrol, , MessageUpdate, MultiPlayer_Yes_Btn Click x%x% y%y%
			C_Click(x, y)
		}
		else if (GdipImageSearch(x, y, "img/MultiPlayer_Leader_Ready.png", 100, 8, 65, 633, 215, 684)) {
			Random, x, 59, 238
			Random, y, 640, 678
			Guicontrol, , MessageUpdate, MultiPlayer_Leader_Ready Click x%x% y%y%
			if !(AutoShutDownAt_Stage)
			{
				MultiPlayer_AutoRestartNumCount++
			}
			if (MultiPlayer_AutoRestartNumCount>=MultiPlayer_AutoRestartNum)
			{
				Guicontrolget, AutoRestartAction
				MultiPlayer_AutoRestartNumCount := 0
				if (AutoRestartAction="重新啟動遊戲")
				{
					KillGame()
				}
				else if (AutoRestartAction="重新啟動模擬器")
				{
					Rebootemulator()
					ReciprocalNum := 60
					Loop, 60
					{
						ReciprocalNum := ReciprocalNum-1
						Guicontrol, , MessageUpdate, 等待 %ReciprocalNum% 秒後繼續。
						sleep 1000
					}
					goto Start
				}
			}
			else
			{
				C_Click(x, y)
			}
		}
		else if (MultiPlayer_FindParty<2 and GdipImageSearch(x, y, "img/MultiPlayer_FindParty.png", 100, 8, 208, 712, 343, 769)) {
			Random, x, 178, 356
			Random, y, 723, 760
			Guicontrol, , MessageUpdate, MultiPlayer_FindParty Click x%x% y%y%
			MultiPlayer_FindParty++
			xx := x , yy := y
			C_Click(x, y)
			sleep 1000
			Loop, 2
			{
				sleep 1000
				 if (GdipImageSearch(x, y, "img/MultiPlayer_InviteFriend.png", 10, 8, 56, 291, 128, 350)) {
					Guicontrol, , MessageUpdate, MultiPlayer_InviteFriend Click x%x% y%y%
					C_Click(x, y)
				}
				if (MultiPlayer_InviteAll)
				{
					sleep 500
					C_Click(xx, yy)
					sleep 1000
					 if (MultiPlayer_InviteAll and GdipImageSearch(x, y, "img/MultiPlayer_InviteAll.png", 10, 8, 57, 483, 120, 544)) {
						Guicontrol, , MessageUpdate, MultiPlayer_InviteAll Click x%x% y%y%
						C_Click(x, y)
					}
				}
			}
		}
		else if (GdipImageSearch(x, y, "img/MultiPlayer_Invite_Cancel_Btn.png", 100, 8, 209, 710, 333, 753)) {
			Guicontrol, , MessageUpdate, MultiPlayer_Invite_Cancel_Btn Click x%x% y%y%
			C_Click(x, y)			
		}
		else if (GdipImageSearch(x, y, "img/MultiPlayer_NextStep_Btn.png", 100, 8, 232, 926, 312, 977)) {
			Guicontrol, , MessageUpdate, MultiPlayer_NextStep_Btn Click x%x% y%y%
			C_Click(x, y)			
		}
		else if (GdipImageSearch(x, y, "img/MultiPlayer_Ready_Btn.png", 100, 8, 186, 628, 331, 672)) {
			Guicontrol, , MessageUpdate, MultiPlayer_Ready_Btn Click x%x% y%y%
			if !(AutoShutDownAt_Stage)
			{
				MultiPlayer_AutoRestartNumCount++
			}
			if (MultiPlayer_AutoRestartNumCount>=MultiPlayer_AutoRestartNum)
			{
				MultiPlayer_AutoRestartNumCount := 0
				run, dnconsole.exe killapp --index %emulatoradb% --packagename air.jp.co.cygames.worldflipper, %ldplayer%, Hide
			}
			else
			{
				C_Click(x, y)
			}			
		}
		else if (GdipImageSearch(x, y, "img/MultiPlayer_WaitingforNextOne.png", 100, 8, 200, 243, 405, 274)) {
			Guicontrol, , MessageUpdate, MultiPlayer_WaitingforNextOne
			
		}
		else if (GdipImageSearch(n, m, "img/MultiPlayer_AllReady.png", 100, 8, 201, 243, 422, 275)) {
			Guicontrol, , MessageUpdate, MultiPlayer_AllReady
			if (GdipImageSearch(x, y, "img/MultiPlayer_AllReady_Fight_Btn.png", 100, 8, 314, 626, 478, 677)) {
				Guicontrol, , MessageUpdate, MultiPlayer_AllReady_Fight_Btn Click x%x% y%y%
				C_Click(x, y)
				MultiPlayer_FindParty := 0				
			}
		}
		else if (GdipImageSearch(x, y, "img/MultiPlayer_Again.png", 100, 8, 298, 926, 467, 977)) {
			Guicontrol, , MessageUpdate, MultiPlayer_Again Click x%x% y%y%
			C_Click(x, y)			
		}
		else if (GdipImageSearch(x, y, "img/MultiPlayer_TimeOut.png", 100, 8, 233, 628, 305, 678)) {
			Guicontrol, , MessageUpdate, MultiPlayer_TimeOut Click x%x% y%y%
			C_Click(x, y)
		}
		else if (!MultiPlayer_Mission_Open and GdipImageSearch(x, y, "img/MultiPlayer_JoinRoom.png", 100, 8, 486, 436, 528, 511)) {
			x := x-180
			Guicontrol, , MessageUpdate, MultiPlayer_JoinRoom Click x%x% y%y%
			C_Click(x, y)
		}
		else if (GdipImageSearch(x, y, "img/MultiPlayer_WrongWay.png", 100, 8, 269, 480, 321, 549))
		{
			
			C_Click(125, 945)
		}
		else if (GdipImageSearch(x, y, "img/MultiPlayer_WrongWay2.png", 100, 8, 26, 330, 96, 408))
		{
			
			C_Click(125, 945)
		}
		Try  ;////這邊開始進行選關/////
		{
			
			if (MultiPlayer_Mission_Open and (GdipImageSearch(x, y, "img/Multi_Player_Join_Can.png", 100, 8, 0, 251, 21, 299) or GdipImageSearch(x, y, "img/Multi_Player_Trans_btn.png", 100, 8, 461, 236, 524, 287))) ;檢查自動開房
			{
				if (MultiPlayer_Choose_Mission="龍")
				{
					if (GdipImageSearch(x, y, "img/MultiPlayer_Refresh_Btn.png", 100, 8, 466, 232, 522, 286) and GdipImageSearch(x, y, "img/MultiPlayer_Mission_Dra.png", 100, 8, 25, 330, 130, 900)) {
						x := x+180, y := y+20
						Guicontrol, , MessageUpdate, MultiPlayer_Mission_Dra Click x%x% y%y%
						C_Click(x, y)						
					}
					else if (GdipImageSearch(x, y, "img/MultiPlayer_Trans.png", 100, 8, 463, 233, 527, 287) and GdipImageSearch(x, y, "img/MultiPlayer_Mission_Dra2.png", 100, 8, 25, 300, 130, 900)) {
						x := x+180, y := y+20
						Guicontrol, , MessageUpdate, MultiPlayer_Mission_Dra2 Click x%x% y%y%
						C_Click(x, y)						
					}
				}
				else if (MultiPlayer_Choose_Mission="羊")
				{
					if (GdipImageSearch(x, y, "img/MultiPlayer_Refresh_Btn.png", 100, 8, 466, 232, 522, 286) and GdipImageSearch(x, y, "img/MultiPlayer_Mission_sheep.png", 100, 8, 25, 330, 130, 900)) {
						x := x+180, y := y+20
						Guicontrol, , MessageUpdate, MultiPlayer_Mission_sheep Click x%x% y%y%
						C_Click(x, y)						
					}
					else if (GdipImageSearch(x, y, "img/MultiPlayer_Trans.png", 100, 8, 463, 233, 527, 287) and !(MultiPlayer_Mission_higher) and GdipImageSearch(x, y, "img/MultiPlayer_Mission_sheep2.png", 100, 8, 25, 330, 130, 900)) {
						x := x+180, y := y+20
						Guicontrol, , MessageUpdate, MultiPlayer_Mission_sheep2 Click x%x% y%y%
						C_Click(x, y)						
					}
					else if (GdipImageSearch(x, y, "img/MultiPlayer_Trans.png", 100, 8, 463, 233, 527, 287) and (MultiPlayer_Mission_higher) and GdipImageSearch(x, y, "img/MultiPlayer_Mission_sheep3.png", 100, 8, 20, 300, 125, 500)) {
						x := x+180, y := y+20
						Guicontrol, , MessageUpdate, MultiPlayer_Mission_sheep3 Click x%x% y%y%
						C_Click(x, y)						
					}
				}
				else if (MultiPlayer_Choose_Mission="虎")
				{
					if (GdipImageSearch(x, y, "img/MultiPlayer_Refresh_Btn.png", 100, 8, 466, 232, 522, 286) and GdipImageSearch(x, y, "img/MultiPlayer_Mission_tiger.png", 100, 8, 25, 330, 130, 900)) {
						x := x+180, y := y+20
						Guicontrol, , MessageUpdate, MultiPlayer_Mission_tiger Click x%x% y%y%
						C_Click(x, y)						
					}
					else if (GdipImageSearch(x, y, "img/MultiPlayer_Trans.png", 100, 8, 463, 233, 527, 287) and !(MultiPlayer_Mission_higher) and GdipImageSearch(x, y, "img/MultiPlayer_Mission_tiger2.png", 100, 8, 25, 330, 130, 900)) {
						x := x+180, y := y+20
						Guicontrol, , MessageUpdate, MultiPlayer_Mission_tiger2 Click x%x% y%y%
						C_Click(x, y)						
					}
					else if (GdipImageSearch(x, y, "img/MultiPlayer_Trans.png", 100, 8, 463, 233, 527, 287) and (MultiPlayer_Mission_higher) and GdipImageSearch(x, y, "img/MultiPlayer_Mission_tiger3.png", 100, 8, 40, 300, 120, 500)) {
						x := x+180, y := y+20
						Guicontrol, , MessageUpdate, MultiPlayer_Mission_tiger3 Click x%x% y%y%
						C_Click(x, y)						
					}
				}
				else if (MultiPlayer_Choose_Mission="暗")
				{
					if (GdipImageSearch(x, y, "img/MultiPlayer_Refresh_Btn.png", 100, 8, 466, 232, 522, 286) and GdipImageSearch(x, y, "img/MultiPlayer_Mission_Dark.png", 100, 8, 25, 330, 130, 900)) {
						x := x+180, y := y+20
						Guicontrol, , MessageUpdate, MultiPlayer_Mission_Dark Click x%x% y%y%
						C_Click(x, y)						
					}
					else if (GdipImageSearch(x, y, "img/MultiPlayer_Trans.png", 100, 8, 463, 233, 527, 287) and !(MultiPlayer_Mission_higher) and GdipImageSearch(x, y, "img/MultiPlayer_Mission_Dark_Normal.png", 100, 8, 25, 330, 130, 900)) {
						x := x+180, y := y+10 ;選中級的
						Guicontrol, , MessageUpdate, MultiPlayer_Mission_Dark_Normal Click x%x% y%y%
						C_Click(x, y)						
					}
					else if (GdipImageSearch(x, y, "img/MultiPlayer_Trans.png", 100, 8, 463, 233, 527, 287) and (MultiPlayer_Mission_higher) and GdipImageSearch(x, y, "img/MultiPlayer_Mission_Dark3.png", 100, 8, 40, 300, 120, 500)) {
						x := x+180, y := y+20
						Guicontrol, , MessageUpdate, MultiPlayer_Mission_Dark3 Click x%x% y%y%
						C_Click(x, y)						
					}
				}
				else if (MultiPlayer_Choose_Mission="魚")
				{
					if (GdipImageSearch(x, y, "img/Multi_Player_Join_Can.png", 100, 8, 0, 251, 21, 299))
						Swipe(250,786,273,450)
					sleep 1000
					if (GdipImageSearch(x, y, "img/MultiPlayer_Refresh_Btn.png", 100, 8, 466, 232, 522, 286) and GdipImageSearch(x, y, "img/MultiPlayer_Mission_Fish.png", 100, 8, 25, 330, 130, 900)) {
						x := x+180, y := y+20
						Guicontrol, , MessageUpdate, MultiPlayer_Mission_Fish Click x%x% y%y%
						C_Click(x, y)						
					}
					else if (GdipImageSearch(x, y, "img/MultiPlayer_Trans.png", 100, 8, 463, 233, 527, 287) and !(MultiPlayer_Mission_higher) and GdipImageSearch(x, y, "img/MultiPlayer_Mission_Fish2.png", 100, 8, 25, 330, 130, 900)) {
						x := x+180, y := y+20
						Guicontrol, , MessageUpdate, MultiPlayer_Mission_Fish2 Click x%x% y%y%
						C_Click(x, y)						
					}
					else if (GdipImageSearch(x, y, "img/MultiPlayer_Trans.png", 100, 8, 463, 233, 527, 287) and (MultiPlayer_Mission_higher) and GdipImageSearch(x, y, "img/MultiPlayer_Mission_Fish3.png", 100, 8, 40, 300, 130, 500)) {
						x := x+180, y := y+20
						Guicontrol, , MessageUpdate, MultiPlayer_Mission_Fish3 Click x%x% y%y%
						C_Click(x, y)						
					}
				}
				else if (MultiPlayer_Choose_Mission="石")
				{
					if (GdipImageSearch(x, y, "img/Multi_Player_Join_Can.png", 100, 8, 0, 251, 21, 299))
						Swipe(250,786,273,450)
					sleep 1000
					if (GdipImageSearch(x, y, "img/MultiPlayer_Refresh_Btn.png", 100, 8, 466, 232, 522, 286) and GdipImageSearch(x, y, "img/MultiPlayer_Mission_Stone.png", 100, 8, 25, 330, 130, 900)) {
						x := x+180, y := y+20
						Guicontrol, , MessageUpdate, MultiPlayer_Mission_Stone Click x%x% y%y%
						C_Click(x, y)						
					}
					else if (GdipImageSearch(x, y, "img/MultiPlayer_Trans.png", 100, 8, 463, 233, 527, 287) and !(MultiPlayer_Mission_higher) and GdipImageSearch(x, y, "img/MultiPlayer_Mission_Stone2.png", 100, 8, 25, 330, 130, 900)) {
						x := x+180, y := y+20
						Guicontrol, , MessageUpdate, MultiPlayer_Mission_Stone2 Click x%x% y%y%
						C_Click(x, y)						
					}
					else if (GdipImageSearch(x, y, "img/MultiPlayer_Trans.png", 100, 8, 463, 233, 527, 287) and (MultiPlayer_Mission_higher) and GdipImageSearch(x, y, "img/MultiPlayer_Mission_Stone3.png", 100, 8, 40, 300, 130, 500)) {
						x := x+180, y := y+20
						Guicontrol, , MessageUpdate, MultiPlayer_Mission_Stone3 Click x%x% y%y%
						C_Click(x, y)						
					}
				}
				else if (MultiPlayer_Choose_Mission="帝")
				{
					if (GdipImageSearch(x, y, "img/Multi_Player_Join_Can.png", 100, 8, 0, 251, 21, 299))
						Swipe(250,786,273,450)
					sleep 1000
					if (GdipImageSearch(x, y, "img/MultiPlayer_Refresh_Btn.png", 100, 8, 466, 232, 522, 286) and GdipImageSearch(x, y, "img/MultiPlayer_Mission_King.png", 100, 8, 25, 330, 130, 900)) {
						x := x+180, y := y+20
						Guicontrol, , MessageUpdate, MultiPlayer_Mission_King Click x%x% y%y%
						C_Click(x, y)						
					}
					else if (GdipImageSearch(x, y, "img/MultiPlayer_Trans.png", 100, 8, 463, 233, 527, 287) and !(MultiPlayer_Mission_higher) and GdipImageSearch(x, y, "img/MultiPlayer_Mission_King2.png", 100, 8, 25, 330, 130, 900)) {
						x := x+180, y := y+20
						Guicontrol, , MessageUpdate, MultiPlayer_Mission_King2 Click x%x% y%y%
						C_Click(x, y)						
					}
					else if (GdipImageSearch(x, y, "img/MultiPlayer_Trans.png", 100, 8, 463, 233, 527, 287) and MultiPlayer_Mission_higher and GdipImageSearch(x, y, "img/MultiPlayer_Mission_King3.png", 100, 8, 25, 330, 120, 800)) {
						x := x+180, y := y+20
						Guicontrol, , MessageUpdate, MultiPlayer_Mission_King3 Click x%x% y%y%
						C_Click(x, y)						
					}
				}
				else if (MultiPlayer_Choose_Mission="鳥")
				{
					if (GdipImageSearch(x, y, "img/Multi_Player_Join_Can.png", 100, 8, 0, 251, 21, 299))
						Swipe(250,786,273,450)
					sleep 1000
					if (GdipImageSearch(x, y, "img/MultiPlayer_Refresh_Btn.png", 100, 8, 466, 232, 522, 286) and GdipImageSearch(x, y, "img/MultiPlayer_Mission_Bird.png", 100, 8, 25, 330, 130, 900)) {
						x := x+180, y := y+20
						Guicontrol, , MessageUpdate, MultiPlayer_Mission_Bird Click x%x% y%y%
						C_Click(x, y)
					}
					else if (GdipImageSearch(x, y, "img/MultiPlayer_Trans.png", 100, 8, 463, 233, 527, 287) and GdipImageSearch(x, y, "img/MultiPlayer_Mission_Bird2.png", 100, 8, 25, 330, 130, 900)) {
						x := x+180, y := y+20
						Guicontrol, , MessageUpdate, MultiPlayer_Mission_Bird2 Click x%x% y%y%
						C_Click(x, y)
					}
				}
			} ;/////檢查自動開房結束
				
			else if (GdipImageSearch(x, y, "img/MultiPlayer_Refresh_Btn.png", 100, 8, 466, 232, 522, 286)) {
				x := x+5, y := y+5 ;
				Random, Randomsleep, 2000, 10000
				Guicontrol, , MessageUpdate, MultiPlayer_Refresh_Btn Click x%x% y%y%
				C_Click(x, y)
				sleep 2000
			}
		}

	
		
	} ;//////多人模式結束////////
	
	else If (Main_ExpMission) ;///////進行經驗關//////////
	{
		if (GdipImageSearch(x, y, "img/Main_ExpMission_Btn.png", 100, 8, 51, 820, 124, 878)) {
			Guicontrol, , MessageUpdate, Main_ExpMission_Btn Click x%x% y%y%
			C_Click(x, y)
		}
		else if (GdipImageSearch(x, y, "img/ExpMission_ExpAction.png", 100, 8, 69, 573, 135, 639)) {
			Guicontrol, , MessageUpdate, ExpMission_ExpAction Click x%x% y%y%
			C_Click(x, y)
		}
		else if (GdipImageSearch(x, y, "img/ExpMission_ExpAction.png", 100, 8, 69, 573, 135, 639)) {
			Guicontrol, , MessageUpdate, ExpMission_ExpAction Click x%x% y%y%
			C_Click(x, y)
		}
		else if (GdipImageSearch(x, y, "img/ExpMission_Yes_Btn.png", 100, 8, 347, 626, 438, 678)) {
			Guicontrol, , MessageUpdate, ExpMission_Yes_Btn Click x%x% y%y%
			C_Click(x, y)
		}
		else if (GdipImageSearch(x, y, "img/ExpMission_Fight_Btn.png", 100, 8, 193, 821, 353, 872)) {
			Guicontrol, , MessageUpdate, ExpMission_Fight_Btn Click x%x% y%y%
			C_Click(x, y)
		}
		else if (GdipImageSearch(x, y, "img/ExpMission_NextStep_Btn.png", 100, 8, 232, 924, 307, 975)) {
			Guicontrol, , MessageUpdate, ExpMission_NextStep_Btn Click x%x% y%y%
			C_Click(x, y)
		}
		else if (GdipImageSearch(x, y, "img/ExpMission_Lower_OK_Btn.png", 100, 8, 238, 926, 305, 974)) {
			Guicontrol, , MessageUpdate, ExpMission_NextStep_Btn Click x%x% y%y%
			C_Click(x, y)
		}
		else if (ExpMission_ChAction)
		{
			if (GdipImageSearch(x, y, "img/ExpMission_ChAction.png", 100, 8, 487, 345, 527, 413))
			{
				Guicontrol, , MessageUpdate, ExpMission_ChAction Choose %ExpMission_ChAction%
				if ExpMission_ChActionNum=1
					C_Click(266, 382)
				else if ExpMission_ChActionNum=2
					C_Click(266, 489)
				else if ExpMission_ChActionNum=3
					C_Click(266, 593)
				else if ExpMission_ChActionNum=4
					C_Click(266, 697)
				else if ExpMission_ChActionNum=5
					C_Click(266, 811)
			}
		}
	} ;//////////經驗關卡結束///////////
	
	else if (ReRoll) ;自動刷首抽開始
	{
		if (GdipImageSearch(x, y, "img/Reroll_No_Btn.png", 105, 8, 98, 629, 198, 676))	{
			Guicontrol, , MessageUpdate, Reroll_No_Btn Click x%x% y%y%
			C_Click(x, y)
		}
		else if (GdipImageSearch(x, y, "img/Reroll_No2_Btn.png", 100, 8, 75, 630, 227, 675))	{
			Guicontrol, , MessageUpdate, Reroll_No2_Btn Click x%x% y%y%
			C_Click(x, y)
		}
		else if (GdipImageSearch(x, y, "img/Reroll_OK_Btn.png", 100, 8, 225, 806, 316, 859))	{
			Guicontrol, , MessageUpdate, Reroll_OK_Btn Click x%x% y%y%
			C_Click(x, y)
		}
		else if (GdipImageSearch(x, y, "img/Reroll_OK2_Btn.png", 100, 8, 342, 910, 445, 960))	{
			Guicontrol, , MessageUpdate, Reroll_OK2_Btn Click x%x% y%y%
			C_Click(x, y)
			C_Click(x, y)
			C_Click(x, y)
			C_Click(x, y)
			C_Click(x, y)
			C_Click(x, y)
			C_Click(x, y)
		}
		else if (GdipImageSearch(x, y, "img/Reroll_Named.png", 100, 8, 136, 140, 406, 193))	{
			Guicontrol, , MessageUpdate, Reroll_Named
			C_Click(96, 301)
			sleep 200
			C_Click(96, 301)
			Guicontrolget, ReRoll_Named
			sleep 500
			RunWait, dnconsole.exe action --index %emulatoradb% --key call.input --value %ReRoll_Named%, %ldplayer%, Hide
			sleep 500
			C_Click(260, 497)
		}
		else if (GdipImageSearch(x, y, "img/Reroll_GoReroll.png", 100, 8, 89, 459, 452, 505))	{
			Guicontrol, , MessageUpdate, Reroll_GoReroll
			C_Click(410, 947)
		}
		else if (GdipImageSearch(x, y, "img/Reroll_Roll_One.png", 100, 8, 141, 478, 401, 520))	{
			Guicontrol, , MessageUpdate, Reroll_Roll_One
			C_Click(223, 682)
		}
		else if (GdipImageSearch(x, y, "img/Reroll_FreeX150.png", 100, 8, 125, 374, 420, 421))	{
			Guicontrol, , MessageUpdate, Reroll_FreeX150
			C_Click(390, 649)
		}
		else if (GdipImageSearch(x, y, "img/Story_Skip_Btn.png", 100, 8, 446, 46, 538, 96)) {
		x := x+20, y := y+5
		Guicontrol, , MessageUpdate, Story_Skip_Btn Click %x% %y%
		C_Click(x , y)
		}
		else if (GdipImageSearch(x, y, "img/SystemMessage_NewPartner.png", 100, 8, 25, 703, 178, 758) or GdipImageSearch(x, y, "img/SystemMessage_NewPartner2.png", 10, 8, 108, 806, 140, 846)) {
		Guicontrol, , MessageUpdate, SystemMessage_NewPartner Click x%x% y%y%
		Random, x, 94, 471
		Random, y, 247, 676
		C_Click(x, y)
		}
		else if (GdipImageSearch(x, y, "img/Reroll_Top_btn2.png", 30, 8, 465, 834, 516, 989))	{
			Guicontrol, , MessageUpdate, Reroll_Top_btn Click x%x% y%y%
			C_Click(x, y)
		}
		else if (GdipImageSearch(x, y, "img/Reroll_Top_btn.png", 80, 8, 319, 826, 368, 880))	{ ;10連抽抽完
			Guicontrol, , MessageUpdate, Reroll_Top_btn2
			sleep 1500
			if (ReRoll_Loopforever and GdipImageSearch(x, y, "img/Reroll_Get_5Star.png", 100, 8, 5, 151, 535, 590)) ;5星才存檔
			{
				sleep 3000
				C_Click( 225, 944)
				sleep 3000
				C_Click( 225, 944)
				sleep 2000
				Loop, 120
				{
					if (GdipImageSearch(x, y, "img/Reroll_Myparty.png", 100, 8, 261, 372, 331, 427))
					{
						Guicontrol, , MessageUpdate, Reroll_Myparty Click x%x% y%y%
						C_Click(x, y)
					}
					else if (GdipImageSearch(x, y, "img/Reroll_Myparty2.png", 100, 8, 100, 472, 157, 529))
					{
						Guicontrol, , MessageUpdate, Reroll_Myparty2 Click x%x% y%y%
						C_Click(x, y)
					}
					else if (GdipImageSearch(x, y, "img/Reroll_Myparty3.png", 100, 8, 0, 919, 81, 977))
					{
						Guicontrol, , MessageUpdate, Reroll_Myparty3 Click x%x% y%y%
						sleep 2000
						Capture(39, 353, 526, 981) 
						sleep 1500
						C_Click( 43, 947)
						sleep 3000
						C_Click( 476, 943)
						sleep 3000
						C_Click( 283, 869)
						break
					}
					sleep 1000
				}
			}
			else if (ReRoll_Loopforever and !(GdipImageSearch(x, y, "img/Reroll_Get_5Star.png", 110, 8, 5, 151, 535, 590)))
			{
				KillGame()
				sleep 2000
				RunGame()
			}
			else 
			{
				MsgBox, 4, 首抽大師, 首抽結束，是否重抽？
				IfMsgBox Yes
					C_Click(21, 938)
				IfMsgBox No
					Reload
			}
		}
		else if (GdipImageSearch(x, y, "img/Reroll_OK3_btn.png", 100, 8, 226, 624, 318, 677))	{
			Guicontrol, , MessageUpdate, Reroll_OK3_btn Click x%x% y%y%
			C_Click(x, y)
		}
		else if (Reroll_AutoX10<1 and GdipImageSearch(x, y, "img/Reroll_AutoX10.png", 100, 8, 19, 674, 115, 715))	{
			Guicontrol, , MessageUpdate, Reroll_AutoX10 Click x%x% y%y%
			Reroll_AutoX10 := 1
			Loop, 6
			{
			sleep 3000
			C_Click(345, 668)
			}
		}
		else if (GdipImageSearch(x, y, "img/Reroll_AutoX10_Confirm.png", 100, 8, 318, 627, 473, 677))	{
			Guicontrol, , MessageUpdate, Reroll_AutoX10_Confirm Click x%x% y%y%
			C_Click(x, y)
		}
		else if (GdipImageSearch(x, y, "img/Reroll_Get_Item.png", 100, 8, 179, 567, 369, 611))	{
			Guicontrol, , MessageUpdate, Reroll_Get_Item Click x%x% y%y%
			C_Click(x, y)
		}
		else if (Reroll_AutoX10=1 and GdipImageSearch(x, y, "img/Reroll_Main_Screen.png", 100, 8, 53, 33, 355, 86))	{
			Guicontrol, , MessageUpdate, Reroll_Main_Screen 
			C_Click(554, 867)
		}
		else if (GdipImageSearch(x, y, "img/Reroll_Main_Screen2.png", 100, 8, 0, 99, 67, 169))	{
			Guicontrol, , MessageUpdate, Reroll_Main_Screen 
			KillGame()
		}
		else if (Reroll_Delete_Account<1 and GdipImageSearch(x, y, "img/Reroll_Delete_Account.png", 100, 8, 462, 54, 528, 104))	{
			Guicontrol, , MessageUpdate, Reroll_Delete_Account 
			if (isdelete<1)
			{
				isdelete := 1
				MsgBox, 4, 警告,  警告！即將刪除帳號，是否繼續？
				IfMsgBox No 
				{
					reload
					return
				}
			}
			C_Click(474, 70)
			sleep 1500
			C_Click(363, 500)
			sleep 1000
			C_Click(359, 712)
			sleep 1500
			C_Click(372, 658)
			sleep 1500
			C_Click(372, 658)
			Reroll_Delete_Account := 1
		}
		else if (Reroll_Delete_Account=1 and GdipImageSearch(x, y, "img/Reroll_Delete_Account.png", 100, 8, 462, 54, 528, 104)) ;自動登入
		{
			Guicontrol, , MessageUpdate, Login 
			Random, x, 94, 471
			Random, y, 247, 676
			C_Click(x, y)
			Reroll_Delete_Account := 0
			Reroll_AutoX10 := 0
			Reroll_Top_btn := 0
		}
		else if (GdipImageSearch(x, y, "img/Reroll_Agree_Btn.png", 100, 8, 170, 304, 373, 354)) {
			Guicontrol, , MessageUpdate, Reroll_Agree_Btn 
			C_Click(350, 685)
		}
		else if (GdipImageSearch(x, y, "img/Reroll_OK4_Btn.png", 100, 8, 346, 910, 441, 958)) {
			Guicontrol, , MessageUpdate, Reroll_OK4_Btn 
			C_Click(x, y)
		}	
		else if (GdipImageSearch(x, y, "img/Reroll_OK5_Btn.png", 100, 8, 358, 627, 427, 678)) {
			Guicontrol, , MessageUpdate, Reroll_OK5_Btn 
			C_Click(x, y)
		}	
		else if (GdipImageSearch(x, y, "img/Reroll_OK6_Btn.png", 100, 8, 358, 627, 427, 678)) {
			Guicontrol, , MessageUpdate, Reroll_OK6_Btn 
			C_Click(x, y)
		}	
		else if (GdipImageSearch(x, y, "img/Reroll_OK6_Btn.png", 100, 8, 225, 910, 317, 959)) {
			Guicontrol, , MessageUpdate, Reroll_OK6_Btn 
			C_Click(x, y)
		}	
		else if (GdipImageSearch(x, y, "img/Reroll_OK6_Btn.png", 100, 8, 225, 910, 317, 959)) {
			Guicontrol, , MessageUpdate, Reroll_OK6_Btn 
			C_Click(x, y)
		}	
		else if (GdipImageSearch(x, y, "img/Reroll_Start_to_Save1.png", 80, 8, 23, 347, 426, 394)) {
			Guicontrol, , MessageUpdate, Reroll_Start_to_Save1 
			C_Click(255, 627)
			sleep 1000
			Loop, 120
			{
				if (GdipImageSearch(x, y, "img/Reroll_Start_to_SaveOK_2.png", 100, 8, 351, 824, 433, 869)) {
					Guicontrol, , MessageUpdate, Reroll_Start_to_SaveOK_2 
					C_Click(x, y)
					sleep 500
				}	
				else if (GdipImageSearch(x, y, "img/Reroll_Start_to_Save3.png", 100, 8, 188, 493, 356, 529)) {
					Guicontrol, , MessageUpdate, Reroll_Start_to_Save3 
					C_Click(x, y)
					sleep 500
				}	
				else if (GdipImageSearch(x, y, "img/Reroll_Start_to_Save4.png", 100, 8, 127, 304, 416, 350)) {
					Guicontrol, , MessageUpdate, Reroll_Start_to_Save4 
					C_Click(271, 692)
					sleep 500
				}	
				else if (GdipImageSearch(x, y, "img/Reroll_Start_to_Save5.png", 100, 8, 116, 571, 425, 621)) {
					Guicontrol, , MessageUpdate, Reroll_Start_to_Save5 
					C_Click(271, 590)
					sleep 500
				}	
				else if (GdipImageSearch(x, y, "img/Reroll_Start_to_Save6.png", 100, 8, 174, 553, 367, 596)) {
					Guicontrol, , MessageUpdate, Reroll_Start_to_Save6 
					C_Click(125, 381)
					sleep 200
					C_Click(125, 381)
					sleep 300
					Guicontrolget, ReRoll_Password
					sleep 100
					RunWait, dnconsole.exe action --index %emulatoradb% --key call.input --value %ReRoll_Password%, %ldplayer%, Hide
					sleep 1000
					C_Click(125, 441)
					sleep 200
					C_Click(125, 441)
					sleep 1000
					RunWait, dnconsole.exe action --index %emulatoradb% --key call.input --value %ReRoll_Password%, %ldplayer%, Hide
					sleep 1000
					C_Click(61, 620)
					sleep 1000
					C_Click(220, 720)
					sleep 3000
					Capture(22, 277, 508, 745) 
					sleep 2000
					KillGame()
					break
				}	
				else if (GdipImageSearch(x, y, "img/Reroll_Start_to_Save7.png", 100, 8, 127, 184, 257, 230)) {
					Guicontrol, , MessageUpdate, Reroll_Start_to_Save7 
					C_Click(30, 947)
				}
				sleep 1000
			}
		}	
			
		
		
		
	} ;////////自動刷首抽結束///////
	


	;//////檢查共用////////
	if (GdipImageSearch(x, y, "img/Start_Game.png", 100, 8, 57, 98, 103, 149)) {
		Guicontrol, , MessageUpdate, Start_Game 
		RunGame()
	}
	else if (!(ReRoll) and GdipImageSearch(x, y, "img/Start_Game_AutoLogin.png", 100, 8, 187, 150, 253, 212)) {
		Random, x, 52, 476
		Random, y, 204, 814
		Guicontrol, , MessageUpdate, Start_Game Click x%x% y%y%
		C_Click(x, y)
	}
	else if (GdipImageSearch(x, y, "img/SystemMessage_Level_Up.png", 100, 8, 188, 448, 359, 495)) {
		Guicontrol, , MessageUpdate, SystemMessage_Level_Up Click x%x% y%y%
		C_Click(x, y)
	}
	else if (GdipImageSearch(x, y, "img/Game_Disconnected.png", 100, 8, 65, 396, 477, 447)) {
		Guicontrol, , MessageUpdate, Game_Disconnected
		C_Click(268, 648)
	}
	else if (GdipImageSearch(x, y, "img/Game_Reconnected.png", 100, 8, 125, 385, 418, 433)) {
		Guicontrol, , MessageUpdate, Game_Reconnected
		C_Click(386, 656)
	}
	else if (GdipImageSearch(x, y, "img/SystemMessage_Center_OK_Btn.png", 100, 8, 227, 500, 317, 900)) {
		Guicontrol, , MessageUpdate, SystemMessage_Center_OK_Btn Click x%x% y%y%
		C_Click(x, y)
	}
	else if (GdipImageSearch(x, y, "img/SystemMessage_At_Stage_CloseUI.png", 100, 8, 460, 53, 508, 107)) {
		Guicontrol, , MessageUpdate, SystemMessage_At_Stage_CloseUI Click x%x% y%y%
		C_Click(x, y)
	}
	else if (GdipImageSearch(x, y, "img/SystemMessage_Message_Confrim_Btn.png", 100, 8, 310, 550, 480, 780)) {
		Guicontrol, , MessageUpdate, SystemMessage_Message_Confrim_Btn Click x%x% y%y%
		C_Click(x, y)
	}
	else if (GdipImageSearch(x, y, "img/SystemMessage_Message_Confrim_Btn.png", 100, 8, 310, 550, 480, 780)) {
		Guicontrol, , MessageUpdate, SystemMessage_Message_Confrim_Btn Click x%x% y%y%
		C_Click(x, y)
	}
	else if (GdipImageSearch(x, y, "img/SystemMessage_LoginBonus.png", 80, 8, 181, 569, 369, 610)) {
		Guicontrol, , MessageUpdate, SystemMessage_LoginBonus Click x%x% y%y%
		C_Click(x, y)
		sleep 5000
		C_Click(269, 918)
	}
	else if (GdipImageSearch(x, y, "img/SystemMessage_Appcrush.png", 60, 8, 142, 546, 361, 596)) {
		Guicontrol, , MessageUpdate, SystemMessage_Appcrush Click x%x% y%y%
		C_Click(x, y)
	}
	else if (GdipImageSearch(x, y, "img/SystemMessage_Appcrush2.png", 50, 8, 143, 546, 315, 596)) {
		Guicontrol, , MessageUpdate, SystemMessage_Appcrush Click x%x% y%y%
		C_Click(x, y)
	}
	
	
	

	
	;///////檢查共用結束//////
	
	
	if (AutoCheck_Vpn) ;開始檢查VPN有無斷線
	{
		if (GdipImageSearch(x, y, "img/CheckVpn_disconnected.png", 100, 8, 163, 580, 382, 681)) ;VPN斷線
		{
			Guicontrol, , MessageUpdate, CheckVpn_disconnected
			KillGame()
			sleep 500
			ResetVPN()
			sleep 3000
			RunGame()
		} 
	} ;/////////////////檢查VPN結束
	
	
	
	
	;///////////等待循環時間/////////////
	if (ReRoll) {
		sleep 1200
	}
	else if (MultiPlayer_Mission_Open and AutoShutDownAt_Stage)
	{
		sleep 800
	}
	else if (AutoClick) {
		sleep 800
	} 
	else
	{
		sleep 2000
	}
	
	
	;///////////等待循環時間結束/////////////
	
	;////////沒有找到任何東西/////
	Guicontrol, , MessageUpdate, Waiting...
	; RobotMan
}
return

ForEmulator:
ForEmulator()
return

Autoaddfriend:
if toggle!=toggle
{
	Loop
	{
		C_Click(362, 110)
		sleep 1000
		Loop, 4
		{
			Swipe(352, 726, 352, 300, 150)
			sleep 400
		}
		C_Click(371, 766)
		sleep 1500
		C_Click(491, 139)
		sleep 1500
		C_Click(42, 945)
		sleep 4000
	}
}
return



C_Click(x, y)
{
	;~ msgbox click x%x% y%y%
	if (MobileMode)
	{
		x := Ceil(Mobile_X/Windwos_W*x)
		y := Ceil(Mobile_Y/Windows_H*y)
		random , x, x-2 , x + 3 ;隨機偏移 避免偵測
		random , y, y-2 , y + 3
		sleep 100
		runwait,  adb.exe -s %mobileadb% shell input tap %x% %y% ,, hide
		sleep 200
	}
	else
	{
		random , x, x-2 , x + 3 ;隨機偏移 避免偵測
		random , y, y-2 , y + 3
		ControlClick, x%x% y%y%, ahk_id %UniqueID%,,, , NA 
		sleep 500
	}
}

GdipImageSearch(byref x, byref y, imagePath = "img/picturehere.png",  Variation=100, direction = 1, x1=0, y1=0, x2=0, y2=0) 
{
    pBitmap := Gdip_BitmapFromHWND(UniqueID)
    LIST = 0
    bmpNeedle := Gdip_CreateBitmapFromFile(imagePath)
	if (MobileMode)
	{
		Variation := Variation+8
	}
    RET := Gdip_ImageSearch(pBitmap, bmpNeedle, LIST, x1, y1, x2, y2, Variation, , direction, 1)
    Gdip_DisposeImage(bmpNeedle)
    Gdip_DisposeImage(pBitmap)
    LISTArray := StrSplit(LIST, ",")
    x := LISTArray[1]
    y := LISTArray[2]
	sleep 35
    return List
}

Swipe(x1,y1,x2,y2,swipetime="")
{
	runwait,  ld.exe -s %emulatoradb% input swipe %x1% %y1% %x2% %y2% %swipetime%,%ldplayer%, Hide
	sleep 200
}

Capture(x1, y1, x2, y2) 
{
FileCreateDir, capture
x2 := x2-x1, y2 := y2-y1
formattime, nowtime,,yyyy.MM.dd_HH.mm.ss
pBitmap := Gdip_BitmapFromHWND(UniqueID)
pBitmap_part := Gdip_CloneBitmapArea(pBitmap, x1, y1, x2, y2)
Gdip_SaveBitmapToFile(pBitmap_part, "capture/" . title . "_" . nowtime . ".jpg", 100)
Gdip_DisposeImage(pBitmap)
Gdip_DisposeImage(pBitmap_part)
}

RunGame()
{
	runwait, dnconsole.exe runapp --index %emulatoradb% --packagename air.jp.co.cygames.worldflipper, %ldplayer%, Hide ;關閉遊戲
}

KillGame()
{
	runwait, dnconsole.exe killapp --index %emulatoradb% --packagename air.jp.co.cygames.worldflipper, %ldplayer%, Hide ;關閉遊戲
}

ForEmulator()
{
	IfWinExist %title%
	{
		MsgBox, 16, 錯誤, 請先關閉模擬器
		return
	}
	runwait, dnconsole.exe downcpu --index %emulatoradb% --rate 50, %ldplayer%, Hide 
	runwait, dnconsole.exe globalsetting --fps 60   --fastplay 1 --cleanmode 1, %ldplayer%, Hide
	MsgBox, 0, 完成, 完成
}


Rebootemulator()
{
	runwait, dnconsole.exe reboot  --index %emulatoradb%, %ldplayer%, Hide ;重啟模擬器
	Loop
	{
		sleep 1000
		IfWinExist %title%
			break
	}
}

ResetVPN()
{
	if (OpenVpn)
	{
		runwait, dnconsole.exe killapp --index %emulatoradb% --packagename net.openvpn.openvpn, %ldplayer%, Hide ;Open VPN 3.07
		runwait, dnconsole.exe killapp --index %emulatoradb% --packagename net.openvpn.openvpn, %ldplayer%, Hide ;Open VPN 3.10
		sleep 3000
		runwait, dnconsole.exe runapp --index %emulatoradb% --packagename net.openvpn.openvpn, %ldplayer%, Hide ;Open VPN 3.07
		runwait, dnconsole.exe runapp --index %emulatoradb% --packagename net.openvpn.openvpn, %ldplayer%, Hide ;Open VPN 3.10
		sleep 3000
		Loop
		{
			if (GdipImageSearch(x, y, "img/CheckVpn_OpenVpn.png", 1, 8, 35, 299, 125, 338))
			{
				C_Click(x, y)
			}
			if (GdipImageSearch(x, y, "img/CheckVpn_Is_Connected.png", 100, 8, 45, 280, 120, 360))
			{
				sleep 1000
				C_Click(551, 907)
				sleep 1000
				break
			}
			sleep 1000
		}
	}
	else if (WangVpn)
	{
		runwait, dnconsole.exe killapp --index %emulatoradb% --packagename com.findtheway, %ldplayer%, Hide
		sleep 3000
		runwait, dnconsole.exe runapp --index %emulatoradb% --packagename com.findtheway, %ldplayer%, Hide
		sleep 3000
		Loop
		{
			if (GdipImageSearch(x, y, "img/WangVpn_I_See.png", 50, 8, 368, 902, 481, 954))
			{
				sleep 500
				C_Click(395, 920)
				sleep 500
			}
			if (GdipImageSearch(x, y, "img/WangVpn_SelectVpn.png", 50, 8, 65, 484, 252, 539))
			{
				C_Click(234, 576) ;展開VPN列表
				sleep 1200
				C_Click(64, 760) ;選第二個日本
				sleep 1200
				C_Click(363, 575) ;關閉NPV列表
				sleep 1200
				Swipe(373, 851, 373, 751, 1000) ;往下滑動
				sleep 1200
				C_Click(392, 860) ;永久
				sleep 1200
				C_Click(269, 234) ;連線
				sleep 8000 ;等廣告
				C_Click(554, 910) ;回到桌面
				break	
			}
			sleep 1000
		}
	}
}

AutoJoinRoom(RoomNum)
{
	if (RoomNum is Number)
	{
		Loop, parse, RoomNum,
		{
			TheNumber=%A_LoopField%
			if TheNumber=1
				C_Click(122, 395)
			else if TheNumber=2
				C_Click(264, 395)
			else if TheNumber=3
				C_Click(395, 395)
			else if TheNumber=4
				C_Click(122, 476)
			else if TheNumber=5
				C_Click(264, 476)
			else if TheNumber=6
				C_Click(395, 476)
			else if TheNumber=7
				C_Click(122, 569)
			else if TheNumber=8
				C_Click(264, 569)
			else if TheNumber=9
				C_Click(395, 569)
			else if TheNumber=0
				C_Click(122, 638)
		}
	}
}


