/* Free to use, Free for life.
	Made by panex0845 
*/ 
Version := 1001
VersionUrl := "https://raw.githubusercontent.com/panex0845/AzurLane/master/ChangeLog.md"
;@Ahk2Exe-SetName AzurLane Helper
;@Ahk2Exe-SetDescription AzurLane Helper
;@Ahk2Exe-SetVersion 1.0.0.1
;@Ahk2Exe-SetMainIcon img\01.ico

if not A_IsAdmin { ;強制用管理員開啟
Run *RunAs "%A_ScriptFullPath%"
Exitapp
}
if FileExist("ChangeLog.md") {
	FileMove, ChangeLog.md, ChangeLog.txt, 1
}

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Persistent
#SingleInstance, force
#include Gdip.dll
#include Textfiles.dll
If !pToken := Gdip_Startup() {
   MsgBox "Gdiplus failed to start. Please ensure you have gdiplus on your system"
   ExitApp
}
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
Menu, tray, add, 檢查更新, IsUpdate2
Menu, tray, add,  , 
Menu, Tray, Default, &顯示介面
Menu, tray, add, 結束, Exitsub
Menu, Tray, Icon , img\01.ico,,, 1
Gui, font, s11 Q0, 新細明體

RegRead, ldplayer, HKEY_CURRENT_USER, Software\Changzhi\dnplayer-tw, InstallDir ; Ldplayer 3.76以下版本
if (ldplayer="") {
	RegRead, ldplayer, HKEY_CURRENT_USER, Software\Changzhi\LDPlayer, InstallDir ; Ldplayer 3.77以上版本
	if (ldplayer="") {
		RegRead, ldplayer, HKEY_CURRENT_USER, Software\XuanZhi\LDPlayer, InstallDir ; Ldplayer 4.0+ version
		if (ldplayer="") {
			MsgBox, 16, 設定精靈, 未能偵測到雷電模擬器的安裝路徑，請嘗試：`n`n1. 重新安裝模擬器。`n`n2. 手動指定路徑： Win+R → Regedit `n　HKEY_CURRENT_USER, Software\Changzhi\LDPlayer `n　底下新增 InstallDir
			MsgBox 0x21, 設定精靈, 未能找到到雷電模擬器路徑，是否繼續設定？
			IfMsgBox OK, {
				;////do notthing////////
			} Else IfMsgBox Cancel, {
				ExitApp
			}
		} else {
			MsgBox, 16, 設定精靈, 雷電模擬器4.0僅供測試使用，`n`n如遇到任何問題，建議更換3.x版本。
		}
	}
}
Global ldplayer

Gui Add, Text,  x15 y20 w100 h20 , 模擬器標題：
IniRead, title, settings.ini, emulator, title, 
Global title
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
Run, %comspec% /c powercfg /change /monitor-timeout-ac 0,, Hide ;關閉螢幕省電模式
iniread, SetGuiBGcolor, settings.ini, OtherSub, SetGuiBGcolor, 0
IniRead, SetGuiBGcolor2, settings.ini, OtherSub, SetGuiBGcolor2, FFD2D2
if (SetGuiBGcolor) {
	Gui, Color, %SetGuiBGcolor2%
} else {
	Gui, Color, F0F0F0 
}
Gui Add, Edit, x110 y17 w100 h21 vtitle ginisettings , %title%
Gui Add, Text,  x220 y20 w80 h20 , 代號：
IniRead, emulatoradb, settings.ini, emulator, emulatoradb, 0
Gui, Add, DropDownList, x270 y15 w40 h300 vemulatoradb ginisettings Choose%emulatoradb%, 1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|0||
GuicontrolGet, emulatoradb
;~ Gui Add, Text,  x330 y20 w80 h20 , 容許誤差：
;~ IniRead, AllowanceValue, settings.ini, emulator, AllowanceValue, 2000
;~ Gui Add, Edit, x410 y17 w50 h21 vAllowanceValue ginisettings  readonly Number Limit4, %AllowanceValue%
Gui, Add, Button, x20 y470 w100 h20 gstart vstart , 開始
Gui, Add, Button, x140 y470 w100 h20 greload vreload, 停止
Gui, Add, Button, x260 y470 w100 h20 gReAnchorSub vReAnchorSub, 再次出擊
Gui, Add, Button, x510 y470 w100 h20 gReSizeWindowSub vReSizeWindowSub, 調整視窗
Guicontrol, disable, start


Gui, Add, button, x810 y470 w100 h20 gexitsub, 結束 
Gui, Add, text, x513 y20 w400 h20 vstarttext, 
AnchorFailedTimes := 0
Gui, Add, text, x513 y50 w400 h20 vAnchorTimesText, 出擊次數：0 次 ｜ 全軍覆沒：%AnchorFailedTimes% 次 ｜ 翻船機率： 0`%
;~ Gui, Add, text, x640 y50 w320 h20 vAnchorFailedText, ; 統計 全軍覆沒：%AnchorFailedTimes%  次 ｜ 翻船機率： %rate%`%
Gui, Add, ListBox, x510 y74 w400 h393 ReadOnly vListBoxLog
;~ Gui, Add, Picture, x480 y450 0x4000000 ,img\WH.png

Gui,Add,Tab3, x10 y50 w490 h405 gTabFunc, 出　擊|出擊２|出擊３|學　院|後　宅|科　研|任　務|其　他
;///////////////////     GUI Right Side  Start  ///////////////////

Gui, Tab, 出　擊
Tab1_Y := 90
iniread, AnchorSub, settings.ini, Battle, AnchorSub
Gui, Add, CheckBox, x30 y%Tab1_Y% w150 h20 gAnchorsettings vAnchorSub checked%AnchorSub% +c4400FF, 啟動自動出擊
Tab1_Y += 30
Gui, Add, text, x30 y%Tab1_Y% w80 h20  , 選擇地圖：
Tab1_Y -= 5
iniread, AnchorMode, settings.ini, Battle, AnchorMode, 普通
if AnchorMode=普通
	Gui, Add, DropDownList, x110 y%Tab1_Y% w60 h100 vAnchorMode gAnchorsettings, 普通||困難|停用|
else if AnchorMode=困難
	Gui, Add, DropDownList, x110 y%Tab1_Y% w60 h100 vAnchorMode gAnchorsettings, 普通|困難||停用|
else if AnchorMode=停用
	Gui, Add, DropDownList, x110 y%Tab1_Y% w60 h100 vAnchorMode gAnchorsettings, 普通|困難|停用||

iniread, CH_AnchorChapter, settings.ini, Battle, CH_AnchorChapter,1
iniread, AnchorChapter2, settings.ini, Battle, AnchorChapter2
Tab1_Y += 5
Gui, Add, text, x180 y%Tab1_Y% w20 h20  , 第
Tab1_Y -= 5

AnchorChapterList = 1|2|3|4|5|6|7|8|紅染1|紅染2|S.P.|異色1|異色2|
StringReplace, AnchorChapterListSR, AnchorChapterList,%CH_AnchorChapter%,%CH_AnchorChapter%|
Gui, Add, DropDownList,  x200 y%Tab1_Y% w60 gAnchorsettings vAnchorChapter, %AnchorChapterListSR%

Tab1_Y += 5
Gui, Add, text, x270 y%Tab1_Y% w40 h20  , 章 第
Gui, Add, DropDownList, x310 y115 w40 h100 vAnchorChapter2 gAnchorsettings Choose%AnchorChapter2% , 1||2|3|4|
Gui, Add, text, x360 y%Tab1_Y% w20 h20  , 節


Tab1_Y += 35
Gui, Add, text, x30 y%Tab1_Y% w80 h20  , 出擊艦隊：
Tab1_Y -= 5
iniread, ChooseParty1, settings.ini, Battle, ChooseParty1, 第一艦隊
if ChooseParty1=第一艦隊
	Gui, Add, DropDownList, x110 y%Tab1_Y% w90 h150 vChooseParty1 gAnchorsettings, 第一艦隊||第二艦隊|第三艦隊|第四艦隊|第五艦隊|第六艦隊|
else if ChooseParty1=第二艦隊
	Gui, Add, DropDownList, x110 y%Tab1_Y% w90 h150 vChooseParty1 gAnchorsettings, 第一艦隊|第二艦隊||第三艦隊|第四艦隊|第五艦隊|第六艦隊|
else if ChooseParty1=第三艦隊
	Gui, Add, DropDownList, x110 y%Tab1_Y% w90 h150 vChooseParty1 gAnchorsettings, 第一艦隊|第二艦隊|第三艦隊||第四艦隊|第五艦隊|第六艦隊|
else if ChooseParty1=第四艦隊
	Gui, Add, DropDownList, x110 y%Tab1_Y% w90 h150 vChooseParty1 gAnchorsettings, 第一艦隊|第二艦隊|第三艦隊|第四艦隊||第五艦隊|第六艦隊|
else if ChooseParty1=第五艦隊
	Gui, Add, DropDownList, x110 y%Tab1_Y% w90 h150 vChooseParty1 gAnchorsettings, 第一艦隊|第二艦隊|第三艦隊|第四艦隊|第五艦隊||第六艦隊|
else if ChooseParty1=第六艦隊
	Gui, Add, DropDownList, x110 y%Tab1_Y% w90 h150 vChooseParty1 gAnchorsettings, 第一艦隊|第二艦隊|第三艦隊|第四艦隊|第五艦隊|第六艦隊||
Tab1_Y += 5
Gui, Add, text, x210 y%Tab1_Y% w15 h20  , 、
Tab1_Y -= 5
iniread, ChooseParty2, settings.ini, Battle, ChooseParty2, 不使用
if ChooseParty2=不使用
	Gui, Add, DropDownList, x230 y%Tab1_Y% w90 h150 vChooseParty2 gAnchorsettings, 第一艦隊|第二艦隊|第三艦隊|第四艦隊|第五艦隊|第六艦隊|不使用||
else if ChooseParty2=第一艦隊
	Gui, Add, DropDownList, x230 y%Tab1_Y% w90 h150 vChooseParty2 gAnchorsettings, 第一艦隊||第二艦隊|第三艦隊|第四艦隊|第五艦隊|第六艦隊|不使用|
else if ChooseParty2=第二艦隊
	Gui, Add, DropDownList, x230 y%Tab1_Y% w90 h150 vChooseParty2 gAnchorsettings, 第一艦隊|第二艦隊||第三艦隊|第四艦隊|第五艦隊|第六艦隊|不使用|
else if ChooseParty2=第三艦隊
	Gui, Add, DropDownList, x230 y%Tab1_Y% w90 h150 vChooseParty2 gAnchorsettings, 第一艦隊|第二艦隊|第三艦隊||第四艦隊|第五艦隊|第六艦隊|不使用|
else if ChooseParty2=第四艦隊
	Gui, Add, DropDownList, x230 y%Tab1_Y% w90 h150 vChooseParty2 gAnchorsettings, 第一艦隊|第二艦隊|第三艦隊|第四艦隊||第五艦隊|第六艦隊|不使用|
else if ChooseParty2=第五艦隊
	Gui, Add, DropDownList, x230 y%Tab1_Y% w90 h150 vChooseParty2 gAnchorsettings, 第一艦隊|第二艦隊|第三艦隊|第四艦隊|第五艦隊||第六艦隊|不使用|
else if ChooseParty2=第六艦隊
	Gui, Add, DropDownList, x230 y%Tab1_Y% w90 h150 vChooseParty2 gAnchorsettings, 第一艦隊|第二艦隊|第三艦隊|第四艦隊|第五艦隊|第六艦隊||不使用|

Tab1_Y += 32
iniread, SwitchPartyAtFirstTime, settings.ini, Battle, SwitchPartyAtFirstTime
Gui, Add, CheckBox, x110 y%Tab1_Y% w190 h20 gAnchorsettings vSwitchPartyAtFirstTime checked%SwitchPartyAtFirstTime% , 進入地圖時交換隊伍順序
iniread, WeekMode, settings.ini, Battle, WeekMode
Gui, Add, CheckBox, x310 y%Tab1_Y% w80 h20 gAnchorsettings vWeekMode checked%WeekMode% , 周回模式

Tab1_Y += 33
Gui, Add, text, x30 y%Tab1_Y% w80 h20  , 偵查目標：
Tab1_Y -= 3 ;  Y = 207
iniread, Ship_Target1, settings.ini, Battle, Ship_Target1, 1
iniread, Ship_Target2, settings.ini, Battle, Ship_Target2, 1
iniread, Ship_Target3, settings.ini, Battle, Ship_Target3, 1
iniread, Ship_Target4, settings.ini, Battle, Ship_Target4, 1
iniread, Item_Bullet, settings.ini, Battle, Item_Bullet, 1
iniread, Item_Quest, settings.ini, Battle, Item_Quest, 1
iniread, Plane_Target1, settings.ini, Battle, Plane_Target1, 0
Gui, Add, CheckBox, x110 y%Tab1_Y% w80 h20 gAnchorsettings vShip_Target1 checked%Ship_Target1% , 航空艦隊
Gui, Add, CheckBox, x195 y%Tab1_Y% w80 h20 gAnchorsettings vShip_Target2 checked%Ship_Target2% , 運輸艦隊
Gui, Add, CheckBox, x280 y%Tab1_Y% w80 h20 gAnchorsettings vShip_Target3 checked%Ship_Target3% , 主力艦隊
Gui, Add, CheckBox, x365 y%Tab1_Y% w80 h20 gAnchorsettings vShip_Target4 checked%Ship_Target4% , 偵查艦隊
Tab1_Y += 25
Gui, Add, CheckBox, x110 y%Tab1_Y% w80 h20 gAnchorsettings vItem_Bullet checked%Item_Bullet% , 子彈補給
Gui, Add, CheckBox, x195 y%Tab1_Y% w80 h20 gAnchorsettings vItem_Quest checked%Item_Quest% , 神秘物資
Gui, Add, CheckBox, x280 y%Tab1_Y% w80 h20 gAnchorsettings vPlane_Target1 checked%Plane_Target1% , 航空器

Tab1_Y += 33
Gui, Add, text, x30 y%Tab1_Y% w80 h20  , 受到伏擊：
iniread, Assault, settings.ini, Battle, Assault, 規避
Tab1_Y -= 5
if Assault=規避
	Gui, Add, DropDownList, x110 y%Tab1_Y% w60 h100 vAssault gAnchorsettings, 規避||迎擊|
else if Assault=迎擊
	Gui, Add, DropDownList, x110 y%Tab1_Y% w60 h100 vAssault gAnchorsettings, 規避|迎擊||

Tab1_Y += 5
Gui, Add, text, x185 y%Tab1_Y% w80 h20  , 自律模式：
Tab1_Y -= 5
iniread, Autobattle, settings.ini, Battle, Autobattle, 自動
if Autobattle=自動
	Gui, Add, DropDownList, x265 y%Tab1_Y% w80 h100 vAutobattle gAnchorsettings, 自動||半自動|關閉|
else if Autobattle=半自動
	Gui, Add, DropDownList, x265 y%Tab1_Y% w80 h100 vAutobattle gAnchorsettings, 自動|半自動||關閉|
else if Autobattle=關閉
	Gui, Add, DropDownList, x265 y%Tab1_Y% w80 h100 vAutobattle gAnchorsettings, 自動|半自動|關閉||

Tab1_Y += 35
Gui, Add, text, x30 y%Tab1_Y% w80 h20  , 遇到BOSS：
Tab1_Y -= 5
iniread, BossAction, settings.ini, Battle, BossAction, 隨緣攻擊－當前隊伍
if BossAction=隨緣攻擊－當前隊伍
	Gui, Add, DropDownList, x110 y%Tab1_Y% w150 h150 vBossAction gAnchorsettings, 隨緣攻擊－當前隊伍||隨緣攻擊－切換隊伍|優先攻擊－當前隊伍|優先攻擊－切換隊伍|能不攻擊就不攻擊|撤退|
else if BossAction=隨緣攻擊－切換隊伍
	Gui, Add, DropDownList, x110 y%Tab1_Y% w150 h150 vBossAction gAnchorsettings, 隨緣攻擊－當前隊伍|隨緣攻擊－切換隊伍||優先攻擊－當前隊伍|優先攻擊－切換隊伍|能不攻擊就不攻擊|撤退|
else if BossAction=優先攻擊－當前隊伍
	Gui, Add, DropDownList, x110 y%Tab1_Y% w150 h150 vBossAction gAnchorsettings, 隨緣攻擊－當前隊伍|隨緣攻擊－切換隊伍|優先攻擊－當前隊伍||優先攻擊－切換隊伍|能不攻擊就不攻擊|撤退|
else if BossAction=優先攻擊－切換隊伍
	Gui, Add, DropDownList, x110 y%Tab1_Y% w150 h150 vBossAction gAnchorsettings, 隨緣攻擊－當前隊伍|隨緣攻擊－切換隊伍|優先攻擊－當前隊伍|優先攻擊－切換隊伍||能不攻擊就不攻擊|撤退|
else if BossAction=能不攻擊就不攻擊
	Gui, Add, DropDownList, x110 y%Tab1_Y% w150 h150 vBossAction gAnchorsettings, 隨緣攻擊－當前隊伍|隨緣攻擊－切換隊伍|優先攻擊－當前隊伍|優先攻擊－切換隊伍|能不攻擊就不攻擊||撤退|
else if BossAction=撤退
	Gui, Add, DropDownList, x110 y%Tab1_Y% w150 h150 vBossAction gAnchorsettings, 隨緣攻擊－當前隊伍|隨緣攻擊－切換隊伍|優先攻擊－當前隊伍|優先攻擊－切換隊伍|能不攻擊就不攻擊|撤退||

Tab1_Y += 35
Gui, Add, text, x30 y%Tab1_Y% w140 h20  , 心情低落：
Tab1_Y -= 5
iniread, mood, settings.ini, Battle, mood, 強制出戰
if mood=強制出戰
	Gui, Add, DropDownList, x110 y%Tab1_Y% w90 h150 vmood gAnchorsettings, 強制出戰||不再出擊|休息1小時|休息2小時|休息3小時|休息5小時|
else if mood=不再出擊
	Gui, Add, DropDownList, x110 y%Tab1_Y% w90 h150 vmood gAnchorsettings, 強制出戰|不再出擊||休息1小時|休息2小時|休息3小時|休息5小時|
else if mood=休息1小時
	Gui, Add, DropDownList, x110 y%Tab1_Y% w90 h150 vmood gAnchorsettings, 強制出戰|不再出擊|休息1小時||休息2小時|休息3小時|休息5小時|
else if mood=休息2小時
	Gui, Add, DropDownList, x110 y%Tab1_Y% w90 h150 vmood gAnchorsettings, 強制出戰|不再出擊|休息1小時|休息2小時||休息3小時|休息5小時|
else if mood=休息3小時
	Gui, Add, DropDownList, x110 y%Tab1_Y% w90 h150 vmood gAnchorsettings, 強制出戰|不再出擊|休息1小時|休息2小時|休息3小時||休息5小時|
else if mood=休息5小時
	Gui, Add, DropDownList, x110 y%Tab1_Y% w90 h150 vmood gAnchorsettings, 強制出戰|不再出擊|休息1小時|休息2小時|休息3小時|休息5小時||
else
	Gui, Add, DropDownList, x110 y%Tab1_Y% w90 h150 vmood gAnchorsettings, 強制出戰||不再出擊|休息1小時|休息2小時|休息3小時|休息5小時|

Tab1_Y += 35
iniread, Use_FixKit, settings.ini, Battle, Use_FixKit
iniread, AlignCenter, settings.ini, Battle, AlignCenter
Gui, Add, CheckBox, x30 y%Tab1_Y% w120 h20 gAnchorsettings vUse_FixKit checked%Use_FixKit% , 使用維修工具
Gui, Add, CheckBox, x160 y%Tab1_Y% w160 h20 gAnchorsettings vAlignCenter checked%AlignCenter% , 偵查時嘗試置中地圖

Tab1_Y += 28
iniread, BattleTimes, settings.ini, Battle, BattleTimes, 0
Gui, Add, CheckBox, x30 y%Tab1_Y% w50 h20 gAnchorsettings vBattleTimes checked%BattleTimes% , 出擊
IniRead, BattleTimes2, settings.ini, Battle, BattleTimes2, 20
Gui Add, Edit, x82 y%Tab1_Y% w40 h20 vBattleTimes2 gAnchorsettings Number Limit4, %BattleTimes2%
Tab1_Y += 3
Gui Add, Text,  x128 y%Tab1_Y% w90 h20 , 輪，強制休息
Tab1_Y -= 3
IniRead, TimetoBattle, settings.ini, Battle, TimetoBattle, 0
Gui, Add, CheckBox, x230 y%Tab1_Y% w30 h20 gAnchorsettings vTimetoBattle checked%TimetoBattle% , 於 
IniRead, TimetoBattle1, settings.ini, Battle, TimetoBattle1, 1302
IniRead, TimetoBattle2, settings.ini, Battle, TimetoBattle2, 0102
Gui Add, Edit, x270 y%Tab1_Y% w40 h20 vTimetoBattle1 gAnchorsettings Number Limit4, %TimetoBattle1% ;指定的重新出擊時間 (24小時制)
Gui Add, Edit, x320 y%Tab1_Y% w40 h20 vTimetoBattle2 gAnchorsettings Number Limit4, %TimetoBattle2% ;指定的重新出擊時間(24小時制)
Tab1_Y += 3
Gui Add, Text,  x370 y%Tab1_Y% w90 h20 , 時，重新出擊
Tab1_Y += 25
iniread, StopBattleTime, settings.ini, Battle, StopBattleTime, 0
Gui, Add, CheckBox, x30 y%Tab1_Y% w70 h20 vStopBattleTime gAnchorsettings checked%StopBattleTime% , 每出擊
Tab1_Y -= 2
iniread, StopBattleTime2, settings.ini, Battle, StopBattleTime2, 5
Gui, Add, DropDownList, x100 y%Tab1_Y% w40 h300 vStopBattleTime2 gAnchorsettings Choose%StopBattleTime2% , 1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|
Tab1_Y += 5
Gui Add, Text,  x150 y%Tab1_Y% w90 h20 , 輪，休息
Tab1_Y -= 5
iniread, StopBattleTime3, settings.ini, Battle, StopBattleTime3, 10
Tab1_Y += 3
Gui, Add, Edit, x220 y%Tab1_Y% w40 h20 vStopBattleTime3 gAnchorsettings Number Limit4, %StopBattleTime3%
Tab1_Y += 3
Gui Add, Text,  x270 y%Tab1_Y% w90 h20 , 分鐘
;~ Gui, Add, CheckBox, x30 y%Tab1_Y% w60 h20  checked%BattleTimes% , TEST

Gui, Tab, 出擊２
Tab2_Y := 90
;~ Gui, Add, text, x30 y%Tab2_Y% w360 h20  +cFF0088, 本頁為出擊頁面的詳細設定，需勾選自動出擊方有效果
;~ Gui, Add, GroupBox, x13 y120 w455 h170, ` 　　　　　　　　　　　　　
Gui, Add, text, x30 y%Tab2_Y% w150 h20, 船䲧已滿：
Tab2_Y-=3
iniread, Shipsfull, settings.ini, Battle, Shipsfull, 停止出擊
if Shipsfull=整理船䲧
	Gui, Add, DropDownList, x110 y%Tab2_Y% w100 h100 vShipsfull gAnchorsettings, 整理船䲧||停止出擊|關閉遊戲|
else if Shipsfull=停止出擊
	Gui, Add, DropDownList, x110 y%Tab2_Y% w100 h100 vShipsfull gAnchorsettings, 整理船䲧|停止出擊||關閉遊戲|
else if Shipsfull=關閉遊戲
	Gui, Add, DropDownList, x110 y%Tab2_Y% w100 h100 vShipsfull gAnchorsettings, 整理船䲧|停止出擊|關閉遊戲||
else
	Gui, Add, DropDownList, x110 y%Tab2_Y% w100 h100 vShipsfull gAnchorsettings, 整理船䲧||停止出擊|關閉遊戲|
Tab2_Y+=3
Gui, Add, text, x220 y%Tab2_Y% w180 h20, 如整理，要退役的角色：
iniread, IndexAll, settings.ini, Battle, IndexAll, 1 ;全部
iniread, Index1, settings.ini, Battle, Index1 ;前排先鋒
iniread, Index2, settings.ini, Battle, Index2 ;後排主力
iniread, Index3, settings.ini, Battle, Index3 ;驅逐
iniread, Index4, settings.ini, Battle, Index4 ;輕巡
iniread, Index5, settings.ini, Battle, Index5 ;重巡
iniread, Index6, settings.ini, Battle, Index6 ;戰列
iniread, Index7, settings.ini, Battle, Index7 ;航母
iniread, Index8, settings.ini, Battle, Index8 ;維修
iniread, Index9, settings.ini, Battle, Index9 ;其他
Tab2_Y+=30
Gui, Add, text, x30 y%Tab2_Y% w50 h20  , 索　引
Tab2_Y-=3
Gui, Add, CheckBox, x80 y%Tab2_Y% w50 h20 gAnchorsettings vIndexAll checked%IndexAll% , 全部
Guicontrol, disable, IndexAll
Gui, Add, CheckBox, x130 y%Tab2_Y% w80 h20 gAnchorsettings vIndex1 checked%Index1% , 前排先鋒
Gui, Add, CheckBox, x210 y%Tab2_Y% w80 h20 gAnchorsettings vIndex2 checked%Index2% , 後排主力
Gui, Add, CheckBox, x290 y%Tab2_Y% w50 h20 gAnchorsettings vIndex3 checked%Index3% , 驅逐
Gui, Add, CheckBox, x340 y%Tab2_Y% w50 h20 gAnchorsettings vIndex4 checked%Index4% , 輕巡
Gui, Add, CheckBox, x390 y%Tab2_Y% w50 h20 gAnchorsettings vIndex5 checked%Index5% , 重巡
Tab2_Y+=30
Gui, Add, CheckBox, x80 y%Tab2_Y% w50 h20 gAnchorsettings vIndex6 checked%Index6% , 戰列
Gui, Add, CheckBox, x130 y%Tab2_Y% w50 h20 gAnchorsettings vIndex7 checked%Index7% , 航母
Gui, Add, CheckBox, x180 y%Tab2_Y% w50 h20 gAnchorsettings vIndex8 checked%Index8% , 維修
Gui, Add, CheckBox, x230 y%Tab2_Y% w50 h20 gAnchorsettings vIndex9 checked%Index9% , 其他

iniread, CampAll, settings.ini, Battle, CampAll, 1 ;全部
iniread, Camp1, settings.ini, Battle, Camp1 ;白鷹
iniread, Camp2, settings.ini, Battle, Camp2 ;皇家
iniread, Camp3, settings.ini, Battle, Camp3 ;重櫻
iniread, Camp4, settings.ini, Battle, Camp4 ;鐵血
iniread, Camp5, settings.ini, Battle, Camp5 ;東煌
iniread, Camp6, settings.ini, Battle, Camp6 ;北方聯合
iniread, Camp7, settings.ini, Battle, Camp7 ;其他
Tab2_Y+=33
Gui, Add, text, x30 y%Tab2_Y% w50 h20  , 陣　營
Tab2_Y-=3
Gui, Add, CheckBox, x80 y%Tab2_Y% w50 h20 gAnchorsettings vCampAll checked%CampAll% , 全部
Guicontrol, disable, CampAll
Gui, Add, CheckBox, x130 y%Tab2_Y% w50 h20 gAnchorsettings vCamp1 checked%Camp1% , 白鷹
Gui, Add, CheckBox, x180 y%Tab2_Y% w50 h20 gAnchorsettings vCamp2 checked%Camp2% , 皇家
Gui, Add, CheckBox, x230 y%Tab2_Y% w50 h20 gAnchorsettings vCamp3 checked%Camp3% , 重櫻
Gui, Add, CheckBox, x280 y%Tab2_Y% w50 h20 gAnchorsettings vCamp4 checked%Camp4% , 鐵血
Gui, Add, CheckBox, x330 y%Tab2_Y% w50 h20 gAnchorsettings vCamp5 checked%Camp5% , 東煌

Gui, Add, CheckBox, x380 y%Tab2_Y% w50 h20 gAnchorsettings vCamp6 checked%Camp6% , 北方
Gui, Add, CheckBox, x430 y%Tab2_Y% w50 h20 gAnchorsettings vCamp7 checked%Camp7% , 其他

iniread, RarityAll, settings.ini, Battle, RarityAll, 1 ;全部
iniread, Rarity1, settings.ini, Battle, Rarity1, 1 ;普通
iniread, Rarity2, settings.ini, Battle, Rarity2, 1 ;稀有
iniread, Rarity3, settings.ini, Battle, Rarity3, 0 ;精銳
iniread, Rarity4, settings.ini, Battle, Rarity4, 0 ;超稀有
Tab2_Y+=33
Gui, Add, text, x30 y%Tab2_Y% w75 h20  , 稀有度：
Tab2_Y-=3
Gui, Add, CheckBox, x80 y%Tab2_Y% w50 h20 gAnchorsettings vRarityAll checked%RarityAll% , 全部
Guicontrol, disable, RarityAll
Gui, Add, CheckBox, x130 y%Tab2_Y% w50 h20 gAnchorsettings vRarity1 checked%Rarity1% , 普通
Gui, Add, CheckBox, x180 y%Tab2_Y% w50 h20 gAnchorsettings vRarity2 checked%Rarity2% , 稀有
Gui, Add, CheckBox, x230 y%Tab2_Y% w50 h20 gAnchorsettings vRarity3 checked%Rarity3% , 精銳
Gui, Add, CheckBox, x280 y%Tab2_Y% w75 h20 gAnchorsettings vRarity4 checked%Rarity4% , 超稀有
Guicontrol, disable, Rarity4

iniread, DailyGoalSub, settings.ini, Battle, DailyGoalSub
;~ Gui, Add, GroupBox, x11 y280 w457 h75, ` 
Tab2_Y+=43 ;270
Gui, Add, CheckBox, x30 y%Tab2_Y% w200 h20 gAnchorsettings vDailyGoalSub checked%DailyGoalSub% , 自動執行每日任務：指派：
Tab2_Y-=2 ;268
iniread, DailyParty, settings.ini, Battle, DailyParty, 第一艦隊
if DailyParty=第一艦隊
	Gui, Add, DropDownList, x240 y%Tab2_Y% w90 h150 vDailyParty gAnchorsettings, 第一艦隊||第二艦隊|第三艦隊|第四艦隊|第五艦隊|
else if DailyParty=第二艦隊
	Gui, Add, DropDownList, x240 y%Tab2_Y% w90 h150 vDailyParty gAnchorsettings, 第一艦隊|第二艦隊||第三艦隊|第四艦隊|第五艦隊|
else if DailyParty=第三艦隊
	Gui, Add, DropDownList, x240 y%Tab2_Y% w90 h150 vDailyParty gAnchorsettings, 第一艦隊|第二艦隊|第三艦隊||第四艦隊|第五艦隊|
else if DailyParty=第四艦隊
	Gui, Add, DropDownList, x240 y%Tab2_Y% w90 h150 vDailyParty gAnchorsettings, 第一艦隊|第二艦隊|第三艦隊|第四艦隊||第五艦隊|
else if DailyParty=第五艦隊
	Gui, Add, DropDownList, x240 y%Tab2_Y% w90 h150 vDailyParty gAnchorsettings, 第一艦隊|第二艦隊|第三艦隊|第四艦隊|第五艦隊||
iniread, DailyGoalRed, settings.ini, Battle, DailyGoalRed, 1
iniread, DailyGoalRedAction, settings.ini, Battle, DailyGoalRedAction
Tab2_Y+=30
Gui, Add, CheckBox, x50 y%Tab2_Y% w110 h20 gAnchorsettings vDailyGoalRed checked%DailyGoalRed% , 斬首行動：第
Tab2_Y-=2
Gui, Add, DropDownList, x160 y%Tab2_Y% w40 h100 vDailyGoalRedAction gAnchorsettings Choose%DailyGoalRedAction% , 1||2|3|4|
Tab2_Y+=5
Gui, Add, text, x210 y%Tab2_Y% w40 h20  , 關。
iniread, DailyGoalGreen, settings.ini, Battle, DailyGoalGreen, 1
iniread, DailyGoalGreenAction, settings.ini, Battle, DailyGoalGreenAction
Tab2_Y+=23
Gui, Add, CheckBox, x50 y%Tab2_Y% w110 h20 gAnchorsettings vDailyGoalGreen checked%DailyGoalGreen% , 海域突進：第
Tab2_Y-=2
Gui, Add, DropDownList, x160 y%Tab2_Y% w40 h100 vDailyGoalGreenAction gAnchorsettings Choose%DailyGoalGreenAction% , 1||2|3|4|
Tab2_Y+=5
Gui, Add, text, x210 y%Tab2_Y% w40 h20  , 關。
iniread, DailyGoalBlue, settings.ini, Battle, DailyGoalBlue, 1
iniread, DailyGoalBlueAction, settings.ini, Battle, DailyGoalBlueAction
Tab2_Y+=23
Gui, Add, CheckBox, x50 y%Tab2_Y% w110 h20 gAnchorsettings vDailyGoalBlue checked%DailyGoalBlue% , 商船護衛：第
Tab2_Y-=2
Gui, Add, DropDownList, x160 y%Tab2_Y% w40 h100 vDailyGoalBlueAction gAnchorsettings Choose%DailyGoalBlueAction% , 1||2|3|4|
Tab2_Y+=5
Gui, Add, text, x210 y%Tab2_Y% w40 h20  , 關。
iniread, DailyGoalSunday, settings.ini, Battle, DailyGoalSunday
Tab2_Y-=29
Gui, Add, CheckBox, x260 y%Tab2_Y% w140 h20 gAnchorsettings vDailyGoalSunday checked%DailyGoalSunday% , 禮拜日三個都打

iniread, OperationSub, settings.ini, Battle, OperationSub
Tab2_Y+=56
Gui, Add, CheckBox, x30 y%Tab2_Y% w230 h20 gAnchorsettings vOperationSub checked%OperationSub% , 自動執行演習，選擇敵方艦隊：
Tab2_Y-=2
iniread, Operationenemy, settings.ini, Battle, Operationenemy, 隨機的
if Operationenemy=隨機的
	Gui, Add, DropDownList, x260 y%Tab2_Y% w70 h150 vOperationenemy gAnchorsettings, 隨機的||最弱的|最左邊|最右邊|
else if Operationenemy=最弱的
	Gui, Add, DropDownList, x260 y%Tab2_Y% w70 h150 vOperationenemy gAnchorsettings, 隨機的|最弱的||最左邊|最右邊|
else if Operationenemy=最左邊
	Gui, Add, DropDownList, x260 y%Tab2_Y% w70 h150 vOperationenemy gAnchorsettings, 隨機的|最弱的|最左邊||最右邊|
else if Operationenemy=最右邊
	Gui, Add, DropDownList, x260 y%Tab2_Y% w70 h150 vOperationenemy gAnchorsettings, 隨機的|最弱的|最左邊|最右邊||
else 
	Gui, Add, DropDownList, x260 y%Tab2_Y% w70 h150 vOperationenemy gAnchorsettings, 隨機的||最弱的|最左邊|最右邊|
Tab2_Y-=2
Gui, Add, button, x355 y%Tab2_Y% w100 h24 gResetOperationSub vResetOperation, 重置演習 

iniread, Leave_Operatio, settings.ini, Battle, Leave_Operatio
Tab2_Y+=30
Gui, Add, CheckBox, x50 y%Tab2_Y% w100 h20 gAnchorsettings vLeave_Operatio checked%Leave_Operatio% , 我方血量＜
IniRead, OperatioMyHpBar, settings.ini, Battle, OperatioMyHpBar, 25
Gui, Add, Slider, x140 y%Tab2_Y% w50 h30 gAnchorsettings vOperatioMyHpBar range20-50 +ToolTip , %OperatioMyHpBar%
Tab2_Y+=2
Gui, Add, Text, x190 y%Tab2_Y% w20 h20 vOperatioMyHpBarUpdate , %OperatioMyHpBar% 
Gui, Add, Text, x210 y%Tab2_Y% w110 h20 vOperatioMyHpBarPercent, `%，敵艦血量＞
Tab2_Y-=2
IniRead, OperatioEnHpBar, settings.ini, Battle, OperatioEnHpBar, 30
Gui, Add, Slider, x310 y%Tab2_Y% w50 h30 gAnchorsettings vOperatioEnHpBar range10-50 +ToolTip , %OperatioEnHpBar%
Tab2_Y+=2
Gui, Add, Text, x360 y%Tab2_Y% w20 h20 vOperatioEnHpBarUpdate , %OperatioEnHpBar% 
Gui, Add, Text, x380 y%Tab2_Y% w80 h20 vOperatioEnHpBarPercent, `%，時撤退

Tab2_Y+=30
IniRead, ResetOperationTime, settings.ini, Battle, ResetOperationTime, 1
IniRead, ResetOperationTime2, settings.ini, Battle, ResetOperationTime2, 1050, 2250
Gui, Add, CheckBox, x50 y%Tab2_Y% w120 h20 gAnchorsettings vResetOperationTime checked%ResetOperationTime% , 自動重置時間
Gui, Add, Edit, x170 y%Tab2_Y% w120 h20 gAnchorsettings vResetOperationTime2 , %ResetOperationTime2%


