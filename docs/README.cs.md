# InkSvgNest

<p align="center">
<a href="https://hits.seeyoufarm.com"><img src="https://hits.seeyoufarm.com/api/count/incr/badge.svg?url=https%3A%2F%2Fgithub.com%2FJakubAndrysek%2FInkSvgNest&count_bg=%2379C83D&title_bg=%23555555&icon=&icon_color=%23E7E7E7&title=views&edge_flat=true"/></a>
<img src="https://img.shields.io/github/license/JakubAndrysek/InkSvgNest?style=flat-square">
</p>

InkSvgNest je transformační doplněk pro zálohu nestovaného rozvržení na ploše.
Slouží k jednoduchému ukládání, čtení a upravování pozice jednotlivých objektů v souboru.
Rozšíření zjednodušuje prototypování dílů, které jsou přesně rozmístěné na pracovní poše.

![](./media/app.png)

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