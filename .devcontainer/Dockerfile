###
### Compile SDL3
###
FROM mcr.microsoft.com/devcontainers/base:noble AS sdl-build

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


# compile SDL3_ttf
RUN mkdir /tmp/SDL3_ttf
WORKDIR /tmp/SDL3_ttf
RUN git clone --branch=preview-3.1.0 https://github.com/libsdl-org/SDL_ttf.git
WORKDIR /tmp/SDL3_ttf/SDL_ttf
RUN mkdir build
WORKDIR /tmp/SDL3_ttf/SDL_ttf/build
RUN cmake -DCMAKE_INSTALL_PREFIX=/usr ..
RUN make -j$(nproc)
RUN make install

###
### Zig
###
FROM mcr.microsoft.com/devcontainers/base:noble AS zig-install
ARG ZIG_VERSION=zig-linux-x86_64-0.13.0

RUN mkdir /tmp/zig
WORKDIR /tmp/zig
RUN wget https://ziglang.org/download/0.13.0/${ZIG_VERSION}.tar.xz
RUN tar -xvf ${ZIG_VERSION}.tar.xz
RUN mkdir /opt/zig
RUN mv ${ZIG_VERSION}/* /opt/zig

###
### Devcontainer
###
FROM mcr.microsoft.com/devcontainers/base:noble
RUN apt-get update && apt-get upgrade -y && apt-get install -y libxml2 libxml2-dev fonts-open-sans libfreetype-dev libfreetype6 \
    libharfbuzz0b
COPY --from=sdl-build /usr /usr
COPY --from=zig-install /opt/zig /opt/zig
COPY fonts/ /usr/share/fonts/
RUN ln -s /opt/zig/zig /usr/bin/zig && ln -s /opt/zig/lib /usr/lib
RUN ln -s /usr/include/libxml2/libxml /usr/include/libxml
ENTRYPOINT ["cat", "/dev/null"]