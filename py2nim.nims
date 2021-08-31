import macros, json
import eval
import nimast/ast

let pyAst = gorgeEx("python3 parser.py").output.parseJson # get json representation of Python script's ast
var nimAst = nnkStmtList.newTree() # create new nim node for building ast tree

# build nim ast tree
for pyNode in pyAst["body"]:
    nimAst.addFromNode(pyNode)

# import necessary nim modules
nimAst.addModules()

# print out nim ast tree
echo "\nNim Script:"
echo nimAst.repr & "\n"