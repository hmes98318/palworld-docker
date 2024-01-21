#!/bin/bash

# Workdir:  /home/steam/steamcmd
# User:     steam

VERSION="v0.1.2"
STEAMCMD="/home/steam/steamcmd/steamcmd.sh"
PALWORLD_DIR="/home/steam/palworld"


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




main(){
  print_system_info

  # Check install
  if [ ! -f "$PALWORLD_DIR/PalServer.sh" ]; then
    install_server
  else
    check_update
  fi


  # Load arguments
  args=""

  if [ -n "$PORT" ]; then
    args+="-port=$PORT "
  else
    args+="-port=8211 "
  fi

  if [ -n "$PLAYERS" ]; then
    args+="-players=$PLAYERS "
  else
    args+="-players=32 "
  fi

  if [ "$MULTITHREAD" = "true" ]; then
    args+="-useperfthreads -NoAsyncLoadingThread -UseMultithreadForDS "
  fi


  # Start server
  echo "----------------------------------------"
  echo  -e "Startup Parameters: \n $PALWORLD_DIR/PalServer.sh $args "
  echo "----------------------------------------"
  echo "-> Starting the PalServer..."

  "$PALWORLD_DIR"/PalServer.sh "$args"
}

main
