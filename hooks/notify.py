#!/usr/bin/env python3
# ==============================================================================
#  Claude Code 智能通知系统
#  处理任务完成 (Stop) 和权限请求 (Notification) 事件
# ==============================================================================

import json
import sys
import subprocess
import os
import platform
from pathlib import Path
from collections import Counter

# ==============================================================================
#  终端 Bundle ID 映射 (用于点击跳转)
# ==============================================================================
TERMINAL_BUNDLE_IDS = {
    "Apple_Terminal": "com.apple.Terminal",
    "iTerm.app": "com.googlecode.iterm2",
    "WarpTerminal": "dev.warp.Warp-Stable",
    "Alacritty": "io.alacritty",
    "kitty": "net.kovidgoyal.kitty",
    "Hyper": "co.zeit.hyper",
    "vscode": "com.microsoft.VSCode",
    "cursor": "com.todesktop.230313mzl4w4u92",
    "zed": "dev.zed.Zed",
}

def get_terminal_bundle_id() -> "str | None":
    """检测当前终端应用的 Bundle ID（仅 macOS 使用）"""
    term_program = os.environ.get("TERM_PROGRAM", "")

    # Cursor 和 VSCode 都报告 TERM_PROGRAM=vscode
    # 用 CURSOR_TRACE_ID 区分
    if term_program == "vscode":
        if os.environ.get("CURSOR_TRACE_ID"):
            return TERMINAL_BUNDLE_IDS["cursor"]
        return TERMINAL_BUNDLE_IDS["vscode"]

    return TERMINAL_BUNDLE_IDS.get(term_program)

def extract_first_line(text: str, max_len: int = 60) -> str:
    """提取文本第一行，去除 markdown 格式"""
    if not text:
        return ""

    lines = text.strip().split('\n')
    for line in lines:
        line = line.strip()
        # 跳过空行、分隔线、代码块标记、表格
        if not line or line.startswith('`') or line.startswith('---') or line.startswith('|'):
            continue
        if set(line) <= set('| -: '):
            continue

        result = line[:max_len].strip()
        if len(line) > max_len:
            result += "..."
        return result

    return ""

def parse_transcript(transcript_path: str) -> dict:
    """解析 transcript 文件，提取关键信息"""
    stats = {
        "assistant_summary": "",
        "files_modified": set(),
        "files_created": set(),
        "tools_used": Counter(),
        "total_turns": 0,
    }

    try:
        with open(transcript_path, 'r', encoding='utf-8') as f:
            for line in f:
                if not line.strip():
                    continue
                try:
                    msg = json.loads(line)
                except json.JSONDecodeError:
                    continue

                msg_type = msg.get("type", "")

                if msg_type == "user":
                    stats["total_turns"] += 1

                elif msg_type == "assistant":
                    content_list = msg.get("message", {}).get("content", [])
                    if isinstance(content_list, list):
                        for item in content_list:
                            if item.get("type") == "text":
                                text = item.get("text", "")
                                summary = extract_first_line(text)
                                if summary:
                                    stats["assistant_summary"] = summary

                            elif item.get("type") == "tool_use":
                                tool_name = item.get("name", "unknown")
                                stats["tools_used"][tool_name] += 1

                                tool_input = item.get("input", {})
                                file_path = tool_input.get("file_path", "")

                                if file_path:
                                    file_name = Path(file_path).name
                                    if tool_name == "Write":
                                        stats["files_created"].add(file_name)
                                    elif tool_name == "Edit":
                                        stats["files_modified"].add(file_name)
    except FileNotFoundError:
        pass
    except Exception:
        pass

    return stats

