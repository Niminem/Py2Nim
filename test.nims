import macros, json
import pynodes/control_flow

const fac4 = (var x = 1; for i in 1..4: x *= i; x)
echo fac4

dumptree:
    var fruits = ["apple", "banana", "cherry", "kiwi", "mango"]
    var newlist =  (var list: seq[string] ; for fruit in fruits: list.add fruit if "a" in fruit) # (x for x in fruits if "a" in x)