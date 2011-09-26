local MogIt,mog = ...;
if not mog.L then
	mog.L = setmetatable({},{__index = function(tbl,key)
		return key;
	end});
end

if GetLocale() ~= "esES" and GetLocale() ~= "esMX" then return end;
local L = mog.L;

-- Plasmax of Dun Modr (EU)
L["Click to open MogIt"] = "Haz click para abrir MogIt"
L["MogIt has loaded! Type \"/mog\" to open it."] = "Mogit cargado! Escribe \"/mog\" para abrilo."
L["Drop"] = "Dejar"
L["Quest"] = "Misión"
L["Vendor"] = "Vendedor"
L["Crafted"] = "Elaborado"
L["Achievement"] = "Logro"
--L["Code Redemption"] 
--L["10N"]
--L["25N"]
--L["10H"]
--L["25H"]
L["http://www.wowhead.com/item="] = "http://es.wowhead.com/item="
L["http://eu.battle.net/wow/en/item/"] = "http://eu.battle.net/wow/es/item/"
L["%d models"] = "%d modelor"
L["%s Item URL"] = "%s URL del objeto"
L["Item %d/%d"] = "Objeto %d/%d"
L["Source:"] = "Fuente:"
L["Profession:"] = "Profesion:"
L["Slot:"] = "Casilla:"
L["Scroll through list"] = "Desplazarse por la lista"
L["Scroll wheel"] = "Rueda de desplazamiento"
L["Change item"] = "Cambiar objeto"
L["Left click"] = "Click izquierdo"
L["Chat link"] = "Enlace de chat"
L["Shift + Left click"] = "Shift + Click izquierdo"
L["Try on"] = "Vista previa"
L["Ctrl + Left click"] = "Ctrl + Click izquierdo"
L["Delete from wishlist"] = "Borrar de deseados"
L["Add to wishlist"] = "Añadir a deseados"
L["Right click"] = "Click derecho"
L["Item URL"] = "URL del objeto"
L["Shift + Right click"] = "Shift + Click derecho"
L["Add to control model"] = "Añadir al modelo plantilla"
L["Ctrl + Right click"] = "Ctrl + Click derecho"
L["Select a category"] = "Seleccionar categoria"
L["Wishlist"] = "Deseados"
L["Click to load addon"] = "Haz click para cargar el addon"
--L["Zoom"]
L["Scroll wheel or"] = "Rueda de desplazamiento o"
L["Move"] = "Mover"
L["Right click and drag"] = "Haz click derecho y arrastra"
L["Rotate"] = "Rotar"
L["Left click and drag"] = "Haz click izquierdo y arrastra"
L["Faction Items:"] = "Objetos de facción:"
L["Class Items:"] = "Objetos de clase:"
L["%d selected"] = "%d seleccionado"
L["Select All"] = "Seleccionar todos"
L["Select None"] = "Deseleccionar todos"
L["One-Hand Slot:"] = "Casilla de una mano:"
L["Sorting:"] = "Ordenando"
L["By Level"] = "Por nivel"
L["By Colour"] = "Por color"
L["Hide Minimap Button"] = "Ocultar botón de minimapa"
L["Catalogue"] = "Catalogo"
L["Naked models"] = "Modelos desnudos"
L["Rows"] = "Filas"
L["Columns"] = "Columnas"
L["Tooltip"] = "Descripción"
L["Enable tooltip model"] = "Habilitar descripción del modelo"
L["Naked model"] = "Modelo desnudo"
L["Rotate with mouse wheel"] = "Rotar con la rueda del ratón"
L["Auto rotate"] = "Auto rotar"
L["Only uncommon/rare/epic"] = "Solamente poco comunes/raros/epicos"