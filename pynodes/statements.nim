# Python AST node documentation (easy to read & understand)
# https://greentreesnakes.readthedocs.io/en/latest/nodes.html
import macros, json
import literals, expressions, variables

proc addAssign*(tree: NimNode, node: JsonNode) = # -- Name --

    var varSectionTree = nnkVarSection.newTree() # creates a var section/scope
    var identDefsTree = newNimNode(nnkIdentDefs) # creates node for identifier
    for target in node["targets"]:
        if target["_type"].getStr == "Name":
            identDefsTree.add ident(target["id"].getStr) # adding each IDENTIFIER/NAME to the node
        else: raise newException(ValueError, "(addAssign) unknown target: " & target["_type"].getStr)

    identDefsTree.add newEmptyNode() # for the return type

    case node["value"]["_type"].getStr # VALUE of the assignment
    of "Str":
        identDefsTree.addString(node["value"])
    of "Num":
        identDefsTree.addIntOrFloat(node["value"]) # value is either int or float
    of "BinOp":
        identDefsTree.addBinOp(node["value"]) # adds infix operation as the value of the assignment
    of "Name":
        identDefsTree.addName(node["value"])
    of "Call":
        identDefsTree.addCall(node["value"])
    of "List":
        identDefsTree.addList(node["value"])
    of "NameConstant":
        identDefsTree.addNameConstant(node["value"])
    of "JoinedStr":
        identDefsTree.addJoinedStr(node["value"])
    else: discard

    varSectionTree.add identDefsTree
    tree.add varSectionTree


proc addPass*(tree: NimNode) = # -- Pass -- (discard for nim)
    tree.add nnkDiscardStmt.newTree(newEmptyNode()) # discard the result


# TODO
# AnnAssign(target, annotation, value, simple)
# AugAssign(target, op, value)
# Raise(exc, cause)
# Assert(test, msg)
# Delete(targets)