# single assignment
this = "that"
# multiple assignments to the same value
x = y = z = 9000
# syntax for multiple assignments to various values (basic tuple unpacking)
(a,b,c) = (1,2,3)
v1, v2, v3 = 9000, "hello", 9.4
test1, test2, test3 = (thisFunc(), f"{x}", z)

# delete these, just running for quick testing
ls = ["this", "that", "the other"]
for item in ls:
    print(item)

if x == z:
    print("x and z are equal")
elif x > z:
    print("x is greater than z")
else:
    print("x is less than z")