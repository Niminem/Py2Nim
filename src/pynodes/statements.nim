# Python AST node documentation (easy to read & understand)
# https://greentreesnakes.readthedocs.io/en/latest/nodes.html
import macros, json
import literals, expressions, variables

proc addAssign*(tree: NimNode, node: JsonNode) = # -- Assign -- variable assignment

    # for distinguishing single vs multi-assign (basic tuple unpacking) *** add functionality for `*` operator ***
    var isMultiAssign = false

    # for assigning a variable name or multiple variable names
    var varSectionTree = nnkVarSection.newTree() # creates a var section/scope
    var identDefsTree = newNimNode(nnkIdentDefs) # creates node for identifier
    # for assigning multiple variable names (tuple unpacking)
    var varTupleTree = nnkVarTuple.newTree() # creates a vartuple scope

    for target in node["targets"]:
        if target["_type"].getStr == "Name":
            identDefsTree.add ident(target["id"].getStr) # adding each IDENTIFIER/NAME to the node
        elif target["_type"].getStr == "Tuple":
            isMultiAssign = true
            for value in target["elts"]:
                varTupleTree.add ident(value["id"].getStr)

        else: raise newException(ValueError, "(addAssign) unknown target: " & target["_type"].getStr)

    identDefsTree.add newEmptyNode() # for the return type
    varTupleTree.add newEmptyNode() # for the return type

    case node["value"]["_type"].getStr # VALUE of the assignment
    of "Str":
        if isMultiAssign: varTupleTree.addString(node["value"])
        else: identDefsTree.addString(node["value"])
    of "Num":
        if isMultiAssign: varTupleTree.addIntOrFloat(node["value"]) # value is either int or float
        else: identDefsTree.addIntOrFloat(node["value"]) # value is either int or float
    of "BinOp":
        if isMultiAssign: varTupleTree.addBinOp(node["value"])
        else: identDefsTree.addBinOp(node["value"]) # adds nim infix operation as the value of the assignment
    of "Name":
        if isMultiAssign: varTupleTree.addName(node["value"])
        else: identDefsTree.addName(node["value"])
    of "Call":
        if isMultiAssign: varTupleTree.addCall(node["value"])
        else: identDefsTree.addCall(node["value"])
    of "List":
        if isMultiAssign: varTupleTree.addList(node["value"])
        else: identDefsTree.addList(node["value"])
    of "NameConstant":
        if isMultiAssign: varTupleTree.addNameConstant(node["value"])
        else: identDefsTree.addNameConstant(node["value"])
    of "JoinedStr":
        if isMultiAssign: varTupleTree.addJoinedStr(node["value"])
        else: identDefsTree.addJoinedStr(node["value"])
    of "Tuple":
        if isMultiAssign: varTupleTree.addTuple(node["value"])
        else: identDefsTree.addTuple(node["value"])
    else:
        raise newException(ValueError, "(addAssign) unknown value type: " & node["value"]["_type"].getStr)

    if isMultiAssign: # if there are multiple assignments
        varSectionTree.add varTupleTree
        tree.add varSectionTree

    else: # if there is only one assignment
        varSectionTree.add identDefsTree
        tree.add varSectionTree



proc addPass*(tree: NimNode) = # -- Pass -- (discard for nim)
    tree.add nnkDiscardStmt.newTree(newEmptyNode()) # discard the result

proc addAssert*(tree: NimNode, node: JsonNode) = # -- Assert --
    var doAssertTree = nnkCommand.newTree()
    doAssertTree.add newIdentNode("doAssert")

    case node["test"]["_type"].getStr
    of "Compare":
        var infixTree = nnkInfix.newTree() # IS THIS BEST?
        infixTree.addCompare(node["test"]) # IS THIS BEST?
        doAssertTree.add infixTree # IS THIS BEST?
    else: raise newException(ValueError, "(addAssert) unknown test type: " & node["test"]["_type"].getStr)

    if $node["msg"] != "null":
        if node["msg"]["_type"].getStr == "Str": doAssertTree.addString(node["msg"])
        else: raise newException(ValueError, "(addAssert) unknown msg type: " & node["msg"]["_type"].getStr)

    tree.add doAssertTree



# TODO
# AnnAssign(target, annotation, value, simple)
# AugAssign(target, op, value)
# Raise(exc, cause)
# Delete(targets)