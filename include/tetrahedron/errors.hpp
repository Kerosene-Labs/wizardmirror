#ifndef SDL_EXCEPTION_H
#define SDL_EXCEPTION_H
#include <stdexcept>
class SDLException : public std::runtime_error {
public:
    SDLException(const std::string& message)
        : std::runtime_error(message) {}
};
#endif