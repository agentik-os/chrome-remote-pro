# Chrome Remote Pro - Guide Complet VPS

## Vue d'Ensemble

Ce guide explique comment configurer ton VPS pour recevoir les connexions Chrome Remote Pro et contrôler tes instances Chrome depuis n'importe où dans le monde.

---

## Architecture

```
┌──────────────────┐         SSH Tunnel          ┌──────────────────┐
│   TON MAC LOCAL  │────────────────────────────>│   VPS DISTANT    │
│                  │                              │                  │
│  Chrome (9222)   │<────Reverse Tunnel──────────│  localhost:9222  │
│  Chrome (9223)   │<────Reverse Tunnel──────────│  localhost:9223  │
│  Chrome (9224)   │<────Reverse Tunnel──────────│  localhost:9224  │
│  Chrome (9225)   │<────Reverse Tunnel──────────│  localhost:9225  │
│  Chrome (9226)   │<────Reverse Tunnel──────────│  localhost:9226  │
└──────────────────┘                              └──────────────────┘
                                                           │
                                                           │
                                                           v
                                                  ┌──────────────────┐
                                                  │   PUPPETEER      │
                                                  │   Contrôle les   │
                                                  │   5 Chrome       │
                                                  └──────────────────┘
```

---

## Informations de Connexion VPS

### Credentials

```bash
Host: 72.61.197.216
Port: 42820
User: hacker
SSH Key: ~/.ssh/id_rsa_vps_chrome
```

### Connexion Rapide

```bash
ssh -i ~/.ssh/id_rsa_vps_chrome -p 42820 hacker@72.61.197.216
```

---

## Ports Exposés sur le VPS

Une fois Chrome Remote Pro lancé sur ton Mac, les ports suivants sont disponibles sur le VPS:

| Port | Projet | Profil Chrome | Email Google |
|------|--------|---------------|--------------|
| 9222 | Simono | Default | simono.gareth@gmail.com |
| 9223 | Dafnck | Profile 1 | studio@dafnck.com |
| 9224 | Gluten Libre | Profile 6 | tech.glutenlibre@gmail.com |
| 9225 | Dentistry | Profile 15 | cto.dentistrygpt@gmail.com |
| 9226 | Agentik OS | Profile 17 | x@agentik-os.com |

---

## Configuration VPS

### 1. Installer Node.js et Puppeteer

Si ce n'est pas déjà fait sur ton VPS:

```bash
# Installer Node.js (si pas installé)
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Créer un répertoire de travail
mkdir -p ~/chrome-remote-control
cd ~/chrome-remote-control

# Installer Puppeteer
npm init -y
npm install puppeteer-core
```

### 2. Vérifier les Tunnels Actifs

Une fois Chrome Remote Pro lancé sur ton Mac, vérifie que les tunnels sont bien établis:

```bash
# Sur le VPS
netstat -tlnp | grep -E '(9222|9223|9224|9225|9226)'
```

Tu devrais voir quelque chose comme:
```
tcp        0      0 127.0.0.1:9222          0.0.0.0:*               LISTEN      12345/sshd: hacker
tcp        0      0 127.0.0.1:9223          0.0.0.0:*               LISTEN      12346/sshd: hacker
tcp        0      0 127.0.0.1:9224          0.0.0.0:*               LISTEN      12347/sshd: hacker
tcp        0      0 127.0.0.1:9225          0.0.0.0:*               LISTEN      12348/sshd: hacker
tcp        0      0 127.0.0.1:9226          0.0.0.0:*               LISTEN      12349/sshd: hacker
```

### 3. Tester la Connexion Chrome DevTools

```bash
# Test avec curl
curl http://localhost:9222/json/version

# Devrait retourner du JSON avec les infos Chrome:
{
  "Browser": "Chrome/131.0.6778.140",
  "Protocol-Version": "1.3",
  "User-Agent": "Mozilla/5.0...",
  "V8-Version": "13.1.201.13",
  "WebKit-Version": "537.36",
  "webSocketDebuggerUrl": "ws://localhost:9222/devtools/browser/..."
}
```

---

## Utilisation avec Puppeteer

### Script de Test Basique

Crée un fichier `test-chrome.js`:

```javascript
const puppeteer = require('puppeteer-core');

async function testConnection(port, projectName) {
    console.log(`\n🔍 Testing ${projectName} on port ${port}...`);

    try {
        const browser = await puppeteer.connect({
            browserURL: `http://localhost:${port}`,
            defaultViewport: null
        });

        const pages = await browser.pages();
        console.log(`✅ Connected to ${projectName}!`);
        console.log(`📄 Found ${pages.length} open tabs`);

        // Lister les URLs des tabs
        for (let i = 0; i < pages.length; i++) {
            const url = pages[i].url();
            console.log(`   Tab ${i + 1}: ${url}`);
        }

        await browser.disconnect();
    } catch (error) {
        console.log(`❌ Failed to connect to ${projectName}: ${error.message}`);
    }
}

