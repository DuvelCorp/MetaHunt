if not ZHunterMod_Saved then
	ZHunterMod_Saved = {}
end

BINDING_HEADER_ZAspectHeader = "ZAspect Buttons"
BINDING_HEADER_ZTrackHeader = "ZTrack Buttons"
BINDING_HEADER_ZTrapHeader = "ZTrap Buttons"
BINDING_HEADER_ZPetHeader = "ZPet Buttons"

function ZHunterMod_AlignButtons()
	zButtonTrack:ClearAllPoints()
	zButtonTrack:SetPoint("TOP", zButtonAspect, "BOTTOM", 0, -15)
	zButtonTrap:ClearAllPoints()
	zButtonTrap:SetPoint("TOP", zButtonTrack, "BOTTOM", 0, -15)
	if AutoStripDisplay then
		AutoStripDisplay:ClearAllPoints()
		AutoStripDisplay:SetPoint("TOP", zButtonTrap, "BOTTOM", 0, -10)
	end
end

-- ////////////////////////////////////////////////////////////////
-- ENGLISH
-- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

ZHUNTER_MAGMADAR = "Magmadar"
ZHUNTER_FLAMEGORE = "Flamegore"
ZHUNTER_CHROMMAGUS = "Chrommagus"
ZHUNTER_HUHURAN = "Princess Huhuran"
ZHUNTER_GLUTH = "Gluth"

ZHUNTER_YOU = "You"
ZHUNTER_HUNTER = "Hunter"
ZHUNTER_BOWS = "Bows"
ZHUNTER_CROSSBOWS = "Crossbows"
ZHUNTER_GUNS = "Guns"
ZHUNTER_AFFLICTED_DAZED = "(.+) (.+) afflicted by Dazed"

ZHUNTER_BULLETS_LIGHT = "Light Shot"
ZHUNTER_BULLETS_CRAFTLIGHT = "Crafted Light Shot"
ZHUNTER_BULLETS_FLASH = "Flash Pellet"
ZHUNTER_BULLETS_HEAVY = "Heavy Shot"
ZHUNTER_BULLETS_PEBBLE = "Smooth Pebble"
ZHUNTER_BULLETS_CRAFTHEAVY = "Crafted Heavy Shot"
ZHUNTER_BULLETS_SOLID = "Solid Shot"
ZHUNTER_BULLETS_CRAFTSOLID = "Crafted Solid Shot"
ZHUNTER_BULLETS_EXPLODING = "Exploding Shot"
ZHUNTER_BULLETS_MITHRILSLUG = "Hi-impact Mithril Slugs"
ZHUNTER_BULLETS_ACCURATE = "Accurate Slugs"
ZHUNTER_BULLETS_GYROSHOT = "Mithril Gyro-Shot"
ZHUNTER_BULLETS_ICETHREADED = "Ice Threaded Bullet"
ZHUNTER_BULLETS_THORIUM = "Thorium Shells"
ZHUNTER_BULLETS_ROCKSHARD = "Rockshard Pellets"
ZHUNTER_BULLETS_CANNONBALL = "Miniature Cannon Balls"

ZHUNTER_ARROWS_ROUGH = "Rough Arrow"
ZHUNTER_ARROWS_SHARP = "Sharp Arrow"
ZHUNTER_ARROWS_RAZOR = "Razor Arrow"
ZHUNTER_ARROWS_FEATHER = "Feathered Arrow"
ZHUNTER_ARROWS_PRECISION = "Precision Arrow"
ZHUNTER_ARROWS_JAGGED = "Jagged Arrow"
ZHUNTER_ARROWS_ICETHREADED = "Ice Threaded Arrow"
ZHUNTER_ARROWS_THORIUM = "Thorium Headed Arrow"
ZHUNTER_ARROWS_DOOMSHOT = "Doomshot"