Gui, Tab, 出擊３
Tab_Y := 90
iniread, FightRoundsDo, settings.ini, Battle, FightRoundsDo, 0
iniread, FightRoundsDo2, settings.ini, Battle, FightRoundsDo2, 或沒子彈
iniread, FightRoundsDo3, settings.ini, Battle, FightRoundsDo3, 更換艦隊Ｂ
Gui, Add, CheckBox, x30 y%Tab_Y% w120 h20 gAnchor3settings vFightRoundsDo checked%FightRoundsDo%, 艦隊Ａ每出擊
Tab_Y -= 2
if FightRoundsDo2=或沒子彈
	Gui, Add, DropDownList, x150 y%Tab_Y% w85 h200 gAnchor3settings vFightRoundsDo2  Choose%FightRoundsDo2%, 1|2|3|4|5|6|7|8|9|10|或沒子彈||
else
	Gui, Add, DropDownList, x150 y%Tab_Y% w85 h200 gAnchor3settings vFightRoundsDo2  Choose%FightRoundsDo2%, 1|2|3|4|5|6|7|8|9|10|或沒子彈|
Tab_Y +=5
Gui, Add, Text, x250 y%Tab_Y% w40 h20 , 次：
Tab_Y -=5
if FightRoundsDo3=更換艦隊Ｂ
	Gui, Add, DropDownList, x290 y%Tab_Y% w100 h200 gAnchor3settings vFightRoundsDo3  Choose%FightRoundsDo3%, 更換艦隊Ｂ||撤退|
else if FightRoundsDo3=撤退
	Gui, Add, DropDownList, x290 y%Tab_Y% w100 h200 gAnchor3settings vFightRoundsDo3  Choose%FightRoundsDo3%, 更換艦隊Ｂ|撤退||
Tab_Y+=30
iniread, Retreat_LowHp, settings.ini, Battle, Retreat_LowHp, 0
Gui, Add, CheckBox, x30 y%Tab_Y% w120 h20 gAnchor3settings vRetreat_LowHp checked%Retreat_LowHp% , 旗艦消耗高於
IniRead, Retreat_LowHpBar, settings.ini, Battle, Retreat_LowHpBar, 30
Gui, Add, Slider, x140 y%Tab_Y% w100 h30 gAnchor3settings vRetreat_LowHpBar range15-90 +ToolTip , %Retreat_LowHpBar%
Tab_Y+=4
Gui, Add, Text, x240 y%Tab_Y% w20 h20 vRetreat_LowHpBarUpdate , %Retreat_LowHpBar% 
Gui, Add, Text, x260 y%Tab_Y% w120 h20 , `% 退出戰鬥，並
Tab_Y-=4
iniread, Retreat_LowHpDo, settings.ini, Battle, Retreat_LowHpDo, 重新來過
if Retreat_LowHpDo=重新來過
	Gui, Add, DropDownList, x375 y%Tab_Y% w85 h200 gAnchor3settings vRetreat_LowHpDo  Choose%Retreat_LowHpDo%, 重新來過||
else
	Gui, Add, DropDownList, x375 y%Tab_Y% w85 h200 gAnchor3settings vRetreat_LowHpDo  Choose%Retreat_LowHpDo%, 重新來過||
Tab_Y+=30
iniread, Stop_LowHp, settings.ini, Battle, Stop_LowHp, 0
iniread, Stop_LowHP_SP, settings.ini, Battle, Stop_LowHP_SP, 0
Gui, Add, CheckBox, x50 y%Tab_Y% w180 h20 gAnchor3settings vStop_LowHp checked%Stop_LowHp% , 討伐BOSS時不退出戰鬥
Gui, Add, CheckBox, x250 y%Tab_Y% w180 h20 gAnchor3settings vStop_LowHP_SP checked%Stop_LowHP_SP% , 更換隊伍後不退出戰鬥

Tab_Y+=30
iniread, Retreat_LowHp2, settings.ini, Battle, Retreat_LowHp2, 0
Gui, Add, CheckBox, x30 y%Tab_Y% w170 h20 gAnchor3settings vRetreat_LowHp2 checked%Retreat_LowHp2% , 戰鬥結束，旗艦HP低於
IniRead, Retreat_LowHp2Bar, settings.ini, Battle, Retreat_LowHp2Bar, 30
Gui, Add, Slider, x200 y%Tab_Y% w100 h30 gAnchor3settings vRetreat_LowHp2Bar range5-90 +ToolTip , %Retreat_LowHp2Bar%
Tab_Y+=4
Gui, Add, Text, x310 y%Tab_Y% w20 h20 vRetreat_LowHp2BarUpdate , %Retreat_Low2HpBar% 
Gui, Add, Text, x330 y%Tab_Y% w120 h20 , `% 
Tab_Y-=4
iniread, Retreat_LowHp2Do, settings.ini, Battle, Retreat_LowHp2Do, 更換隊伍
if Retreat_LowHp2Do=更換隊伍
	Gui, Add, DropDownList, x350 y%Tab_Y% w85 h200 gAnchor3settings vRetreat_LowHp2Do  Choose%Retreat_LowHp2Do%, 更換隊伍||撤退|
else
	Gui, Add, DropDownList, x350 y%Tab_Y% w85 h200 gAnchor3settings vRetreat_LowHp2Do  Choose%Retreat_LowHp2Do%, 更換隊伍|撤退||
Tab_Y+=30
iniread, Take_ItemQuest, settings.ini, Battle, Take_ItemQuest, 0
iniread, Take_ItemQuestNum, settings.ini, Battle, Take_ItemQuestNum, 3
Gui, Add, CheckBox, x30 y%Tab_Y% w120 h20 gAnchor3settings vTake_ItemQuest checked%Take_ItemQuest%, 拾取神秘物資
Tab_Y -= 2
	Gui, Add, DropDownList, x150 y%Tab_Y% w40 h200 gAnchor3settings vTake_ItemQuestNum  Choose%Take_ItemQuestNum%, 1|2|3||4|5|
Tab_Y +=5
Gui, Add, Text, x200 y%Tab_Y% w80 h20 , 次後撤退


Gui, Tab, 學　院
Tab_Y := 90 ;///////////學院///////////////
iniread, AcademySub, settings.ini, Academy, AcademySub, 0
Gui, Add, CheckBox, x30 y%Tab_Y% w150 h20 gAcademysettings vAcademySub checked%AcademySub% +c4400FF, 啟動自動學院
Tab_Y +=30
iniread, AcademyOil, settings.ini, Academy, AcademyOil, 1
Gui, Add, CheckBox, x30 y%Tab_Y% w150 h20 gAcademysettings vAcademyOil checked%AcademyOil%, 採集石油
Tab_Y +=30
iniread, AcademyCoin, settings.ini, Academy, AcademyCoin, 1
Gui, Add, CheckBox, x30 y%Tab_Y% w150 h20 gAcademysettings vAcademyCoin checked%AcademyCoin%, 領取金幣
Tab_Y +=30
iniread, AcademyTactics, settings.ini, Academy, AcademyTactics, 1
Gui, Add, CheckBox, x30 y%Tab_Y% w80 h20 gAcademysettings vAcademyTactics checked%AcademyTactics%, 學習技能
iniread, 150expbookonly, settings.ini, Academy, 150expbookonly, 1
Gui, Add, CheckBox, x120 y%Tab_Y% w200 h20 gAcademysettings v150expbookonly checked%150expbookonly%, 僅使用150`%經驗的課本
Tab_Y +=30
iniread, AcademyShop, settings.ini, Academy, AcademyShop, 1
Gui, Add, CheckBox, x30 y%Tab_Y% w220 h20 gAcademysettings vAcademyShop checked%AcademyShop%, 購買補給商店軍火商`(金幣)
iniread, SkillBook_ATK, settings.ini, Academy, SkillBook_ATK, 1
iniread, SkillBook_DEF, settings.ini, Academy, SkillBook_DEF, 1
iniread, SkillBook_SUP, settings.ini, Academy, SkillBook_SUP, 1
iniread, Cube, settings.ini, Academy, Cube, 1
iniread, Part_Aircraft, settings.ini, Academy, Part_Aircraft, 0
iniread, Part_Cannon, settings.ini, Academy, Part_Cannon, 0
iniread, Part_torpedo, settings.ini, Academy, Part_torpedo, 0
iniread, Part_Anti_Aircraft, settings.ini, Academy, Part_Anti_Aircraft, 0
iniread, Part_Common, settings.ini, Academy, Part_Common, 0
iniread, Item_Equ_Box1, settings.ini, Academy, Item_Equ_Box1, 0
iniread, Item_Water, settings.ini, Academy, Item_Water, 0
iniread, Item_Tempura, settings.ini, Academy, Item_Tempura, 0
Tab_Y +=30
Gui, Add, CheckBox, x50 y%Tab_Y% w80 h20 gAcademysettings vSkillBook_ATK checked%SkillBook_ATK%, 攻擊教材
Gui, Add, CheckBox, x140 y%Tab_Y% w80 h20 gAcademysettings vSkillBook_DEF checked%SkillBook_DEF%, 防禦教材
Gui, Add, CheckBox, x230 y%Tab_Y% w80 h20 gAcademysettings vSkillBook_SUP checked%SkillBook_SUP%, 輔助教材
Gui, Add, CheckBox, x320 y%Tab_Y% w80 h20 gAcademysettings vCube checked%Cube%, 心智魔方
Tab_Y +=30
Gui, Add, CheckBox, x50 y%Tab_Y% w110 h20 gAcademysettings vPart_Aircraft checked%Part_Aircraft%, 艦載機部件T3
Gui, Add, CheckBox, x170 y%Tab_Y% w100 h20 gAcademysettings vPart_Cannon checked%Part_Cannon%, 主砲部件T3
Gui, Add, CheckBox, x270 y%Tab_Y% w100 h20 gAcademysettings vPart_torpedo checked%Part_torpedo%, 魚雷部件T3
Gui, Add, CheckBox, x370 y%Tab_Y% w110 h20 gAcademysettings vPart_Anti_Aircraft checked%Part_Anti_Aircraft%, 防空砲部件T3
Tab_Y +=30
Gui, Add, CheckBox, x50 y%Tab_Y% w110 h20 gAcademysettings vPart_Common checked%Part_Common%, 共通部件T3
Gui, Add, CheckBox, x170 y%Tab_Y% w100 h20 gAcademysettings vItem_Equ_Box1 checked%Item_Equ_Box1%, 外觀裝備箱
Gui, Add, CheckBox, x270 y%Tab_Y% w100 h20 gAcademysettings vItem_Water checked%Item_Water%, 秘製冷卻水
Gui, Add, CheckBox, x370 y%Tab_Y% w80 h20 gAcademysettings vItem_Tempura checked%Item_Tempura%, 天婦羅
Tab_Y +=30
iniread, Item_Ex4_Box, settings.ini, Academy, Item_Ex4_Box, 0
Gui, Add, CheckBox, x50 y%Tab_Y% w120 h20 gAcademysettings vItem_Ex4_Box checked%Item_Ex4_Box%, 科技箱T4`(功勳)

Gui, Tab, 後　宅
Tab_Y :=90 ;////////////後宅//////////////
iniread, DormSub, settings.ini, Dorm, DormSub, 0
Gui, Add, CheckBox, x30 y%Tab_Y% w150 h20 gDormsettings vDormSub checked%DormSub% +c4400FF, 啟動自動後宅
Tab_Y +=30
iniread, DormCoin, settings.ini, Dorm, DormCoin, 1
Gui, Add, CheckBox, x30 y%Tab_Y% w110 h20 gDormsettings vDormCoin checked%DormCoin%, 領取傢俱幣
Tab_Y +=30
iniread, Dormheart, settings.ini, Dorm, Dormheart, 1
Gui, Add, CheckBox, x30 y%Tab_Y% w130 h20 gDormsettings vDormheart checked%Dormheart%, 打撈海洋之心
Tab_Y +=30
iniread, DormFood, settings.ini, Dorm, DormFood
Gui, Add, CheckBox, x30 y%Tab_Y% w80 h20 gDormsettings vDormFood checked%DormFood%, 糧食低於
Tab_Y -=2
IniRead, DormFoodBar, settings.ini, Dorm, DormFoodBar, 80
Gui, Add, Slider, x110 y%Tab_Y% w100 h30 gDormsettings vDormFoodBar range10-80 +ToolTip , %DormFoodBar%
Tab_Y +=2
Gui, Add, Text, x215 y%Tab_Y% w20 h20 vDormFoodBarUpdate , %DormFoodBarUpdate% 
Gui, Add, Text, x240 y%Tab_Y% w100 h20 vTestbar1Percent, `%自動補給


Gui, Tab, 科　研
Tab_Y := 90
iniread, TechacademySub, settings.ini, TechacademySub, TechacademySub
Gui, Add, CheckBox, x30 y%Tab_Y% w150 h20 gTechacademysettings vTechacademySub checked%TechacademySub% +c4400FF, 啟動自動執行科研
Tab_Y += 30
Gui, Add, Text, x30 y%Tab_Y% w80 h20, 研發項目：
iniread, TechTarget_01, settings.ini, TechacademySub, TechTarget_01, 1
iniread, TechTarget_02, settings.ini, TechacademySub, TechTarget_02, 1
iniread, TechTarget_03, settings.ini, TechacademySub, TechTarget_03, 1
iniread, TechTarget_04, settings.ini, TechacademySub, TechTarget_04, 1
iniread, TechTarget_05, settings.ini, TechacademySub, TechTarget_05, 1
iniread, TechTarget_06, settings.ini, TechacademySub, TechTarget_06, 1
iniread, TechTarget_07, settings.ini, TechacademySub, TechTarget_07, 1
Tab_Y -= 3
Gui, Add, CheckBox, x110 y%Tab_Y% w80 h20 gTechacademysettings vTechTarget_01 checked%TechTarget_01% , 定向研發
Gui, Add, CheckBox, x200 y%Tab_Y% w80 h20 gTechacademysettings vTechTarget_02 checked%TechTarget_02% , 資金募集
Gui, Add, CheckBox, x290 y%Tab_Y% w80 h20 gTechacademysettings vTechTarget_03 checked%TechTarget_03% , 數據蒐集
Gui, Add, CheckBox, x380 y%Tab_Y% w80 h20 gTechacademysettings vTechTarget_04 checked%TechTarget_04% , 艦裝解析
Tab_Y += 25
Gui, Add, CheckBox, x110 y%Tab_Y% w80 h20 gTechacademysettings vTechTarget_05 checked%TechTarget_05% , 研究委託
Gui, Add, CheckBox, x200 y%Tab_Y% w80 h20 gTechacademysettings vTechTarget_06 checked%TechTarget_06% , 試驗募集
Gui, Add, CheckBox, x290 y%Tab_Y% w80 h20 gTechacademysettings vTechTarget_07 checked%TechTarget_07% , 基礎研究
Tab_Y += 30
;~ Gui, Add, Text, x30 y%Tab_Y% w80 h20, 研發消耗：
;~ Tab_Y -= 3
;~ Gui, Add, CheckBox, x110 y%Tab_Y% w80 h20 gTechacademysettings vTechExpend_Coin checked%TechExpend_Coin% , 金幣
;~ Gui, Add, CheckBox, x200 y%Tab_Y% w80 h20 gTechacademysettings vTechExpend_Free checked%TechExpend_Free% , 免費
;~ Gui, Add, CheckBox, x290 y%Tab_Y% w80 h20 gTechacademysettings vTechExpend_Other checked%TechExpend_Other% , 其他
iniread, Tech_NoCoin, settings.ini, TechacademySub, Tech_NoCoin, 0
Gui, Add, CheckBox, x30 y%Tab_Y% w100 h20 gTechacademysettings vTech_NoCoin checked%Tech_NoCoin% , 不使用金幣

Gui, Tab, 任　務
iniread, MissionSub, settings.ini, MissionSub, MissionSub
Gui, Add, CheckBox, x30 y90 w150 h20 gMissionsettings vMissionSub checked%MissionSub% +c4400FF, 啟動自動接收任務

Gui, Tab, 其　他
Tab_Y := 90
Gui, Add, button, x30 y%TAB_Y% w120 h20 vdebug gDebug2, 測試取色
Gui, Add, button, x180 y%TAB_Y% w120 h20 gForumSub, GitHub
Gui, Add, button, x330 y%TAB_Y% w120 h20 gDiscordSub, Discord
Tab_Y += 30
Gui, Add, button, x30 y%TAB_Y% w120 h20 gstartemulatorsub, 啟動模擬器
Gui, Add, button, x180 y%TAB_Y% w120 h20 gDailyGoalSub2, 執行每日任務
Gui, Add, button, x330 y%TAB_Y% w120 h20 gOperationSub, 執行演習
;~ Gui, Add, button, x30 y%TAB_Y% w120 h20 gAdjustGetPixelMode, 調整取色方式
;~ Tab_Y += 30
;~ Gui, Add, button, x180 y%TAB_Y% w120 h20 gIsUpdate, 檢查更新
;~ Gui, Add, button, x180 y%TAB_Y% w120 h20 gAutopuzzle, 自動拼圖
Tab_Y += 30
iniread, CheckUpdate, settings.ini, OtherSub, CheckUpdate, 0
Gui, Add, Checkbox, x30 y%TAB_Y% w160 h20 gOthersettings vCheckUpdate checked%CheckUpdate% , 啟動時自動檢查更新
iniread, GuiHideX, settings.ini, OtherSub, GuiHideX
Gui, Add, CheckBox, x240 y%TAB_Y% w200 h20 gOthersettings vGuiHideX checked%GuiHideX% , 按X隱藏本視窗，而非關閉

Tab_Y += 30
iniread, EmulatorCrushCheck, settings.ini, OtherSub, EmulatorCrushCheck
Gui, Add, CheckBox, x30 y%TAB_Y% w200 h20 gOthersettings vEmulatorCrushCheck checked%EmulatorCrushCheck% , 模擬器或輔助卡住自動重啟
iniread, AutoLogin, settings.ini, OtherSub, AutoLogin
Gui, Add, CheckBox, x240 y%TAB_Y% w200 h20 gOthersettings vAutoLogin checked%AutoLogin% , 斷線自動重登(Google帳號)
Tab_Y += 30
Gui, Add, CheckBox, x30 y%TAB_Y% w125 h20 gOthersettings vSetGuiBGcolor checked%SetGuiBGcolor% , 自訂背景顏色 0x
Tab_Y -= 1
Gui Add, Edit, x155 y%TAB_Y% w70 h21 vSetGuiBGcolor2 gOthersettings Limit6, %SetGuiBGcolor2%
Gui Add, Button, x240 y%TAB_Y% w120 h21 gHexadecimalSub , 色票查詢工具

Tab_Y += 30
iniread, DebugMode, settings.ini, OtherSub, DebugMode, 0
Gui, Add, CheckBox, x30 y%TAB_Y% w125 h20 gOthersettings vDebugMode checked%DebugMode% , 除錯模式
Tab_Y += 32
Iniread, DwmMode, settings.ini, OtherSub, DwmMode, 1
Iniread, GdiMode, settings.ini, OtherSub, GdiMode, 0
Iniread, AHKMode, settings.ini, OtherSub, AHKMode, 0
Gui, Add, Text,  x30 y%TAB_Y%  w100 h20 , 取色方式：
Tab_Y -= 3
Iniread, CloneWindowforDWM, settings.ini, OtherSub, CloneWindowforDWM, 0
Gui, Add, Radio,  x110 y%TAB_Y% w60 h20 gOthersettings vDwmMode checked%DwmMode% , DWM

Gui, Add, Radio,  x180 y%TAB_Y% w50 h20 gOthersettings vGdiMode checked%GdiMode% , GDI
Gui, Add, Radio,  x240 y%TAB_Y% w60 h20 gOthersettings vAHKMode checked%AHKMode% , AHK
Gui, Add, CheckBox, x310 y%TAB_Y% w300 h20 gOthersettings vCloneWindowforDWM checked%CloneWindowforDWM% , 創造隱形視窗`(DWM)
Tab_Y += 30
Gui, Add, Text,  x30 y%TAB_Y%  w100 h20 , 點擊方式：
Tab_Y -= 3
Iniread, SendFromAHK, settings.ini, OtherSub, SendFromAHK, 1
Iniread, SendFromADB, settings.ini, OtherSub, SendFromADB, 0
Gui, Add, Radio,  x110 y%TAB_Y% w120 h20 gOthersettings vSendFromAHK checked%SendFromAHK% , 模擬滑鼠點擊
Gui, Add, Radio,  x230 y%TAB_Y% w150 h20 gOthersettings vSendFromADB checked%SendFromADB% , ADB發送點擊指令
Tab_Y += 35
Gui, Add, Text,  x30 y%TAB_Y%  w140 h20 , 容許誤差：文字
IniRead, Value_Err0, settings.ini, OtherSub, Value_Err0, 0
Tab_Y -= 3
Gui, Add, Slider, x140 y%TAB_Y% w80 h30 gOthersettings vValue_Err0 range0-50 +ToolTip , %Value_Err0%
Tab_Y += 3
Gui, Add, Text, x220 y%TAB_Y% w30 h20 vValue_Err0BarUpdate , %Value_Err0BarUpdate% 
Gui, Add, Text, x250 y%TAB_Y% w100 h20 , `%

Gui, Add, Text,  x280 y%TAB_Y%  w50 h20 , 背景
IniRead, Value_Err1, settings.ini, OtherSub, Value_Err1, 0
Tab_Y -= 3
Gui, Add, Slider, x310 y%TAB_Y% w80 h30 gOthersettings vValue_Err1 range0-50 +ToolTip , %Value_Err1%
Tab_Y += 3
Gui, Add, Text, x400 y%TAB_Y% w30 h20 vValue_Err1BarUpdate , %Value_Err1BarUpdate% 
Gui, Add, Text, x430 y%TAB_Y% w100 h20 , `%
Tab_Y += 30
Gui, Add, Text,  x105 y%TAB_Y%  w40 h20 , 圖片
IniRead, Value_Pic, settings.ini, OtherSub, Value_Pic, 0
Tab_Y -= 3
Gui, Add, Slider, x140 y%TAB_Y% w80 h30 gOthersettings vValue_Pic range0-50 +ToolTip , %Value_Pic%
Tab_Y += 3
Gui, Add, Text, x220 y%TAB_Y% w30 h20 vValue_PicBarUpdate , %Value_PicBarUpdate% 
Gui, Add, Text, x250 y%TAB_Y% w100 h20 , `%
Tab_Y += 35
Gui, Add, Text,  x30 y%TAB_Y%  w120 h20 , 檢測頻率：每　
IniRead, MainsubTimer, settings.ini, OtherSub, MainsubTimer, 3
Tab_Y -= 3
Gui, Add, Slider, x140 y%TAB_Y% w80 h30 gMainsubTimersettings vMainsubTimer range2-10 +ToolTip , %MainsubTimer%
Tab_Y += 3
Gui, Add, Text, x220 y%TAB_Y% w20 h20 vMainsubTimerBarUpdate , %MainsubTimerBarUpdate% 
Gui, Add, Text, x240 y%TAB_Y% w100 h20 , 秒/次
Tab_Y += 30
Iniread, Ldplayer3, settings.ini, EmulatorSub, Ldplayer3, 1
Iniread, Ldplayer4, settings.ini, EmulatorSub, Ldplayer4, 0
Iniread, NoxPlayer5, settings.ini, EmulatorSub, NoxPlayer5, 0
Gui, Add, Text,  x30 y%TAB_Y%  w140 h20 , 模  擬  器：
Tab_Y -= 3
Gui, Add, Radio,  x110 y%TAB_Y% w80 h20 gEmulatorsettings vLdplayer3 checked%Ldplayer3% , 雷電3.x
Gui, Add, Radio,  x190 y%TAB_Y% w80 h20 gEmulatorsettings vLdplayer4 checked%Ldplayer4% , 雷電4.x
Gui, Add, Radio,  x270 y%TAB_Y% w80 h20 gEmulatorsettings vNoxPlayer5 checked%NoxPlayer5% , 夜神
Global Ldplayer3, Ldplayer4, NoxPlayer5
;///////////////////     GUI Right Side  End ///////////////////

if (Ldplayer3) {
	EmulatorResolution_W := 1318  ; 雷電4.0 1322 夜神 1284
	EmulatorResolution_H := 758 ;夜神 754
	RegRead, ldplayer, HKEY_CURRENT_USER, Software\Changzhi\dnplayer-tw, InstallDir ; Ldplayer 3.76以下版本
	if (ldplayer="") {
		RegRead, ldplayer, HKEY_CURRENT_USER, Software\Changzhi\LDPlayer, InstallDir ; Ldplayer 3.77以上版本
	}
	Consolefile = dnconsole.exe
} else if (Ldplayer4) {
	EmulatorResolution_W := 1322  ; 雷電4.0 1322 夜神 1284
	EmulatorResolution_H := 758 ;夜神 754
	RegRead, ldplayer, HKEY_CURRENT_USER, Software\XuanZhi\LDPlayer, InstallDir ; Ldplayer 4.0+ version
	Consolefile = dnconsole.exe
} else if (NoxPlayer5) {
	EmulatorResolution_W := 1284  ; 雷電4.0 1322 夜神 1284
	EmulatorResolution_H := 754 ;夜神 754
	iniRead, ldplayer, settings.ini, NoxInstallDir, NoxInstallDir
	if (ldplayer="" or ldplayer="ERROR")
	{
		InputBox, ldplayer, 設定精靈, 請輸入夜神模擬器的路徑`n`n例如: C:\Program Files\Nox\bin
		iniwrite, %ldplayer%, settings.ini, NoxInstallDir, NoxInstallDir
	}
	Consolefile = NoxConsole.exe
}
Global EmulatorResolution_W, EmulatorResolution_H, Consolefile

IniRead, azur_x, settings.ini, Winposition, azur_x, 0
IniRead, azur_y, settings.ini, Winposition, azur_y, 0
if azur_x=
	azur_x := 0
if azur_y=
	azur_y := 0
Gui, +OwnDialogs
Gui Show, w925 h500 x%azur_x% y%azur_y%, Azur Lane - %title%
Menu, Tray, Tip , Azur Lane `(%title%)
Winget, UniqueID,, %title%
Allowance = %AllowanceValue%
Global UniqueID
Global Allowance
Gosub, whitealbum
Settimer, whitealbum, 10000 ;很重要!
iniread, Autostart, settings.ini, OtherSub, Autostart, 0
if (Autostart) {
	iniread, AutostartMessage, settings.ini, OtherSub, AutostartMessage
	iniwrite, 0, settings.ini, OtherSub, Autostart
	iniwrite, 0, settings.ini, OtherSub, AutostartMessage
	LogShow(AutostartMessage)
	Goto, Start
}
else if (CheckUpdate) { ;啟動時檢查自動更新
	gosub, Isupdate2
}
;//////////////刪除雷電模擬器可能的惡意廣告檔案//////////////////
DefaultDir = %A_WorkingDir%
SetWorkingDir, %ldplayer%
OnMessage(0x53, "WM_HELP")
if (FileExist("fyservice.exe") or FileExist("fynews.exe") or FileExist("ldnews.exe") or FileExist("news")) {
	MsgBox, 24628, 敬告, 發現雷電模擬器中的廣告檔案，是否自動刪除？
	IfMsgBox Yes
	{
		while (FileExist("fyservice.exe") or FileExist("fynews.exe") or FileExist("ldnews.exe") or FileExist("news"))
		{ ;ldnews.exe 刪除不影響運作 看起來很像廣告檔案
			WinClose, ahk_exe fynews.exe
			WinClose, ahk_exe fyservice.exe
			WinClose, ahk_exe ldnews.exe
			FileDelete, fynews.exe
			FileDelete, fyservice.exe
			FileDelete, ldnews.exe
			FileRemoveDir, news, 1
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
		}
		While (InStr(FileExist("fy"), "D"))
		{
			WinClose, ahk_exe fynews.exe
			WinClose, ahk_exe fyservice.exe
			WinClose, ahk_exe ldnews.exe
			FileRemoveDir, fy, 1
		}
		LogShow("廣告檔案刪除成功")
	}
	else IfMsgBox No 
	{
	}
} 
SetWorkingDir, %A_temp%
While (InStr(FileExist("fy"), "D"))
{
	WinClose, ahk_exe fynews.exe
	WinClose, ahk_exe fyservice.exe
	WinClose, ahk_exe ldnews.exe
	FileRemoveDir, fy, 1
	LogShow("發現雷電的廣告檔案，自動刪除")
}
SetWorkingDir, %DefaultDir%
if (substr(A_osversion, 1, 2)!=10)
{
	iniread, OsVersionCheck, settings.ini, Osversion, OsVersionCheck
	Text := "在作業系統非Windows10的環境下，本程式可能無法正確運作。`n`n請嘗試：`n`n1.　更新您的作業系統至Windows10。`n`n2.　<a href=""https://www.google.com/search?q=關閉Aero特效"">關閉Aero特效</a>。`n"
	OsVersionCheckText := "不再提示"
	if (OsVersionCheck!=1)
	{
		Result := MsgBoxEx(Text, "提示", "OK", 4, OsVersionCheckText, "-SysMenu AlwaysOnTop", 0, 0, "s12 c0x000000", "Segoe UI")
		if (OsVersionCheckText=1) {
			iniwrite, 1, settings.ini, Osversion, OsVersionCheck
		} else {
			iniwrite, 0, settings.ini, Osversion, OsVersionCheck
		}
	}
}
IfWinNotExist, ahk_exe NVDisplay.Container.exe
{
	iniread, VideoCardCheck, settings.ini, VideoCard, VideoCardCheck
	Text := "未偵測到Nvidia顯示卡驅動程式。"
	. "`n`n`n請注意，在非使用Nvidia顯示卡的情況下，本程式取色有關功能可能無法正確運作。"
	. "`n`n如果您使用的是:`n`n1. Nvidia顯示卡，請嘗試"
	. "<a href=""https://www.nvidia.com.tw/Download/index.aspx?lang=tw"">更新顯示卡驅動程式</a>。"
	. "`n`n2. AMD顯示卡，因為作者沒有AMD顯示卡，所以無法排除此問題。"
	VideoCardCheckText := "不再提示"
	if (VideoCardCheck!=1)
	{
		Result := MsgBoxEx(Text, "提示", "OK", 4, VideoCardCheckText, "-SysMenu AlwaysOnTop", 0, 0, "s12 c0x000000", "Segoe UI")
		if (VideoCardCheckText=1) {
			iniwrite, 1, settings.ini, VideoCard, VideoCardCheck
		} else {
			iniwrite, 0, settings.ini, VideoCard, VideoCardCheck
		}
	}
}
LogShow("啟動完畢，等待開始")
Guicontrol, Enable, start
return

Debug2:
LogShow("檢測中")
GuiControl, disable, debug
WinRestore,  %title%
WinMove,  %title%, , , , %EmulatorResolution_W%, %EmulatorResolution_H%
text1 := GdiGetPixel(12, 24)
text2 := DwmGetPixel(12, 24)
text3 := GdiGetPixel(1300, 681)
text4 := DwmGetPixel(1300, 681)
text5 := GdiGetPixel(485, 21)
text6 := DwmGetPixel(485, 21)
text11 := Dwmcheckcolor(1300, 681, 16777215)
text22 := Dwmcheckcolor(13, 25, 16041247)
text33 := DwmCheckcolor(13, 25, 16041247)
SysGet, VirtualWidth, 78
SysGet, VirtualHeight, 79
WinGetPos, X, Y, Width, Height, %title%
debug_Y := 1
Loop {
	DwmCheckcolor(1, debug_Y, 1250067)
	debug_Y++
	debug_YY++
	if (debug_YY>60)
		debug_Y := debug_Y_Failed
} until !DwmCheckcolor(1, debug_Y, 1250067) or debug_YY>60
debug_X := 1
Loop {
	DwmCheckcolor(debug_X, 16, 1250067)
	debug_X++
	debug_XX++
	if (debug_XX>60)
		debug_X := debug_X_Failed or debug_XX>60
} until !DwmCheckcolor(debug_X, 16, 1250067)
WinGet, UniqueID, ,Azur Lane - %title%
Global UniqueID 
gui, Color, FF0000
sleep 100
Red := DwmGetPixel(336, 456)
sleep 200
gui, Color, 00FF00
sleep 100
Green := DwmGetPixel(336, 456)
sleep 200
gui, Color, 0000FF
sleep 100
Blue :=  DwmGetPixel(336, 456)
sleep 200
gui, Color, FFFFFF
sleep 100
White := DwmGetPixel(336, 456)
sleep 200
gui, Color, 000000
sleep 100
Black := DwmGetPixel(336, 456)
sleep 200
gui, Color, Default
Msgbox, Red: %Red% `nGreen:%Green%`nBlue: %Blue%`nWhite: %White%`nBlack:%Black%`n`nGdiGetPixel(12, 24)：%text1% and 4294231327`nDwmGetPixel(12, 24)：%text2% and %text22%`nGdiGetPixel(1300, 681)：%text3% and 4294967295`nDwmGetPixel(1300, 681)：%text4% and %text11%`nGdiGetPixel(485, 21)：%text5% and 4280823870`nDwmGetPixel(485, 21)：%text6% and %text33%`n`ndebug_Y: %debug_Y%`ndebug_X: %debug_X%`n`nWin_Width: %Width%`nWin_Height: %Height%`n`nScreenWidth: %VirtualWidth% `nScreenHeight: %VirtualHeight%`nWin_X: %X%`nWin_Y: %Y%`n`n請對此視窗截圖("Alt+PrintScreen")
Winget, UniqueID,, %title%
Global UniqueID
GuiControl,enable, debug
GuiControl,, ListBoxLog, |
return

TabFunc: ;切換分頁讀取GUI設定，否則可能導致選項失效
gosub, inisettings
gosub, Anchorsettings
gosub, Anchor3settings
gosub, Academysettings
gosub, Dormsettings
gosub, Missionsettings
gosub, Othersettings
gosub, MainsubTimersettings
return

inisettings: ;一般設定
Critical
Guicontrolget, title
Guicontrolget, emulatoradb
Guicontrolget, AllowanceValue
Iniwrite, %emulatoradb%, settings.ini, emulator, emulatoradb
Iniwrite, %title%, settings.ini, emulator, title
Iniwrite, %AllowanceValue%, settings.ini, emulator, AllowanceValue
Critical, off
return

Anchorsettings: ;出擊設定
Critical
;///////////////TAB1//////////////
Guicontrolget, AnchorSub
Guicontrolget, AnchorMode
Guicontrolget, AnchorChapter
Guicontrolget, AnchorChapter2
Guicontrolget, Assault
Guicontrolget, mood
Guicontrolget, Autobattle
Guicontrolget, BossAction
Guicontrolget, Shipsfull
Guicontrolget, ChooseParty1
Guicontrolget, ChooseParty2
Guicontrolget, SwitchPartyAtFirstTime
Guicontrolget, WeekMode
Guicontrolget, Use_FixKit
Guicontrolget, AlignCenter
Guicontrolget, BattleTimes
Guicontrolget, BattleTimes2
Guicontrolget, Ship_Target1
Guicontrolget, Ship_Target2
Guicontrolget, Ship_Target3
Guicontrolget, Ship_Target4
Guicontrolget, Item_Bullet
Guicontrolget, Item_Quest
Guicontrolget, Plane_Target1
Guicontrolget, TimetoBattle
Guicontrolget, TimetoBattle1
Guicontrolget, TimetoBattle2
Guicontrolget, StopBattleTime
Guicontrolget, StopBattleTime2
Guicontrolget, StopBattleTime3
Iniwrite, %AnchorSub%, settings.ini, Battle, AnchorSub
Iniwrite, %AnchorMode%, settings.ini, Battle, AnchorMode
Iniwrite, %AnchorChapter%, settings.ini, Battle, CH_AnchorChapter
Iniwrite, %AnchorChapter2%, settings.ini, Battle, AnchorChapter2
Iniwrite, %Assault%, settings.ini, Battle, Assault
Iniwrite, %mood%, settings.ini, Battle, mood
Iniwrite, %Autobattle%, settings.ini, Battle, Autobattle
Iniwrite, %BossAction%, settings.ini, Battle, BossAction
Iniwrite, %Shipsfull%, settings.ini, Battle, Shipsfull
Iniwrite, %ChooseParty1%, settings.ini, Battle, ChooseParty1
Iniwrite, %ChooseParty2%, settings.ini, Battle, ChooseParty2
Iniwrite, %SwitchPartyAtFirstTime%, settings.ini, Battle, SwitchPartyAtFirstTime
Iniwrite, %WeekMode%, settings.ini, Battle, WeekMode
Iniwrite, %Use_FixKit%, settings.ini, Battle, Use_FixKit
Iniwrite, %AlignCenter%, settings.ini, Battle, AlignCenter
Iniwrite, %BattleTimes%, settings.ini, Battle, BattleTimes
Iniwrite, %BattleTimes2%, settings.ini, Battle, BattleTimes2
Iniwrite, %Ship_Target1%, settings.ini, Battle, Ship_Target1
Iniwrite, %Ship_Target2%, settings.ini, Battle, Ship_Target2
Iniwrite, %Ship_Target3%, settings.ini, Battle, Ship_Target3
Iniwrite, %Ship_Target4%, settings.ini, Battle, Ship_Target4
Iniwrite, %Item_Bullet%, settings.ini, Battle, Item_Bullet
Iniwrite, %Item_Quest%, settings.ini, Battle, Item_Quest
Iniwrite, %Plane_Target1%, settings.ini, Battle, Plane_Target1
Iniwrite, %TimetoBattle%, settings.ini, Battle, TimetoBattle
Iniwrite, %TimetoBattle1%, settings.ini, Battle, TimetoBattle1
Iniwrite, %TimetoBattle2%, settings.ini, Battle, TimetoBattle2
Iniwrite, %StopBattleTime%, settings.ini, Battle, StopBattleTime
Iniwrite, %StopBattleTime2%, settings.ini, Battle, StopBattleTime2
Iniwrite, %StopBattleTime3%, settings.ini, Battle, StopBattleTime3
Global Assault, Autobattle, shipsfull, ChooseParty1, ChooseParty2, AnchorMode, SwitchPartyAtFirstTime, WeekMode, AnchorChapter, AnchorChapter2, mood

