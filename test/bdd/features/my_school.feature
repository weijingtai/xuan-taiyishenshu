# language: zh-CN
@school-manager @AC11 @AC12 @AC16
功能: 我的流派
  作为太乙神数用户
  我希望复制或派生官方流派并创建自己的版本
  以便自定义积年参数和算法开关

  背景:
    假如 应用已启动并进入排盘页面

  @copy-school
  场景: 复制官方流派创建用户流派
    当 用户打开流派管理页面
    而且 用户点击"金镜派"旁的"复制"按钮
    那么 应弹出编辑对话框
    而且 名称应默认为"我的金镜派"
    当 用户修改名称为"太乙新法"
    而且 用户修改 ancientBase 为 2000000
    而且 用户点击"保存"
    那么 流派列表应出现"太乙新法"
    而且 官方"金镜派"不应被修改
    而且 "太乙新法"应有用户标识

  @school-lineage
  场景: 用户流派保存传承链
    当 用户复制官方流派"金镜派"并保存为"我的金镜派"
    而且 用户查看"我的金镜派"的详情
    那么 应显示传承路径"金镜派 > 我的金镜派"

  @school-chain
  场景: 从用户流派再次派生
    假如 用户已有"我的金镜派"
    当 用户复制"我的金镜派"并保存为"我的金镜派-实验二"
    而且 用户查看详情
    那么 应显示传承路径"金镜派 > 我的金镜派 > 我的金镜派-实验二"

  @school-editable-fields
  场景: 用户流派可编辑字段范围
    假如 用户已有"我的金镜派"
    当 用户编辑"我的金镜派"
    那么 应可修改以下字段:
      | 字段              | 说明           |
      | name              | 流派名称       |
      | description       | 描述           |
      | ancientBase       | 上元积年基数   |
      | epochYear         | 基准年         |
      | correction        | 修正值         |
      | tropicalYear      | 回归年长度     |
      | palaceFormula     | 太乙落宫公式   |
      | wenChangStayRule  | 文昌驻留       |
      | useTwelveJiShen   | 计神十二支     |
      | eightDoorMode     | 八门模式       |
      | hostGuestBase     | 客算基准       |
      | dayOffset         | 日计偏移       |
      | hourOffset        | 时计偏移       |
      | zhangSui          | 章岁           |
      | zhangYue          | 章月           |

  @official-school-readonly
  场景: 官方流派不可修改
    当 用户在流派列表中查看"金镜派"
    那么 "金镜派"不应有编辑按钮
    而且 "金镜派"不应有删除按钮
    而且 只应有"复制"按钮

  @switch-to-user-school
  场景: 切换到用户流派后重新排盘
    假如 用户已有"我的金镜派"（ancientBase 修改为 2000000）
    当 用户切换到"我的金镜派"
    那么 盘面应自动刷新
    而且 积年数应使用 ancientBase=2000000 计算
    而且 所有落宫应基于新积年数重新计算
