#ifndef HEADLINES_H
#define HEADLINES_H

#include "tetrahedron/component.h"

class NewsHeadline : public Component {
public:
    void render() override;  // Virtual function declaration
};

#endif