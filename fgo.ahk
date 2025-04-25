; ===========================
; FGO AHK - 配置管理 + 控制面板合并
; ===========================
#Requires AutoHotkey v2.0
#Include *i %A_ScriptDir%\index.ahk
#Include *i %A_ScriptDir%\BattleFlow.ahk
#NoTrayIcon
#SingleInstance Force

FileEncoding "UTF-8"    ; 设置文件编码为 UTF-8

; ===== 初始化配置目录 =====
CONFIG_DIR := A_ScriptDir "\configs"
CURRENT_CONFIG := A_ScriptDir "\skill_config.txt"
if !DirExist(CONFIG_DIR)
    DirCreate(CONFIG_DIR)

; ===== 全局变量 =====
global isRunning := false   ; 是否正在运行
global timer := 0       ; 定时器ID
global counter := 0     ; 计数器
global configList := [] ; 配置文件列表
global maxRunCount := 0


; ===== 创建 GUI 界面 =====
myGui := Gui("+AlwaysOnTop", "FGO-Auto3T")   ; 创建一个新的 GUI 窗口
myGui.SetFont("s10", "Microsoft YaHei") ; 设置字体

statusText := myGui.AddText("x30 y10 w150 h30", "等待开始...")  ; 状态文本

myGui.AddButton("x20 y50 w100 h40", "开始").OnEvent("Click", StartScript)           ; 开始按钮
myButtonStop := myGui.AddButton("x140 y50 w100 h40", "停止")    ; 停止按钮
myButtonStop.OnEvent("Click", StopScript)   ; 停止按钮事件
myButtonStop.Enabled := false   ; 默认禁用停止按钮
myGui.AddButton("x260 y50 w100 h40", "退出").OnEvent("Click", ExitScript)   ; 退出按钮

myGui.AddText("x20 y110", "当前配置:")      ; 当前配置文本
currentText := myGui.AddText("x100 y110 w260", "无")    ; 当前配置显示

myGui.AddText("x20 y220", "选择配置:")  ; 选择配置文本
cbConfigs := myGui.AddComboBox("x100 y220 w260 vSelectedConfig ReadOnly")    ; 配置下拉框

; ========== 体力回复 ==========
myGui.AddText("x20 y260", "体力回复:")  ; 体力回复
fruitBox := myGui.AddComboBox("x100 y260 w260 vFruitChoice Choose1 ReadOnly", ["黄金果实", "白银果实", "青铜果实"])
global SelectedFruit := "黄金果实"
fruitBox.OnEvent("Change", OnFruitChange)

; ========== 执行次数规划 ==========
myGui.AddText("x260 y10", "执行次数:")
inputMaxRuns := myGui.AddEdit("x320 y10 w40 vMaxRunCount", "0")  ; 默认值为 0 表示不限制


myGui.AddText("x20 y180", "新配置命名:")    ; 新配置命名文本
inputName := myGui.AddEdit("x100 y180 w260 vNewConfigName")  ; 新配置命名输入框

myGui.AddButton("x20 y140 w80", "保存为...").OnEvent("Click", SaveConfig)   ; 保存按钮
myGui.AddButton("x110 y140 w80", "读取配置").OnEvent("Click", LoadConfig)   ; 读取按钮
myGui.AddButton("x200 y140 w80", "删除配置").OnEvent("Click", DeleteConfig)  ; 删除按钮


; ========== 偏移微调 GUI（附加控件） ==========
GuiOffset := Gui("+AlwaysOnTop", "偏移设置")
GuiOffset.SetFont("s10", "Microsoft YaHei")
GuiOffset.Add("Text", "x10 y10 w120", "横向偏移 dx:")
EditDx := GuiOffset.Add("Edit", "x140 y10 w100", OffsetHandler.dx)
GuiOffset.Add("Text", "x10 y50 w120", "纵向偏移 dy:")
EditDy := GuiOffset.Add("Edit", "x140 y50 w100", OffsetHandler.dy)
btnApply := GuiOffset.AddButton("x10 y90 w230", "应用偏移设置")
btnApply.OnEvent("Click", OffsetApplyHandler)

