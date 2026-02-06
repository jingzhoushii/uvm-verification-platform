#!/usr/bin/env python3
"""
File: parse_log.py
Description: 仿真日志分析工具
Author: UVM Verification Platform
Created: 2026-02-06
"""

import re
import sys
import argparse
from collections import Counter
from datetime import datetime


class LogParser:
    """仿真日志解析器"""
    
    def __init__(self, log_file):
        self.log_file = log_file
        self.lines = []
        self.errors = []
        self.warnings = []
        self.info = []
        
    def load(self):
        """加载日志文件"""
        try:
            with open(self.log_file, 'r', encoding='utf-8', errors='ignore') as f:
                self.lines = f.readlines()
        except FileNotFoundError:
            print(f"错误: 文件不存在 - {self.log_file}")
            sys.exit(1)
        except Exception as e:
            print(f"错误: 读取文件失败 - {e}")
            sys.exit(1)
    
    def parse(self):
        """解析日志"""
        for line in self.lines:
            line = line.strip()
            
            if '[ERROR]' in line or 'UVM_ERROR' in line.upper():
                self.errors.append(line)
            elif '[WARN]' in line or 'UVM_WARNING' in line.upper():
                self.warnings.append(line)
            elif '[INFO]' in line or 'UVM_INFO' in line.upper():
                self.info.append(line)
    
    def print_summary(self):
        """打印摘要"""
        print("\n" + "="*60)
        print("UVM Verification Platform - 日志分析报告")
        print("="*60)
        print(f"\n日志文件: {self.log_file}")
        print(f"总行数: {len(self.lines)}")
        print(f"错误数: {len(self.errors)}")
        print(f"警告数: {len(self.warnings)}")
        print(f"信息数: {len(self.info)}")
        
        # 测试结果检查
        if any('TEST PASSED' in line for line in self.lines):
            print("\n✅ 测试结果: 通过")
        elif any('TEST FAILED' in line for line in self.lines):
            print("\n❌ 测试结果: 失败")
        else:
            print("\n⚠️ 测试结果: 不确定")
        
        print("\n" + "="*60)
    
    def print_errors(self, limit=10):
        """打印错误"""
        if not self.errors:
            print("\n✅ 没有错误")
            return
            
        print(f"\n错误 (前 {limit} 个):")
        print("-" * 60)
        for i, error in enumerate(self.errors[:limit], 1):
            print(f"{i}. {error}")
        
        if len(self.errors) > limit:
            print(f"\n... 还有 {len(self.errors) - limit} 个错误")
    
    def print_warnings(self, limit=10):
        """打印警告"""
        if not self.warnings:
            print("\n✅ 没有警告")
            return
            
        print(f"\n警告 (前 {limit} 个):")
        print("-" * 60)
        for i, warning in enumerate(self.warnings[:limit], 1):
            print(f"{i}. {warning}")
    
    def extract_uvm_info(self):
        """提取 UVM 信息"""
        print("\nUVM 信息统计:")
        print("-" * 60)
        
        # 统计组件
        components = Counter()
        for line in self.info:
            match = re.search(r'\[(\w+)\]', line)
            if match:
                components[match.group(1)] += 1
        
        for comp, count in components.most_common(10):
            print(f"  {comp}: {count}")
    
    def generate_report(self, output_file):
        """生成报告"""
        report = []
        report.append("UVM Verification Platform - 日志分析报告")
        report.append("=" * 60)
        report.append(f"\n生成时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        report.append(f"日志文件: {self.log_file}")
        report.append(f"总行数: {len(self.lines)}")
        report.append(f"错误数: {len(self.errors)}")
        report.append(f"警告数: {len(self.warnings)}")
        report.append(f"信息数: {len(self.info)}")
        
        if self.errors:
            report.append("\n错误:")
            for error in self.errors[:20]:
                report.append(f"  - {error}")
        
        try:
            with open(output_file, 'w', encoding='utf-8') as f:
                f.write('\n'.join(report))
            print(f"\n报告已生成: {output_file}")
        except Exception as e:
            print(f"错误: 生成报告失败 - {e}")


def main():
    parser = argparse.ArgumentParser(
        description='UVM 仿真日志分析工具'
    )
    parser.add_argument('log_file', nargs='?', default='sim/vcs/simv.log',
                       help='日志文件路径')
    parser.add_argument('-e', '--errors', action='store_true',
                       help='只显示错误')
    parser.add_argument('-w', '--warnings', action='store_true',
                       help='只显示警告')
    parser.add_argument('-o', '--output', 
                       help='输出报告文件')
    parser.add_argument('-q', '--quiet', action='store_true',
                       help='安静模式（只显示摘要）')
    
    args = parser.parse_args()
    
    # 解析日志
    parser_obj = LogParser(args.log_file)
    parser_obj.load()
    parser_obj.parse()
    
    # 显示结果
    if not args.quiet:
        parser_obj.print_summary()
        
        if not args.warnings:
            parser_obj.print_errors()
        
        if not args.errors:
            parser_obj.print_warnings()
        
        parser_obj.extract_uvm_info()
    
    # 生成报告
    if args.output:
        parser_obj.generate_report(args.output)


if __name__ == '__main__':
    main()
