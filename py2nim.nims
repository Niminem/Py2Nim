import macros, json
import eval

let pyAst = gorgeEx("python3 parser.py").output.parseJson
var nimAst = nnkStmtList.newTree()

for pyNode in pyAst["body"]:
    nimAst.addFromNode(pyNode)

echo "\nNim Script:"
echo nimAst.repr & "\n"