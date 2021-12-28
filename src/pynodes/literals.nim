# Python AST node documentation (easy to read & understand)
# https://greentreesnakes.readthedocs.io/en/latest/nodes.html
import macros, json, sequtils
import ../nimast/ast
import variables

# NOTE: may run into problems w/ big numbers (BiggestFloat / BiggestInt ?)
proc addIntOrFloat*(tree: NimNode, node: JsonNode) = # integer / float
    case node["n"].kind
    of JFloat:
        tree.add newLit(node["n"].getFloat)
    of JInt:
        tree.add newLit(node["n"].getInt)
    else: raise newException(ValueError, "(addIntOrFloat) unknown kind for Num: " & $node["n"].kind)

proc addString*(tree: NimNode, node: JsonNode) = # string
    tree.add newStrLitNode(node["s"].getStr) # *** need to remove the \' from the string ***

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
                # TODO: add support for other types in list
                raise newException(ValueError, "(addList) unsupported type in list: " & firstValType)

            prefixTree.add bracketTree
            tree.add prefixTree

    else:
        # TODO: handle list of mixed types later
        raise newException(ValueError, "(addList) mixed types in list not yet supported")


proc addNameConstant*(tree: NimNode, node: JsonNode) = # -- name constant -- boolean for nim (true, false, None)
    case $node["value"]
    of "true","false": tree.add newLit(node["value"].getBool)
    else: raise newException(ValueError, "(addNameConstant) python `None` not yet supported")
        # tree.add newCommentStmtNode("Manual Fix Needed: value is None") # don't delete


proc formattedValue*(node: JsonNode): string = # formatted value for JoinedStr # EXPERIMENTAL / TEST
    if node["conversion"].getInt != -1: raise newException(ValueError,
            "(formattedValue) conversion formatting not yet supported")
    if $node["format_spec"] != "null": raise newException(ValueError,
            "(formattedValue) format_spec formatting not yet supported")
    
    case node["value"]["_type"].getStr
    of "Num":
        case node["value"]["n"].kind
        of JFloat:
            return "{" & $node["value"]["n"].getFloat & "}"
        of JInt:
            return "{" & $node["value"]["n"].getInt & "}"
        else: raise newException(ValueError, "(formattedValue) unknown kind for Num: " & $node["value"]["n"].kind)
    of "Str": return $node["value"]["s"] # *** TEST ***
    of "Name": return "{" & node["value"]["id"].getStr & "}"
    of "Call":
        if node["value"]["args"].len != 0 and node["value"]["keywords"].len != 0:
            raise newException(ValueError, "(formattedValue) keywords/args not yet supported")
        return "{" & node["value"]["func"]["id"].getStr & "()" & "}"

    else: raise newException(ValueError, "(formattedValue) unknown value type: " & node["value"]["_type"].getStr)


proc addJoinedStr*(tree: NimNode, node: JsonNode) = # -- joined string -- (f string, import strformat for Nim) # EXPERIMENTAL / TEST

    var callStrLit = nnkCallStrLit.newTree(ident("fmt"))
    var fmtStr: string
    for value in node["values"]:
        case value["_type"].getStr
        of "FormattedValue": fmtStr.add formattedValue(value)
        of "Str": fmtStr.add value["s"].getStr
        else: raise newException(ValueError, "(JoinedStr) unknown value type: " & value["_type"].getStr)

    callStrLit.add newLit(fmtStr)
    tree.add callStrLit

    nimModules.add("strformat") # for importing strformat module to Nim file after ast is generated

from expressions import addCall # apparently this gets around a circular import problem... for now
proc addTuple*(tree: NimNode, node: JsonNode) = # -- tuple --
    var tupleConstrTree = nnkTupleConstr.newTree()

    for value in node["elts"].getElems:
        case value["_type"].getStr
        of "Num":
            tupleConstrTree.addIntOrFloat(value)
        of "Str":
            tupleConstrTree.addString(value)
        of "NameConstant":
            tupleConstrTree.addNameConstant(value)
        of "Call":
            tupleconstrTree.addCall(value)
        of "JoinedStr":
            tupleConstrTree.addJoinedStr(value)
        of "Name":
            tupleConstrTree.addName(value)
        else: raise newException(ValueError, "(addTuple) unknown value type: " & value["_type"].getStr)
    
    tree.add tupleConstrTree


# TODO:
# Bytes(s)
# Set(elts)
# Dict(keys, values)
# Ellipsis