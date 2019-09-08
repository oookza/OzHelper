#SingleInstance Force
#NoEnv
#KeyHistory 0
#Warn

SetBatchLines -1
SetWorkingDir %A_ScriptDir%
SetControlDelay, -1
ListLines Off

CoordMode, Pixel, Client
CoordMode, Mouse, Client

global DEFAULT_KEY_DELAY := 100
			,BYTE_COUNT := 9

;Classes := [ "Barbarian", "Monk", "Necromancer", "Wizard", "DemonHunter" ]
Classes := [ "Barbarian", "Monk", "Necromancer", "DemonHunter" ]

Barbarian := [ "IgnorePain"
							,"WarCry"
							,"ThreateningShout"
							,"WrathOfTheBerserker"
							,"Sprint" ]

Monk := [ "Epiphany"
				 ,"MantraOfHealing"
				 ,"SweepingWind"
				 ,"BreathOfHeaven"
				 ,"MantraOfConviction"
				 ,"BlindingFlash" ]

Necromancer := [ "LandOfTheDead"
								,"BoneArmor"
								,"SkeletalMage"
								,"Devour"
								,"Simulacrum"
								,"DeathNova"
								,"CommandSkeletons" ]

Wizard := [ "WaveOfForce"
					 ,"Electrocute"
					 ,"Meteor"
					 ,"Disintegrate"
					 ,"BlackHole"
					 ,"StormArmor"
					 ,"MagicWeapon"
					 ,"Archon"
					 ,"ArcaneBlast"
					 ,"ExplosiveBlast" ]

DemonHunter := [ "ShadowPower"
							 , "SmokeScreen"
							 , "Vengeance"
							 , "Preparation"
							 , "Companion"
							 , "Multishot"]

global Active := false
			,ImBarb := false
			,ImMonk := false
			,ImWizard := false
			,ImNecro := false
			,ImDh := false
			,ImSader := false
			,ConventionLight := false
			,ConventionArcane := false
			,ConventionCold := false
			,ConventionFire := false
			,BlackholeBuffActive := false
			,CastArcaneBlast := false
			,InARift := false
			,DontCastLand := false
			,CastBlindingFlash := false
			,CastCommandSkeletons := false
			,CastIp := false
			,CastSim := false
			,DontCastSim := false
			,CastFalter := false
			,CastBerserker := false
			,CastSprint := false
			,CastEpiphany := false
			,CastWc := false
			,CastMantraHealing := false
			,CastSweepingWind := false
			,CastBoh := false
			,CastMantraConviction := false
			,CastLotd := false
			,CastBoneArmor := false
			,CastPotion := false
			,CastStormArmor := false
			,CastMagicWeapon := false
			,CastShadowPower := false
			,CastSmokeScreen := false
			,CastVengeance := false
			,CastPreparation := false
			,CastCompanion := false
			,CastMultishot := false
			,CastSkeleMages := false
			,NeedToMove := false
			,CastExplosiveBlast := false
			,CastBloodNova := false
			,MoveHexingPants := false

global Paused := true
			,Bytes := []
			,Controls := []
			,ConvictionDuration := A_TickCount
			,DiabloWidth
			,DiabloHeight
			,HexX
			,HexY

BuildGui()
ReadConfig()
Gui, Show

SetKeyDelay, %DEFAULT_KEY_DELAY%
Counter := 0
GetClientWindowSize("ahk_class D3 Main Window Class", DiabloWidth, DiabloHeight)
HexX := Round(DiabloWidth / 2)
HexY := Round(DiabloHeight * 0.47)

