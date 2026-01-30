# Prompt pour Claude AI sur le VPS

Copie-colle ce prompt complet à Claude AI quand tu es connecté sur ton VPS pour configurer automatiquement tout le système Chrome Remote Pro.

---

## 📋 PROMPT À ENVOYER À CLAUDE AI

```
Salut Claude! Je dois configurer mon VPS pour recevoir des connexions Chrome Remote Pro depuis mon Mac.

# ARCHITECTURE

Je lance Chrome Remote Pro sur mon Mac local. Cette application:
- Lance 5 instances Chrome avec remote debugging
- Crée des tunnels SSH reverse vers ce VPS
- Expose les ports Chrome locaux (9222-9226) sur ce VPS en localhost

# MES 5 PROJETS

Voici mes 5 projets Chrome configurés:

1. **Simono** (Port 9222)
   - Profil Chrome: Default
   - Email Google: simono.gareth@gmail.com
   - Compte personnel principal

2. **Dafnck** (Port 9223)
   - Profil Chrome: Profile 1
   - Email Google: studio@dafnck.com
   - Projet Dafnck Studio

3. **Gluten Libre** (Port 9224)
   - Profil Chrome: Profile 6
   - Email Google: tech.glutenlibre@gmail.com
   - Projet Gluten Libre

4. **Dentistry** (Port 9225)
   - Profil Chrome: Profile 15
   - Email Google: cto.dentistrygpt@gmail.com
   - Projet Dentistry

5. **Agentik OS** (Port 9226)
   - Profil Chrome: Profile 17
   - Email Google: x@agentik-os.com (+ studio@dafnck.com)
   - Projet Agentik (ce profil a 2 comptes Google)

# CONNEXION SSH

- Host actuel: 72.61.197.216
- Port SSH: 42820
- User: hacker
- Clé SSH: ~/.ssh/id_rsa_vps_chrome

Les tunnels SSH reverse sont établis automatiquement par l'app Mac.

# CE QUE JE VEUX QUE TU FASSES

1. **Setup initial complet:**
   - Vérifie et installe Node.js (version 20+) si nécessaire
   - Crée le répertoire ~/chrome-remote-control
   - Installe puppeteer-core
   - Installe tous les autres outils nécessaires (curl, jq, etc.)

2. **Scripts de test:**
   - Crée un script `test-connections.js` qui teste les 5 ports
   - Crée un script `list-tabs.sh` qui liste tous les tabs ouverts sur chaque projet
   - Crée un script `check-tunnels.sh` qui vérifie que les tunnels SSH sont actifs

3. **Scripts d'automatisation par projet:**
   - Crée un dossier `~/chrome-remote-control/scripts/` avec 5 sous-dossiers (simono, dafnck, glutenlibre, dentistry, agentik)
   - Dans chaque dossier, crée un script exemple qui se connecte au Chrome correspondant

4. **Configuration Claude AI:**
   - Crée un fichier `~/chrome-remote-control/config.json` avec toute la configuration
   - Crée un fichier `~/chrome-remote-control/README.md` qui explique comment utiliser chaque script

5. **Monitoring:**
   - Crée un script `monitor.sh` qui affiche en temps réel l'état des 5 connexions

# FORMAT ATTENDU

Pour chaque script que tu crées:
- Ajoute des commentaires clairs
- Utilise des console.log avec des émojis pour la lisibilité
- Gère les erreurs proprement
- Documente les paramètres si nécessaire

# EXEMPLE DE CE QUE JE VEUX

Par exemple, `test-connections.js` devrait:
```javascript
const puppeteer = require('puppeteer-core');

const projects = [
    { name: 'Simono', port: 9222, email: 'simono.gareth@gmail.com' },
    { name: 'Dafnck', port: 9223, email: 'studio@dafnck.com' },
    { name: 'Gluten Libre', port: 9224, email: 'tech.glutenlibre@gmail.com' },
    { name: 'Dentistry', port: 9225, email: 'cto.dentistrygpt@gmail.com' },
    { name: 'Agentik OS', port: 9226, email: 'x@agentik-os.com' }
];

