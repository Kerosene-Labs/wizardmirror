#include "tetrahedron/component.h"
#include <vector>

std::vector<Component> components;

void Component::render() {}

void register_component(const Component& component) {
    components.push_back(component);
}