ZHUNTER_RAPIDFIRE = "Rapid Fire"
ZHUNTER_IMPROVEDHAWK = "Quick Shots"
ZHUNTER_BERSERKING = "Berserking"
ZHUNTER_AUTO = "Auto Shot"
ZHUNTER_AIMED = "Aimed Shot"
ZHUNTER_SERPENT = "Serpent Sting"
ZHUNTER_SCORPID = "Scorpid Sting"
ZHUNTER_VIPER = "Viper Sting"
ZHUNTER_ARCANE = "Arcane Shot"
ZHUNTER_CONCUSSIVE = "Concussive Shot"
ZHUNTER_DISTRACTING = "Distracting Shot"
ZHUNTER_VOLLEY = "Volley"

ZHUNTER_TRACK_HUMANOIDS = "Track Humanoids"
ZHUNTER_TRACK_HIDDEN = "Track Hidden"
ZHUNTER_TRACK_BEASTS = "Track Beasts"
ZHUNTER_TRACK_ELEMENTALS = "Track Elementals"
ZHUNTER_TRACK_DEMONS = "Track Demons"
ZHUNTER_TRACK_DRAGONKIN = "Track Dragonkin"
ZHUNTER_TRACK_UNDEAD = "Track Undead"
ZHUNTER_TRACK_GIANTS = "Track Giants"
ZHUNTER_TRACK_MINERALS = "Find Minerals"
ZHUNTER_TRACK_HERBS = "Find Herbs"
ZHUNTER_TRACK_TREASURE = "Find Treasure"

ZHUNTER_TRAP_FREEZING = "Freezing Trap"
ZHUNTER_TRAP_FROST = "Frost Trap"
ZHUNTER_TRAP_IMMOLATION = "Immolation Trap"
ZHUNTER_TRAP_EXPLOSIVE = "Explosive Trap"

ZHUNTER_ASPECT_HAWK = "Aspect of the Hawk"
ZHUNTER_ASPECT_MONKEY = "Aspect of the Monkey"
ZHUNTER_ASPECT_CHEETAH = "Aspect of the Cheetah"
ZHUNTER_ASPECT_BEAST = "Aspect of the Beast"
ZHUNTER_ASPECT_PACK = "Aspect of the Pack"
ZHUNTER_ASPECT_WILD = "Aspect of the Wild"

ZHUNTER_PET_EYES = "Eyes of the Beast"
ZHUNTER_PET_DISMISS = "Dismiss Pet"
ZHUNTER_PET_MEND = "Mend Pet"
ZHUNTER_PET_FEED = "Feed Pet"
ZHUNTER_PET_CALL = "Call Pet"
ZHUNTER_PET_REVIVE = "Revive Pet"
ZHUNTER_PET_LORE = "Beast Lore"
ZHUNTER_PET_TRAINING = "Beast Training"
ZHUNTER_PET_TAMING = "Tame Beast"

--------------------------------------------------------------------
-- Meta 09 Feb 2026 
-- Twow spells addition
ZHUNTER_PET_POSITION = "Pet Command: Take Position"

ZHUNTER_ASPECT_WOLF = "Aspect of the Wolf"
ZHUNTER_ASPECT_VIPER = "Aspect of the Viper"

ZHUNTER_STEADY = "Steady Shot"
ZHUNTER_BAITED = "Baited Shot"
ZHUNTER_INTIMIDATION = "Intimidation"
ZHUNTER_KILLCOMMAND = "Kill Command"
ZHUNTER_CARVE = "Carve"
ZHUNTER_LACERATE = "Lacerate"

--------------------------------------------------------------------



-- ////////////////////////////////////////////////////////////////
-- FRENCH
-- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

-- � = \195\136   � = \195\168
-- � = \195\137   � = \195\169
-- � = \195\138   � = \195\170
-- � = \195\143   � = \195\175
-- � = \195\135   � = \195\167

if ( GetLocale() == "frFR" ) then

--ZHUNTER_MAGMADAR = "Magmadar"
--ZHUNTER_FLAMEGORE = "Flamegore"
--ZHUNTER_CHROMMAGUS = "Chrommagus"
--ZHUNTER_HUHURAN = "Princess Huhuran"
--ZHUNTER_GLUTH = "Gluth"