async function testProject(project) {
    console.log(`\n🔍 Testing ${project.name} (${project.email})...`);

    try {
        const browser = await puppeteer.connect({
            browserURL: `http://localhost:${project.port}`,
            defaultViewport: null
        });

        const pages = await browser.pages();
        console.log(`   ✅ Connected! Found ${pages.length} tabs`);

        await browser.disconnect();
        return true;
    } catch (error) {
        console.log(`   ❌ Failed: ${error.message}`);
        return false;
    }
}

async function main() {
    console.log('🚀 Testing Chrome Remote Pro connections...\n');
    console.log('=' .repeat(50));

    let successCount = 0;

    for (const project of projects) {
        const success = await testProject(project);
        if (success) successCount++;
    }

    console.log('\n' + '='.repeat(50));
    console.log(`\n✨ Results: ${successCount}/${projects.length} projects accessible\n`);

    if (successCount === projects.length) {
        console.log('🎉 All connections working perfectly!');
    } else if (successCount > 0) {
        console.log('⚠️  Some connections failed - check if Chrome Remote Pro is running on Mac');
    } else {
        console.log('❌ No connections available - Chrome Remote Pro might not be running');
    }
}

main();
```

# STRUCTURE FINALE ATTENDUE

Après ton setup, je veux avoir cette structure:

```
~/chrome-remote-control/
├── config.json
├── README.md
├── package.json
├── node_modules/
├── test-connections.js
├── list-tabs.sh
├── check-tunnels.sh
├── monitor.sh
└── scripts/
    ├── simono/
    │   ├── example.js
    │   └── README.md
    ├── dafnck/
    │   ├── example.js
    │   └── README.md
    ├── glutenlibre/
    │   ├── example.js
    │   └── README.md
    ├── dentistry/
    │   ├── example.js
    │   └── README.md
    └── agentik/
        ├── example.js
        └── README.md
```

# EXEMPLES D'AUTOMATISATION

Pour m'aider, voici des exemples de ce que je veux pouvoir faire:

**Exemple 1: Ouvrir Gmail sur Dentistry**
```javascript
const browser = await puppeteer.connect({ browserURL: 'http://localhost:9225' });
const page = await browser.newPage();
await page.goto('https://mail.google.com');
// Session de cto.dentistrygpt@gmail.com déjà active!
```

**Exemple 2: Lister tous les tabs de Simono**
```bash
curl -s http://localhost:9222/json | jq -r '.[] | "\(.title) - \(.url)"'
```

**Exemple 3: Créer un nouveau tab sur Gluten Libre**
```javascript
const browser = await puppeteer.connect({ browserURL: 'http://localhost:9224' });
const page = await browser.newPage();
await page.goto('https://example.com');
await browser.disconnect(); // Disconnect, ne ferme PAS le browser!
```

# IMPORTANT

- Les sessions Google sont DÉJÀ actives dans chaque Chrome (pas besoin de login)
- Utilise TOUJOURS `browser.disconnect()`, JAMAIS `browser.close()`
- Les ports sont en localhost sur ce VPS (pas exposés publiquement)
- Si les connexions échouent, c'est probablement que Chrome Remote Pro n'est pas lancé sur le Mac

# MONITORING

Le script `monitor.sh` devrait afficher quelque chose comme:

```
🔍 Chrome Remote Pro - Connection Monitor

Simono (9222):       ✅ Active - 5 tabs - cto.dentistrygpt@gmail.com
Dafnck (9223):       ✅ Active - 3 tabs - studio@dafnck.com
Gluten Libre (9224): ✅ Active - 7 tabs - tech.glutenlibre@gmail.com
Dentistry (9225):    ✅ Active - 12 tabs - cto.dentistrygpt@gmail.com
Agentik OS (9226):   ❌ Inactive

