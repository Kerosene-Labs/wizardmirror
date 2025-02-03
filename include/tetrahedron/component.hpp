#ifndef COMPONENT_H
#define COMPONENT_H
#include <vector>
#include <memory>

class Component {
public:
    virtual ~Component() = default;
    virtual void render() = 0;
};

void register_component(std::unique_ptr<Component>);
std::vector<std::unique_ptr<Component>>* get_components();

#endif