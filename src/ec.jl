"""
Bitstrings, genetic algorithms and such thngs
"""

import Base.show
using Base.Threads
using IterTools
using Plots
using Random
using Test

# Constants
const POP_SIZE = 50
const FITNESS_TARGET = 1000 # Or size of bit vector
const MAX_GENERATIONS = 100000

const DEBUG = true


mutable struct Bitstring
  data::Vector{Bool}

  function Bitstring(data::String)
    return new(map(x -> x == '1', collect(data)))
  end
end

function show(io::IO, bs::Bitstring)
  for c in bs.data
    print(c ? '1' : '0', "  ")
  end
end

size(bs::Bitstring) = length(bs.data)
ones(bs::Bitstring) = count(c -> c, bs.data)
zeros(bs::Bitstring) = count(c -> !c, bs.data)

# ================================================
#            HELPERS
# ================================================
function flip_at!(bs::Bitstring, idx::Integer)
  bs.data[idx] = !bs.data[idx]
end

function flip_all!(bs::Bitstring)
  for i in eachindex(bs.data)
    flip_at!(bs, i)
  end
end

function flip_random_n!(bs::Bitstring, n::Integer)
  idxs = randperm(FITNESS_TARGET)[1:n]

  @threads for i in idxs
    flip_at!(bs, i)
  end
end


# Population represented
mutable struct Population
  pop::Vector{Bitstring}
  size::Integer

  function Population(pop::Vector{Bitstring}, size::Integer)
    return new(pop, size)
  end
end

function show(io::IO, p::Population)
  for bs in p.pop
    println(bs)
  end
end

pop_size(pop::Population) = pop.size


# Init
function generate_random_population(n::Integer)
  return Population([Bitstring(join(rand(["0", "1"]) for _ in 1:FITNESS_TARGET)) for _ in 1:n], n)
end

# Mutation - Alpha is the small amount of people that should not be mutated
function mutate!(p::Population, alpha=0.1)
  # bstomutate = rand(1:POP_SIZE, Int(ceil(POP_SIZE * alpha)))

  # Random distinct members of population
  individuals_to_mutate = randperm(POP_SIZE)[1:Int(ceil(POP_SIZE * alpha))]

  for i in individuals_to_mutate
    mutate!(p.pop[i])
  end
end

# n is amount of bits to flip
mutate!(bs::Bitstring, n=2) = flip_random_n!(bs, n)


""" 
Crossover between multiple bitstrings
"""

"""
    cross two parents two create two children and add them to pop 
"""
function cross!(p::Population, i::Integer; split=0.5)
  half = Int(floor(FITNESS_TARGET * split))

  a = join([b ? "1" : "0" for b in p.pop[i].data[1:half]])
  b = join([b ? "1" : "0" for b in p.pop[i+1].data[half+1:FITNESS_TARGET]])

  c = join([b ? "1" : "0" for b in p.pop[i+1].data[1:half]])
  d = join([b ? "1" : "0" for b in p.pop[i].data[half+1:FITNESS_TARGET]])

  c1 = Bitstring(a * b)
  c2 = Bitstring(c * d)

  push!(p.pop, c1)
  push!(p.pop, c2)

  return nothing
end


# Eval - the best solution has all ones
evaluate_population(p::Population)::Bool = ones(p.pop[1]) == FITNESS_TARGET


function print_statistics(p::Population, gen::Integer)
  print("Found solution in $(gen) generations.\nPopulation with size: $(p.size) where first element is $(p.pop[1])")
end

function plotstats(xs, ys; title="test")
  plot!(xs, ys, title=title, xlabel="Gen", ylabel="D away from all ones")

  xaxis!()
  yaxis!()

  savefig("$(title).pdf")
end


function main()
  # INIT
  population = generate_random_population(POP_SIZE)
  curr_gen = 1

  found_ideal_generation = false

  # Amount of zeros 
  ys::Vector{Int64} = []


  while curr_gen < MAX_GENERATIONS
    # Evaluation based on fitness
    best = evaluate_population(population)

    # Add best value to ys
    append!(ys, zeros(population.pop[1]))

    if best
      found_ideal_generation = true
      break
    end

    # TODO: Add better selection here

    # Crossover - cross parents to create children
    for i = 1:2:POP_SIZE
      cross!(population, i)
    end

    # Mutation, an alpha percent of the population, children or not,
    # gets mutated through a virus
    mutate!(population, 0.02)

    # SELECTION, sort in descending order
    sort!(population.pop, by=x -> zeros(x))

    # Always only keep the best ones for next gen
    population.pop = population.pop[1:POP_SIZE]

    if DEBUG
      println("Gen: $(curr_gen) - Away: $(ys[curr_gen]) ", population.pop[1])
    end

    curr_gen += 1
  end


  if found_ideal_generation
    print_statistics(population, curr_gen)
    plotstats(1:curr_gen, ys)
    return nothing
  end

  print("Better luck next time.")
end

Random.seed!(42)
@time main()

## NOTES

# TODO: Parallel tournament selector
# TODO: Create children in their own array and only mutate these
# TODO: Sorting could be done in parallel?
# TODO: Parallel Mutation
