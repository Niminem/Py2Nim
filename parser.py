import ast, json
from ast2json import ast2json

with open("py/script.py", "r") as source:
    ast = ast2json(ast.parse(source.read()))

print(json.dumps(ast, indent=2))