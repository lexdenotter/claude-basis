# Basis-werkafspraken

Dit bestand komt uit `lexdenotter/claude-basis` en wordt in elk project door de sync-Action overschreven (`.claude/basis/CLAUDE.md`). Pas het daar dus niet aan. Een wijziging voor alle projecten gaat via een PR in `claude-basis`. Wijkt een project af, dan staat dat in de eigen CLAUDE.md van het project als "Afwijking van de basis: …", en dan gaat die regel voor.

## Werkwijze

- **Taal**: alles in het Nederlands, ook commit-berichten, PR-teksten, UI-teksten, commentaar in code en vragen aan de gebruiker.
- **Grill-me bij elke nieuwe aanvraag**: begint de gebruiker een nieuwe taak (een functie, wijziging, plan of idee), start dan eerst een grill-sessie met de skill `grilling`. Ga pas daarna aan de slag, en pas als de gebruiker bevestigt dat jullie het eens zijn. Feiten zoek je zelf op, en alleen de keuzes leg je voor. Geen grill-sessie bij kleine vragen, bij een vervolg op een taak die al besproken is, of als de gebruiker zegt dat het niet hoeft. `/grill-me` start de sessie met de hand.
- **Model-router standaard aan**: roep aan het begin van elke taak de skill `/model-router` (`anthropic-skills:model-router`) aan en volg die. Deelwerk gaat dan naar een subagent met een passend model en niveau: Haiku voor eenvoudig, Sonnet voor middel, Opus voor complex. Dit geldt als uitdrukkelijk verzoek van de gebruiker om subagents te gebruiken. Kleine vragen en korte antwoorden handel je gewoon zelf af.
- **Ponytail standaard aan**: roep bij elke codeertaak de skill `/ponytail` aan (niveau `full`) en volg die: de kleinste wijziging die de taak helemaal oplost, eerst hergebruiken wat er al is, geen nieuwe afhankelijkheden voor een paar regels. Geef subagents uit de model-router dezelfde opdracht mee.
- **Git**: werk op een eigen branch en open een PR. Push nooit rechtstreeks op `main`. Zeg pas dat een PR klaar is als alle commits gepusht zijn. Na een gemergede PR start je de branch opnieuw vanaf `origin/main`.
- **Zelf mergen**: staat de PR-controle op groen, merge de PR dan zelf. De gebruiker heeft daar toestemming voor gegeven. Denk eraan dat een merge naar `main` de wijziging meteen live zet. In deze gevallen merge je niet, maar vraag je het de gebruiker:
  - de controle is rood, ontbreekt of draait niet;
  - de gebruiker moet eerst iets doen (een secret of variable zetten, iets op de server uitvoeren);
  - de wijziging raakt iets op de server dat de deploy niet zelf regelt (Caddy, docker-compose, data, geheimen), of haalt iets weg;
  - je kon iets belangrijks niet controleren, zoals een kernfunctie op een echte iPhone;
  - de gebruiker heeft gevraagd om eerst zelf te kijken.

  Meld na het mergen of de deploy en de rooktest gelukt zijn.
- **Voor je oplevert**: draai de controles die het project noemt (typecheck, tests, build, validators). Controleer UI-wijzigingen door het echte pad met Playwright te doorlopen, met schermafbeeldingen op 390 px breed (iPhone) en op desktop, in licht en donker. Zeg eerlijk wat je niet hebt gecontroleerd, vooral wat alleen op een echte iPhone te testen is.
- **Afsluiten**: eindig met een korte lijst "Wat jij nog moet doen" (bijvoorbeeld een secret zetten, de app opnieuw op het beginscherm zetten). Werk op de server stap voor stap, met opdrachten die de gebruiker zo kan plakken.
- **PR-controle**: elk project heeft een workflow `.github/workflows/controle.yml` die de controles van het project (typecheck, tests, build, validators) op elke pull request draait. Staat hij er niet, zet er dan een neer: voor een Node-project met `package.json`-scripts `typecheck`, `test` en `build` uit `sync/controle-node.yml` in `claude-basis`, anders een passende voor het project. Zo valt een fout vóór het mergen op. De sync overschrijft deze workflow niet, want elk project heeft andere controles.
- **Geheimen** (`.env`, sleutels, tokens, wachtwoorden) nooit tonen, terugsturen of in de repo zetten.

