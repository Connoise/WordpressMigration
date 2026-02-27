# WordPress to Static Site Migration Guide (Command Line Edition)
## Complete Step-by-Step Guide for connoi.se

---

## ⚠️ IMPORTANT: Update Your WordPress Export First

Your current export is from **November 20, 2025**. You've mentioned 6 new code project pages:
1. Xhungus – Twitter Archive to Obsidian Notes
2. Frog Budget – Budget Tracking and Analysis App
3. Inventorois – Home Inventory App
4. Second Brian – Chat to Obsidian System
5. Chuuning-Byou – Autotune with Harmonic Qualities
6. I'm Bad at Music Theory – Chord Generator and Music Theory Aid

These pages are **NOT in your current export**. Before proceeding:

### Get Updated Export:
1. Log into your WordPress admin at https://connoi.se/wp-admin
2. Go to **Tools → Export**
3. Select **All content**
4. Click **Download Export File**
5. Save as `connoise_wordpress_LATEST.xml`
6. Run the conversion script again with the new file

---

## 📋 Table of Contents

1. [Initial Setup](#initial-setup)
2. [Download Media Files](#download-media-files)
3. [Organize Your Site](#organize-your-site)
4. [Update File Paths](#update-file-paths)
5. [Test Locally](#test-locally)
6. [Deploy to Hosting](#deploy-to-hosting)
7. [Configure Domain](#configure-domain)
8. [Final Steps](#final-steps)

---

## 1. Initial Setup

### What You Have

```
connoise_static/
├── index.html              # Homepage with links to all pages
├── pages/                  # 25+ HTML pages (will be more with updated export)
├── posts/                  # Blog posts
├── media/
│   └── media_urls.txt      # List of 99 media files to download
└── site_metadata.json      # Complete site data
```

### Current Status

```bash
# Check what you have
ls -la connoise_static/
ls connoise_static/pages/ | wc -l    # Shows number of pages
cat connoise_static/media/media_urls.txt | wc -l  # Shows number of media files
```

### Re-run Conversion (After Getting Updated Export)

```bash
# When you have the updated WordPress export
python wordpress_to_static.py connoise_wordpress_LATEST.xml connoise_static_new

# This will create a fresh conversion with all your new pages
```

---

## 2. Download Media Files

You have **99 media files** to download from your WordPress site.

### Method 1: Using wget (Recommended)

```bash
# Navigate to your project directory
cd connoise_static

# Create media directory with year/month structure
mkdir -p media/{2021,2022,2023,2024,2025}/{01..12}

# Download all files using wget
wget -i media/media_urls.txt -P media/downloads/

# This downloads all 99 files to media/downloads/
```

### Method 2: Using curl

```bash
# Create download directory
mkdir -p media/downloads

# Download all files with curl
while read url; do
    filename=$(basename "$url")
    curl -L "$url" -o "media/downloads/$filename"
    echo "Downloaded: $filename"
done < media/media_urls.txt
```

### Method 3: Parallel Downloads (Faster)

```bash
# Install GNU parallel if not already installed
# On macOS: brew install parallel
# On Linux: sudo apt-get install parallel

# Download 4 files at a time
cat media/media_urls.txt | parallel -j 4 'wget -P media/downloads {}'
```

### Method 4: Using aria2c (Fastest)

```bash
# Install aria2 if not already installed
# On macOS: brew install aria2
# On Linux: sudo apt-get install aria2

# Download files with aria2 (uses multiple connections per file)
aria2c -i media/media_urls.txt -d media/downloads/ -j 4 -x 4
```

### Verify Downloads

```bash
# Check how many files were downloaded
ls media/downloads/ | wc -l

# Should show 99 files

# Check total size
du -sh media/downloads/

# List all downloaded files
ls -lh media/downloads/
```

---

## 3. Organize Your Site

### Option A: Keep Flat Structure (Easiest)

```bash
# Keep all media in one folder
mkdir -p media/
mv media/downloads/* media/
rmdir media/downloads
```

### Option B: Organize by Type

```bash
# Create directories by file type
mkdir -p media/{images,audio,fonts,archives}

# Move files by type
mv media/downloads/*.{jpg,jpeg,png,gif,webp} media/images/
mv media/downloads/*.{mp3,wav} media/audio/
mv media/downloads/*.ttf media/fonts/
mv media/downloads/*.zip media/archives/

# Remove empty download directory
rmdir media/downloads
```

### Option C: Organize by Date (WordPress Structure)

```bash
# Extract year/month from URLs and organize accordingly
while read url; do
    # Extract year and month from URL path
    if [[ $url =~ uploads/([0-9]{4})/([0-9]{2})/ ]]; then
        year="${BASH_REMATCH[1]}"
        month="${BASH_REMATCH[2]}"
        filename=$(basename "$url")
        
        # Create directory structure
        mkdir -p "media/$year/$month"
        
        # Move file if it exists
        if [ -f "media/downloads/$filename" ]; then
            mv "media/downloads/$filename" "media/$year/$month/"
            echo "Organized: $filename -> $year/$month/"
        fi
    fi
done < media/media_urls.txt

# Clean up
rmdir media/downloads 2>/dev/null || true
```

---

## 4. Update File Paths

Your HTML files currently reference WordPress URLs. You need to update them to point to local files.

### Automated Path Replacement

```bash
# Create a backup first
cp -r connoise_static connoise_static_backup

# Replace WordPress URLs with local paths (flat structure)
find pages -name "*.html" -type f -exec sed -i 's|https://connoi.se/wp-content/uploads/[0-9]*/[0-9]*/\([^"]*\)|../media/\1|g' {} +

# For posts directory too
find posts -name "*.html" -type f -exec sed -i 's|https://connoi.se/wp-content/uploads/[0-9]*/[0-9]*/\([^"]*\)|../media/\1|g' {} +
```

### For Date-Organized Structure

```bash
# Replace with year/month structure
find pages -name "*.html" -type f -exec sed -i 's|https://connoi.se/wp-content/uploads/\([0-9]*\)/\([0-9]*\)/\([^"]*\)|../media/\1/\2/\3|g' {} +

find posts -name "*.html" -type f -exec sed -i 's|https://connoi.se/wp-content/uploads/\([0-9]*\)/\([0-9]*\)/\([^"]*\)|../media/\1/\2/\3|g' {} +
```

### Manual Verification

```bash
# Check for remaining WordPress URLs
grep -r "connoi.se/wp-content" pages/ || echo "✓ All paths updated!"

# Count references to local media
grep -r "../media/" pages/ | wc -l
```

### Create Path Update Script

```bash
# Create a reusable script
cat > update_paths.sh << 'EOF'
#!/bin/bash
# Update WordPress URLs to local media paths

STRUCTURE="${1:-flat}"  # flat or date

if [ "$STRUCTURE" = "flat" ]; then
    echo "Updating to flat structure..."
    find pages posts -name "*.html" -type f -exec sed -i 's|https://connoi.se/wp-content/uploads/[0-9]*/[0-9]*/\([^"]*\)|../media/\1|g' {} +
else
    echo "Updating to date structure..."
    find pages posts -name "*.html" -type f -exec sed -i 's|https://connoi.se/wp-content/uploads/\([0-9]*\)/\([0-9]*\)/\([^"]*\)|../media/\1/\2/\3|g' {} +
fi

echo "✓ Paths updated!"
EOF

chmod +x update_paths.sh

# Run it
./update_paths.sh flat    # or ./update_paths.sh date
```

---

## 5. Test Locally

### Using Python HTTP Server

```bash
# Navigate to your site directory
cd connoise_static

# Start a local web server
python3 -m http.server 8000

# Open in browser:
# http://localhost:8000
```

### Using Node.js HTTP Server

```bash
# Install http-server globally (once)
npm install -g http-server

# Start server
cd connoise_static
http-server -p 8000

# Open http://localhost:8000
```

### Using PHP Built-in Server

```bash
cd connoise_static
php -S localhost:8000

# Open http://localhost:8000
```

### Test Checklist

```bash
# Create a test script
cat > test_site.sh << 'EOF'
#!/bin/bash

echo "Testing connoi.se static site..."
echo

# Check for broken image links
echo "Checking for missing images..."
for file in pages/*.html posts/*.html; do
    grep -o 'src="[^"]*"' "$file" | sed 's/src="//;s/"//' | while read src; do
        # Skip external URLs
        if [[ $src == http* ]]; then continue; fi
        
        # Convert relative path to absolute
        filepath=$(dirname "$file")/$src
        filepath=$(realpath -m "$filepath")
        
        if [ ! -f "$filepath" ]; then
            echo "Missing: $src (referenced in $file)"
        fi
    done
done

echo
echo "Checking for broken audio links..."
for file in pages/*.html posts/*.html; do
    grep -o 'src="[^"]*\.mp3\|wav"' "$file" | sed 's/src="//;s/"//' | while read src; do
        if [[ $src == http* ]]; then continue; fi
        
        filepath=$(dirname "$file")/$src
        filepath=$(realpath -m "$filepath")
        
        if [ ! -f "$filepath" ]; then
            echo "Missing: $src (referenced in $file)"
        fi
    done
done

echo
echo "✓ Test complete!"
EOF

chmod +x test_site.sh
./test_site.sh
```

---

## 6. Deploy to Hosting

### Option 1: Netlify (Recommended - Free)

```bash
# Install Netlify CLI
npm install -g netlify-cli

# Login to Netlify
netlify login

# Navigate to your site directory
cd connoise_static

# Initialize and deploy
netlify init

# Or deploy directly
netlify deploy --prod

# Follow prompts:
# - Choose "Create & configure a new site"
# - Pick your team
# - Site name: connoise (or whatever you prefer)
# - Deploy path: . (current directory)
```

### Option 2: Vercel (Also Free)

```bash
# Install Vercel CLI
npm install -g vercel

# Login
vercel login

# Deploy
cd connoise_static
vercel

# Follow prompts and deploy
vercel --prod  # Deploy to production
```

### Option 3: GitHub Pages

```bash
# Initialize git repository
cd connoise_static
git init
git add .
git commit -m "Initial commit - Static site migration"

# Create GitHub repository (do this on github.com first)
# Then:
git remote add origin https://github.com/YOUR_USERNAME/connoise.git
git branch -M main
git push -u origin main

# Enable GitHub Pages in repository settings
# Settings → Pages → Source: main branch
```

### Option 4: Cloudflare Pages

```bash
# Install Wrangler CLI
npm install -g wrangler

# Login to Cloudflare
wrangler login

# Create and deploy
cd connoise_static
wrangler pages project create connoise
wrangler pages publish . --project-name=connoise
```

### Option 5: AWS S3 + CloudFront

```bash
# Install AWS CLI
# On macOS: brew install awscli
# On Linux: sudo apt-get install awscli

# Configure AWS
aws configure

# Create S3 bucket
aws s3 mb s3://connoise-static-site --region us-east-1

# Enable static website hosting
aws s3 website s3://connoise-static-site --index-document index.html

# Upload files
cd connoise_static
aws s3 sync . s3://connoise-static-site --acl public-read

# Set up CloudFront (optional, for CDN)
# Use AWS Console for this - more complex via CLI
```

### Option 6: Traditional Hosting (GoDaddy/cPanel)

```bash
# Compress your site
cd ..
tar -czf connoise_static.tar.gz connoise_static/

# Or create zip
zip -r connoise_static.zip connoise_static/

# Upload via FTP/SFTP
# Using lftp:
lftp -u YOUR_USERNAME,YOUR_PASSWORD sftp://YOUR_HOST
put connoise_static.tar.gz
bye

# Then SSH into server and extract:
ssh YOUR_USERNAME@YOUR_HOST
cd public_html
tar -xzf ../connoise_static.tar.gz
mv connoise_static/* .
rmdir connoise_static
```

---

## 7. Configure Domain

### Update DNS Records (For External Hosting)

```bash
# You'll need to update DNS at GoDaddy to point to your new host

# For Netlify:
# A Record: @ → 75.2.60.5
# CNAME: www → YOUR_SITE.netlify.app

# For Vercel:
# A Record: @ → 76.76.21.21
# CNAME: www → cname.vercel-dns.com

# For Cloudflare Pages:
# CNAME: @ → YOUR_SITE.pages.dev
# CNAME: www → YOUR_SITE.pages.dev

# For GitHub Pages:
# A Records:
# @ → 185.199.108.153
# @ → 185.199.109.153
# @ → 185.199.110.153
# @ → 185.199.111.153
# CNAME: www → YOUR_USERNAME.github.io
```

### Verify DNS Propagation

```bash
# Check DNS propagation
dig connoi.se +short
dig www.connoi.se +short

# Or use nslookup
nslookup connoi.se
nslookup www.connoi.se

# Check from multiple locations
curl -s "https://www.whatsmydns.net/api/details?server=world&type=A&query=connoi.se" | jq
```

---

## 8. Final Steps

### Create Deployment Script

```bash
cat > deploy.sh << 'EOF'
#!/bin/bash
# Deployment script for connoi.se

set -e  # Exit on error

echo "🚀 Deploying connoi.se..."
echo

# Run tests
echo "Running tests..."
./test_site.sh

# Backup
echo "Creating backup..."
tar -czf "backups/connoise_$(date +%Y%m%d_%H%M%S).tar.gz" connoise_static/

# Deploy (choose your method)
echo "Deploying to Netlify..."
cd connoise_static
netlify deploy --prod

echo
echo "✅ Deployment complete!"
echo "Site: https://connoi.se"
EOF

chmod +x deploy.sh
```

### Set Up Continuous Deployment

```bash
# Create .github/workflows/deploy.yml for GitHub Actions
mkdir -p .github/workflows

cat > .github/workflows/deploy.yml << 'EOF'
name: Deploy to Netlify

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Deploy to Netlify
        uses: nwtgck/actions-netlify@v1.2
        with:
          publish-dir: './connoise_static'
          production-deploy: true
        env:
          NETLIFY_AUTH_TOKEN: ${{ secrets.NETLIFY_AUTH_TOKEN }}
          NETLIFY_SITE_ID: ${{ secrets.NETLIFY_SITE_ID }}
EOF
```

### Monitoring and Maintenance

```bash
# Create monitoring script
cat > monitor.sh << 'EOF'
#!/bin/bash

# Check if site is up
if curl -s -o /dev/null -w "%{http_code}" https://connoi.se | grep -q "200"; then
    echo "✓ Site is up"
else
    echo "✗ Site is down!"
    # Send alert (configure your notification method)
fi

# Check for broken links
wget --spider -r -nd -nv -H -l 1 -w 2 -o wget.log https://connoi.se
if grep -q "broken link" wget.log; then
    echo "⚠ Broken links detected"
    grep "broken link" wget.log
fi
EOF

chmod +x monitor.sh

# Run via cron (every hour)
# crontab -e
# 0 * * * * /path/to/monitor.sh
```

---

## 9. Complete Migration Checklist

```bash
# Save this checklist
cat > MIGRATION_CHECKLIST.md << 'EOF'
# Migration Checklist for connoi.se

## Pre-Migration
- [ ] Export latest WordPress XML (includes all 6 new code pages)
- [ ] Run conversion script with latest export
- [ ] Verify all pages are present (should be 31+ pages)

## Download Phase
- [ ] Download all 99 media files
- [ ] Verify file count matches (99 files)
- [ ] Check total download size
- [ ] Organize files (choose structure)

## Update Phase
- [ ] Update file paths in HTML files
- [ ] Verify no WordPress URLs remain
- [ ] Test all internal links
- [ ] Test all media files load

## Local Testing
- [ ] Start local server
- [ ] Test all pages load
- [ ] Check all images display
- [ ] Test all audio players work
- [ ] Verify all links work
- [ ] Test on mobile browser
- [ ] Check console for errors

## Deployment
- [ ] Choose hosting platform
- [ ] Create account/login
- [ ] Deploy site
- [ ] Verify deployment successful
- [ ] Test live site

## Domain Configuration
- [ ] Update DNS records
- [ ] Wait for DNS propagation (24-48 hours)
- [ ] Verify connoi.se loads new site
- [ ] Verify www.connoi.se works
- [ ] Check HTTPS is enabled

## Post-Migration
- [ ] Test all pages on live site
- [ ] Verify all media loads correctly
- [ ] Check mobile responsiveness
- [ ] Set up analytics (optional)
- [ ] Create backup of static files
- [ ] Keep WordPress running for 1-2 weeks as backup
- [ ] Monitor for issues
- [ ] Cancel WordPress hosting after verification

## Cleanup
- [ ] Delete old WordPress files (after backup)
- [ ] Update bookmarks/links
- [ ] Notify users of migration (if applicable)
- [ ] Archive WordPress export file

EOF
```

---

## Quick Command Reference

```bash
# Download media files
wget -i media/media_urls.txt -P media/downloads/

# Update paths (flat structure)
find pages posts -name "*.html" -type f -exec sed -i 's|https://connoi.se/wp-content/uploads/[0-9]*/[0-9]*/\([^"]*\)|../media/\1|g' {} +

# Test locally
python3 -m http.server 8000

# Deploy to Netlify
netlify deploy --prod

# Check deployment
curl -I https://connoi.se

# Monitor site
./monitor.sh
```

---

## Troubleshooting

### Issue: Media files not downloading

```bash
# Check internet connection
ping -c 3 connoi.se

# Try with verbose output
wget -v -i media/media_urls.txt -P media/downloads/

# Check for specific file
wget -v https://connoi.se/wp-content/uploads/2024/04/song.wav
```

### Issue: Paths not updating

```bash
# Check for macOS vs Linux sed differences
# macOS requires: sed -i '' 's/pattern/replacement/' file
# Linux uses: sed -i 's/pattern/replacement/' file

# Universal approach:
sed 's|old|new|g' file > file.tmp && mv file.tmp file
```

### Issue: Broken links after deployment

```bash
# Find all links
grep -r "href=" pages/ | grep -v "http" | sort | uniq

# Check for absolute paths (should be relative)
grep -r 'href="/' pages/

# Fix absolute to relative paths
find pages -name "*.html" -exec sed -i 's|href="/pages/|href="../pages/|g' {} +
```

---

## Next Steps

1. **Get Updated WordPress Export** with all 6 new code pages
2. **Re-run Conversion** with new export file
3. **Follow this guide** step by step
4. **Test thoroughly** before going live
5. **Deploy** when confident everything works

---

**Total Time Estimate:** 4-6 hours
**Difficulty:** Intermediate
**Required Skills:** Basic command line, HTML editing
**Cost:** $0-15/year (just domain)

Good luck with your migration! 🚀
