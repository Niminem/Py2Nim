# Python AST node documentation (easy to read & understand)
# https://greentreesnakes.readthedocs.io/en/latest/nodes.html
import macros, json, sequtils

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

proc addList*(tree: NimNode, node: JsonNode) = # list / tuple, depending on value types in py list

    var prefixTree = nnkPrefix.newTree(newIdentNode("@"))
    var bracketTree = nnkBracket.newTree()

    if node["elts"].len < 1: # empty list, have infer type later in Ledger logic
        prefixTree.add bracketTree
        tree.add prefixTree
        return

    let firstValType = node["elts"][0]["_type"].getStr # get first value type of list
    # check if all values are of same type
    echo firstValType
    if all(node["elts"].getElems,
        proc (element: JsonNode): bool = return element["_type"].getStr == firstValType):

            if firstValType == "Num":
                if all(node["elts"].getElems, proc (element: JsonNode): bool =
                    return element["n"].kind == node["elts"][0]["n"].kind):
                        for elem in node["elts"].getElems:
                            bracketTree.addIntOrFloat(elem)
                else:
                    prefixTree.add bracketTree
                    tree.add prefixTree
                    tree.add newCommentStmtNode("Manual Fix Needed: mixed int/float types in list")
                    return

            elif firstValType == "Str":
                for elem in node["elts"].getElems:
                    bracketTree.addString(elem)
            else:
                discard # TODO: add support for other types

            prefixTree.add bracketTree
            tree.add prefixTree

    else:
        discard # handle list of mixed types later

proc addNameConstant*(tree: NimNode, node: JsonNode) = # name constant (true, false, None)
    case $node["value"]
    of "true","false": tree.add newLit(node["value"].getBool)
    else: tree.add newCommentStmtNode("Manual Fix Needed: value is None")


# TODO:
# FormattedValue(value, conversion, format_spec)
# JoinedStr(values)
# Bytes(s)
# Tuple(elts, ctx)
# Set(elts)
# Dict(keys, values)
# NameConstant(value)
# Ellipsis