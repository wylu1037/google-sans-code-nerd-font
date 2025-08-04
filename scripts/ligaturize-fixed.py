#!/usr/bin/env python3
# Fixed version of Ligaturizer for Python 3 compatibility
# Original: https://github.com/ToxicFrog/ligaturizer
# Fix: Handle Python 3 division returning float instead of int

import sys
import fontforge
import psMat
import argparse
import os

def ligaturize_font(input_font_path, ligature_font_path, output_path):
    """Apply ligatures from ligature_font to input_font and save to output_path"""
    
    print(f"Loading input font: {input_font_path}")
    input_font = fontforge.open(input_font_path)
    
    print(f"Loading ligature font: {ligature_font_path}")
    ligature_font = fontforge.open(ligature_font_path)
    
    # Copy ligature information
    print("Copying ligature tables...")
    
    # Copy GSUB table (ligature information)
    if 'GSUB' in ligature_font:
        input_font['GSUB'] = ligature_font['GSUB']
    
    # Copy ligature glyphs
    ligature_count = 0
    for glyph_name in ligature_font:
        glyph = ligature_font[glyph_name]
        if glyph.unicode == -1 and len(glyph_name) > 1:  # Ligature glyph
            if glyph_name not in input_font:
                input_font.createChar(-1, glyph_name)
            input_font[glyph_name].clear()
            ligature_font.selection.select(glyph_name)
            ligature_font.copy()
            input_font.selection.select(glyph_name)
            input_font.paste()
            ligature_count += 1
    
    print(f"Copied {ligature_count} ligature glyphs")
    
    # Fix bearing calculations for Python 3
    print("Adjusting glyph metrics...")
    for glyph_name in input_font:
        glyph = input_font[glyph_name]
        if glyph.left_side_bearing is not None and glyph.right_side_bearing is not None:
            left_bearing = glyph.left_side_bearing
            right_bearing = glyph.right_side_bearing
            # Fix: Explicitly convert to int for Python 3 compatibility
            center_bearing = int((left_bearing + right_bearing) / 2)
            glyph.left_side_bearing = center_bearing
            glyph.right_side_bearing = center_bearing
    
    # Generate output font
    print(f"Generating font: {output_path}")
    input_font.generate(output_path)
    
    input_font.close()
    ligature_font.close()
    
    print(f"Successfully created ligaturized font: {output_path}")

def main():
    parser = argparse.ArgumentParser(description='Add ligatures to a font using another font as source')
    parser.add_argument('input_font', help='Input font file path')
    parser.add_argument('ligature_font', help='Font containing ligatures (e.g., Fira Code)')
    parser.add_argument('output_font', help='Output font file path')
    
    args = parser.parse_args()
    
    if not os.path.exists(args.input_font):
        print(f"Error: Input font not found: {args.input_font}")
        sys.exit(1)
    
    if not os.path.exists(args.ligature_font):
        print(f"Error: Ligature font not found: {args.ligature_font}")
        sys.exit(1)
    
    # Create output directory if it doesn't exist
    output_dir = os.path.dirname(args.output_font)
    if output_dir and not os.path.exists(output_dir):
        os.makedirs(output_dir)
    
    try:
        ligaturize_font(args.input_font, args.ligature_font, args.output_font)
    except Exception as e:
        print(f"Error during ligaturization: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()