import macros, json

{.experimental:"codeReordering".} # removes the need for forward declarations, should be useful here

proc addPass*(tree: NimNode) =
    tree.add nnkDiscardStmt.newTree(newEmptyNode())

proc addName*(tree: NimNode, node: JsonNode) =
    tree.add newIdentNode(node["id"].getStr)

proc addString*(tree: NimNode, node: JsonNode) =
    tree.add newLit(node["s"].getStr)

proc addIntOrFloat*(tree: NimNode, node: JsonNode) =
    case node["n"].kind
    of JFloat:
        tree.add newLit(node["n"].getFloat) # value is a FLOAT
    of JInt:
        tree.add newLit(node["n"].getInt) # value is an INTEGER
    else: discard


proc addPyCall*(tree: NimNode, node: JsonNode) =
    case node["func"]["id"].getStr # Function Name

    of "print":
        tree.add newIdentNode("echo")
    else: discard

    for arg in node["args"]:
        case arg["_type"].getStr
        of "Str":
            tree.addString(arg)
        else:
            tree.add newIdentNode(arg["id"].getStr)
    
    for kwarg in node["keywords"]:
        discard


proc addPyBinOp*(tree: NimNode, node: JsonNode) =
    var infixTree = nnkInfix.newTree()

    case node["op"]["_type"].getStr # adding the operator
    of "Mult":
        infixTree.add ident("*")
    of "Sub":
        infixTree.add ident("-")
    of "Add":
        infixTree.add ident("+")
    of "Div":
        infixTree.add ident("/")
    of "Mod":
        infixTree.add ident("mod")
    # of "Pow": # must be able to handle two different ways (refer to `math` lib for pow() and `^`)
    else: discard

    case node["left"]["_type"].getStr # left side of the operator
    of "Num":
        infixTree.addIntOrFloat(node["left"])
    of "BinOp":
        infixTree.addPyBinOp(node["left"])
    of "Name":
        infixTree.addName(node["left"])
    else: discard

    case node["right"]["_type"].getStr # right side of the operator
    of "Num":
        infixTree.addIntOrFloat(node["right"])
    of "BinOp":
        infixTree.addPyBinOp(node["right"])
    of "Name":
        infixTree.addName(node["right"])
    else: discard

    tree.add infixTree


proc addExpr*(tree: NimNode, node: JsonNode) =
    case node["_type"].getStr
    of "Call":
        var callTree = nnkCall.newTree()
        callTree.addPyCall(node)
        tree.add callTree
    else: discard


proc addAssign*(tree: NimNode, node: JsonNode) =
    var varSectionTree = nnkVarSection.newTree() # creates a var section/scope
    var identDefsTree = newNimNode(nnkIdentDefs) # creates node for identifier
    for target in node["targets"]:
        if target["_type"].getStr == "Name":
            identDefsTree.add ident(target["id"].getStr) # adding each IDENTIFIER/NAME to the node
        else: discard

    identDefsTree.add newEmptyNode() # for the return type

    case node["value"]["_type"].getStr # VALUE of the assignment
    of "Str":
        identDefsTree.addString(node["value"])
    of "Num":
        identDefsTree.addIntOrFloat(node["value"]) # value is either int or float
    of "BinOp":
        identDefsTree.addPyBinOp(node["value"]) # adds infix operation as the value of the assignment
    else: discard

    varSectionTree.add identDefsTree
    tree.add varSectionTree


proc addCompare*(tree: NimNode, node: JsonNode) =
    # tree is an infix tree (refer to `addIf` proc for more info)
    if node["comparators"].len > 1: raise newException(Exception,
        "(more than 1 comparators) Must add functionality :)")
    if node["ops"].len > 1: raise newException(Exception,
        "(more than 1 ops) Must add functionality :)")

    for op in node["ops"]: # add the operator to the infix tree
        case op["_type"].getStr
        of "Eq": tree.add newIdentNode("==")
        of "NotEq": tree.add newIdentNode("!=")
        of "Lt": tree.add newIdentNode("<")
        of "LtE": tree.add newIdentNode("<=")
        of "Gt": tree.add newIdentNode(">")
        of "GtE": tree.add newIdentNode(">=")
        else: discard

    case node["left"]["_type"].getStr # left side of the comparison
    of "Str": tree.addString(node["left"])
    of "Num": tree.addIntOrFloat(node["left"])
    of "Name": tree.addName(node["left"])
    of "BinOp": tree.addPyBinOp(node["left"])
    else: discard

    for comparator in node["comparators"]: # add the comparator to the infix tree (right side)
        case comparator["_type"].getStr
        of "Str": tree.addString(comparator)
        of "Num": tree.addIntOrFloat(comparator)
        of "Name": tree.addName(comparator)
        of "BinOp": tree.addPyBinOp(comparator)
        else: discard