;////出擊2/////// TAB2
Guicontrolget, IndexAll
Guicontrolget, Index1
Guicontrolget, Index2
Guicontrolget, Index3
Guicontrolget, Index4
Guicontrolget, Index5
Guicontrolget, Index6
Guicontrolget, Index7
Guicontrolget, Index8
Guicontrolget, Index9
Guicontrolget, CampAll
Guicontrolget, Camp1
Guicontrolget, Camp2
Guicontrolget, Camp3
Guicontrolget, Camp4
Guicontrolget, Camp5
Guicontrolget, Camp6
Guicontrolget, Camp7
Guicontrolget, RarityAll
Guicontrolget, Rarity1
Guicontrolget, Rarity2
Guicontrolget, Rarity3
Guicontrolget, Rarity4
Guicontrolget, DailyGoalSub
Guicontrolget, DailyParty
Guicontrolget, DailyGoalSunday
Guicontrolget, DailyGoalRed
Guicontrolget, DailyGoalRedAction
Guicontrolget, DailyGoalGreen
Guicontrolget, DailyGoalGreenAction
Guicontrolget, DailyGoalBlue
Guicontrolget, DailyGoalBlueAction
Guicontrolget, OperationSub
Guicontrolget, Operationenemy
Guicontrolget, Leave_Operatio
Guicontrolget, OperatioMyHpBar
Guicontrolget, OperatioMyHpBarUpdate
Guicontrolget, OperatioEnHpBar
Guicontrolget, OperatioEnHpBarUpdate
Guicontrolget, ResetOperationTime
Guicontrolget, ResetOperationTime2
Iniwrite, %IndexAll%, settings.ini, Battle, IndexAll ;全部
Iniwrite, %Index1%, settings.ini, Battle, Index1 ;前排先鋒
Iniwrite, %Index2%, settings.ini, Battle, Index2 ;後排主力
Iniwrite, %Index3%, settings.ini, Battle, Index3 ;驅逐
Iniwrite, %Index4%, settings.ini, Battle, Index4 ;輕巡
Iniwrite, %Index5%, settings.ini, Battle, Index5 ;重巡
Iniwrite, %Index6%, settings.ini, Battle, Index6 ;戰列
Iniwrite, %Index7%, settings.ini, Battle, Index7 ;航母
Iniwrite, %Index8%, settings.ini, Battle, Index8 ;維修
Iniwrite, %Index9%, settings.ini, Battle, Index9 ;其他
Iniwrite, %CampAll%, settings.ini, Battle, CampAll ;全部
Iniwrite, %Camp1%, settings.ini, Battle, Camp1 ;白鷹
Iniwrite, %Camp2%, settings.ini, Battle, Camp2 ;皇家
Iniwrite, %Camp3%, settings.ini, Battle, Camp3 ;重櫻
Iniwrite, %Camp4%, settings.ini, Battle, Camp4 ;鐵血
Iniwrite, %Camp5%, settings.ini, Battle, Camp5 ;東煌
Iniwrite, %Camp6%, settings.ini, Battle, Camp6 ;北方聯合
Iniwrite, %Camp7%, settings.ini, Battle, Camp7 ;其他
Iniwrite, %RarityAll%, settings.ini, Battle, RarityAll ;全部
Iniwrite, %Rarity1%, settings.ini, Battle, Rarity1 ;普通
Iniwrite, %Rarity2%, settings.ini, Battle, Rarity2 ;稀有
Iniwrite, %Rarity3%, settings.ini, Battle, Rarity3 ;精銳
Iniwrite, %Rarity4%, settings.ini, Battle, Rarity4 ;超稀有
Iniwrite, %DailyGoalSub%, settings.ini, Battle, DailyGoalSub  ;自動執行每日任務
Iniwrite, %DailyParty%, settings.ini, Battle, DailyParty  ;每日隊伍選擇
Iniwrite, %DailyGoalSunday%, settings.ini, Battle, DailyGoalSunday ;禮拜日三個都打
Iniwrite, %DailyGoalRed%, settings.ini, Battle, DailyGoalRed
Iniwrite, %DailyGoalRedAction%, settings.ini, Battle, DailyGoalRedAction
Iniwrite, %DailyGoalGreen%, settings.ini, Battle, DailyGoalGreen
Iniwrite, %DailyGoalGreenAction%, settings.ini, Battle, DailyGoalGreenAction
Iniwrite, %DailyGoalBlue%, settings.ini, Battle, DailyGoalBlue
Iniwrite, %DailyGoalBlueAction%, settings.ini, Battle, DailyGoalBlueAction
Iniwrite, %OperationSub%, settings.ini, Battle, OperationSub ;自動執行演習
Iniwrite, %Operationenemy%, settings.ini, Battle, Operationenemy
Iniwrite, %Leave_Operatio%, settings.ini, Battle, Leave_Operatio
Iniwrite, %OperatioMyHpBar%, settings.ini, Battle, OperatioMyHpBar ;演習時的我方血量
Iniwrite, %OperatioEnHpBar%, settings.ini, Battle, OperatioEnHpBar ;演習時的敵方血量
Iniwrite, %ResetOperationTime%, settings.ini, Battle, ResetOperationTime
Iniwrite, %ResetOperationTime2%, settings.ini, Battle, ResetOperationTime2
Guicontrol, ,OperatioMyHpBarUpdate, %OperatioMyHpBar%
Guicontrol, ,OperatioEnHpBarUpdate, %OperatioEnHpBar%
Global IndexAll, Index1, Index2, Index3, Index4, Index5, Index6, Index7, Index8, Index9, CampAll, Camp1,Camp2, Camp3, Camp4, Camp5, Camp6, Camp7, Camp8, Camp9, RarityAll, Rarity1, Rarity2, Rarity3, Rarity4, DailyParty, Leave_Operatio, OperatioMyHpBar, OperatioEnHpBar
Critical, off
return

Anchor3settings: ;TAB出擊3
Critical
Guicontrolget, FightRoundsDo
Guicontrolget, FightRoundsDo2
Guicontrolget, FightRoundsDo3
Guicontrolget, Retreat_LowHp
Guicontrolget, Retreat_LowHpBar
Guicontrolget, Retreat_LowHpDo
Guicontrolget, Stop_LowHp
Guicontrolget, Stop_LowHP_SP
Guicontrolget, Retreat_LowHp2
Guicontrolget, Retreat_LowHp2Bar
Guicontrolget, Retreat_LowHp2Do
Guicontrolget, Take_ItemQuest
Guicontrolget, Take_ItemQuestNum
Iniwrite, %FightRoundsDo%, settings.ini, Battle, FightRoundsDo ;當艦隊A....
Iniwrite, %FightRoundsDo2%, settings.ini, Battle, FightRoundsDo2 ;出擊次數
Iniwrite, %FightRoundsDo3%, settings.ini, Battle, FightRoundsDo3 ; 做什麼事
Iniwrite, %Retreat_LowHp%, settings.ini, Battle, Retreat_LowHp
Iniwrite, %Retreat_LowHpBar%, settings.ini, Battle, Retreat_LowHpBar
Iniwrite, %Retreat_LowHpDo%, settings.ini, Battle, Retreat_LowHpDo
Iniwrite, %Stop_LowHp%, settings.ini, Battle, Stop_LowHp
Iniwrite, %Stop_LowHP_SP%, settings.ini, Battle, Stop_LowHP_SP
Iniwrite, %Retreat_LowHp2%, settings.ini, Battle, Retreat_LowHp2
Iniwrite, %Retreat_LowHp2Bar%, settings.ini, Battle, Retreat_LowHp2Bar
Iniwrite, %Retreat_LowHp2Do%, settings.ini, Battle, Retreat_LowHp2Do
Iniwrite, %Take_ItemQuest%, settings.ini, Battle, Take_ItemQuest
Iniwrite, %Take_ItemQuestNum%, settings.ini, Battle, Take_ItemQuestNum
Guicontrol, ,Retreat_LowHpBarUpdate, %Retreat_LowHpBar%
Guicontrol, ,Retreat_LowHp2BarUpdate, %Retreat_LowHp2Bar%
Global Retreat_LowHp, Retreat_LowHpBar, Retreat_LowHpDo, Stop_LowHp, Stop_LowHP_SP, Retreat_LowHp2, Retreat_LowHp2Bar, Retreat_LowHp2Do
Critical, off
return



Academysettings: ;學院設定
Critical
Guicontrolget, AcademySub
Guicontrolget, AcademyOil
Guicontrolget, AcademyCoin
Guicontrolget, AcademyTactics
Guicontrolget, AcademyShop
Guicontrolget, 150expbookonly
Guicontrolget, SkillBook_ATK
Guicontrolget, SkillBook_DEF
Guicontrolget, SkillBook_SUP
Guicontrolget, Cube
Guicontrolget, Part_Aircraft
Guicontrolget, Part_Cannon
Guicontrolget, Part_torpedo
Guicontrolget, Part_Anti_Aircraft
Guicontrolget, Part_Common
Guicontrolget, Item_Equ_Box1
Guicontrolget, Item_Water
Guicontrolget, Item_Tempura
Guicontrolget, Item_Ex4_Box
Iniwrite, %AcademySub%, settings.ini, Academy, AcademySub
Iniwrite, %AcademyOil%, settings.ini, Academy, AcademyOil
Iniwrite, %AcademyCoin%, settings.ini, Academy, AcademyCoin
Iniwrite, %AcademyShop%, settings.ini, Academy, AcademyShop
Iniwrite, %AcademyTactics%, settings.ini, Academy, AcademyTactics
Iniwrite, %150expbookonly%, settings.ini, Academy, 150expbookonly
Iniwrite, %SkillBook_ATK%, settings.ini, Academy, SkillBook_ATK
Iniwrite, %SkillBook_DEF%, settings.ini, Academy, SkillBook_DEF
Iniwrite, %SkillBook_SUP%, settings.ini, Academy, SkillBook_SUP
Iniwrite, %Cube%, settings.ini, Academy, Cube
Iniwrite, %Part_Aircraft%, settings.ini, Academy, Part_Aircraft
Iniwrite, %Part_Cannon%, settings.ini, Academy, Part_Cannon
Iniwrite, %Part_torpedo%, settings.ini, Academy, Part_torpedo
Iniwrite, %Part_Anti_Aircraft%, settings.ini, Academy, Part_Anti_Aircraft
Iniwrite, %Part_Common%, settings.ini, Academy, Part_Common
Iniwrite, %Item_Equ_Box1%, settings.ini, Academy, Item_Equ_Box1
Iniwrite, %Item_Water%, settings.ini, Academy, Item_Water
Iniwrite, %Item_Tempura%, settings.ini, Academy, Item_Tempura
Iniwrite, %Item_Ex4_Box%, settings.ini, Academy, Item_Ex4_Box
Critical, off
return

Dormsettings: ;後宅設定
Critical
Guicontrolget, DormSub
Guicontrolget, DormCoin
Guicontrolget, Dormheart
Guicontrolget, DormFood
Guicontrolget, DormFoodBar
Iniwrite, %DormSub%, settings.ini, Dorm, DormSub
Iniwrite, %DormCoin%, settings.ini, Dorm, DormCoin
Iniwrite, %Dormheart%, settings.ini, Dorm, Dormheart
Iniwrite, %DormFood%, settings.ini, Dorm, DormFood
Iniwrite, %DormFoodBar%, settings.ini, Dorm, DormFoodBar
Guicontrol, ,DormFoodBarUpdate, %DormFoodBar%
Global DormFood
Critical, off
return


Techacademysettings: ;科研設定
Critical
Guicontrolget, TechacademySub
Guicontrolget, TechTarget_01 ;定向研發
Guicontrolget, TechTarget_02 ;資金募集
Guicontrolget, TechTarget_03 ;數據蒐集
Guicontrolget, TechTarget_04 ;艦裝解析
Guicontrolget, TechTarget_05 ;研究委託
Guicontrolget, TechTarget_06 ;試驗品募集
Guicontrolget, TechTarget_07 ;基礎研究
Guicontrolget, Tech_NoCoin
Iniwrite, %TechacademySub%, settings.ini, TechacademySub, TechacademySub
Iniwrite, %TechTarget_01%, settings.ini, TechacademySub, TechTarget_01
Iniwrite, %TechTarget_02%, settings.ini, TechacademySub, TechTarget_02
Iniwrite, %TechTarget_03%, settings.ini, TechacademySub, TechTarget_03
Iniwrite, %TechTarget_04%, settings.ini, TechacademySub, TechTarget_04
Iniwrite, %TechTarget_05%, settings.ini, TechacademySub, TechTarget_05
Iniwrite, %TechTarget_06%, settings.ini, TechacademySub, TechTarget_06
Iniwrite, %TechTarget_07%, settings.ini, TechacademySub, TechTarget_07
Iniwrite, %Tech_NoCoin%, settings.ini, TechacademySub, Tech_NoCoin
Critical, off
return

Missionsettings: ;任務設定
Critical
Guicontrolget, MissionSub
Iniwrite, %MissionSub%, settings.ini, MissionSub, MissionSub
Critical, off
return

Othersettings: ;其他設定
Critical
Guicontrolget, CheckUpdate
Guicontrolget, GuiHideX
Guicontrolget, EmulatorCrushCheck
Guicontrolget, AutoLogin
Guicontrolget, SetGuiBGcolor
Guicontrolget, SetGuiBGcolor2
Guicontrolget, DebugMode
Guicontrolget, DwmMode
Guicontrolget, GdiMode
Guicontrolget, AHKMode
Guicontrolget, CloneWindowforDWM
Guicontrolget, SendFromAHK
Guicontrolget, SendFromADB
Guicontrolget, Value_Err0
Guicontrolget, Value_Err0BarUpdate
Guicontrolget, Value_Err1
Guicontrolget, Value_Err1BarUpdate
Guicontrolget, Value_Pic
Guicontrolget, Value_PicBarUpdate
Iniwrite, %CheckUpdate%, settings.ini, OtherSub, CheckUpdate
Iniwrite, %GuiHideX%, settings.ini, OtherSub, GuiHideX
Iniwrite, %EmulatorCrushCheck%, settings.ini, OtherSub, EmulatorCrushCheck
Iniwrite, %AutoLogin%, settings.ini, OtherSub, AutoLogin
Iniwrite, %SetGuiBGcolor%, settings.ini, OtherSub, SetGuiBGcolor
Iniwrite, %SetGuiBGcolor2%, settings.ini, OtherSub, SetGuiBGcolor2
Iniwrite, %DebugMode%, settings.ini, OtherSub, DebugMode
Iniwrite, %DwmMode%, settings.ini, OtherSub, DwmMode
Iniwrite, %GdiMode%, settings.ini, OtherSub, GdiMode
Iniwrite, %AHKMode%, settings.ini, OtherSub, AHKMode
Iniwrite, %CloneWindowforDWM%, settings.ini, OtherSub, CloneWindowforDWM
Iniwrite, %SendFromAHK%, settings.ini, OtherSub, SendFromAHK
Iniwrite, %SendFromADB%, settings.ini, OtherSub, SendFromADB
Iniwrite, %Value_Err0%, settings.ini, OtherSub, Value_Err0
Iniwrite, %Value_Err1%, settings.ini, OtherSub, Value_Err1
Iniwrite, %Value_Pic%, settings.ini, OtherSub, Value_Pic
Iniwrite, %MainsubTimer%, settings.ini, OtherSub, MainsubTimer

Err0_V := if (Value_Err0!=0) ? Round(Value_Err0/100, 2) : 0.00
Err1_V := if (Value_Err1!=0) ? Round(Value_Err1/100, 2) : 0.00
Value_Pic := if Value_Pic!=0 ? Round(Value_Pic/10, 2) : 0.00
Guicontrol, ,Value_Err0BarUpdate, %Err0_V%
Guicontrol, ,Value_Err1BarUpdate, %Err1_V%
Guicontrol, ,Value_PicBarUpdate, %Value_Pic%
Global AutoLogin, DebugMode, DwmMode, GdiMode, AHKMode, CloneWindowforDWM, SendFromAHK, SendFromADB, Err0_V, Err1_V, Value_Pic
Critical, off
return

Emulatorsettings:
Guicontrolget, Ldplayer3
Guicontrolget, Ldplayer4
Guicontrolget, NoxPlayer5
Iniwrite, %Ldplayer3%, settings.ini, EmulatorSub, Ldplayer3
Iniwrite, %Ldplayer4%, settings.ini, EmulatorSub, Ldplayer4
Iniwrite, %NoxPlayer5%, settings.ini, EmulatorSub, NoxPlayer5
Global Ldplayer3, Ldplayer4, NoxPlayer5
if (Ldplayer4 or NoxPlayer5)
{
	IniRead, EmCheckText, settings.ini, EmCheckText, EmCheckText
	if (EmCheckText!=1)
	{
		Text := "如使用雷電4.0或夜神模擬器遇到問題，`n`n"
		. "作者並不會特別進行維護，`n`n"
		. "有興趣的人可以研究相容各模擬器的版本或方式。`n`n"
		. "另請注意:`n`n"
		. "1. 因為雷電4.0有偷偷減少繪圖bits以提高流暢度，`n"
		. "　故一定要調整文字/背景容許誤差，否則必定卡住。`n`n"
		. "2. 使用夜神模擬器將導致自動重啟及ADB點擊功能失效。"
		EmCheckText := "不再提示"
		MsgBoxEx(Text, "提示", "OK", 5, EmCheckText, "", 0, 0, "s11 c0x000000", "Segoe UI")
	}
	If (EmCheckText=1)
	{
		IniWrite, 1, settings.ini, EmCheckText, EmCheckText
	}
}
Text := "切換模擬器版本，等待自動重啟。"
MsgBoxEx(Text, "設定精靈", "", [229, "imageres.dll"], "", "-SysMenu AlwaysOnTop", WinExist("A"), 2, "s11 c0x000000", "Segoe UI")
reload
return

MainsubTimersettings:
Critical
Guicontrolget, MainsubTimer
Guicontrol, ,MainsubTimerBarUpdate, %MainsubTimer%
if (Is_Start=1){
	MainsubTime := MainsubTimer*1000
	Settimer, Mainsub, %MainsubTime%
}
Critical, off
return

exitsub:
Critical
WindowName = Azur Lane - %title%
wingetpos, azur_x, azur_y,, WindowName
iniwrite, %azur_x%, settings.ini, Winposition, azur_x
iniwrite, %azur_y%, settings.ini, Winposition, azur_y
if (substr(A_osversion, 1, 1)=7) {
	DllCall("dwmapi\DwmEnableComposition", "uint", 1)
}
exitapp
Critical, off
return

Showsub:
Gui, show
return

CloneWindowSub:
Gui, CloneWindow:New, -Caption +ToolWindow, CloneWindow-%title% ;創造一個GUI
Gui, CloneWindow:Show, w1318 h758,  ;創造一個GUI
if !(debugMode)
	WinSet, Transparent, 0, CloneWindow-%title%
CloneTitle = CloneWindow-%title%
CloneWindow := WinExist(CloneTitle)
Global CloneTitle, CloneWindow
DC := DllCall("user32.dll\GetDCEx", "UInt", CloneWindow, "UInt", 0, "UInt", 2)
Settimer, CloneWindowSub2, %MainsubTime%
return

CloneWindowSub2:
DllCall("User32.dll\PrintWindow", "Ptr", UniqueID, "Ptr", DC, "UInt", 2)
return

HexadecimalSub:
MsgBox, 8228, 設定精靈, 即將前往色票工具網站：https://color.adobe.com/zh/create
ifMsgBox Yes 
	Run, https://color.adobe.com/zh/create
return

GuiClose:
if GuiHideX {
	;~ Traytip, 訊息, 　`nAzurLane (%title%) 於背景執行中!`n　, 1
	Gui, Hide
	Text = AzurLane - %title% `n`n於背景執行中
	MsgBoxEx(Text, "通知", "", [188, "imageres.dll"], "", "-SysMenu", 0, 1.5, "s12 c0x000000", "Segoe UI", "0xFFFFFF")
} else {
	WindowName = Azur Lane - %title%
	wingetpos, azur_x, azur_y,, WindowName
	iniwrite, %azur_x%, settings.ini, Winposition, azur_x
	iniwrite, %azur_y%, settings.ini, Winposition, azur_y
	if (substr(A_osversion, 1, 1)=7) {
		DllCall("dwmapi\DwmEnableComposition", "uint", 1)
	}
	ExitApp
}
return

guicontrols: ;關閉某些按鈕，避免更動
Guicontrol, disable, Start
Guicontrol, disable, title
Guicontrol, disable, emulatoradb
Guicontrol, disable, EmulatorCrushCheck
Guicontrol, disable, BattleTimes2
Guicontrol, disable, Timetobattle1
Guicontrol, disable, Timetobattle2
Guicontrol, disable, StopBattleTime3
Guicontrol, disable, CloneWindowforDWM
Guicontrol, disable, ResetOperationTime2
Guicontrol, disable, Ldplayer3
Guicontrol, disable, Ldplayer4
Guicontrol, disable, NoxPlayer5
return

Start:
if (substr(A_osversion, 1, 1)=7) {
	LogShow("偵測到系統為Windows7，關閉AERO")
	DllCall("dwmapi\DwmEnableComposition", "uint", 0)
}
gosub, TabFunc
gosub, guicontrols
IfWinNotExist , %title%
	goto startemulatorsub
Winget, UniqueID,, %title%
Allowance = %AllowanceValue%
emulatoradb = %emulatoradb%
Global UniqueID
Global Allowance
Global emulatoradb
LogShow("開始！")
WinRestore,  %title%
WinMove,  %title%, , , , %EmulatorResolution_W%, %EmulatorResolution_H%
WinSet, Transparent, off, %title%
MainsubTime := MainsubTimer*1000
Settimer, Mainsub, %MainsubTime%
Settimer, WinSub, 3200
if (DWMmode and CloneWindowforDWM)
	gosub, CloneWindowSub
if (EmulatorCrushCheck and !Noxplayer5)
	Settimer, EmulatorCrushCheckSub, 60000
Is_Start := 1
return

ForumSub:
Run, https://github.com/panex0845/AzurLane/
return

DiscordSub:
Run, https://discord.gg/GFCRSap
return

IsUpdate:
Run, https://github.com/panex0845/AzurLane
return

IsUpdate2:
FileReadLine, ThisVersion, ChangeLog.txt, 1
Loop, Parse, ThisVersion
{
  If A_LoopField is Number
    OldVersion .= A_LoopField
}
if (OldVersion="") {
	LogShow2("------------------------------------------------------------------------------")
	message = `　　　ChangeLog檔案遺失，無法正確判斷目前版本，
	LogShow2(message)
	LogShow2(" ")
	message = `　　　　　請嘗試重新安裝本程式或手動更新。
	LogShow2(message)
	LogShow2("------------------------------------------------------------------------------")
	return
}
message = 檢查更新中，目前版本 v%OldVersion%。
LogShow(message)
VersionUrl := "https://raw.githubusercontent.com/panex0845/AzurLane/master/ChangeLog.md"
FileUrl := "https://github.com/panex0845/AzurLane/archive/master.zip"
UrlDownloadToFile, %VersionUrl%, Temp.txt
FileReadLine, ThisVersion, Temp.txt, 1
Loop, Parse, ThisVersion
{
  If A_LoopField is Number
    NewVersion .= A_LoopField
}
filename = AzurLane v%NewVersion%.zip
OnMessage(0x53, "Update_HELP")
if (FileExist(filename) and NewVersion!=OldVersion)
{
	
	LogShow2("------------------------------------------------------------------------------")
	message = `　　更新檔 %filename% 已下載完畢，請手動安裝。
	LogShow2(message)
	LogShow2("------------------------------------------------------------------------------")
}
else if (NewVersion!=OldVersion) {
	Gui +OwnDialogs
	MsgBox, 0x4041, 設定精靈, 目前版本：%OldVersion%`n`nGitHub版本：%NewVersion%，是否自動下載？
	IfMsgBox OK
	{
		Guicontrol, disable, Start
		LogShow("下載更新檔中，請稍後…")
		FileDelete, temp.txt
		UrlDownloadToFile, %FileUrl%, %filename%
		TrayTip, AzurLane, 更新檔下載完畢，`n`n請手動安裝更新檔。
		message = `　　更新檔 %filename% 已下載完畢，請手動安裝。
		LogShow2("------------------------------------------------------------------------------")
		LogShow2(message)
		LogShow2("------------------------------------------------------------------------------")
		Guicontrol, enable, Start
	}
	else IfMsgBox Cancel
	{
		LogShow("取消")
	}
}
else {
	LogShow("目前是最新版本")
}
FileDelete, temp.txt
NewVersion := ""
OldVersion := ""
return

AdjustGetPixelMode:
MsgBox, 262208, 設定精靈, 請回到遊戲首頁後再按下確認
LogShow("開始調整")
WinRestore,  %title%
WinMove,  %title%, , , , %EmulatorResolution_W%, %EmulatorResolution_H%
sleep 200
Position1 := DwmGetpixel(12, 200) ;左上角稜形方塊 16777215
Position11 := GdiGetpixel(12, 200) ;左上角稜形方塊 4294967295
Logshow(Position1)
Logshow(Position11)
Position2 := DwmGetpixel(576, 64) ;上方汽油桶 3224625
Position22 := GdiGetpixel(576, 64) ;上方汽油桶 4281414705
Logshow(Position2)
Logshow(Position22)
Position3 := DwmGetpixel(794, 78) ;上方金幣 16234050
Position33 := GdiGetpixel(794, 78) ;上方金幣 4294424130
Logshow(Position3)
Logshow(Position33)
Position4 := DwmGetpixel(997, 64) ;上方紅尖尖 16729459
Position44 := GdiGetpixel(997, 64) ;上方紅尖尖 4294919539
Logshow(Position4)
Logshow(Position44)
Position5 := DwmGetpixel(976, 429) ;編隊按鈕 5421815
Position55 := GdiGetpixel(976, 429) ;編隊按鈕 4283611895
Logshow(Position5)
Logshow(Position55)
Position6 := DwmGetpixel(1149, 448) ;出擊按鈕 14592594
Position66 := GdiGetpixel(1149, 448) ;出擊按鈕 4292782674
Logshow(Position6)
Logshow(Position66)
if (Position1=16777215 and Position2=3224625 and Position3=16234050 and Position4=16729459 and Position5=5421815 and Position6=14592594)
{
	LogShow("不需調整")
	AllowanceValue := 2000
	Iniwrite, %AllowanceValue%, settings.ini, emulator, AllowanceValue
}
else 	if (Position11=4294967295 and Position22=4281414705 and Position33=4294424130 and Position44=4294919539 and Position55=4283611895 and Position66=4292782674)
{
	LogShow("GdiGetpixel = True")
	LogShow("請手動按下停止鍵")
	Iniwrite, 1, settings.ini, emulator, UseGdiGetpixel
}
else
{
	LogShow("出現不可預期的錯誤")
	LogShow("請手動按下停止鍵")
}
return

EmulatorCrushCheckSub:
GameCrushed_1920x1080 := [DwmCheckcolor(426, 101, 908287), DwmCheckcolor(1167, 49, 16777215), DwmCheckcolor(635, 631, 16777215), DwmCheckcolor(438, 102, 16768256)]
GameCrushed_1280x720 := [DwmCheckcolor(432, 115, 907775) and DwmCheckcolor(446, 116, 16768000) and DwmCheckcolor(441, 120, 16201485) and DwmCheckcolor(633, 596, 16777215)]
if (CheckArray2(GameCrushed_1920x1080*) or CheckArray2(GameCrushed_1280x720*)) ;遊戲閃退 位於模擬器桌面
{
	LogShow("=========遊戲閃退，重啟=========")
	EmulatorCrushCheckCount := VarSetCapacity
	iniwrite, "=======遊戲閃退，自動重啟=======", settings.ini, OtherSub, AutostartMessage
	iniwrite, 1, settings.ini, OtherSub, Autostart
	runwait, %Consolefile% quit --index %emulatoradb% , %ldplayer%, Hide
	sleep 10000
	reload
}
Loop, 3
{
	EmulatorCrushCheckCount++
	CheckPostion%EmulatorCrushCheckCount% := [DwmGetpixel(50, 95), DwmGetpixel(582, 74), DwmGetpixel(961, 242),DwmGetpixel(320, 215), DwmGetpixel(778, 583), DwmGetpixel(312, 446), DwmGetpixel(164, 173)]
	For k, v in CheckPostion%EmulatorCrushCheckCount%
		s%EmulatorCrushCheckCount%%k% := v
	sleep 100
	if (EmulatorCrushCheckCount=3)
	{
		Loop, 3
		{
			Check1%A_index% := CheckPostion%A_index%[1]
			Check2%A_index% := CheckPostion%A_index%[2]
			Check3%A_index% := CheckPostion%A_index%[3]
			Check4%A_index% := CheckPostion%A_index%[4]
			Check5%A_index% := CheckPostion%A_index%[5]
			Check6%A_index% := CheckPostion%A_index%[6]
			Check7%A_index% := CheckPostion%A_index%[7]
		}
		if (Check11=Check12 and Check11=Check13)
			if (Check21=Check22 and Check21=Check23)
				if (Check31=Check32 and Check31=Check33)
					if (Check41=Check42 and Check41=Check43)
						if (Check51=Check52 and Check51=Check53)
							if (Check61=Check62 and Check61=Check63)
								if (Check71=Check72 and Check71=Check73)
								{
									Checkzz++
									if (Checkzz=9)
									{
										if (DebugMode)
											Capture() 
										LogShow("=========模擬器當機，重啟=========")
										EmulatorCrushCheckCount := VarSetCapacity
										iniwrite, "=========模擬器當機，自動重啟=========", settings.ini, OtherSub, AutostartMessage
										iniwrite, 1, settings.ini, OtherSub, Autostart
										runwait, %Consolefile% quit --index %emulatoradb% , %ldplayer%, Hide
										sleep 10000
										reload
									}
									EmulatorCrushCheckCount := VarSetCapacity
									return
								}
		EmulatorCrushCheckCount := VarSetCapacity
	}
}
Checkzz := VarSetCapacity
return

ResetOperationSub:
GuiControl, disable, ResetOperation
OperationDone := VarSetCapacity  ;重置演習判斷
iniWrite, 0, settings.ini, Battle, OperationYesterday
LogShow("演習已被重置")
sleep 200
GuiControl, Enable, ResetOperation
return

ResetOperationClock:
ResetOperationDone := VarSetCapacity
return

Mainsub: ;優先檢查出擊以外的其他功能
if (Noxplayer5)
{
	LDplayerCheck := Find(x, y, 0, 0, 60, 35, NoxPlayerLogo) 
} else {
	LDplayerCheck := Find(x, y, 0, 0, 60, 35, LdPlayerLogo) 
}
if (LDplayerCheck=0) {
	LogShow("無法正確偵測到模擬器。")
	sleep 1000
}
Formattime, Nowtime, ,HHmm
if !LDplayerCheck ;檢查模擬器有沒有被縮小
{
	goto, Winsub
}
else if LDplayerCheck
{
	if (NowTime=0001 or Nowtime=1301)
	{
		DailyDone := VarSetCapacity ;重置每日判斷
		if !(ResetOperationTime)
		{
			OperationDone := VarSetCapacity  ;重置演習判斷
			ResetOperationDone := 1
		}
	}
	if (ResetOperationTime and ResetOperationDone<1) ;如果有勾選自動重置演習
	{
		ResetOperationTime3 := StrSplit(ResetOperationTime2, ",")
		for k, Resettime in ResetOperationTime3
		{
			if (NowTime=Resettime)
			{
				OperationDone := VarSetCapacity  ;重置演習判斷
				iniread, OperationYesterday, settings.ini, Battle, OperationYesterday
					if (OperationYesterday>=1)
					{
						LogShow("自動重置演習。")
					}
				iniWrite, 0, settings.ini, Battle, OperationYesterday
				ResetOperationDone := 1
				Settimer, ResetOperationClock, -61000
				if (Find(x, y, 734, 401, 834, 461, MainPage_Btn_Formation))
				{
					C_Click(1080, 403)
					sleep 2000
				}
			}
		}
	}
	Formation := Find(x, y, 734, 401, 834, 461, MainPage_Btn_Formation) ;編隊BTN
	WeighAnchor := Find(x, y, 996, 362, 1096, 422, MainPage_Btn_WeighAnchor) ;出擊BTN
	MissionCheck := Find(x, y, 868, 680, 968, 740, MainPage_MissionDone) ;任務完成
	MissionCheck2 :=Find(x, y, 2, 154, 102, 214, MainPage_N_Done)
	if (MissionSub and (MissionCheck or MissionCheck2)) ;任務 or 軍事委託
	{
		sleep 500
		gosub, MissionSub
		sleep 500
	}
	Living_AreaCheck := Find(x, y, 580, 681, 680, 741, "|<>*167$7.zswSD7XlswTzjXvk") ;生活圈驚嘆號
	if (AcademySub and Living_AreaCheck and Formation and WeighAnchor and AcademyDone<1) ;學院
	{
		sleep 500
		Random, x, 501, 624
		Random, y, 713, 738
		C_Click(x, y)
		Loop
		{
			if (Find(x, y, 403, 472, 503, 532, WaitingforAcademy)) ;等待進入學院/後宅選單
				break
			sleep 500
		}
		sleep 500
		if (Find(x, y, 479, 239, 579, 299, AcademyDoneIco)) ;
		{
			LogShow("執行學院任務！")
			gosub, AcademySub
		}
		else 
		{
			Random, x, 570, 680
			Random, y, 285, 500
			C_Click(x, y)
			AcademyDone := 1
			Settimer, AcademyClock, -900000 
			sleep 1500
		}
		sleep 500
	}
	Living_AreaCheck := Find(x, y, 580, 681, 680, 741, "|<>*167$7.zswSD7XlswTzjXvk") ;生活圈驚嘆號
	if (DormSub and Living_AreaCheck and Formation and WeighAnchor and DormDone<1)  ;後宅
	{
		sleep 500
		Random, x, 501, 624
		Random, y, 713, 738
		C_Click(x, y)
		Loop
		{
			if (Find(x, y, 403, 472, 503, 532, WaitingforAcademy)) ;等待進入學院/後宅選單
				break
			sleep 500
		}
		sleep 500
		if (Find(x, y, 907, 238, 1007, 298, DormIco)) ;
		{
			LogShow("執行後宅任務！")
			gosub, DormSub
		}
		else 
		{
			Random, x, 570, 680
			Random, y, 285, 500
			C_Click(x, y)
			sleep 1500
			DormDone := 1
			Settimer, DormClock, -900000
		}
		sleep 500
	}
	TechacademyCheck := Find(x, y, 740, 684, 840, 744, MainPage_ResearchDeptDone)
	if (TechacademySub and TechacademyCheck and Formation and WeighAnchor and TechacademyDone<1)
	{
		sleep 500
		Random, x, 660, 775
		Random, y, 713, 738
		C_Click(x, y)
		sleep 1000
		Loop
		{
			if (Find(x, y, 101, 33, 201, 93, TechPage_ResearchDept))
				break ;等待進入科研選單
			if Find(x, y, 716, 683, 816, 743, MainPage_ResearchDeptDone) 
			{
				Random, x, 660, 775
				Random, y, 713, 738
				C_Click(x, y)
			}
		}
		gosub, TechacademySub
	}
	if ((AnchorSub) and (!Living_AreaCheck or AcademyDone=1 or !AcademySub) and (!Living_AreaCheck or DormDone=1 or !DormSub))  ;出擊
	{
		gosub, AnchorSub
	}
}
if ((Timetobattle) and (Nowtime=TimetoBattle1 or Nowtime=TimetoBattle2) and RunOnceTime<1)
{
	StopAnchor := 0
	LogShow("重新出擊")
	Timetobattle11 := Timetobattle1+1
	Timetobattle22 := Timetobattle2+1
	RunOnceTime := 1
}
else if (RunOnceTime=1 and (Nowtime=Timetobattle11 or Nowtime=Timetobattle11))
{
	RunOnceTime := VarSetCapacity
	Timetobattle11 := VarSetCapacity
	Timetobattle22 := VarSetCapacity
}
return

clock:
StopAnchor := 0
return

ReAnchorSub:
Guicontrol, disable, ReAnchorSub
LogShow("再次出擊！")
gosub, TabFunc
StopAnchor := VarSetCapacity
StopBattleTimeCount := VarSetCapacity
WeighAnchorCount := VarSetCapacity
sleep 1000
Guicontrol, enable, ReAnchorSub
return


