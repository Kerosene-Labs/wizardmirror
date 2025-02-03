#ifndef HEADLINES_H
#define HEADLINES_H

#include "tetrahedron/component.hpp"

class NewsHeadline : public Component {
public:
    void render() override;
};

#endif