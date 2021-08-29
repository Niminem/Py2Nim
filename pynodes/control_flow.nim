# Python AST node documentation (easy to read & understand)
# https://greentreesnakes.readthedocs.io/en/latest/nodes.html
import macros, json
import expressions, literals, statements, variables

# {.experimental: "codeReordering".}

proc addFor*(tree: NimNode, node: JsonNode) # FORWARD DECLARATION

proc addIfBranches*(tree: var seq[NimNode], node: JsonNode) =

    var branchTree = nnkElifBranch.newTree()
    var ifStmtInfixTree = nnkInfix.newTree()
    var ifStmtBodyTree = nnkStmtList.newTree()

    # logic for the operation type of the if statement
    case node["test"]["_type"].getStr
    
    of "Compare": # if the if statement operation is a comparison
        ifStmtInfixTree.addCompare(node["test"])

    of "NameConstant":
        branchTree.addNameConstant(node["test"])

    else: raise newException(Exception,
        "(if statement is NOT a Comparison or Name Constant) Must add functionality :)")

    # logic for the body of the if statement
    # if node["body"].len > 1: raise newException(Exception,
    #     "(more than 1 body for If statement) Must add functionality :)")
    for body in node["body"]:
        case body["_type"].getStr
        of "Expr":
            ifStmtBodyTree.addExpr(body)
        of "Pass":
            ifStmtBodyTree.addPass()
        of "Assign":
            ifStmtBodyTree.addAssign(body)
        of "For":
            ifStmtBodyTree.addFor(body) # TEST
        else: discard

    # add the IF statement to the tree
    if node["test"]["_type"].getStr == "Compare":
        branchTree.add ifStmtInfixTree
    branchTree.add ifstmtBodyTree
    tree.add branchTree

    # # logic for the elif/else branch(es) of the if statement
    # var elseBranchTree = nnkElse.newTree()
    # var elseBodyTree = nnkStmtList.newTree()
    # for branch in node["orelse"]:
    #     var elifElseBranchTreeSeq: seq[NimNode]
    #     case branch["_type"].getStr
    #     of "If":
    #         elifElseBranchTreeSeq.addIfBranches(branch)
    #     of "Pass":
    #         elseBranchTree.addPass()
    #         elifElseBranchTreeSeq.add elseBranchTree
    #     of "Assign":
    #         elseBodyTree.addAssign(branch)
    #     # of "For":
    #     #     var elseBranchTree = nnkElse.newTree()
    #     #     elseBranchTree.addFor(branch)
    #     #     elifElseBranchTreeSeq.add elseBranchTree
        
    #     else: discard

    #     for brnch in elifElseBranchTreeSeq:
    #         tree.add brnch
    # elseBodyTree.add elseBodyTree
    # tree.add elseBranchTree

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
    of "NameConstant":
        ifBranchTree.addNameConstant(node["test"])

    else: raise newException(Exception,
        "(if statement is NOT a Comparison or Name Constant) Must add functionality :)")
 
    # logic for the body of the if statement
    # if node["body"].len > 1: raise newException(Exception,
    #     "(more than 1 body for If statement) Must add functionality :)")
    for body in node["body"]:
        case body["_type"].getStr
        of "Expr":
            ifStmtBodyTree.addExpr(body)
        of "Pass":
            ifStmtBodyTree.addPass()
        of "For":
            ifStmtBodyTree.addFor(body)
        of "Assign":
            ifStmtBodyTree.addAssign(body)
        else: discard

    # add the IF statement to the tree
    if node["test"]["_type"].getStr == "Compare":
        ifBranchTree.add ifStmtInfixTree
    ifBranchTree.add ifstmtBodyTree
    ifElifElseBranches.add ifBranchTree

    # logic for the elif/else branch(es) of the if statement
    for branch in node["orelse"]:
        var elifElseBranchTreeSeq: seq[NimNode]
        case branch["_type"].getStr
        of "If":
            elifElseBranchTreeSeq.addIfBranches(branch)
        of "Pass":
            var elseBranchTree = nnkElse.newTree()
            elseBranchTree.addPass()
            elifElseBranchTreeSeq.add elseBranchTree
        of "Expr":
            var elseBranchTree = nnkElse.newTree()
            elseBranchTree.addExpr(branch)
            elifElseBranchTreeSeq.add elseBranchTree
        # of "Assign":
        #     var elseBranchTree = nnkElse.newTree()
        #     elseBranchTree.addAssign(branch)
        #     elifElseBranchTreeSeq.add elseBranchTree
        # of "For":
        #     var elseBranchTree = nnkElse.newTree()
        #     elseBranchTree.addFor(branch)
        #     elifElseBranchTreeSeq.add elseBranchTree
        
        else: discard

        for brnch in elifElseBranchTreeSeq:
            ifElifElseBranches.add brnch

    # build the tree
    for branch in ifElifElseBranches:
        ifStmtTree.add branch

    tree.add ifStmtTree


proc addFor*(tree: NimNode, node: JsonNode) =

    # for TARGET in ITER: BODY
    var forStmtTree = nnkForStmt.newTree()

    # TARGET
    case node["target"]["_type"].getStr
    of "Name":
        forStmtTree.addName(node["target"])
    else: discard
    # ITER
    case node["iter"]["_type"].getStr
    of "Name":
        forStmtTree.addName(node["iter"])
    of "Str":
        forStmtTree.addString(node["iter"])
    of "List":
        forStmtTree.addList(node["iter"])
    else: discard
    # BODY
    var bodyStmtTree = nnkStmtList.newTree()
    for body in node["body"]:
        case body["_type"].getStr
        of "Expr":
            bodyStmtTree.addExpr(body)
        of "Pass":
            bodyStmtTree.addPass()
        of "If":
            bodyStmtTree.addIf(body)
        else: discard
    
    forStmtTree.add bodyStmtTree
    tree.add forStmtTree


# TODO
# While(test, body, orelse)
# Break
# Continue
# Try(body, handlers, orelse, finalbody)
# TryFinally(body, finalbody)
# TryExcept(body, handlers, orelse)
# ExceptHandler(type, name, body)
# With(items, body, type_comment)
# withitem(context_expr, optional_vars)