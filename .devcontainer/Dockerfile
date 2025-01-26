FROM mcr.microsoft.com/devcontainers/base:noble AS sdlbase
RUN apt-get update && apt-get upgrade -y
RUN apt-get install cmake gcc g++ git -y

# begin compiling SDL3
RUN mkdir /tmp/SDL3
WORKDIR /tmp/sdl3
RUN git clone https://github.com/libsdl-org/SDL.git