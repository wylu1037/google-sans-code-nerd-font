#!/usr/bin/env python3
"""
Simplified but robust ligaturizer for Google Sans Code
Fixed version that handles FontForge API correctly
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
        
        # First, let's discover what ligatures actually exist in Fira Code
        print("🔍 Discovering available ligatures in Fira Code...")
        available_ligatures = []
        for glyph_name in ligature_font:
            glyph = ligature_font[glyph_name]
            # Look for ligature-like glyphs (typically have no unicode mapping and compound names)
            if (glyph.unicode < 0 and 
                ('_' in glyph_name or 
                 'liga' in glyph_name or
                 any(x in glyph_name.lower() for x in ['hyphen', 'greater', 'equal', 'less', 'exclam', 'plus', 'bar', 'ampersand']))):
                available_ligatures.append(glyph_name)
        
        print(f"📋 Found {len(available_ligatures)} potential ligatures:")
        for liga in sorted(available_ligatures)[:20]:  # Show first 20
            print(f"   - {liga}")
        if len(available_ligatures) > 20:
            print(f"   ... and {len(available_ligatures) - 20} more")
        
        # Define ligatures we want to support with their character sequences
        target_ligatures = [
            # Try to find arrow ligatures
            (['hyphen', 'greater'], ['-', '>']),      # ->
            (['equal', 'greater'], ['=', '>']),       # =>  
            (['less', 'hyphen'], ['<', '-']),         # <-
            (['less', 'equal'], ['<', '=']),          # <=
            (['greater', 'equal'], ['>', '=']),       # >=
            (['equal', 'equal'], ['=', '=']),         # ==
            (['exclam', 'equal'], ['!', '=']),        # !=
            (['hyphen', 'hyphen'], ['-', '-']),       # --
            (['plus', 'plus'], ['+', '+']),           # ++
            (['bar', 'bar'], ['|', '|']),             # ||
            (['ampersand', 'ampersand'], ['&', '&']), # &&
        ]
        
        copied_count = 0
        
        # Create a single lookup for all ligatures to avoid conflicts
        main_lookup_name = "programming_ligatures"
        main_subtable_name = "programming_ligatures_subtable"
        
        try:
            # Add the main lookup table
            input_font.addLookup(main_lookup_name, 'gsub_ligature', (), 
                (('liga', (('DFLT', ('dflt',)), ('latn', ('dflt',)))),))
            input_font.addLookupSubtable(main_lookup_name, main_subtable_name)
            print(f"✅ Created main ligature lookup: {main_lookup_name}")
        except Exception as e:
            print(f"❌ Failed to create main lookup: {e}")
            return False
        
        # Try to find and copy ligatures
        for char_names, char_symbols in target_ligatures:
            liga_symbol = ''.join(char_symbols)
            
            # Try different possible ligature names
            possible_names = [
                '_'.join(char_names) + '.liga',
                '_'.join(char_names),
                liga_symbol,
            ]
            
            # Also try variations with common Fira Code naming
            for name in char_names:
                possible_names.extend([
                    f"{name}_{char_names[1] if len(char_names) > 1 else ''}.liga",
                    f"{name}{char_names[1] if len(char_names) > 1 else ''}",
                ])
            
            ligature_found = False
            source_liga_name = None
            
            # Search for the ligature in available ligatures
            for possible_name in possible_names:
                if possible_name in available_ligatures:
                    source_liga_name = possible_name
                    ligature_found = True
                    break
            
            # Also try fuzzy matching
            if not ligature_found:
                for available_liga in available_ligatures:
                    # Check if this ligature could match our target
                    if (all(char in available_liga.lower() for char in char_names) or
                        liga_symbol.replace('-', 'hyphen').replace('>', 'greater').replace('=', 'equal').replace('<', 'less').replace('!', 'exclam').replace('+', 'plus').replace('|', 'bar').replace('&', 'ampersand') in available_liga.lower()):
                        source_liga_name = available_liga
                        ligature_found = True
                        break
            
            if not ligature_found:
                print(f"  ⚠️  Ligature for {liga_symbol} not found, skipping")
                continue
            
            try:
                # Copy the ligature glyph
                ligature_font.selection.none()
                ligature_font.selection.select(source_liga_name)
                ligature_font.copy()
                
                # Create the ligature in target font
                target_liga_name = f"liga_{liga_symbol.replace('-', 'hyphen').replace('>', 'gt').replace('=', 'eq').replace('<', 'lt').replace('!', 'excl').replace('+', 'plus').replace('|', 'bar').replace('&', 'amp')}"
                input_font.createChar(-1, target_liga_name)
                input_font.selection.none()
                input_font.selection.select(target_liga_name)
                input_font.paste()
                
                # Find the actual glyph names for the characters in the font
                char_glyph_names = []
                for char_symbol in char_symbols:
                    char_found = False
                    for glyph_name in input_font:
                        try:
                            if input_font[glyph_name].unicode == ord(char_symbol):
                                char_glyph_names.append(glyph_name)
                                char_found = True
                                break
                        except:
                            continue
                    
                    if not char_found:
                        print(f"    ⚠️  Character '{char_symbol}' not found in font")
                        break
                
                if len(char_glyph_names) == len(char_symbols):
                    # Create the ligature substitution
                    # Format: first_glyph.addPosSub(subtable_name, tuple_of_all_glyphs, target_ligature)
                    source_glyphs = tuple(char_glyph_names)
                    input_font[char_glyph_names[0]].addPosSub(main_subtable_name, source_glyphs, target_liga_name)
                    copied_count += 1
                    print(f"  ✅ Added ligature: {liga_symbol} ({source_liga_name} -> {target_liga_name})")
                else:
                    print(f"  ⚠️  Could not map all characters for {liga_symbol}")
                
            except Exception as e:
                print(f"  ⚠️  Failed to add ligature for {liga_symbol}: {e}")
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
