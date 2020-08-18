#!/bin/bash

red='\e[91m'
green='\e[92m'
yellow='\e[93m'
magenta='\e[95m'
cyan='\e[96m'
none='\e[0m'
sh_url="https://raw.githubusercontent.com/DS587/tg_dicebot/master/main.py"
Abstract="..........Dice! Telegram 一键部署脚本 by DS ..........

项目地址: https://github.com/DS587/tg_dicebot

1. 安装
2. 卸载"

_install_service() {
  cat >/lib/systemd/system/tgdicebot.service <<-EOF
[Unit]
Description=tgdicebot Service
After=network.target
Wants=network.target
[Service]
Type=simple
PIDFile=/var/run/tgdicebot.pid
WorkingDirectory=/usr/local/etc/tg_dicebot
ExecStart=/usr/local/bin/pipenv run python3 /usr/local/etc/tg_dicebot/main.py
RestartSec=3
Restart=always
LimitNOFILE=1048576
LimitNPROC=512
[Install]
WantedBy=multi-user.target
EOF
  systemctl enable tgdicebot
  systemctl restart tgdicebot
}

error() {
echo -e "\n$red 输入错误！$none\n"
}

install() {
    if [[ -d python && $(python -V | sed 's/Python//') < 3.6 ]] && [[ -d python3 && $(python3 -V | sed 's/Python//') < 3.6 ]]; then
        echo "Python 版本<3.6，不符合部署条件"
        read -p "$(echo -e "是否更新Python版本？ [${magenta}y/n$none]")" choose_py37
        case $choose_py37 in
        y)
            install_python37
            break
            ;;
        n)
            break
            ;;
        *)
            error
            ;;
        esac
    else
        read -p "$(echo -e "请输入机器人TOKEN(务必填写正确): ")" api_token
        if [[ -z $api_token ]];then
            error
            echo "退出脚本"
            exit
        else
            token=$api_token
        fi

        echo "..........开始安装.........."
        read -rsp "$(echo -e "按$green Enter 回车键 $none继续....或按$red Ctrl + C $none取消.")" -d $'\n'
        if [[ $(which pipenv) == '' ]]; then 
            echo "开始安装环境管理工具 pipenv"

            if [[ $(which pip3) == '' ]]; then
                apt install python3-pip -y
            fi
            pip3 install pipenv
        fi

        mkdir /usr/local/etc/tg_dicebot
        cd /usr/local/etc/tg_dicebot
        touch config.ini
        echo '[TELEGRAM]' >> config.ini
        echo 'ACCESS_TOKEN = '$token >> config.ini
        wget $sh_url
        pipenv install --three python-telegram-bot
        _install_service
    fi
}

uninstall() {
    if [[ -d "/usr/local/etc/tg_dicebot" ]]; then
        systemctl stop tgdicebot
        rm -rf /usr/local/etc/tg_dicebot
        echo "卸载成功"
    else
        echo "您还未安装本服务"
        read -rsp "$(echo -e "$red 退出脚本..... $none.")" -d $'\n'
    fi

}

install_python37() {
    apt-get install python3.7
    rm -rf /usr/bin/python3
    rm -rf /usr/bin/pip3
    py37_path=$(which python3.7)

    ln -s $py37_path /usr/bin/python3

    if [[$(python3 -V) == '' ]]; then
        echo "升级至Python 3.7失败！请手动检查环境！"
        read -rsp "$(echo -e "$red 退出脚本..... $none.")" -d $'\n'
    fi
}

while :; do
    echo "${Abstract}"
    read -p "$(echo -e "请选择 [${magenta}1-2$none]:")" choose
    case $choose in
    1)
        install
        break
        ;;
    2)
        uninstall
        break
        ;;
    *)
        error
        ;;
    esac
done
