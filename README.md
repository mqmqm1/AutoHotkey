# FGO 自动化战斗脚本使用说明

> 本脚本基于 AutoHotkey v2 编写，支持技能配置文件切换、偏移校准、自定义助战识别等功能。

---

## 🔧 战斗配置说明（`skill_config.txt`）

战斗配置建议放在 `/configs` 文件夹内，通过程序 GUI 可保存/切换命名配置。

游戏运行建议为 **16:9 模拟器窗口化** + **关闭右侧菜单栏** 以避免坐标偏移问题。若存在坐标不准，请手动在偏移设置中调整。

---

### 📄 配置文件示例：

```ini
SupportName,光之高扬斯卡娅   ; 指定助战识别角色

# Round 1
UseSkill,1,1           ; 一号位 → 技能1
UseSkill,2,3,2         ; 二号位 → 技能3，目标为2号位
Attack
UseNoblePhantasm1      ; 使用宝具1
UseNoblePhantasm2      ; 使用宝具2

MasterSkill_Atlas,3    ; 使用冷却服技能，目标为3号位
MasterSkill_AllBuff    ; 全体攻击加成
MasterSkill_Change,3,1 ; 换人服 → 将前场3号与候补1号交换
