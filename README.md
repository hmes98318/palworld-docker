# palworld-docker
Docker container that can easily run Palworld dedicated server  
[View on Docker Hub](https://hub.docker.com/r/hmes98318/palworld-docker)  


## Environments
| Variable              | Describe                          | Default Values | Allowed Values       |
|-----------------------|-----------------------------------|----------------|----------------------|
| PORT                  | The server listening port         | 8211           | 0-65535              |
| PLAYERS               | Max number of players             | 16             | 1-32                 |
| MULTITHREAD           | Whether to enable multithreading  | true           | true/false           |
| CHECK_UPDATE_ON_START | Whether to automatically check for game updates every time you start it   | true           | true/false   |

### The first startup will download the Palworld server file, which may take a while (depends on your network condition)  


## Volumes
| Container mount point             | Description           |
|-----------------------------------|-----------------------|
| `/home/steam/palworld/Pal/Saved`  | Game config and saves |

You must modify the permissions of your host's mounting directory, otherwise the container cannot read it.  
(ex: `chmod -R 777 ./palSaved`)  

The game settings are in the local directory `./palSaved/Config/LinuxServer/PalWorldSettings.ini` (it will be generated after running it for the first time).  
Refer to [`DefaultPalWorldSettings.ini`](./DefaultPalWorldSettings.ini) to modify.  


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