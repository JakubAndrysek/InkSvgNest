# InkSvgNest EN

InkSvgNest is tool for backup nesting configuration.
It is used to easily save, read and edit the position of individual objects in the file.
The extension simplifies the prototyping of parts that are precisely nested on the work plane.

![](doc/app.png)

## Installation
Copy files from folder `InkSvgNest` to specify folder.

* Linux - `~/.config/inkscape/extensions` or `/usr/share/inkscape/extensions`
* Windows - `C:\Program Files\Inkscape\share\extensions`

## Usage

### Original SVG to new SVG
The extension reads original nested version and tries to apply same coordination to opened objects.

### SVG to YAML with coordinates
The extension reads the coordinates of the currently open file and saves them in a YAML file in the format `"Object name"->"Coordinates"`.

### YAML with coordinates to SVG
The opposite variant to the previous option. Extension opens a YAML file with coordinates and tries to apply them to the open file according to the object name.

## Options
### Absolute path
When selecting, it is necessary to select the full path to a specific folder and in it the file to / from which the file is saved / read.
The colon is used for graphical selection of the path.
If the required file does not exist, it is created, otherwise the file is overwritten.

### Relative path
By relative path is meant the same folder as for the currently open file.

# InkSvgNest CZ

InkSvgNest je transformační doplněk pro zálohu nestovaného rozvržení na ploše.
Slouží k jednoduchému ukládání, čtení a upravování pozice jednotlivých objektů v souboru.
Rozšíření zjednodušuje prototypování dílů, které jsou přesně rozmístěné na pracovní poše.

## Instalace
Obsah složky `InkSvgNest` nakopírujte do níže specifikovaného místa.

* Linux - `~/.config/inkscape/extensions` or `/usr/share/inkscape/extensions`
* Windows - `C:\Program Files\Inkscape\share\extensions`

## Použití

### Původní SVG na nové SVG
Rozšíření načte předchozí nanestovanou verzi souboru a pokusí se aplikovat veškeré transformace i na právě otevřený soubor.

### SVG na souřadnicový YAML
Rozšíření přečte souřadnice právě otevřeného souboru a uloží je do YAML souboru ve formátu `"Název objektu" -> "Souřadnice"`.

### Souřadnicový YAML na SVG
Opačná varianta k k předchozí volbě otevře YAML soubor se souřadnicemi a pokusí se je podle názvu objektu aplikovat na otevřený soubor.

## Varianty

### Absolutní cesta
Při výběru je nutné vybrat celou cestu k konkrétní složce a v ní i soubor do/z kterého se soubor uloží/přečte.
Trojtečka slouží ke grafickému výberu cesty.
Pokud požadovaný soubor neexistuje je vytvořen, v opačném případě je soubor přepsán.

### Relativní cesta
Relativní cestou je myšlena stejná složka jako pro aktuálně otevřený soubor.