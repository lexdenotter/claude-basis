# Basis-werkafspraken

Dit bestand komt uit `lexdenotter/claude-basis` en wordt in elk project door de sync-Action overschreven (`.claude/basis/CLAUDE.md`). Pas het daar dus niet aan. Een wijziging voor alle projecten gaat via een PR in `claude-basis`. Wijkt een project af, dan staat dat in de eigen CLAUDE.md van het project als "Afwijking van de basis: …", en dan gaat die regel voor.

## Werkwijze

- **Taal**: alles in het Nederlands, ook commit-berichten, PR-teksten, UI-teksten, commentaar in code en vragen aan de gebruiker.
- **Grill-me bij elke nieuwe aanvraag**: begint de gebruiker een nieuwe taak (een functie, wijziging, plan of idee), start dan eerst een grill-sessie met de skill `grilling`. Ga pas daarna aan de slag, en pas als de gebruiker bevestigt dat jullie het eens zijn. Feiten zoek je zelf op, en alleen de keuzes leg je voor. Geen grill-sessie bij kleine vragen, bij een vervolg op een taak die al besproken is, of als de gebruiker zegt dat het niet hoeft. `/grill-me` start de sessie met de hand.
- **Model-router standaard aan**: roep aan het begin van elke taak de skill `/model-router` (`anthropic-skills:model-router`) aan en volg die. Deelwerk gaat dan naar een subagent met een passend model en niveau: Haiku voor eenvoudig, Sonnet voor middel, Opus voor complex. Dit geldt als uitdrukkelijk verzoek van de gebruiker om subagents te gebruiken. Kleine vragen en korte antwoorden handel je gewoon zelf af.
- **Ponytail standaard aan**: roep bij elke codeertaak de skill `/ponytail` aan (niveau `full`) en volg die: de kleinste wijziging die de taak helemaal oplost, eerst hergebruiken wat er al is, geen nieuwe afhankelijkheden voor een paar regels. Geef subagents uit de model-router dezelfde opdracht mee.
- **Git**: werk op een eigen branch en open een PR. **De gebruiker merget.** Nooit zelf mergen of op `main` pushen. Na een gemergede PR start je de branch opnieuw vanaf `origin/main`.
- **Voor je oplevert**: draai de controles die het project noemt (typecheck, tests, build, validators). Controleer UI-wijzigingen met een schermafbeelding. Zeg eerlijk wat je niet hebt gecontroleerd.
- **PR-controle**: elk project heeft een workflow `.github/workflows/controle.yml` die de controles van het project (typecheck, tests, build, validators) op elke pull request draait. Staat hij er niet, zet er dan een neer: voor een Node-project met `package.json`-scripts `typecheck`, `test` en `build` uit `sync/controle-node.yml` in `claude-basis`, anders een passende voor het project. Zo valt een fout vóór het mergen op. De sync overschrijft deze workflow niet, want elk project heeft andere controles.
- **Geheimen** (`.env`, sleutels, tokens, wachtwoorden) nooit tonen, terugsturen of in de repo zetten.

## Skills uit de basis

De sync zet deze skills in `.claude/skills/` van het project. Pas ze daar niet aan; ze worden bij de volgende sync overschreven. De basis-repo vergelijkt ze elke maand met de bron en opent een PR als er iets veranderd is.

| Skill | Bron (MIT) |
|---|---|
| ponytail | `DietrichGebert/ponytail` |
| grilling | `mattpocock/skills` |
| grill-me | `mattpocock/skills` (roept alleen `grilling` aan) |