Loop {
	WinGetTitle, ActiveWin, A

	If (!Paused && ActiveWin = "Diablo III") {
		Loop %BYTE_COUNT% {
			PixelGetColor, ByteColor, 2, 2 + (A_Index - 1) * 5
			Bytes[A_Index] := ByteColor & 0xFF
			StatusConnected := Bytes[A_Index] = ByteColor ? 1 : 0
			If (!StatusConnected)
				Break
		}

		If (StatusConnected) {
			GuiControl, , StatusConnected, 1
			If (Counter != Bytes[BYTE_COUNT]) {
				Counter := Bytes[BYTE_COUNT]
				ParseBytes()
	
				If (Active) {
					GuiControl, , StatusActive, 1
					Gui, Submit, NoHide
				
					Potion()
					HexingPants()
					If (ImNecro)
						Necromancer()
					If (ImMonk)
						Monk()
					If (ImBarb)
						Barbarian()
					If (ImDh)
						DemonHunter()
				}
				Else {
					GuiControl, , StatusActive, 0
				}
			}
		}
		Else {
			GuiControl, , StatusConnected, 0
		}
	}
	
	If (!Paused && !WinExist("ahk_class D3 Main Window Class")) {
		ToggleStartStop()
	}
	
	Sleep, 5
}

;F1::ToggleStartStop()

BuildGui()
{
	global
	
	w := 310
	
	For class_index, class in Classes {
		If (class_index = 1)
			Gui, Add, GroupBox, Section R4 W%w%, %class%
		Else
			Gui, Add, GroupBox, Section R4 W%w% xs, %class%

		For skill_index, skill in %class% {
			x := 10+30*(skill_index-1)
			Gui, Add, Picture, xs+%x% ys+20, SkillPictures\%skill%.bmp
		
			Control = %skill%Enabled
			Controls.Push(Control)
			Gui, Add, Checkbox, xp yp+25 v%skill%Enabled
			Control = %skill%Key
			Controls.Push(Control)
			Gui, Add, Edit, xp yp+18 w17 v%skill%Key Limit1
		}
	}

	Gui, Add, GroupBox, Section R4 W65 xs, General

	Gui, Add, Picture, xs+10 ys+20, SkillPictures\Potion.bmp
	Gui, Add, Checkbox, xp yp+25 vPotionEnabled
	Controls.Push("PotionEnabled")
	Gui, Add, Edit, xp yp+18 w17 vPotionKey Limit1
	Controls.Push("PotionKey")

	Gui, Add, Picture, xs+40 ys+20, SkillPictures\HexingPants.bmp
	Gui, Add, Checkbox, xp yp+25 vHexingPantsEnabled
	Controls.Push("HexingPantsEnabled")

	Gui, Add, GroupBox, Section xs+75 ys R4 W235, Options

	Gui, Add, Checkbox, xs+10 ys+20 vSecondSim,  Delay first Simulacrum
	Controls.Push("SecondSim")

	Gui, Add, Text, xs+10 yp+25, Force Stand Still:
	Gui, Add, Edit, yp-3 xp+85 w40 vForceStandStillKey Limit5
	Controls.Push("ForceStandStillKey")

	Gui, Add, Text, xs+10 yp+25, Start/Stop Function Key: F
	Gui, Add, Edit, yp-3 xp+126 w20 vStartStopFKey Number Limit2
	Controls.Push("StartStopFKey")
	
	Gui, Add, Button, Default w80 section xm vButtonStartStop gButtonStartStop, &Start
	Gui, Add, Button, w80 ys vSaveButton, S&ave
	Controls.Push("SaveButton")
	Gui, Add, Button, w80 ys vExitButton, E&xit
	Controls.Push("ExitButton")

	Gui, Add, Text, section xs, Status:
	Gui, Add, Checkbox, ys Disabled Check3 vStatusConnected, Connected
	Gui, Add, Checkbox, ys Disabled Check3 vStatusActive, Active

	GuiControl, , StatusConnected, -1
	GuiControl, , StatusActive, -1

	x := w + 10
	Gui, Add, GroupBox, Section H499 W300 xm+%x% ym, Help
	Gui, Add, Picture, xs+10 ys+20, SkillPictures\IgnorePain.bmp
	Gui, Add, Checkbox, xp yp+25 vHelpTick
	GuiControl, , HelpTick, 1
	Gui, Add, Edit, xp yp+18 w17 Limit1, 1
	Gui, Add, Text, xs+40 ys+22, <= Skill
	Gui, Add, Text, xs+40 ys+44, <= Tick to enable
	Gui, Add, Text, xs+40 ys+66, <= Skill use key 0-9, a-z, L, R (Left or Right Click)
	
	Gui, Add, Picture, xs+10 ys+90, SkillPictures\Potion.bmp
	Gui, Add, Text, xs+40 yp+2, Use potion at low health
	
	Gui, Add, Picture, xs+10 ys+118, SkillPictures\HexingPants.bmp
	Gui, Add, Text, xs+40 yp-5, Keep Hexing Pants buff up
	Gui, Add, Text, xs+40 yp+15, (Assign Middle Mouse Button to Force Move)
	Gui, Add, Text, xs+10 yp+22, Force Stand Still key: 0-9, a-z, Space, Alt, Shift, Ctrl
	
	Gui, Add, Text, xs+10 yp+20, Status:
	Gui, Add, Text, xp+40 yp, Connected: OzHelper and TurboHUD connected
	Gui, Add, Text, xp yp+15, Active: OzHelper is active

	Gui, Add, Text, xs+10 yp+20, Start/Stop Function Key: Save to activate change
}

