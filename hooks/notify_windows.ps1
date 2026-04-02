# ==============================================================================
#  Claude Code 通知系统 - Windows 版
#  使用 BurntToast 发送 Toast 通知
#  前置要求：Install-Module -Name BurntToast -Force -Scope CurrentUser
# ==============================================================================

$inputData = [Console]::In.ReadToEnd() | ConvertFrom-Json
$eventName = $inputData.hook_event_name

# 处理 Notification 事件 (需要授权时)
if ($eventName -eq "Notification") {
    $notificationType = $inputData.notification_type
    $message = $inputData.message

    if ($message.Length -gt 100) {
        $message = $message.Substring(0, 97) + "..."
    }

    switch ($notificationType) {
        "permission_prompt" { $title = "Claude Code ⚠️ 需要授权" }
        "idle_prompt"       { $title = "Claude Code 💤 等待输入" }
        default             { $title = "Claude Code 📢" }
    }

    New-BurntToastNotification -Text $title, $message -Sound Default
    exit 0
}

# 处理 Stop 事件 (任务完成时)
if ($eventName -eq "Stop") {
    $transcriptPath = $inputData.transcript_path
    $summary = ""
    $filesModified = @()
    $filesCreated = @()

    if (Test-Path $transcriptPath) {
        Get-Content $transcriptPath | ForEach-Object {
            try {
                $msg = $_ | ConvertFrom-Json
                if ($msg.type -eq "assistant") {
                    $content = $msg.message.content
                    foreach ($item in $content) {
                        # 提取摘要（取最后一条有效文本行）
                        if ($item.type -eq "text") {
                            $lines = $item.text -split "`n" | Where-Object {
                                $_.Trim() -and
                                -not $_.TrimStart().StartsWith('`') -and
                                -not $_.StartsWith('---') -and
                                -not $_.StartsWith('|')
                            }
                            if ($lines.Count -gt 0) {
                                $line = $lines[0].Trim()
                                $summary = $line.Substring(0, [Math]::Min(60, $line.Length))
                            }
                        }
                        # 统计文件操作
                        if ($item.type -eq "tool_use" -and $item.input.file_path) {
                            $fileName = Split-Path $item.input.file_path -Leaf
                            if ($item.name -eq "Write") { $filesCreated += $fileName }
                            elseif ($item.name -eq "Edit") { $filesModified += $fileName }
                        }
                    }
                }
            } catch { }
        }
    }

    # 构建通知消息
    $parts = @()
    if ($summary) { $parts += $summary }

    if ($filesCreated.Count -gt 0) {
        if ($filesCreated.Count -le 2) {
            $parts += "创建: " + ($filesCreated | Select-Object -First 2 | Join-String -Separator ", ")
        } else {
            $parts += "创建 $($filesCreated.Count) 个文件"
        }
    }
    if ($filesModified.Count -gt 0) {
        if ($filesModified.Count -le 2) {
            $parts += "修改: " + ($filesModified | Select-Object -First 2 | Join-String -Separator ", ")
        } else {
            $parts += "修改 $($filesModified.Count) 个文件"
        }
    }

    $message = if ($parts.Count -gt 0) { $parts -join " | " } else { "任务已完成" }
    if ($message.Length -gt 150) { $message = $message.Substring(0, 147) + "..." }

    New-BurntToastNotification -Text "Claude Code ✓", $message -Sound Default
    exit 0
}

exit 0