proc addIfBranches*(tree: var seq[NimNode], node: JsonNode) =

    var branchTree = nnkElifBranch.newTree()

    var ifStmtInfixTree = nnkInfix.newTree()
    var ifStmtBodyTree = nnkStmtList.newTree()
    var ifElifElseBranches: seq[NimNode]

    # logic for the operation type of the if statement
    case node["test"]["_type"].getStr
    
    of "Compare": # if the if statement operation is a comparison
        ifStmtInfixTree.addCompare(node["test"])

    else: raise newException(Exception,
        "(if statement is NOT a Comparison) Must add functionality :)")

    # logic for the body of the if statement
    if node["body"].len > 1: raise newException(Exception,
        "(more than 1 body for If statement) Must add functionality :)")
    for body in node["body"]:
        case body["_type"].getStr
        of "Expr":
            ifStmtBodyTree.addExpr(body["value"])
        of "Pass":
            ifStmtBodyTree.addPass()
        else: discard

    # add the IF statement to the tree
    branchTree.add ifStmtInfixTree
    branchTree.add ifstmtBodyTree
    #ifElifElseBranches.add branchTree
    tree.add branchTree

    # logic for the elif/else branch(es) of the if statement
    if node["orelse"].len > 1:
        raise newException(Exception,
            "(more than 1 item in orelse) Must add functionality :)")

    for branch in node["orelse"]:
        var elifElseBranchTreeSeq: seq[NimNode]
        case branch["_type"].getStr
        of "If":
            elifElseBranchTreeSeq.addIfBranches(branch)
        else: discard

        for brnch in elifElseBranchTreeSeq:
            tree.add brnch


proc addIf*(tree: NimNode, node: JsonNode) =

    var ifStmtTree = nnkIfStmt.newTree()
    var ifBranchTree = nnkElifBranch.newTree()
    var ifStmtInfixTree = nnkInfix.newTree()
    var ifStmtBodyTree = nnkStmtList.newTree()
    var ifElifElseBranches: seq[NimNode]

    # logic for the operation type of the if statement
    case node["test"]["_type"].getStr
    
    of "Compare": # if the if statement operation is a comparison
        ifStmtInfixTree.addCompare(node["test"])

    else: raise newException(Exception,
        "(if statement is NOT a Comparison) Must add functionality :)")

    # logic for the body of the if statement
    if node["body"].len > 1: raise newException(Exception,
        "(more than 1 body for If statement) Must add functionality :)")
    for body in node["body"]:
        case body["_type"].getStr
        of "Expr":
            ifStmtBodyTree.addExpr(body["value"])
        of "Pass":
            ifStmtBodyTree.addPass()
        else: discard

    # add the IF statement to the tree
    ifBranchTree.add ifStmtInfixTree
    ifBranchTree.add ifstmtBodyTree
    ifElifElseBranches.add ifBranchTree

    # logic for the elif/else branch(es) of the if statement
    if node["orelse"].len > 1:
        raise newException(Exception,
            "(more than 1 item in orelse) Must add functionality :)")

    for branch in node["orelse"]:
        var elifElseBranchTreeSeq: seq[NimNode] #= nnkElifBranch.newTree()
        case branch["_type"].getStr
        of "If":
            elifElseBranchTreeSeq.addIfBranches(branch)
        else: discard

        for brnch in elifElseBranchTreeSeq:
            ifElifElseBranches.add brnch

    # build the tree
    for branch in ifElifElseBranches:
        ifStmtTree.add branch

    tree.add ifStmtTree