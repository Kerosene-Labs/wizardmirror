#include <SDL3/SDL.h>
#include <SDL3_ttf/SDL_ttf.h>
#include "errors.h"

void run(std::string name) {
     if(!SDL_Init(SDL_INIT_VIDEO)) {
        throw new SDLException(SDL_GetError());
    }

    if(!TTF_Init()) {
        throw new SDLException(SDL_GetError());
    }

    SDL_Window* sdl_window = SDL_CreateWindow(name.c_str(), 600, 800, SDL_WINDOW_RESIZABLE);
    if (sdl_window == NULL) {
        throw new SDLException(SDL_GetError());
    }

    SDL_Renderer* renderer = SDL_CreateRenderer(sdl_window, NULL);
    if (sdl_window == NULL) {
        throw new SDLException(SDL_GetError());
    }

    SDL_Event event;
    while (true) {
        while (SDL_PollEvent(&event)) {
            if (event.type == SDL_EVENT_QUIT ) {
                throw new SDLException(SDL_GetError());
            }
        }

        if (!SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255)) {
            throw new SDLException(SDL_GetError());
        }

        if (!SDL_RenderClear(renderer)) {
           throw new SDLException(SDL_GetError());
        }

        SDL_SetRenderDrawColor(renderer, 255, 255, 255, 255);
        SDL_FRect rect = {0.0f, 0.0f, 100, 100};
        SDL_RenderFillRect(renderer, &rect);
        if (!SDL_RenderPresent(renderer)){
            throw new SDLException(SDL_GetError());       
        }
    }
}