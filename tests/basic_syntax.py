# single assignment
this = "that"
that = this
# multiple assignments to the same value
x = y = z = 9000
# syntax for multiple assignments to various values (basic tuple unpacking)
(a,b,c) = (1,2,3)
v1, v2, v3 = 9000, "hello", 9.4
test1, test2, test3 = (thisFunc(), f"{x}", z) # make this only work during assignments for valid nim code ***

# Lists
ls = [1,2,3]
ls2 = ["this", "that", "the other"]
ls3 = [1.2, 3.2, 4.2]
ls4 = [(1,2,3), (4,5,6), (7,8,9)]
ls5 = [True, False, True]
# ls6 = [1, "this", 3.2] # mixed types in LIST not supported yet ***
# ls7 = [thisFunc(), "str", "str2"] # calls in LIST not supported yet (zero typeinfo functionality) ***
# ls8 = [(1,2,3), (1.2, 3.3), ("this", "that", "the other")] # this works, but isn't valid nim code. (need typeinfo) ***
# ls9 = [x,y,z] # identifiers in LIST not supported yet (zero typeinfo functionality) ***

# if/elif/else
if x == 9000:
    myls = [1,2,3]
    for elem in myls:
        if 5 >= 7:
            print(elem)
        elif elem == 2:
            print("elem is 2")
        else:
            pass
    if True:
        print("true")
elif x != 9001:
    print("x is 9001")
    tup = (1,2,3)
else:
    print("x is neither 9000 nor 9001")

if False:
    print("not false")
else:
    pass