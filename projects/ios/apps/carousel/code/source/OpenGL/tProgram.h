#pragma once

#include <set>

class tProgram
{
protected:
	std::set<GLuint> mActiveAttribs;
    GLuint mProgramID;

protected:
	void AddAttrib(GLuint index);
	void EnableAttribs();
	void DisableAttribs();
	void ClearAttribs();

public:
    tProgram(const tShader& newVertShader, const tShader& newFragShader);
    ~tProgram();

    bool linkStatus() const;
    bool validate() const;
    
    void setActive();

    std::string getInfoLog() const;

    friend class tSGSetUniformNode;
    friend class tSGSetAttributeNode;
	friend class tSGSetProgramNode;
    friend class Whiteboard;
};
