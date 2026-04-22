#!/bin/bash
# Path Update Script for connoi.se Migration
# Updates WordPress URLs to local media file paths

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "========================================="
echo "  connoi.se Path Update Script"
echo "========================================="
echo

# Check if we're in the right directory
if [ ! -d "pages" ] || [ ! -d "media" ]; then
    echo -e "${RED}Error: Please run this script from the connoise_static directory${NC}"
    exit 1
fi

# Create backup
echo -e "${YELLOW}Creating backup...${NC}"
BACKUP_DIR="backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"
cp -r pages posts "$BACKUP_DIR/"
echo -e "${GREEN}✓${NC} Backup created in $BACKUP_DIR/"
echo

# Detect media organization
echo "Detecting media file organization..."
if [ -d "media/images" ] || [ -d "media/audio" ]; then
    STRUCTURE="organized"
    echo -e "${BLUE}Structure: Organized by type${NC}"
elif [ -d "media/2021" ] || [ -d "media/2024" ]; then
    STRUCTURE="date"
    echo -e "${BLUE}Structure: Organized by date${NC}"
else
    STRUCTURE="flat"
    echo -e "${BLUE}Structure: Flat (all in media/downloads or media/)${NC}"
fi
echo

# Count WordPress URLs before
BEFORE=$(grep -r "connoi.se/wp-content" pages/ posts/ 2>/dev/null | wc -l)
echo "WordPress URLs found: $BEFORE"
echo

# Update paths based on structure
echo -e "${YELLOW}Updating file paths...${NC}"

case $STRUCTURE in
    flat)
        # Flat structure: ../media/filename.ext
        find pages posts -name "*.html" -type f -exec sed -i.bak \
            's|https://connoi\.se/wp-content/uploads/[0-9]*/[0-9]*/\([^"]*\)|../media/\1|g' {} \;
        ;;
    date)
        # Date structure: ../media/YYYY/MM/filename.ext
        find pages posts -name "*.html" -type f -exec sed -i.bak \
            's|https://connoi\.se/wp-content/uploads/\([0-9]*\)/\([0-9]*\)/\([^"]*\)|../media/\1/\2/\3|g' {} \;
        ;;
    organized)
        # Need to determine file type and update accordingly
        echo -e "${YELLOW}Organized structure detected. Using smart path resolution...${NC}"
        
        # Process each HTML file
        for htmlfile in pages/*.html posts/*.html; do
            [ -f "$htmlfile" ] || continue
            
            # Find all media references
            grep -o 'src="https://connoi\.se/wp-content/uploads/[^"]*"' "$htmlfile" | \
            sed 's/src="//;s/"//' | while read url; do
                filename=$(basename "$url")
                
                # Determine file type and location
                if [ -f "media/images/$filename" ]; then
                    newpath="../media/images/$filename"
                elif [ -f "media/audio/$filename" ]; then
                    newpath="../media/audio/$filename"
                elif [ -f "media/fonts/$filename" ]; then
                    newpath="../media/fonts/$filename"
                elif [ -f "media/archives/$filename" ]; then
                    newpath="../media/archives/$filename"
                else
                    # Fallback to flat structure
                    newpath="../media/$filename"
                fi
                
                # Replace in file
                sed -i.bak "s|$url|$newpath|g" "$htmlfile"
            done
        done
        ;;
esac

# Remove backup files created by sed
find pages posts -name "*.bak" -delete

# Count WordPress URLs after
AFTER=$(grep -r "connoi.se/wp-content" pages/ posts/ 2>/dev/null | wc -l)
echo -e "${GREEN}✓${NC} Paths updated"
echo

# Show results
echo "Results:"
echo "  Before: $BEFORE WordPress URLs"
echo "  After:  $AFTER WordPress URLs"
echo "  Fixed:  $((BEFORE - AFTER)) URLs"
echo

if [ "$AFTER" -eq 0 ]; then
    echo -e "${GREEN}✅ All WordPress URLs successfully converted!${NC}"
else
    echo -e "${YELLOW}⚠ Warning: $AFTER WordPress URLs remain${NC}"
    echo "These may be external references or need manual review:"
    grep -r "connoi.se/wp-content" pages/ posts/ 2>/dev/null | head -5
    echo
fi

# Verify local media references
LOCAL_REFS=$(grep -r '../media/' pages/ posts/ 2>/dev/null | wc -l)
echo "Local media references: $LOCAL_REFS"
echo

# Check for broken local links
echo -e "${YELLOW}Checking for broken media links...${NC}"
BROKEN=0

for htmlfile in pages/*.html posts/*.html; do
    [ -f "$htmlfile" ] || continue
    
    # Extract local media paths
    grep -o 'src="\.\.\/media\/[^"]*"' "$htmlfile" | \
    sed 's/src="//;s/"//' | while read relpath; do
        # Convert relative path to absolute
        filepath="$(dirname "$htmlfile")/$relpath"
        
        # Normalize path
        filepath=$(python3 -c "import os; print(os.path.normpath('$filepath'))" 2>/dev/null || echo "$filepath")
        
        if [ ! -f "$filepath" ]; then
            echo -e "${RED}  Missing:${NC} $relpath (in $htmlfile)"
            BROKEN=$((BROKEN + 1))
        fi
    done
done

if [ $BROKEN -eq 0 ]; then
    echo -e "${GREEN}✓${NC} No broken links detected"
else
    echo -e "${YELLOW}⚠ Found $BROKEN broken links${NC}"
    echo "  Check file organization and re-download if needed"
fi

echo
echo -e "${GREEN}🎉 Path update complete!${NC}"
echo
echo "Next steps:"
echo "1. Test locally: python3 -m http.server 8000"
echo "2. Open http://localhost:8000 in browser"
echo "3. Check that all images and audio files load"
echo "4. If everything works, proceed with deployment"
echo
echo "Backup saved in: $BACKUP_DIR/"
echo
