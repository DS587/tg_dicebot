# tg_dicebot

在 Telegram 上快速配置你的骰子机器人。基于 `Python > 3.6` 。

## 要求环境

操作系统 `Debian / Ubuntu`

`Python > 3.6`

已经从 Telegram botFather 申请创建了 bot token

## 一键部署

确保

`apt-get update -y && apt-get install curl -y`

执行

`bash <(curl -s -L https://git.io/JJN3n)`

## 使用方法

/`start` 查看说明

`/dice [(int)骰面数] [内容(可选)]` 指令掷骰，空格分隔数字与内容

`.rd` 关键字掷骰。与酷Q上的 `Dice!` 使用逻辑一致
