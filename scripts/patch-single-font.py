#!/usr/bin/env python3
"""
Google Sans Code Nerd Font - 单字体补丁脚本

这个脚本提供了一个Python接口来补丁单个字体文件，
可以作为构建脚本的后端，也可以独立使用。

作者: Google Sans Code Nerd Font Project
许可: MIT License
"""

import argparse
import json
import os
import subprocess
import sys
import time
from pathlib import Path
from typing import List, Dict, Optional


class FontPatcher:
    """字体补丁器类"""
    
    def __init__(self, config_file: Optional[str] = None):
        """
        初始化字体补丁器
        
        Args:
            config_file: 配置文件路径
        """
        self.script_dir = Path(__file__).parent
        self.project_dir = self.script_dir.parent
        self.patcher_script = self.project_dir / "src" / "font-patcher"
        self.glyphs_dir = self.project_dir / "src" / "glyphs"
        self.default_output_dir = self.project_dir / "patched-fonts"
        
        # 加载配置
        self.config = self._load_config(config_file)
        
        # 检查依赖
        self._check_dependencies()
    
    def _load_config(self, config_file: Optional[str]) -> Dict:
        """加载配置文件"""
        default_config = {
            "remove_ligatures": False,
            "custom_icons": [],
            "font_name_suffix": "Nerd Font",
            "font_name_mono_suffix": "Nerd Font Mono",
            "font_name_propo_suffix": "Nerd Font Propo",
            "output_dir": "patched-fonts",
            "temp_dir": "temp"
        }
        
        if config_file and Path(config_file).exists():
            try:
                with open(config_file, 'r', encoding='utf-8') as f:
                    user_config = json.load(f)
                default_config.update(user_config)
            except (json.JSONDecodeError, IOError) as e:
                print(f"警告: 无法加载配置文件 {config_file}: {e}")
        
        return default_config
    
    def _check_dependencies(self):
        """检查必要的依赖"""
        # 检查 FontForge
        try:
            subprocess.run(["fontforge", "--version"], 
                         capture_output=True, check=True)
        except (subprocess.CalledProcessError, FileNotFoundError):
            raise RuntimeError("FontForge 未安装或不在 PATH 中")
        
        # 检查 font-patcher 脚本
        if not self.patcher_script.exists():
            raise RuntimeError(f"未找到 font-patcher 脚本: {self.patcher_script}")
        
        # 检查字形目录
        if not self.glyphs_dir.exists() or not any(self.glyphs_dir.iterdir()):
            raise RuntimeError(f"未找到字形文件: {self.glyphs_dir}")
    
    def build_patcher_args(self, 
                          output_dir: str,
                          build_type: str = "complete",
                          icon_sets: Optional[List[str]] = None,
                          extra_args: Optional[List[str]] = None) -> List[str]:
        """
        构建 font-patcher 参数
        
        Args:
            output_dir: 输出目录
            build_type: 构建类型 (complete, mono, propo)
            icon_sets: 图标集列表
            extra_args: 额外参数
            
        Returns:
            参数列表
        """
        args = [
            "--quiet",
            "--glyphdir", str(self.glyphs_dir),
            "--outputdir", output_dir
        ]
        
        # 构建类型参数
        if build_type == "mono":
            args.extend(["--mono", "--complete"])
        elif build_type == "propo":
            args.extend(["--variable-width-glyphs", "--complete"])
        elif build_type == "complete":
            args.append("--complete")
        else:
            # 自定义图标集
            if icon_sets:
                for icon_set in icon_sets:
                    if icon_set in self._get_available_icon_sets():
                        args.append(f"--{icon_set}")
            else:
                # 默认包含所有图标
                args.append("--complete")
        
        # 额外参数
        if extra_args:
            args.extend(extra_args)
        
        # 处理配置选项
        if self.config.get("remove_ligatures", False):
            args.append("--removeligs")
        
        return args
    
    def _get_available_icon_sets(self) -> Dict[str, str]:
        """获取可用的图标集"""
        return {
            "fontawesome": "Font Awesome",
            "fontawesomeextension": "Font Awesome Extension", 
            "octicons": "Octicons (GitHub)",
            "codicons": "Codicons (VS Code)",
            "powerline": "Powerline",
            "powerlineextra": "Powerline Extra",
            "material": "Material Design Icons",
            "weather": "Weather Icons",
            "devicons": "Devicons",
            "pomicons": "Pomicons",
            "fontlogos": "Font Logos",
            "powersymbols": "IEC Power Symbols"
        }
    
    def patch_font(self,
                  font_file: str,
                  output_dir: Optional[str] = None,
                  build_type: str = "complete",
                  icon_sets: Optional[List[str]] = None,
                  extra_args: Optional[List[str]] = None,
                  verbose: bool = False) -> bool:
        """
        补丁单个字体文件
        
        Args:
            font_file: 字体文件路径
            output_dir: 输出目录
            build_type: 构建类型
            icon_sets: 图标集列表
            extra_args: 额外参数
            verbose: 详细输出
            
        Returns:
            是否成功
        """
        font_path = Path(font_file)
        
        if not font_path.exists():
            print(f"错误: 字体文件不存在: {font_file}")
            return False
        
        if not font_path.suffix.lower() in ['.ttf', '.otf']:
            print(f"错误: 不支持的字体格式: {font_path.suffix}")
            return False
        
        # 确定输出目录
        if not output_dir:
            output_dir = str(self.default_output_dir)
        
        # 创建输出目录
        Path(output_dir).mkdir(parents=True, exist_ok=True)
        
        # 构建参数
        patcher_args = self.build_patcher_args(
            output_dir=output_dir,
            build_type=build_type,
            icon_sets=icon_sets,
            extra_args=extra_args
        )
        
        # 构建命令
        cmd = [
            "fontforge",
            "-script",
            str(self.patcher_script)
        ] + patcher_args + [str(font_path)]
        
        if verbose:
            print(f"执行命令: {' '.join(cmd)}")
        
        # 执行补丁
        start_time = time.time()
        
        try:
            result = subprocess.run(
                cmd,
                capture_output=not verbose,
                text=True,
                check=False
            )
            
            end_time = time.time()
            duration = end_time - start_time
            
            if result.returncode == 0:
                if verbose:
                    print(f"✅ 成功补丁字体: {font_path.name} ({duration:.1f}秒)")
                return True
            else:
                print(f"❌ 补丁失败: {font_path.name}")
                if result.stderr and verbose:
                    print(f"错误信息: {result.stderr}")
                return False
                
        except Exception as e:
            print(f"❌ 执行失败: {e}")
            return False
    
    def get_font_info(self, font_file: str) -> Optional[Dict]:
        """
        获取字体信息
        
        Args:
            font_file: 字体文件路径
            
        Returns:
            字体信息字典
        """
        try:
            import fontTools.ttLib as ttLib
            
            font = ttLib.TTFont(font_file)
            name_table = font['name']
            
            # 提取字体名称
            font_family = None
            font_style = None
            
            for record in name_table.names:
                if record.nameID == 1:  # Font Family
                    if record.platformID == 3:  # Microsoft
                        font_family = record.toUnicode()
                elif record.nameID == 2:  # Font Subfamily
                    if record.platformID == 3:  # Microsoft
                        font_style = record.toUnicode()
            
            return {
                "family": font_family or "Unknown",
                "style": font_style or "Regular",
                "file": Path(font_file).name
            }
            
        except Exception as e:
            print(f"警告: 无法读取字体信息: {e}")
            return {
                "family": "Unknown",
                "style": "Unknown", 
                "file": Path(font_file).name
            }


