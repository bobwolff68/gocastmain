#pragma once

class tTexture
{
protected:
    tDimension2f mTextureSize;
    GLuint textureID;       //This is the 'id' we reference when we want to use it.

protected:
    void MakeCurrent();
    void MakeSurfaceCopy(tSurface& dst, const tSurface& src);

    void CreateFromSurface(const tSurface& newSurface);

public:
    tTexture(const tSurface& newSurface);
    ~tTexture();

    tDimension2f getSize() const;

    friend class tSurface;
    friend class CarouselApp;
};

