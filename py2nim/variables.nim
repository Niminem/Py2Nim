# Python AST node documentation (easy to read & understand)
# https://greentreesnakes.readthedocs.io/en/latest/nodes.html
import macros, json

# NOTES:
# may need ctx classes below, but not sure yet
# Load
# Store
# Del

proc addName*(tree: NimNode, node: JsonNode) = # name (identifier node for Nim)
    tree.add newIdentNode(node["id"].getStr)


# TODO:
# Starred(value, ctx)