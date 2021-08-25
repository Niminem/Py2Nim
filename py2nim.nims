import macros, json
import ast

let pyAst = gorgeEx("python3 parser.py").output.parseJson
var nimAst = nnkStmtList.newTree()

for pyNode in pyAst["body"]:
    nimAst.addEvaluatedPyType(pyNode)

echo "\nPython Script:\n"
echo readFile("script.py")
echo "\nNim Script:"
echo nimAst.repr & "\n"