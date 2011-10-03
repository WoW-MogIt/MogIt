local MogIt,mog = ...;
if not mog.L then
	mog.L = setmetatable({},{__index = function(tbl,key)
		return key;
	end});
end

if GetLocale() ~= "deDE" then return end;
local L = mog.L;

-- Bromber of Antonidas (EU)
L["Click to open MogIt"] = "Hier klicken, um Mogit zu öffnen"
L["MogIt has loaded! Type \"/mog\" to open it."] = "MogIt wurde geladen! Schreibe \"/mog\", um es zu öffnen."
L["Drop"] = "Beute"
--L["Quest"]
L["Vendor"] = "Verkäufer"
L["Crafted"] = "Hergestellte Gegenstände"
L["Achievement"] = "Erfolg"
--L["Code Redemption"]
--L["10N"]
--L["25N"]
--L["10H"]
--L["25H"]
L["http://www.wowhead.com/item="] = "http://de.wowhead.com/item="
L["http://eu.battle.net/wow/en/item/"] = "http://eu.battle.net/wow/de/item/"
L["%d models"] = "%d Modelle"
L["%s Item URL"] = "%s Gegenstand URL"
L["Item %d/%d"] = "Gegenstand %d/%d"
L["Source:"] = "Quelle:"
L["Profession:"] = "Beruf:"
--L["Slot:"] = "Slot:"
L["Scroll through list"] = "Durch die Liste scrollen"
L["Scroll wheel"] = "Scroll-Rad"
L["Change item"] = "Gegenstand ändern"
L["Left click"] = "Linke Maustaste klicken"
--L["Chat link"] = "Chat link"
L["Shift + Left click"] = "Shift + Linke Maustaste drücken"
L["Try on"] = "Weiterversuchen"
L["Ctrl + Left click"] = "Strg + Linke Maustaste klicken"
L["Delete from wishlist"] = "Von der Wunschliste streichen"
L["Add to wishlist"] = "Auf die Wunschliste setzen"
L["Right click"] = "Rechte Maustaste klicken"
L["Item URL"] = "Gegenstand URL"
L["Shift + Right click"] = "Shift + Rechte Maustaste drücken"
L["Add to control model"] = "Zum Kontrollmodell hinzufügen"
L["Ctrl + Right click"] = "Strg + Rechte Maustaste drücken"
L["Select a category"] = "Kategorie auswählen"
L["Wishlist"] = "Wunschliste"
L["Click to load addon"] = "Klicken, um das Addon zu laden"
L["Zoom"] = "Zoomen"
L["Scroll wheel or"] = "Scroll-Rad oder"
L["Move"] = "Bewegen"
L["Right click and drag"] = "Rechte Maustaste klicken und ziehen"
L["Rotate"] = "Rotieren"
L["Left click and drag"] = "Linke Maustaste klicken und ziehen"
L["Faction Items:"] = "Fraktions-Gegenstände:"
L["Class Items:"] = "Klassen-Gegenstände:"
L["%d selected"] = "%d ausgewählt"
L["Select All"] = "Alle auswählen"
L["Select None"] = "Nichts auswählen"
L["One-Hand Slot:"] = "Slot: Einhändig:"
L["Sorting:"] = "Sortieren:"
L["By Level"] = "Nach Level"
L["By Colour"] = "Nach Farbe"
L["Hide Minimap Button"] = "Minimap-Knopf verstecken"
L["Catalogue"] = "Katalog"
L["Naked models"] = "Nackte Modelle"
L["Rows"] = "Reihen"
L["Columns"] = "Spalten"
--L["Tooltip"] = "Tooltip"
L["Enable tooltip model"] = "Tooltip für die Modelle aktivieren"
L["Naked model"] = "Nacktes Modell"
L["Rotate with mouse wheel"] = "Mit dem Mausrad rotieren"
L["Auto rotate"] = "Automatisches Rotieren"
L["Only uncommon/rare/epic"] = "Nur Selten/Rar/Episch"