# Quick Start Guide
## connoi.se WordPress to Static Migration

**Date:** January 15, 2026

---

## ⚠️ FIRST: Update Your WordPress Export

Your current export is from **November 20, 2025** and is **missing 6 new pages**.

**👉 See `HOW_TO_EXPORT_WORDPRESS.md` for step-by-step instructions**

New pages not in current export:
1. Xhungus
2. Frog Budget
3. Inventorois
4. Second Brian
5. Chuuning-Byou
6. I'm Bad at Music Theory

---

## 🚀 Migration in 4 Commands

Once you have an updated WordPress export:

```bash
# 1. Download all 99 media files
./download_media.sh

# 2. Update file paths
./update_paths.sh

# 3. Test locally
python3 -m http.server 8000

# 4. Deploy
netlify deploy --prod
```

---

## 📖 Documentation

- **`README.md`** - Start here for overview
- **`CLI_MIGRATION_GUIDE.md`** - Complete command line guide
- **`HOW_TO_EXPORT_WORDPRESS.md`** - Get updated WordPress export
- **`download_media.sh`** - Automated media download
- **`update_paths.sh`** - Automated path updates

---

## 💡 What You Get

✅ Static HTML site (no WordPress needed)  
✅ 25 pages converted (31 with updated export)  
✅ All media files preserved  
✅ Automated migration scripts  
✅ Free hosting options  
✅ $120-270/year savings  

---

## ⏱️ Time Estimate

| Task | Time |
|------|------|
| Get updated WP export | 5 min |
| Re-run conversion | 2 min |
| Download media (99 files) | 10-20 min |
| Update paths | 2 min |
| Test locally | 10 min |
| Deploy to hosting | 15 min |
| **TOTAL** | **~45 minutes** |

---

## 🎯 Current Status

**Exported:** November 20, 2025  
**Pages:** 25 (missing 6 new ones)  
**Posts:** 1  
**Media:** 99 files  
**Scripts:** Ready to use  

---

## Next Step

**👉 Read `README.md` for complete workflow**