def main():
    """主函数"""
    parser = argparse.ArgumentParser(
        description="Google Sans Code Nerd Font 单字体补丁工具",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
示例:
  # 补丁单个字体（完整版）
  python patch-single-font.py GoogleSansCode-Regular.ttf
  
  # 补丁为等宽版本
  python patch-single-font.py GoogleSansCode-Regular.ttf --type mono
  
  # 仅添加特定图标集
  python patch-single-font.py GoogleSansCode-Regular.ttf --icons fontawesome octicons
  
  # 自定义输出目录
  python patch-single-font.py GoogleSansCode-Regular.ttf --output my-fonts
        """
    )
    
    parser.add_argument(
        "font_file",
        help="要补丁的字体文件路径"
    )
    
    parser.add_argument(
        "--output", "-o",
        help="输出目录（默认: patched-fonts）"
    )
    
    parser.add_argument(
        "--type", "-t",
        choices=["complete", "mono", "propo"],
        default="complete",
        help="构建类型（默认: complete）"
    )
    
    parser.add_argument(
        "--icons", "-i",
        nargs="*",
        help="图标集列表（如果指定，则不使用 --type）"
    )
    
    parser.add_argument(
        "--config", "-c",
        help="配置文件路径"
    )
    
    parser.add_argument(
        "--verbose", "-v",
        action="store_true",
        help="详细输出"
    )
    
    parser.add_argument(
        "--info",
        action="store_true",
        help="显示字体信息并退出"
    )
    
    parser.add_argument(
        "--list-icons",
        action="store_true",
        help="列出可用的图标集并退出"
    )
    
    args = parser.parse_args()
    
    try:
        # 创建补丁器
        patcher = FontPatcher(config_file=args.config)
        
        # 列出图标集
        if args.list_icons:
            print("可用的图标集:")
            for key, name in patcher._get_available_icon_sets().items():
                print(f"  {key:<20} - {name}")
            return 0
        
        # 显示字体信息
        if args.info:
            info = patcher.get_font_info(args.font_file)
            if info:
                print(f"字体文件: {info['file']}")
                print(f"字体族: {info['family']}")
                print(f"样式: {info['style']}")
            return 0
        
        # 补丁字体
        success = patcher.patch_font(
            font_file=args.font_file,
            output_dir=args.output,
            build_type=args.type,
            icon_sets=args.icons,
            verbose=args.verbose
        )
        
        return 0 if success else 1
        
    except Exception as e:
        print(f"错误: {e}")
        return 1


if __name__ == "__main__":
    sys.exit(main())