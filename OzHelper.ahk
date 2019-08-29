#NoEnv
SetBatchLines -1
ListLines Off

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

DemonHunter := [ "Vengeance"
								,"RainOfVengeance"
								,"Preparation" ]

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
			,CastVengeance := false
			,CastRainOfVengeance := false
			,CastPreparation := false
			,CastSkeleMages := false
			,NeedToMove := false
			,CastExplosiveBlast := false
			,CastBloodNova := false

global Paused := true
			,Bytes := []
			,Controls := []
			,ConvictionDuration := A_TickCount

For class_index, class in Classes {
	If (class_index = 1) {
		Gui, Add, Text, section, %class%:
	}
	Else {
		Gui, Add, Text, section xs, %class%:
	}

	For skill_index, skill in %class% {
		Gui, Add, Picture, ys, SkillPictures\%skill%.bmp
		Control = %skill%Enabled
		Controls.Push(Control)
		Gui, Add, Checkbox, xp yp+25 v%skill%Enabled
		Control = %skill%Key
		Controls.Push(Control)
		Gui, Add, Edit, xp yp+18 w17 v%skill%Key Limit1
	}
}

Gui, Add, Text, section xs, Potion:
Gui, Add, Picture, ys, SkillPictures\Potion.bmp
Gui, Add, Checkbox, xp yp+25 vPotionEnabled
Controls.Push("PotionEnabled")
Gui, Add, Edit, xp yp+18 w17 vPotionKey Limit1
Controls.Push("PotionKey")


Gui, Add, Text, section xs, Miscellaneous:
Gui, Add, Checkbox, ys vSecondSim,  Necromancer Second Simulacrum
Controls.Push("SecondSim")
;Gui, Add, Checkbox, vHexingPantsMacroEnabled, Hexing  Pants Force Move Macro

Gui, Add, Text, section xs, Force Stand Still:
Gui, Add, Edit, ys w40 vForceStandStillKey Limit5
Controls.Push("ForceStandStillKey")
Gui, Add, Text, ys, (Character, Space, Alt, Shift, Ctrl)

Gui, Add, Button, Default w80 section xs vButtonStartStop gButtonStartStop, &Start
Gui, Add, Button, w80 ys vSaveButton, S&ave
Controls.Push("SaveButton")
Gui, Add, Button, w80 ys vExitButton, E&xit
Controls.Push("ExitButton")

ReadConfig()

Gui, Show

Counter := 0
	
Loop {
	WinGetTitle, ActiveWin, A
	If (!Paused && ActiveWin = "Diablo III")
	{
		Loop 8 {
			PixelGetColor, ByteColor, 2 + (A_Index - 1) * 5, 2
			Bytes[A_Index] := ByteColor & 0xFF
		}
		If (Counter != Bytes[8]) {
		  Counter := Bytes[8]
			ParseBytes()
	
			If (Active) {
				Gui, Submit, NoHide
				
				Potion()
				If (ImNecro)
					Necromancer()
				If (ImMonk)
					Monk()
				If (ImBarb)
					Barbarian()
				If (ImDh)
					DemonHunter()
			}
		}
	}
	
	If !WinExist("ahk_class D3 Main Window Class") {
		ToggleStartStop()
	}
}

F1::ToggleStartStop()

ButtonStartStop:
	ToggleStartStop()
Return

ButtonSave:
	Gui, Submit, NoHide
	WriteConfig()
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
		GuiControl, ,ButtonStartStop, &Stop
	}
	Else {
		Paused := true
		GuiControl, ,ButtonStartStop, &Resume
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
			IniRead, %skill%Key, OzHelper.ini, %class%, %skill%Key,  X
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

	IniRead, SecondSim, OzHelper.ini, Settings, SecondSim, 0
	GuiControl, ,SecondSim, %SecondSim%

	IniRead, ForceStandStillKey, OzHelper.ini, Settings, ForceStandStillKey, Shift
	GuiControl, ,ForceStandStillKey, %ForceStandStillKey%
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
	IniWrite, %SecondSim%, OzHelper.ini, Settings, SecondSim
	IniWrite, %ForceStandStillKey%, OzHelper.ini, Settings, ForceStandStillKey
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
	ConventionLight := Bytes[2] & 2
	ConventionArcane := Bytes[2] & 4
	ConventionCold := Bytes[2] & 8
	ConventionFire := Bytes[2] & 16
	BlackholeBuffActive := Bytes[2] & 32
	CastArcaneBlast := Bytes[2] & 64

  Byte := Bytes[3]
	InARift := Byte & 2
	DontCastLand := Bytes[3] & 4
	CastBlindingFlash := Bytes[3] & 8
	CastCommandSkeletons := Bytes[3] & 16

  Byte := Bytes[4]
	CastIp := Byte & 2
	CastSim := Bytes[4] & 4
	DontCastSim := Bytes[4] & 8
	CastFalter := Bytes[4] & 16
	CastBerserker := Bytes[4] & 32
	CastSprint := Bytes[4] & 64
	CastEpiphany := Bytes[4] & 128

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
	CastRainOfVengeance := Byte & 32
	CastPreparation := Byte & 64
	CastSkeleMages := Byte & 128

  Byte := Bytes[7]
	NeedToMove := Byte & 2
	CastExplosiveBlast := Byte & 4
	CastBloodNova := Byte & 8
}

