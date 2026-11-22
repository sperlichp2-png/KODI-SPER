# KODI-SPER

Repozitář doplňků pro [Kodi](https://kodi.tv) (Kodi 19 a novější). Obsahuje doplněk **PvS Cinema**.

## Instalace do Kodi

1. **Povolit neznámé zdroje:** Nastavení → Systém → Doplňky → *Neznámé zdroje* → zapnout.
2. **Přidat zdroj:** Nastavení → Správce souborů → *Přidat zdroj* → `<none>` → zadej adresu
   `https://<uživatel>.github.io/KODI-SPER/` → pojmenuj ho např. `kodisper` → OK.
3. **Nainstalovat repozitář:** Doplňky → *Instalovat ze souboru zip* → `kodisper` →
   `repository.kodisper-….zip`.
4. **Nainstalovat PvS Cinema:** Doplňky → *Instalovat z repozitáře* → **KODI-SPER** →
   Doplňky videí → **PvS Cinema** → Instalovat.

Nové verze se pak do všech zařízení stahují samy (Kodi kontroluje aktualizace automaticky).

Bez GitHub Pages: stáhni `repository.kodisper-….zip` z této stránky do zařízení a v kroku 3 ho vyber.

## Pro správce: vydání nové verze

1. Ve zdrojích doplňku zvedni `version` v `addon.xml`.
2. Spusť `.\build.ps1 -User <github-uživatel>`.
3. Nahraj na GitHub změněné soubory: `addons.xml`, `addons.xml.md5`, složku `zips/`
   (a `repository.kodisper-*.zip` + `index.html`, pokud se změnil repozitář).
