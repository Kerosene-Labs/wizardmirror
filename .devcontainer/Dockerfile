FROM mcr.microsoft.com/devcontainers/base:noble AS sdl-build

###
### Compile SDL3
###
RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y build-essential git make \
    pkg-config cmake ninja-build gnome-desktop-testing libasound2-dev libpulse-dev \
    libaudio-dev libjack-dev libsndio-dev libx11-dev libxext-dev \
    libxrandr-dev libxcursor-dev libxfixes-dev libxi-dev libxss-dev \
    libxkbcommon-dev libdrm-dev libgbm-dev libgl1-mesa-dev libgles2-mesa-dev \
    libegl1-mesa-dev libdbus-1-dev libibus-1.0-dev libudev-dev fcitx-libs-dev \
    libpipewire-0.3-dev libwayland-dev libdecor-0-dev liburing-dev libfreetype-dev

# begin compiling SDL3
RUN mkdir /tmp/SDL3
WORKDIR /tmp/SDL3
RUN git clone https://github.com/libsdl-org/SDL.git
WORKDIR /tmp/SDL3/SDL
RUN mkdir build
WORKDIR /tmp/SDL3/SDL/build
RUN cmake -DCMAKE_INSTALL_PREFIX=/usr ..
RUN make -j$(nproc)
RUN make install
# RUN ls /usr/local/lib && exit 1


# compile SDL3_ttf
RUN mkdir /tmp/SDL3_ttf
WORKDIR /tmp/SDL3_ttf
RUN git clone https://github.com/libsdl-org/SDL_ttf.git
WORKDIR /tmp/SDL3_ttf/SDL_ttf
RUN mkdir build
WORKDIR /tmp/SDL3_ttf/SDL_ttf/build
RUN cmake -DCMAKE_INSTALL_PREFIX=/usr ..
RUN make -j$(nproc)
RUN make install

###
### Devcontainer
###
FROM mcr.microsoft.com/devcontainers/base:noble
RUN apt-get update && apt-get upgrade -y && apt-get install -y libxml2 libxml2-dev
COPY --from=sdl-build /usr /usr
# RUN ln -s /usr/local/include/SDL3 /usr/include/SDL3 && ln -s /usr/local/include/SDL3_ttf /usr/include/SDL3_ttf
# RUN ln -s /usr/local/lib/libSDL3.* /usr/lib/libSDL3.so
# RUN ln -s /usr/local/lib/ 
RUN ln -s /usr/include/libxml2/libxml /usr/include/libxml
ENTRYPOINT ["cat", "/dev/null"]