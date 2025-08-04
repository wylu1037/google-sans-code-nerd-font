#!/usr/bin/env python3
# Simplified Ligaturizer for Google Sans Code + Fira Code ligatures
# Fixed for Python 3 compatibility and robustness

import sys
import os
import argparse

def ligaturize_font(input_font_path, ligature_font_path, output_path):
    """Apply ligatures from ligature_font to input_font and save to output_path"""
    
    try:
        import fontforge
    except ImportError:
        print("❌ Error: FontForge Python module not available")
        print("   Make sure python3-fontforge is installed")
        raise ImportError("FontForge Python module is required for ligaturization")
    
    print(f"📂 Loading input font: {input_font_path}")
    input_font = fontforge.open(input_font_path)
    
    print(f"📂 Loading ligature font: {ligature_font_path}")
    ligature_font = fontforge.open(ligature_font_path)
    
    # Copy OpenType features and lookup tables
    print("🔗 Copying ligature features...")
    
    ligature_count = 0
    
    # Copy GSUB table if available (contains ligature information)
    try:
        input_font.mergeFonts(ligature_font_path)
        print("✅ Merged ligature features successfully")
        ligature_count = "merged"
    except Exception as e:
        print(f"⚠️  Warning: Could not merge fonts directly: {e}")
        print("   Trying manual glyph copying...")
        
        # Manual copy of ligature glyphs
        for glyph_name in ligature_font:
            try:
                glyph = ligature_font[glyph_name]
                # Check if this is a ligature glyph (no unicode value, composite name)
                if (glyph.unicode < 0 and 
                    ('_' in glyph_name or len(glyph_name) > 3 or 
                     any(x in glyph_name for x in ['equal', 'greater', 'less', 'arrow']))):
                    
                    if glyph_name not in input_font:
                        input_font.createChar(-1, glyph_name)
                    
                    # Copy glyph
                    ligature_font.selection.select(glyph_name)
                    ligature_font.copy()
                    input_font.selection.select(glyph_name)
                    input_font.paste()
                    ligature_count += 1
                    
            except Exception:
                continue  # Skip problematic glyphs
        
        if ligature_count == 0:
            raise Exception("No ligature glyphs could be copied")
        
        print(f"📊 Copied {ligature_count} ligature glyphs manually")
    
    # Set font family name to preserve original identity
    original_family = input_font.familyname
    input_font.familyname = original_family
    input_font.fontname = input_font.fontname.replace(" ", "")
    
    # Generate output font
    print(f"💾 Generating output font: {output_path}")
    input_font.generate(output_path)
    
    # Cleanup
    input_font.close()
    ligature_font.close()
    
    # Verify output file was created and has reasonable size
    if not os.path.exists(output_path):
        raise Exception(f"Output font file was not created: {output_path}")
    
    file_size = os.path.getsize(output_path)
    if file_size < 100000:  # Less than 100KB
        raise Exception(f"Output font file is too small ({file_size} bytes), likely corrupted")
    
    print(f"✅ Successfully created ligaturized font: {output_path} ({file_size} bytes)")
    return True

def main():
    parser = argparse.ArgumentParser(description='Add ligatures to a font using Fira Code as source')
    parser.add_argument('input_font', help='Input font file path')
    parser.add_argument('ligature_font', help='Font containing ligatures (Fira Code)')
    parser.add_argument('output_font', help='Output font file path')
    
    args = parser.parse_args()
    
    # Validate input files
    if not os.path.exists(args.input_font):
        print(f"❌ Error: Input font not found: {args.input_font}")
        sys.exit(1)
    
    if not os.path.exists(args.ligature_font):
        print(f"❌ Error: Ligature font not found: {args.ligature_font}")
        sys.exit(1)
    
    # Create output directory if needed
    output_dir = os.path.dirname(args.output_font)
    if output_dir and not os.path.exists(output_dir):
        os.makedirs(output_dir)
    
    # Perform ligaturization
    try:
        ligaturize_font(args.input_font, args.ligature_font, args.output_font)
        print("🎉 Ligaturization completed successfully!")
    except Exception as e:
        print(f"❌ Ligaturization failed: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()