import macros, json
import src/[eval] #ast is working/tested/original

let pyAst = gorgeEx("python3 parser.py").output.parseJson
var nimAst = nnkStmtList.newTree()

for pyNode in pyAst["body"]:
    nimAst.addEvaluatedPyType(pyNode)

echo "\nPython Script:\n"
echo readFile("py/script.py")
echo "\nNim Script:"
echo nimAst.repr & "\n"