# Python AST node documentation (easy to read & understand)
# https://greentreesnakes.readthedocs.io/en/latest/nodes.html
import macros, json

proc addName*(tree: NimNode, node: JsonNode) = # Name (identifier node for Nim)
    tree.add newIdentNode(node["id"].getStr)



# TODO:
# load, store, del for `ctx` field of Name (may not need this)
# Starred(value, ctx)