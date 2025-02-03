#ifndef COMPONENT_H
#define COMPONENT_H

std::vector<Component> components;

class Component {
public:
    virtual void render();
    virtual ~Component() = default;
};

void register_component(Component&);

#endif