TechacademySub: ;科研
Techacademy_Done := Find(x, y, 396, 471, 496, 531, TechPage_TechDone)
Shipworks_Done := 0 ;暫時無用
if (Techacademy_Done) ;軍部研究室OK
{
	LogShow("進入軍部科研室")
	Random, x, 247, 388
	Random, y, 331, 479
	C_Click(x, y)
	sleep 1000
	科研目標 := [定向研發, 資金募集, 數據蒐集, 艦裝解析, 研究委託, 試驗品募集, 基礎研究, 0]
	Loop
	{
		if (Find(x, y, 612, 601, 712, 661, TechPage_TechComplete)) ;研發已完成(綠色)
		{
			C_Click(614, 282)
		}
		if (Find(x, y, 611, 602, 711, 662, TechPage_ViewDetails)) ;等待研發(查看詳情)
		{
			C_Click(633, 281)
		}
		if (Find(x, y, 450, 130, 830, 330, Touch_to_Contunue)) ;點擊繼續
		{
			C_Click(x, y)
		}
		if (Find(x, y, 432, 588, 532, 648, TechPage_StartTech)) ;開始研發
		{
			for k, v in 科研目標
			{
				if (Find(x, y, 310, 125, 420, 190, v))
					break
			}
			if (k=1 and !TechTarget_01) or (k=2 and !TechTarget_02) or (k=3 and !TechTarget_03) or (k=3 and !TechTarget_03) or (k=4 and !TechTarget_04) or (k=5 and !TechTarget_05) or (k=6 and !TechTarget_06) or (k=7 and !TechTarget_07) 
			{
				if k=1
					k=定向研發
				if k=2 
					k=資金募集
				if k=3
					k=數據蒐集
				if k=4 
					k=艦裝解析
				if k=5 
					k=研究委託
				if k=6 
					k=試驗募集
				if k=7 
					k=基礎研究
				message = 項目 %k% 不研發，更換科研項目。
				LogShow(message)
				Random, x, 320, 980
				Random, y ,690, 720
				C_Click(x, y)
				Loop
				{
					if (Find(x, y, 613, 602, 713, 662, 查看詳情)) {
						C_Click(895, 270)
						break
					}
					sleep 300
				}
			}
			else if (k=8)
			{
				LogShow("科研項目發生錯誤(文字搜尋失敗)")
				sleep 5000
				C_Click(690, 717)
				sleep 1000
				C_Click(885, 252)
			}
			if (Tech_NoCoin and Tech_NoCoincount<5)
			{
				sleep 1500
				if (Find(x, y, 800, 420, 1070, 510, Tech_NoCoinIco))
				{
					Tech_NoCoincount++
					message = 不使用金幣，嘗試切換研發項目 %Tech_NoCoincount%
					LogShow(message)
					C_Click(698, 705)
					sleep 1000
					C_Click(888, 248)
				}
				else
				{
					LogShow("開始研發")
					C_Click(507, 617)
					sleep 1000
					if (Find(x, y, 429, 330, 529, 390, TechPage_Is_Teching))
					{
						LogShow("已經有研發科目，嘗試切換項目")
						C_Click(698, 705)
						sleep 1000
						C_Click(888, 248)
					}
				}
			}
			else
			{
				LogShow("開始研發")
				C_Click(507, 617)
				sleep 1000
				if (Find(x, y, 429, 330, 529, 390, TechPage_Is_Teching))
				{
					LogShow("已經有研發科目，嘗試切換項目")
					C_Click(698, 705)
					sleep 1000
					C_Click(888, 248)
				}
			}
		}
		if (DwmCheckcolor(438, 618, 9742022) and DwmCheckcolor(579, 618, 9740998) and DwmCheckcolor(532, 618, 13552598))  or (DwmCheckcolor(438, 618, 8692422) and DwmCheckcolor(579, 618, 8691398) and DwmCheckcolor(532, 618, 13028302))  ;缺少研發道具
		{
			LogShow("缺少研究道具")
			C_Click(657, 713)
			sleep 1000
			C_Click(885, 265)
		}
		if (Find(x, y, 343, 224, 934, 532, 需要消耗))
		{
			C_Click(791, 552)
		}
		if (Find(x, y, 422, 587, 522, 647, TechPage_Stop_Teching)) ;已經開始研發(停止研發按鈕)
		{
			LogShow("離開軍部科研室")
			Tech_NoCoincount := VarSetCapacity
			C_Click(714, 712)
			sleep 500
			C_Click(1227, 71)
			Loop
			{
				if (Find(x, y, 734, 401, 834, 461, MainPage_Btn_Formation))
					break
				sleep 500
			}
			break
		}
		sleep 500
	}
}
else
{
	C_Click(1232, 69) ;回首頁
}
TechacademyDone := 1
Settimer, TechacademyClock, -900000
return

TechacademyClock:
TechacademyDone := VarSetCapacity
return

Autopuzzle:
夢中茶會:="|<>*221$71.00000000000003Vk007000A43zzzU0C000w8Dzzz00Q00Tzkzzzy11zU1zzUwxw07zzs3zz0zzzUDzzs0761zzzUzzzs0Dw3zSD1zD3k0zs7zzw3kS3kDzk7zzU7Uw7Uzi01zw0D1sD7wQ1zzzkS3kSDzy3zzzkw7VsDzw7zU7VyD7k7zsDTzj1zzzU7rUTzzw1zzy03j0Tzzk0zzk0Dz0DES003s00yy0Rns007U07ts0nzU00D00T3kDzw000S00w7UTzU000w00kC0Tk0000s0000000000000001"
if (Find(x, y, 1064, 285, 1200, 334, 夢中茶會))
{
	ClickList = D3 C3 C2 D2 D1 C1 C2 D2 D3 D4 C4 B4 A4 A3 A2 B2 B3 C3 C2 C1 B1 A1 A2 B2 B1 C1 D1 D2 D3 D4 C4 C3 C2 B2 B3 B4 C4 C3 D3 D2 C2 C3 B3 A3 A4 B4 B3 C3 D3 D4
	ClickList := StrSplit(ClickList, " ")
	for k, v in ClickList
	{
		List%A_Index% := ClickList[A_Index]
		List%A_index% := StrSplit(List%A_index%, "")
		if (List%A_index%[1]="A")
			y:= 225
		else if (List%A_index%[1]="B")
			y:= 318
		else if (List%A_index%[1]="C")
			y:= 412
		else if (List%A_index%[1]="D")
			y:= 510
		if (List%A_index%[2]="1")
			x:= 389
		else if (List%A_index%[2]="2")
			x:= 531
		else if (List%A_index%[2]="3")
			x:= 662
		else if (List%A_index%[2]="4")
			x:= 800
		ControlClick, x%x% y%y%, ahk_id %UniqueID%,,,, NA
		sleep 100
	}
} else {
	MsgBox, 16, 錯誤, 請移動到拼圖介面
}
return

