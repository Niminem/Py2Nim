# Python AST node documentation (easy to read & understand)
# https://greentreesnakes.readthedocs.io/en/latest/nodes.html
import macros, json

proc addName*(tree: NimNode, node: JsonNode) = # name (identifier node for Nim)
    tree.add newIdentNode(node["id"].getStr)

# TODO:
# Starred(value, ctx)