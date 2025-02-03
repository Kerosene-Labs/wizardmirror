#include <SDL3/SDL.h>
#include <SDL3_ttf/SDL_ttf.h>

int main() {
    if(!SDL_Init(SDL_INIT_VIDEO)) {
        SDL_Log("%s", SDL_GetError());
        return 1;
    }

    if(!TTF_Init()) {
        SDL_Log("%s", SDL_GetError());
        return 1;
    }

    SDL_Window* sdl_window = SDL_CreateWindow("Test", 600, 800, SDL_WINDOW_RESIZABLE);
    if (sdl_window == NULL) {
        SDL_Log("%s", SDL_GetError());
        return 1;
    }

    SDL_Renderer* renderer = SDL_CreateRenderer(sdl_window, NULL);
    if (sdl_window == NULL) {
        SDL_Log("%s", SDL_GetError());
        return 1;
    }

    SDL_Event event;
    while (true) {
        while (SDL_PollEvent(&event)) {
            if (event.type == SDL_EVENT_QUIT ) {
                SDL_Log("%s", SDL_GetError());
                return 1;
            }
        }

        if (!SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255)) {
            SDL_Log("%s", SDL_GetError());
            return 1;
        }

        if (!SDL_RenderClear(renderer)) {
            SDL_Log("%s", SDL_GetError());
            return 1;
        }

        SDL_SetRenderDrawColor(renderer, 255, 255, 255, 255);
        SDL_FRect rect = {0.0f, 0.0f, 100, 100};
        SDL_RenderFillRect(renderer, &rect);
        if (!SDL_RenderPresent(renderer)){
            SDL_Log("%s", SDL_GetError());
            return 1;            
        }
    }
    return 0;
}