AnchorSub: ;出擊
if (Find(x, y, 996, 362, 1096, 422, MainPage_Btn_WeighAnchor) and StopAnchor<1)
{
	Random, x, 1025, 1145
	Random, y, 356, 453
	C_Click(x,y) ;於首頁點擊點擊右邊"出擊"
	sleep 2000
}
if (Find(x, y, 164, 42, 264, 102, Formation_Upp) and Find(x, y, 0, 587, 86, 647, Formation_Tank)) ;在出擊的編隊頁面
{
    if (Find(x, y, 726, 127, 826, 187, Auto_Battle_Off) and Autobattle="自動") ;Auto Battle >> ON
    {
		LogShow("開啟自律模式")
        C_Click(819, 160)
    }
	else if (Find(x, y, 728, 128, 828, 188, Auto_Battle_On) and Autobattle="半自動")
	{
		LogShow("開啟半自動模式")
		C_Click(819, 160)
	}
	else if (Find(x, y, 728, 128, 828, 188, Auto_Battle_On) and Autobattle="關閉")
	{
		LogShow("關閉自律模式")
		C_Click(819, 160)
	}
	if (!Find(x, y, 79, 555, 179, 615, None_Kit) and (Use_FixKit)) ;如果有維修工具
	{
		Loop, 100
		{
			if (!Find(x, y, 79, 555, 179, 615, None_Kit)) ;如果有維修工具
			{
				C_Click(119, 570) ;使用維修工具
				sleep 500
			}
			if (Find(x, y, 707, 451, 807, 511, Using_Kit)) ; 跳出訊息選單
			{
				C_Click(x, y) ;點擊使用
				sleep 1000
			}
			if (Find(x, y, 479, 452, 579, 512, Using_kit_Cancel)) ;如果HP是滿的
			{
				C_Click(x, y) ;點擊取消
			}
			sleep 300
			if (Find(x, y, 164, 42, 264, 102, Formation_Upp)) ;回到編隊頁面
			{
				break
			}	
		}
	}
	AnchorTimes++ ;統計出擊次數
	Global AnchorTimes, switchparty
	FightRoundsDoCount++ ;統計當艦隊A每出擊
	rate := Round(AnchorFailedTimes/AnchorTimes*100, 2)
	GuiControl, ,AnchorTimesText, 出擊次數：%AnchorTimes% 次 ｜ 全軍覆沒：%AnchorFailedTimes% 次 ｜ 翻船機率：%rate%`%
	LogShow("出擊～！")
    Random, x, 1056, 1225
	Random, y, 656, 690
	C_Click(x, y) ;於編隊頁面點擊右下 "出擊"
	sleep 500
	shipsfull()
	IsDetect := VarSetCapacity
    TargetFailed := VarSetCapacity
    TargetFailed2 := VarSetCapacity
    TargetFailed3 := VarSetCapacity
    TargetFailed4 := VarSetCapacity
    TargetFailed5 := VarSetCapacity
    TargetFailed6 := VarSetCapacity
	Plane_TargetFailed1 := VarSetCapacity
    BossFailed := VarSetCapacity
    BulletFailed := VarSetCapacity
    QuestFailed := VarSetCapacity
	SearchLoopcount := VarSetCapacity
	SearchFailedMessage := VarSetCapacity
	SearchLoopcountFailed2 := VarSetCapacity
    if (Find(x, y, 700, 500, 880, 600, Academy_BTN_Confirm)) ;心情低落
    {
		if mood=強制出戰
		{
			LogShow("老婆心情低落：提督SAMA沒人性")
			C_Click(x, y)
		}
		else if mood=不再出擊
		{
			LogShow("老婆心情低落，不再出擊")
			takeabreak := 600
			C_Click(492, 555)
			sleep 3000
			C_Click(1227, 67)
			StopAnchor := 1
		}
		else if mood=休息1小時
		{
			LogShow("老婆心情低落：休息1小時")
			takeabreak := 600
			C_Click(492, 555)
			sleep 3000
			C_Click(1227, 67)
			StopAnchor := 1
			settimer, clock,  -3600000
		}
		else if mood=休息2小時
		{
			LogShow("老婆心情低落：休息2小時")
			takeabreak := 600
			C_Click(492, 555)
			sleep 3000
			C_Click(1227, 67)
			StopAnchor := 1
			settimer, clock, -7200000
		}
		else if mood=休息3小時
		{
			LogShow("老婆心情低落：休息3小時")
			takeabreak := 600
			C_Click(492, 555)
			sleep 3000
			C_Click(1227, 67)
			StopAnchor := 1
			settimer, clock, -10800000
		}
		else if mood=休息5小時
		{
			LogShow("老婆心情低落：休息5小時")
			takeabreak := 600
			C_Click(492, 555)
			sleep 3000
			C_Click(1227, 67)
			StopAnchor := 1
			settimer, clock, -14400000
		}
		else
		{
			LogShow("心情低落選項出錯")
		}
    }
    if (DwmCheckcolor(543, 361, 15724527) and DwmCheckcolor(784, 63, 16773987) and DwmCheckcolor(1000, 63, 16729459)) ;石油不足
    {
        LogShow("石油不足，停止出擊到永遠！")
        C_Click(1230, 74)
		StopAnchor := 1
    }
}
if (Find(x, y, 750, 682, 850, 742, Battle_Map))
{
	if (StopAnchor=1)
	{
		LogShow("停止出擊中，返回上一頁")
		sleep 500
		C_Click(56, 86)
		return
	}
	if (IsDetect<1)
		LogShow("偵查中。")
	sleep 1000
	MapX1 := 130, MapY1 := 130, MapX2 :=1260, MapY2 := 670 ; //////////檢查敵方艦隊的範圍//////////
	;Mainfleet := 4287894561 ; ARGB 主力艦隊
	;~ FinalBoss := 4294920522 ; ARGB BOSS艦隊
	if (DwmCheckcolor(1186, 565, 5418619) and DwmCheckcolor(1228, 565, 5418619) and DwmCheckcolor(1273, 565, 5418619))
	{ ;陣容鎖定已被開啟
		LogShow("關閉陣容鎖定")
		Random, x, 1197, 1257
		Random, y, 537, 551
		C_Click(x, y)
	}
	if (NowHP>=1 and Retreat_LowHp2 and SwitchParty<1 and (NowHp<=Retreat_LowHp2Bar))
	{
		Message = 旗艦HP剩餘於 %NowHP%`%＜%Retreat_LowHp2Bar%`%，%Retreat_LowHp2Do%。
		LogShow(Message)
		if (Retreat_LowHp2Do="更換隊伍")
		{
			SwitchParty := 1
			sleep 500
			C_Click(1030, 713)
			sleep 2000
		}
		else if (Retreat_LowHp2Do="撤退")
		{
			sleep 1000
			C_Click(827, 715)
			sleep 1000
			C_Click(785, 548)
			sleep 2000
			return
		}
	}
	if (FightRoundsDo and ((FightRoundsDoCount=FightRoundsDo2) or (FightRoundsDo2="或沒子彈" and GdipImageSearch(n, n, "img/Bullet_None.png", 10, SearchDirection, 129, 96, 1271, 677))) and FightRoundsDone<1 and SwitchParty<1)
	{
		FightRoundsDone := 1
		if FightRoundsDo3=撤退
		{
			FightRoundsText = 艦隊Ａ已出擊%FightRoundsDoCount%次，%FightRoundsDo3%
			LogShow(FightRoundsText)
			sleep 1000
			C_Click(834, 716)
			sleep 2000
			C_Click(791, 556)
			return
		}
		else if (GdipImageSearch(x, y, "img/targetboss_1.png", 0, SearchDirection, MapX1, MapY1, MapX2, MapY2) and BossFailed<1) and (Bossaction="優先攻擊－切換隊伍")
		{
			;如果出現BOSS則不做事 避免出現BOSS導致多打道中
			LogShow("偵查到BOSS，等待切換隊伍")
			TargetFailed := 1
			TargetFailed2 := 1
			TargetFailed3 := 1
			TargetFailed4 := 1
		}
		else if FightRoundsDo3=更換艦隊Ｂ
		{
			SwitchParty := 1
			FightRoundsText = 艦隊Ａ已出擊%FightRoundsDo2%次，%FightRoundsDo3%
			LogShow(FightRoundsText)
			sleep 1000
			C_Click(1034, 713) ;點擊更換艦隊
			sleep 1500
		}
	}
	if (AlignCenter) and !(GdipImageSearch(x, y, "img/Map_Lower.png", 1, 1, 150, 540, 650, 740)) and ((Bossaction="優先攻擊－當前隊伍" or Bossaction="優先攻擊－切換隊伍") and !(GdipImageSearch(n, m, "img/targetboss_1.png", 0, 1, MapX1, MapY1, MapX2, MapY2))) ; 嘗試置中地圖
	{
		if (AnchorChapter="異色1" or AnchorChapter="異色2")
		{
			Swipe(210, 228, 735, 400)
			sleep 300
		}
		Swipe(210, 228, 735, 423)
		sleep 300
		Swipe(477, 297, 1107, 596) ;往右下角拖曳
		Loop
		{
			x := 350, y := 220
			Random, xx, 0, 750
			Random, yy, 0, 400
			x1 := x+xx, y1 := y+yy
			x2 := x1-55, y2 := y1-110
			Swipe(x1, y1, x2, y2)
			AlignCenterCount++
			sleep 100
		} until (GdipImageSearch(x, y, "img/Map_Lower.png", 1, 1, 300, 550, 1000, 750)) or AlignCenterCount>8
		y1 := y-1
		y2 := y+1
		AlignCenterCount := VarSetCapacity
		Loop 
		{
			if (GdipImageSearch(x, y, "img/Map_Lower.png", 1, 1, 125, y1, 220, y2))
				break
			Random, y, 180, 650
			Swipe(650, y, 430, y)
			AlignCenterCount++
			sleep 100
		} until (GdipImageSearch(x, y, "img/Map_Lower.png", 1, 1, 125, y1, 220, y2)) or AlignCenterCount>6
		AlignCenterCount := VarSetCapacity
	}
	Loop, 100
	{
		sleep 300
		if (AnchorChapter=7 and AnchorChapter2=2) ;7-2從左邊開始偵查到右邊 提高拿到左邊"？"的機率
		{
			SearchDirection := 5
		}
		else
		{
			Random, SearchDirection, 1, 8
		}
		if (DwmCheckcolor(1102, 480, 16768842))
		{
			LogShow("關閉陣型列表")
			C_Click(1071, 476)
		}
		if (GdipImageSearch(x, y, "img/bullet.png", 105, SearchDirection, MapX1, MapY1, MapX2, MapY2) and GdipImageSearch(n, n, "img/Bullet_None.png", 10, SearchDirection, MapX1, MapY1, MapX2, MapY2) and bulletFailed<1 and Item_Bullet) ;只有在彈藥歸零時才會拾取
		{
			LogShow("嗶嗶嚕嗶～發現：子彈補給！")
			xx := x 
			yy := y + 80
			Loop, 3
			{
				if (xx<360 and yy<195)
				{
					Swipe(238,315,248,400)
					break
				}
				if (yy>660)
				{
					Swipe(238,400,248,315)
					break
				}
				if (Find(n, m, 750, 682, 850, 742, Battle_Map)) ;如果在限時(無限時)地圖
				{
					C_Click(xx, yy)
					if (Find(x, y, 495, 330, 530, 390, "|<>*200$8.zyT3kyTzzyT3kwD3kwD3kwD3kwD3kzy"))
					{
						bulletFailed++
						break
					}
					sleep 2000
				}
				if (Find(n, m, 0, 587, 86, 647, Formation_Tank)) ;規避失敗
				{
					Break
				}
				if (DwmCheckcolor(325, 358, 16250871)) ;獲得道具
				{
					C_Click(xx, yy)
					Break
				}
				BackAttack()
				sleep 1000
			}
			bulletFailed++
		}
		if (GdipImageSearch(x, y, "img/quest.png", 8, SearchDirection, MapX1, MapY1, MapX2, MapY2) and questFailed<1 and Item_Quest) ;
		{
			TakeQuest++
			Message = 嗶嗶嚕嗶～發現：神秘物資 %TakeQuest% 次！
			LogShow(Message)
			xx := x
			yy := y + 70
			Loop, 6
			{
				if (xx<360 and yy<195)
				{
					TakeQuest--
					Swipe(238,315,248,400)
					break
				}
				if (yy>660)
				{
					TakeQuest--
					Swipe(238,400,248,315)
					break
				}
				if (xx>1180 and yy>420)
				{
					TakeQuest--
					Swipe(750,300,650,300)
					break
				}
				if (Find(n, m, 750, 682, 850, 742, Battle_Map)) ;如果在限時(無限時)地圖
				{
					C_Click(xx, yy)
					sleep 300
					if (Find(n, m, 495, 330, 530, 390, "|<>*200$8.zyT3kyTzzyT3kwD3kwD3kwD3kwD3kzy"))
					{
						questFailed++
						TakeQuest--
						Message = 哎呀哎呀，前往神秘物資的路徑被擋住了！ 
						if (AnchorChapter=7 and AnchorChapter2=2 and xx<290 and yy<414)
						{
							yy := yy+100
							message = 前往神秘物資路徑受阻，攻擊下方部隊。
							LogShow(Message)
							Click_Fleet(xx, yy)
						}
						else 
						{
						LogShow(Message)
						}
						sleep 300
						break
					}
					sleep 2000
				}
				if (Find(n, m, 0, 587, 86, 647, Formation_Tank)) ;規避失敗
				{
					Message = 規避伏擊失敗。
					LogShow(Message)
					TakeQuest--
					Break
				}
				if (Find(n, m, 450, 130, 830, 330, Touch_to_Contunue)) ;獲得道具
				{
					C_Click(276, 619)
					Break
				}
				if (DwmCheckcolor(449, 359, 16249847)) ;撿到子彈
				{
					sleep 1000
					break
				}
				BackAttack()
				sleep 1000
			}
			sleep 300
			IsDetect := 1
			return
		}
		if (Take_ItemQuest and TakeQuest>=Take_ItemQuestNum) ;拾取神秘物資N次後撤退
		{
			Message = 已拾取神秘物資 %TakeQuest% 次，撤退。
			LogShow(Message)
			sleep 1000
			C_Click(827, 715)
			sleep 1000
			C_Click(785, 548)
			sleep 2000
			return
		}
		if (GdipImageSearch(x, y, "img/targetboss_1.png", 0, SearchDirection, MapX1, MapY1, MapX2, MapY2) and BossFailed<1) and (Bossaction="優先攻擊－當前隊伍" or Bossaction="優先攻擊－切換隊伍" or Bossaction="撤退") ;ＢＯＳＳ
		{
			if Bossaction=撤退
			{
				LogShow("嗶嗶嚕嗶～發現：最終BOSS，撤退！")
				C_Click(830, 710) ;點擊撤退
				sleep 1000
				C_Click(791, 543) ;點擊確定
				return
			}
			else if (x<340 and y<190) ;如果在左上角可能誤點
			{
				LogShow("BOSS位於左上角，拖曳畫面！")
				Random, y, 200, 600
				Swipe(370, y, 700, y)
				return
			}
			else if Bossaction=優先攻擊－當前隊伍
			{
				LogShow("嗶嗶嚕嗶～優先攻擊最終BOSS！")
				TargetFailed := 1
				TargetFailed2 := 1
				TargetFailed3 := 1
				TargetFailed4 := 1
				Loop, 15
				{
					xx := x
					yy := y
					if (Find(n, m, 750, 682, 850, 742, Battle_Map) and xx>147 and yy>200 and xx<MapX2 and yy<MapY2) 
					{
						C_Click(xx, yy)
						if (Find(n, m, 465, 329, 565, 389, "|<>*200$8.zyT3kyTzzyT3kwD3kwD3kwD3kwD3kzy"))  ;16250871
						{
							BossFailed++
							LogShow("哎呀哎呀，前往BOSS的路徑被擋住了！")
							sleep 2000
							TargetFailed := 0
							TargetFailed2 := 0
							TargetFailed3 := 0
							TargetFailed4 := 0
							break
						}
					}
					else if (Find(n, m, 750, 682, 850, 742, Battle_Map) and xx<290 and yy<195) 
					{
						random, swipeboss, 1, 2
						if swipeboss=1
						{
							Swipe(238,315,248,400)  ;下
						}
						else if swipeboss=2
						{
							Swipe(148,300,138,215)  ;上
						}
						break
					}
					if (Find(x, y, 750, 682, 850, 742, Battle_Map)) ;如果在限時(無限時)地圖
					{
						sleep 1000
					}
					if (Find(x, y, 0, 587, 86, 647, Formation_Tank)) ;進入戰鬥界面
					{
						Break
					}
					BackAttack()
					sleep 500
				}
			}
			else if Bossaction=優先攻擊－切換隊伍
			{
				xx := x 
				yy := y 
				if (SwitchParty<1)
				{
					LogShow("嗶嗶嚕嗶～切換隊伍並重新搜尋最終BOSS！")
					SwitchParty := 1
					BossactionTarget := 1 ;如果已經觸發到BOSS
					bulletFailed := 1
					TargetFailed := 1
					TargetFailed2 := 1
					TargetFailed3 := 1
					TargetFailed4 := 1
					boss := Dwmgetpixel(x, y)
					C_Click(1035, 715) ;切換隊伍
					sleep 300
					if (Find(x, y, 440, 328, 540, 388, Switch_NoParty)) ;沒有艦隊可以切換
					{
					}
					else 
					{
						Loop, 20
						{
							if (Dwmgetpixel(x, y)=boss)
							{
								C_Click(1035, 715) ;切換隊伍
								if (Find(x, y, 440, 328, 540, 388, Switch_NoParty)) ;沒有艦隊可以切換
								{
									Break
								}
								sleep 300
								if (Dwmgetpixel(x, y)!=boss)
								{
									break
								}
							}
							else if (Dwmgetpixel(x, y)!=boss)
							{
								break
							}
							sleep 300
						}
					}
					GuiControlGet, AnchorChapter
					if (AnchorChapter="異色1") ;異色格地圖太大，直接滑動到BOSS可能的出生點
					{
						sleep 1000
						if (GdipImageSearch(x, y, "img/targetboss_1.png", 0, SearchDirection, MapX1, MapY1, MapX2, MapY2) and BossFailed<1)
						{
							LogShow("發現：最終ＢＯＳＳ")
							C_Click(x, y)
							BossGetpixel := dwmgetpixel(x, y)
							Loop, 10
							{
								if (BossGetpixel!=dwmgetpixel(x, y))
								{
									sleep 1500
									Break
								}
								sleep 1000
							}
							return
						}
						else
						{
							Loop, 3
							{
								Swipe(998, 443, 300, 443)
								sleep 300
							}
							sleep 500
							if (GdipImageSearch(x, y, "img/targetboss_1.png", 0, SearchDirection, MapX1, MapY1, MapX2, MapY2) and BossFailed<1)
							{
								LogShow("發現：最終ＢＯＳＳ(2)")
								C_Click(x, y)
								BossGetpixel := dwmgetpixel(x, y)
								Loop, 10
								{
									if (BossGetpixel!=dwmgetpixel(x, y))
									{
										sleep 1500
										Break
									}
									sleep 1000
								}
								return
							}
							else
							{
								Loop, 2
								{
									Swipe(607, 561, 607, 200)
									sleep 300
								}
								sleep 500
								if (GdipImageSearch(x, y, "img/targetboss_1.png", 0, SearchDirection, MapX1, MapY1, MapX2, MapY2) and BossFailed<1)
								{
									LogShow("發現：最終ＢＯＳＳ(3)")
									C_Click(x, y)
									BossGetpixel := dwmgetpixel(x, y)
									Loop, 10
									{
										if (BossGetpixel!=dwmgetpixel(x, y))
										{
											sleep 1500
											Break
										}
										sleep 1000
									}
									return
								}
							}
						}
					}
					else if (AnchorChapter="異色2" and AnchorChapter2="1") ;異色格地圖太大，直接滑動到BOSS可能的出生點2
					{
						sleep 1000
						if (GdipImageSearch(x, y, "img/targetboss_1.png", 0, SearchDirection, MapX1, MapY1, MapX2, MapY2) and BossFailed<1)
						{
							LogShow("發現：最終ＢＯＳＳ")
							C_Click(x, y)
							BossGetpixel := dwmgetpixel(x, y)
							Loop, 10
							{
								if (BossGetpixel!=dwmgetpixel(x, y))
								{
									sleep 1500
									Break
								}
								sleep 1000
							}
							return
						}
						else
						{
							Loop, 3
							{
								Swipe(998, 443, 300, 443)
								sleep 300
							}
							sleep 500
							if (GdipImageSearch(x, y, "img/targetboss_1.png", 0, SearchDirection, MapX1, MapY1, MapX2, MapY2) and BossFailed<1)
							{
								LogShow("發現：最終ＢＯＳＳ(2)")
								C_Click(x, y)
								BossGetpixel := dwmgetpixel(x, y)
								Loop, 10
								{
									if (BossGetpixel!=dwmgetpixel(x, y))
									{
										sleep 1500
										Break
									}
									sleep 1000
								}
								return
							}
							else
							{
								Loop, 2
								{
									Swipe(607, 200, 607, 560)
									sleep 300
								}
								sleep 500
								if (GdipImageSearch(x, y, "img/targetboss_1.png", 0, SearchDirection, MapX1, MapY1, MapX2, MapY2) and BossFailed<1)
								{
									LogShow("發現：最終ＢＯＳＳ(3)")
									C_Click(x, y)
									BossGetpixel := dwmgetpixel(x, y)
									Loop, 10
									{
										if (BossGetpixel!=dwmgetpixel(x, y))
										{
											sleep 1500
											Break
										}
										sleep 1000
									}
									return
								}
							}
						}
					}
					else if (AnchorChapter="異色2" and AnchorChapter2="4") ;異色格地圖太大，直接滑動到BOSS可能的出生點2
					{
						sleep 1000
						if (GdipImageSearch(x, y, "img/targetboss_1.png", 0, SearchDirection, MapX1, MapY1, MapX2, MapY2) and BossFailed<1)
						{
							LogShow("發現：最終ＢＯＳＳ")
							C_Click(x, y)
							BossGetpixel := dwmgetpixel(x, y)
							Loop, 10
							{
								if (BossGetpixel!=dwmgetpixel(x, y))
								{
									sleep 1500
									Break
								}
								sleep 1000
							}
							return
						}
						else
						{
							Swipe(922, 253, 498, 608)
							sleep 600
							if (GdipImageSearch(x, y, "img/targetboss_1.png", 0, SearchDirection, MapX1, MapY1, MapX2, MapY2) and BossFailed<1)
							{
								LogShow("發現：最終ＢＯＳＳ(2)")
								C_Click(x, y)
								BossGetpixel := dwmgetpixel(x, y)
								Loop, 10
								{
									if (BossGetpixel!=dwmgetpixel(x, y))
									{
										sleep 1500
										Break
									}
									sleep 1000
								}
								return
							}
						}
					}
				}
				else
				{
					C_Click(xx, yy)
					C_Click(xx, yy)
					if (Find(x, y, 495, 330, 530, 390, "|<>*200$8.zyT3kyTzzyT3kwD3kwD3kwD3kwD3kzy"))
					{
						BossFailed++
						LogShow("哎呀哎呀，前往BOSS的路徑被擋住了！")
						sleep 1000
						if !(FightRoundsDo)
						{
							C_Click(1035, 715) ;換回原本的隊伍
							SwitchParty := 0
						}
						sleep 1000
						TargetFailed := 0
						TargetFailed2 := 0
						TargetFailed3 := 0
						TargetFailed4 := 0
						return
					}
					sleep 4050
					BackAttack()
					if !(Find(x, y, 0, 587, 86, 647, Formation_Tank) and BossFailed<1) ; 如果沒有成功進入戰鬥，再試一次
					{
						C_Click(xx, yy)
						sleep 2050
					}
				}
			}
			else
			{
				LogShow("優先攻擊－當前隊伍 or 優先攻擊－切換隊伍 發生錯誤")
			}
			return
		}
		if ((GdipImageSearch(x, y, "img/target2_1.png", 103, SearchDirection, MapX1, MapY1, MapX2, MapY2) or GdipImageSearch(x, y, "img/target2_2.png", 103, SearchDirection, MapX1, MapY1, MapX2, MapY2) or GdipImageSearch(x, y, "img/target2_3.png", 103, SearchDirection, MapX1, MapY1, MapX2, MapY2)) and TargetFailed2<1 and (Ship_Target2 or SearchLoopcount>9)) ;
		{
			LogShow("嗶嗶嚕嗶～發現：運輸艦隊！")
			xx := x 
			yy := y 
			Loop, 15
			{
				if (xx<360 and yy<195)
				{
					Swipe(238,315,248,400)
					break
				}
				if (Find(x, y, 750, 682, 850, 742, Battle_Map)) ;如果在限時(無限時)地圖
				{
					C_Click(xx, yy)
					if (Find(x, y, 495, 330, 530, 390, "|<>*200$8.zyT3kyTzzyT3kwD3kwD3kwD3kwD3kzy"))
					{
						TargetFailed2++
						LogShow("哎呀哎呀，前往運輸艦隊的路徑被擋住了！")
						sleep 2000
						break
					}
					sleep 1500
				}
				if (Find(x, y, 0, 587, 86, 647, Formation_Tank))
				{
					Break
				}
				BackAttack()
				sleep 500
			}
			return
		}
		if ((GdipImageSearch(x, y, "img/target_1.png", 32, SearchDirection, MapX1, MapY1, MapX2, MapY2) or GdipImageSearch(x, y, "img/target_2.png", 32, SearchDirection, MapX1, MapY1, MapX2, MapY2) or GdipImageSearch(x, y, "img/target_3.png", 32, SearchDirection, MapX1, MapY1, MapX2, MapY2) or GdipImageSearch(x, y, "img/target_4.png", 100, SearchDirection, MapX1, MapY1, MapX2, MapY2)) and TargetFailed<1 and (Ship_Target1 or SearchLoopcount>9)) ;
		{
			LogShow("嗶嗶嚕嗶～發現：航空艦隊！")
			xx := x 
			yy := y 
			Loop, 15
			{
				if (xx<360 and yy<195)
				{
					Swipe(238,315,248,400)
					break
				}
				if (Find(x, y, 750, 682, 850, 742, Battle_Map)) ;如果在限時(無限時)地圖
				{
					C_Click(xx, yy)
					if (Find(x, y, 495, 330, 530, 390, "|<>*200$8.zyT3kyTzzyT3kwD3kwD3kwD3kwD3kzy"))
					{
						TargetFailed++
						LogShow("哎呀哎呀，前往航空艦隊的路徑被擋住了！")
						sleep 2000
						break
					}
					sleep 1500
				}
				if (Find(x, y, 0, 587, 86, 647, Formation_Tank))
				{
					Break
				}
				BackAttack()
				sleep 500
			}
			return
		}
		if ((AnchorChapter="異色1" or AnchorChapter="異色2") and (GdipImageSearch(x, y, "img/target_4.png", 90, SearchDirection, MapX1, MapY1, MapX2, MapY2)) and TargetFailed<1 and (Ship_Target1 or SearchLoopcount>9)) ;
		{
			LogShow("嗶嗶嚕嗶～發現：航空艦隊！(異色格)")
			xx := x 
			yy := y 
			Loop, 15
			{
				if (xx<360 and yy<195)
				{
					Swipe(238,315,248,400)
					break
				}
				if (Find(x, y, 750, 682, 850, 742, Battle_Map)) ;如果在限時(無限時)地圖
				{
					C_Click(xx, yy)
					if (Find(x, y, 495, 330, 530, 390, "|<>*200$8.zyT3kyTzzyT3kwD3kwD3kwD3kwD3kzy"))
					{
						TargetFailed++
						LogShow("哎呀哎呀，前往航空艦隊的路徑被擋住了！")
						sleep 2000
						break
					}
					sleep 1500
				}
				if (Find(x, y, 0, 587, 86, 647, Formation_Tank))
				{
					Break
				}
				BackAttack()
				sleep 500
			}
			return
		}
		if ((GdipImageSearch(x, y, "img/target4_1.png", 60, SearchDirection, MapX1, MapY1, MapX2, MapY2) or GdipImageSearch(x, y, "img/target4_2.png", 60, SearchDirection, MapX1, MapY1, MapX2, MapY2) or GdipImageSearch(x, y, "img/target4_3.png", 60, SearchDirection, MapX1, MapY1, MapX2, MapY2)) and TargetFailed4<1 and (Ship_Target4 or SearchLoopcount>9)) 
		{
			LogShow("嗶嗶嚕嗶～發現：偵查艦隊！")
			xx := x
			yy := y
			Loop, 15
			{
				if (xx<360 and yy<195)
				{
					Swipe(238,315,248,400)
					break
				}
				if (Find(x, y, 750, 682, 850, 742, Battle_Map)) ;如果在限時(無限時)地圖
				{
					C_Click(xx, yy)
					if (Find(x, y, 495, 330, 530, 390, "|<>*200$8.zyT3kyTzzyT3kwD3kwD3kwD3kwD3kzy"))
					{
						TargetFailed4++
						LogShow("哎呀哎呀，前往偵查艦隊的路徑被擋住了！")
						sleep 2000
						break
					}
					sleep 1500
				}
				if (Find(x, y, 0, 587, 86, 647, Formation_Tank))
				{
					Break
				}
				BackAttack()
				sleep 500
			}
			return
		}
		if ((GdipImageSearch(x, y, "img/target3_1.png", 45, SearchDirection, MapX1, MapY1, MapX2, MapY2) or GdipImageSearch(x, y, "img/target3_2.png", 45, SearchDirection, MapX1, MapY1, MapX2, MapY2) or GdipImageSearch(x, y, "img/target3_3.png", 45, SearchDirection, MapX1, MapY1, MapX2, MapY2)) and TargetFailed3<1 and (Ship_Target3 or SearchLoopcount>9)) 
		;~ else if (Gdip_PixelSearch2( x,  y, MapX1, MapY1, MapX2, MapY2, Mainfleet, 0) and TargetFailed3<1) 
		{
			LogShow("嗶嗶嚕嗶～發現：主力艦隊！")
			xx := x
			yy := y 
			Loop, 15
			{
				if (xx<360 and yy<195)
				{
					Swipe(238,315,248,400)
					break
				}
				if (Find(x, y, 750, 682, 850, 742, Battle_Map)) ;如果在限時(無限時)地圖
				{
					C_Click(xx, yy)
					if (Find(x, y, 495, 330, 530, 390, "|<>*200$8.zyT3kyTzzyT3kwD3kwD3kwD3kwD3kzy"))
					{
						TargetFailed3++
						LogShow("哎呀哎呀，前往主力艦隊的路徑被擋住了！")
						sleep 2000
						break
					}
					sleep 1500
				}
				if (Find(x, y, 0, 587, 86, 647, Formation_Tank))
				{
					Break
				}
				BackAttack()
				sleep 500
			}
			return
		}
		if ((Plane_Target1 or SearchLoopcount>9) and GdipImageSearch(x, y, "img/target_plane1.png", 25, SearchDirection, MapX1, MapY1, MapX2, MapY2) and Plane_TargetFailed1<1) ;航空器
		{
			LogShow("嗶嗶嚕嗶～發現：航空器！")
			xx := x 
			yy := y 
			Loop, 15
			{
				if (xx<360 and yy<195)
				{
					Swipe(238,315,248,400)
					break
				}
				if (Find(x, y, 750, 682, 850, 742, Battle_Map)) ;如果在限時(無限時)地圖
				{
					C_Click(xx, yy)
					if (Find(x, y, 495, 330, 530, 390, "|<>*200$8.zyT3kyTzzyT3kwD3kwD3kwD3kwD3kzy"))
					{
						Plane_TargetFailed1++
						LogShow("哎呀哎呀，前往航空器的路徑被擋住了！")
						sleep 2000
						break
					}
					sleep 1500
				}
				if (Find(x, y, 0, 587, 86, 647, Formation_Tank))
				{
					Break
				}
				BackAttack()
				sleep 500
			}
			return
		}
		if (Bossaction!="能不攻擊就不攻擊" and SearchLoopcount>15) and (GdipImageSearch(x, y, "img/targetboss_1.png", 0, SearchDirection, MapX1, MapY1, MapX2, MapY2) and BossFailed<1 ) ;ＢＯＳＳ
		{
			xx := x 
			yy := y 
			if (xx<360 and yy<195)
			{
				Swipe(238,315,248,400)
				return
			}
			if (SearchLoopcount>15 and ossaction="能不攻擊就不攻擊")
			{
				LogShow("已經偵查不到其他船艦，攻擊最終BOSS！")
			}
			else
			{
			LogShow("嗶嗶嚕嗶～發現最終BOSS！")
			}
			if (SwitchParty<1 and Bossaction="隨緣攻擊－切換隊伍")
			{
				LogShow("發現BOSS：隨緣攻擊－切換隊伍！")
				SwitchParty := 1
				C_Click(1035, 706)
			}
			else
			{
				C_Click(xx, yy)
				C_Click(xx, yy)
			}
			if (Find(x, y, 495, 330, 530, 390, "|<>*200$8.zyT3kyTzzyT3kwD3kwD3kwD3kwD3kzy")) 
			{
				BossFailed++
				return
			}
			sleep 4050
			BackAttack()
			if !(Find(x, y, 0, 587, 86, 647, Formation_Tank) and BossFailed<1) ; 如果沒有成功進入戰鬥，再試一次
			{
				C_Click(xx, yy)
				sleep 2050
			}
			return
		}
		if (SearchLoopcount>3 and Find(x, y, 750, 682, 850, 742, Battle_Map))
		{
			if (SearchFailedMessage<1)
			{
				LogShow("偵查失敗，嘗試拖曳畫面")
				SearchFailedMessage := 1
			}
			if side<1
			{
				;~ Swipe(652,166,652,660)  ;下
				Swipe(1013,531,211,106)  ;↖
				sleep 300
				Swipe(1013,531,211,106)  ;↖
				sleep 300
				side := 2
			}
			else if side=2
			{
				Swipe(652,190,652,710)  ;swipe side : ↓
				sleep 300
				side=3
			}
			else if side=3
			{
				Swipe(652,190,652,710)  ;swipe side : ↓
				sleep 300
				side=4
			}
			else if side=4
			{
				Swipe(257,310,1040,310) ;swipe side : →
				sleep 300
				;~ Swipe(1256,310,120,310) ;左
				side=5
			}
			else if side=5
			{
				;~ Swipe(1256,310,120,310) ;左
				Swipe(188,241,1164,621) ;swipe side : ↘
				sleep 300
				side=6
			}
			else if side=6
			{
				;~ Swipe(1256,310,120,310) ;左
				Swipe(604,710,652,180)  ;swipe side : ↑
				sleep 300
				side=7
			}
			else if side=7
			{
				;~ Swipe(200,310,1240,310) ;右
				Swipe(363,555,1011,220) ;swipe side : ↗
				sleep 300
				side=8
			}
			else if side=8
			{
				;~ Swipe(200,310,1240,310) ;右
				Swipe(1256,310,120,310) ;swipe side : ←
				sleep 300
				side=0
			}
			sleep 300
			SearchLoopcountFailed++
			SearchLoopcountFailed2++
			if (GdipImageSearch(x, y, "img/Myposition.png", 10, SearchDirection, MapX1, MapY1, MapX2, MapY2) and SearchLoopcountFailed>2)
			{
				Random, xx, 1, 3
				if xx=1
				{
					xx := x + 150
					yy := y + 200
				}
				else if xx=2
				{
					xx := x - 150
					yy := y + 200
				}
				else if xx=3
				{
					xx := x 
					yy := y + 320
				}
				if (xx>130 and xx<1185) and (yy>150 and yy<660)
				{
					LogShow("未找到指定目標，嘗試隨機移動")
					MoveCheck := Dwmgetpixel(xx, yy)
					sleep 500
					if (Dwmgetpixel(xx, yy)=MoveCheck) ;避免切換到艦隊
					{
						C_Click(xx, yy)
						C_Click(xx, yy)
					}
					MoveCheck := VarSetCapacity
				}
				SearchLoopcountFailed := 0
				sleep 2000
				if (DwmCheckcolor(793, 711, 16250871))
				{
					MoveFailed++
				}
			}
			if (BossactionTarget!=1)
			{
				TargetFailed := VarSetCapacity
				TargetFailed2 := VarSetCapacity
				TargetFailed3 := VarSetCapacity
				TargetFailed4 := VarSetCapacity
				Plane_TargetFailed1 := VarSetCapacity
			}
			else if (BossactionTarget=1 and SearchLoopcountFailed2>15)
			{
				TargetFailed := VarSetCapacity
				TargetFailed2 := VarSetCapacity
				TargetFailed3 := VarSetCapacity
				TargetFailed4 := VarSetCapacity
				Plane_TargetFailed1 := VarSetCapacity
				BossactionTarget := VarSetCapacity
			}
			else if (BossFailed=1)
			{
				TargetFailed := VarSetCapacity
				TargetFailed2 := VarSetCapacity
				TargetFailed3 := VarSetCapacity
				TargetFailed4 := VarSetCapacity
				Plane_TargetFailed1 := VarSetCapacity
			}
			else if (SearchLoopcountFailed2>15)
			{
				TargetFailed := VarSetCapacity
				TargetFailed2 := VarSetCapacity
				TargetFailed3 := VarSetCapacity
				TargetFailed4 := VarSetCapacity
				Plane_TargetFailed1 := VarSetCapacity
			}
			if (SearchLoopcountFailed2>45 and ChooseParty2!="不使用" and SwitchParty<1)
			{
					LogShow("無法偵測到任何目標，嘗試切換隊伍")
					SwitchParty := 1
					Random, x, 963, 1096
					Random, y, 701, 728
					C_Click(x,y) ;點擊"切換"
			}
			if (SearchLoopcountFailed2>60)
			{
				LogShow("重複60次未能偵查到目標，撤退")
				TargetFailed := VarSetCapacity
				TargetFailed2 := VarSetCapacity
				TargetFailed3 := VarSetCapacity
				TargetFailed4 := VarSetCapacity
				TargetFailed5 := VarSetCapacity
				TargetFailed6 := VarSetCapacity
				Plane_TargetFailed1 := VarSetCapacity
				BossFailed := VarSetCapacity
				BulletFailed := VarSetCapacity
				QuestFailed := VarSetCapacity
				SearchLoopcount := VarSetCapacity
				SearchLoopcountFailed2 := VarSetCapacity
				C_Click(794, 714)
				sleep 200
				C_Click(781, 545)
			}
		}
		SearchLoopcount++
	} until !(Find(x, y, 750, 682, 850, 742, Battle_Map))
}
if (Find(x, y, 95, 34, 195, 94, Weigh_Anchor)) ;在出擊選擇關卡的頁面
{
	if (MissionSub and Find(x, y, 1014, 651, 1114, 711, CommisionDone)) ;委託任務已完成
	{
		LogShow("執行軍事委託(主線)！")
		C_Click(1006, 712)
		sleep 1000
		Loop, 60
		{
			if (Find(x, y, 1014, 651, 1114, 711, CommisionDone))
			{
				C_Click(1006, 712)
				sleep 1000
			}
			sleep 300
		} Until Find(x, y, 99, 33, 199, 93, Commision_Delegation)
		sleep 1000
		DelegationMission()
		sleep 1000
		Loop, 30
		{
			if (Find(x, y, 99, 33, 199, 93, Commision_Delegation))
			{
				C_Click(58, 92)
				sleep 2000
			}
			else if (Find(x, y, 95, 34, 195, 94, Weigh_Anchor))
			{
				break
			}
			sleep 500
		}
	}
	if (DailyGoalSub and DailyDone<1)
	{
		iniread, Yesterday, settings.ini, Battle, Yesterday
		FormatTime, Today, ,dd
		Formattime, Checkweek, , Wday ;星期的天數 (1 – 7). 星期天為 1.
		if (Yesterday=Today)
		{
			DailyDone := 1
		}
		else if ((Checkweek=1 or Checkweek=4 or Checkweek=7) and DailyGoalRed) ;
		{
			DailyDone := 0
		}
		else if ((Checkweek=1 or Checkweek=3 or Checkweek=6) and DailyGoalGreen) ;
		{
			DailyDone := 0
		}
		else if ((Checkweek=1 or Checkweek=2 or Checkweek=5) and DailyGoalBlue) ;
		{
			DailyDone := 0
		}
		else 
		{
			DailyDone := 1
		}
		if (DailyDone=0)
		{
			if (Find(x, y, 95, 34, 195, 94, Weigh_Anchor) and Find(x, y, 774, 684, 874, 744, Daily_Task))
			{ ;如果在出擊頁面檢查到每日還沒執行
				LogShow("執行每日任務！")
				Loop
				{
					if (Find(x, y, 95, 34, 195, 94, Weigh_Anchor) and Find(x, y, 774, 684, 874, 744, Daily_Task))  ;如果在出擊頁面檢查到每日還沒執行
					{
						C_Click(826, 709) ;嘗試進入每日頁面
						sleep 3000
					}
					if (Find(x, y, 98, 33, 198, 93, DailyRaid))
					{
						Break ;成功進入每日頁面
					}
					sleep 500
				}
			Goto, DailyGoalSub
			}
		}
		else
		{
			DailyDone := 1
		}
	}
	if (OperationSub and OperationDone<1)
	{
		iniread, OperationYesterday, settings.ini, Battle, OperationYesterday
		FormatTime, OperationToday, ,dd
		if (OperationYesterday=OperationToday)
		{
			OperationDone := 1
		}
		else if (ResetOperationTime and OperationYesterday>=1)
		{
			OperationDone := 1
		}
		else
		{
			if (Find(x, y, 95, 34, 195, 94, Weigh_Anchor) and Find(x, y, 1078, 663, 1178, 723, BTN_Exercise))
			{ ;如果在出擊頁面檢查到演習還沒執行
				LogShow("自動執行演習！")
				Loop
				{
					if (Find(x, y, 95, 34, 195, 94, Weigh_Anchor) and Find(x, y, 1078, 663, 1178, 723, BTN_Exercise)) ;如果在出擊頁面檢查到演習還沒執行
					{
						C_Click(1177, 706) ;嘗試進入演習頁面
						sleep 3000
					}
					if (Find(x, y, 99, 35, 199, 95, Operation_Upp)) ;左上"演習"
					{
						Break ;成功進入每日頁面
					}
				}
			Goto, OperationSub
			}
		}
	}
	if (StopAnchor=1)
	{
		LogShow("停止出擊中，返回首頁")
		C_Click(1228, 72)
		return
	}
	if (BattleTimes) ;如果有勾選出擊N輪
	{
		if (WeighAnchorCount>=BattleTimes2 or BattleTimes2=0) ;如果已達出擊次數
		{
			textshow = 已出擊 %WeighAnchorCount% 輪，強制休息。
			WeighAnchorCount := VarSetCapacity
			LogShow(textshow)
			sleep 1000
			StopAnchor := 1
			C_Click(1229, 71) ;回首頁
			return
		}
	}
	if (StopBattleTime) ;勾選 " 每出擊N輪
	{
		if (StopBattleTimeCount>=StopBattleTime2)
		{
			StopAnchor := 1
			textshow = ☆☆ 已出擊 %StopBattleTimeCount% 輪，休息 %StopBattleTime3% 分鐘。 ☆☆
			LogShow(textshow)
			StopBattleTimeCount := VarSetCapacity
			StopBattleTime3ms := StopBattleTime3*60*1000
			Settimer, clock, -%StopBattleTime3ms%
			C_Click(1229, 71) ;回首頁
			sleep 5000
			return
		}
	}
	if (WeighAnchorCount>=5) ;每打5輪回首頁 (檢查一些在首頁才會有的功能)
	{
		WeighAnchorCount := VarSetCapacity
		C_Click(1229, 71) 
		sleep 2000
		return
	}
	bulletFailed := 1 ;進去關卡第一輪不拿彈藥
	StopBattleTimeCount++ ;每出擊N場修及的判斷次數
	WeighAnchorCount++ ;判斷目前出擊次數
	FightRoundsDoCount := VarSetCapacity ;將艦隊A每出擊次數歸零
	FightRoundsDone := VarSetCapacity ;將艦隊A每出擊次數歸零
	TakeQuest := VarSetCapacity ;將拿取神祕物資次數歸零
	NowHP := VarSetCapacity ;清空目前HP
	sleep 1000 ;判斷現在位於第幾關 1 2 3 4 5 6 7 8 9 
	Chapter1 := Find(x, y, 162, 499, 262, 559, "|<>*132$25.wTzwQDzw87zs03zs21zy1kzzksTzsQDzwC40C72073V03VkzzksTzsQDzwC7zy73zz2")  ;第一關 1-1
	Chapter2 := Find(x, y, 830, 500, 930, 560, "|<>*139$26.UTzy03zz00Tz067zU1Vzw0ETzkwDzwC3zz3VU1kkM0Q8C0727zzk1zzw03zz00zzk0Dzw8") ;第二關 2-1
	Chapter3 := Find(x, y, 419, 263, 519, 323, "|<>*141$27.UDzz01zzk07zs0Ezy027zs7kzzksDzy71zzks40C7kU1k240C0Ezzk27zy00zzk0Dzy41zzkU") ;第三關 3-1
	Chapter4 := Find(x, y, 252, 349, 352, 409, "|<>*137$27.w7zz70zzks7zs60zy0k7zs60zzkW7zy4EzzkW40C0EU1k000C00Tzk03zy7kzzky7zy7kzzkU") ;第四關 4-1
	Chapter5 := Find(x, y, 256, 409, 356, 469, "|<>*135$27.0Dzz00zzk0Dzs0Tzy00Dzs00zzk07zy0Ezzky40C7kU1k240C0Ezzk27zy00zzk07zy41zzkU") ;第五關 5-1
	Chapter6 := Find(x, y, 933, 541, 1033, 601, "|<>*137$27.kDzz40zzk07zs0Ezy03zzs0Hzzk07zy00zzk240C0EU1k240C0Ezzk27zy0EzzkU7zy61zzkU") ;第六關 6-1
	Chapter7 := Find(x, y, 222, 524, 322, 584, "|<>*131$25.0Dzw07zw03zs7Vzs3kzy1kzzksTzsQDzwC40C72073303VVzzkkzzsMTzwADzy4Dzz2") ;第七關 7-1
	Chapter8 := Find(x, y, 568, 230, 668, 290, "|<>*146$27.UDzz01zzk07zs0Ezy027zs0EzzkUDzy41zzk040C0EU1k240C0Ezzk27zy0Ezzk07zy41zzkU") ; 第八關 8-1
	Chapter9 := 0
	Chapter10 := 0
	Chapter11 := 0
	Chapter12 := 0
	Chapter13 := 0
	ChapterEvent1 := DwmCheckcolor(500, 248, 16777215) ;14 活動：紅染1 A1
	ChapterEvent2 := DwmCheckcolor(421, 588, 16777215) ;15 活動：紅染2 B1
	ChapterEventSP := DwmCheckcolor(530, 263, 16777215) ; 16 活動：努力、希望和計畫
	ChapterEvent3 := DwmCheckcolor(272, 291, 16777215) ;17 活動 異色格1 A1
	ChapterEvent4 := if (GdipImageSearch(x, y, "img/Number/Number_1.png", 60, 8, 359, 292, 380, 322)) ? 1 : 0 ;18 活動 異色格2 
	ChapterFailed := 1
	array := [Chapter1, Chapter2,Chapter3, Chapter4, Chapter5, Chapter6, Chapter7, Chapter8, Chapter9, Chapter10, Chapter11, Chapter12, Chapter13, ChapterEvent1,ChapterEvent2, ChapterEventSP, ChapterEvent3, ChapterEvent4, ChapterFailed]
	Chapter := VarSetCapacity
	Loop % array.MaxIndex()
	{
		this_Chapter := array[A_Index]
		Chapter++
		if (this_Chapter=1)
		{
			break
		}
	}
	if (AnchorChapter=Chapter) 
	{
		;~ LogShow("畫面已經在主線地圖") 
	}
	else if (Chapter=14 or Chapter=15 or Chapter=17 or Chapter=18) and ((AnchorChapter="紅染1" or AnchorChapter="紅染2") or (AnchorChapter="異色1" or AnchorChapter="異色2"))
	{
		BacktoNormalMap++
		if ((OperationSub and OperationDone<1) or (DailyGoalSub and DailyDone<1) or (BacktoNormalMap>2))
		{
			Message = 位於%AnchorChapter%地圖，返回主線。
			LogShow(Message)
			BacktoNormalMap := VarSetCapacity
			C_Click(60, 90)
			return
		}
	}
	else if (Chapter=16) and (AnchorChapter="S.P.")
	{
		;~ LogShow("畫面已經在S.P.地圖") 
	}
	else if ((Chapter=14 or Chapter=15 or Chapter=16 or Chapter=17 or Chapter=18) and ((OperationSub and OperationDone<1) or (DailyGoalSub and DailyDone<1)))
	{
		if (OperationSub and OperationDone<1)
			text1=每日
		if (DailyGoalSub and DailyDone<1)
			text1=演習
		SendText = 位於活動關卡，返回地圖執行%text1%。
		LogShow(SendText)
		C_Click(60, 90)
		return
	}
	else if ((Chapter=14 or Chapter=15 or Chapter=16 or Chapter=17 or Chapter=18) and (AnchorChapter is number))
	{
		LogShow("位於活動地圖，返回主線。")
		C_Click(60, 90)
		return
	}
	else if (Chapter=array.MaxIndex())
	{
		LogShow("選擇章節時發生錯誤2")
	}
	else
	{
		;~ LogShow("1111")
		ClickSide := (AnchorChapter-Chapter) ; 負數點右邊 正數點左邊
		ClickCount := abs(AnchorChapter-Chapter)
		if (ClickSide>0)
		{
			Loop, %ClickCount%
			{
			C_Click(1224,412)
			sleep 200
			}
		}
		else
		{
			Loop, %ClickCount%
			{
			C_Click(52,412)
			sleep 200
			}
		}
	}
	if AnchorMode=停用
	{
		StopAnchor := 1
		LogShow("選擇地圖已停用，停止出擊到永遠。")
		sleep 1000
		C_Click(1228, 68)
		sleep 1000
		Loop, 30
		{
			if (Find(x, y, 95, 34, 195, 94, Weigh_Anchor)) ;如果還在出擊頁面
			{
				C_Click(1228, 68)
			}
			else if (Find(x, y, 996, 362, 1096, 422, MainPage_Btn_WeighAnchor)) ;成功回到首頁
			{
				Break
			}
			sleep 350
		}
		return
	}
	else if AnchorMode=普通
	{
		LogShow("選擇攻略地圖，難度：普通")
		if (Find(x, y, 22, 677, 272, 737, HardMode)) ;一般關卡的困難 OR 活動難度的困難
		{
			;不做任何事
		}
		else if (Find(x, y, 22, 677, 272, 737, NormalMode))
		{
			C_Click(99,703)
			sleep 1000
			if !(Find(x, y, 22, 677, 272, 737, HardMode))
			{
				LogShow("難度選擇為普通時發生錯誤1")
				return
			}
		}
		else if (AnchorChapter="S.P.")
		{
			;不做任何事 (SP似乎沒有分難度)
		}
		else 
		{
			LogShow("難度選擇為普通時發生錯誤2")
			return
		}
	}
	else if AnchorMode=困難
	{
		LogShow("選擇攻略地圖，難度：困難")
		if (Find(x, y, 22, 677, 272, 737, NormalMode))
		{
			;不做任何事
		}
		else if (Find(x, y, 22, 677, 272, 737, HardMode))
		{
			C_Click(99,703)
			sleep 1000
			if !(Find(x, y, 22, 677, 272, 737, NormalMode))
			{
				LogShow("難度選擇為困難時發生錯誤1")
				return
			}
		}
		else 
		{
			LogShow("難度選擇為困難時發生錯誤2")
			return
		}
	}
	sleep 500
	GuiControlGet, AnchorChapter
	GuiControlGet, AnchorChapter2
	Chaptermessage = ——選擇關卡： 第 %AnchorChapter% 章 第 %AnchorChapter2% 節。——
	LogShow(Chaptermessage)
	if (AnchorChapter=1 and AnchorChapter2=1) ; 選擇關卡 1-1
	{
		if (DwmCheckcolor(220, 527, 16777215))
		{
			C_Click(221,526)
		}
	}
	else if (AnchorChapter=1 and AnchorChapter2=2) ; 選擇關卡 1-2
	{
		if (DwmCheckcolor(509, 341, 16777215))
		{
			C_Click(510,342)
		}
	}
	else if (AnchorChapter=1 and AnchorChapter2=3) ; 選擇關卡 1-3
	{
		if (DwmCheckcolor(712, 599, 16777215))
		{
			C_Click(713,600)
		}
	}
	else if (AnchorChapter=1 and AnchorChapter2=4) ; 選擇關卡 1-4
	{
		if (DwmCheckcolor(861, 246, 16777215))
		{
			C_Click(862,247)
		}
	}
	else if (AnchorChapter=2 and AnchorChapter2=1) ; 選擇關卡 2-1
	{
		if (DwmCheckcolor(867, 531, 16777215))
		{
			C_Click(868,530)
		}
	}
	else if (AnchorChapter=2 and AnchorChapter2=2) ; 選擇關卡 2-2
	{
		if (DwmCheckcolor(802, 261, 16777215))
		{
			C_Click(803,262)
		}
	}
	else if (AnchorChapter=2 and AnchorChapter2=3) ; 選擇關卡 2-3
	{
		if (DwmCheckcolor(341, 345, 16777215))
		{
			C_Click(341,346)
		}
	}
	else if (AnchorChapter=2 and AnchorChapter2=4) ; 選擇關卡 2-4
	{
		if (DwmCheckcolor(437, 619, 16777215))
		{
			C_Click(438,620)
		}
	}
	else if (AnchorChapter=3 and AnchorChapter2=1) ; 選擇關卡3-1
	{
		if (DwmCheckcolor(476, 292, 16777215))
		{
			C_Click(477,293)
		}
	}
	else if (AnchorChapter=3 and AnchorChapter2=2) ; 選擇關卡3-2
	{
		if (DwmCheckcolor(304, 572, 16777215))
		{
			C_Click(305,573)
		}
	}
	else if (AnchorChapter=3 and AnchorChapter2=3) ; 選擇關卡3-3
	{
		if (DwmCheckcolor(866, 208, 16777215))
		{
			C_Click(867,209)
		}
	}
	else if (AnchorChapter=3 and AnchorChapter2=4) ; 選擇關卡3-4
	{
		if (DwmCheckcolor(690, 432, 16777215))
		{
			C_Click(691,433)
		}
	}
	else if (AnchorChapter=4 and AnchorChapter2=1) ; 選擇關卡4-1
	{
		if (DwmCheckcolor(311, 377, 16777215))
		{
			C_Click(312,378)
		}
	}
	else if (AnchorChapter=4 and AnchorChapter2=2) ; 選擇關卡4-2
	{
		if (DwmCheckcolor(476, 540, 16777215))
		{
			C_Click(477,541)
		}
	}
	else if (AnchorChapter=4 and AnchorChapter2=3) ; 選擇關卡4-3
	{
		if (DwmCheckcolor(878, 618, 16777215))
		{
			C_Click(879,619)
		}
	}
	else if (AnchorChapter=4 and AnchorChapter2=4) ; 選擇關卡4-4
	{
		if (DwmCheckcolor(855, 360, 16777215))
		{
			C_Click(856,361)
		}
	}
	else if (AnchorChapter=5 and AnchorChapter2=1) ; 選擇關卡5-1
	{
		if (DwmCheckcolor(315, 437, 16777215))
		{
			C_Click(516,438)
		}
	}
	else if (AnchorChapter=5 and AnchorChapter2=2) ; 選擇關卡5-2
	{
		if (DwmCheckcolor(906, 607, 16777215))
		{
		C_Click(907,608)
		}
	}
	else if (AnchorChapter=5 and AnchorChapter2=3) ; 選擇關卡5-3
	{
		if (DwmCheckcolor(788, 435, 16777215))
		{
			C_Click(789,436)
		}
	}
	else if (AnchorChapter=5 and AnchorChapter2=4) ; 選擇關卡5-4
	{
		if (DwmCheckcolor(642, 284, 16777215))
		{
			C_Click(623,285)
		}
	}
	else if (AnchorChapter=6 and AnchorChapter2=1) ; 選擇關卡6-1
	{
		if (DwmCheckcolor(965, 573, 16777215))
		{
			C_Click(966,574)
		}
	}
	else if (AnchorChapter=6 and AnchorChapter2=2) ; 選擇關卡6-2
	{
		if (DwmCheckcolor(777, 416, 16777215))
		{
			C_Click(778,417)
		}
	}
	else if (AnchorChapter=6 and AnchorChapter2=3) ; 選擇關卡6-3
	{
		if (DwmCheckcolor(477, 289, 16777215))
		{
			C_Click(478,290)
		}
	}
	else if (AnchorChapter=6 and AnchorChapter2=4) ; 選擇關卡6-4
	{
		if (DwmCheckcolor(373, 498, 16777215))
		{
			C_Click(374,499)
		}
	}
	else if (AnchorChapter=7 and AnchorChapter2=1) ; 選擇關卡7-1
	{
		if (DwmCheckcolor(279, 558, 16777215))
		{
			C_Click(280,559)
		}
	}
	else if (AnchorChapter=7 and AnchorChapter2=2) ; 選擇關卡7-2
	{
		if (DwmCheckcolor(533, 255, 16777215))
		{
			C_Click(534,256)
		}
	}
	else if (AnchorChapter=7 and AnchorChapter2=3) ; 選擇關卡7-3
	{
		if (DwmCheckcolor(875, 356, 16777215))
		{
			C_Click(876,357)
		}
	}
	else if (AnchorChapter=7 and AnchorChapter2=4) ; 選擇關卡7-4
	{
		if (DwmCheckcolor(1018, 521, 16777215))
		{
			C_Click(1019,522)
		}
	}
	else if (AnchorChapter=8 and AnchorChapter2=1) ; 選擇關卡8-1
	{
		if (DwmCheckcolor(623, 259, 16777215))
		{
			C_Click(624,259)
		}
	}
	else if (AnchorChapter=8 and AnchorChapter2=2) ; 選擇關卡8-2
	{
		if (DwmCheckcolor(349, 431, 16777215))
		{
			C_Click(348,430)
		}
	}
	else if (AnchorChapter=8 and AnchorChapter2=3) ; 選擇關卡8-3
	{
		if (DwmCheckcolor(390, 638, 16777215))
		{
			C_Click(391,639)
		}
	}
	else if (AnchorChapter=8 and AnchorChapter2=4) ; 選擇關卡8-4
	{
		if (DwmCheckcolor(858, 532, 16777215))
		{
			C_Click(859,533)
		}
	}
	else if (AnchorChapter="紅染1" or AnchorChapter="紅染2")
	{
		if (DwmCheckcolor(1238, 246, 16760369) and (AnchorChapter="紅染1" or AnchorChapter="紅染2"))
		{
			C_Click(1201, 226)
			sleep 2000
		}
		else if (ChapterEvent1 and AnchorChapter="紅染2") ;
		{
			C_Click(1223, 411)
			sleep 2000
		}
		else if (ChapterEvent2 and AnchorChapter="紅染1") ;
		{
			C_Click(48, 409)
			sleep 2000
		}
		if (AnchorChapter="紅染1" and AnchorChapter2=1)
		{
			if (DwmCheckcolor(500, 249, 16777215))
			{
				C_Click(501,250)
			}
		}
		else if (AnchorChapter="紅染1" and AnchorChapter2=2)
		{
			if (DwmCheckcolor(798, 594, 16777215))
			{
				C_Click(799,595)
			}
		}
		else if (AnchorChapter="紅染1" and AnchorChapter2=3)
		{
			if (DwmCheckcolor(963, 326, 16777215))
			{
				C_Click(964,325)
			}
		}
		else if (AnchorChapter="紅染1" and AnchorChapter2=4)
		{
			LogShow("紅染1篇沒有第四關")
		}
		else if (AnchorChapter="紅染2" and AnchorChapter2=1)
		{
			if (DwmCheckcolor(421, 591, 16777215))
			{
				C_Click(422,592)
			}
		}
		else if (AnchorChapter="紅染2" and AnchorChapter2=2)
		{
			if (DwmCheckcolor(935, 573, 16777215))
			{
				C_Click(936,574)
			}
		}
		else if (AnchorChapter="紅染2" and AnchorChapter2=3)
		{
			if (DwmCheckcolor(774, 297, 16777215))
			{
				C_Click(775,298)
			}
		}
	}
	else if (AnchorChapter="S.P.")
	{
		if (DwmCheckcolor(1199, 234, 16772054) and AnchorChapter="S.P.")
		{
			C_Click(1201, 226) ;畫面在主線地圖時，點擊特殊作戰進入SP地圖
			sleep 2000
		}
		if (AnchorChapter="S.P." and AnchorChapter2=1)
		{
			if (DwmCheckcolor(530, 265, 16777215))
			{
				C_Click(531,264) ;點擊SP1
			}
		}
		else if (AnchorChapter="S.P." and AnchorChapter2=2)
		{
			if (DwmCheckcolor(819, 395, 16777215))
			{
				C_Click(820,394) ;點擊SP2
			}
		}
		else if (AnchorChapter="S.P." and AnchorChapter2=3)
		{
			if (DwmCheckcolor(649, 601, 16777215))
			{
				C_Click(650,600) ;點擊SP3
			}
		}
	}
	else if (AnchorChapter="異色1" or AnchorChapter="異色2")
	{
		if (DwmCheckcolor(1194, 232, 16772062) and (AnchorChapter="異色1" or AnchorChapter="異色2")) ;如果在主線，則進入異色關卡
		{
			C_Click(1201, 226) 
			sleep 2000
		}
		else if (ChapterEvent3 and AnchorChapter="異色2") ;
		{
			C_Click(1223, 411)
			sleep 2000
		}
		else if (ChapterEvent4 and AnchorChapter="異色1") ;
		{
			C_Click(48, 409)
			sleep 2000
		}
		if (AnchorChapter="異色1" and AnchorChapter2=1)
		{
			if (DwmCheckcolor(272, 291, 16777215))
			{
				C_Click(284,292)
			}
		}
		else if (AnchorChapter="異色1" and AnchorChapter2=2)
		{
			if (DwmCheckcolor(378, 565, 16777215))
			{
				C_Click(373,564)
			}
		}
		else if (AnchorChapter="異色1" and AnchorChapter2=3)
		{
			if (DwmCheckcolor(858, 314, 16777215))
			{
				C_Click(864,319)
			}
		}
		else if (AnchorChapter="異色1" and AnchorChapter2=4)
		{
			if (DwmCheckcolor(941, 575, 16777215))
			{
				C_Click(955,577)
			}
		}
		else if (AnchorChapter="異色2" and AnchorChapter2=1)
		{
			if (GdipImageSearch(x, y, "img/Number/Number_1.png", 100, 8, 359, 292, 380, 322))
			{
				C_Click(422,305)
			}
		}
		else if (AnchorChapter="異色2" and AnchorChapter2=2)
		{
			if (GdipImageSearch(x, y, "img/Number/Number_2.png", 100, 8, 933, 253, 953, 280))
			{
				C_Click(966,265)
			}
		}
		else if (AnchorChapter="異色2" and AnchorChapter2=3)
		{
			if (GdipImageSearch(x, y, "img/Number/Number_3.png", 100, 8, 473, 592, 493, 621))
			{
				C_Click(517,608)
			}
		}
		else if (AnchorChapter="異色2" and AnchorChapter2=4)
		{
			if (GdipImageSearch(x, y, "img/Number/Number_4.png", 100, 8, 780, 421, 800, 450))
			{
				C_Click(817,435)
			}
		}
	}
	else 
	{
		LogShow("選擇關卡時發生錯誤！")
		sleep 2000
		return
	}
	sleep 2000
	SwitchParty := 0 ;BOSS換隊
	ToMap()
	;~ ChapterCheck := ("0,0,0")
	;~ ChapterCheckArray := StrSplit(ChapterCheck, ",")
	;~ msgbox % ChapterCheckArray.MaxIndex()
	;~ Loop % ChapterCheckArray.MaxIndex()
	;~ {
		;~ this_Chapter := ChapterCheckArray[A_Index]
		;~ Chapter++
		;~ if (this_Chapter=1)
		;~ {
			;~ msgbox, 目前位於：第 %Chapter% 關
			;~ Chapter := VarSetCapacity
			;~ break
		;~ }
	;~ }
	;~ LogShow("ERROR")
}
Try
{
	battlevictory()
	Battle()
	ChooseParty(StopAnchor)
	ToMap()
	shipsfull()
	BackAttack()
	Message_Story()
	Battle_End()
	UnknowWife()
	Message_Normal()
	Message_Center()
	GetCard()
	GetItem()
	battlevictory()
	GuLuGuLuLu()
	CloseEventList()
	SystemNotify()
	ClickFailed()
	AutoLoginIn()
}
return

OperationSub:
LogShow("開始演習。")
Loop
{
	sleep 300
	if (GdipImageSearch(x, y, "img/None_Operation.png", 100, 8, 1060, 173, 1213, 205)) ;演習次數剩餘0次
	{
			LogShow("演習次數剩餘0次，演習結束！")
			Iniwrite, %OperationToday%, settings.ini, Battle, OperationYesterday
			C_Click(1239, 72) ;回到首頁
			break
	}
	if (Find(x, y, 99, 35, 199, 95, Operation_Upp))  ;演習介面隨機
	{
		if (Operationenemy="最弱的")
		{
			Capture2(234, 298, 293, 322)   ;第一位敵人主力
			enemy1 := OCR("capture/OCRTemp.png")
			Capture2(481, 298, 538, 322)   ;第二位敵人主力
			enemy2 := OCR("capture/OCRTemp.png")			
			Capture2(720, 298, 783, 322)  ;第三位敵人主力
			enemy3 := OCR("capture/OCRTemp.png")
			Capture2(963, 298, 1027, 322) ;第四位敵人主力
			enemy4 := OCR("capture/OCRTemp.png")
			FileDelete, capture\OCRTemp.png
			Min_enemy := MinMax("min",enemy1,enemy2,enemy3,enemy4)
			enemytext = 敵方戰力：%enemy1%, %enemy2%, %enemy3%, %enemy4%.
			LogShow(enemytext)
			;~ msgbox, enemy1=%enemy1%`nenemy2=%enemy2%`nenemy3=%enemy3%`nenemy4=%enemy4%`nMin_enemy=%Min_enemy%
			if (Min_enemy=enemy1)
			{
				C_Click(218, 280)
			} 
			else if (Min_enemy=enemy2)
			{
				C_Click(462, 280)
			}
			else if (Min_enemy=enemy3)
			{
				C_Click(708, 280)
			}
			else if (Min_enemy=enemy4)
			{
				C_Click(940, 280)
			}
			else
			{
				C_Click(218, 280) ;判斷失敗 打左邊第一個
			}
			enemy1 := VarSetCapacity
			enemy2 := VarSetCapacity
			enemy3 := VarSetCapacity
			enemy4 := VarSetCapacity
			Min_enemy := VarSetCapacity
		}
		else if (Operationenemy="隨機的")
		{
			LogShow("選擇隨機的敵方艦隊")
			Random, clickpos, 1, 4 ;隨機挑選敵人
			if clickpos=1
			{
				C_Click(226, 286)
			}
			else if clickpos=2
			{
				C_Click(453, 286)
			}
			else if clickpos=3
			{
				C_Click(700, 286)
			}
			else if clickpos=4
			{
				C_Click(941, 286)
			}
		}
		else if (Operationenemy="最左邊")
		{
			C_Click(226, 286)
		}
		else if (Operationenemy="最右邊")
		{
			C_Click(941, 286)
		}
	}
	else if (Find(x, y, 560, 568, 660, 628, Operation_Start)) ;演習對手訊息
	{
		C_Click(647, 608)
		sleep 500
	}
	else if (Find(x, y, 98, 33, 198, 93, Operation_Formation)) ;編隊畫面
	{
		LogShow("演習出擊。")
		C_Click(1089, 689)
		sleep 1300
		if (Find(x, y, 98, 33, 198, 93, Operation_Formation))
		{
			LogShow("演習結束！")
			Iniwrite, %OperationToday%, settings.ini, Battle, OperationYesterday
			C_Click(1239, 72) ;回到首頁
			break
		}
		sleep 5000
		if (Find(x, y, 98, 33, 198, 93, Operation_Formation)) ;點了出擊過了5秒還是沒出擊
		{
			LogShow("演習異常，強制結束！")
			Iniwrite, %OperationToday%, settings.ini, Battle, OperationYesterday
			C_Click(1239, 72) ;回到首頁
			break
		}
	}
	else if (Find(x, y, 101, 33, 201, 93, Operation_Shop)) ;誤點商店
	{
		C_Click(57, 90) ;誤點商店，自動離開
	}
	Try
	{
		battlevictory()
		Battle_Operation()
		ChooseParty(StopAnchor)
		ToMap()
		shipsfull()
		BackAttack()
		Message_Story()
		Battle_End()
		UnknowWife()
		Message_Normal()
		Message_Center()
		GetCard()
		GetItem()
		battlevictory()
		GuLuGuLuLu()
		CloseEventList()
		SystemNotify()
		AutoLoginIn()
	}
}
return

startemulatorSub:
runwait, %Consolefile% globalsetting --fastplay 0 --cleanmode 1, %ldplayer%, Hide
runwait, %Consolefile% launchex --index %emulatoradb% --packagename "com.hkmanjuu.azurlane.gp" , %ldplayer%, Hide
sleep 10000
Winget, UniqueID,, %title%
Allowance = %AllowanceValue%
Global UniqueID, Allowance
Loop
{
	if (Find(x, y, 1197, 704, 1297, 764, CRIWare))
	{
		LogShow("位於遊戲首頁，自動登入")
		sleep 5000
		C_Click(642, 420)
		sleep 5000
	}
	if (Find(x, y, 420, 450, 850, 600, Game_Update)) ;更新提示
	{
		LogShow("開始自動更新")
		C_Click(786, 534)
	}
	if (Find(x, y, 996, 362, 1096, 422, MainPage_Btn_WeighAnchor))
	{
		LogShow("自動登入完畢。")
		break
	}
	AutoLoginIn()
	SystemNotify()
	GetItem()
	CloseEventList()
	sleep 1000
	WinMove,  %title%, , , , %EmulatorResolution_W%, %EmulatorResolution_H%
}
iniread, Autostart, settings.ini, OtherSub, Autostart, 0
if (Autostart)
{
	iniwrite, 0, settings.ini, OtherSub, Autostart
	goto, start
}
else
{
	goto, start
}
return

DailyGoalSub:
if  (DailyGoalSub and DailyDone<1)
{
	iniread, Yesterday, settings.ini, Battle, Yesterday
	FormatTime, Today, ,dd
	if (Yesterday=Today)
	{
		DailyDone := 1
		LogShow("已完成每日任務。")
		Loop
		{
			if (Find(x, y, 97, 34, 197, 94, DailyYraid)) ;如果在每日頁面
			{
				LogShow("返回主選單。")
				C_Click(1242, 69)
			}
			if (Find(x, y, 996, 362, 1096, 422, MainPage_Btn_WeighAnchor)) ;如果成功返回首頁
			{
				Break
			}
		}
	}
	else
	{
		DailyGoalSub2:
		Formattime, Checkweek, , Wday ;星期的天數 (1 – 7). 星期天為 1.
		Loop
		{
			if (Find(x, y, 348, 162, 448, 222, Daily_LV))
			{
				sleep 300
				if ((Checkweek=1 or Checkweek=4 or Checkweek=7) and DailyGoalRedAction=1) or ((Checkweek=3 or Checkweek=6) and DailyGoalGreenAction=1) or ((Checkweek=2 or Checkweek=5) and DailyGoalBlueAction=1)
				{
					C_Click(721, 262)
				}
				else if ((Checkweek=1 or Checkweek=4 or Checkweek=7) and DailyGoalRedAction=2) or ((Checkweek=3 or Checkweek=6) and DailyGoalGreenAction=2) or ((Checkweek=2 or Checkweek=5) and DailyGoalBlueAction=2)
				{
					C_Click(721, 401)
				}
				else if ((Checkweek=1 or Checkweek=4 or Checkweek=7) and DailyGoalRedAction=3) or ((Checkweek=3 or Checkweek=6) and DailyGoalGreenAction=3) or ((Checkweek=2 or Checkweek=5) and DailyGoalBlueAction=3)
				{
					C_Click(721, 552)
				}
				else if ((Checkweek=1 or Checkweek=4 or Checkweek=7) and DailyGoalRedAction=4) or ((Checkweek=3 or Checkweek=6) and DailyGoalGreenAction=4) or ((Checkweek=2 or Checkweek=5) and DailyGoalBlueAction=4)
				{
					C_Click(756, 552)
				}
				sleep 1000
				if (Find(x, y, 427, 328, 527, 388, Daily_Ico)) ;如果出現驚嘆號 (多確認一個紅尖尖 避免誤判)
				{
					if (Checkweek=1 and CheckweekCount<1 and DailyGoalSunday) ;如果是禮拜天  (打左邊)
					{
						CheckweekCount := 1
						Checkweek := 2
						C_Click(55, 90)
						sleep 500
						C_Click(367, 376)
						C_Click(645, 414)
						sleep 1000
					}
					else if (Checkweek=2 and CheckweekCount=1 and DailyGoalSunday) ;如果是禮拜天  (打右邊)
					{
						CheckweekCount := 2
						Checkweek := 3
						C_Click(55, 90)
						sleep 500
						C_Click(889, 403)
						C_Click(907, 416)
						C_Click(627, 410)
						sleep 1000
					}
					else
					{
						Logshow("每日任務次數用盡，返回主選單。")
						Loop, 30
						{
							if (Find(x, y, 97, 34, 197, 94, DailyYraid)) ;檢查每日頁面左上角 每日
							{
								C_Click(1242, 66)
								sleep 2000
							}
							if (Find(x, y, 996, 362, 1096, 422, MainPage_Btn_WeighAnchor))
							{
								DailyBreak := 1
								DailyDone := 1
								Logshow("每日任務已結束")
								Break
							}
							sleep 500
						}
						DailyDone := 1
						DailyBreak := 1
					}
				}
				if (DailyBreak=1)
				{
					Break
				}
				sleep 2000
			}
			else if (Find(x, y, 100, 34, 200, 94, Daily_Formation))
			{
				if (ChooseDailyParty<1) ;第一次執行時判斷使用第幾隊 寫法偷懶 等有閒再來改
				{
					Logshow("選擇每日艦隊中。")
					sleep 1000
					Loop, 5
					{
						C_Click(39, 372) ;偷懶...不判斷目前第幾隊 直接點左邊5下換回第一艦隊
					}
					if DailyParty=第一艦隊
					{ ;不執行 本來就是第一艦隊
					}
					else if DailyParty=第二艦隊
					{
						C_Click(915, 376)
					}
					else if DailyParty=第三艦隊
					{
						Loop, 2 
						{
							C_Click(915, 376)
						}
					}
					else if DailyParty=第四艦隊
					{
						Loop, 3 
						{
							C_Click(915, 376)
						}
					}
					else if DailyParty=第五艦隊
					{
						Loop, 4 
						{
							C_Click(915, 376)
						}
					}
					ChooseDailyParty := 1
				}
				Logshow("出擊每日任務！")
				if (Retreat_LowHp) { ; 每日任務不撤退
					Retreat_LowHp := 0
					IsRetreat_LowHp := 1
				}
				C_Click(1147, 667)
				if (DwmCheckcolor(330, 209, 16777215) and DwmCheckcolor(330, 209, 16777215) and DwmCheckcolor(791, 546, 4355509) and DwmCheckcolor(849, 232, 4877741))
				{
					Logshow("老婆心情低落，休息10分鐘。")
					C_Click(496, 543) ;點擊取消
					sleep 600000
					if (DwmCheckcolor(1235, 650, 16250871))
					{
						C_Click(1133, 690) ;點擊出擊
					}
				}
				else if (DwmCheckcolor(543, 358, 16250871) and DwmCheckcolor(543, 364, 15198183))
				{
					Logshow("石油不足，停止每日任務。")
					StopAnchor := 1
					Loop, 20
					{
						if (DwmCheckcolor(133, 56, 15201279) and DwmCheckcolor(133, 56, 15201279)) ;檢查"編隊"
						{
							C_Click(1230, 68) ;返回主選單
						}
						else if (Find(x, y, 996, 362, 1096, 422, MainPage_Btn_WeighAnchor))
						{
							Break
						}
						sleep 1000
					}
					return
				}
			}
			else if (Find(x, y, 0, 364, 91, 424, Daily_Left) and Find(x, y, 1196, 366, 1296, 426, Daily_Right))   ;如果在每日選擇關卡頁面，選中間那個
			{
				C_Click(642, 423)
			}
			else
			{
				Try
				{
					battlevictory()
					Battle()
					ChooseParty(StopAnchor)
					ToMap()
					shipsfull()
					BackAttack()
					Message_Story()
					Battle_End()
					UnknowWife()
					Message_Normal()
					Message_Center()
					GetCard()
					GetItem()
					battlevictory()
					GuLuGuLuLu()
					CloseEventList()
					SystemNotify()
					AutoLoginIn()
				}
			}
		}
	}
	if (IsRetreat_LowHp) {
		Retreat_LowHp := 1
	}
	Iniwrite, %Today%, settings.ini, Battle, Yesterday
	DailyBreak := VarSetCapacity
	ChooseDailyParty := VarSetCapacity
	CheckweekCount := VarSetCapacity
}
return

MissionSub:
if (MissionCheck) ;如果有任務獎勵
{
    LogShow("發現任務獎勵！")
    C_Click(883, 725) ;點擊任務按紐
	sleep 1000
	Loop
	{
		if (Find(x, y, 868, 680, 968, 740, MainPage_MissionDone)) 
		{
			C_Click(883, 725) ;點擊任務按紐
			sleep 1000
		}
		sleep 500
	} until Find(x, y, 2, 154, 102, 214, MissionPage_All) ;等待進入任務界面 (偵測金色的"全部")
    Loop
    {
        if (Find(x, y, 1023, 29, 1123, 89, MissionPage_ReveiveAward)) ;全部領取任務獎勵
        {
            LogShow("領取全部任務獎勵！")
            C_Click(1068, 63)
        }
        else if (Find(x, y, 1087, 152, 1187, 212, MissionPage_ReveiveAward_1)) ;領取第一個任務獎勵
        {
            C_Click(1136, 187)
        }
		else if (Find(x, y, 450, 130, 830, 330, Touch_to_Contunue)) ;獲得道具
		{
			C_Click(636, 91)
		}
        else if (GdiGetPixel(751, 205)=4286894079 or GdiGetPixel(749, 278)=4287419391 ) ;確認獎勵
        {
            C_Click(641, 597)
        }
        else if (Find(x, y, 1051, 622, 1151, 682, GetCards)) ;獲得新卡片
		{
			C_Click(567, 289)
		}
        else if (GdiGetPixel(915, 232)=4291714403 and GdiGetPixel(815, 232)=4283594165) ;是否鎖定該腳色(否)
        {
            C_Click(489, 546)
        }
		else if (DwmCheckcolor(459, 544, 16777215) and DwmCheckcolor(811, 546, 16777215) and DwmCheckcolor(413, 225, 16777215)) ;是否提交物品(是)
        {
            C_Click(811, 546)
        }
		else if (Find(x, y, 1161, 46, 1261, 106, SkipBtn)) ;劇情
        {
            C_Click(811, 546)	 
        }
        else if (Find(x, y, 1084, 153, 1184, 213, MissionPage_MoveForward) or Find(x, y, 233, 334, 333, 394, MissionPage_List_Empty))
        {
            LogShow("獎勵領取結束，返回主選單！")
            C_Click(1227, 69)
			MissionDone := 1
			sleep 1000
        }
		else if (Find(x, y, 734, 401, 834, 461, MainPage_Btn_Formation) and MissionDone=1)
		{
			MissionDone :=0
			break
		}
        sleep 500
    }
}
if (MissionCheck2) ;在主選單偵測到軍事任務已完成
{
	LogShow("執行軍事委託")
	C_Click(20, 200)
	sleep 1000
	Loop
	{
		if (Find(x, y, 2, 154, 102, 214, MainPage_N_Done))
		{
			C_Click(20, 200)
			sleep 1000
		}
		if (Find(x, y, 392, 288, 492, 348, Delegation_Done)) ;出現選單"完成"
		{
			C_Click(x, y) ;點擊軍事委託完成
			sleep 2500
		}
		if (Find(x, y, 200, 80, 450, 180, Delegation_Incredible) or Find(x, y, 200, 80, 450, 180, Delegation_Perfect)) ;出現委託成功S頁面
		{
			break
		}
		sleep 500
	}
	Loop
	{
		sleep 400
		if (Find(x, y, 200, 80, 450, 180, Delegation_Incredible) or Find(x, y, 200, 80, 450, 180, Delegation_Perfect)) ;委託成功 S
		{
			C_Click(639, 141) ;隨便點
			sleep 1000
		}
		else if (Find(x, y, 203, 320, 303, 380, Delegation_idle)) ;如果已經"空閒"
		{
			sleep 500
			if (Find(x, y, 203, 320, 303, 380, Delegation_idle))
			{
				C_Click(441, 314)
				sleep 1500
			}
		}
		else if (Find(x, y, 99, 34, 199, 94, DelegationPage_in_Delegation)) ;成功進入委託頁面
		{
			Rmenu := 1
			break
		}
		else
		{
			LoopVar++
			if (LoopVar=50 or LoopVar=60 or LoopVar=70)
			{
				C_Click(514, 116)
			}
			if (LoopVar>100)
			{
				LogShow("軍事委託出現錯誤")
				LoopVar := VarSetCapacity
				Rmenu := VarSetCapacity
				Break
			}
		}
		GetItem()
	}
	LoopVar := VarSetCapacity
	if (Rmenu=1)
	{
		Rmenu := VarSetCapacity
		DelegationMission()
		sleep 1000
		C_Click(1246, 89)
		Loop, 50
		{
			if (Find(x, y, 150, 163, 250, 223, Delegation_Canteen))
			{
				C_Click(1246, 89)
				sleep 1000
			}
			else  if (Find(x, y, 996, 362, 1096, 422, MainPage_Btn_WeighAnchor))
			{
				break
			}
			sleep 500
		}
	}
	else
	{
		Loop, 50
		{
			if (Find(x, y, 150, 163, 250, 223, Delegation_Canteen))
			{
				C_Click(1246, 89)
				sleep 1000
			}
			else  if (Find(x, y, 996, 362, 1096, 422, MainPage_Btn_WeighAnchor))
			{
				break
			}
			sleep 500
		}
	}
	LogShow("軍事委託結束")
}
return

AcademySub:
if (AcademyDone<1)
{
	ShopX1 := 100, ShopY1 := 100, ShopX2 := 1250, ShopY2 := 650
	Random, x, 320, 509
	Random, y, 290, 508
	C_Click(x, y)
	sleep 1000
	Loop ;等待進入學院
	{
		sleep 500
		if (Find(x, y, 97, 34, 197, 94, AcademyPage_Academy))
		{
			break
		}
		else if (A_index=200)
		{
			Logshow("AcademySub Error")
			return ;不再執行
		}
	}
	Loop
	{
		if (GdipImageSearch(x, y, "img/AcademyOil.png", 100, 8, 95, 298, 542, 723) and AcademyOil and GetOil<1) ;
		{
			LogShow("發現石油，高雄發大財！")
			GetOil := 1
			C_Click(x, y)
		}
		if (GdipImageSearch(x, y, "img/AcademyCoin.png", 100, 8, 450, 411, 843, 748) and AcademyCoin and fullycoin<1) ;
		{
			LogShow("發現金幣，高雄發大財！")
			C_Click(x, y)
			if (DwmCheckcolor(437, 361, 15724527))
			{
				LogShow("高雄的錢…真的太多了…")
				fullycoin := 1
			}
		}
		if (Find(x, y, 1021, 202, 1121, 262, AcademyPage_Shop) and AcademyShop and AcademyShopDone<1) ;商店出現 "！" DwmCheckcolor(1132, 213, 16774127)
		{
			LogShow("商店街發大財")
			C_Click(1113, 210)
			Loop, 20
			{
				sleep 500
			} until Find(x, y, 98, 32, 198, 92, AcademyPage_into_Shop) ;檢查是否進入商店
			ShopX1 := 430, ShopY1 := 150, ShopX2 := 1250, ShopY2 := 620
			Loop
			{
				if (Find(x, y, ShopX1, ShopY1, ShopX2, ShopY2, 外觀裝備箱) and Item_Equ_Box1 and Item_Equ_Box1Coin<1) ;如果有外觀裝備箱
				{
					Item_Equ_Box1Pos := dwmgetpixel(x,y)
					LogShow("購買外觀裝備箱(金幣)")
					Loop, 20
					{
						if (Item_Equ_Box1Pos=dwmgetpixel(x,y))
						{
							xx := x+10
							yy := y+8
							C_Click(xx,yy) ;點擊裝備箱
						}
						if (Find(x, y, 700, 500, 860, 600, Shop_exchange)) ;跳出購買訊息
						{
							Random, xx, 713, 863
							Random, yy, 543, 569
							C_Click(xx,yy) ;隨機點擊"兌換"鈕
							sleep 4000
							if (Find(x, y, 700, 500, 850, 600, Shop_Confirm)) ;如果金幣不足
							{
								Item_Equ_Box1Coin++
								Random, xx, 423, 558
								Random, yy, 543, 569
								C_Click(xx,yy) ;點擊取消
							}
							C_Click(187,362) ;點不知火取消獲得道具的視窗
							Break
						}
						sleep 600
					}
				}
				if (GdipImageSearch(x, y, "img/SkillBook_ATK.png", 110, 8, ShopX1, ShopY1, ShopX2, ShopY2) and SkillBook_ATK and AtkCoin<1) ;如果有攻擊課本
				{
					SkillBookPos := dwmgetpixel(x,y)
					LogShow("購買艦艇教材-攻擊(金幣)")
					Loop, 20
					{
						if (SkillBookPos=dwmgetpixel(x,y))
						{
							xx := x+10
							yy := y+8
							C_Click(xx,yy) ;點擊課本
						}
						if (Find(x, y, 700, 500, 860, 600, Shop_exchange)) ;跳出購買訊息
						{
							Random, xx, 713, 863
							Random, yy, 543, 569
							C_Click(xx,yy) ;隨機點擊"兌換"鈕
							sleep 4000
							if (Find(x, y, 700, 500, 850, 600, Shop_Confirm)) ;如果金幣不足
							{
								AtkCoin++
								Random, xx, 423, 558
								Random, yy, 543, 569
								C_Click(xx,yy) ;點擊取消
							}
							Break
						}
						sleep 600
					}
				}
				if (GdipImageSearch(x, y, "img/SkillBook_DEF.png", 110, 8, ShopX1, ShopY1, ShopX2, ShopY2) and SkillBook_DEF and DefCoin<1) ;如果有防禦課本
				{
					SkillBookPos := dwmgetpixel(x,y)
					LogShow("購買艦艇教材-防禦(金幣)")
					Loop, 20
					{
						if (SkillBookPos=dwmgetpixel(x,y))
						{
							xx := x+10
							yy := y+8
							C_Click(xx,yy) ;點擊課本
						}
						if (Find(x, y, 700, 500, 860, 600, Shop_exchange)) ;跳出購買訊息
						{
							Random, xx, 713, 863
							Random, yy, 543, 569
							C_Click(xx,yy) ;隨機點擊"兌換"鈕
							sleep 4000
							if (Find(x, y, 700, 500, 850, 600, Shop_Confirm)) ;如果金幣不足
							{
								DefCoin++
								Random, xx, 423, 558
								Random, yy, 543, 569
								C_Click(xx,yy) ;點擊取消
							}
							Break
						}
						sleep 600
					}
				}
				if (GdipImageSearch(x, y, "img/SkillBook_SUP.png", 110, 8, ShopX1, ShopY1, ShopX2, ShopY2) and SkillBook_SUP and SupCoin<1) ;如果有防禦課本
				{
					SkillBookPos := dwmgetpixel(x,y)
					LogShow("購買艦艇教材-輔助(金幣)")
					Loop, 20
					{
						if (SkillBookPos=dwmgetpixel(x,y))
						{
							xx := x+10
							yy := y+8
							C_Click(xx,yy) ;點擊課本
						}
						if (Find(x, y, 700, 500, 860, 600, Shop_exchange)) ;跳出購買訊息
						{
							Random, xx, 713, 863
							Random, yy, 543, 569
							C_Click(xx,yy) ;隨機點擊"兌換"鈕
							sleep 4000
							if (Find(x, y, 700, 500, 850, 600, Shop_Confirm)) ;如果金幣不足
							{
								SupCoin++
								Random, xx, 423, 558
								Random, yy, 543, 569
								C_Click(xx,yy) ;點擊取消
							}
							Break
						}
						sleep 600
					}
				}
				if (GdipImageSearch(x, y, "img/Cube.png", 113, 8, ShopX1, ShopY1, ShopX2, ShopY2) and Cube and CubeCoin<1) ;如果有心智魔方
				{
					CubePos := dwmgetpixel(x,y)
					LogShow("購買心智魔方(金幣)")
					Loop, 20
					{
						if (CubePos=dwmgetpixel(x,y))
						{
							xx := x+10
							yy := y+8
							C_Click(xx,yy) ;點擊魔方
						}
						if (Find(x, y, 700, 500, 860, 600, Shop_exchange)) ;跳出購買訊息
						{
							Random, xx, 713, 863
							Random, yy, 543, 569
							C_Click(xx,yy) ;隨機點擊"兌換"鈕
							sleep 4000
							if (Find(x, y, 700, 500, 850, 600, Shop_Confirm)) ;如果金幣不足
							{
								CubeCoin++
								Random, xx, 423, 558
								Random, yy, 543, 569
								C_Click(xx,yy) ;點擊取消
							}
							Break
						}
						sleep 600
					}
				}
				if (GdipImageSearch(x, y, "img/Part_Aircraft.png", 113, 8, ShopX1, ShopY1, ShopX2, ShopY2) and Part_Aircraft and Part_AircraftCoin<1) 
				{
					Part_AircraftPos := dwmgetpixel(x,y)
					LogShow("購買艦載機部件T3(金幣)")
					Loop, 20
					{
						if (Part_AircraftPos=dwmgetpixel(x,y))
						{
							xx := x+10
							yy := y+8
							C_Click(xx,yy) ;點擊
						}
						if (Find(x, y, 700, 500, 860, 600, Shop_exchange)) ;跳出購買訊息
						{
							Random, xx, 713, 863
							Random, yy, 543, 569
							C_Click(xx,yy) ;隨機點擊"兌換"鈕
							sleep 4000
							if (Find(x, y, 700, 500, 850, 600, Shop_Confirm)) ;如果金幣不足
							{
								Part_AircraftCoin++
								Random, xx, 423, 558
								Random, yy, 543, 569
								C_Click(xx,yy) ;點擊取消
							}
							Break
						}
						sleep 600
					}
				}
				if (GdipImageSearch(x, y, "img/Part_Cannon.png", 113, 8, ShopX1, ShopY1, ShopX2, ShopY2) and Part_Cannon and Part_CannonCoin<1) 
				{
					Part_CannonPos := dwmgetpixel(x,y)
					LogShow("購買主砲部件T3(金幣)")
					Loop, 20
					{
						if (Part_CannonPos=dwmgetpixel(x,y))
						{
							xx := x+10
							yy := y+8
							C_Click(xx,yy) ;點擊
						}
						if (Find(x, y, 700, 500, 860, 600, Shop_exchange)) ;跳出購買訊息
						{
							Random, xx, 713, 863
							Random, yy, 543, 569
							C_Click(xx,yy) ;隨機點擊"兌換"鈕
							sleep 4000
							if (Find(x, y, 700, 500, 850, 600, Shop_Confirm)) ;如果金幣不足
							{
								Part_CannonCoin++
								Random, xx, 423, 558
								Random, yy, 543, 569
								C_Click(xx,yy) ;點擊取消
							}
							Break
						}
						sleep 600
					}
				}
				if (GdipImageSearch(x, y, "img/Part_torpedo.png", 113, 8, ShopX1, ShopY1, ShopX2, ShopY2) and Part_torpedo and Part_torpedoCoin<1) 
				{
					Part_torpedoPos := dwmgetpixel(x,y)
					LogShow("購買魚雷部件T3(金幣)")
					Loop, 20
					{
						if (Part_torpedoPos=dwmgetpixel(x,y))
						{
							xx := x+10
							yy := y+8
							C_Click(xx,yy) ;點擊
						}
						if (Find(x, y, 700, 500, 860, 600, Shop_exchange)) ;跳出購買訊息
						{
							Random, xx, 713, 863
							Random, yy, 543, 569
							C_Click(xx,yy) ;隨機點擊"兌換"鈕
							sleep 4000
							if (Find(x, y, 700, 500, 850, 600, Shop_Confirm)) ;如果金幣不足
							{
								Part_torpedoCoin++
								Random, xx, 423, 558
								Random, yy, 543, 569
								C_Click(xx,yy) ;點擊取消
							}
							Break
						}
						sleep 600
					}
				}
				if (GdipImageSearch(x, y, "img/Part_Anti_Aircraft.png", 113, 8, ShopX1, ShopY1, ShopX2, ShopY2) and Part_Anti_Aircraft and Part_Anti_AircraftCoin<1) 
				{
					Part_Anti_AircraftPos := dwmgetpixel(x,y)
					LogShow("購買防空砲部件(金幣)")
					Loop, 20
					{
						if (Part_Anti_AircraftPos=dwmgetpixel(x,y))
						{
							xx := x+10
							yy := y+8
							C_Click(xx,yy) ;點擊
						}
						if (Find(x, y, 700, 500, 860, 600, Shop_exchange)) ;跳出購買訊息
						{
							Random, xx, 713, 863
							Random, yy, 543, 569
							C_Click(xx,yy) ;隨機點擊"兌換"鈕
							sleep 4000
							if (Find(x, y, 700, 500, 850, 600, Shop_Confirm)) ;如果金幣不足
							{
								Part_Anti_AircraftCoin++
								Random, xx, 423, 558
								Random, yy, 543, 569
								C_Click(xx,yy) ;點擊取消
							}
							Break
						}
						sleep 600
					}
				}
				if (Find(x, y, ShopX1, ShopY1, ShopX2, ShopY2, 通用部件T3) and Part_Common and Part_CommonCoin<1) 
				{
					Part_CommonPos := dwmgetpixel(x,y)
					LogShow("購買共通部件(金幣)")
					Loop, 20
					{
						if (Part_CommonPos=dwmgetpixel(x,y))
						{
							xx := x+10
							yy := y+8
							C_Click(xx,yy) ;點擊
						}
						if (Find(x, y, 700, 500, 860, 600, Shop_exchange)) ;跳出購買訊息
						{
							Random, xx, 713, 863
							Random, yy, 543, 569
							C_Click(xx,yy) ;隨機點擊"兌換"鈕
							sleep 4000
							if (Find(x, y, 700, 500, 850, 600, Shop_Confirm)) ;如果金幣不足
							{
								Part_CommonCoin++
								Random, xx, 423, 558
								Random, yy, 543, 569
								C_Click(xx,yy) ;點擊取消
							}
							Break
						}
						sleep 600
					}
				}
				if (GdipImageSearch(x, y, "img/Item_Water.png", 125, 8, ShopX1, ShopY1, ShopX2, ShopY2) and Item_Water and Item_WaterCoin<1) 
				{
					Item_WaterPos := dwmgetpixel(x,y)
					LogShow("購買秘製冷卻水(金幣)")
					Loop, 20
					{
						if (Item_WaterPos=dwmgetpixel(x,y))
						{
							xx := x+10
							yy := y+8
							C_Click(xx,yy) ;點擊
						}
						if (Find(x, y, 700, 500, 860, 600, Shop_exchange)) ;跳出購買訊息
						{
							Random, xx, 713, 863
							Random, yy, 543, 569
							C_Click(xx,yy) ;隨機點擊"兌換"鈕
							sleep 4000
							if (Find(x, y, 700, 500, 850, 600, Shop_Confirm)) ;如果金幣不足
							{
								Item_WaterCoin++
								Random, xx, 423, 558
								Random, yy, 543, 569
								C_Click(xx,yy) ;點擊取消
							}
							Break
						}
						sleep 600
					}
				}
				if (GdipImageSearch(x, y, "img/Item_Tempura.png", 125, 8, ShopX1, ShopY1, ShopX2, ShopY2) and Item_Tempura and Item_TempuraCoin<1) 
				{
					Item_TempuraPos := dwmgetpixel(x,y)
					LogShow("購買天婦羅(金幣)")
					Loop, 20
					{
						if (Item_TempuraPos=dwmgetpixel(x,y))
						{
							xx := x+10
							yy := y+8
							C_Click(xx,yy) ;點擊
						}
						if (Find(x, y, 700, 500, 860, 600, Shop_exchange)) ;跳出購買訊息
						{
							Random, xx, 713, 863
							Random, yy, 543, 569
							C_Click(xx,yy) ;隨機點擊"兌換"鈕
							sleep 4000
							if (Find(x, y, 700, 500, 850, 600, Shop_Confirm)) ;如果金幣不足
							{
								Item_TempuraCoin++
								Random, xx, 423, 558
								Random, yy, 543, 569
								C_Click(xx,yy) ;點擊取消
							}
							Break
						}
						sleep 600
					}
				}
				ShopCount++
				if (Item_Ex4_Box and ShopCount>=7 and ShopCount<=10)
				{
					if (Find(x, y, 700, 651, 1034, 711, supply)) ;軍需商店
					{
						C_Click(x, y)
					}
					if (Find(x, y, ShopX1, ShopY1, ShopX2, ShopY2, 科技箱T4) and Item_Box_T4Coin<1) ;T4裝備箱
					{
						Item_Box_T4 := dwmgetpixel(x,y)
						Loop, 20
						{
							if (dwmgetpixel(x,y)=Item_Box_T4)
							{
								C_Click(x, y)
								sleep 500
							}
							if (Find(n, m, 700, 500, 860, 600, Shop_exchange)) ;跳出購買訊息
							{
								Random, xx, 713, 863
								Random, yy, 543, 569
								C_Click(xx,yy) ;隨機點擊"兌換"鈕
								sleep 4000
								if (Find(n, m, 700, 500, 850, 600, Shop_Confirm)) ;如果金幣不足
								{
									Item_Box_T4Coin++
									Random, xx, 423, 558
									Random, yy, 543, 569
									C_Click(xx,yy) ;點擊取消
								}
							Break
							}
							sleep 500
						}
					}
				}
				if (ShopCount>10)
				{
					AcademyShopDone := 1
					ShopCount := VarSetCapacity
					AtkCoin := VarSetCapacity
					DefCoin := VarSetCapacity
					SupCoin := VarSetCapacity
					CubeCoin := VarSetCapacity
					LogShow("購買結束")
					C_Click(59, 91)
					break
				}
				sleep 500
			}
		}
		if (Find(x, y, 825, 146, 925, 206, AcademyDoneIco2) and AcademyTactics and learnt<1) ;學院出現！
		{
			LogShow("我們真的學不來！")
			C_Click(740, 166) ;點擊學院
			sleep 3000  
			Loop
			{
				if (Find(x, y, 343, 224, 934, 532, 繼續學習))
				{
					LogShow("繼續學習！")
					C_Click(788, 567)
				}
				else if (DwmCheckcolor(330, 209, 16777215) and DwmCheckcolor(414, 225, 16777215) and DwmCheckcolor(661, 548, 16777215) and DwmCheckcolor(608, 550, 16777215)) ;學習的技能已滿等
				{
					C_Click(643, 545) ;點擊確定
				}
				else if (Find(x, y, 1031, 624, 1131, 684, StartLesson)) ;選擇課本頁面
				{
					If (150expbookonly)
					{
						if (GdipImageSearch(x, y, "img/150exp.png", 110, 8, 100, 100, 1200, 650)) ;如果找到150% EXP課本
						{
							LogShow("使用150%經驗課本！")
							xx := x
							yy := y + 30
							C_Click(xx, yy)
							C_Click(1097, 641) ;開始課程
						}
						else
						{
							LogShow("未找到150%經驗課本！")
							C_Click(904, 655) ;取消
						}
					}
					else
					{
						LogShow("開始課程！")
						C_Click(1097, 641)
						if (DwmCheckcolor(556, 358, 16249847))
						{
							LogShow("課本不足，無法學習")
							C_Click(903,653)
						}
					}
				}
				else if (DwmCheckcolor(330, 210, 16777215) and DwmCheckcolor(414, 226, 16777215) and DwmCheckcolor(599, 549, 4353453) and DwmCheckcolor(661, 559, 16777215)) ;技能滿等
				{
					C_Click(639, 545)
				}
				else if (Find(x, y, 700, 500, 860, 650, Academy_BTN_Confirm)) 
				{
					LogShow("確認使用教材以訓練技能！")
					C_Click(x, y)
				}
				else if (Find(x, y, 102, 33, 202, 93, Academy_In_Academy))
				{
					sleep 4000
					if (Find(x, y, 102, 33, 202, 93, Academy_In_Academy))
					{
						LogShow("學習結束～！")
						learnt := 1
						C_Click(56, 94)
						sleep 1000
						break
					}
				}
				sleep 300
			}
		}
		if (DwmCheckcolor(532, 233, 16776175) and Classroom and ClassroomDone<1) ;大講堂出現！
		{
			C_Click(460, 208)
			Loop
			{
				if (DwmCheckcolor(78, 547, 16775151) and DwmCheckcolor(190, 67, 14610431)) ;等待進入大講堂
					break
				sleep 300
			}
			sleep 500
			Loop
			{
				EndLesson := DwmCheckcolor(1229, 677, 11382445) ;結束課程
				if (EndLesson) ;結束課程
				{
					Random, x, 1068, 1224
					Random, y, 667, 699
					C_Click(x, y)
				}
				if (DwmCheckcolor(330, 210, 16777215) and DwmCheckcolor(414, 226, 16777215) and DwmCheckcolor(790, 556, 4355509))
				{
					C_Click(790, 554) ;確定結束課程
				}
				V := DwmCheckcolor(412, 99, 6520237) , I := DwmCheckcolor(474, 101, 6520237), C := DwmCheckcolor(551, 100, 6520237)
				if (V and I and C)
				{
					Random, x, 267, 1108
					Random, y, 81, 178
					C_Click(x, y)
				}
			}
		}
		sleep 300
		Academycount++
		if (Academycount>15)
		{
			LogShow("離開學院。")
			GetOil := VarSetCapacity
			Academycount := VarSetCapacity
			fullycoin := VarSetCapacity
			learnt := VarSetCapacity
			AcademyShopDone := VarSetCapacity
			AcademyDone := 1
			Settimer, AcademyClock, -900000 ;15分鐘後再開始檢查
			C_Click(38, 92)
			sleep 2000
			Loop, 60
			{
				if (Find(x, y, 86, 34, 186, 94, AcademyPage_Academy))
				{
					C_Click(38, 92)
					sleep 3000
				}
				else if (Find(x, y, 996, 362, 1096, 422, MainPage_Btn_WeighAnchor))
				{
					Break
				}
				GetItem()
				CloseEventList()
				sleep 500
			}
			break
		}
	}
}
return

AcademyClock:
LogShow("AcademyDone := VarSetCapacity")
AcademyDone := VarSetCapacity
return

WinSub:
LDplayerCheck := [Find(x, y, 1119, 0, 1219, 46, LdPlayerLogo), CloneWindowforDWM]
if !LDplayerCheck[1] or LDplayerCheck[2]
{
	WinGet, Wincheck, MinMax, %title%
	if Wincheck=-1
	{
		LogShow("視窗被縮小，等待自動恢復")
		WinRestore, %title%
	}
}
return

ReSizeWindowSub:
GuiControl, disable, ReSizeWindowSub
LogShow("視窗已調整為：1280 x 720")
WinRestore,  %title%
WinMove,  %title%, , , , %EmulatorResolution_W%, %EmulatorResolution_H%
sleep 100
GuiControl, enable, ReSizeWindowSub
return

DormSub:
if (DormDone<1) ;後宅發現任務
{
	DormX1 := 0
	DormY1 := 0
	DormX2 := 1250
	DormY2 := 620
	Random, x, 750, 938
	Random, y, 290, 508
	C_Click(x, y)
	sleep 1000
	Loop ;等待進入後宅
	{
		sleep 500
		if (Find(x, y, 907, 238, 1007, 298, DormIco)) ;
		{
			Random, x, 750, 938
			Random, y, 290, 508
			C_Click(x, y)
			sleep 1000
		}
		GuLuGuLuLu()
		if (Find(x, y, 0, 59, 91, 119, DormPage_in_Dorm))
		{
			sleep 500
			break
		}
		else if (Find(x, y, 1057, 631, 1157, 691, DormPage_Exp_Confirm))
		{
			C_Click(x, y) ;獲得經驗 按確定
		}
		else if (DormCount=200)
		{
			LogShow("DormSub Error")
			return
		}
		DormCount++
	}
	DormCount := VarSetCapacity
	Loop
	{
		GuLuGuLuLu() ;如果太過飢餓 
		if (Find(x, y, 53, 168, 153, 228, DormPage_Training))
			C_Click(1261, 464) ;點到訓練自動離開
		if (DwmCheckcolor(372, 337, 11924356) and DwmCheckcolor(458, 344, 9235282) and DwmCheckcolor(450, 292, 8090037))
			C_Click(1261, 464) ;點到施工自動離開
		if (Find(x, y, 592, 477, 692, 537, DormPage_Cancel))
			C_Click(x, y) ;點到換層自動離開
		if (Find(x, y, 277, 482, 377, 542, DormPage_Supplies))
			C_Click(617, 115) ;點到存糧自動離開
		if (Find(x, y, 92, 513, 192, 573, DormPage_Subject))
			C_Click(37, 90) ;點到管理自動離開
		if (Find(x, y, 98, 208, 198, 268, DormPage_Subject_Shop))
			C_Click(1200, 68) ;點到商店自動離開
		if (Find(x, y, 591, 533, 691, 593, DormPage_Inform_Confirm))
			C_Click(638, 545) ;點到訊息自動離開
		if (Find(x, y, 301, 87, 401, 147, DormPage_Share))
			C_Click(1299, 646) ;點到分享自動離開
		if (Find(x, y, 1057, 631, 1157, 691, DormPage_Exp_Confirm))
			C_Click(1110, 657) ;獲得經驗 按確定
		if (Find(x, y, 470, 452, 570, 512, DormPage_NickName))
			C_Click(x, y) ;點到取名自動離開
		if (DormFood and DormFoodDone<1)
		{
			FoodX := Ceil((550-30)*(DormFoodBar/100)+30)
			if (DwmGetpixel(FoodX, 725)<8000000) ;存糧進度條
			{
				FoodCheck := 1
			} else {
				FoodCheck := 0
			}
			;~ FoodCheck := DwmCheckcolor(FoodX, 729, 5394770) 
			FoodCheck2 := Find(x, y, 0, 657, 98, 717, DormPage_YellowCross) ;左下黃十字
			if (FoodCheck and FoodCheck2)
			{
				if (DormFoodBar>=50 and DormFoodBar<65)
				{
					DormFoodBar := 66
				}
				else if (DormFoodBar<50 and DormFoodBar>39)
				{
					DormFoodBar := 38
				}
				LogShow("存糧不足，自動補給")
				C_Click(292,718)
				Loop
				{
					Food1 := Dwmgetpixel(305, 468)
					Food2 := Dwmgetpixel(461, 468)
					Food3 := Dwmgetpixel(619, 468)
					Food4 := Dwmgetpixel(774, 468)
					SuppilesbartargetX := Ceil((1020-430)*(DormFoodBar/100)+430)  ; x1=430 , x2=1020, y=303
					Suppilesbar := DwmCheckcolor(SuppilesbartargetX, 303, 4869450)
					if (Food1<10000000 and Suppilesbar)
					{
						C_Click(358,416) 
					}
					else if (Food2<10000000 and Suppilesbar)
					{
						C_Click(519,416)
					}
					else if (Food3<10000000 and Suppilesbar)
					{
						C_Click(669,416)
					}
					else if (Food4<10000000 and Suppilesbar)
					{
						C_Click(826,416)
					}
					if (!Suppilesbar or (Food1>10000000 and Food2>10000000 and Food3>10000000 and Food4>10000000))
					{
						C_Click(557,119) ;離開餵食
						sleep 500
						DormFoodDone := 1
						break
					}
				}
			}
		}
		if ((GdipImageSearch(x, y, "img/Dorm_Coin.png", 8, 8, DormX1, DormY1, DormX2, DormY2) or GdipImageSearch(x, y, "img/Dorm_Coin2.png", 7, 8, DormX1, DormY1, DormX2, DormY2)) and DormCoin and Dorm_Coin<3) 
		{
			LogShow("收成傢俱幣")
			C_Click(x, y)
			Dorm_Coin++
		}
		else if ((GdipImageSearch(x, y, "img/Dorm_heart.png", 5, 8, DormX1, DormY1, DormX2, DormY2) or GdipImageSearch(x, y, "img/Dorm_heart2.png", 10, 8, DormX1, DormY1, DormX2, DormY2)) and Dormheart and Dorm_heart<3) 
		{
			LogShow("增加親密度")
			C_Click(x, y)
			Dorm_heart++
		}
		sleep 300
		Dormcount++
		if (Dormcount>15)
		{
			LogShow("離開後宅。")
			Dorm_Coin := VarSetCapacity
			Dorm_heart := VarSetCapacity
			Dormcount := VarSetCapacity
			DormFoodDone := VarSetCapacity
			DormDone := 1
			Settimer, DormClock, -1800000 ;半小時檢查一次
			C_Click(35, 86)
			sleep 2000
			Loop, 60
			{
				if (Find(x, y, 0, 59, 91, 119, DormPage_in_Dorm))
				{
					C_Click(x, y)
					sleep 2000
				}
				else if (Find(x, y, 996, 362, 1096, 422, MainPage_Btn_WeighAnchor))
				{
					Break
				}
				sleep 500
			}
			break
		}
	}
}
return

DormClock:
DormDone := VarSetCapacity
LogShow("DormDone := VarSetCapacity")
return

Reload:
Critical
WindowName = Azur Lane - %title%
wingetpos, azur_x, azur_y,, WindowName
iniwrite, %azur_x%, settings.ini, Winposition, azur_x
iniwrite, %azur_y%, settings.ini, Winposition, azur_y
Guicontrol, disable, Reload
Reload
return

whitealbum: ;重要！
Random, num, 1, 15
if (num=1) 
    Guicontrol, ,starttext, 目前狀態：白色相簿什麼的已經無所謂了。
else if (num=2) 
    Guicontrol, ,starttext, 目前狀態：為什麼你會這麼熟練啊！
else if (num=3)   
    Guicontrol, ,starttext, 目前狀態：是我，是我先，明明都是我先來的……
else if (num=4) 
    Guicontrol, ,starttext, 目前狀態：又到了白色相簿的季節。
else if (num=5) 
    Guicontrol, ,starttext, 目前狀態：為什麼會變成這樣呢……
else if (num=6) 
    Guicontrol, ,starttext, 目前狀態：傳達不了的戀情已經不需要了。
else if (num=7) 
    Guicontrol, ,starttext, 目前狀態：你到底要把我甩開多遠你才甘心啊！？
else if (num=8) 
    Guicontrol, ,starttext, 目前狀態：冬馬和雪菜都是好女孩！
else if (num=9) 
    Guicontrol, ,starttext, 目前狀態：夢裡不覺秋已深，余情豈是為他人。
else if (num=10) 
    Guicontrol, ,starttext, 目前狀態：先從我眼前消失的是你吧！？
else if (num=11) 
    Guicontrol, ,starttext, 目前狀態：你就把你能治好的人給治好吧。
else if (num=12) 
    Guicontrol, ,starttext, 目前狀態：我……害怕雪，因為很美麗，所以我害怕。
else if (num=13) 
    Guicontrol, ,starttext, 目前狀態：對不起…我的嫉妒，真的很深啊。
else if (num=14) 
    Guicontrol, ,starttext, 目前狀態：逞強的話語中 卻總藏著一聲嘆息 。
return

DelegationMission() {
	點擊繼續 := "|<>*172$68.zzzrzbzzrzrzw0tz0A7wmNzz/CTk39yQ2jzmXbw0a7Z03zw8s703lm0Ezz0C0mG0wY2DzmHXw0WC301jw0ty0A7UlbPztyTmH1y407zk3Xw00799bzw0U7003kGtvzts1k03s00azU2SS00Tx03zs1bbU07kGQzzp9tk00Q027zk2SM003E01zx207zbzY00PyGs1zVztA02zzyyTszzzzzs"
	委託 :="|<>*145$53.k001z7zsDU003z7w0D000DyD00zzUzzwS0Tk000600EzU000A07Vz0000Tzz3zk007zzy7zUkEDk1wDw3UkDU3sS0D1kDzzk00S7kTzs00sDy3w00060000s0U7w0001zzwDs0003U3sTy3z1z07kzw3y3y0DVzw3k7wQT3nw10Tssy7Xw01zllwD6000DU3sS0000D07s007y0S0Dk1zzzzwTzk3"
	進行中 := "|<>*201$57.zrzzDzzzDww9zlU1zsz3X7wQ0Dz7w8073k1zszn00kzzy007kszMzzk00w77z7zyT77k0Dl00nsw101wM06T7U8tz3z7nswl01kTsy00680C3z7k00l7DyTsy006803nz7nswl00STszz7y0zznz7zsz03syT0zz7ss07ns7zszjk0yTVzzDw"
	NoneDelegation := "|<>*170$58.zzzzzzzzyDzzzzzzzzszzzzzzzzzXzzzzzzzzyDzzzzzzzzszzzzzzzzzXzzzzzzzzyDzzzzzzzzszzzzzzzzzXzzzzzzzzyDzzzzzzzzss000DzzzzXU000zzzzyDzzzzzzzzszzzzzzzzzXzzzzzzzzyDzzzzzzzzszzzzzzzzzXzzzzzzzzyDzzzzzzzzszzzzzzzzzXzzzzzzzzyDzzzzzzzzszzzzzzzzzXU"
	緊急 := "|<>*138$35.000000000003zzzzzzzzzzzzzzz3zk01w0DU03k0T0161ky00A00Q0ky00s00Q01s0Ms03s0Dk07U0z00DUCC00y00Q28w00s49w03kA1U11U0367W81bzzzzzw"
	Delegation_Empty := "|<>*155$65.UTXsz0Tk3tsTz7lySTwztkzy73wyztzn9zwC7txznzmE7tRDnnzbzVUTmGTUDzDzXDzagz7zyTzCTzANyTzwzyQzyNnwzztzws3wvbtzznzts7xzTvzzjzvk"
	Loop
	{
		if (Find(x, y, 97, 34, 197, 94, 委託))
			break
		sleep 500
	}
	Loop
	{
		sleep 400
		if (DwmCheckcolor(181, 136, 11358530)) 
		{	
			LogShow("完成委託任務")
			C_Click(411, 180)
		}
		else if (DwmCheckcolor(58, 76, 16777215) or DwmCheckcolor(1215, 74, 16777215))
		{
			C_Click(411, 180)
		}
		else if (Find(x, y, 413, 472, 881, 659, 點擊繼續))
		{
			LogShow("每日獲得道具，點擊繼續")
			C_Click(636, 91)
		}
		else if (Find(x, y, 359, 175, 465, 250, 進行中) or Find(x, y, 359, 175, 465, 250, NoneDelegation)) ;任務都在進行中 or 都沒接到任務
		{
			break
		}
		else if (A_index=100 or A_index=120 or A_index=140 or A_index=160)
		{
			LogShow("似乎卡住了，嘗試點擊上方1")
			C_Click(629, 73)
		}
	}
	C_Click(51, 283) ;緊急
	sleep 1500
	Loop
	{
		sleep 300
	} until DwmCheckcolor(53, 295, 16252820) ;等待切換到緊急頁面
	Loop
	{
		sleep 200
		if (DwmCheckcolor(181, 136, 11358530))
		{
			LogShow("完成委託任務")
			C_Click(411, 180)
		}
		else if (DwmCheckcolor(58, 76, 16777215) or DwmCheckcolor(1215, 74, 16777215))
		{
			C_Click(411, 180)
		}
		else if (Find(x, y, 413, 472, 881, 659, 點擊繼續))
		{
			LogShow("緊急獲得道具，點擊繼續")
			C_Click(636, 91)
		}
		else if (Find(x, y, 359, 175, 459, 235, 進行中) or Find(x, y, 359, 175, 465, 235, NoneDelegation) or Find(x, y, 325, 334, 425, 394, Delegation_Empty)) ;任務都在進行中 or 都沒接到任務
		{
			break
		}
		else if (A_index=100 or A_index=120 or A_index=140 or A_index=160)
		{
			LogShow("似乎卡住了，嘗試點擊上方2")
			C_Click(629, 73)
		}
		else if (Find(x, y, 0, 278, 100, 338, 緊急))
		{
			failedcount++
			if (failedcount>20)
				break
		}
	}
	if (Find(x, y, 364, 177, 465, 725, NoneDelegation))  ;接獲緊急任務
	{
		DelegationMission3()
	}
	C_Click(53, 191) ;每日
	sleep 300
	DelegationMission3()
	sleep 500
	Loop, 30
	{
		if (DwmCheckcolor(167, 64, 15201279))
		{
			C_Click(53, 89) ;離開
			sleep 2000
		}
		else if !(DwmCheckcolor(167, 64, 15201279))
		{
			Break
		}
		sleep 300
	}
}

DelegationMission3() ;自動接收軍事任務 . 0=接受失敗 . 1=接受成功 . 2=油耗過高不接受 . 3=進入選單失敗
{
	if (DwmCheckcolor(438, 205, 6515067) or DwmCheckcolor(438, 205, 7042444)) ;第一個任務未開始
	{
		LogShow("Mission1 := 0")
		Mission1 := 0
	}
	if (DwmCheckcolor(435, 352, 6516091) or DwmCheckcolor(435, 352, 7042444)) ;第二個任務未開始
	{
		LogShow("Mission2 := 0")
		Mission2 := 0
	}
	if (DwmCheckcolor(437, 499, 7040379) or DwmCheckcolor(437, 499, 7043468)) ;第三個任務未開始
	{
		LogShow("Mission3 := 0")
		Mission3 := 0
	}
	if (DwmCheckcolor(435, 643, 6516091) or DwmCheckcolor(435, 643, 7043468)) ;第四個任務未開始
	{
		LogShow("Mission4 := 0")
		Mission4 := 0
	}
	if (Mission1 = 0 and !DwmCheckcolor(1082, 62, 9211540) and !DwmCheckcolor(1088, 63, 11383477))
	{
		C_Click(560, 192)
		Mission1 := DelegationMission2()
		if (Mission1=2 and !DwmCheckcolor(1082, 62, 9211540) and !DwmCheckcolor(1088, 63, 11383477) and Mission4=0)
		{
			Swipe(1221,395, 1221, 115)
			C_Click(560, 651)
			DelegationMission2()
		}
	}
	if (Mission2 = 0 and !DwmCheckcolor(1082, 62, 9211540) and !DwmCheckcolor(1088, 63, 11383477))
	{
		C_Click(560, 332)
		Mission2 := DelegationMission2()
		if (Mission1=2  and Mission4=0)
		{
			Swipe(1221,395, 1221, 115)
			C_Click(560, 651)
			DelegationMission2()
		}
	}
	if (Mission3 = 0 and !DwmCheckcolor(1082, 62, 9211540) and !DwmCheckcolor(1088, 63, 11383477))
	{
		C_Click(560, 471)
		Mission3 := DelegationMission2()
		if (Mission3=2  and Mission4=0)
		{
			Swipe(1221,395, 1221, 115)
			C_Click(560, 651)
			DelegationMission2()
		}
	}
	if (Mission4 = 0 and !DwmCheckcolor(1082, 62, 9211540) and !DwmCheckcolor(1088, 63, 11383477))
	{
		C_Click(560, 620)
		Mission4 := DelegationMission2()
		if (Mission4=2)
		{
			Swipe(1221,395, 1221, 115)
			C_Click(560, 651)
			DelegationMission2()
		}
		if (DwmCheckcolor(1085, 61, 12435142)) ;如果可派出艦隊是1/4
		{
			Swipe(1221,395, 1221, 115)
			C_Click(560, 651)
			DelegationMission2()			
		}
	}
	Mission1 := VarSetCapacity
	Mission2 := VarSetCapacity
	Mission3 := VarSetCapacity
	Mission4 := VarSetCapacity
}

DelegationMission2()
{
Loop, 30  ;等待選單開啟
	{
		sleep 300
		if (DwmCheckcolor(992, 365, 16777215) and DwmCheckcolor(1149, 366, 16777215))
		{
			loopcount := VarSetCapacity
			break
		}
		loopcount++
		if (loopcount>20)
		{
			;~ Logshow("未能成功進入軍事任務選單")
			e := 3
			loopcount := VarSetCapacity
			return e
		}
	}
	;~ LogShow("成功進入")
	if (DwmCheckcolor(1138, 338, 4870499) or DwmCheckcolor(1108, 166, 16729459) or DwmCheckcolor(772, 165, 3748921) or DwmCheckcolor(771, 166, 3224625)) ;如果耗油是個位數 或 出現寶石 或 出現油田
	{
		C_Click(931, 380)
		if (DwmCheckcolor(1149, 386, 15709770)) ;如果成功推薦角色
		{
			C_Click(1096, 385) ;開始
			sleep 1000
			if (DwmCheckcolor(329, 209, 16777215) and DwmCheckcolor(375, 232, 16777215)) ;如果有花費油
			{
				C_Click(788, 546) ;確認
				sleep 1000
			}
			C_Click(1227, 172) ;離開介面
			sleep 300
			Swipe(1220,187,1220,473) ;往上拉
			e := 1 ;成功接受委託任務
			;~ LogShow("軍事任務成功接受")
			return e
		}
		else 
		{
			C_Click(1227, 172) ;離開介面
			sleep 500
			Swipe(1220,187,1220,473) ;往上拉
			sleep 500
			e := 0 ;接收失敗...可能是角色等級或數量不足 etc...
			;~ LogShow("軍事任務接收失敗")
			return e
		}
	}
	else
	{
		C_Click(1227, 172) ;離開介面
		sleep 500
		Swipe(1220,187,1220,473) ;往上拉
		sleep 500
		e := 2 ;油耗超過個位數 不予接受
		;~ LogShow("軍事任務油耗超過個位數")
		return e
	}
}

battlevictory() ;戰鬥勝利(失敗) 大獲全勝
{
	Victory := Find(x, y, 783, 385, 883, 445, Battle_Victory)
	IsTouch_to_continue := Find(x, y, 122, 637, 222, 697, Battle_Touch_to_Continue)
	;~ Global
	if (Victory and IsTouch_to_continue)
	{	
		if (Find(x, y, 790, 438, 870, 498, "|<>*85$18.Tzw7zsbzllzXtz7wSDyQTz8zzlzzXzzZzzATySTwz7tzbnzlbztDzwU")) ; 有隊員倒下
		{
			message = 敵艦討伐完畢（隊員受重創）。
		} 
		else if (Find(x, y, 790, 449, 870, 548, "|<>*85$18.Tzw7zsbzllzXtz7wSDyQTz8zzlzzXzzZzzATySTwz7tzbnzlbztDzwU"))
		{
			message = 敵艦討伐完畢（戰鬥時間逾120秒）。
		}
		else 
		{
			message = 敵艦討伐完畢。
		}
		LogShow(message)
		Random, x, 100, 1000
		Random, y, 100, 600
		sleep 500
		C_Click(x, y)
	}
	else if (IsTouch_to_continue and !Victory) ;點擊繼續
	{
		Global AnchorFailedTimes
		AnchorFailedTimes++
		rate := Round(AnchorFailedTimes/AnchorTimes*100, 2)
		Message = 出擊: %AnchorTimes% 次　覆沒：%AnchorFailedTimes% 次　機率： %rate%`%
		LogShow(Message)
		Random, x, 100, 1000
		Random, y, 100, 600
		sleep 500
		C_Click(x, y)
	}
}

