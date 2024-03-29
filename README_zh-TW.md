# palworld-docker
[English](./README.md) | `繁體中文`

一個可以輕鬆運行 Palworld 專用伺服器的 Docker 容器  
如果需要安裝教學可以[在此查看](https://forum.gamer.com.tw/C.php?bsn=71458&snA=193)  
[在 Docker Hub 上查看](https://hub.docker.com/r/hmes98318/palworld-docker)  


## Environments
| 環境變量                  | 描述                                 | 預設值         | 允許值             |
|------------------------|------------------------------------|--------------|---------------------|
| CHECK_UPDATE_ON_START  | 是否在每次啟動時自動檢查遊戲更新         | true         | true/false          |
| PORT                   | 伺服器監聽端口                       | 8211            | 0-65535             |
| PLAYERS                | 最大玩家數                           | 16              | 1-32                |
| MULTITHREAD            | 是否啟用多線程                       | true            | true/false          |
| ADMIN_PASSWORD         | 伺服器管理員密碼                     | None            | string                 |
| SERVER_NAME            | 伺服器名稱                         | string            | string                 |
| SERVER_DESC            | 伺服器描述                         | string            | string                 |
| SERVER_PASSWORD        | 伺服器密碼                         | None            | string                 |
| COMMUNITY              | 是否顯示在社群伺服器清單中 (請設定 SERVER_PASSWORD)    | false       | true/false           |
| COMMUNITY_IP           | 社群伺服器的 IP 地址               | None              | string                 |
| COMMUNITY_PORT         | 社群伺服器的端口號                 | 8211              | 0-65535              |
| RCON_ENABLED           | 啟用伺服器的 RCON 功能             | true              | true/false           |
| RCON_PORT              | RCON 端口號                        | 25575             | 0-65535              |

### 首次啟動將會下載 Palworld 伺服器文件，可能需要一些時間 (取決於你的網絡狀況)


## Volumes
| 容器掛載點                          | 描述              |
|----------------------------------|------------------|
| `/home/steam/palworld/Pal/Saved` | 遊戲配置和存檔      |

你必須修改主機掛載目錄的權限，否則容器無法讀取。  
 (例如：`chmod -R 777 ./palSaved`)  


## 遊戲設置
遊戲設置位於本地目錄 `./palSaved/Config/LinuxServer/PalWorldSettings.ini` (首次運行後會自動生成)。  
請參考 [`DefaultPalWorldSettings.ini`](./DefaultPalWorldSettings.ini) 和[官方文檔](https://tech.palworldgame.com/optimize-game-balance)進行修改。  


## Docker Compose
參考此 [docker-compose.yml](./docker-compose.yml) 範例文件

```yml
version: '3.8'

services:
  palserver:
    image: hmes98318/palworld-docker:latest
    container_name: palserver
    restart: always
    environment:
      TZ: "Asia/Taipei"
      CHECK_UPDATE_ON_START: true
      PORT: 8211
      PLAYERS: 32
      MULTITHREAD: true
      ADMIN_PASSWORD: "youradminpassword"
      SERVER_NAME: "Palworld Server"
      SERVER_DESC: "Palworld Server Description"
      SERVER_PASSWORD: ""
      # COMMUNITY: false  # 如果你希望伺服器顯示在社群伺服器列表中，啟用此選項，(請設定 SERVER_PASSWORD)
      # COMMUNITY_IP: 
      # COMMUNITY_PORT: 8211
      RCON_ENABLED: false
      RCON_PORT: 25575
    volumes:
      - ./palSaved:/home/steam/palworld/Pal/Saved
    ports:
      - 8211:8211/udp
```


## Docker run

```bash
docker run -d \
  --name palserver \
  --restart always \
  -e TZ="Asia/Taipei" \
  -e CHECK_UPDATE_ON_START=true \
  -e PORT=8211 \
  -e PLAYERS=32 \
  -e MULTITHREAD=true \
  -e ADMIN_PASSWORD="youradminpassword" \
  -e SERVER_NAME="Palworld Server" \
  -e SERVER_DESC="Palworld Server Description" \
  -e SERVER_PASSWORD="" \
  -e RCON_ENABLED=false \
  -e RCON_PORT=25575 \
  -v ./palSaved:/home/steam/palworld/Pal/Saved \
  -p 8211:8211/udp \
  hmes98318/palworld-docker:latest
```