## Hosting

Alles draait op de eigen server (een VPS), niet op GitHub Pages of Vercel.

- **Domein**: `lexdenotter.com`, met een wildcard-DNS `*.lexdenotter.com` naar de server. Elk project krijgt één kort subdomein, zoals `egypte.lexdenotter.com`. DNS hoef je daarvoor niet aan te passen.
- **Caddy** regelt de domeinen en HTTPS. Er is geen nginx of certbot. Caddy draait in Docker als de container `huishoudbot-caddy` en hoort bij de repo `WhatsApp-bot` in `/srv/WhatsApp-bot`.
  - Een site toevoegen: maak een eigen bestand `/srv/WhatsApp-bot/caddy-sites/<project>.caddy` aan met `<naam>.lexdenotter.com { reverse_proxy <container>:80 }`. Dat bestand staat niet in git.
  - De projectcontainer moet in het Docker-netwerk `whatsapp-bot_web` hangen. Caddy vindt hem via de containernaam.
  - Herladen: `cd /srv/WhatsApp-bot && docker compose exec caddy caddy reload --config /etc/caddy/Caddyfile`. Werkt dat niet, gebruik dan `docker compose up -d --force-recreate caddy`.
- **Deploy**: na een merge naar `main` kopieert een GitHub Action de bestanden met rsync over SSH naar `/opt/<project>` en doet daarna een rooktest. Die rooktest kijkt of de nieuwe versie online staat. Secrets: `DEPLOY_HOST`, `DEPLOY_PATH`, `DEPLOY_SSH_KEY`, `DEPLOY_KNOWN_HOSTS`. Variables: `DEPLOY_USER`, `DEPLOY_URL`. Nieuw project: kopieer `sync/deploy-rsync.yml` uit `claude-basis` naar `.github/workflows/deploy.yml` en vul `SITE_FILES` (en eventueel `BUILD`) in.
- **Serverregels**:
  - Nooit `docker compose down -v`, `docker volume rm` of `docker system prune` gebruiken.
  - In `/srv/WhatsApp-bot` alleen het eigen bestand in `caddy-sites/` aanpassen.
  - De map niet hernoemen: die naam bepaalt de volumes en het netwerk.
  - De containers van de huishoudbot (n8n, push) niet herstarten.
  - Git in die map draai je als `sudo -u lex git`.
  - Een 502 vlak na een herstart: wacht een halve minuut en probeer het opnieuw.
- **Docs kloppen met de server**: de README en `CLAUDE.md` van een project noemen het echte pad, de echte container en het echte `caddy-sites`-bestand. Pas ze aan als iets op de server verandert.
- **Domeinwissel**: zet geen redirect van de oude naam, want die breekt API-aanroepen en webhooks. Laat de oude naam een tijd naast de nieuwe draaien, met een einddatum. Een nieuw domein is voor de iPhone een nieuwe site: de app moet opnieuw op het beginscherm, en wat in localStorage stond gaat niet mee.

## Webapps (PWA)

- **Updates**: verhoog `VERSION` in `sw.js` bij elke wijziging. Laat Caddy `sw.js` met `Cache-Control: no-cache` serveren. Laat de app bij terugkeer naar voren zoeken naar een update en dan een melding "Nieuwe versie beschikbaar" tonen met de knop "Vernieuwen".
- **Safari**: gebruik niets wat Safari 16.4 niet kent (bijvoorbeeld geen regex-lookbehind). Een stille modus, vergrendelen, QR-scannen en audio gedragen zich op een iPhone anders. Noem die als "niet gecontroleerd" als je ze niet op een echt toestel hebt kunnen testen.

## Skills uit de basis

De sync zet deze skills in `.claude/skills/` van het project. Pas ze daar niet aan; ze worden bij de volgende sync overschreven. De basis-repo vergelijkt ze elke maand met de bron en opent een PR als er iets veranderd is.

| Skill | Bron (MIT) |
|---|---|
| ponytail | `DietrichGebert/ponytail` |
| grilling | `mattpocock/skills` |
| grill-me | `mattpocock/skills` (roept alleen `grilling` aan) |