GetItem()
{
	if (Find(x, y, 450, 130, 830, 330, Touch_to_Contunue)) ;獲得道具
	{
		LogShow("獲得道具，點擊繼續！")
		C_Click(638, 519)
	}
}

GetCard()
{
	if (Find(x, y, 1051, 622, 1151, 682, GetCards)) ;獲得新卡片
	{
		sleep 1500
		Capture() ;拍照
		C_Click(604, 349) ;離開介面
		sleep 500
		if (Find(x, y, 720, 500, 850, 620, Academy_BTN_Confirm))
		{
			LogShow("獲得新卡片，自動上鎖！")
			C_Click(x, y) ;上鎖
		}
	}
}

Message_Center()
{
	Tips := "|<>*181$64.kSC00z0y7AD3kMS1y2000Q001sDs8000l3y7UzkzkzyADsS3zjb7bskzVsDxy007b3y7UzXs00BwDsS3y7Vz1zknVsC067w7z227UzVs80Q000S3y7U01zUz1sDsS7w7y3y7UzVsTkTsDsS3y7Uz1zUzVsDsS007y0y7UzVsTkTsEsS3y7Vz1zV1VsDsS3w7wC67UzVs00Tks8S3y7Vz1z7UVsDl6DwTsS200w63zzzXwMC3Uw000ATzVsC3s001nzy7VwTk00C"
	Center_Confirm := "|<>*182$70.sDW00Tzk0003Uw8T3zw7zzwC7VUwTzUTzzksS48rzy1zzw7VwlVzzsDzzUyDz64zzUzzw3kvsMUzz4000D37U03zzzw7zw0AC7zzzzkTzkkksTzzzz1zy323VDzzkQ7rsA0A0Tzz0kSDUkk01zzw71kC333VzzzkQ00kAAC7zzz3kTzEkksHzzwD1zz333V7zzUw7zwAAA0Tzy1kTzkkkkTzzs31zz333Vzzz307zw0AC7zzwS000kkksMzzls0033D311zyDk00ATw007zlzk00zzkzzzzTzs02"
	if (Find(x, y, 571, 537, 671, 597, Tips))
	{
		LogShow("每日提示，今日不再顯示！")
		C_Click(790, 497)
		C_Click(641, 559)
	}
	else if (Find(x, y, 580, 500, 695, 600, Center_Confirm)) ;中央訊息 按鈕在下方
	{
		LogShow("中央訊息，點擊確認！")
		C_Click(635, 542)
	}
}

