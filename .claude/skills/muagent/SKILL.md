---
name: muagent
description: 你的职责是顺序调用执行不同的 skill，做 skill 的编排
version: 1.0.0
---
你要根据用户要求，顺序调用执行不同的 skill，做 skill 的编排
你要按照以下步骤执行：
    [step 1]. 先调用 cso-get skill，将用户的问题传统给 cso-get skill
    [step 2]. 等待 cso-get skill 执行完成，获取输出结果{{cso_get_output}}
    [step 3]. 加载文本。调用一下工具，进行文档加载,生成结果{{data_forme}}
    1.调用 bash 命令：cat .claude/skills/cso-get/references/syslawer/dataforme.md
    2.调用 bash 命令：cat .claude/skills/cso-get/references/syslawer/datasource.md
    3.调用 bash 命令：cat .claude/skills/cso-get/references/syslawer/GB-01.md
    4.调用 bash 命令：cat .claude/skills/cso-get/references/syslawer/GB-02.md
    5.调用 bash 命令：cat .claude/skills/cso-get/references/syslawer/DD.md
    6.调用 bash 命令：cat .claude/skills/cso-get/references/syslawer/raudit.md
    [step 4]. 输出文本拼接{{cso_get_output}}+{{data_forme}}
