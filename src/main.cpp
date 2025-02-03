#include <SDL3/SDL.h>
#include <SDL3_ttf/SDL_ttf.h>
#include "tetrahedron/lifecycle.hpp"
#include "tetrahedron/errors.hpp"
#include "tetrahedron/component.hpp"
#include "components/headlines.hpp"

int main() {
    NewsHeadline news_headline;
    register_component(news_headline);

    try {
        run("WizardMirror");
    } catch (const SDLException& e) {
        SDL_Log("Got SDLException while running: %s", e.what());
        return 1;
    }
}