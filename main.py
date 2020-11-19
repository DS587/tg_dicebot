# version should >python 3.6
import configparser
import re
import logging

from telegram.ext import Updater
from telegram.ext import CommandHandler
from telegram.ext import MessageHandler, Filters

import random

# 读取config.ini的预设
config = configparser.ConfigParser()
config.read('config.ini')


# 打开logging
logging.basicConfig(format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
                    level=logging.INFO)
logger = logging.getLogger(__name__)

# 初始化
updater = Updater(token=(config['TELEGRAM']['ACCESS_TOKEN']), use_context=True)
dispatcher = updater.dispatcher

# 函数部分
def start(update, context):
	context.bot.send_message(chat_id=update.effective_chat.id,text="👴有以下功能:\n        /dice    掷骰")

# 掷骰
def dice(update, context):
    try:
        if is_number(context.args[0]):
            number = random.randint(1, int(context.args[0]))
            if len(context.args)<2:
                text_number = number
            else:
                text_number = "针对 `" + " ".join(context.args[1:]) + "` 的投掷结果为： " + str(number)
        else:
            text_number = "没面数我骰个锤子"
    except IndexError:
        text_number = "没内容爬"

    
    context.bot.send_message(chat_id=update.effective_chat.id, reply_to_message_id=update.message.message_id, parse_mode="MarkdownV2", text=text_number)

# 关键字掷骰
def roll(update, context):
    # 先把省略输入次数或面数的初始化
    if context.match.group(1) == '':
        time = '1'
    else:
        time = context.match.group(1)
    if context.match.group(2) == '':
        dice = '100'
    else:
        dice = context.match.group(2)

    # 判断输入是否非法
    if time == '0' or dice == '0':
        text_number = "`非法输入给爷死`"
    else:
        i = 0
        num_list = []
        while i < int(time):
            num = random.randint(1,int(dice))
            num_list.append(num)
            i += 1

        num_list_new = [str(x) for x in num_list]

        # 修整输出
        if context.match.group(3) == '':
            text_number = " ".join(num_list_new)
        else:
            text_number = "针对 `" + context.match.group(3) + " ` 的投掷结果为： \n" + " ".join(num_list_new)

    context.bot.send_message(chat_id=update.effective_chat.id, reply_to_message_id=update.message.message_id, parse_mode="MarkdownV2", text=text_number)



# 针对没有功能的指令的回复
def unknown(update, context):
    context.bot.send_message(chat_id=update.effective_chat.id, reply_to_message_id=update.message.message_id, parse_mode="MarkdownV2", text="对8起做不到 `无此指令`")

# 上车
start_handler = CommandHandler('start', start)
dispatcher.add_handler(start_handler)

dice_handler = CommandHandler('dice', dice )
dispatcher.add_handler(dice_handler)

roll_handler = MessageHandler(Filters.regex(r"^.r([1-9]?\d?\d?)d([1-9]?\d?\d?)?(.*)"), roll)
dispatcher.add_handler(roll_handler)

unknown_handler = MessageHandler(Filters.command, unknown)
dispatcher.add_handler(unknown_handler)

# 运行
updater.start_polling()

# 审查
def is_number(s):
    try:
        int(s)
        return True
    except ValueError:
        pass
 
    return False

