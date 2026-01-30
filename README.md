# Chrome Remote Pro

**Control your Chrome browsers remotely with Google sessions preserved!**

Chrome Remote Pro is a macOS menu bar application that allows you to:
- Launch multiple Chrome instances with different profiles
- Access them remotely via SSH tunnels
- Keep all your Google sessions active
- Control browsers with Puppeteer from a remote VPS

Perfect for automation, testing, and managing multiple Google accounts!

---

## ✨ Features

- 🚀 **Launch multiple Chrome profiles** - Use up to 10 different Chrome profiles simultaneously
- 🔐 **Google sessions preserved** - All cookies, passwords, and logins are automatically available
- 🌐 **Remote access** - Control your browsers from anywhere via SSH tunnels
- 🤖 **Puppeteer-ready** - Full Chrome DevTools Protocol support
- 🎨 **Clean dark interface** - Minimalist menu bar app
- 📊 **Real-time monitoring** - See Chrome, tunnel, and VPS status for each project
- ⚡ **One-click window opening** - Click port badge to open Chrome windows
- 🔄 **Auto-reconnect** - Automatically handles IP changes

---

## 🖥️ System Requirements

- **macOS 11.0+** (Big Sur or later)
- **Google Chrome** installed
- **Xcode Command Line Tools** (for compilation)
- **SSH access to a VPS** (optional, for remote control)

---

## 📦 Installation

### Quick Install (One Command)

```bash
curl -fsSL https://your-website.com/install.sh | bash
```

### Manual Installation

1. **Download the installer:**
   ```bash
   curl -O https://your-website.com/chrome-remote-pro-installer.sh
   chmod +x chrome-remote-pro-installer.sh
   ```

2. **Run the installer:**
   ```bash
   ./chrome-remote-pro-installer.sh
   ```

3. **Follow the prompts:**
   - Select how many projects you want
   - Choose Chrome profiles for each project
   - Configure VPS settings (optional)

4. **Launch the app:**
   - Open LaunchPad
   - Search for "Chrome Remote Pro"
   - Click to launch

---

## 🚀 Quick Start

### 1. Launch the App

Open Chrome Remote Pro from your menu bar (top right corner).

### 2. Configure Projects

The app automatically detects your Chrome profiles. During installation, you'll have configured your projects.

### 3. Start Projects

Click **"Start All"** to launch all your Chrome instances with their profiles.

### 4. Open Chrome Windows

Click the **↗️ port badge** (e.g., ↗️ :9222) to open a Chrome window.

**Result:** Chrome opens with your Google session already active!

---

## 📖 Usage Examples

### Example 1: Personal Account (Port 9222)

```bash
# In Chrome Remote Pro, click ↗️ :9222
# Chrome opens with your personal Google account
# Go to https://mail.google.com
# You're already logged in!
```

### Example 2: Work Account (Port 9223)

```bash
# Click ↗️ :9223
# Chrome opens with your work Google account
# Access company Gmail, Drive, etc.
# Everything is ready!
```

### Example 3: Remote Automation with Puppeteer

```javascript
const puppeteer = require('puppeteer-core');

// Connect to Chrome on port 9222 (via SSH tunnel)
const browser = await puppeteer.connect({
    browserURL: 'http://localhost:9222',
    defaultViewport: null
});

// Your Google session is already active!
const page = await browser.newPage();
await page.goto('https://mail.google.com');

// Automate Gmail, Drive, Calendar, etc.
// No need to login!

await browser.disconnect();
```

---

## 🔧 Configuration

### Config File Location

```
~/.chrome_remote_pro_config.json
```

### Example Configuration

```json
{
  "sshKeyPath": "~/.ssh/id_rsa",
  "sshPort": 22,
  "sshHost": "your-vps-ip",
  "sshUser": "your-username",
  "projects": [
    {
      "name": "Personal",
      "chromeProfile": "Default",
      "port": 9222
    },
    {
      "name": "Work",
      "chromeProfile": "Profile 1",
      "port": 9223
    }
  ]
}
```

