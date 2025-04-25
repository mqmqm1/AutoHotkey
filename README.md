#  FGO-Auto3T
FGO自动3t挂机脚本


需要更改战斗配置时，仅在skill_config.txt中进行更改，在运行应用时可以重新命名保存当前配置（便于切换）			||
																									||
战斗配置存放在configs文件夹里。保存配置时，默认将当前目录下的skill_config.txt内容存入configs文件夹。			||
																									||
游戏运行画面比例要求16:9（模拟器内置分辨率），同时关闭侧边菜单栏并以窗口化运行以获得最佳效果，			||
否则可能产生点击偏移																					||
																									||
若产生点击偏移可在偏移设置里自行微调。																	||
																									||
=========================================================================|

SupportName,光之高扬斯卡娅 	---------->选择助战

# Round 1   				---------------> 分隔战斗轮次(1,2,3)

UseSkill,1,1				---------------> 1号位使用1技能

UseSkill,2,3,2				---------------> 2号位使用3技能,释放对象为2号位

Attack  					---------------> 点击攻击键

UseNoblePhantasm1		--------------->使用1号位宝具
UseNoblePhantasm2		--------------->使用2号位宝具


MasterSkill_Atlas,3		--------------->冷却服（使用御主三技能，并选择3号位释放技能）

MasterSkill_AllBuff		--------------->全体加攻

MasterSkill_Change,3,1	--------------->换人服（将  ''前场3号''  与  ''候补1号''  调换）



示例：
SupportName,光之高扬斯卡娅


# Round 1
UseSkill,1,3
UseSkill,2,1
UseSkill,3,2,1
UseSkill,3,3,1
Attack
UseNoblePhantasm1

# Round 2
UseSkill,1,1
UseSkill,2,2,2
UseSkill,2,3
UseSkill,3,1,1
Attack
UseNoblePhantasm1

# Round 3
UseSkill,2,1,1
UseSkill,2,2,1
UseSkill,2,3,1
MasterSkill_Change,3,1
MasterSkill_AllBuff
UseSkill,3,1
UseSkill,3,2,1
UseSkill,3,3,1
UseSkill,1,3
Attack
UseNoblePhantasm1
