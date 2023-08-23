using Random
using Statistics
using Plots
using Base.Threads

# Function to minimize
f(x) = x - 6
fitness(x) = f(x)

eval_population(pop) = f.(pop)

# selection 
function select_parents(population, scores)
  rank = sortperm(scores, rev=true)
  rank_prob = [((2 * length(scores) - i) / (2 * length(scores))) for i in 1:length(scores)]
  parent_indices = Int[]

  for _ in 1:2
    random_number = rand()
    for i in eachindex(rank_prob)
      if random_number < rank_prob[i]
        push!(parent_indices, rank[i])
        break
      end
    end
  end

  return [population[i] for i in parent_indices]
end

# crossover - single point
function crossover(parents)
  point = rand(1:length(parents[1]))
  @show point
  c1 = vcat(parents[1][1:point], parents[2][point+1:end])
  c2 = vcat(parents[2][1:point], parents[1][point+1:end])
  return [c1, c2]
end

# Mutation 
function mutate(child, mutation_rate)
  if rand(Float64, (0, 1)) < mutation_rate
    child *= rand(Float64, (0.99, 1.01))
  end

  return child
end


function ga()
  gens = 100
  pop_size = 10

  # 1: Init 
  population = rand(-20:0.01:20, pop_size)

  graph = []

  for gen in 1:gens
    # 2: Eval 
    scores = eval_population(population)

    # 3: Selection
    parents = [select_parents(population, scores) for _ in 1:pop_size/2]

    @show parents

    # 4: crossover 
    children = crossover.(parents)
    children = [item for sublist in children for item in sublist]

    # 5: Mutation 
    mutated = mutate.(children, 0.01)

    combined = vcat(parents, mutated)

    ranked_pop = [x for (_, x) in zip(scores, combined)[end:-1:1]]
    population = ranked_pop[1:pop_size+1]

    println("Gen $(gen) - x: $(ranked_pop[1]) - f(x): ")
    push!(graph, (ranked_pop[1], fitness(ranked_pop[1])))
  end

  return population[0], graph[1], graph[2]
end


function main()
  Random.seed!(42)
  best, xs, ys = ga()

  println(best)

  plot(xs, ys, label="Line Plot", linewidth=2, marker=:circle, markersize=6)
  xlabel!("Generation")
  ylabel!("Best value")
  title!("Evolution")

  # Display the plot
  display(gcf())  # gcf() returns the current figure
end

main()
