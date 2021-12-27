import ast, json, sys
from ast2json import ast2json

srcPth = sys.argv[1]
with open(srcPth, "r") as source:
    pyAst = ast2json(ast.parse(source.read()))
print(json.dumps(pyAst, indent=2))