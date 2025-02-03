#include <SDL3/SDL.h>
#include "tetrahedron/component.hpp"
#include "tetrahedron/lifecycle.hpp"
#include "components/headlines.hpp"

void NewsHeadline::render() {
    // SDL_Log("Rendered news headlines");
    SDL_FRect rect = {.x = 0, .y = 0, .w = 100, .h = 100};
    SDL_SetRenderDrawColor(renderer, 255, 255, 255, 255);
    SDL_RenderFillRect(renderer, &rect);
}