# Python AST node documentation (easy to read & understand)
# https://greentreesnakes.readthedocs.io/en/latest/nodes.html
import macros, json
import expressions, literals, statements, variables

proc addIfBranches*(tree: var seq[NimNode], node: JsonNode) =

    var branchTree = nnkElifBranch.newTree()
    var ifStmtInfixTree = nnkInfix.newTree()
    var ifStmtBodyTree = nnkStmtList.newTree()

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
            ifStmtBodyTree.addExpr(body)
        of "Pass":
            ifStmtBodyTree.addPass()
        else: discard

    # add the IF statement to the tree
    branchTree.add ifStmtInfixTree
    branchTree.add ifstmtBodyTree
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
        of "Pass":
            var elseBranchTree = nnkElse.newTree()
            elseBranchTree.addPass()
            elifElseBranchTreeSeq.add elseBranchTree
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
            ifStmtBodyTree.addExpr(body)
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
        var elifElseBranchTreeSeq: seq[NimNode]
        case branch["_type"].getStr
        of "If":
            elifElseBranchTreeSeq.addIfBranches(branch)
        of "Pass":
            var elseBranchTree = nnkElse.newTree()
            elseBranchTree.addPass()
            elifElseBranchTreeSeq.add elseBranchTree
        else: discard

        for brnch in elifElseBranchTreeSeq:
            ifElifElseBranches.add brnch

    # build the tree
    for branch in ifElifElseBranches:
        ifStmtTree.add branch

    tree.add ifStmtTree


# TODO
# For(target, iter, body, orelse, type_comment)
# While(test, body, orelse)
# Break
# Continue
# Try(body, handlers, orelse, finalbody)
# TryFinally(body, finalbody)
# TryExcept(body, handlers, orelse)
# ExceptHandler(type, name, body)
# With(items, body, type_comment)
# withitem(context_expr, optional_vars)