SendKeyOrMouseWithoutMove(input)
{
	global
	
	If (input = "L") {
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
	Else If (input = "R") {
		ControlClick, , ahk_class D3 Main Window Class, ,R
	}
	Else {
		ControlSend, , {Blind}{%input%}, ahk_class D3 Main Window Class
	}
}

Potion()
{
	global

	If (CastPotion && PotionEnabled)
		{
			SendKeyOrMouseWithoutMove(PotionKey)
			Sleep, 100
		}
}

Necromancer()
{
	global
	
	;Land of the Dead	
	If (SecondSim) {
		If (CastLotd && LandOfTheDeadEnabled && !DontCastLand) {
			SendKeyOrMouseWithoutMove(LandOfTheDeadKey)
			Sleep, 100
		}
	}
	else {
		If (CastLotd && LandOfTheDeadEnabled) {
			SendKeyOrMouseWithoutMove(LandOfTheDeadKey)
			Sleep, 100
		}
	}
	
	;Bone Armor
	If (CastBoneArmor && BoneArmorEnabled) {
		SendKeyOrMouseWithoutMove(BoneArmorKey)
		Sleep, 100
	}
	
	;Skeletal Mage
	If (CastSkeleMages && SkeletalMageEnabled) {
		SendKeyOrMouseWithoutMove(SkeletalMageKey)
		Sleep, 100
	}

	;Devour
	If (DevourEnabled) {
		SendKeyOrMouseWithoutMove(DevourKey)
		Sleep, 50
	}
	
	;Simulacrum
	If (SecondSim) {
		If (CastSim && SimulacrumEnabled && !DontCastSim) {
			SendKeyOrMouseWithoutMove(SimulacrumKey)
			Sleep, 100
		}
	}
	else {
		If (CastSim && SimulacrumEnabled) {
			SendKeyOrMouseWithoutMove(SimulacrumKey)
			Sleep, 100
		}
	}

	;Death Nova
	If (CastBloodNova && DeathNovaEnabled) {
		SendKeyOrMouseWithoutMove(DeathNovaKey)
		Sleep, 100
	}

	;Command Skeletons
	If (CastCommandSkeletons && CommandSkeletonsEnabled) {
		SendKeyOrMouseWithoutMove(CommandSkeletonsKey)
		Sleep, 100
	}
}

Monk()
{
	global
	
	;Epiphany
	if (CastEpiphany && EpiphanyEnabled)
	{
		SendKeyOrMouseWithoutMove(EpiphanyKey)
		Sleep, 100
	}

	;Blinding Flash
	if (CastBlindingFlash && BlindingFlashEnabled)
	{
		SendKeyOrMouseWithoutMove(BlindingFlashKey)
		Sleep, 100
	}

	;Mantra of Healing
	if (CastMantraHealing && MantraOfHealingEnabled)
	{
		SendKeyOrMouseWithoutMove(MantraOfHealingKey)
		Sleep, 50
	}

	;Sweeping Wind
	if (CastSweepingWind && SweepingWindEnabled)
	{
		SendKeyOrMouseWithoutMove(SweepingWindKey)
		Sleep, 100
	}

	;Breath of Heaven
	if (CastBoh && BreathOfHeavenEnabled)
	{
		SendKeyOrMouseWithoutMove(BreathOfHeavenKey)
		Sleep, 100
	}

	;Mantra of Conviction
	if (CastMantraConviction && (A_TickCount - 3000 >= ConvictionDuration) && MantraOfConvictionEnabled)
	{
		SendKeyOrMouseWithoutMove(MantraOfConvictionKey)
		ConvictionDuration := A_TickCount
		Sleep, 100
	}
}

Barbarian()
{
	global
	
	;Ignore Pain
	if (CastIp && IgnorePainEnabled)
	{
		SendKeyOrMouseWithoutMove(IgnorePainKey)
		Sleep, 100
	}

	;War Cry
	if (CastWc && WarCryEnabled)
	{
		SendKeyOrMouseWithoutMove(WarCryKey)
		Sleep, 100
	}

	;Threatening Shout
	if (CastFalter && ThreateningShoutEnabled)
	{
		SendKeyOrMouseWithoutMove(ThreateningShoutKey)
		Sleep, 100
	}

	;Wrath of the Berserker
	if (CastBerserker && WrathOfTheBerserkerEnabled)
	{
		SendKeyOrMouseWithoutMove(WrathOfTheBerserkerKey)
		Sleep, 100
	}

	;Sprint
	if (CastSprint && SprintEnabled)
	{
		SendKeyOrMouseWithoutMove(SprintKey)
		Sleep, 100
	}
}

DemonHunter()
{
	global
	
	;Vengeance
	if (CastVengeance && VengeanceEnabled)
	{
		SendKeyOrMouseWithoutMove(VengeanceKey)
		Sleep, 100
	}

	;Rain of Vengeance
	if (CastRainOfVengeance && RainOfVengeanceEnabled)
	{
		SendKeyOrMouseWithoutMove(RainOfVengeanceKey)
		Sleep, 100
	}

	;Preparation
	if (CastPreparation && PreparationEnabled)
	{
		SendKeyOrMouseWithoutMove(PreparationEnabledKey)
		Sleep, 100
	}
}