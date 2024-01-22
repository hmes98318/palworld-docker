# palworld-docker
[`English`](./README.md) | `繁體中文`

一個可以輕鬆運行 Palworld 專用伺服器的 Docker 容器  
[在 Docker Hub 上查看](https://hub.docker.com/r/hmes98318/palworld-docker)  


## Environments
| 環境變量                  | 描述                                 | 預設值         | 允許值             |
|------------------------|------------------------------------|--------------|---------------------|
| PORT                   | 伺服器監聽端口                       | 8211         | 0-65535             |
| PLAYERS                | 最大玩家數                           | 16           | 1-32                |
| MULTITHREAD            | 是否啟用多線程                       | true         | true/false          |
| CHECK_UPDATE_ON_START  | 是否在每次啟動時自動檢查遊戲更新         | false         | true/false          |

### 首次啟動將會下載 Palworld 伺服器文件，可能需要一些時間 (取決於你的網絡狀況)


## Volumes
| 容器掛載點                          | 描述              |
|----------------------------------|------------------|
| `/home/steam/palworld/Pal/Saved` | 遊戲配置和存檔      |

你必須修改主機掛載目錄的權限，否則容器無法讀取。  
 (例如：`chmod -R 777 ./palSaved`)  

遊戲設置位於本地目錄 `./palSaved/Config/LinuxServer/PalWorldSettings.ini` (首次運行後會自動生成)。  
參考 [`DefaultPalWorldSettings.ini`](./DefaultPalWorldSettings.ini) 進行修改。  


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
      PORT: 8211
      PLAYERS: 16
      MULTITHREAD: true
      CHECK_UPDATE_ON_START: false
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
  -e PORT=8211 \
  -e PLAYERS=16 \
  -e MULTITHREAD=true \
  -e CHECK_UPDATE_ON_START=false \
  -v $(pwd)/palSaved:/home/steam/palworld/Pal/Saved \
  -p 8211:8211/udp \
  hmes98318/palworld-docker:latest
```