async function main() {
    console.log('🚀 Testing all Chrome Remote Pro connections...\n');

    await testConnection(9222, 'Simono');
    await testConnection(9223, 'Dafnck');
    await testConnection(9224, 'Gluten Libre');
    await testConnection(9225, 'Dentistry');
    await testConnection(9226, 'Agentik OS');

    console.log('\n✨ Test complete!');
}

main();
```

Exécute le test:

```bash
node test-chrome.js
```

### Exemple d'Automatisation

Crée un fichier `automate-dentistry.js`:

```javascript
const puppeteer = require('puppeteer-core');

async function automateDentistry() {
    // Connecte-toi au Chrome du projet Dentistry (port 9225)
    const browser = await puppeteer.connect({
        browserURL: 'http://localhost:9225',
        defaultViewport: null
    });

    // Récupère toutes les pages ouvertes
    const pages = await browser.pages();
    console.log(`Connected! Found ${pages.length} tabs`);

    // Crée un nouvel onglet
    const page = await browser.newPage();

    // Navigue vers un site
    await page.goto('https://dentistry.example.com');

    // Interagis avec la page
    await page.type('#username', 'cto.dentistrygpt@gmail.com');
    await page.type('#password', 'your-password');
    await page.click('#login-button');

    console.log('✅ Automated task completed!');

    // Déconnecte (ne ferme PAS le navigateur)
    await browser.disconnect();
}

automateDentistry().catch(console.error);
```

---

## Exemples d'Utilisation par Projet

### 1. Simono (Port 9222) - Compte Personnel

```javascript
const browser = await puppeteer.connect({
    browserURL: 'http://localhost:9222',
    defaultViewport: null
});

// Session Google de simono.gareth@gmail.com déjà active
const page = await browser.newPage();
await page.goto('https://mail.google.com');
// Déjà connecté automatiquement!
```

### 2. Dafnck (Port 9223) - Projet Studio

```javascript
const browser = await puppeteer.connect({
    browserURL: 'http://localhost:9223',
    defaultViewport: null
});

// Session de studio@dafnck.com déjà active
const page = await browser.newPage();
await page.goto('https://console.cloud.google.com');
```

### 3. Gluten Libre (Port 9224)

```javascript
const browser = await puppeteer.connect({
    browserURL: 'http://localhost:9224',
    defaultViewport: null
});

// Session de tech.glutenlibre@gmail.com déjà active
```

### 4. Dentistry (Port 9225)

```javascript
const browser = await puppeteer.connect({
    browserURL: 'http://localhost:9225',
    defaultViewport: null
});

// Session de cto.dentistrygpt@gmail.com déjà active
```

### 5. Agentik OS (Port 9226)

```javascript
const browser = await puppeteer.connect({
    browserURL: 'http://localhost:9226',
    defaultViewport: null
});

// Session de x@agentik-os.com déjà active
// Note: Ce profil a aussi studio@dafnck.com
```

---

## Debugging et Troubleshooting

### Vérifier les Connexions

```bash
# Sur le VPS - Voir les tunnels SSH actifs
ps aux | grep ssh | grep 9222

# Tester un port spécifique
curl http://localhost:9222/json/version

# Voir les logs d'erreur SSH (si problème)
tail -f /tmp/chrome-remote-*-error.log
```

### Problèmes Courants

#### 1. Port non accessible

**Symptôme**: `Failed to connect to localhost:9222`

**Solution**:
- Vérifie que Chrome Remote Pro est lancé sur ton Mac
- Vérifie que le projet spécifique est bien démarré (bouton ▶️)
- Vérifie le tunnel SSH: `ps aux | grep "ssh.*-R.*9222"`

#### 2. Tunnel SSH mort

**Symptôme**: Status "Tunnel" rouge dans l'app

**Solution**:
- Arrête et relance le projet
- Vérifie la connexion SSH manuellement:
  ```bash
  ssh -i ~/.ssh/id_rsa_vps_chrome -p 42820 hacker@72.61.197.216
  ```

#### 3. Sessions Google pas actives

**Symptôme**: Chrome demande de se reconnecter

**Solution**:
- Assure-toi que Chrome normal est fermé avant de lancer les projets
- Ferme Chrome normal: `pkill -f "Google Chrome.app" | grep -v "remote-debugging-port"`
- Relance les projets

---

## Configuration SSH (Pour Référence)

### Sur ton Mac Local

Le fichier `~/.chrome_remote_pro_config.json` contient:

```json
{
  "sshKeyPath": "~/.ssh/id_rsa_vps_chrome",
  "sshPort": 42820,
  "sshHost": "72.61.197.216",
  "sshUser": "hacker"
}
```

### Commande SSH Complète Générée

Quand tu lances un projet (ex: Dentistry port 9225), l'app exécute:

```bash
ssh -f -N \
    -i ~/.ssh/id_rsa_vps_chrome \
    -R 9225:localhost:9225 \
    -p 42820 \
    -o ServerAliveInterval=60 \
    -o ServerAliveCountMax=3 \
    -o StrictHostKeyChecking=no \
    hacker@72.61.197.216