Message_Normal()
{
	Message_Inform := "|<>*178$64.y6wC3zk000zwlksDz1zw7k033Vzw7zkTzzwC7zkTz1zzzksTz0007zyD3Vzw7zkTzkQC7zkTz1z03ksTz1zw7zzz01zw000Tzxw07zkTz1zzW00Tz1zw7w073Vzw7zkTzzwC7zkTz1zzzksTz0007wyD3Uzw7zkTk0QC3zkSTDz31ksDzs8TTwA73krzUUyDkkQD3Ta73sD31kw5yMQCkQA73k7VVlt1kkQD0Q63z6331ky1kM008A073s73U00VkkwDkQS003y"
	Message_Cancel := "|<>*205$71.zzXzzzzUzw7Tzz1zzzzUnsAA003zzzzUlkMC7Vzwzzz1VUkQD3zkzzy611XsS7z0zzzP22DkwAy0zzzq44zVsTy3zsTCM+z00vsDzsCXkMy7VrkTzkN000QD3jUzzkG3z0sS7D1zzV47z3kwCS7zzqMDy7VsSsDzzskTwD00wkTzzlU00S7VtVzzzb000wD3k3zzyC3zVsS7k7zzsQ7z3kwDUTzzlsDy7Vs30zzz3kTsD00T3zzs7U00M01y3zzwD1zkk03s3zzsS3zVU67U3zzkQ7z31wD41zzUsDy7"
	Message_Reconnect := "|<>*173$71.zzzzzzzzzzzzyTzzzzzzzzzzw00DUA0DU60Tm00T0M0T0A0zbzwywrwySNtyTztxtjtwwnnwk0HvnTnttbblU0bk6w7k30D3zzDUBzzU30Q7zyTSPzzzb7tC0Qywk0zyT7qQ0txtU1k000wttnvnHnk003tnnbk6rbyTlznbbD0BaTlzkzbDCSSPAy0Q0DC0Qwwr3s0M0SQ0tttj7wwnnwtznnnSDttbbtrzbbasTnnDDnzzCTBaDU60TbzUQkMSD0A0zDzVzVryySNtzzzzzzzzzzzzzzzzzzzzzzzz"
	Message_FixKit := "|<>*160$48.zzzzznzz0107zXzz0207z00zAT77y00z03b7wTlzDnWDsTVzDXkTk00703sTU007ATkTzzzbATU7zzz70073y007zXTny007z3rzzzzbw63zw007k0Bzw007s0szzwTzw3sDzyTzU007taDnU0Tbt77lwwtzl7bNswsTn7y8Vwy7XU0Q7UzbrU0TzVzzzw1zU"
	Message_FixKit2 := "|<>*152$71.zzzzzzs01zzzzzzzzzU07zzzzzzzzy00TzzzzzzUTs01zzzzzzz0Tk07zxzzzzy0zU0Dzlzzzzw1y00Tz3zzzzs3w00zw7zzzs00801zkDzzzk00E01z0TzzzU00U01w0zzzz001000E1zzzy00200003zzzw00000007zzzzk7U0000DzzzzUC00000zzzzz0M00001zzzzy0000007zzzzw000000Tzzzs0000000zzzz00000003zzzw0000000TzzzU0000001zzzy00000Q03zzzs00001y07zz"

	
	if (Find(x, y, 446, 333, 546, 393, Message_Reconnect) and Find(x, y, 320, 150, 460, 350, Message_Inform) and Find(x, y, 441, 450, 541, 650, Message_Cancel))
	{
		LogShow("遊戲斷線，嘗試重連") ;有取消跟確認的
		C_Click(785, 544)
	}
	else if (Find(x, y, 320, 150, 460, 350, Message_Inform) and Find(x, y, 441, 450, 541, 650, Message_Cancel))
	{
		LogShow("出現訊息，點擊取消！") ;有取消跟確認的
		Random, x, 423, 537
		Random, y, 554, 573
		C_Click(x, y)
	}
	else if (Find(x, y, 467, 279, 567, 339, Message_FixKit))
	{
		LogShow("出現維修工具，點擊取消！") ;有取消跟確認的
		Random, x, 466, 578
		Random, y, 471, 493
		C_Click(x, y)
	}
	else if (Find(x, y, 372, 319, 472, 379, Message_FixKit2))
	{
		LogShow("出現維修工具，點擊取消2！") ;有取消跟確認的
		Random, x, 458, 576
		Random, y, 466, 493
		C_Click(x, y)
	}
}

Four_Chicken() {
	Chicken_Face := "|<>*185$16.k0PU1y07s0DU0k000401w0Ds0zU1w01UU"
	if (Find(x, y, 516, 339, 616, 399, Chicken_Face)) {
		LogShow("網路不穩定，發現四隻小雞！")
		Loop
		{
			if (Find(x, y, 516, 339, 616, 399, Chicken_Face)) {
				Chicken++
			}
			if (Chicken=60) {
				LogShow("重新連線逾時，重新啟動模擬器。")
				LogShow("但是其實還沒做，卡住了")
			}
			if (A_index>120)
			{
				break
			}
			sleep 1000
		}
	}
}

UnknowWife()
{
	if (Find(x, y, 390, 343, 490, 403, UnknowWife)) ;未知腳色(確認)
	{
		LogShow("未知腳色(確認)！")
		C_Click(811, 546)
	}
}

Battle_End()
{
	if (Find(x, y, 866, 655, 966, 715, Battle_End)) ;確定
	{
		LogShow("結算畫面，點擊確定！")
		Random, x, 1015, 1160
		Random, y, 679, 712
		C_Click(x, y)
		sleep 6000
	}
}

Message_Story()
{
	 if (Find(x, y, 1161, 46, 1261, 106, SkipBtn))
	{
		LogShow("劇情對話，自動略過")
		C_Click(1200, 74)
		sleep 1500
		C_Click(790, 550)
	}
}

BackAttack()
{
	if (Find(x, y, 765, 471, 865, 531, Battle_BackAttack)) ;遇襲
	{
		if Assault=迎擊
		{
			LogShow("遇襲：迎擊！")
			C_Click(843, 508)
		}
		else if Assault=規避
		{
			LogShow("遇襲：規避！")
			C_Click(1068, 502)
		}
		else
		{
			LogShow("伏擊錯誤")
		}
	}
}

shipsfull()
{
	global StopAnchor
	if (Find(x, y, 400, 300, 600, 500, SF_Ship_is_Full))
	{
		if shipsfull=停止出擊
		{
			LogShow("船䲧已滿：停止出擊。")
			Traytip, Azur Lane, 船䲧已滿：停止出擊。
			C_Click(896,231)
			sleep 500
			C_Click(1227,71)
			Loop
			{
				if (Find(x, y, 0, 587, 86, 647, Formation_Tank)) ;進入戰鬥的編隊頁面 
				{
					C_Click(1227,71)
					sleep 1000
				}
				if (Find(x, y, 400, 300, 600, 500, SF_Ship_is_Full))
				{
					C_Click(896,231)
					sleep 1000
				}
				if (Find(x, y, 996, 362, 1096, 422, MainPage_Btn_WeighAnchor)) ;回到首頁
				{
					StopAnchor := 1 ;不再出擊
					return StopAnchor
					Break
				}
				else
				{
					BreakShipsfailed++
					if (BreakShipsfailed>=50)
					{
						StopAnchor := 1 ;不再出擊
						return StopAnchor
						Break
					}
				}
				sleep 300
			}
			BreakShipsfailed := VarSetCapacity
		}
		else if shipsfull=關閉遊戲
		{
			LogShow("船䲧已滿：關閉模擬器。")
			sleep 500
			run, %Consolefile% quit --index %emulatoradb%, %ldplayer%, Hide
			sleep 500
			Settimer, EmulatorCrushCheckSub, off
		}
		else if shipsfull=整理船䲧
		{
			LogShow("船䲧已滿：開始整理。")
			C_Click(437, 546)
			Loop ;等待進入船䲧畫面
			{
				sleep 400
				shipcount++
				if (shipcount>100)
				{
					LogShow("等待進入船䲧的過程中發生錯誤")
					StopAnchor := 1 ;不再出擊
					return StopAnchor
				}
			} until Find(x, y, 96, 32, 196, 92, SF_In_Dock)
			shipcount := VarSetCapacity
			sleep 500
			Gosub, Anchorsettings
			sleep 500
			Loop
			{
				if (Find(x, y, 96, 32, 196, 92, SF_In_Dock))
				{
					C_Click(1136, 64) ;開啟篩選
					Loop
					{
						sleep 400
						shipcount++
						if (shipcount>200)
						{
							LogShow("等待進入篩選清單的過程中發生錯誤")
							StopAnchor := 1 ;不再出擊
							return StopAnchor
						}
					} until Find(x, y, 32, 97, 132, 157, Dock_Sort)
					sleep 1000
					shipcount := VarSetCapacity
					C_Click(502, 129) ;排序 等級
					C_Click(363, 266) ;索引 全部
					C_Click(363, 397)  ;陣營全 陣營
					C_Click(363, 530)  ;稀有度 全部
					if (Index1)
						C_Click(517, 264)
					if (Index2)
						C_Click(666, 265)
					if (Index3)
						C_Click(833, 265)
					if (Index4)
						C_Click(991, 265)
					if (Index5)
						C_Click(1134, 265)
					if (Index6)
						C_Click(348, 324)
					if (Index7)
						C_Click(517, 324)
					if (Index8)
						C_Click(666, 324)
					if (Index9)
						C_Click(833, 324)
					if (Camp1)
						C_Click(513, 397)
					if (Camp2)
						C_Click(666, 397)
					if (Camp3)
						C_Click(833, 397)
					if (Camp4)
						C_Click(991, 397)
					if (Camp5)
						C_Click(1134, 397)
					if (Camp6)
						C_Click(356, 457)
					if (Camp7)
						C_Click(666, 457)
					if (Rarity1)
						C_Click(513, 529)
					if (Rarity2)
						C_Click(666, 529)
					if (Rarity3)
						C_Click(833, 529)
					if (Rarity4)
						C_Click(991, 529)
					if (Find(x, y, 32, 97, 132, 157, Dock_Sort)) ;
					{
						if ((Rarity1) and GdipImageSearch(x, y, "img/Dock_Rarity_02_N.png", 40, 8, 445, 514, 576, 552)) or ((Rarity2) and GdipImageSearch(x, y, "img/Dock_Rarity_03_N.png", 40, 8, 605, 514, 732, 553)) or ((Rarity3) and GdipImageSearch(x, y, "img/Dock_Rarity_04_N.png", 40, 8, 763, 514, 891, 553))
						{
							LogShow("篩選腳色過程中出現出錯，強制停止1")
							Loop
							{
								sleep 5000
							}
							return
						}
						if ((Rarity1) and !(DwmCheckcolor(473, 533, 4877733))) or ((Rarity2) and !(DwmCheckcolor(632, 530, 4876700))) or ((Rarity3) and !(DwmCheckcolor(790, 530, 4876709)))
						{
							LogShow("篩選腳色過程中出現出錯，強制停止01")
							Loop
							{
								sleep 5000
							}
							return
						}
						if ((Rarity1) and !GdipImageSearch(x, y, "img/Dock_Rarity_02_Y.png", 40, 8, 453, 513, 571, 552)) or ((Rarity2) and !GdipImageSearch(x, y, "img/Dock_Rarity_03_Y.png", 40, 8, 608, 514, 731, 552)) or ((Rarity3) and !GdipImageSearch(x, y, "img/Dock_Rarity_04_Y.png", 40, 8, 766, 513, 887, 552))
						{
							LogShow("篩選腳色過程中出現出錯，強制停止2")
							Loop
							{
								sleep 5000
							}
							return
						}
						if ((Rarity1) and DwmCheckcolor(476, 529, 7043468)) or ((Rarity2) and DwmCheckcolor(633, 529, 7042436)) or ((Rarity3) and DwmCheckcolor(789, 531, 7043468))
						{
							LogShow("篩選腳色過程中出現出錯，強制停止02")
							Loop
							{
								sleep 5000
							}
							return
						}
						if ((Rarity1) and GdipImageSearch(x, y, "img/Dock_Rarity_02_Y.png", 40, 8, 453, 513, 571, 552)) or ((Rarity2) and GdipImageSearch(x, y, "img/Dock_Rarity_03_Y.png", 40, 8, 608, 514, 731, 552)) or ((Rarity3) and GdipImageSearch(x, y, "img/Dock_Rarity_04_Y.png", 40, 8, 766, 513, 887, 552))
						{
							C_Click(796, 702) ;點擊確定
						}
						else
						{
							LogShow("篩選腳色過程中出現出錯，強制停止3")
							Loop
							{
								sleep 5000
							}
							return
						}
						sleep 1000
						if (Find(x, y, 77, 370, 177, 430, Dock_Ship_Empty)) ;如果篩選完畢發現沒有船可以退役
						{
							LogShow("篩選後已經無符合條件的船艦，強制停止")
							StopAnchor := 1
							C_Click(1243, 67) ;回到首頁
							return StopAnchor
						}
					break
					}
					else
					{
						LogShow("排序角色出錯，為避免退役錯誤強制停止。")
						Loop
						{
							sleep 5000
						}
					}
				sleep 300
				}
			}
			LogShow("排序退役腳色完畢，開始退役。")
			Loop
			{
				if (Find(x, y, 247, 84, 347, 144, Dock_Inform))
					C_Click(1014,677)  ;退役確定 
				else if (DwmCheckcolor(330, 208, 16777215) and DwmCheckcolor(523, 546, 16777215) and DwmCheckcolor(811, 555, 16777215)) ;如果有角色等級不為1(確定)
					C_Click(787,546)  
				else if (Find(x, y, 450, 130, 830, 330, Touch_to_Contunue)) ;獲得道具(一行)
					C_Click(x, y)
				else if (Find(x, y, 500, 150, 700, 400, Dock_Get_Items_2))
					C_Click(x, y)
				else if (Find(x, y, 909, 551, 1009, 611, Dock_UnEqu_Confirm)) ;拆裝(確定)
					C_Click(979, 580)
				else if (Find(x, y, 532, 151, 632, 211, Dock_Get_Items)) ;將獲得以下材料
					C_Click(805, 605)
				else if (Find(x, y, 77, 370, 177, 430, Dock_Ship_Empty)) ;暫無符合條件的艦船
				{
					sleep 300
					C_Click(64, 91)
					Logshow("退役結束")
					break
				}
				else if (Find(x, y, 96, 32, 196, 92, SF_In_Dock) and !Find(x, y, 77, 370, 177, 430, Dock_Ship_Empty)) ;第一位還沒被退役
				{
					DockCount++
					if (DockCount>30 and Find(x, y, 96, 32, 196, 92, SF_In_Dock)) ;偵測"船塢"
					{
						C_Click(64, 91) ;避免出現一些問題(例如船未上鎖)，強制結束退役
						DockCount := VarSetCapacity
						Logshow("發生一些問題，退役結束")
						break
					}
					else
					{
						C_Click(165,220) ;1
						if !DwmCheckcolor(330, 220, 2171945)
							C_Click(330,220) ;2
						if !DwmCheckcolor(495, 220, 4342090)
							C_Click(495,220) ;3
						if !DwmCheckcolor(660, 220, 5393754)
							C_Click(660,220) ;4
						if !DwmCheckcolor(825, 220, 5393754)
							C_Click(825,220) ;5
						if !DwmCheckcolor(990, 220, 3750986)
							C_Click(990,220) ;6
						if !DwmCheckcolor(1155, 220, 2698289)
							C_Click(1155,220) ;7
						if !DwmCheckcolor(165, 420, 4335665)
							C_Click(165,420) ;2-1
						if !DwmCheckcolor(330, 420, 3745841)
							C_Click(330,420) ;2-2
						if !DwmCheckcolor(495, 220, 4342090)
							C_Click(495,420) ;2-3
						C_Click(1078,702)  ;確定
					}
				}
				Try
				{
					IsDockCount++
					if (IsDockCount>300 and Find(x, y, 96, 32, 196, 92, SF_In_Dock)) ;偵測"船塢"
					{
						C_Click(64, 91) ;避免出現一些問題(例如船未上鎖)，強制結束退役
						IsDockCount := VarSetCapacity
						Logshow("發生一些問題，退役結束2")
						break
					}
				}
				sleep 500
			}
			DockCount := VarSetCapacity
			IsDockCount  := VarSetCapacity
		}
	}
}

ToMap()
{
	if (Find(x, y, 868, 517, 968, 577, ToMap_Start))
	{
		if (WeekMode) ;周回模式開關
		{
			if (Find(x, y, 996, 602, 1096, 662, Mode_off)) ;
			{
				LogShow("開啟周回模式")
				C_Click(1022, 631)
			}
		}
		else if !(WeekMode)
		{
			if (Find(x, y, 958, 602, 1058, 662, Mode_on))
			{
				LogShow("關閉周回模式")
				C_Click(1012, 631)
			}
		}
		LogShow("立刻前往攻略地圖")
		Random, x, 866, 1034
		Random, y, 533, 571
		C_Click(x, y)
	}
}