---

## 🌐 Remote Access Setup

### On Your Mac

1. Launch Chrome Remote Pro
2. Click "Start All"
3. Your IP is shown in the app header

### On Your VPS

1. **Install Node.js and Puppeteer:**
   ```bash
   curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
   sudo apt-get install -y nodejs
   npm install puppeteer-core
   ```

2. **Test connection:**
   ```bash
   curl http://localhost:9222/json/version
   ```

3. **Create automation script:**
   ```javascript
   const puppeteer = require('puppeteer-core');

   const browser = await puppeteer.connect({
       browserURL: 'http://localhost:9222'
   });

   // Your automation here!
   ```

---

## 🎨 Interface

### Header

```
🔘 Chrome Remote Pro              🔄
    5 projects

🌐 Local IP: 192.168.1.45    VPS: 72.61.197.216
```

- **🔄 Refresh:** Click to refresh status or reconnect VPS

### Project Card

```
┌─────────────────────────────────────────────┐
│ 🟢 Personal               ↗️ :9222    ▶️   │
│ your.email@gmail.com                        │
│ Chrome 🟢 | Tunnel 🟢 | VPS 🟢             │
└─────────────────────────────────────────────┘
```

- **Status Dot (🟢/🔴/🟠):** Overall project status
- **Port Badge (↗️ :9222):** Click to open Chrome window
- **Play Button (▶️):** Start/stop project
- **Status Bar:** Chrome, Tunnel, and VPS status

---

## 🔍 Troubleshooting

### Problem: "Profile is locked"

**Cause:** Chrome normal is using the profile

**Solution:**
```bash
# Close Chrome completely (Cmd+Q)
# Then launch projects in Chrome Remote Pro
```

The app automatically closes Chrome normal when you click "Start All".

### Problem: Sessions not synchronized

**Cause:** Chrome profiles not accessible

**Solution:**
1. Stop all projects
2. Close Chrome normal completely
3. Click "Start All" again

### Problem: Can't open Chrome window

**Cause:** Project not running

**Solution:**
1. Check if project status is green (🟢)
2. If red, click ▶️ to start
3. Wait 5 seconds
4. Click ↗️ port badge again

---

## 📚 Documentation

- [Installation Guide](https://your-website.com/docs/installation)
- [Configuration Guide](https://your-website.com/docs/configuration)
- [VPS Setup](https://your-website.com/docs/vps-setup)
- [Puppeteer Examples](https://your-website.com/docs/puppeteer)
- [Troubleshooting](https://your-website.com/docs/troubleshooting)

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## ⚠️ Disclaimer

This tool is for legitimate automation purposes only. Always respect:
- Terms of Service of websites you automate
- Google's Terms of Service
- Privacy and security best practices

Use responsibly and at your own risk.

---

## 🙏 Acknowledgments

- Built with SwiftUI and AppKit
- Uses Chrome DevTools Protocol
- Inspired by browser automation needs

---

## 💬 Support

- 📧 Email: support@your-website.com
- 🐦 Twitter: [@yourusername](https://twitter.com/yourusername)
- 💬 Discord: [Join our server](https://discord.gg/yourserver)
- 🐛 Issues: [GitHub Issues](https://github.com/yourusername/chrome-remote-pro/issues)

---

## 🗺️ Roadmap

- [ ] Support for multiple VPS endpoints
- [ ] Built-in Puppeteer script editor
- [ ] Chrome extension sync
- [ ] Scheduled automation tasks
- [ ] Dashboard web interface
- [ ] Windows support (future)

---

## ⭐ Star History

[![Star History Chart](https://api.star-history.com/svg?repos=yourusername/chrome-remote-pro&type=Date)](https://star-history.com/#yourusername/chrome-remote-pro&Date)

---

**Made with ❤️ for browser automation enthusiasts**

🚀 **[Get Started Now](https://your-website.com/install)** 🚀
