# %%
ls = """
Lines one.
Lines two "with a quoted section"!
Were done.
"""
print(ls)
# %%
for j in 0:4
    println(j^2)
end
# %%

for i ∈ 0:3, j ∈ 4:6
    println([i, j, i + j])
end
# %%

for c ∈ "Francois"
    print(c * " ⋅ ")
end

# %%

function duble(x)
    2x
end

squred(x) = x^2

println(duble(2))
println(squred(2))
# %%

function lengt3d(x, y, z)
    sqrt(x^2 + y^2 + z^2)
end

lengt3d(2, 4, 6)
# %%


# %%


# %%


# %%


# %%
