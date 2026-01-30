# Chrome Remote Pro - Quick Start

## Installation (1 minute)

```bash
curl -fsSL https://your-website.com/install.sh | bash
```

## Usage (3 steps)

1. **Launch the app** from LaunchPad
2. **Click "Start All"** to launch your Chrome instances
3. **Click port badges** (↗️ :9222) to open Chrome windows

## Your Google Sessions Are Ready!

All your Google logins are automatically preserved. Just open Gmail, Drive, or any Google service - you're already connected!

## Remote Control

From your VPS:

```javascript
const puppeteer = require('puppeteer-core');
const browser = await puppeteer.connect({
    browserURL: 'http://localhost:9222'
});

// Your Google session is active! Automate away!
```

## Documentation

- Full README: [README.md](README.md)
- VPS Setup: [docs/VPS_SETUP_GUIDE.md](docs/VPS_SETUP_GUIDE.md)
- Troubleshooting: [docs/CHROME_SESSIONS_GUIDE.md](docs/CHROME_SESSIONS_GUIDE.md)

## Support

- Email: support@your-website.com
- GitHub: https://github.com/yourusername/chrome-remote-pro

Happy automating! 🚀
