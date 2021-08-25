import macros, json
import ast


let pyAst = gorgeEx("python3 parser.py").output.parseJson
var nimAst = nnkStmtList.newTree()

for pyNode in pyAst["body"]:

    case pyNode["_type"].getStr
    of "Expr":
        nimAst.addExpr(pyNode["value"])
    of "Assign":
        nimAst.addAssign(pyNode)
    of "If":
        nimAst.addIf(pyNode)

    else: discard



echo "\nPython Script:\n"
echo readFile("script.py")
echo "\nNim Script:"
echo nimAst.repr & "\n"