FROM cm2network/steamcmd:root

# USER root
# RUN apt update -y && apt install vim -y


USER steam

WORKDIR /home/steam/steamcmd

RUN mkdir -p /home/steam/palworld/Pal/Saved

COPY DefaultPalWorldSettings.ini /home/steam/palworld/DefaultPalWorldSettings.ini
COPY entrypoint.sh /home/steam/palworld/entrypoint.sh


USER root

RUN chown steam:steam /home/steam/palworld/DefaultPalWorldSettings.ini
RUN chown steam:steam /home/steam/palworld/entrypoint.sh
RUN chmod +x /home/steam/palworld/entrypoint.sh


USER steam

EXPOSE 8211/udp

VOLUME ["/home/steam/palworld/Pal/Saved"]

ENTRYPOINT ["/home/steam/palworld/entrypoint.sh"]


