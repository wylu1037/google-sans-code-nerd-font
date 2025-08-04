#!/bin/bash

# Google Sans Code Nerd Font Build Test Script with Ligature Support
# Used to verify the font processing workflow locally

set -e  # Exit on error

echo "🚀 Starting the Google Sans Code Nerd Font + Ligatures build process test..."

# Check for necessary tools
check_dependencies() {
    echo "📋 Checking dependencies..."
    
    if ! command -v fontforge &> /dev/null; then
        echo "❌ FontForge is not installed. Please install it first:"
        echo "   Ubuntu/Debian: sudo apt-get install fontforge python3-fontforge"
        echo "   macOS: brew install fontforge"
        exit 1
    fi
    
    if ! command -v python3 &> /dev/null; then
        echo "❌ Python3 is not installed"
        exit 1
    fi
    
    if ! command -v curl &> /dev/null; then
        echo "❌ curl is not installed"
        exit 1
    fi
    
    if ! command -v unzip &> /dev/null; then
        echo "❌ unzip is not installed"
        exit 1
    fi
    
    echo "✅ Dependency check passed"
}

# Check font files
check_fonts() {
    echo "📁 Checking font files..."
    
    if [ ! -d "data/google-sans-code/static" ]; then
        echo "❌ Font file directory does not exist: data/google-sans-code/static"
        exit 1
    fi
    
    font_count=$(find data/google-sans-code/static -name "*.ttf" | wc -l)
    echo "✅ Found $font_count font files"
    
    if [ $font_count -eq 0 ]; then
        echo "❌ No font files found"
        exit 1
    fi
}

# Download Fira Code for ligatures
setup_fira_code() {
    echo "⬇️ Setting up Fira Code for ligatures..."
    
    mkdir -p tools
    cd tools
    
    if [ ! -f "FiraCode-Regular.ttf" ]; then
        echo "Downloading Fira Code..."
        curl -L "https://github.com/tonsky/FiraCode/releases/download/6.2/Fira_Code_v6.2.zip" -o FiraCode.zip
        unzip -q FiraCode.zip
        # Find and copy the Regular font
        find . -name "*Regular.ttf" -type f -exec cp {} FiraCode-Regular.ttf \;
    fi
    
    if [ ! -f "FiraCode-Regular.ttf" ]; then
        echo "❌ Fira Code Regular font not found"
        exit 1
    fi
    
    echo "✅ Fira Code setup complete"
    cd ..
}

# Download Font Patcher
setup_patcher() {
    echo "⬇️ Setting up Nerd Font Patcher..."
    
    mkdir -p tools
    cd tools
    
    if [ ! -f "font-patcher" ]; then
        echo "Downloading FontPatcher.zip..."
        # Pinning version for reproducible builds
        curl -L https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/FontPatcher.zip -o FontPatcher.zip
        unzip -q FontPatcher.zip
        chmod +x font-patcher
    fi
    
    if [ ! -f "font-patcher" ]; then
        echo "❌ font-patcher script not found"
        exit 1
    fi
    
    echo "✅ Font Patcher setup complete"
    cd ..
}

# Test ligaturization
test_ligaturize() {
    echo "🔗 Testing ligaturization process..."
    
    # Find the first font file to test
    test_font=$(find data/google-sans-code/static -name "*.ttf" | head -1)
    
    if [ -z "$test_font" ]; then
        echo "❌ No test font file found"
        exit 1
    fi
    
    echo "Testing ligaturization with font: $(basename "$test_font")"
    
    mkdir -p test-output
    
    # Test ligaturization
    output_ligaturized="test-output/$(basename "$test_font" .ttf)-ligaturized.ttf"
    
    # Check if we can use system Python with FontForge, otherwise fall back to python3
    if command -v /usr/bin/python3 &> /dev/null && /usr/bin/python3 -c "import fontforge" 2>/dev/null; then
        PYTHON_CMD="/usr/bin/python3"
        echo "Using system Python with FontForge support"
    else
        PYTHON_CMD="python3"
        echo "Using default Python (may need PYTHONPATH)"
        export PYTHONPATH="/usr/lib/python3/dist-packages:/usr/local/lib/python3/dist-packages:$PYTHONPATH"
    fi
    
    echo "Executing: $PYTHON_CMD scripts/ligaturize-fixed.py \"$test_font\" tools/FiraCode-Regular.ttf \"$output_ligaturized\""
    
    if $PYTHON_CMD scripts/ligaturize-fixed.py "$test_font" tools/FiraCode-Regular.ttf "$output_ligaturized"; then
        echo "✅ Ligaturization test successful"
        
        # Check output file
        if [ -f "$output_ligaturized" ]; then
            echo "✅ Ligaturized font created: $(basename "$output_ligaturized")"
            ls -la "$output_ligaturized"
        else
            echo "❌ Ligaturized font file not created"
            exit 1
        fi
    else
        echo "❌ Ligaturization test failed"
        exit 1
    fi
}

# Test processing of a single font file
test_single_font() {
    echo "🧪 Testing Nerd Font patching..."
    
    # Use ligaturized font as input for Nerd Font patching
    ligaturized_font=$(find test-output -name "*-ligaturized.ttf" | head -1)
    
    if [ -z "$ligaturized_font" ]; then
        echo "❌ No ligaturized font file found"
        exit 1
    fi
    
    echo "Testing Nerd Font patching with: $(basename "$ligaturized_font")"
    
    mkdir -p test-output
    
    cd tools
    echo "Executing: fontforge -script font-patcher \"$ligaturized_font\" --fontawesome --outputdir ../test-output"
    
    # Use only --fontawesome for a quick test to avoid long processing time with --complete
    if fontforge -script font-patcher "../$ligaturized_font" --fontawesome --outputdir ../test-output --quiet; then
        echo "✅ Font processing test successful"
    else
        echo "❌ Font processing test failed"
        exit 1
    fi
    
    cd ..
    
    # Check output files
    output_count=$(find test-output -name "*.ttf" | wc -l)
    if [ $output_count -gt 0 ]; then
        echo "✅ Generated $output_count output font files"
        ls -la test-output/
    else
        echo "❌ No output files generated"
        exit 1
    fi
}

# Clean up test files
cleanup() {
    echo "🧹 Cleaning up test files..."
    rm -rf tools/FontPatcher.zip
    rm -rf tools/FiraCode.zip
    rm -rf test-output
    echo "✅ Cleanup complete"
}

# Main function
main() {
    echo "📍 Current directory: $(pwd)"
    
    check_dependencies
    check_fonts
    setup_fira_code
    setup_patcher
    test_ligaturize
    test_single_font
    
    echo ""
    echo "🎉 Test complete! The GitHub Actions workflow should run correctly."
    echo ""
    echo "Next steps:"
    echo "1. Commit and push your changes to GitHub"
    echo "2. Check the Actions tab to see the build status"
    echo "3. Download the font files from the Artifacts after the build is complete"
    echo "4. Test ligatures using scripts/ligature-test.txt"
    echo ""
    
    # In CI environments, always clean up. Otherwise, ask the user.
    if [ -n "$CI" ]; then
        echo "CI environment detected. Cleaning up automatically."
        cleanup
    else
        read -p "Clean up test files? (y/N) " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            cleanup
        fi
    fi
}

# Run main function
main "$@"
