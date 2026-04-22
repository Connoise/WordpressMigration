#!/bin/bash
# Media Download Script for connoi.se Migration
# This script downloads all 99 media files from your WordPress site

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "========================================="
echo "  connoi.se Media Download Script"
echo "========================================="
echo

# Check if wget is available
if ! command -v wget &> /dev/null; then
    echo -e "${RED}Error: wget is not installed${NC}"
    echo "Please install wget:"
    echo "  macOS: brew install wget"
    echo "  Ubuntu/Debian: sudo apt-get install wget"
    echo "  Fedora: sudo dnf install wget"
    exit 1
fi

# Create media directory
echo -e "${YELLOW}Creating media directory...${NC}"
mkdir -p media/downloads
echo -e "${GREEN}✓${NC} Directory created"
echo

# Count total files
TOTAL_FILES=$(wc -l < media/media_urls.txt)
echo "Files to download: $TOTAL_FILES"
echo

# Ask for download method
echo "Choose download method:"
echo "1) Sequential (one at a time, slower but reliable)"
echo "2) Parallel (4 at a time, faster but may timeout)"
echo "3) Aria2c (fastest, requires aria2 installation)"
read -p "Enter choice [1-3]: " choice
echo

case $choice in
    1)
        echo -e "${YELLOW}Downloading files sequentially...${NC}"
        wget -i media/media_urls.txt -P media/downloads/ --progress=bar:force
        ;;
    2)
        if ! command -v parallel &> /dev/null; then
            echo -e "${RED}Error: GNU parallel is not installed${NC}"
            echo "Please install it first or choose option 1"
            exit 1
        fi
        echo -e "${YELLOW}Downloading files in parallel (4 connections)...${NC}"
        cat media/media_urls.txt | parallel -j 4 'wget -q -P media/downloads {} && echo "Downloaded: {}"'
        ;;
    3)
        if ! command -v aria2c &> /dev/null; then
            echo -e "${RED}Error: aria2 is not installed${NC}"
            echo "Please install it first or choose option 1"
            exit 1
        fi
        echo -e "${YELLOW}Downloading files with aria2c...${NC}"
        aria2c -i media/media_urls.txt -d media/downloads/ -j 4 -x 4
        ;;
    *)
        echo -e "${RED}Invalid choice${NC}"
        exit 1
        ;;
esac

echo
echo -e "${GREEN}✅ Download complete!${NC}"
echo

# Verify downloads
DOWNLOADED=$(ls media/downloads/ | wc -l)
echo "Files downloaded: $DOWNLOADED / $TOTAL_FILES"

if [ "$DOWNLOADED" -eq "$TOTAL_FILES" ]; then
    echo -e "${GREEN}✓ All files downloaded successfully!${NC}"
else
    echo -e "${YELLOW}⚠ Warning: Some files may be missing${NC}"
    echo "Expected: $TOTAL_FILES"
    echo "Got: $DOWNLOADED"
fi

# Show file size
TOTAL_SIZE=$(du -sh media/downloads/ | cut -f1)
echo "Total size: $TOTAL_SIZE"
echo

# Ask about organization
echo "Would you like to organize files by type? [y/N]"
read -p "> " organize

if [[ $organize =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Organizing files...${NC}"
    
    mkdir -p media/{images,audio,fonts,archives}
    
    mv media/downloads/*.{jpg,jpeg,png,gif,webp} media/images/ 2>/dev/null || true
    mv media/downloads/*.{mp3,wav} media/audio/ 2>/dev/null || true
    mv media/downloads/*.ttf media/fonts/ 2>/dev/null || true
    mv media/downloads/*.zip media/archives/ 2>/dev/null || true
    
    rmdir media/downloads 2>/dev/null || true
    
    echo -e "${GREEN}✓ Files organized by type${NC}"
    echo "  Images: $(ls media/images/ 2>/dev/null | wc -l)"
    echo "  Audio: $(ls media/audio/ 2>/dev/null | wc -l)"
    echo "  Fonts: $(ls media/fonts/ 2>/dev/null | wc -l)"
    echo "  Archives: $(ls media/archives/ 2>/dev/null | wc -l)"
else
    echo "Files remain in media/downloads/"
fi

echo
echo -e "${GREEN}🎉 Media download complete!${NC}"
echo
echo "Next steps:"
echo "1. Update file paths in HTML files"
echo "2. Test locally with: python3 -m http.server 8000"
echo "3. See CLI_MIGRATION_GUIDE.md for full instructions"
echo
