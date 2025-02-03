#ifndef COMPONENT_H
#define COMPONENT_H
#include <vector>

class Component {
public:
    virtual void render();
    virtual ~Component() = default;
};

extern std::vector<Component> components;

void register_component(Component&);

#endif