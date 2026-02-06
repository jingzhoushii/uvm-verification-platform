#!/usr/bin/env python3
"""
File: gen_html_report.py
Description: 生成 HTML 回归测试报告
Author: UVM Verification Platform
Created: 2026-02-06
"""

import os
import json
import glob
from datetime import datetime


def generate_html_report(results_dir='results', output_file='report.html'):
    """生成 HTML 回归报告"""
    
    # 收集测试结果
    tests = []
    
    # 从 summary.log 读取
    summary_file = os.path.join(results_dir, 'summary.log')
    if os.path.exists(summary_file):
        with open(summary_file, 'r') as f:
            for line in f:
                line = line.strip()
                if ':' in line:
                    parts = line.split(':')
                    name = parts[0]
                    result = parts[1] if len(parts) > 1 else 'UNKNOWN'
                    duration = parts[2] if len(parts) > 2 else '0'
                    tests.append({
                        'name': name,
                        'result': result,
                        'duration': duration
                    })
    
    # 生成 HTML
    html = f"""<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>UVM Verification Platform - 回归测试报告</title>
    <style>
        body {{
            font-family: 'Segoe UI', Arial, sans-serif;
            margin: 0;
            padding: 20px;
            background: #f5f5f5;
        }}
        .container {{
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }}
        h1 {{
            color: #333;
            border-bottom: 3px solid #4CAF50;
            padding-bottom: 10px;
        }}
        .summary {{
            display: flex;
            gap: 20px;
            margin: 20px 0;
            padding: 20px;
            background: #f9f9f9;
            border-radius: 8px;
        }}
        .stat {{
            text-align: center;
            padding: 15px 25px;
            border-radius: 8px;
        }}
        .stat.passed {{ background: #dff0d8; }}
        .stat.failed {{ background: #f2dede; }}
        .stat.total {{ background: #d9edf7; }}
        .stat .number {{
            font-size: 36px;
            font-weight: bold;
        }}
        .stat .label {{
            color: #666;
            margin-top: 5px;
        }}
        table {{
            width: 100%;
            border-collapse: collapse;
            margin: 20px 0;
        }}
        th, td {{
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }}
        th {{
            background: #4CAF50;
            color: white;
        }}
        tr:hover {{ background: #f5f5f5; }}
        .pass {{ color: #3c763d; }}
        .fail {{ color: #a94442; }}
        .footer {{
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid #ddd;
            color: #666;
            text-align: center;
        }}
        .progress-bar {{
            width: 100%;
            height: 20px;
            background: #ddd;
            border-radius: 10px;
            overflow: hidden;
            margin: 10px 0;
        }}
        .progress {{
            height: 100%;
            background: #4CAF50;
        }}
    </style>
</head>
<body>
    <div class="container">
        <h1>UVM Verification Platform - 回归测试报告</h1>
        
        <div class="summary">
            <div class="stat total">
                <div class="number">{len(tests)}</div>
                <div class="label">总测试数</div>
            </div>
            <div class="stat passed">
                <div class="number">{sum(1 for t in tests if t['result'] == 'PASS')}</div>
                <div class="label">通过</div>
            </div>
            <div class="stat failed">
                <div class="number">{sum(1 for t in tests if t['result'] == 'FAIL')}</div>
                <div class="label">失败</div>
            </div>
        </div>
        
        <h2>测试详情</h2>
        <table>
            <tr>
                <th>测试名称</th>
                <th>结果</th>
                <th>耗时 (秒)</th>
            </tr>
"""
    
    for test in tests:
        status_class = 'pass' if test['result'] == 'PASS' else 'fail'
        html += f"""            <tr>
                <td>{test['name']}</td>
                <td class="{status_class}">{test['result']}</td>
                <td>{test['duration']}</td>
            </tr>
"""
    
    passed = sum(1 for t in tests if t['result'] == 'PASS')
    total = len(tests)
    pass_rate = (passed / total * 100) if total > 0 else 0
    
    html += f"""        </table>
        
        <div class="progress-bar">
            <div class="progress" style="width: {pass_rate}%"></div>
        </div>
        <p style="text-align: center;">通过率: {pass_rate:.1f}%</p>
        
        <div class="footer">
            <p>生成时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}</p>
            <p>UVM Verification Platform v1.0.3</p>
        </div>
    </div>
</body>
</html>
"""
    
    # 写入文件
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(html)
    
    print(f"✅ 报告已生成: {output_file}")
    return output_file


if __name__ == '__main__':
    import sys
    
    results_dir = 'results'
    output_file = 'report.html'
    
    if len(sys.argv) > 1:
        results_dir = sys.argv[1]
    if len(sys.argv) > 2:
        output_file = sys.argv[2]
    
    generate_html_report(results_dir, output_file)
