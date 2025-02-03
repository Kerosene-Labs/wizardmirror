#include <SDL3/SDL.h>
#include <SDL3_ttf/SDL_ttf.h>
#include "tetrahedron/lifecycle.hpp"
#include "tetrahedron/errors.hpp"
#include "tetrahedron/component.hpp"
#include "components/headlines.hpp"
#include <memory> 
#include <vector>

int main() {
    register_component(std::make_unique<NewsHeadline>());

    try {
        run("WizardMirror");
    } catch (const SDLException& e) {
        SDL_Log("Got SDLException while running: %s", e.what());
        return 1;
    }
}