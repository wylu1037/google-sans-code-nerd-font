#!/usr/bin/env python3
"""
Simplified and more robust ligaturizer for Google Sans Code
Designed to be more stable than the original ToxicFrog implementation
"""

import argparse
import os
import sys

def ligaturize_font(input_font_path, ligature_font_path, output_path):
    """Apply ligatures from ligature_font to input_font and save to output_path"""
    
    try:
        import fontforge
        print("✅ FontForge imported successfully")
    except ImportError:
        print("❌ FontForge Python module is required for ligaturization")
        return False
    
    try:
        print(f"📂 Loading input font: {input_font_path}")
        input_font = fontforge.open(input_font_path)
        
        print(f"📂 Loading ligature font: {ligature_font_path}")
        ligature_font = fontforge.open(ligature_font_path)
        
        # Scale ligature font to match input font
        ligature_font.em = input_font.em
        
        print("🔗 Copying ligature features using simplified approach...")
        
        # Use the safest approach: direct font merging
        try:
            print("  🔄 Using FontForge's mergeFonts method...")
            
            # Create a backup of the original font name for later restoration
            original_fontname = input_font.fontname
            original_familyname = input_font.familyname
            original_fullname = input_font.fullname
            
            # Merge the ligature font into the input font
            # This copies both glyphs and OpenType features safely
            input_font.mergeFonts(ligature_font_path)
            
            # Restore original font metadata to prevent name conflicts
            input_font.fontname = original_fontname
            input_font.familyname = original_familyname
            input_font.fullname = original_fullname
            
            print("✅ Successfully merged ligature font")
            
        except Exception as e:
            print(f"⚠️  Direct merge failed, trying manual glyph copying: {e}")
            
            # Fallback: manually copy ligature glyphs only (safer approach)
            ligature_count = 0
            
            try:
                for glyph_name in ligature_font:
                    glyph = ligature_font[glyph_name]
                    
                    # Only copy ligature glyphs (no Unicode mapping, likely composite names)
                    if (glyph.unicode < 0 and 
                        ('_' in glyph_name or 
                         any(x in glyph_name.lower() for x in ['equal', 'greater', 'less', 'hyphen', 'arrow', 'liga']))):
                        
                        try:
                            # Copy the glyph if it doesn't exist in target
                            if glyph_name not in input_font:
                                ligature_font.selection.select(glyph_name)
                                ligature_font.copy()
                                
                                input_font.createChar(-1, glyph_name)
                                input_font.selection.select(glyph_name)
                                input_font.paste()
                                
                                ligature_count += 1
                        except Exception:
                            continue  # Skip problematic glyphs
                
                if ligature_count > 0:
                    print(f"✅ Manually copied {ligature_count} ligature glyphs")
                else:
                    print("❌ No ligature glyphs could be copied")
                    return False
                    
            except Exception as e:
                print(f"❌ Manual glyph copying failed: {e}")
                return False
        
        # Preserve original font metadata
        original_family = input_font.familyname
        input_font.familyname = f"{original_family}"
        
        # Generate output font
        print(f"💾 Generating output font: {output_path}")
        
        # Create output directory if it doesn't exist
        output_dir = os.path.dirname(output_path)
        if output_dir and not os.path.exists(output_dir):
            os.makedirs(output_dir)
        
        input_font.generate(output_path)
        
        # Cleanup
        input_font.close()
        ligature_font.close()
        
        # Verify output
        if not os.path.exists(output_path):
            print(f"❌ Output font file was not created: {output_path}")
            return False
        
        file_size = os.path.getsize(output_path)
        if file_size < 100000:  # Less than 100KB
            print(f"❌ Output font file is too small ({file_size} bytes), likely corrupted")
            return False
        
        print(f"✅ Successfully created ligaturized font: {output_path} ({file_size} bytes)")
        return True
        
    except Exception as e:
        print(f"❌ Ligaturization failed with error: {e}")
        import traceback
        traceback.print_exc()
        return False

def main():
    parser = argparse.ArgumentParser(description='Add ligatures to a font using a simplified approach')
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
    
    # Perform ligaturization
    success = ligaturize_font(args.input_font, args.ligature_font, args.output_font)
    
    if success:
        print("🎉 Ligaturization completed successfully!")
        sys.exit(0)
    else:
        print("❌ Ligaturization failed!")
        sys.exit(1)

if __name__ == "__main__":
    main()