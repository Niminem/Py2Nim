import macros, json
# Python AST node documentation (easy to read & understand)
# https://greentreesnakes.readthedocs.io/en/latest/nodes.html

# NOTE: may run into problems w/ big numbers
proc addIntOrFloat*(tree: NimNode, node: JsonNode) = # integer / float
    case node["n"].kind
    of JFloat:
        tree.add newLit(node["n"].getFloat)
    of JInt:
        tree.add newLit(node["n"].getInt)
    else: discard

proc addString*(tree: NimNode, node: JsonNode) = # string
    tree.add newLit(node["s"].getStr)



# TODO:
# FormattedValue(value, conversion, format_spec)
# JoinedStr(values)
# Bytes(s)
# List(elts, ctx)
# Tuple(elts, ctx)
# Set(elts)
# Dict(keys, values)
# NameConstant(value)
# Ellipsis