```

**Explications**:
- `-f`: Background
- `-N`: Pas de commande (juste le tunnel)
- `-R 9225:localhost:9225`: Reverse tunnel (Mac → VPS)
- `-o ServerAliveInterval=60`: Keep-alive toutes les 60s
- `-o ServerAliveCountMax=3`: Reconnecte après 3 échecs

---

## Utilisation depuis un Autre Ordinateur

Si tu veux installer Chrome Remote Pro sur un autre ordinateur:

### 1. Copier les Fichiers

Sur le nouvel ordinateur:

```bash
# Copie le dossier source
scp -r user@old-mac:~/ChromeRemotePro ~/ChromeRemotePro

# Copie la clé SSH
scp user@old-mac:~/.ssh/id_rsa_vps_chrome ~/.ssh/
chmod 600 ~/.ssh/id_rsa_vps_chrome

# Copie le script d'installation
scp user@old-mac:~/install_chrome_remote_pro.sh ~/
```

### 2. Installer

```bash
bash ~/install_chrome_remote_pro.sh
```

### 3. Configurer tes Profils Chrome

L'app détectera automatiquement les profils Chrome disponibles sur ce nouveau Mac. Tu peux:

- Utiliser les mêmes profils Chrome (si synchronisés via Google Sync)
- Ou créer de nouveaux projets avec les profils locaux

Les ports restent les mêmes (9222-9226), donc tes scripts VPS continuent de fonctionner!

---

## Monitoring et Logs

### Logs SSH sur le VPS

```bash
# Voir les connexions SSH actives
sudo tail -f /var/log/auth.log | grep hacker

# Voir les tunnels actifs
ss -tlnp | grep -E '(9222|9223|9224|9225|9226)'
```

### Sur ton Mac

```bash
# Voir les processus Chrome avec debugging
ps aux | grep "remote-debugging-port"

# Voir les tunnels SSH actifs
ps aux | grep "ssh.*-R"

# Logs d'erreur SSH (créés par l'app)
tail -f /tmp/chrome-remote-*-error.log
```

---

## Sécurité

### Points de Sécurité Actuels

✅ **Bon:**
- Utilise une clé SSH dédiée (`id_rsa_vps_chrome`)
- Port SSH custom (42820, pas 22)
- Tunnels en localhost seulement sur le VPS (pas exposés publiquement)

⚠️ **À Considérer:**

Pour renforcer la sécurité si nécessaire:

1. **Ajouter un mot de passe à la clé SSH:**
   ```bash
   ssh-keygen -p -f ~/.ssh/id_rsa_vps_chrome
   ```

2. **Limiter les IPs autorisées sur le VPS** (dans `/etc/ssh/sshd_config`):
   ```
   AllowUsers hacker@ton-ip-fixe
   ```

3. **Activer fail2ban sur le VPS:**
   ```bash
   sudo apt-get install fail2ban
   ```

---

## Résumé des Commandes Essentielles

### Sur ton Mac

```bash
# Lancer l'app
open ~/Applications/Chrome\ Remote\ Pro.app

# Ou depuis le LaunchPad
# Recherche "Chrome Remote Pro"

# Fermer Chrome normal d'abord (automatique maintenant)
# L'app le fait automatiquement quand tu lances les projets

# Vérifier la config
cat ~/.chrome_remote_pro_config.json | python3 -m json.tool
```

### Sur le VPS

```bash
# Se connecter
ssh -i ~/.ssh/id_rsa_vps_chrome -p 42820 hacker@72.61.197.216

# Tester les connexions
curl http://localhost:9222/json/version
curl http://localhost:9223/json/version
curl http://localhost:9224/json/version
curl http://localhost:9225/json/version
curl http://localhost:9226/json/version

# Lancer un script Puppeteer
node test-chrome.js
```

---

## Support

Si tu rencontres des problèmes:

1. **Vérifie les status dans l'app** (Chrome, Tunnel, VPS)
2. **Regarde les logs SSH**: `/tmp/chrome-remote-*-error.log`
3. **Teste la connexion SSH manuellement**
4. **Vérifie que Chrome normal est bien fermé**

---

## Prochaines Étapes

Tu es prêt! Tu peux maintenant:

1. ✅ Lancer Chrome Remote Pro depuis le LaunchPad
2. ✅ Cliquer sur "Start All" pour lancer tes 5 projets
3. ✅ Te connecter au VPS
4. ✅ Utiliser Puppeteer pour contrôler tes Chrome

**Toutes tes sessions Google sont déjà actives et prêtes!**
