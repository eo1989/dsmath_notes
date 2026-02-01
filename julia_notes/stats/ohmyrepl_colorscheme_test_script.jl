using OhMyRepl

# quick sample expression to test its syntax highlighting
sample_code = """
function demo(x)
    return sin(x) + cos(x)
end
demo(3.14)
"""

# cycle through all
for scheme in keys(OhMyREPL.colorschemes)
    OhMyREPL.colorscheme(scheme)
    println("\n--- Colorscheme: $(scheme) ---")
    println(sample_code)
    sleep(2)
end