ZHUNTER_YOU = "Vous"
ZHUNTER_HUNTER = "Chasseur"
--ZHUNTER_BOWS = "Bows"
ZHUNTER_CROSSBOWS = "Arbal\195\168tes"
ZHUNTER_GUNS = "Armes\195\160feus"
--ZHUNTER_AFFLICTED_DAZED = "(.+) (.+) afflicted by Dazed"

ZHUNTER_BULLETS_LIGHT = "Balle l\195\169g\195\168re"
ZHUNTER_BULLETS_CRAFTLIGHT = "Balle l\195\169g\195\168re fabriqu\195\169e"
ZHUNTER_BULLETS_FLASH = "Bille d'\195\169clair"
ZHUNTER_BULLETS_HEAVY = "Balle lourde"
ZHUNTER_BULLETS_PEBBLE = "Caillou lisse"
ZHUNTER_BULLETS_CRAFTHEAVY = "Balle lourde fabriqu\195\169e"
ZHUNTER_BULLETS_SOLID = "Balle dure"
ZHUNTER_BULLETS_CRAFTSOLID = "Balle dure fabriqu\195\169e"
ZHUNTER_BULLETS_EXPLODING = "Balle explosive"
ZHUNTER_BULLETS_MITHRILSLUG = "Balle per\195\167antes en mithril"
ZHUNTER_BULLETS_ACCURATE = "Balles de pr\195\169cision"
ZHUNTER_BULLETS_GYROSHOT = "Balle gyroscopique en mithril"
ZHUNTER_BULLETS_ICETHREADED = "Balle de glace"
ZHUNTER_BULLETS_THORIUM = "Obus en thorium"
ZHUNTER_BULLETS_ROCKSHARD = "Balle de roche"
ZHUNTER_BULLETS_CANNONBALL = "Boulet de canon miniature"

ZHUNTER_ARROWS_ROUGH = "Fl\195\168che grossi\195\168re"
ZHUNTER_ARROWS_SHARP = "Fl\195\168che pointue"
ZHUNTER_ARROWS_RAZOR = "Fl\195\168che rasoir"
ZHUNTER_ARROWS_FEATHER = "Fl\195\168che \195\160 plumes"
ZHUNTER_ARROWS_PRECISION = "Fl\195\168che de pr\195\169cision"
ZHUNTER_ARROWS_JAGGED = "Fl\195\168che barbel\195\169e"
ZHUNTER_ARROWS_ICETHREADED = "Fl\195\168che de glace"
ZHUNTER_ARROWS_THORIUM = "Fl\195\168ches \195\160 pointe de thorium"
ZHUNTER_ARROWS_DOOMSHOT = "Tir maudit"

ZHUNTER_RAPIDFIRE = "Tir rapide"
--ZHUNTER_IMPROVEDHAWK = "Quick Shots"
--ZHUNTER_BERSERKING = "Berserking"
ZHUNTER_AUTO = "Tir automatique"
ZHUNTER_AIMED = "Vis\195\169e"
ZHUNTER_SERPENT = "Morsure de serpent"
ZHUNTER_SCORPID = "Piq\195\187re de scorpide"
ZHUNTER_VIPER = "Morsure de vip\195\168re"
ZHUNTER_ARCANE = "Tir des arcanes"
ZHUNTER_CONCUSSIVE = "Trait de choc"
ZHUNTER_DISTRACTING = "Trait provocateur"

ZHUNTER_TRACK_HUMANOIDS = "Pistage des humano\195\175des"
ZHUNTER_TRACK_HIDDEN = "Pistage des camoufl\195\169s"
ZHUNTER_TRACK_BEASTS = "Pistage des b\195\170tes"
ZHUNTER_TRACK_ELEMENTALS = "Pistage des \195\169l\195\169mentaires"
ZHUNTER_TRACK_DEMONS = "Pistage des d\195\169mons"
ZHUNTER_TRACK_DRAGONKIN = "Pistage des draconiens"
ZHUNTER_TRACK_UNDEAD = "Pistage des morts-vivants"
ZHUNTER_TRACK_GIANTS = "Pistage des g\195\169ants"
--ZHUNTER_TRACK_MINERALS = "Find Minerals"
--ZHUNTER_TRACK_HERBS = "Find Herbs"
--ZHUNTER_TRACK_TREASURE = "Find Treasure"

