#Requires AutoHotkey v2.0
#Include *i %A_ScriptDir%\index.ahk
; 战斗逻辑
StartBattle() {
    global counter, isRunning, statusText
    ; 缩放系数初始化
    OffsetHandler.UpdateScale()
    if !isRunning
        return
    
    counter += 1
    statusText.Text := "状态: 运行中 (第 " counter " 次)"
    
    try {
        ; 第一轮操作
        if (GameManager.WaitForText("攻击")) {
            if !isRunning
                return
        LoadAndExecuteSkillsFromTxt("Round 1")  ;从外部配置文件加载技能并执行
            if !isRunning
                return
        } else {
            MsgBox "第一轮未找到'攻击'","Tips", 0x1000
            return
        }
        
        ; 第二轮操作
        if (GameManager.WaitForText("攻击")) {
            if !isRunning
                return
        LoadAndExecuteSkillsFromTxt("Round 2")  ;从外部配置文件加载技能并执行
            if !isRunning
                return
        } else {
            MsgBox "第二轮未找到'攻击'","Tips", 0x1000
            return
        }
        
        ; 第三轮操作
        if (GameManager.WaitForText("攻击")) {
            if !isRunning
                return
        LoadAndExecuteSkillsFromTxt("Round 3")  ;从外部配置文件加载技能并执行
            if !isRunning
                return
        } else {
            MsgBox "第三轮未找到'攻击'","Tips", 0x1000
            return
        }
        
        ; 结算流程
        if GameManager.WaitForText("请点击游戏界面") {
           loop 4
            {
                MouseHandler.ClientClick(985,965)  ; 点击
                sleep 500
            } ; 点击空白处
           
        }
       
        if !isRunning
            return
        
        if !GameManager.WaitForTextAndClick("下一步") {
            MsgBox "未检测到'下一步'","Tips", 0x1000
            return
        }

        Sleep 1000  ; 等待1秒，确保界面稳定
        if !isRunning
            return
        
        if (maxRunCount > 0 && counter >= maxRunCount) {
            StopScript()
            MsgBox "已完成 " maxRunCount " 次执行，自动停止。", "提示", 0x1000
        }

        if !isRunning
            return
        
        ; 处理非好友助战后的结束按钮
        if OCRHandler.ocrRecognize("结束") {
            GameManager.WaitForTextAndClick("结束")
        }
        Sleep 2000  ; 等待3秒，确保界面稳定

        if !isRunning
            return

        

        if !GameManager.WaitForTextAndClick("连续出击") {
            MsgBox "未检测到'连续出击'","Tips", 0x1000
            return
        }

        if !isRunning
            return
        
        ; 处理体力
        if OCRHandler.ocrRecognize("黄金果实") {
            UseFruit(SelectedFruit)
        }
        Sleep 2000  ; 等待3秒，确保界面稳定
        if !isRunning
            return
       
        
        ; 选择助战
        ; 选择助战（从配置读取）
        servantName := GetSupportServantNameFromTxt()

        if servantName != "" {
            SelectSupport(servantName)
        } else {
            MsgBox "未在 skill_config.txt 中找到 SupportName 配置，跳过助战选择。","Tips", 0x1000
        }


        if !isRunning
            return
    } catch as e {
        MsgBox "发生错误: " e.Message
        
    }
}