ButtonStartStop:
	ToggleStartStop()
Return

ButtonSave:
	Gui, Submit, NoHide
	WriteConfig()
	Reload
Return	

ButtonExit:
	ExitApp
Return

GuiClose:
	ExitApp
Return

ToggleStartStop()
{
	If (Paused = true) {
		If !WinExist("ahk_class D3 Main Window Class")
			Return

		Paused := false
		GuiControl, , ButtonStartStop, &Stop
	}
	Else {
		Paused := true
		GuiControl, , ButtonStartStop, &Start
		GuiControl, , StatusConnected, -1
		GuiControl, , StatusActive, -1
	}
	
	ToggleControls()
Return
}

ToggleControls()
{
	For index, ctrl in Controls {
	  GuiControl, % (Paused) ? "Enable" : "Disable", % ctrl
	}
}

ReadConfig()
{
	global

	For class_index, class in Classes {
		For skill_index, skill  in %class% {
			IniRead, %skill%Enabled,  OzHelper.ini, %class%,  %skill%Enabled, 0
			IniRead, %skill%Key, OzHelper.ini, %class%, %skill%Key,  U
			SkillEnabled := %skill%Enabled
			SkillKey := %skill%Key
			GuiControl, , %skill%Enabled, %SkillEnabled%
			GuiControl, , %skill%Key, %SkillKey%
		}
	}

	IniRead, PotionEnabled,  OzHelper.ini, Settings,  PotionEnabled, 1
	IniRead, PotionKey, OzHelper.ini, Settings, PotionKey,  q
	GuiControl, , PotionEnabled, %PotionEnabled%
	GuiControl, , PotionKey, %PotionKey%

	IniRead, HexingPantsEnabled,  OzHelper.ini, Settings,  HexingPantsEnabled, 0
	GuiControl, , HexingPantsEnabled, %HexingPantsEnabled%

	IniRead, SecondSim, OzHelper.ini, Settings, SecondSim, 0
	GuiControl, ,SecondSim, %SecondSim%

	IniRead, ForceStandStillKey, OzHelper.ini, Settings, ForceStandStillKey, Shift
	GuiControl, ,ForceStandStillKey, %ForceStandStillKey%

	IniRead, StartStopFKey, OzHelper.ini, Settings, StartStopFKey, 1
	GuiControl, ,StartStopFKey, %StartStopFKey%
	
	Hotkey, F%StartStopFkey%, ButtonStartStop
}

WriteConfig()
{
	global

	For class_index, class in Classes {
		For skill_index, skill  in %class% {
			SkillEnabled := %skill%Enabled
			SkillKey := %skill%Key
			IniWrite, %SkillEnabled%, OzHelper.ini, %class%, %skill%Enabled
			IniWrite, %SkillKey%, OzHelper.ini, %class%, %skill%Key
		}
	}

	IniWrite, %PotionEnabled%, OzHelper.ini, Settings, PotionEnabled
	IniWrite, %PotionKey%, OzHelper.ini, Settings, PotionKey
	IniWrite, %HexingPantsEnabled%, OzHelper.ini, Settings, HexingPantsEnabled
	IniWrite, %SecondSim%, OzHelper.ini, Settings, SecondSim
	IniWrite, %ForceStandStillKey%, OzHelper.ini, Settings, ForceStandStillKey
	IniWrite, %StartStopFKey%, OzHelper.ini, Settings, StartStopFKey
}