def generate_notification_message(stats: dict) -> tuple[str, str]:
    """生成通知标题和内容"""
    title = "Claude Code ✓"
    parts = []

    if stats["assistant_summary"]:
        parts.append(stats["assistant_summary"])

    file_actions = []
    if stats["files_created"]:
        count = len(stats["files_created"])
        if count <= 2:
            file_actions.append(f"创建: {', '.join(stats['files_created'])}")
        else:
            file_actions.append(f"创建 {count} 个文件")

    if stats["files_modified"]:
        count = len(stats["files_modified"])
        if count <= 2:
            file_actions.append(f"修改: {', '.join(stats['files_modified'])}")
        else:
            file_actions.append(f"修改 {count} 个文件")

    if file_actions:
        parts.append(" | ".join(file_actions))

    if not parts:
        message = "任务已完成"
    else:
        message = "\n".join(parts)

    if len(message) > 150:
        message = message[:147] + "..."

    return title, message

def send_notification_macos(title: str, message: str):
    """发送 macOS 通知，使用 terminal-notifier，点击可跳转回终端"""
    # 尝试 Apple Silicon 和 Intel 两个路径
    notifier = "/opt/homebrew/bin/terminal-notifier"
    if not os.path.exists(notifier):
        notifier = "/usr/local/bin/terminal-notifier"

    cmd = [
        notifier,
        "-title", title,
        "-message", message,
        "-sound", "default",
        "-group", "claude-code"
    ]

    bundle_id = get_terminal_bundle_id()
    if bundle_id:
        cmd.extend(["-activate", bundle_id])

    subprocess.run(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)


def send_notification_windows(title: str, message: str):
    """发送 Windows Toast 通知，使用 PowerShell"""
    # 转义单引号，防止 PowerShell 注入
    safe_title = title.replace("'", "''")
    safe_message = message.replace("'", "''")

    ps_script = f"""
$ErrorActionPreference = 'SilentlyContinue'
[Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
$template = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent(
    [Windows.UI.Notifications.ToastTemplateType]::ToastText02
)
$xml = [xml]$template.GetXml()
$xml.GetElementsByTagName('text')[0].AppendChild($xml.CreateTextNode('{safe_title}')) | Out-Null
$xml.GetElementsByTagName('text')[1].AppendChild($xml.CreateTextNode('{safe_message}')) | Out-Null
$toast = [Windows.UI.Notifications.ToastNotification]::new($template)
$notifier = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier('Claude Code')
$notifier.Show($toast)
"""
    subprocess.run(
        ["powershell", "-NonInteractive", "-WindowStyle", "Hidden", "-Command", ps_script],
        stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL
    )


def send_notification_linux(title: str, message: str):
    """发送 Linux 桌面通知，使用 notify-send"""
    subprocess.run(
        ["notify-send", "-a", "Claude Code", title, message],
        stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL
    )


def send_notification(title: str, message: str):
    """跨平台发送系统通知（macOS / Windows / Linux）"""
    system = platform.system()
    if system == "Darwin":
        send_notification_macos(title, message)
    elif system == "Windows":
        send_notification_windows(title, message)
    else:
        send_notification_linux(title, message)

def main():
    try:
        input_data = json.load(sys.stdin)
    except json.JSONDecodeError:
        sys.exit(0)

    event_name = input_data.get("hook_event_name", "")

    # 处理 Notification 事件 (需要用户确认时)
    if event_name == "Notification":
        notification_type = input_data.get("notification_type", "")
        message = input_data.get("message", "需要确认")

        # 根据通知类型设置不同标题
        if notification_type == "permission_prompt":
            title = "Claude Code ⚠️ 需要授权"
        elif notification_type == "idle_prompt":
            title = "Claude Code 💤 等待输入"
        else:
            title = "Claude Code 📢"

        # 截断消息长度
        if len(message) > 100:
            message = message[:97] + "..."

        send_notification(title, message)
        sys.exit(0)

    # 处理 Stop 事件 (任务完成时)
    if event_name == "Stop":
        transcript_path = input_data.get("transcript_path", "")
        stats = parse_transcript(transcript_path)
        title, message = generate_notification_message(stats)
        send_notification(title, message)
        sys.exit(0)

    sys.exit(0)

if __name__ == "__main__":
    main()