ZHUNTER_TRAP_FREEZING = "Pi\195\168ge givrant"
ZHUNTER_TRAP_FROST = "Pi\195\168ge de givre"
ZHUNTER_TRAP_IMMOLATION = "Pi\195\168ge d'Immolation"
ZHUNTER_TRAP_EXPLOSIVE = "Pi\195\168ge explosif"

ZHUNTER_ASPECT_HAWK = "Aspect du faucon"
ZHUNTER_ASPECT_MONKEY = "Aspect du singe"
ZHUNTER_ASPECT_CHEETAH = "Aspect du gu\195\169pard"
ZHUNTER_ASPECT_BEAST = "Aspect de la b\195\170te"
ZHUNTER_ASPECT_PACK = "Aspect de la meute"
ZHUNTER_ASPECT_WILD = "Aspect de la nature"

ZHUNTER_PET_EYES = "oeil de la b\195\170te"
--ZHUNTER_PET_DISMISS = "Dismiss Pet"
--ZHUNTER_PET_MEND = "Mend Pet"
--ZHUNTER_PET_FEED = "Feed Pet"
--ZHUNTER_PET_CALL = "Call Pet"
--ZHUNTER_PET_REVIVE = "Revive Pet"

end

-- ////////////////////////////////////////////////////////////////
-- GERMAN
-- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

-- � = /195/164
-- � = /195/188
-- � = /195/182

if ( GetLocale() == "deDE" ) then

ZHUNTER_MAGMADAR = "Magmadar"
ZHUNTER_FLAMEGORE = "Flammenmaul"
ZHUNTER_CHROMMAGUS = "Chrommagus"
ZHUNTER_HUHURAN = "Prinzessin Huhuran"
--ZHUNTER_GLUTH = "Gluth"

ZHUNTER_YOU = "Ihr"
ZHUNTER_HUNTER = "J\195\164ger"
ZHUNTER_BOWS = "B\195\182gen"
ZHUNTER_CROSSBOWS = "Armbr\195\188ste"
ZHUNTER_GUNS = "Schusswaffen"
ZHUNTER_AFFLICTED_DAZED = "(.+) (.+) ersch\195\188ttert"

ZHUNTER_BULLETS_LIGHT = "Leichtes Geschoss"
ZHUNTER_BULLETS_CRAFTLIGHT = "Gefertigtes leichtes Geschoss"
ZHUNTER_BULLETS_FLASH = "Blitzk\195\188gelchen"
ZHUNTER_BULLETS_HEAVY = "Schweres Geschoss"
ZHUNTER_BULLETS_PEBBLE = "Glatter Kiesel"
ZHUNTER_BULLETS_CRAFTHEAVY = "Gefertigtes schweres Geschoss"
ZHUNTER_BULLETS_SOLID = "Robustes Geschoss"
ZHUNTER_BULLETS_CRAFTSOLID = "Gefertigtes robustes Geschoss"
ZHUNTER_BULLETS_EXPLODING = "Explosivgeschoss"
ZHUNTER_BULLETS_MITHRILSLUG = "Stark einschlagende Mithrilpatronen"
ZHUNTER_BULLETS_ACCURATE = "Genaue Patronen"
ZHUNTER_BULLETS_GYROSHOT = "Gyro-Mithrilgeschoss"
ZHUNTER_BULLETS_ICETHREADED = "Eisgewirkte Kugel"
ZHUNTER_BULLETS_THORIUM = "Thoriumpatronen"
ZHUNTER_BULLETS_ROCKSHARD = "Felssplitterk\195\188gelchen"
ZHUNTER_BULLETS_CANNONBALL = "Miniaturkanonenkugeln"

