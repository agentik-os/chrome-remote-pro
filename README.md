# Chrome Remote Pro

Control Chrome browsers remotely with Google sessions preserved. Perfect for automation, testing, and remote browser management.

![Version](https://img.shields.io/badge/version-2.1.0-blue)
![Platform](https://img.shields.io/badge/platform-macOS%2011%2B-lightgrey)
![License](https://img.shields.io/badge/license-MIT-green)

## 🚀 Quick Install

### One-Line Install (Recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/Agentik-OS/chrome-remote-pro/main/install.sh | bash
```

### Manual Install

1. Download [ChromeRemotePro-v2.0.0.dmg](https://github.com/Agentik-OS/chrome-remote-pro/releases/latest)
2. Open the DMG
3. Drag **Chrome Remote Pro** to Applications
4. Launch from Launchpad

## ✨ Features

### 🖥️ Remote Browser Control
- Control multiple Chrome instances simultaneously
- Each project gets its own dedicated Chrome profile
- Google sessions automatically preserved (no re-login!)
- Access from anywhere via SSH tunnels

### 🔐 Secure SSH Management
- **One-click SSH key generation** (no terminal needed!)
- Built-in SSH key manager with copy-paste instructions
- Test VPS connection before saving
- Complete troubleshooting guide included

### 🤖 Claude Code Integration
- **Auto-generates setup prompts** with your config
- Includes VPS IP, projects, SSH instructions
- One-click copy to clipboard
- Claude does ALL the VPS setup automatically!

### 📊 Real-Time Monitoring
- Visual status for Chrome, Tunnel, and VPS
- Color-coded indicators (green/red/orange)
- Live connection monitoring
- Automatic reconnection on IP change

### 🎨 Clean macOS Design
- Native SwiftUI interface
- Menu bar application (no Dock icon)
- Dark mode optimized
- Minimal and powerful

## 🎯 Use Cases

- **Web Automation**: Run Puppeteer scripts on remote Chrome with your Google sessions
- **Testing**: Test across multiple Google accounts simultaneously
- **Remote Work**: Access your Chrome sessions from anywhere
- **AI Development**: Perfect for Claude Code and AI-powered automation
- **Multi-Account Management**: Manage multiple Google accounts effortlessly

## 📖 How It Works

1. **Launch Chrome Remote Pro** on your Mac
2. **Add Projects**: Each project = one Chrome profile + one port
3. **Start Projects**: Chrome launches in debug mode with your Google sessions
4. **SSH Tunnels**: Automatically created to your VPS
5. **Remote Control**: Use Puppeteer from your VPS to control your local Chrome!

## 🔧 Setup Guide

### Step 1: Install the App

```bash
curl -fsSL https://raw.githubusercontent.com/Agentik-OS/chrome-remote-pro/main/install.sh | bash
```

Or download the DMG manually.

### Step 2: Configure VPS (Optional)

On first launch, you'll see a setup wizard:
- **VPS Host**: Your VPS IP (e.g., 192.168.1.100)
- **SSH Port**: Usually 22 or custom
- **SSH User**: Your VPS username
- **SSH Key**: Path to your private key

Or click **"Skip for Now"** to use locally only.

### Step 3: Generate SSH Key

In Settings (⚙️):
1. Click **"Generate New SSH Key"**
2. Copy the public key shown
3. Add it to your VPS:
```bash
ssh your-user@your-vps
echo "[paste your key]" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```
4. Test the connection!

### Step 4: Setup VPS with Claude Code

1. Open Settings → **"Generate & Copy Prompt"**
2. SSH to your VPS and launch Claude Code
3. Paste the prompt
4. Claude will automatically:
   - Install Node.js and Puppeteer
   - Create test scripts
   - Setup monitoring tools
   - Generate examples for each project

### Step 5: Add Projects

1. Click **"Add"** in the app
2. Name your project (e.g., "Personal Gmail")
3. Select Chrome profile (your Google sessions are here!)
4. Choose a port (9222, 9223, etc.)
5. Click **"Start"**!

## 💻 VPS Setup (Automated)

Chrome Remote Pro generates a **complete Claude Code prompt** that sets up your VPS automatically.

What it creates on your VPS:
```
~/chrome-remote-control/
├── config.json              # Your projects configuration
├── package.json             # Node dependencies
├── test-connections.js      # Test all Chrome connections
├── monitor.sh               # Real-time status monitoring
├── check-tunnels.sh         # Verify SSH tunnels
└── scripts/
    ├── project1/
    │   ├── example.js       # Puppeteer example
    │   └── README.md
    ├── project2/
    └── ...
```

## 📝 Example Puppeteer Script

```javascript
const puppeteer = require('puppeteer-core');

async function automateTask() {
    const browser = await puppeteer.connect({
        browserURL: 'http://localhost:9222',
        defaultViewport: null
    });

    const pages = await browser.pages();
    console.log(`Connected! Found ${pages.length} tabs`);

    const page = await browser.newPage();
    await page.goto('https://gmail.com');

    // Your automation here - Google session is already active!

    await browser.disconnect(); // NEVER use close()!
}

automateTask();
```

## 🔒 Security

- **No VPS hardcoded** in the app
- **SSH keys locally generated** and managed
- **Localhost tunnels only** (ports not exposed)
- **No data collection** or tracking
- **Open source** - verify the code yourself

## 🛠️ Requirements

**Mac:**
- macOS 11.0 or later
- Google Chrome installed
- SSH access (for remote features)

**VPS (Optional):**
- Linux server with SSH access
- Node.js 20+ (auto-installed by Claude Code)
- Puppeteer-core (auto-installed)

## 📚 Documentation

- [VPS Setup Guide](docs/VPS_SETUP_GUIDE.md) - Complete VPS configuration
- [Chrome Sessions Guide](docs/CHROME_SESSIONS_GUIDE.md) - Understanding Chrome profiles
- [Claude Code Integration](docs/CLAUDE_AI_INTEGRATION.md) - AI-powered automation

## ❓ FAQ

**Q: Do I need a VPS?**
A: No! You can use Chrome Remote Pro locally only. VPS is for remote access.

**Q: Will my Google sessions stay logged in?**
A: Yes! Chrome Remote Pro uses your actual Chrome profiles, so all sessions are preserved.

**Q: Can I use this for multiple Google accounts?**
A: Yes! Each project can use a different Chrome profile with different Google accounts.

**Q: Is this safe?**
A: Yes. All connections are SSH tunnels (localhost only), and your data never leaves your machine except through your encrypted SSH connection.

**Q: Do I need to know SSH/Terminal commands?**
A: No! Chrome Remote Pro has one-click SSH key generation and guides you through everything.

## 🐛 Troubleshooting

**Chrome won't start:**
- Make sure normal Chrome is closed first
- Chrome can only use one profile at a time

**Connection failed:**
- Test your VPS connection in Settings
- Verify SSH key is added to VPS
- Check VPS IP and port

**Google sessions not preserved:**
- Make sure you selected the correct Chrome profile
- Don't use "Guest" or "Profile 0" (they reset)

## 🤝 Contributing

Contributions welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) first.

## 📄 License

MIT License - see [LICENSE](LICENSE) for details.

## 🙏 Credits

Built with:
- SwiftUI (macOS native interface)
- Puppeteer (browser automation)
- Chrome DevTools Protocol
- SSH tunneling

## 📞 Support

- [GitHub Issues](https://github.com/Agentik-OS/chrome-remote-pro/issues)
- [Documentation](docs/)

## 🔗 Links

- [Website](https://agentik-os.com)
- [GitHub](https://github.com/Agentik-OS/chrome-remote-pro)
- [Releases](https://github.com/Agentik-OS/chrome-remote-pro/releases)

---

Made with ❤️ for the automation community

**Star ⭐ this repo if you find it useful!**
