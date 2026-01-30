# Guide d'Intégration Claude AI - Chrome Remote Pro

## Vue d'Ensemble

Ce document explique comment Claude AI doit automatiquement comprendre et configurer les connexions Chrome Remote Pro quand tu lui demandes de créer un tunnel SSH ou de se connecter à un Chrome distant.

---

## Context Automatique pour Claude

Quand tu utilises Claude et que tu mentionnes **Chrome Remote Pro**, **tunnel SSH**, ou **connexion VPS Chrome**, Claude doit automatiquement comprendre cette architecture:

### Configuration Standard

```json
{
  "vps": {
    "host": "72.61.197.216",
    "port": 42820,
    "user": "hacker",
    "keyPath": "~/.ssh/id_rsa_vps_chrome"
  },
  "projects": [
    {
      "name": "Simono",
      "port": 9222,
      "profile": "Default",
      "email": "simono.gareth@gmail.com"
    },
    {
      "name": "Dafnck",
      "port": 9223,
      "profile": "Profile 1",
      "email": "studio@dafnck.com"
    },
    {
      "name": "Gluten Libre",
      "port": 9224,
      "profile": "Profile 6",
      "email": "tech.glutenlibre@gmail.com"
    },
    {
      "name": "Dentistry",
      "port": 9225,
      "profile": "Profile 15",
      "email": "cto.dentistrygpt@gmail.com"
    },
    {
      "name": "Agentik OS",
      "port": 9226,
      "profile": "Profile 17",
      "email": "x@agentik-os.com"
    }
  ]
}
```

---

## Phrases Clés pour Claude

Quand tu dis à Claude:

### Exemple 1: "Crée-moi un tunnel SSH pour Chrome"

**Claude doit comprendre:**
```bash
# Tunnel SSH reverse vers le VPS
ssh -f -N \
    -i ~/.ssh/id_rsa_vps_chrome \
    -R PORT:localhost:PORT \
    -p 42820 \
    -o ServerAliveInterval=60 \
    -o ServerAliveCountMax=3 \
    hacker@72.61.197.216
```

Et demander: "Quel projet? (Simono/Dafnck/Gluten Libre/Dentistry/Agentik OS)"

### Exemple 2: "Connecte-toi au Chrome de Dentistry"

**Claude doit automatiquement:**
1. Savoir que Dentistry = port 9225
2. Générer un script Puppeteer:

```javascript
const puppeteer = require('puppeteer-core');

const browser = await puppeteer.connect({
    browserURL: 'http://localhost:9225',
    defaultViewport: null
});

// Session de cto.dentistrygpt@gmail.com déjà active!
```

### Exemple 3: "Lance tous les tunnels Chrome Remote Pro"

**Claude doit:**
1. Vérifier que Chrome Remote Pro est lancé
2. Ou générer la commande pour le lancer:

```bash
open ~/Applications/Chrome\ Remote\ Pro.app
```

3. Ou utiliser "Start All" dans l'app

### Exemple 4: "Automatise une tâche sur le Chrome de Gluten Libre"

**Claude doit:**
1. Identifier port 9224 = Gluten Libre
2. Créer un script avec le bon port:

```javascript
const browser = await puppeteer.connect({
    browserURL: 'http://localhost:9224',  // Port de Gluten Libre
    defaultViewport: null
});

// Session de tech.glutenlibre@gmail.com déjà active
```

---

## Template de Script pour Claude

Quand tu demandes à Claude de créer un script d'automatisation Chrome, il doit utiliser ce template:

```javascript
#!/usr/bin/env node

const puppeteer = require('puppeteer-core');

async function main() {
    // Configuration du projet
    const PROJECT_NAME = 'NOM_DU_PROJET';  // Simono/Dafnck/Gluten Libre/Dentistry/Agentik OS
    const PORT = 9222;  // Port correspondant au projet
    const EMAIL = 'email@gmail.com';  // Email Google du profil

    console.log(`🚀 Connecting to ${PROJECT_NAME} (${EMAIL})...`);

    try {
        // Connexion au Chrome distant via le port local
        const browser = await puppeteer.connect({
            browserURL: `http://localhost:${PORT}`,
            defaultViewport: null
        });

        console.log(`✅ Connected to ${PROJECT_NAME}!`);

        // Récupérer les pages existantes
        const pages = await browser.pages();
        console.log(`📄 Found ${pages.length} existing tabs`);

        // Créer un nouvel onglet si nécessaire
        const page = await browser.newPage();

        // TON AUTOMATISATION ICI
        await page.goto('https://example.com');

        // [... ton code d'automatisation ...]

        console.log('✨ Task completed!');

        // IMPORTANT: Disconnect, ne ferme PAS le browser
        await browser.disconnect();

    } catch (error) {
        console.error(`❌ Error: ${error.message}`);
        process.exit(1);
    }
}

main();
```

---

## Détection Automatique de la Configuration

### Si Claude ne sait pas quel projet utiliser

**Claude doit demander:**

```
Quel projet Chrome veux-tu utiliser?

1. Simono (9222) - simono.gareth@gmail.com
2. Dafnck (9223) - studio@dafnck.com
3. Gluten Libre (9224) - tech.glutenlibre@gmail.com
4. Dentistry (9225) - cto.dentistrygpt@gmail.com
5. Agentik OS (9226) - x@agentik-os.com
```

### Si Claude détecte que l'app n'est pas lancée

**Claude doit suggérer:**

```bash
# Lancer Chrome Remote Pro
open ~/Applications/Chrome\ Remote\ Pro.app

# Attendre 3 secondes
sleep 3

# Vérifier que l'app tourne
pgrep -fl ChromeRemotePro
```

---

## Commandes VPS pour Claude

### Vérifier les Tunnels

Quand tu demandes "Est-ce que les tunnels sont actifs?", Claude doit:

```bash
# Se connecter au VPS
ssh -i ~/.ssh/id_rsa_vps_chrome -p 42820 hacker@72.61.197.216

# Une fois connecté, vérifier les ports
netstat -tlnp | grep -E '(9222|9223|9224|9225|9226)'

# Ou tester les connexions Chrome
curl -s http://localhost:9222/json/version | jq .Browser
curl -s http://localhost:9223/json/version | jq .Browser
curl -s http://localhost:9224/json/version | jq .Browser
curl -s http://localhost:9225/json/version | jq .Browser
curl -s http://localhost:9226/json/version | jq .Browser
```

### Tester un Port Spécifique

```bash
# Exemple pour Dentistry (9225)
curl -s http://localhost:9225/json/version
```

**Réponse attendue:**
```json
{
  "Browser": "Chrome/131.0.6778.140",
  "Protocol-Version": "1.3",
  "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) ...",
  "webSocketDebuggerUrl": "ws://localhost:9225/devtools/browser/..."
}
```

---

## Mapping Automatique des Contextes

Claude doit comprendre ces associations:

### Par Nom de Projet

| Nom | Port | Email | Profil Chrome |
|-----|------|-------|---------------|
| Simono | 9222 | simono.gareth@gmail.com | Default |
| Dafnck | 9223 | studio@dafnck.com | Profile 1 |
| Gluten Libre | 9224 | tech.glutenlibre@gmail.com | Profile 6 |
| Dentistry | 9225 | cto.dentistrygpt@gmail.com | Profile 15 |
| Agentik OS | 9226 | x@agentik-os.com | Profile 17 |

### Par Domaine d'Email

Si tu mentionnes un email, Claude identifie le projet:

- `simono.gareth@gmail.com` → Simono (9222)
- `studio@dafnck.com` → Dafnck (9223)
- `tech.glutenlibre@gmail.com` → Gluten Libre (9224)
- `cto.dentistrygpt@gmail.com` → Dentistry (9225)
- `x@agentik-os.com` → Agentik OS (9226)

### Par Domaine Web

Si tu mentionnes un site web, Claude peut deviner le projet:

- `dafnck.com` → Probablement Dafnck (9223)
- `glutenlibre.com` → Probablement Gluten Libre (9224)
- `dentistry*` → Probablement Dentistry (9225)
- `agentik-os.com` → Probablement Agentik OS (9226)

---

## Exemples de Conversations avec Claude

### Exemple 1: Automatisation Simple

**Toi:**
> "Crée-moi un script pour ouvrir Gmail dans le Chrome de Dentistry"

**Claude doit répondre:**
```javascript
// Script pour ouvrir Gmail dans Dentistry (port 9225)
const puppeteer = require('puppeteer-core');

