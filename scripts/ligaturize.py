#!/usr/bin/env python3
"""
Simplified but robust ligaturizer for Google Sans Code
Avoids complex contextual rules that can cause FontForge to crash
"""

import argparse
import os
import sys

def ligaturize_font(input_font_file, ligature_font_file, output_dir=None, output_name=None, prefix=None, **kwargs):
    """Apply ligatures from ligature_font to input_font and save to output"""
    
    try:
        import fontforge
        print("✅ FontForge imported successfully")
    except ImportError:
        print("❌ FontForge Python module is required for ligaturization")
        return False
    
    try:
        print(f"📂 Loading input font: {input_font_file}")
        input_font = fontforge.open(input_font_file)
        
        print(f"📂 Loading ligature font: {ligature_font_file}")
        ligature_font = fontforge.open(ligature_font_file)
        
        # Scale ligature font to match input font
        ligature_font.em = input_font.em
        
        print("🔗 Copying ligature features using simplified approach...")
        
        # Define the most important ligatures to copy
        # These are the core programming ligatures that work reliably
        important_ligatures = [
            # Arrow operators
            ('hyphen_greater.liga', ['hyphen', 'greater']),  # ->
            ('equal_greater.liga', ['equal', 'greater']),    # =>
            ('less_hyphen.liga', ['less', 'hyphen']),        # <-
            ('less_equal.liga', ['less', 'equal']),          # <=
            ('greater_equal.liga', ['greater', 'equal']),    # >=
            
            # Comparison operators
            ('equal_equal.liga', ['equal', 'equal']),        # ==
            ('exclam_equal.liga', ['exclam', 'equal']),      # !=
            ('equal_equal_equal.liga', ['equal', 'equal', 'equal']),  # ===
            ('exclam_equal_equal.liga', ['exclam', 'equal', 'equal']), # !==
            
            # Double operators
            ('hyphen_hyphen.liga', ['hyphen', 'hyphen']),    # --
            ('plus_plus.liga', ['plus', 'plus']),            # ++
            ('bar_bar.liga', ['bar', 'bar']),                # ||
            ('ampersand_ampersand.liga', ['ampersand', 'ampersand']), # &&
        ]
        
        copied_count = 0
        
        # Use a simpler approach: direct glyph substitution with basic GSUB features
        for liga_name, char_sequence in important_ligatures:
            try:
                # Check if ligature exists in source font
                if liga_name not in ligature_font:
                    print(f"  ⚠️  Ligature {liga_name} not found in source font, skipping")
                    continue
                
                # Copy the ligature glyph
                ligature_font.selection.none()
                ligature_font.selection.select(liga_name)
                ligature_font.copy()
                
                # Create the ligature in target font
                lig_glyph_name = f"liga_{copied_count}"
                input_font.createChar(-1, lig_glyph_name)
                input_font.selection.none()
                input_font.selection.select(lig_glyph_name)
                input_font.paste()
                
                # Create a simple substitution lookup
                lookup_name = f"liga_lookup_{copied_count}"
                subtable_name = f"liga_subtable_{copied_count}"
                
                # Add lookup table
                input_font.addLookup(lookup_name, 'gsub_ligature', (), 
                    (('liga', (('DFLT', ('dflt',)), ('latn', ('dflt',)))),))
                input_font.addLookupSubtable(lookup_name, subtable_name)
                
                # Map character sequence to ligature
                char_names = []
                for char in char_sequence:
                    # Convert character names to actual character references
                    char_map = {
                        'hyphen': '-', 'greater': '>', 'equal': '=', 'less': '<',
                        'exclam': '!', 'plus': '+', 'bar': '|', 'ampersand': '&'
                    }
                    if char in char_map:
                        actual_char = char_map[char]
                        # Find the glyph name in the font
                        glyph_name = None
                        for glyph in input_font:
                            if input_font[glyph].unicode == ord(actual_char):
                                glyph_name = glyph
                                break
                        if glyph_name:
                            char_names.append(glyph_name)
                
                if len(char_names) == len(char_sequence):
                    # Create the ligature substitution
                    ligature_tuple = tuple(char_names)
                    input_font[char_names[0]].addPosSub(subtable_name, ligature_tuple, lig_glyph_name)
                    copied_count += 1
                    print(f"  ✅ Added ligature: {''.join([char_map.get(c, c) for c in char_sequence])}")
                
            except Exception as e:
                print(f"  ⚠️  Failed to add ligature {liga_name}: {e}")
                continue
        
        print(f"📊 Successfully copied {copied_count} ligatures")
        
        # Set output font metadata
        if output_name:
            input_font.familyname = output_name
            input_font.fullname = output_name
            input_font.fontname = output_name.replace(' ', '')
        elif prefix:
            input_font.familyname = f"{prefix} {input_font.familyname}"
            input_font.fullname = f"{prefix} {input_font.fullname}"
            input_font.fontname = f"{prefix}{input_font.fontname}"
        
        # Generate output font
        if not output_dir:
            output_dir = os.path.dirname(input_font_file)
        
        output_filename = input_font.fontname + ('.otf' if input_font_file.lower().endswith('.otf') else '.ttf')
        output_path = os.path.join(output_dir, output_filename)
        
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
        
    except Exception as e:
        print(f"❌ Ligaturization failed: {e}")
        return False

def main():
    parser = argparse.ArgumentParser(description='Add ligatures to a font using Fira Code as source')
    parser.add_argument('input_font_file', help='Input font file path')
    parser.add_argument('--ligature-font-file', required=True, help='Font containing ligatures (Fira Code)')
    parser.add_argument('--output-dir', help='Output directory')
    parser.add_argument('--output-name', help='Output font name')
    parser.add_argument('--prefix', default='Liga', help='Prefix for font name')
    
    args = parser.parse_args()
    
    # Validate input files
    if not os.path.exists(args.input_font_file):
        print(f"❌ Error: Input font not found: {args.input_font_file}")
        sys.exit(1)
    
    if not os.path.exists(args.ligature_font_file):
        print(f"❌ Error: Ligature font not found: {args.ligature_font_file}")
        sys.exit(1)
    
    # Create output directory if needed
    if args.output_dir and not os.path.exists(args.output_dir):
        os.makedirs(args.output_dir)
    
    # Perform ligaturization
    success = ligaturize_font(
        args.input_font_file,
        args.ligature_font_file,
        args.output_dir,
        args.output_name,
        args.prefix
    )
    
    if success:
        print("🎉 Ligaturization completed successfully!")
        sys.exit(0)
    else:
        print("❌ Ligaturization failed!")
        sys.exit(1)

if __name__ == "__main__":
    main()