ParseBytes()
{
  Byte := Bytes[1]
  Active := Byte & 2
	ImBarb := Byte & 4
  ImMonk := Byte & 8
	ImWizard := Byte & 16
	ImNecro := Byte & 32
	ImDh := Byte & 64
	ImSader := Byte & 128

  Byte := Bytes[2]
	ConventionLight := Byte & 2
	ConventionArcane := Byte & 4
	ConventionCold := Byte & 8
	ConventionFire := Byte & 16
	BlackholeBuffActive := Byte & 32
	CastArcaneBlast := Byte & 64

  Byte := Bytes[3]
	InARift := Byte & 2
	DontCastLand := Byte & 4
	CastBlindingFlash := Byte & 8
	CastCommandSkeletons := Byte & 16

  Byte := Bytes[4]
	CastIp := Byte & 2
	CastSim := Byte & 4
	DontCastSim := Byte & 8
	CastFalter := Byte & 16
	CastBerserker := Byte & 32
	CastSprint := Byte & 64
	CastEpiphany := Byte & 128

  Byte := Bytes[5]
	CastWc := Byte & 2
	CastMantraHealing := Byte & 4
	CastSweepingWind := Byte & 8
	CastBoh := Byte & 16
	CastMantraConviction := Byte & 32
	CastLotd := Byte & 64
	CastBoneArmor := Byte & 128

  Byte := Bytes[6]
	CastPotion := Byte & 2
	CastStormArmor := Byte & 4
	CastMagicWeapon := Byte & 8
	CastVengeance := Byte & 16
	CastMultishot := Byte & 32
	CastPreparation := Byte & 64
	CastSkeleMages := Byte & 128

  Byte := Bytes[7]
	NeedToMove := Byte & 2
	CastExplosiveBlast := Byte & 4
	CastBloodNova := Byte & 8
	MoveHexingPants := Byte & 16
	
 Byte := Bytes[8]
	CastShadowPower := Byte & 2
	CastSmokeScreen := Byte & 4
	CastCompanion := Byte & 8
}

SendKeyOrMouseWithoutMove(input)
{
	global
	
	If (input == "L") {
		GetKeyState, state, %ForceStandStillKey%
		
		If (state = "D") {
			ControlClick, , ahk_class D3 Main Window Class, ,L
		}
		Else {
			ControlSend, , {Blind}{%ForceStandStillKey% Down}, ahk_class D3 Main Window Class
			ControlClick, , ahk_class D3 Main Window Class, ,L
			ControlSend, , {Blind}{%ForceStandStillKey% Up}, ahk_class D3 Main Window Class
		}
	}
	Else If (input == "R") {
		ControlClick, , ahk_class D3 Main Window Class, ,R
	}
	Else {
		ControlSend, , {Blind}{%input%}, ahk_class D3 Main Window Class
	}
}

GetClientWindowSize(ClientWindow, ByRef ClientWidth, ByRef ClientHeight)
{
	hwnd := WinExist(ClientWindow)
	VarSetCapacity(rc, 16)
	DllCall("GetClientRect", "uint", hwnd, "uint", &rc)
	ClientWidth := NumGet(rc, 8, "int")
	ClientHeight := NumGet(rc, 12, "int")
}

Potion()
{
	global

	If (CastPotion && PotionEnabled)
			SendKeyOrMouseWithoutMove(PotionKey)
}

HexingPants()
{
	global

	If (MoveHexingPants && HexingPantsEnabled) {
		;ControlClick, x%HexX% y%HexY%, ahk_class D3 Main Window Class, , M, , NA
		ControlClick, x%HexX% y%HexY%, ahk_class D3 Main Window Class, , M
	}
}

