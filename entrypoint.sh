#!/bin/bash

# Workdir: /home/steam/steamcmd
# User: steam

VERSION="v0.1.0"
STEAMCMD_DIR="/home/steam/steamcmd"
PALWORLD_DIR="/home/steam/palworld"


# Install PalServer
install_server() {
  "$STEAMCMD_DIR"/steamcmd.sh +force_install_dir "$PALWORLD_DIR" +login anonymous +app_update 2394010 validate +quit
}

# Whether to check for server updates
check_update() {
  if [ "$CHECK_UPDATE_ON_START" = "true" ]; then
      echo "-> Checking for updates..."
      "$STEAMCMD_DIR"/steamcmd.sh +force_install_dir "$PALWORLD_DIR" +login anonymous +app_update 2394010 validate +quit
  else
      echo "-> Skipping update check."
  fi
}

print_system_info() {
  echo "--------------------"
  echo "OS: $(cat /etc/os-release | grep "^PRETTY_NAME" | cut -d'=' -f2)"
  echo "CPU: $(grep 'model name' /proc/cpuinfo | uniq | cut -d':' -f2)"
  echo "RAM: $(awk '/MemAvailable/ {printf( "%d\n", $2 / 1024000 )}' /proc/meminfo)GB/$(awk '/MemTotal/ {printf( "%d\n", $2 / 1024000 )}' /proc/meminfo)GB"
  echo "Disk Space: $(df -h / | awk 'NR==2{printf "%s/%s\n", $3, $2}')"
  echo "--------------------"
  echo "PalServer-docker: $VERSION"
  echo "Author: hmes98318"
  echo "GitHub: https://github.com/hmes98318"
  echo "--------------------"
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
  echo  -e "--------------------\nStartup Parameters: \n $PALWORLD_DIR/PalServer.sh $args \n--------------------"
  echo "-> Starting the PalServer..."

  "$PALWORLD_DIR"/PalServer.sh "$args"
}

main
