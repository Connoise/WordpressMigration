# How to Export Updated WordPress Content

## ⚠️ Your Current Export is Outdated

Your WordPress export is from **November 20, 2025**, but you've created new pages since then:

1. Xhungus – Twitter Archive to Obsidian Notes
2. Frog Budget – Budget Tracking and Analysis App
3. Inventorois – Home Inventory App
4. Second Brian – Chat to Obsidian System
5. Chuuning-Byou – Autotune with Harmonic Qualities
6. I'm Bad at Music Theory – Chord Generator and Music Theory Aid

These pages **are not** in your current static site export. Follow these steps to update.

---

## 📥 Step-by-Step Export Instructions

### 1. Log into WordPress Admin

```
URL: https://connoi.se/wp-admin
```

Enter your WordPress username and password.

### 2. Navigate to Export Tool

1. In the left sidebar, click **Tools**
2. Click **Export**

Or go directly to: `https://connoi.se/wp-admin/export.php`

### 3. Export All Content

1. Select **All content** radio button
   - This ensures you get ALL pages, posts, media, etc.
   
2. Click **Download Export File** button

3. Save the file with a descriptive name:
   ```
   connoise_wordpress_2026-01-15.xml
   ```
   (Use today's date)

### 4. Verify the Export

Open the downloaded XML file and search for one of your new pages to confirm:

```bash
# Search for your new pages
grep -i "xhungus\|frog budget\|inventorois" connoise_wordpress_2026-01-15.xml
```

If you see results, the export is good!

---

## 🔄 Re-run the Conversion

### Using the Python Script

```bash
# Copy the script if you don't have it
# (It's included in your download)

# Run conversion with new export
python wordpress_to_static.py connoise_wordpress_2026-01-15.xml connoise_static_new

# This creates a fresh conversion with ALL your pages
```

### What to Expect

The script will show:
```
Converting WordPress export: connoise_wordpress_2026-01-15.xml
Output directory: connoise_static_new

Site: Agoe the Idol//connoise
URL: https://connoi.se
Description: our faces are melting like popsicles!

✓ Page: Xhungus -> xhungus.html
✓ Page: Frog Budget -> frog-budget.html
✓ Page: Inventorois -> inventorois.html
✓ Page: Second Brian -> second-brian.html
✓ Page: Chuuning-Byou -> chuuning-byou.html
✓ Page: I'm Bad at Music Theory -> im-bad-at-music-theory.html
[... and all your other pages ...]

✅ Extraction complete!
   Pages: 31
   Posts: 1
   Media: 99
```

You should now see **31 pages** instead of 25!

---

## 📦 After Re-conversion

### 1. Replace Your Old Static Site

```bash
# Backup old version (optional)
mv connoise_static connoise_static_old_backup

# Rename new version
mv connoise_static_new connoise_static

# Or just work with the new directory
cd connoise_static_new
```

### 2. Download Media Files

The media files are the same, but if you haven't downloaded them yet:

```bash
./download_media.sh
```

### 3. Update Paths

```bash
./update_paths.sh
```

### 4. Test Locally

```bash
python3 -m http.server 8000
```

Open http://localhost:8000 and verify all 31 pages are there!

### 5. Check Your New Pages

Navigate to your new code project pages:
- `/pages/xhungus.html`
- `/pages/frog-budget.html`
- `/pages/inventorois.html`
- `/pages/second-brian.html`
- `/pages/chuuning-byou.html`
- `/pages/im-bad-at-music-theory.html`

---

## 🔍 Verification Checklist

Before proceeding with deployment:

```bash
# Count pages
ls pages/ | wc -l
# Should show 30+ pages

# List all pages
ls pages/

# Check for new project pages
ls pages/ | grep -E "xhungus|frog|inventor|brian|chuuning|music-theory"

# Verify index.html includes all pages
cat index.html | grep -E "xhungus|frog|inventor|brian|chuuning|music-theory"
```

---

## 📝 WordPress Export Settings

For reference, here's what the export settings should look like:

```
Export
------
Choose what to export:

⚪ All content (selected)
   This will contain all of your posts, pages, comments, custom 
   fields, terms, navigation menus, and custom posts.

⚪ Posts
⚪ Pages  
⚪ Media

[Download Export File]
```

Always choose **All content** to ensure nothing is missed!

---

## 🤔 Troubleshooting

### Issue: Export file is very small (< 100KB)

**Problem:** Export might be incomplete  
**Solution:** Try exporting again, ensure all content is published

### Issue: Can't find new pages in export

**Problem:** Pages might be drafts or scheduled  
**Solution:** Check page status in WordPress, publish if needed

### Issue: Export times out or fails

**Problem:** Site too large or server timeout  
**Solution:** 
1. Try exporting just pages first
2. Contact your host to increase timeout limits
3. Use WP All Export plugin as alternative

### Issue: "Download Export File" button does nothing

**Problem:** JavaScript issue or browser block  
**Solution:**
1. Try different browser
2. Disable ad blockers
3. Check browser console for errors

---

## 🔗 Alternative: WP All Export Plugin

If WordPress export isn't working:

1. Install "WP All Export" plugin
2. Go to All Export → New Export
3. Select "Specific Post Type" → Pages
4. Export as XML
5. Repeat for Posts if needed

---

## ✅ Final Notes

- Export files can be large (1-10 MB) - this is normal
- Keep your export files as backups
- Export regularly if you make frequent changes
- The XML file is just a backup format - human readable

Once you have the new export and re-run the conversion, you'll have ALL your pages including the 6 new code projects!

---

**Need Help?**

See `CLI_MIGRATION_GUIDE.md` for the complete migration workflow after getting your updated export.
