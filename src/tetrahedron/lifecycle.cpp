#include <SDL3/SDL.h>
#include <SDL3_ttf/SDL_ttf.h>
#include "tetrahedron/errors.hpp"
#include "tetrahedron/component.hpp"

SDL_Renderer* renderer;

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

    renderer = SDL_CreateRenderer(sdl_window, NULL);
    if (sdl_window == NULL) {
        throw new SDLException(SDL_GetError());
    }

    bool running = true;
    SDL_Event event;
    while (running) {
        while (SDL_PollEvent(&event)) {
            if (event.type == SDL_EVENT_QUIT ) {
                running = false;
            }
        }

        if (!SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255)) {
            throw new SDLException(SDL_GetError());
        }

        if (!SDL_RenderClear(renderer)) {
           throw new SDLException(SDL_GetError());
        }
        
        for (const auto& component : *get_components()) {
            component->render();
        }
        
        if (!SDL_RenderPresent(renderer)){
            throw new SDLException(SDL_GetError());       
        }
    }
}