Status: 4/5 projects connected
Last update: 2026-01-30 14:30:45
```

# CONFIGURATION SYSTÈME

Si tu as besoin de vérifier la config système:
- OS: Probablement Ubuntu/Debian
- J'ai accès sudo si nécessaire
- Node.js doit être installé (ou tu l'installes)
- curl et jq devraient être disponibles

# QUESTIONS

Si tu as besoin de clarifications avant de commencer le setup:
1. Demande-moi
2. Sinon, fais des choix raisonnables et documente-les dans le README

# ACTION

Maintenant, fais le setup complet! Commence par vérifier l'environnement, installe ce qui manque, et crée tous les fichiers et scripts nécessaires.

Documente chaque étape et explique-moi ce que tu fais.

Prêt? Go! 🚀
```

---

## 📝 NOTES POUR TOI

### Quand Utiliser ce Prompt

**Situations:**
1. Premier setup du VPS
2. Après un changement d'IP du Mac (l'app a un bouton "Reconnect VPS" maintenant)
3. Si tu réinstalles le VPS
4. Si tu veux ajouter de nouveaux scripts d'automatisation

### Customisation du Prompt

Si tu veux que Claude fasse quelque chose de spécifique, ajoute une section au prompt:

**Exemple - Ajouter un script spécifique:**
```
# SCRIPT ADDITIONNEL

Je veux aussi un script qui:
- Se connecte au Chrome de Dentistry
- Ouvre automatiquement mon dashboard
- Fait une capture d'écran
- Envoie la capture sur Slack

Crée ce script dans ~/chrome-remote-control/scripts/dentistry/auto-screenshot.js
```

### Après le Setup

Une fois que Claude a tout setup sur le VPS, tu peux:

1. **Tester les connexions:**
```bash
cd ~/chrome-remote-control
node test-connections.js
```

2. **Lister les tabs:**
```bash
./list-tabs.sh
```

3. **Monitorer en temps réel:**
```bash
./monitor.sh
```

4. **Utiliser les scripts par projet:**
```bash
cd ~/chrome-remote-control/scripts/dentistry
node example.js
```

### Variables à Remplacer

Si ta configuration change, modifie ces valeurs dans le prompt:

| Variable | Valeur Actuelle | Description |
|----------|----------------|-------------|
| Host VPS | 72.61.197.216 | IP du VPS |
| Port SSH | 42820 | Port SSH custom |
| User | hacker | Utilisateur SSH |
| Clé SSH | ~/.ssh/id_rsa_vps_chrome | Chemin de la clé |

### Si l'IP du Mac Change

L'app Chrome Remote Pro a maintenant un bouton "Reconnect VPS" (icône de rotation).

**Quand l'utiliser:**
- Après un redémarrage du Mac
- Si tu changes de réseau WiFi
- Si les tunnels ne fonctionnent plus

**Ce que fait le bouton:**
1. Détecte la nouvelle IP locale
2. Arrête tous les projets
3. Relance tous les projets avec les nouveaux tunnels
4. Affiche une notification avec la nouvelle IP

**Sur le VPS:**
Rien à faire! Les tunnels SSH reverse se reconnectent automatiquement.

---

## 🔄 Workflow Complet

### 1. Premier Setup (Une fois)

**Sur le VPS:**
```bash
# Connecte-toi
ssh -i ~/.ssh/id_rsa_vps_chrome -p 42820 hacker@72.61.197.216

# Lance Claude AI (ou utilise cette conversation)
# Colle le prompt ci-dessus

# Attends que Claude setup tout
# Vérifie que tout fonctionne
cd ~/chrome-remote-control
node test-connections.js
```

### 2. Utilisation Quotidienne

**Sur ton Mac:**
```bash
# Lance Chrome Remote Pro (LaunchPad ou menu bar)
# Clique sur "Start All"
# L'app affiche ton IP locale dans le header
```

**Sur le VPS:**
```bash
# Les ports sont automatiquement disponibles
curl http://localhost:9222/json/version
curl http://localhost:9223/json/version
# etc.

# Lance tes automatisations
cd ~/chrome-remote-control
node test-connections.js
```

### 3. Si l'IP Change

**Sur ton Mac:**
```bash
# Dans Chrome Remote Pro
# Clique sur l'icône de rotation (Reconnect VPS)
# Attends 10 secondes
# Tout est reconnecté!
```

