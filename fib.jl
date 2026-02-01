using CSV, DataFrames, Plots

function fibonacci(n::Int)::Int
    if n <= 1
        return n
    else
        return fibonacci(n - 1) + fibonacci(n - 2)
    end
end

# fibs(n)

function main()
    total_time = 0.0
    # temp println(pwd())
    output_file = pwd() * "fib-jl.csv"

    f = open(output_file, "w")
    write(f, "Run,Time")

    for i in 1:20
        start_time = time()
        fibonacci(45)
        end_time = time()
        execution_time = end_time - start_time
        total_time += execution_time
        println("Run $i time taken: $execution_time seconds")
        row = (; Run = i, Time = execution_time)
        CSV.write(f, [row], append = i > 1)
    end

    close(f)

    avg_time = total_time / 20
    println("Average time taken: $avg_time seconds")

    return nothing
end

main()
