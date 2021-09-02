# Python AST node documentation (easy to read & understand)
# https://greentreesnakes.readthedocs.io/en/latest/nodes.html
import macros, json, sequtils
import ../nimast/ast

# NOTE: may run into problems w/ big numbers
proc addIntOrFloat*(tree: NimNode, node: JsonNode) = # integer / float
    case node["n"].kind
    of JFloat:
        tree.add newLit(node["n"].getFloat)
    of JInt:
        tree.add newLit(node["n"].getInt)
    else: discard

proc addString*(tree: NimNode, node: JsonNode) = # string
    tree.add newStrLitNode(node["s"].getStr)
    # need to remove the \' from the string later ...

proc addList*(tree: NimNode, node: JsonNode) = # list / tuple, depending on value types in py list

    var prefixTree = nnkPrefix.newTree(newIdentNode("@"))
    var bracketTree = nnkBracket.newTree()

    if node["elts"].len < 1: # empty list, have infer type later in Ledger logic
        prefixTree.add bracketTree
        tree.add prefixTree
        return

    let firstValType = node["elts"][0]["_type"].getStr # get first value type of list
    # check if all values are of same type
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


proc formattedValue*(node: JsonNode): string = # formatted value for JoinedStr # EXPERIMENTAL / TEST
    if node["conversion"].getInt != -1: raise newException(ValueError,
            "formatted value conversion 'formatting not yet supported")
    if $node["format_spec"] != "null": raise newException(ValueError,
            "formatted value format_spec 'formatting not yet supported")
    
    case node["value"]["_type"].getStr
    of "Num":
        case node["value"]["n"].kind
        of JFloat:
            return "{" & $node["value"]["n"].getFloat & "}"
        of JInt:
            return "{" & $node["value"]["n"].getInt & "}"
        else: raise newException(ValueError, "unexpected type for Num")
    of "Str": return $node["value"]["s"]
    of "Name": return "{" & node["value"]["id"].getStr & "}"

    of "Call":
        if node["value"]["args"].len != 0 and node["value"]["keywords"].len != 0:
            raise newException(ValueError, "(addFormattedValue) keywords/args not yet supported- add functionality")
        return "{" & node["value"]["func"]["id"].getStr & "()" & "}"

    else: raise newException(ValueError, "unexpected type for formattedvalue")


proc addJoinedStr*(tree: NimNode, node: JsonNode) = # joined string (f string, import strformat for Nim) # EXPERIMENTAL / TEST

    var callStrLit = nnkCallStrLit.newTree(ident("fmt"))
    var fmtStr: string
    for value in node["values"]:
        case value["_type"].getStr
        of "FormattedValue": fmtStr.add formattedValue(value)
        of "Str": fmtStr.add value["s"].getStr
        else: raise newException(ValueError, "unsupported type in addJoinedStr: " & value["_type"].getStr)

    callStrLit.add newLit(fmtStr)
    tree.add callStrLit

    nimModules.add("strformat") # for importing strformat module to Nim file after ast is generated




# TODO:
# Bytes(s)
# Tuple(elts, ctx)
# Set(elts)
# Dict(keys, values)
# Ellipsis