#!/bin/bash

GRN='\033[0;32m'
CYA='\033[0;36m'
YEL='\033[1;33m'
NC='\033[0m'

clear
echo "Bir seçenek seçin:"
select secenekler in "Root kullanıcısı aktifleştirme" "PPPoE bilgileri öğrenme"
do
    case $secenekler in
        "Root kullanıcısı aktifleştirme")
            clear
            printf "!!! Internet e bağlı değilseniz devam etmeyin !!!\n"
            printf "!!! İşlem bittiğinde kullanıcı adı:$YEL sUser$NC Şifre:$YEL Solroot2024.$NC olacaktır!!!\n"
            printf "!!! Daha sonra dilerseniz şifreyi arayüzden değiştirebilirsiniz.!!!\n"
            printf "!!! Internet e bağlıysanız ilerlemek için$CYA Enter$NC 'a basın !!!\n"
            read ileri

            clear
            printf "Terminale $CYA ip addr$NC yazıp bakabilirsiniz çoğunlukla enp ile başlar.\n"
            printf "Ethernet kartı arayüzü adı: "
            read ethkarti

            clear
            printf "Terminale $CYA ip addr$NC yazıp bakabilirsiniz çoğunlukla w ile başlar.\n"
            printf "Wifi kartı arayüzü adı:  "
            read wifikarti

            apt update && apt install pppoe mitmproxy --assume-yes
            sudo pkill pppoe-server
            printf "\"fiber@fiber\"   *       \"fiber\"         *\n">/etc/ppp/pap-secrets
            printf "\"fiber@fiber\"   *       \"fiber\"         *\n">/etc/ppp/chap-secrets

            printf "ms-dns 213.74.1.1\n">/etc/ppp/pppoe-server-options
            printf "ms-dns 213.74.0.1\n">>/etc/ppp/pppoe-server-options
            printf "require-chap\n">>/etc/ppp/pppoe-server-options
            printf "lcp-echo-interval 10\n">>/etc/ppp/pppoe-server-options
            printf "lcp-echo-failure 2\n">>/etc/ppp/pppoe-server-options

            printf "asyncmap 0\n">/etc/ppp/options
            printf "auth\n">>/etc/ppp/options
            printf "crtscts\n">>/etc/ppp/options
            printf "lock\n">>/etc/ppp/options
            printf "hide-password\n">>/etc/ppp/options
            printf "modem\n">>/etc/ppp/options
            printf "%s\n" "-pap" >> /etc/ppp/options
            printf "+chap\n">>/etc/ppp/options
            printf "lcp-echo-interval 30\n">>/etc/ppp/options
            printf "lcp-echo-failure 4\n">>/etc/ppp/options
            printf "noipx\n">>/etc/ppp/options

            clear
            printf "\nUyarı: Wifi bağlantınızı yapmayı unutmayın, zaten ağa bağlıysanız devam etmek için$CYA Enter$NC 'a basın. "
            read ileri

            printf "\nSırasıyla; \n1 - Router ın$YEL WAN$NC kablosunu çıkarın ve bilgisayarınızın ethernet girişindeki ethernet kablosunu router ın wan portuna takın, \n2 - Router ı reset tuşuyla fabrika ayarlarına döndürün. \n3 - Ilerlemek için$CYA Enter$NC 'a basın."
            read ileri
            clear
            
            sudo sysctl net.ipv4.ip_forward=1
            sudo iptables -t nat -A POSTROUTING -o $wifikarti -j MASQUERADE
            sudo iptables -t nat -A PREROUTING -p tcp --dport 8015 -j REDIRECT --to-port 8080
            sudo pppoe-server -I $ethkarti -L 10.116.13.1 -R 10.116.13.100 -N 100
            clear

            printf "\nBundan sonraki adımda açılan ekranda bad request hatasını beklemelisiniz. \n O hatayı görürseniz işleminiz bitmiştir arayüzden $YEL sUser $NC kullanıcısına $YEL Solroot2024. $NC şifresi ile girebilirsiniz. \n İşlemi başlatmak için$CYA Enter$NC 'a basın.\n"
            read ileri

            sudo mitmproxy -s istek_degistirici.py -k --mode transparent --showhost --listen-port 8080

            printf "Umarım başarılı olmuşsundur aklına takılan birşey yada sormak istediğin birşey var ise $GRN https://ensty.site/hesaplar $NC üzerindeki hesaplardan bana ulaşabilirsin.\n"
            break
            ;;
        "PPPoE bilgileri öğrenme")
          clear
          printf "\nUyarı: Paketler kurulacaktır internetinizin bağlı olduğundan emin olun devam etmek için enter a basın."
          read ileri
          clear
          printf "Terminale $CYA ip addr$NC yazıp bakabilirsiniz çoğunlukla enp ile başlar.\n"
          printf "Ethernet kartı arayüzü adı: "
          read ethkarti
          sudo apt update && sudo apt install pppoe mitmproxy --assume-yes
          clear
            printf "ms-dns 213.74.1.1\n">/etc/ppp/pppoe-server-options
            printf "ms-dns 213.74.0.1\n">>/etc/ppp/pppoe-server-options
            printf "require-pap\n">>/etc/ppp/pppoe-server-options
            printf "lcp-echo-interval 10\n">>/etc/ppp/pppoe-server-options
            printf "lcp-echo-failure 2\n">>/etc/ppp/pppoe-server-options

            printf "asyncmap 0\n">/etc/ppp/options
            printf "auth\n">>/etc/ppp/options
            printf "crtscts\n">>/etc/ppp/options
            printf "lock\n">>/etc/ppp/options
            printf "show-password\n">>/etc/ppp/options
            printf "modem\n">>/etc/ppp/options
            printf "%s\n" "-chap" >> /etc/ppp/options
            printf "+pap\n">>/etc/ppp/options
            printf "lcp-echo-interval 30\n">>/etc/ppp/options
            printf "lcp-echo-failure 4\n">>/etc/ppp/options
            printf "noipx\n">>/etc/ppp/options
            printf "debug\n">>/etc/ppp/options
            printf "logfile /var/log/pppoe-server-log\n">>/etc/ppp/options
        sudo pppoe-server -I $ethkarti -L 10.116.13.1 -R 10.116.13.100 -N 100
        printf "\nPPPoE bağlantısı bekleniyor... Lütfen modemin wan portunu bilgisayarınıza bağlayınız"
        echo "" > /var/log/pppoe-server-log
        tail -f /var/log/pppoe-server-log | while read line; do
        if [[ "$line" =~ rcvd\ \[PAP\ AuthReq.*user=\"([^\"]+)\".*password=\"([^\"]+)\" ]]; then
        user="${BASH_REMATCH[1]}"
        password="${BASH_REMATCH[2]}"
        clear
        echo "PPPoE bilgileri alındı."
        echo ""
        echo "Kullanıcı adı: $user"
        echo "Şifre: $password"
        echo ""
        echo "Root için sudo bash h3600.sh komutunu tekrar kullanın"
        echo ""
        sudo pkill pppoe-server
    exit 0 
    fi
done
      break
            ;;
        *)
            echo "Geçersiz seçenek, lütfen tekrar deneyin."
            ;;
    esac
done