async function openGmail() {
    const browser = await puppeteer.connect({
        browserURL: 'http://localhost:9225',
        defaultViewport: null
    });

    const page = await browser.newPage();
    await page.goto('https://mail.google.com');

    // Session de cto.dentistrygpt@gmail.com déjà active!
    console.log('✅ Gmail opened in Dentistry Chrome');

    await browser.disconnect();
}

openGmail();
```

### Exemple 2: Multi-Projets

**Toi:**
> "Lance un script qui vérifie si Gmail est connecté sur tous les projets"

**Claude doit répondre:**
```javascript
const puppeteer = require('puppeteer-core');

const projects = [
    { name: 'Simono', port: 9222, email: 'simono.gareth@gmail.com' },
    { name: 'Dafnck', port: 9223, email: 'studio@dafnck.com' },
    { name: 'Gluten Libre', port: 9224, email: 'tech.glutenlibre@gmail.com' },
    { name: 'Dentistry', port: 9225, email: 'cto.dentistrygpt@gmail.com' },
    { name: 'Agentik OS', port: 9226, email: 'x@agentik-os.com' }
];

async function checkGmail(project) {
    try {
        const browser = await puppeteer.connect({
            browserURL: `http://localhost:${project.port}`,
            defaultViewport: null
        });

        const page = await browser.newPage();
        await page.goto('https://mail.google.com', { timeout: 10000 });

        // Vérifier si connecté
        const isLoggedIn = await page.$('.gb_d') !== null;

        console.log(`${project.name}: ${isLoggedIn ? '✅ Logged in' : '❌ Not logged in'} (${project.email})`);

        await browser.disconnect();
    } catch (error) {
        console.log(`${project.name}: ❌ Connection failed`);
    }
}

async function main() {
    console.log('🔍 Checking Gmail sessions...\n');

    for (const project of projects) {
        await checkGmail(project);
    }
}

main();
```

### Exemple 3: Déploiement sur VPS

**Toi:**
> "Déploie ce script sur le VPS pour automatiser Dentistry"

**Claude doit:**
1. Copier le script sur le VPS:
```bash
scp -i ~/.ssh/id_rsa_vps_chrome -P 42820 script.js hacker@72.61.197.216:~/
```

2. Se connecter au VPS:
```bash
ssh -i ~/.ssh/id_rsa_vps_chrome -p 42820 hacker@72.61.197.216
```

3. Exécuter le script:
```bash
node script.js
```

---

## Configuration de Claude (Pour Toi)

Pour que Claude comprenne automatiquement ce contexte, ajoute ceci à ta configuration Claude:

### System Prompt Personnalisé

```
Chrome Remote Pro Configuration:
- VPS: hacker@72.61.197.216:42820
- SSH Key: ~/.ssh/id_rsa_vps_chrome
- Projects:
  * Simono (9222) - simono.gareth@gmail.com
  * Dafnck (9223) - studio@dafnck.com
  * Gluten Libre (9224) - tech.glutenlibre@gmail.com
  * Dentistry (9225) - cto.dentistrygpt@gmail.com
  * Agentik OS (9226) - x@agentik-os.com