ChooseParty(Byref StopAnchor)
{
	Global
	if (Find(x, y, 112, 97, 212, 157, Fleet_Select))
	{
		LogShow("選擇出擊艦隊中。")
		if (AnchorMode="普通") and !(AnchorChapter="S.P.")
		{
			C_Click(1142, 370) ;先清掉第二艦隊
			sleep 300
			C_Click(1060, 230) ;開啟第一艦隊的選擇選單
			sleep 500
			if (Find(x, y, 1012, 329, 1112, 389, Fleet_Select_Party2)) ;如果選單沒有正確開啟
				return
			if ChooseParty1=第一艦隊
				C_Click(1093, 296) 
			else if ChooseParty1=第二艦隊
				C_Click(1093, 340) 
			else if ChooseParty1=第三艦隊
				C_Click(1093, 382) 
			else if ChooseParty1=第四艦隊
				C_Click(1098, 424) 
			else if ChooseParty1=第五艦隊
				C_Click(1098, 466) 
			else if ChooseParty1=第六艦隊
				C_Click(1098, 506) 
			if ChooseParty2!=不使用
			{
				sleep 500
				C_Click(1053, 368)	;開啟第二艦隊的選擇選單
				sleep 500
				if (Find(x, y, 1047, 601, 1147, 661, Fleet_Start)) ;如果選單沒有正確開啟
				{
					C_Click(1161, 126)
					return
				}
			}
			if ChooseParty2=第一艦隊
				C_Click(1103, 431)
			else if ChooseParty2=第二艦隊
				C_Click(1103, 472)
			else if ChooseParty2=第三艦隊
				C_Click(1103, 514)
			else if ChooseParty2=第四艦隊
				C_Click(1103, 556)
			else if ChooseParty2=第五艦隊
				C_Click(1103, 600)
			else if ChooseParty2=第六艦隊
				C_Click(1103, 641)
			sleep 300
		}
		Random, x, 1000, 1150
		Random, y, 620, 655
		C_Click(x, y)	;立刻前往
		sleep 500
		BTN_Confirm := dwmgetpixel(743, 555) ;4355509
		BTN_Cancel := dwmgetpixel(444, 554) ;9211540
		if (DwmCheckcolor(330, 209, 16777215) and Isbetween(BTN_Cancel, 8211540, 11211540) and Isbetween(BTN_Confirm, 3755509, 4905509)) ;心情低落
		{
			LogShow("老婆心情低落中。")
			C_Click(743, 541)
		}
		else if (DwmCheckcolor(530, 360, 15724535) or DwmCheckcolor(530, 360, 16249847)) ; 資源不夠
		{
			LogShow("石油不足，停止出擊到永久。")
			StopAnchor := 1
			sleep 1000
			C_Click(1230, 68) ;返回主選單
			sleep 2000
			return StopAnchor
		}
		else if Find(x, y, 377, 328, 477, 388, Fleet_Done) and AnchorMode="困難"
		{
			LogShow("困難模式次數已用盡，停止出擊到永久。")
			StopAnchor := 1
			sleep 1000
			C_Click(1230, 68) ;返回主選單
			sleep 2000
			return StopAnchor
		}
		Loop, 20
		{
			sleep 500
			if (Find(x, y, 750, 682, 850, 742, Battle_Map)) ;如果進入地圖頁面 
			{
				if (SwitchPartyAtFirstTime and (ChooseParty2!="不使用" or AnchorMode="困難"))
				{
					Loop, 20 ;等待進入地圖的掃描結束
					{
						MapScan1 := DwmGetPixel(364, 351)
						sleep 500
						MapScan2 := DwmGetPixel(364, 351)
						if (MapScan1=MapScan2)
							break
					}
					sleep 3000
					Random, x, 970, 1050
					Random, y, 710, 720
					C_Click(x,y) ;點擊"切換"
					sleep 1000
				}
				if (AnchorChapter="7" and AnchorChapter2="2") ;如果是7-2 往右邊拖曳 以偵測左邊問號
				{
					sleep 1000
					Swipe(500, 400, 780, 600)
				}
				else if ((AnchorChapter="S.P.") and AnchorChapter2="3") ;如果是SP3 先往左上拉 避免開場的多次偵測
				{
					Swipe(272, 419, 1100, 422)
				}
				break
			}
		} 
	}
}

Battle_Operation()
{
	if (Find(x, y, 1188, 51, 1288, 111, BTN_Pause))
	{
		LogShow("報告提督SAMA，艦娘航行中！")
		Loop
		{
			sleep 400
			if !(Find(x, y, 1188, 51, 1288, 111, BTN_Pause))
			{
				sleep 1000
				if !(Find(x, y, 1188, 51, 1288, 111, BTN_Pause))
				{
					Break
				}
			}
			if (Leave_Operatio and IsChanged<6) ;快輸了自動離開
			{
				; 我方血量起點 X: 584 Y: 87  Color : 15672353 終點 X: 274 
				; 敵方血量起點 X: 694 Y: 87 Color : 15672353 終點 X: 1001
				MyTargetHP_X := Ceil((274-584)*(OperatioMyHpBar/100)+584)
				EnTargetHP_X := Ceil((1001-694)*(OperatioEnHpBar/100)+694)
				MyTargetHP := DwmGetpixel(MyTargetHP_X, 87) ;15672336
				EnTargetHP := DwmGetpixel(EnTargetHP_X, 87) ;15672336
				if (DwmCheckcolor(584, 87, 15672353) and MyTargetHP<15630000 and DwmCheckcolor(694, 87, 15672353) and (EnTargetHP>15650000 and EnTargetHP<15690000))
				{
					sleep 1000
					MyTargetHP := DwmGetpixel(MyTargetHP_X, 87) ;15672336
					EnTargetHP := DwmGetpixel(EnTargetHP_X, 87) ;15672336
					if (DwmCheckcolor(584, 87, 15672353) and MyTargetHP<15630000 and DwmCheckcolor(694, 87, 15672353) and (EnTargetHP>15630000 and EnTargetHP<15690000))   ;再檢查一次
					{
						LogShow("我方血量過低，自動離開戰鬥")
						Loop, 100
						{
							if (Find(x, y, 1188, 51, 1288, 111, BTN_Pause)) ;點擊暫停按紐
							{
								Random, x, 1152, 1256
								Random, y, 69, 88
								C_Click(x, y)
								sleep 1000
							}
							else if (Find(x, y, 439, 500, 539, 600, Battle_Exit_Battle)) ;退出戰鬥
							{
								Random, x, 443, 567
								Random, y, 540, 569
								C_Click(x, y)
								sleep 1000
							}
							else if (Find(x, y, 767, 500, 850, 600, Battle_Exit_Battle)) ;確認退出
							{
								Random, x, 726, 862
								Random, y, 544, 570
								C_Click(x, y)
								sleep 2000
							}
							else if (Find(x, y, 1124, 677, 1224, 737, Battle_Defensive)) ;迎擊
							{
								Random, x, 1163, 1244
								Random, y, 700, 725
								C_Click(x, y)
								sleep 1000
							}
							else if (Find(x, y, 100, 34, 200, 94, Daily_Formation)) ;回到編隊出擊頁面
							{
								C_Click(59, 90) ;返回上一頁
							}
							else if (Find(x, y, 99, 35, 199, 95, Operation_Upp)) ;回到演習頁面
							{
								C_Click(1142, 395) ;更換對手
								IsChanged++
								Break
							}
							else if (DwmCheckcolor(1221, 73, 16777215)) ;太慢退出
							{
								C_Click(620, 391)
								break
							}
							sleep 333
						}
					}
				}
			}
			battletime++
			if (battletime>900) ;如過戰鬥超過15分鐘
			{
				LogShow("戰鬥超時，自動離開")
				Loop, 999
				{
					sleep 500
					if (Find(x, y, 1188, 51, 1288, 111, BTN_Pause)) ;點擊暫停按紐
					{
						Random, x, 1152, 1256
						Random, y, 69, 88
						C_Click(x, y)
						sleep 1000
					}
					else if (Find(x, y, 439, 500, 539, 600, Battle_Exit_Battle)) ;退出戰鬥
					{
						Random, x, 443, 567
						Random, y, 540, 569
						C_Click(x, y)
						sleep 1000
					}
					else if (Find(x, y, 767, 500, 850, 600, Battle_Exit_Battle)) ;確認退出
					{
						Random, x, 726, 862
						Random, y, 544, 570
						C_Click(x, y)
						sleep 2000
					}
					else if (Find(x, y, 100, 34, 200, 94, Daily_Formation)) ;回到編隊出擊頁面
					{
						C_Click(59, 90) ;返回上一頁
					}
					else if (Find(x, y, 99, 35, 199, 95, Operation_Upp)) ;回到演習頁面
					{
						Break
					}
				}
			}
		} 
		battletime := VarSetCapacity
	}
}

Battle()
{
	global NowHP
	if (Find(x, y, 1188, 51, 1288, 111, BTN_Pause))
	{
		LogShow("報告提督SAMA，艦娘航行中！")
		Loop
		{
			sleep 1000
			if !(Find(x, y, 1188, 51, 1288, 111, BTN_Pause))
			{
				sleep 1000
				if !(Find(x, y, 1188, 51, 1288, 111, BTN_Pause))
				{
					Break
				}
			}
			else if Autobattle=半自動
			{
				if (DwmCheckcolor(455, 82, 15671329)) or (DwmCheckcolor(372, 61, 16777215))
				{
					if (MoveDown<1)
					{
						Swipe(150,630, 150, 700, 650) ;下
						sleep 200
						Swipe(116,587, 20, 587, 1000) ;往後
						swipeside := 3
					}
					MoveDown := 1
					if (DwmCheckcolor(897, 656, 16777215) and DwmCheckcolor(1225, 83, 16249847)) ;飛機準備就緒
					{
						C_Click(897, 656)
					}
					else if (DwmCheckcolor(1043, 651, 16777215) and DwmCheckcolor(1225, 83, 16249847) and swipeside=4) ;魚雷準備就緒
					{
						C_Click(1043, 651)
					}
					else if (DwmCheckcolor(1198, 654, 16777215) and DwmCheckcolor(1225, 83, 16249847) and swipeside=4) ;大砲準備就緒
					{
						C_Click(1182, 649)
					}
				}
				HalfAuto++
				if HalfAuto>3
				{
					;~ if swipeside=1
					;~ {
						;~ Swipe(149,545, 149, 400, 2500) ;上
						;~ Swipe := 2
					;~ }
					;~ else if swipeside=2
					;~ {
						;~ Swipe(150,630, 150, 700, 2500) ;下
						;~ Swipe := 3
					;~ }
					if swipeside=3
					{
						Swipe(198,591, 298, 591, 1800) ;往前
						swipeside := 4
					}
					else if swipeside=4
					{
						Swipe(116,587, 20, 587, 1600) ;往後
						swipeside := 3
					}
					HalfAuto := 0
				}
				sleep 300
			}
			battletime++
			if (battletime>600) ;如過戰鬥超過10分鐘
			{
				LogShow("戰鬥超時，自動離開")
				Loop, 999
				{
					sleep 500
					if (DwmCheckcolor(1241, 82, 16249847))
					{
						C_Click(1210, 82) ;點擊暫停
						sleep 1000
					}
					if (DwmCheckcolor(457, 549, 16777215) and DwmCheckcolor(457, 549, 16777215))
					{
						C_Click(504, 553) ;退出戰鬥
						sleep 1000
					}
					if (DwmCheckcolor(330, 209, 16777215) and DwmCheckcolor(821, 535, 16777215))
					{
						C_Click(790, 544) ;拋棄獲得的資源 道具 腳色
						sleep 10000
						break
					}
				}
			}
			if (Retreat_LowHp) ;旗艦HP過低撤退
			{
				Hp_Variation := 30
				if (OriginalHP<1) ;先檢查原本HP剩多少
				{
					DetectHP_Pos := [10, 410, 105, 490]
					if (GdipImageSearch(x, y, "img/battle/LowHP.png", Hp_Variation, 8, DetectHP_Pos[1], DetectHP_Pos[2], DetectHP_Pos[3], DetectHP_Pos[4]))
					{
						OriginalHP := Ceil((x-10)/85*100)
						OriginalHP2 := OriginalHP-Retreat_LowHpBar
						Message = 旗艦HP: %OriginalHP%`%，當HP＜: %OriginalHP2%`%，%Retreat_LowHpDo%。
						LogShow(Message)
					}
					else if (DebugMode)
					{
						LogShow("HP檢測中。")
						sleep 500
					}
					else
					{
						sleep 500
					}
				}
				else if (OriginalHP>=1)
				{
					IsPositive_Integer := if (OriginalHP-Retreat_LowHpBar)>1 ? 1 : 0
					if (IsPositive_Integer)
					{
						DetectHP_Pos := [10, 410, 105, 490]
						if (GdipImageSearch(x, y, "img/battle/LowHP.png", Hp_Variation, 8, DetectHP_Pos[1], DetectHP_Pos[2], DetectHP_Pos[3], DetectHP_Pos[4]))
						{
							NowHP := Ceil((x-10)/85*100)
							if (debugMode)
							{
								HpdebugMode++
								if (HpdebugMode=5)
								{
									SufferHP := OriginalHP-NowHP
									if (SufferHP>=0)
										Message = 目前HP: %NowHP%`%，消耗HP: %SufferHP%`%。
									else if (SufferHP<0)
									{
										SufferHP := Abs(SufferHP)
										Message = 目前HP: %NowHP%`%，維修HP: %SufferHP%`%。
									}	
									LogShow(Message)
									HpdebugMode := VarSetCapacity
								}
							}
						}
						if (Stop_LowHp and NotRetreat<1) ;如果檢測到打王則不撤退
						{
							if (Find(x, y, 292, 31, 392, 91, Battle_BossIco)) 
							{
								NotRetreat := 1
								if (debugmode)
									LogShow("BOSS出現，停止撤退！")
							}
						}
						if (Stop_LowHP_SP and switchparty>=1 and NotRetreat<1)
						{
							NotRetreat := 1
							if (debugmode)
								LogShow("已交換隊伍，停止撤退！")
						}
						if ((OriginalHP-NowHP)>=Retreat_LowHpBar and NotRetreat<1) ;HP過低撤退
						{
							SufferHP := OriginalHP-NowHP
							Message = 目前HP: %NowHP%`%，消耗HP: %SufferHP%`%。
							LogShow(Message)
							Message = 旗艦消耗高於%Retreat_LowHpBar%`%，%Retreat_LowHpDo%
							LogShow(Message)
							Loop, 300
							{
								if (Find(x, y, 1188, 51, 1288, 111, BTN_Pause)) ;點擊暫停按紐
								{
									Random, x, 1152, 1256
									Random, y, 69, 88
									C_Click(x, y)
									sleep 1000
								}
								else if (Find(x, y, 439, 500, 539, 600, Battle_Exit_Battle)) ;退出戰鬥
								{
									Random, x, 443, 567
									Random, y, 540, 569
									C_Click(x, y)
									sleep 1000
								}
								else if (Find(x, y, 767, 500, 850, 600, Battle_Exit_Battle)) ;確認退出
								{
									Random, x, 726, 862
									Random, y, 544, 570
									C_Click(x, y)
									sleep 2000
								}
								else if (Find(x, y, 1124, 677, 1224, 737, Battle_Defensive)) ;迎擊
								{
									Random, x, 1163, 1244
									Random, y, 700, 725
									C_Click(x, y)
									sleep 1000
								}
								else if (Find(x, y, 1029, 628, 1129, 688, Battle_Weigh)) ;再次出擊
								{
									Random, x, 1060, 1221
									Random, y, 658, 692
									C_Click(x, y)
									sleep 1000
									if (Find(x, y, 700, 500, 880, 600, Academy_BTN_Confirm)) ;心情低落
									{
										if mood=強制出戰
										{
											LogShow("老婆心情低落：提督SAMA沒人性")
											C_Click(x, y)
										}
									}
									break
								}
								sleep 350
							}
						}
					sleep 500
					}
					else
					{
						if (GdipImageSearch(x, y, "img/battle/LowHP.png", Hp_Variation, 8, DetectHP_Pos[1], DetectHP_Pos[2], DetectHP_Pos[3], DetectHP_Pos[4]))
						{
							NowHP := Ceil((x-10)/85*100)
						}
						if (ShowLog<1)
						{
							Message = 目前HP(%OriginalHP%`%)扣除: %Retreat_LowHpBar%`%後小於1，不撤退。
							LogShow(Message)
							ShowLog := 1
						}
					}
				}
			}
			if (!(Retreat_LowHp) and Retreat_LowHp2) ;旗艦HP過低撤退
			{
				DetectHP_Pos := [10, 410, 105, 490]
				Hp_Variation := 30
				if (GdipImageSearch(x, y, "img/battle/LowHP.png", Hp_Variation, 8, DetectHP_Pos[1], DetectHP_Pos[2], DetectHP_Pos[3], DetectHP_Pos[4]))
				{
					NowHP := Ceil((x-10)/85*100)
					if (debugMode)
					{
						HpdebugMode++
						if (HpdebugMode=5)
						{
							Message = 旗艦血量： %NowHP%`%
							LogShow(Message)
							HpdebugMode := VarSetCapacity
						}
					}
				}
				sleep 100
			}
		} 
		battletime := VarSetCapacity
	}
}

GuLuGuLuLu()
{
	if (DwmCheckcolor(355, 206, 16776183) and DwmCheckcolor(355, 206, 16776183) and DwmCheckcolor(468, 561, 16764787) and DwmCheckcolor(794, 564, 16755282))
	{
			LogShow("提督SAMA人家不給吃飯飯！")
			Random, x, 446, 588
			Random, y, 541, 576
			C_Click(x, y)
	}
}

CloseEventList()
{
	EventList := "|<>*161$71.67zkz1zw0606ADzXU01s0805sTy7003kVU0TU1wS007U067l03k084D3V01W07W0E0S7203y4C0E20w0AUaA8Q0U8Vslt9AMEs3013k0E0MkVw6607U0U1lV3s480Dk007X27V83UTU00764D6000z3zsCA8Q0003y000QMEs000Dw000tkVk1zzzsTz1zV3zyFWDk003W6704X6TVzwD4AC116Az000TMsQG2Dsy001zVktY4QFzUkS861n8M0Xw3UwEA7aEk160D00xsDzzk7w1z03zzzzzzzzzzzz"
	if (Find(x, y, 148, 33, 248, 93, EventList))
	{
		LogShow("關閉活動總覽")
		C_Click(1240,66)
	}
}

SystemNotify()
{
	Announce := "|<>*160$60.zUTDzzVsD1z0zbzzUs00z1zXzz0000y1zVzz3sDzy3zkzz7sDzw7zkDyDsDzwDDk7yTsDwsD3s1zzsDskS1w0xzs7kky0w1s0000Xy1y3zzzzz7w3z7zzzzzDw7zzzbzz7zs7zzzVzy3zsDzzzU001zkTXzzUzy1zkzVzzUzy3zVzkTzUzy3z3zkDzUzy3y7zkDzUzy3s0007zUzy3s00A7zUzy3s01w3zUTy3s0Dw3zU003w3zy7zUzy3U"
	Announce_Check := "|<>*144$29.zzzz7zzzw7zzzk7zzz0Dzzw0Tzzk1zzz07zzw0Tnzk1y3z07s3w0TU3k1z0307z000Tz001zy007zz00Tzz01zzz07zzz0Tzzz1zzzz7zzzzTzzk"
	if (Find(x, y, 117, 75, 217, 135, Announce))
	{
		LogShow("出現系統公告，不再顯示")
		if !(Find(x, y, 946, 78, 1046, 138, Announce_Check))
		{
			C_Click(994, 110)
		}
		C_Click(1193, 103)
	}
}

ClickFailed()
{
	if (DwmCheckcolor(331, 210, 16777215) and DwmCheckcolor(919, 282, 16241474) and DwmCheckcolor(415, 224, 16777215)) ;誤點"制空值"訊息
	{
		C_Click(893, 229)
		Swipe(153, 227,153,453)
	}
	else if (DwmCheckcolor(220, 127, 16777215) and DwmCheckcolor(452, 570, 16771988) and DwmCheckcolor(838, 561, 16746116)) ;誤點敵軍詳情
	{
		C_Click(1136, 298)
		Swipe(153, 453,153,227)
	}
}

Swipe(x1,y1,x2,y2,swipetime=200) {	
	If (SendFromAHK)
	{
		WinGetpos,xx,yy,w1,h1, ahk_id %UniqueID%
		MouseGetPos,x,y, thewindow ;偵測滑鼠位置
		HideGuiID = Gui%UniqueID%
		if (thewindow=UniqueID) { ;如果滑鼠位於視窗內，則創造一個隱形GUI
			Gui, HideGui:Show, w%w1% h%h1% x%xx% y%yy%, %HideGuiID% ;創造一個隱形的GUI去檔住滑鼠
			Gui, HideGui: -caption +AlwaysOnTop
			WinSet, Transparent, 1, %HideGuiID%
		}
		ShiftX := Ceil((x2 - x1)/5) , ShiftY := Ceil((y2 - y1)/5), sleeptime := Ceil(swipetime/5) ;計算拖曳座標距離 時間
		Loop, 5
		{
			ControlClick, x%x1% y%y1%, ahk_id %UniqueID%,,,, D NA ;拖曳畫面(X1->X2, Y1->Y2)
			x1 += ShiftX, y1 += ShiftY
			sleep %sleeptime%
		}
		ControlClick, x%x1% y%y1%, ahk_id %UniqueID%,,,, U NA 
		Gui, HideGui:Hide ;隱藏上方創造的隱形GUI
		
	} else if (SendFromADB){
		y1 := y1-36, y2 := y2-36
		runwait,  ld.exe -s %emulatoradb% input swipe %x1% %y1% %x2% %y2% %swipetime%,%ldplayer%, Hide ;雷電4.0似乎有BUG 偶爾會卡住
	}
	sleep 450
}

Ld_Click(PosX,PosY) {
	Random, randomsleep, 400, 550
	random , x, PosX - 3, PosX + 3 ;隨機偏移 避免偵測
	random , y, PosY - 2, PosY + 2
	sleep %randomsleep%
	Runwait, ld.exe -s %emulatoradb% input tap %x% %y%, %ldplayer%, Hide
	sleep 500
}

C_Click(PosX, PosY) {
	sleep 100
	random , x, PosX - 3, PosX + 3 ;隨機偏移 避免偵測
	random , y, PosY - 2, PosY + 2
	if (SendfromAHK){
		ControlClick, x%x% y%y%, ahk_id %UniqueID%,,,, NA 
		sleep 800
	} else if (SendfromADB){
		y := y - 36
		Runwait, ld.exe -s %emulatoradb% input tap %x% %y%, %ldplayer%, Hide
		sleep 600
	}
}

GdiGetPixel( x, y) {
    pBitmap:= Gdip_BitmapFromHWND(UniqueID)
    Argb := Gdip_GetPixel(pBitmap, x, y)
    Gdip_DisposeImage(pBitmap)
    return ARGB
}

Capture(){
	FileCreateDir, capture
	formattime, nowtime,,yyyy.MM.dd_HH.mm.ss
	pBitmap := Gdip_BitmapFromHWND(UniqueID)
	pBitmap_part := Gdip_CloneBitmapArea(pBitmap, 0, 36, 1280, 722)
	Gdip_SaveBitmapToFile(pBitmap_part, "capture/" . title . "AzurLane_" . nowtime . ".jpg", 100)
	Gdip_DisposeImage(pBitmap)
	Gdip_DisposeImage(pBitmap_part)
}

Capture2(x1, y1, x2, y2) {
	FileCreateDir, capture
	x2 := x2-x1, y2 := y2-y1
	pBitmap := Gdip_BitmapFromHWND(UniqueID)
	pBitmap_part := Gdip_CloneBitmapArea(pBitmap, x1, y1, x2, y2)
	Gdip_SaveBitmapToFile(pBitmap_part, "capture/" . "OCRTemp" . ".png")
	Gdip_DisposeImage(pBitmap)
	Gdip_DisposeImage(pBitmap_part)
}

AreaDwmCheckcolor(byref x, byref y, x1, y1, x2, y2, color="") {
	defaultX1 := x1, defaultY1 := y1, y := y1
	hDC := DllCall("user32.dll\GetDCEx", "UInt", UniqueID, "UInt", 0, "UInt", 1|2)
	Loop {
		x1 := x1 +1, x := x1
		if (x1=x2) {
			x1 := defaultX1,	y1 := y1 +1, y := y1
		}
		pix := DllCall("gdi32.dll\GetPixel", "UInt", hDC, "Int", x, "Int", y, "UInt")
		pix := ConvertColor(pix)
	} until pix=color or y=y2
	DllCall("user32.dll\ReleaseDC", "UInt", UniqueID, "UInt", hDC)
	DllCall("gdi32.dll\DeleteDC", "UInt", hDC)
	if (pix=color) {
		x := x,	y := y, a := 1
		return a
	} else {
		x :="" , y :="", a := 0
		return a
	}
}

ColorVariation(Color1, Color2) {
	color := ConvertColor(Color1)
	pix := ConvertColor(Color2)
	tr := format("{:d}","0x" . substr(color,3,2)), tg := format("{:d}","0x" . substr(color,5,2)), tb := format("{:d}","0x" . substr(color,7,2))
	pr := format("{:d}","0x" . substr(pix,3,2)), pg := format("{:d}","0x" . substr(pix,5,2)), pb := format("{:d}","0x" . substr(pix,7,2))
	distance := sqrt((tr-pr)**2+(tg-pg)**2+(pb-tb)**2)
	msgbox %distance%
}

DwmCheckcolor(x, y, color="", Variation=15) {
	if (NoxPlayer5) {
		x := x+1, y := y-4
	}
	if (GdiMode) {
		pBitmap:= Gdip_BitmapFromHWND(UniqueID)
		Argb := Gdip_GetPixel(pBitmap, x, y)
		Gdip_DisposeImage(pBitmap)
		pix := ARGB & 0x00ffffff
	} else if (DwmMode) {
		if !(CloneWindowforDWM) {
			hDC := DllCall("user32.dll\GetDCEx", "UInt", UniqueID, "UInt", 0, "UInt", 1|2)
			pix := DllCall("gdi32.dll\GetPixel", "UInt", hDC, "Int", x, "Int", y, "UInt")
			DllCall("user32.dll\ReleaseDC", "UInt", UniqueID, "UInt", hDC)
		} else {
			hDC := DllCall("user32.dll\GetDCEx", "UInt", CloneWindow, "UInt", 0, "UInt", 1|2)
			pix := DllCall("gdi32.dll\GetPixel", "UInt", hDC, "Int", x, "Int", y, "UInt")
			DllCall("user32.dll\ReleaseDC", "UInt", CloneWindow, "UInt", hDC)
		}
		pix := ConvertColor(pix)
	} else if (AHKMode) {
		PixelGetColor, pix, x, y , Alt RGB
	}
	if (Variation>=0) {
		color := DecToHex(color)
		pix := DecToHex(pix)
		tr := format("{:d}","0x" . substr(color,3,2)), tg := format("{:d}","0x" . substr(color,5,2)), tb := format("{:d}","0x" . substr(color,7,2))
		pr := format("{:d}","0x" . substr(pix,3,2)), pg := format("{:d}","0x" . substr(pix,5,2)), pb := format("{:d}","0x" . substr(pix,7,2))
		distance := sqrt((tr-pr)**2+(tg-pg)**2+(pb-tb)**2)
		if (distance<=Variation) {
			return 1
		}
		return 0
	} else {
	if (Allowance>=abs(color-pix))
		return 1
	return 0
	}
}

GdipImageSearch(byref x, byref y, imagePath = "img/picturehere.png",  Variation=100, direction = 1, x1=0, y1=0, x2=0, y2=0) {
    if (Value_Pic!=0) {
		Variation := if (Variation>=2) ? Variation+Value_Pic : Variation
	}
	pBitmap := Gdip_BitmapFromHWND(UniqueID)
	bmpNeedle := Gdip_CreateBitmapFromFile(imagePath)
    Gdip_ImageSearch(pBitmap, bmpNeedle, LIST, x1, y1, x2, y2, Variation, , direction, 1)
    Gdip_DisposeImage(bmpNeedle)
	Gdip_DisposeImage(pBitmap)
    LISTArray := StrSplit(LIST, ",")
    x := LISTArray[1], y := LISTArray[2]
    return List
}

LogShow(logData) {
	formattime, nowtime,, MM-dd HH:mm:ss
	guicontrol, , ListBoxLog, [%nowtime%]  %logData%||
	if (DebugMode) {
		FileAppend, [%nowtime%]  %logData%`n, AzurLane.log
	}
}

LogShow2(logData) {
	guicontrol, , ListBoxLog, %logData%||
}

DwmGetPixel(x, y) {
	if (NoxPlayer5) {
		x := x+1, y := y-4
	}
	if (GdiMode) {
		pBitmap:= Gdip_BitmapFromHWND(UniqueID)
		Argb := Gdip_GetPixel(pBitmap, x, y)
		Gdip_DisposeImage(pBitmap)		
		RGB := ARGB & 0x00ffffff
		return RGB
	} else if (DwmMode) {
		if !(CloneWindowforDWM) {
			hDC := DllCall("user32.dll\GetDCEx", "UInt", UniqueID, "UInt", 0, "UInt", 1|2)
			pix := DllCall("gdi32.dll\GetPixel", "UInt", hDC, "Int", x, "Int", y, "UInt")
			DllCall("user32.dll\ReleaseDC", "UInt", UniqueID, "UInt", hDC)
		} else {
			hDC := DllCall("user32.dll\GetDCEx", "UInt", CloneWindow, "UInt", 0, "UInt", 1|2)
			pix := DllCall("gdi32.dll\GetPixel", "UInt", hDC, "Int", x, "Int", y, "UInt")
			DllCall("user32.dll\ReleaseDC", "UInt", CloneWindow, "UInt", hDC)
		}
		pix := ConvertColor(pix)
		Return pix
	} else if (AHKMode) {
		PixelGetColor, pix, x, y , Alt RGB
		Return pix
	}
}

DecToHex(dec) {
   oldfrmt := A_FormatInteger
   hex := dec
   SetFormat, IntegerFast, hex
   hex += 0
   hex .= ""
   SetFormat, IntegerFast, %oldfrmt%
   return hex
}

ConvertColor(BGRValue) {
	BlueByte := ( BGRValue & 0xFF0000 ) >> 16
	GreenByte := BGRValue & 0x00FF00
	RedByte := ( BGRValue & 0x0000FF ) << 16
	return RedByte | GreenByte | BlueByte
}

AutoLoginIn() ;預設登入Google帳號
{
	if (AutoLogin)
	{
		If (Find(x, y, 589, 435, 689, 495, Login_In)) ;斷線的登入頁面(密碼登入)
		{
			LogShow("遊戲斷線，開始重登")
			C_Click(777, 254) ;快速登入
			sleep 500
			Loop
			{
				sleep 500
				If (Find(x, y, 589, 435, 689, 495, Login_In)) ;斷線的登入頁面(密碼登入)
				{
					C_Click(777, 254) ;快速登入
					sleep 500
				}
				else if (Find(x, y, 658, 555, 758, 615, Login_Google)) ;FB or Google
				{
					C_Click(704, 586) ;GOOGLE登入
					sleep 500
				}
				else if (Find(x, y, 554, 270, 654, 330, Select_Account)) ;選擇帳戶
				{
					C_Click(442, 455) ;第一個帳戶
					sleep 1000
				}
				else if (Find(x, y, 1197, 704, 1297, 764, CRIWare)) ;位於首頁
				{
					C_Click(587, 377)
					sleep 500
				}
				else if (Find(x, y, 996, 362, 1096, 422, MainPage_Btn_WeighAnchor))
				{
					break
				}
			}
		}
		else if (Find(x, y, 1197, 704, 1297, 764, CRIWare)) ;登入伺服器選擇頁面
		{
			sleep 3000
			Random, x, 231, 1051
			Random, y, 70, 507
			C_Click( x, y) ;隨機點擊登入
			sleep 3000
		}
	}
}

CheckArray(Var*) { ;檢查數組中，其中一個是否為真
	for k, v in Var
	if v=1
		return 1
	return 0
}

CheckArray2(Var*) {
	for k, v in Var
	if v=0
		return 0
	return 1
}

MinMax(type := "max", values*) {
	y := 0, c:= 0
	for k, v in values
		if v is number 
			x .= (k = values.MaxIndex() ? v : v ";"), ++c, y += v 
	Sort, x, % "d`; N" (type = "max" ? " R" : "")
	return type = "avg" ? y/c : SubStr(x, 1, InStr(x, ";") - 1)
}

Update_HELP()
{
	Run, temp.txt
}

WM_HELP()
{
	Run, https://www.reddit.com/r/RagnarokMobile/comments/e6cccx/tech_support_ldplayer_update_added_shady/
	sleep 1000
	Run, https://www.ptt.cc/bbs/AzurLane/M.1575711622.A.AF3.html
}

Isbetween(Var, Min, Max) {
	if (Var>Min and Var<Max)
		return 1
	return 0
}

VC(Array){
	return DwmCheckColor(Array[1], Array[2], Array[3], Array[4])	
}

Find(byref x, byref y, x1, y1, x2, y2, text) {
	WinGetPos, wx, wy, ww, wh, %title%
	id := WinExist(title)
	BindWindow(id)
	xx1 := wx+x1, yy1 := wy+y1, xx2 := wx+x2, yy2 := wy+y2
	if (ok := FindText(xx1, yy1, xx2, yy2 , Err0_V, Err1_V, text))	{
		X:=ok.1.x, Y:=ok.1.y, Comment:=ok.1.id
		x := x-wx, y:=y-wy
		return 1
	}
	x := "", y := ""
	return 0
}


MsgBoxEx(Text, Title := "", Buttons := "", Icon := "", ByRef CheckText := "", Styles := "", Owner := "", Timeout := "", FontOptions := "", FontName := "", BGColor := "", Callback := "") {
    Static hWnd, y2, p, px, pw, c, cw, cy, ch, f, o, gL, hBtn, lb, DHW, ww, Off, k, v, RetVal
    Static Sound := {2: "*48", 4: "*16", 5: "*64"}

    Gui New, hWndhWnd LabelMsgBoxEx -0xA0000
    Gui % (Owner) ? "+Owner" . Owner : ""
    Gui Font
    Gui Font, % (FontOptions) ? FontOptions : "s9", % (FontName) ? FontName : "Segoe UI"
    Gui Color, % (BGColor) ? BGColor : "White"
    Gui Margin, 10, 12

    If (IsObject(Icon)) {
        Gui Add, Picture, % "x20 y24 w32 h32 Icon" . Icon[1], % (Icon[2] != "") ? Icon[2] : "shell32.dll"
    } Else If (Icon + 0) {
        Gui Add, Picture, x20 y24 Icon%Icon% w32 h32, user32.dll
        SoundPlay % Sound[Icon]
    }

    Gui Add, Link, % "x" . (Icon ? 65 : 20) . " y" . (InStr(Text, "`n") ? 24 : 32) . " vc", %Text%
    GuicontrolGet c, Pos
    GuiControl Move, c, % "w" . (cw + 30)
    y2 := (cy + ch < 52) ? 90 : cy + ch + 34

    Gui Add, Text, vf -Background ; Footer

    Gui Font
    Gui Font, s9, Segoe UI
    px := 42
    If (CheckText != "") {
        CheckText := StrReplace(CheckText, "*",, ErrorLevel)
        Gui Add, CheckBox, vCheckText x12 y%y2% h26 -Wrap -Background AltSubmit Checked%ErrorLevel%, %CheckText%
        GuicontrolGet p, Pos, CheckText
        px := px + pw + 10
    }

    o := {}
    Loop Parse, Buttons, |, *
    {
        gL := (Callback != "" && InStr(A_LoopField, "...")) ? Callback : "MsgBoxExBUTTON"
        Gui Add, Button, hWndhBtn g%gL% x%px% w90 y%y2% h26 -Wrap, %A_Loopfield%
        lb := hBtn
        o[hBtn] := px
        px += 98
    }
    GuiControl +Default, % (RegExMatch(Buttons, "([^\*\|]*)\*", Match)) ? Match1 : StrSplit(Buttons, "|")[1]

    Gui Show, Autosize Center Hide, %Title%
    DHW := A_DetectHiddenWindows
    DetectHiddenWindows On
    WinGetPos,,, ww,, ahk_id %hWnd%
    GuiControlGet p, Pos, %lb% ; Last button
    Off := ww - (((px + pw + 14) * A_ScreenDPI) // 96)
    For k, v in o {
        GuiControl Move, %k%, % "x" . (v + Off)
    }
    Guicontrol MoveDraw, f, % "x-1 y" . (y2 - 10) . " w" . ww . " h" . 48

    Gui Show
    Gui +SysMenu %Styles%
    DetectHiddenWindows %DHW%

    If (Timeout) {
        SetTimer MsgBoxExTIMEOUT, % Round(Timeout) * 1000
    }

    If (Owner) {
        WinSet Disable,, ahk_id %Owner%
    }

    GuiControl Focus, f
    Gui Font
    WinWaitClose ahk_id %hWnd%
    Return RetVal

    MsgBoxExESCAPE:
    MsgBoxExCLOSE:
    MsgBoxExTIMEOUT:
    MsgBoxExBUTTON:
        SetTimer MsgBoxExTIMEOUT, Delete

        If (A_ThisLabel == "MsgBoxExBUTTON") {
            RetVal := StrReplace(A_GuiControl, "&")
        } Else {
            RetVal := (A_ThisLabel == "MsgBoxExTIMEOUT") ? "Timeout" : "Cancel"
        }

        If (Owner) {
            WinSet Enable,, ahk_id %Owner%
        }

        Gui Submit
        Gui %hWnd%: Destroy
    Return
}

Click_Fleet(x, y)
{
	Loop, 15
	{
		if (Find(n, m, 750, 682, 850, 742, Battle_Map)) ;如果在限時(無限時)地圖
		{
			C_Click(x, y)
			sleep 1500
		}
		if (Find(n, m, 0, 587, 86, 647, Formation_Tank))
		{
			Break
		}
		BackAttack()
		sleep 500
	}
}

;~ F3::
;~ MapX1 := 10, MapY1 := 100, MapX2 := 1261, MapY2 := 680
;~ Random, SearchDirection, 1, 8
;~ if (GdipImageSearch(x, y, "img\Item_Cola.png", 125, SearchDirection, MapX1, MapY1, MapX2, MapY2))
;~ {
;~ WinActivate, %title%
;~ tooltip x%x% y%y%
;~ mousemove, %x%, %y%
;~ } else {
	;~ tooltip NotFound
;~ }
;~ return