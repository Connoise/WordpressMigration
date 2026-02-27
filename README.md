# connoi.se - Static Site Files

Your WordPress site has been successfully converted to static HTML!

## ⚠️ IMPORTANT: Missing Pages

Your current export is from **November 20, 2025**. The following new code project pages are NOT included:
1. Xhungus – Twitter Archive to Obsidian Notes
2. Frog Budget – Budget Tracking and Analysis App
3. Inventorois – Home Inventory App
4. Second Brian – Chat to Obsidian System
5. Chuuning-Byou – Autotune with Harmonic Qualities
6. I'm Bad at Music Theory – Chord Generator and Music Theory Aid

**Action Required:** Export a new WordPress XML file that includes these pages, then re-run the conversion.

## 📦 What's Included

- **25 HTML pages** - All your content from WordPress (current export)
- **1 blog post** - Your "Hello World" post
- **Site metadata** - Complete data in JSON format
- **Media list** - URLs for all 99 media files
- **Migration scripts** - Automated tools for easy migration

## 🚀 Quick Start (Command Line)

### 1. Download Media Files (Required)

```bash
# Make scripts executable (if not already)
chmod +x download_media.sh update_paths.sh

# Download all 99 media files
./download_media.sh

# This will:
# - Download all files from your WordPress site
# - Optionally organize them by type
# - Verify download completion
```

### 2. Update File Paths

```bash
# Update WordPress URLs to local paths
./update_paths.sh

# This will:
# - Create backup of HTML files
# - Replace all WordPress URLs with local paths
# - Verify no broken links
```

### 3. Test Locally

```bash
# Start local web server
python3 -m http.server 8000

# Open browser to: http://localhost:8000
# Test all pages, images, and audio files
```

### 4. Deploy to Hosting

```bash
# Using Netlify (recommended - free)
npm install -g netlify-cli
netlify deploy --prod

# Or use MEDIA_DOWNLOADER.html for browser-based download
# See CLI_MIGRATION_GUIDE.md for other hosting options
```

## 📖 Documentation

**Start Here:**
- `CLI_MIGRATION_GUIDE.md` - Complete step-by-step command line guide
- `MIGRATION_SUMMARY.md` - Quick overview and options

**Tools:**
- `download_media.sh` - Automated media download script
- `update_paths.sh` - Automated path update script
- `MEDIA_DOWNLOADER.html` - Browser-based download tool (alternative)

**Reference:**
- `MEDIA_DOWNLOADER_GUIDE.md` - Media downloader instructions
- `site_metadata.json` - Complete site data

## 📁 Folder Structure

```
connoise_static/
├── index.html                      # Homepage
├── pages/                          # All your pages (25 currently)
│   ├── music.html
│   ├── about.html
│   ├── contact.html
│   └── ...
├── posts/                          # Blog posts
│   └── hello-world.html
├── media/
│   ├── media_urls.txt              # List of 99 media URLs
│   └── downloads/                  # Downloaded files go here
├── download_media.sh               # Media download script ⭐
├── update_paths.sh                 # Path update script ⭐
├── CLI_MIGRATION_GUIDE.md          # Complete CLI guide ⭐
├── MIGRATION_SUMMARY.md            # Quick reference
├── MEDIA_DOWNLOADER.html           # Browser download tool
├── MEDIA_DOWNLOADER_GUIDE.md       # Download guide
└── site_metadata.json              # Site data
```

## ⚡ Complete Workflow

```bash
# 1. Get latest WordPress export (if you have new pages)
#    Go to WordPress: Tools → Export → Download
#    Then: python wordpress_to_static.py NEW_EXPORT.xml connoise_new

# 2. Download media files
./download_media.sh

# 3. Update file paths
./update_paths.sh

# 4. Test locally
python3 -m http.server 8000
# Open http://localhost:8000 in browser

# 5. Deploy
netlify deploy --prod  # or your preferred hosting
```

## 🎯 Your Site

**Site:** Agoe the Idol//connoise  
**Tagline:** our faces are melting like popsicles!  
**Current Pages:** 25 (missing 6 code project pages)  
**Media Files:** 99

## 💡 Key Features

✅ **Automated Scripts** - Download and update with one command  
✅ **Multiple Download Methods** - wget, parallel, aria2c support  
✅ **Automatic Path Detection** - Smart path updating based on file organization  
✅ **Backup Creation** - Automatic backups before any changes  
✅ **Verification** - Built-in checks for missing files  
✅ **Command Line & Browser** - Choose your preferred workflow

## 📞 Getting Help

**For Command Line Users:**
- See `CLI_MIGRATION_GUIDE.md` for comprehensive instructions
- Scripts include built-in help and error messages

**For Browser Users:**
- Open `MEDIA_DOWNLOADER.html` for graphical download tool
- See `MEDIA_DOWNLOADER_GUIDE.md` for instructions

**For Everyone:**
- Check `MIGRATION_SUMMARY.md` for quick reference
- All scripts create backups before modifying files

## ⚠️ Important Reminders

1. **Download media BEFORE shutting down WordPress** - Files are still hosted there
2. **Test locally first** - Don't deploy until everything works
3. **Keep WordPress running** for 1-2 weeks as backup during migration
4. **Get updated export** if you have new pages created after November 20, 2025

## 🎵 Next Steps

1. **Update WordPress Export** (if you have new pages)
2. **Run `./download_media.sh`** to get all media files
3. **Run `./update_paths.sh`** to fix file paths
4. **Test with local server** to verify everything works
5. **Deploy** to your chosen hosting platform
6. **Configure domain** to point to new host
7. **Enjoy your faster, cheaper site!**

---

**Total Time:** 2-4 hours  
**Savings:** $120-270/year  
**Difficulty:** Easy with provided scripts

Generated on January 15, 2026
