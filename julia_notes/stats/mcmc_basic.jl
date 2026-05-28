using Distributions

function p(x)
    return pdf(Normal(0, 1), x)
end

function mcmc(p, N)
    samples = []

    # initiating sample
    push!(samples, 0)

    for i in 2:N
        # xᵢ is the previous sample
        xᵢ = samples[i - 1]

        # sample from the proposal distribution
        x_star = rand(Normal(xᵢ, 1))

        # accept or reject the proposal
        acceptance = p(x_star) / p(xᵢ)
        if rand() < acceptance
            push!(samples, x_star)
        else
            push!(samples, xᵢ)
        end
    end
    return samples
end

chain = mcmc(p, 10_000)

println("mean: ", mean(chain))
println("stdev: ", std(chain))
