# palworld-docker
`English` | [繁體中文](./README_zh-TW.md)

Docker container that can easily run Palworld dedicated server  
[View on Docker Hub](https://hub.docker.com/r/hmes98318/palworld-docker)  


## Environments
| Variable              | Describe                          | Default Values | Allowed Values       |
|-----------------------|-----------------------------------|----------------|----------------------|
| PORT                  | The server listening port         | 8211           | 0-65535              |
| PLAYERS               | Max number of players             | 16             | 1-32                 |
| MULTITHREAD           | Whether to enable multithreading  | true           | true/false           |
| ADMIN_PASSWORD        | Server admin password             | None           | string               |
| SERVER_NAME           | The name of your server           | string         | string               |
| SERVER_DESC           | Description of your server        | string         | string               |
| SERVER_PASSWORD       | The password of your server       | None           | string               |
| COMMUNITY             | Whether the server is appears in the community server list (please set SERVER_PASSWORD)             | false           | true/false               |
| COMMUNITY_IP          | The IP of the community server    | None           | string               |
| COMMUNITY_PORT        | The port of the community server  | 8211           | 0-65535              |
| RCON_ENABLED          | Enable RCON for your server       | true           | true/false           |
| RCON_PORT             | RCON port number                  | 25575          | 0-65535              |
| CHECK_UPDATE_ON_START | Whether to automatically check for game updates every time you start it   | false           | true/false   |

### The first startup will download the Palworld server file, which may take a while (depends on your network condition)  


## Volumes
| Container mount point             | Description           |
|-----------------------------------|-----------------------|
| `/home/steam/palworld/Pal/Saved`  | Game config and saves |

You must modify the permissions of your host's mounting directory, otherwise the container cannot read it.  
(ex: `chmod -R 777 ./palSaved`)  


## Game settings
The game settings are in the local directory `./palSaved/Config/LinuxServer/PalWorldSettings.ini` (it will be generated after running it for the first time).  
Please refer to [`DefaultPalWorldSettings.ini`](./DefaultPalWorldSettings.ini) and [official documents](https://tech.palworldgame.com/optimize-game-balance) for modification.  

## Docker Compose
Refer to this [docker-compose.yml](./docker-compose.yml) example file

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
      PLAYERS: 32
      MULTITHREAD: true
      ADMIN_PASSWORD: "youradminpassword"
      SERVER_NAME: "Palworld Server"
      SERVER_DESC: "Palworld Server Description"
      SERVER_PASSWORD: ""
      # COMMUNITY: false  # Enable this option if you want your server to appear in the community servers list, please set SERVER_PASSWORD
      # COMMUNITY_IP: 
      # COMMUNITY_PORT: 8211
      RCON_ENABLED: false
      RCON_PORT: 25575
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
  -e PLAYERS=32 \
  -e MULTITHREAD=true \
  -e ADMIN_PASSWORD="youradminpassword" \
  -e SERVER_NAME="Palworld Server" \
  -e SERVER_DESC="Palworld Server Description" \
  -e SERVER_PASSWORD="" \
  -e RCON_ENABLED=false \
  -e RCON_PORT=25575 \
  -e CHECK_UPDATE_ON_START=false \
  -v ./palSaved:/home/steam/palworld/Pal/Saved \
  -p 8211:8211/udp \
  hmes98318/palworld-docker:latest
```