Necromancer()
{
	global
	
	;Land of the Dead	
	If (SecondSim) {
		If (CastLotd && LandOfTheDeadEnabled && !DontCastLand)
			SendKeyOrMouseWithoutMove(LandOfTheDeadKey)
	}
	else {
		If (CastLotd && LandOfTheDeadEnabled)
			SendKeyOrMouseWithoutMove(LandOfTheDeadKey)
	}
	
	;Bone Armor
	If (CastBoneArmor && BoneArmorEnabled)
		SendKeyOrMouseWithoutMove(BoneArmorKey)
	
	;Skeletal Mage
	If (CastSkeleMages && SkeletalMageEnabled)
		SendKeyOrMouseWithoutMove(SkeletalMageKey)

	;Devour
	If (DevourEnabled) {
		SetKeyDelay, 50
		SendKeyOrMouseWithoutMove(DevourKey)
		SetKeyDelay, %DEFAULT_KEY_DELAY%
	}
	
	;Simulacrum
	If (SecondSim) {
		If (CastSim && SimulacrumEnabled && !DontCastSim)
			SendKeyOrMouseWithoutMove(SimulacrumKey)
	}
	else {
		If (CastSim && SimulacrumEnabled)
			SendKeyOrMouseWithoutMove(SimulacrumKey)
	}

	;Death Nova
	If (CastBloodNova && DeathNovaEnabled)
		SendKeyOrMouseWithoutMove(DeathNovaKey)

	;Command Skeletons
	If (CastCommandSkeletons && CommandSkeletonsEnabled)
		SendKeyOrMouseWithoutMove(CommandSkeletonsKey)
}

Monk()
{
	global
	
	;Epiphany
	if (CastEpiphany && EpiphanyEnabled)
		SendKeyOrMouseWithoutMove(EpiphanyKey)

	;Blinding Flash
	if (CastBlindingFlash && BlindingFlashEnabled)
		SendKeyOrMouseWithoutMove(BlindingFlashKey)

	;Mantra of Healing
	if (CastMantraHealing && MantraOfHealingEnabled) {
		SetKeyDelay, 50
		SendKeyOrMouseWithoutMove(MantraOfHealingKey)
		SetKeyDelay, %DEFAULT_KEY_DELAY%
	}

	;Sweeping Wind
	if (CastSweepingWind && SweepingWindEnabled)
		SendKeyOrMouseWithoutMove(SweepingWindKey)

	;Breath of Heaven
	if (CastBoh && BreathOfHeavenEnabled)
		SendKeyOrMouseWithoutMove(BreathOfHeavenKey)

	;Mantra of Conviction
	if (CastMantraConviction && (A_TickCount - 3000 >= ConvictionDuration) && MantraOfConvictionEnabled) {
		SendKeyOrMouseWithoutMove(MantraOfConvictionKey)
		ConvictionDuration := A_TickCount
	}
}

Barbarian()
{
	global
	
	;Ignore Pain
	if (CastIp && IgnorePainEnabled)
		SendKeyOrMouseWithoutMove(IgnorePainKey)

	;War Cry
	if (CastWc && WarCryEnabled)
		SendKeyOrMouseWithoutMove(WarCryKey)

	;Threatening Shout
	if (CastFalter && ThreateningShoutEnabled)
		SendKeyOrMouseWithoutMove(ThreateningShoutKey)

	;Wrath of the Berserker
	if (CastBerserker && WrathOfTheBerserkerEnabled)
		SendKeyOrMouseWithoutMove(WrathOfTheBerserkerKey)

	;Sprint
	if (CastSprint && SprintEnabled)
		SendKeyOrMouseWithoutMove(SprintKey)
}

DemonHunter()
{
	global
	
	;Shadow Power
	if (CastShadowPower && ShadowPowerEnabled)
		SendKeyOrMouseWithoutMove(ShadowPowerKey)
	
	;Smoke Screen
	if (CastSmokeScreen && SmokeScreenEnabled)
		SendKeyOrMouseWithoutMove(SmokeScreenKey)
	
	;Vengeance
	if (CastVengeance && VengeanceEnabled)
		SendKeyOrMouseWithoutMove(VengeanceKey)

	;Preparation
	if (CastPreparation && PreparationEnabled)
		SendKeyOrMouseWithoutMove(PreparationKey)
	
	;Companion
	if (CastCompanion && CompanionEnabled)
		SendKeyOrMouseWithoutMove(CompanionKey)
		
	;Multishot
	if (CastMultishot && MultishotEnabled)
		SendKeyOrMouseWithoutMove(MultishotKey)
}
