#!/bin/bash

# Workdir:  /home/steam/steamcmd
# User:     steam

VERSION="v0.2.0"
STEAMCMD="/home/steam/steamcmd/steamcmd.sh"
PALWORLD_DIR="/home/steam/palworld"
PALWORLD_SETTINGS="$PALWORLD_DIR/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini"


# Install PalServer
install_server() {
  echo "-> Installing the server..."
  "$STEAMCMD" +force_install_dir "$PALWORLD_DIR" +login anonymous +app_update 2394010 validate +quit
}

# Whether to check for server updates
check_update() {
  if [ "$CHECK_UPDATE_ON_START" = "true" ]; then
    echo "-> Checking for updates..."
    "$STEAMCMD" +force_install_dir "$PALWORLD_DIR" +login anonymous +app_update 2394010 validate +quit
  else
    echo "-> Skipping update check."
  fi
}

print_system_info() {
  BUILD_ID=$("$STEAMCMD" +force_install_dir "$PALWORLD_DIR" +login anonymous +app_status 2394010 +quit | grep -e "BuildID" | awk '{print $8}')

  echo "----------------------------------------"
  echo "PalServer-docker: $VERSION"
  echo "Build ID: $BUILD_ID"
  echo "Author: hmes98318"
  echo "GitHub: https://github.com/hmes98318/palworld-docker"
  echo "----------------------------------------"
  echo "OS: $(cat /etc/os-release | grep "^PRETTY_NAME" | cut -d'=' -f2)"
  echo "CPU: $(grep 'model name' /proc/cpuinfo | uniq | cut -d':' -f2)"
  echo "RAM: $(awk '/MemTotal/ {total=$2} /MemFree/ {free=$2} END {printf("%.2fGB/%.2fGB", (total-free)/1024000, total/1024000)}' /proc/meminfo)"
  echo "Disk Space: $(df -h / | awk 'NR==2{printf "%s/%s\n", $3, $2}')"
  echo "Startup Time: $(date)"
  echo "----------------------------------------"
}

# Set startup arguments
set_args() {
  if [ -n "$PORT" ]; then
    args+="-port=$PORT "
  fi

  if [ -n "$PLAYERS" ]; then
    args+="-players=$PLAYERS "
  fi

  #---------- Community server setup ----------

  if [ -n "$COMMUNITY" ]; then
    args+="EpicApp=PalServer "
  fi

  if [ -n "$COMMUNITY_IP" ]; then
    args+="-publicip=$COMMUNITY_IP "
  fi

  if [ -n "$COMMUNITY_PORT" ]; then
    args+="-publicport=$COMMUNITY_PORT "
  else
    if [ -n "$COMMUNITY" ]; then
      args+="-publicport=8211 "
    fi
  fi

  #---------- END Community server setup ----------

  if [ "$MULTITHREAD" = "true" ]; then
    args+="-useperfthreads -NoAsyncLoadingThread -UseMultithreadForDS "
  fi
}

# Load PalWorld settings to PalWorldSettings.ini
set_settings() {
  if [ -n "$ADMIN_PASSWORD" ]; then
    ADMIN_PASSWORD=$(echo "$ADMIN_PASSWORD" | tr -d '"')
  else
    ADMIN_PASSWORD=""
  fi
  sed -i "s/AdminPassword=\"[^\"]*\"/AdminPassword=\"$ADMIN_PASSWORD\"/g" $PALWORLD_SETTINGS

  if [ -n "$SERVER_NAME" ]; then
    SERVER_NAME=$(echo "$SERVER_NAME" | tr -d '"')
    sed -i "s/ServerName=\"[^\"]*\"/ServerName=\"$SERVER_NAME\"/g" $PALWORLD_SETTINGS
  fi

  if [ -n "$SERVER_DESC" ]; then
    SERVER_DESC=$(echo "$SERVER_DESC" | tr -d '"')
    sed -i "s/ServerDescription=\"[^\"]*\"/ServerDescription=\"$SERVER_DESC\"/g" $PALWORLD_SETTINGS
  fi

  if [ -n "$SERVER_PASSWORD" ]; then
    SERVER_PASSWORD=$(echo "$SERVER_PASSWORD" | tr -d '"')
  else
    SERVER_PASSWORD=""
  fi
  sed -i "s/ServerPassword=\"[^\"]*\"/ServerPassword=\"$SERVER_PASSWORD\"/g" $PALWORLD_SETTINGS

  # Rcon
  if [ -n "$RCON_ENABLED" ]; then
    sed -i "s/RCONEnabled=[^,]*/RCONEnabled=$RCON_ENABLED/g" $PALWORLD_SETTINGS

    if [ -n "$RCON_PORT" ]; then
      sed -i "s/RCONPort=[^,]*/RCONPort=$RCON_PORT/g" $PALWORLD_SETTINGS
    else
      sed -i "s/RCONPort=[^,]*/RCONPort=25575/g" $PALWORLD_SETTINGS
    fi
  fi
}




main(){
  echo "----------------------------------------"
  echo "Initializing the PalServer..."
  print_system_info


  # Check install
  if [ ! -f "$PALWORLD_DIR/PalServer.sh" ]; then
    install_server

    # Error check
    if [ ! -f "$PALWORLD_DIR/PalServer.sh" ]; then
      echo "Installation failed: Please make sure to reserve at least 10GB of free disk space." >&2
      exit 1
    fi
  else
    check_update
  fi


  # Load startup arguments
  args=""
  set_args


  # Load PalWorld settings
  # If the settings file does not exist, initialization is performed first
  echo "----------------------------------------"

  if [ ! -f "$PALWORLD_SETTINGS" ]; then
    echo "-> Initializing PalServer to generate settings file..."
    timeout -s SIGTERM 20s "$PALWORLD_DIR/PalServer.sh"
    cp "$PALWORLD_DIR/DefaultPalWorldSettings.ini" "$PALWORLD_SETTINGS"

    # Check if initialization is successful
    if [ ! -f "$PALWORLD_SETTINGS" ]; then
      echo "Initialization failed: Unable to generate settings file." >&2
      exit 1
    fi

    sleep 5
    echo "-> Successfully generated PalServer settings file"
  fi

  set_settings
  echo "-> Successfully loaded PalServer settings file"


  # Start server
  echo "----------------------------------------"
  echo -e "Startup Parameters: \n$PALWORLD_DIR/PalServer.sh $args "
  echo "----------------------------------------"
  echo -e "PalWorldSettings.ini config: \n"
  cat "$PALWORLD_SETTINGS"
  echo "----------------------------------------"
  echo "-> Starting the PalServer..."

  "$PALWORLD_DIR"/PalServer.sh "$args"
}

main
