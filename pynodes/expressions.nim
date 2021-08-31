# Python AST node documentation (easy to read & understand)
# https://greentreesnakes.readthedocs.io/en/latest/nodes.html
import macros, json
import literals, variables

{.experimental: "codeReordering".} # removes need for forward declarations in top-level code


proc addExpr*(tree: NimNode, node: JsonNode) = # -- Expression --
    case node["value"]["_type"].getStr
    of "Call":
        tree.addCall(node["value"])
    of "BinaryOp":
        tree.addBinOp(node["value"])
    of "Name":
        tree.addName(node["value"])
    of "Num":
        tree.addIntOrFloat(node["value"])
    of "Str":
        tree.addString(node["value"])
    of "NameConstant":
        tree.addNameConstant(node["value"])
    else: discard


proc addCall*(tree: NimNode, node: JsonNode) = # -- Call --

    var callTree = nnkCall.newTree()
    case node["func"]["id"].getStr # function name
    of "print":
        callTree.add newIdentNode("echo")
    of "type":
        callTree.add newIdentNode("type")
    else: callTree.add newIdentNode(node["func"]["id"].getStr) # test

    for arg in node["args"]:
        case arg["_type"].getStr
        of "Str":
            callTree.addString(arg)
        of "Call":
            callTree.addCall(arg)
        of "NameConstant":
            callTree.addNameConstant(arg)
        of "Num":
            callTree.addIntOrFloat(arg)
        of "Name":
            callTree.addName(arg)
        of "List":
            callTree.addList(arg)
        of "JoinedStr":
            callTree.addJoinedStr(arg)
        else:
            raise newException(ValueError,
                "Unknown arg in node[\"args\"] (Call() in expressions.nim)\n" & $arg["_type"])
    
    for kwarg in node["keywords"]:
        discard

    tree.add callTree


proc addBinOp*(tree: NimNode, node: JsonNode) =
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
    # of "Pow": # must be able to handle two different ways (refer to `math` lib for pow() and `^` diff/uses)
    # *** OTHER OPERATORS ***
    else: discard

    case node["left"]["_type"].getStr # left side of the operator
    of "Num":
        infixTree.addIntOrFloat(node["left"])
    of "BinOp":
        infixTree.addBinOp(node["left"])
    of "Name":
        infixTree.addName(node["left"])
    of "Call":
        infixTree.addCall(node["left"])
    else: discard

    case node["right"]["_type"].getStr # right side of the operator
    of "Num":
        infixTree.addIntOrFloat(node["right"])
    of "BinOp":
        infixTree.addBinOp(node["right"])
    of "Name":
        infixTree.addName(node["right"])
    of "Call":
        infixTree.addCall(node["right"])
    else: discard

    tree.add infixTree


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
    of "BinOp": tree.addBinOp(node["left"])
    of "NameConstant": tree.addNameConstant(node["left"])
    of "Call": tree.addCall(node["left"])
    of "List": tree.addList(node["left"])
    else: discard

    for comparator in node["comparators"]: # add the comparator to the infix tree (right side)
        case comparator["_type"].getStr
        of "Str": tree.addString(comparator)
        of "Num": tree.addIntOrFloat(comparator)
        of "Name": tree.addName(comparator)
        of "BinOp": tree.addBinOp(comparator)
        of "NameConstant": tree.addNameConstant(comparator)
        of "Call": tree.addCall(comparator)
        of "List": tree.addList(comparator)
        else: discard


# TODO
# UnaryOp(op, operand)
# BoolOp(op, values)
# keyword(arg, value) # for function calls or class definitions
# IfExp(test, body, orelse)
# Attribute(value, attr, ctx) # for Attribute access