**Sur le VPS:**
```bash
# Les tunnels se reconnectent automatiquement
# Vérifie avec:
./check-tunnels.sh
```

---

## 💡 Exemples de Tâches à Demander à Claude VPS

Une fois le setup fait, tu peux demander à Claude sur le VPS:

### Exemple 1: Script d'Automatisation
```
"Crée-moi un script qui se connecte au Chrome de Dentistry,
ouvre 5 nouveaux onglets avec différentes URLs de mon dashboard,
et arrange les fenêtres côte à côte"
```

### Exemple 2: Monitoring Avancé
```
"Modifie monitor.sh pour qu'il m'envoie une notification
Slack si un des projets se déconnecte"
```

### Exemple 3: Extraction de Données
```
"Crée un script qui se connecte à tous les Gmail de mes 5 projets
et extrait le nombre d'emails non lus"
```

### Exemple 4: Screenshot Automatique
```
"Crée un cron job qui prend une capture d'écran du dashboard
Dentistry toutes les heures et les sauvegarde dans ~/screenshots/"
```

---

## 🔒 Sécurité

### Points de Sécurité

Le prompt et le setup respectent:
- ✅ Tunnels en localhost seulement (pas exposés publiquement)
- ✅ Utilisation de clé SSH dédiée
- ✅ Port SSH custom (42820)
- ✅ Pas de credentials hardcodés

### Renforcement (Optionnel)

Si tu veux renforcer la sécurité:

**1. Firewall sur le VPS:**
```bash
# Bloquer tous les ports sauf SSH
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 42820/tcp
sudo ufw enable
```

**2. Fail2ban:**
```bash
sudo apt-get install fail2ban
sudo systemctl enable fail2ban
```

**3. Rotation des Clés SSH:**
```bash
# Tous les 6 mois, régénère la clé
ssh-keygen -t ed25519 -f ~/.ssh/id_rsa_vps_chrome_new
# Puis update dans l'app
```

---

## 📊 Dashboard Suggéré

Demande à Claude de créer un dashboard web simple:

```
"Crée-moi un dashboard web simple (HTML+JS) qui:
- Affiche l'état de mes 5 projets Chrome
- Montre le nombre de tabs par projet
- Permet de lancer des automatisations prédéfinies
- Tourne sur http://localhost:3000
"
```

Tu pourras ensuite y accéder depuis ton Mac via un tunnel SSH forward:
```bash
ssh -i ~/.ssh/id_rsa_vps_chrome -p 42820 -L 3000:localhost:3000 hacker@72.61.197.216
# Puis ouvre http://localhost:3000 dans ton browser
```

---

## ✨ Résumé

**Ce que fait le prompt:**
1. ✅ Setup complet de l'environnement VPS
2. ✅ Installation de tous les outils nécessaires
3. ✅ Création de scripts de test et monitoring
4. ✅ Structure de dossiers organisée par projet
5. ✅ Documentation complète
6. ✅ Exemples d'automatisation pour chaque projet

**Ce que tu dois faire:**
1. Te connecter au VPS
2. Coller le prompt à Claude AI
3. Attendre que Claude setup tout
4. Tester avec `node test-connections.js`
5. Profiter! 🚀

**En cas de problème:**
- Vérifie que Chrome Remote Pro est lancé sur ton Mac
- Clique sur "Reconnect VPS" si l'IP a changé
- Lance `./check-tunnels.sh` sur le VPS
- Regarde les logs SSH: `tail -f /tmp/chrome-remote-*-error.log`

**Ton Chrome Remote Pro est maintenant:**
- ✅ Affiche l'IP locale dans le header
- ✅ Affiche l'IP du VPS
- ✅ Bouton "Reconnect VPS" pour reconfigurer automatiquement
- ✅ Bouton "Refresh" pour mettre à jour les status
- ✅ Ferme automatiquement Chrome normal au lancement
- ✅ Prêt pour une automatisation complète depuis le VPS!

🎉 **Setup terminé!**