When I mention Chrome automation, tunnels, or project names, use this config automatically.
```

### Fichier de Configuration (Alternative)

Crée un fichier `~/.claude_chrome_config.json`:

```json
{
  "chromeRemotePro": {
    "vps": {
      "host": "72.61.197.216",
      "port": 42820,
      "user": "hacker",
      "keyPath": "~/.ssh/id_rsa_vps_chrome"
    },
    "projects": {
      "simono": { "port": 9222, "email": "simono.gareth@gmail.com", "profile": "Default" },
      "dafnck": { "port": 9223, "email": "studio@dafnck.com", "profile": "Profile 1" },
      "glutenLibre": { "port": 9224, "email": "tech.glutenlibre@gmail.com", "profile": "Profile 6" },
      "dentistry": { "port": 9225, "email": "cto.dentistrygpt@gmail.com", "profile": "Profile 15" },
      "agentikOS": { "port": 9226, "email": "x@agentik-os.com", "profile": "Profile 17" }
    }
  }
}
```

Puis dis à Claude:
> "Charge ma config Chrome depuis ~/.claude_chrome_config.json"

---

## Checklist pour Claude

Quand tu demandes une automatisation Chrome, Claude doit:

- [ ] Identifier le projet concerné (ou demander)
- [ ] Utiliser le bon port (9222-9226)
- [ ] Générer un script Puppeteer avec `browserURL: http://localhost:PORT`
- [ ] Mentionner que la session Google est déjà active
- [ ] Utiliser `browser.disconnect()` (PAS `browser.close()`)
- [ ] Inclure une gestion d'erreur basique
- [ ] Vérifier que Chrome Remote Pro est lancé si nécessaire

---

## Commandes Rapides pour Claude

### Setup Initial

```bash
# Installer Puppeteer sur VPS
ssh -i ~/.ssh/id_rsa_vps_chrome -p 42820 hacker@72.61.197.216
npm install puppeteer-core
```

### Tests Rapides

```bash
# Tester tous les ports
for port in 9222 9223 9224 9225 9226; do
  curl -s http://localhost:$port/json/version | jq -r '.Browser'
done

# Compter les tabs par projet
for port in 9222 9223 9224 9225 9226; do
  echo "Port $port: $(curl -s http://localhost:$port/json | jq length) tabs"
done
```

### Debug

```bash
# Voir les tunnels actifs (sur Mac)
ps aux | grep "ssh.*-R.*922"

# Voir les Chrome debugging actifs (sur Mac)
ps aux | grep "remote-debugging-port"

# Tester connexion VPS
ssh -i ~/.ssh/id_rsa_vps_chrome -p 42820 hacker@72.61.197.216 echo "Connected!"
```

---

## Résumé pour Claude

**En résumé, Claude doit automatiquement:**

1. ✅ Connaître les 5 projets et leurs ports
2. ✅ Générer des scripts Puppeteer corrects
3. ✅ Utiliser les bonnes credentials VPS
4. ✅ Suggérer de lancer Chrome Remote Pro si besoin
5. ✅ Ne jamais fermer le browser (`disconnect()` only)
6. ✅ Mentionner que les sessions Google sont actives

**Quand tu dis:**
- "Chrome de Dentistry" → Claude sait que c'est le port 9225
- "Tunnel SSH" → Claude sait comment le configurer
- "Sur le VPS" → Claude connaît les credentials
- "Automatise" → Claude génère un script Puppeteer

**C'est aussi simple que ça!** 🚀

---

## Exemple Final

**Toi:**
> "Claude, connecte-toi au VPS et liste tous les tabs ouverts dans Dentistry"

**Claude génère et exécute:**
```bash
ssh -i ~/.ssh/id_rsa_vps_chrome -p 42820 hacker@72.61.197.216 << 'ENDSSH'
curl -s http://localhost:9225/json | jq -r '.[] | "\(.title) - \(.url)"'
ENDSSH
```

**Résultat:**
```
Gmail - https://mail.google.com
Google Calendar - https://calendar.google.com
Dentistry Dashboard - https://app.dentistry.com/dashboard
```

**C'est tout!** Claude comprend automatiquement ton setup Chrome Remote Pro. 🎉