ZHUNTER_ARROWS_ROUGH = "Rauer Pfeil"
ZHUNTER_ARROWS_SHARP = "Scharfer Pfeil"
ZHUNTER_ARROWS_RAZOR = "Schneidenpfeil"
ZHUNTER_ARROWS_FEATHER = "Gefiederter Pfeil"
ZHUNTER_ARROWS_PRECISION = "Pr\195\164zisionspfeil"
ZHUNTER_ARROWS_JAGGED = "Gezackter Pfeil"
ZHUNTER_ARROWS_ICETHREADED = "Eisgewirkter Pfeil"
ZHUNTER_ARROWS_THORIUM = "Thoriumpfeile"
ZHUNTER_ARROWS_DOOMSHOT = "Verdammnisgeschoss"

ZHUNTER_RAPIDFIRE = "Schnellfeuer"
ZHUNTER_IMPROVEDHAWK = "Schnelle Sch\195\188sse"
ZHUNTER_BERSERKING = "Berserker"
ZHUNTER_AUTO = "Autom. Schuss"
ZHUNTER_AIMED = "Gezielter Schuss"
ZHUNTER_SERPENT = "Schlangenbiss"
ZHUNTER_SCORPID = "Skorpidstich"
ZHUNTER_VIPER = "Vipernbiss"
ZHUNTER_ARCANE = "Arkaner Schuss"
ZHUNTER_CONCUSSIVE = "Ersch\195\188tternder Schuss"
ZHUNTER_DISTRACTING = "Ablenkender Schuss"

ZHUNTER_TRACK_HUMANOIDS = "Humanoide aufsp\195\188ren"
ZHUNTER_TRACK_HIDDEN = "Verborgenes aufsp\195\188ren"
ZHUNTER_TRACK_BEASTS = "Wildtiere aufsp\195\188ren"
ZHUNTER_TRACK_ELEMENTALS = "Elementare aufsp\195\188ren"
ZHUNTER_TRACK_DEMONS = "D\195\164monen aufsp\195\188ren"
ZHUNTER_TRACK_DRAGONKIN = "Drachkin aufsp\195\188ren"
ZHUNTER_TRACK_UNDEAD = "Untote aufsp\195\188ren"
ZHUNTER_TRACK_GIANTS = "Riesen aufsp\195\188ren"
ZHUNTER_TRACK_MINERALS = "Mineraliensuche"
ZHUNTER_TRACK_HERBS = "Kr\195\164utersuche"
ZHUNTER_TRACK_TREASURE = "Schatzsucher"

ZHUNTER_TRAP_FREEZING = "Eisk\195\164ltefalle"
ZHUNTER_TRAP_FROST = "Frostfalle"
ZHUNTER_TRAP_IMMOLATION = "Feuerbrandfalle"
ZHUNTER_TRAP_EXPLOSIVE = "Sprengfalle"

ZHUNTER_ASPECT_HAWK = "Aspekt des Falken"
ZHUNTER_ASPECT_MONKEY = "Aspekt des Affen"
ZHUNTER_ASPECT_CHEETAH = "Aspekt des Geparden"
ZHUNTER_ASPECT_BEAST = "Aspekt des Wildtiers"
ZHUNTER_ASPECT_PACK = "Aspekt des Rudels"
ZHUNTER_ASPECT_WILD = "Aspekt der Wildnis"

ZHUNTER_PET_EYES = "Augen des Wildtiers"
ZHUNTER_PET_DISMISS = "Tier freigeben"
ZHUNTER_PET_MEND = "Tier heilen"
ZHUNTER_PET_FEED = "Tier f\195\188ttern"
ZHUNTER_PET_CALL = "Tier rufen"
ZHUNTER_PET_REVIVE = "Tier wiederbeleben"
ZHUNTER_PET_TAMING = "Wildtier z\195\164hmen"
ZHUNTER_PET_TRAINING = "Wildtierausbildung"

ZHUNTER_PET_POSITION = "Pet Command: Take Position"

end