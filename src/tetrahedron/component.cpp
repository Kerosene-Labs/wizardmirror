#include <vector>
#include <SDL3/SDL.h>
#include "tetrahedron/component.hpp"

std::vector<Component> components;

void Component::render() {}

void register_component(Component& component) {
    components.push_back(component);
}