; 添加外部入口按钮（用于集成到主 GUI）
if IsSet(myGui) {
    myGui.AddButton("x290 y140 w80", "偏移设置").OnEvent("Click", ShowOffsetGui)
}

OffsetApplyHandler(*) {
    dx := EditDx.Value
    dy := EditDy.Value
    OffsetHandler.SetOffsetFromGUI(Integer(dx), Integer(dy))
    MsgBox "偏移设置已应用: dx=" OffsetHandler.dx ", dy=" OffsetHandler.dy,"Tips", 0x1000
}

ShowOffsetGui(*) {
    GuiOffset.Show("w260 h140")
}

InitConfigList() ; 初始化配置列表
myGui.OnEvent("Close", ExitScript)  ; 直接关闭窗口时退出脚本


; ========== 创建 GUI 窗口 ==========
myGui.Show("w400 h300") ; 创建 GUI 窗口



; ===== 主控制逻辑 =====
StartScript(*) {
    global isRunning, timer, counter, statusText, myButtonStop,maxRunCount

    if isRunning
        return

    isRunning := true
    counter := 0
    maxRunCount := inputMaxRuns.Value  ; 从 GUI 获取执行次数限制
    maxRunCount := Integer(maxRunCount)
    statusText.Text := "状态: 运行中..."
    myButtonStop.Enabled := true

    StartBattle()
    if !isRunning
        return
    SetTimer(StartBattle, 5000)
}

StopScript(*) {
    global isRunning, statusText, myButtonStop

    if !isRunning
        return

    isRunning := false
    SetTimer(StartBattle, 0)
    statusText.Text := "状态: 已停止"
    myButtonStop.Enabled := false
}

ExitScript(*) {
    global isRunning
    if isRunning
        SetTimer(StartBattle, 0)
    ExitApp
}

; ===== 配置文件管理逻辑 =====

InitConfigList() {
    global configList, cbConfigs
    configList := []    ; 清空配置列表
    cbConfigs.Delete()  ; 清空下拉框
    Loop Files CONFIG_DIR "\*_config.txt" {  ; 遍历配置文件
        name := RegExReplace(A_LoopFileName, "^(.*)_config\.txt$", "$1")    ; 提取文件名
        configList.Push(name)
        cbConfigs.Add([name])
    }
}

SaveConfig(*) {
    global inputName
    name := Trim(inputName.Value)   ; 获取输入的配置名
    if name = "" {
        MsgBox "请输入配置名","Tips", 0x1000
       
        return
    }
    dest := CONFIG_DIR "\" name "_config.txt"   ; 需要保存的配置文件路径
    try FileCopy(CURRENT_CONFIG, dest, true)    ; 复制 当前配置文件 到 配置库的路径        
    catch {
        MsgBox "保存失败，可能是配置文件不存在","Tips", 0x1000
       
        return
    }
    MsgBox "配置已保存为：" name,"Tips", 0x1000
   
    InitConfigList()
}

LoadConfig(*) {
    global cbConfigs, currentText
    name := Trim(cbConfigs.Text)    ; 获取下拉框选中的配置名
    if name = "" {
        MsgBox "请选择一个配置","Tips", 0x1000
        
        return
    }
    
    src := CONFIG_DIR "\" name "_config.txt"    ; 已保存过的配置文件路径
    try FileCopy(src, CURRENT_CONFIG, true)     ;从 已保存过的配置文件库 中 复制到当前配置文件
    catch {
        MsgBox "加载失败，文件不存在","Tips", 0x1000
        
        return
    }
    currentText.Value := name
    MsgBox "已加载配置：" name,"Tips", 0x1000     ; 显示加载提示
    
}

DeleteConfig(*) {
    global cbConfigs
    name := Trim(cbConfigs.Text)
    if name = "" {
        MsgBox "请选择要删除的配置","Tips", 0x1000
       
        return
    }
    file := CONFIG_DIR "\" name "_config.txt"   ; 要删除的配置文件路径
    try FileDelete(file)
    catch {
        MsgBox "删除失败","Tips", 0x1000
        
        return
    }
    MsgBox "配置已删除：" name,"Tips", 0x1000
   
    InitConfigList()
}


OnFruitChange(*) {
    global SelectedFruit, myGui
    SelectedFruit := myGui.Submit(false).FruitChoice
    
}




