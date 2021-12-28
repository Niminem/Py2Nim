import std/[macros, json, strutils]
import eval, nimast/ast

proc sourceGen*(pyAst: JsonNode): string =

    # create new nim node for building ast tree
    var nimAst = nnkStmtList.newTree()

    # build nim ast tree
    for pyNode in pyAst["body"]:
        nimAst.addFromNode(pyNode)

    # add imports if needed
    nimAst.addModules()

    # generate source code from ast tree
    result = nimAst.repr
    result.removePrefix() # removes the leading new line from the source code