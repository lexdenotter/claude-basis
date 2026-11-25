# claude-basis

Gedeelde werkafspraken (`CLAUDE.md`) en skills voor Claude Code, voor al mijn projecten. Elk project haalt ze wekelijks op en krijgt een PR als er iets veranderd is.

```
bron van de skills (Ponytail, mattpocock/skills)
   └─ maandelijks: skills-bijwerken.yml → PR hier → mergen
         └─ wekelijks in elk project: claude-basis.yml → PR daar → mergen
```

## Wat staat waar

| Bestand | Doel |
|---|---|
| `CLAUDE.md` | De basis-werkafspraken. Komt in projecten in `.claude/basis/CLAUDE.md` |
| `skills/` | Skills die in elk project in `.claude/skills/` komen |
| `bronnen.txt` | Waar elke skill vandaan komt, voor de maandelijkse controle |
| `sync.sh` | Zet de basis in een project. Raakt alleen skills die uit de basis komen (`.claude/basis/skills.txt`) |
| `sync/claude-basis.yml` | De sync-Action om in een project te zetten |
| `sync/controle-node.yml` | Sjabloon voor de PR-controle (typecheck, tests, build) in een Node-project. Wordt niet gesynct; je kopieert hem één keer |
| `sync/deploy-rsync.yml` | Sjabloon voor de deploy naar de eigen server (rsync over SSH, met rooktest). Wordt niet gesynct; je kopieert hem één keer naar `.github/workflows/deploy.yml` |

## De basis in een project zetten

Vraag Claude in het project: "zet de claude-basis erin". De stappen:

1. Kopieer `sync/claude-basis.yml` naar `.github/workflows/claude-basis.yml` in het project.
2. Staan er in het project al losse kopieën van basis-skills (bijvoorbeeld `.claude/skills/ponytail`), haal die dan eerst weg. De sync overschrijft geen skills die hij niet zelf heeft gezet.
3. Draai de sync één keer vanuit de root van het project:
   `git clone --depth 1 https://github.com/lexdenotter/claude-basis /tmp/claude-basis && bash /tmp/claude-basis/sync.sh /tmp/claude-basis`
4. Laat de `CLAUDE.md` van het project beginnen met:
   ```
   @.claude/basis/CLAUDE.md
   ```
   Haal regels die al in de basis staan uit het project weg. Afwijkingen schrijf je als "Afwijking van de basis: …".
5. Heeft het project nog geen PR-controle, zet er dan een neer: kopieer `sync/controle-node.yml` naar `.github/workflows/controle.yml` en pas de stappen aan op de scripts van het project (of schrijf een passende workflow als het geen Node-project is).
6. Open een PR.
7. De gebruiker zet in het project aan: *Settings → Actions → General → "Allow GitHub Actions to create and approve pull requests"*.

## Een skill toevoegen

Zet hem in `skills/<naam>/SKILL.md`. Komt hij van buiten, voeg dan een regel toe aan `bronnen.txt` en aan de tabel in `CLAUDE.md`.
