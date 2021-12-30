# single assignment
this = "that"
# multiple assignments to the same value
x = y = z = 9000
# syntax for multiple assignments to various values (basic tuple unpacking)
(a,b,c) = (1,2,3)
v1, v2, v3 = 9000, "hello", 9.4
test1, test2, test3 = (thisFunc(), f"{x}", z)

# BASIC TYPES

# lists
ls = [1,2,3]
ls2 = ["this", "that", "the other"]
ls3 = [1.2, 3.2, 4.2]
ls4 = [(1,2,3), (4,5,6), (7,8,9)]
# ls5 = [1, "this", 3.2] # mixed types in list not supported yet ***
# ls6 = [thisFunc(), "str", "str2"] # calls, and typeinfo from calls not supported yet ***
# ls7 = [(1,2,3), (1.2, 3.3), ("this", "that", "the other")] # this works, but isn't valid nim code. need typeinfo ***
