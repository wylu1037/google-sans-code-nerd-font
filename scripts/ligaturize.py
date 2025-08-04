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
        
        # Use the safer mergeFeature approach instead of complex OpenType rules
        try:
            # Copy GSUB table features that contain ligatures
            for lookup_name in ligature_font.gsub_lookups:
                try:
                    # Skip if lookup already exists in target font
                    if lookup_name in input_font.gsub_lookups:
                        continue
                        
                    lookup_info = ligature_font.getLookupInfo(lookup_name)
                    if lookup_info and 'liga' in str(lookup_info).lower():
                        print(f"  📋 Copying lookup: {lookup_name}")
                        input_font.importLookups(ligature_font, (lookup_name,))
                except Exception as e:
                    print(f"  ⚠️  Skipped lookup {lookup_name}: {e}")
                    continue
            
            print("✅ Successfully copied ligature lookups")
            
        except Exception as e:
            print(f"⚠️  Lookup copying failed, trying alternative method: {e}")
            
            # Fallback: try to merge specific ligature glyphs manually
            ligature_glyphs = []
            for glyph_name in ligature_font:
                glyph = ligature_font[glyph_name]
                # Look for ligature glyphs (usually have specific naming patterns)
                if (glyph.unicode < 0 and 
                    ('liga' in glyph_name or '_' in glyph_name or 
                     any(x in glyph_name.lower() for x in ['equal', 'greater', 'less', 'arrow', 'hyphen']))):
                    ligature_glyphs.append(glyph_name)
            
            print(f"  📊 Found {len(ligature_glyphs)} potential ligature glyphs")
            
            if ligature_glyphs:
                # Use FontForge's mergeFeature if available
                try:
                    input_font.mergeFeature(ligature_font_path)
                    print("✅ Successfully merged ligature features")
                except Exception as e:
                    print(f"❌ Feature merge failed: {e}")
                    return False
            else:
                print("❌ No ligature glyphs found in source font")
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