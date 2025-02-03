#include <vector>
#include <memory>
#include <SDL3/SDL.h>
#include "tetrahedron/component.hpp"

std::vector<std::unique_ptr<Component>> components;

void register_component(std::unique_ptr<Component> component) {
    components.push_back(std::move(component));
}

std::vector<std::unique_ptr<Component>>* get_components() {
    return &components;
}