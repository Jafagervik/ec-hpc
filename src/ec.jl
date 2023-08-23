"""
Bitstrings, genetic algorithms and such thngs
"""

import Base.show

using Base.Threads
using IterTools
using Random

# Constants
const FINTESS_TARGET = 5
const MAX_GENERATIONS = 1000


mutable struct Bitstring
  data::Vector{Bool}

  function Bitstring(data::String)
    return new(map(x -> x == '1', collect(data)))
  end
end

function show(io::IO, bs::Bitstring)
  for c in bs.data
    print(c ? '1' : '0', " ")
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
  idxs = randperm(1, 5)[1:n]
  for i in idxs
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
  return Population([Bitstring(join(rand(["0", "1"]) for _ in 1:6)) for _ in 1:n], n)
end

# Selection
#
# 

"""
  Select at most n of all the strings in the population
"""
function deterministic_select!(p::Population, n::Integer; treshhold::Integer=1)
  r::Vector{Bitstring} = [e for e in p.pop if ones(e) >= treshhold]

  println(r)
  println()

  compare_score(lhs::Bitstring, rhs::Bitstring) = ones(lhs) > ones(rhs)

  # Only take largest elements
  if length(r) > n
    sort!(r, by=compare_score)
    r = r[1:n]
  end

  println(r)

  # Update population
  p = Population(r, length(r))
  return nothing
end

# Mutation - Alpha is the small amount of people that should not be mutated
function mutate!(p::Population; alpha=0.01)
  Threads.@threads for child in p.pop
    mutate!(child)
  end
end

# n is amount of bits to flip
function mutate!(bs::Bitstring, n=2)
  flip_random_n!(bs, n)
end

# mutate n bits randomly

""" 
Crossover between multiple bitstrings
"""

# Need a sliding window here and to account for both even and odd populations
function cross!(p::Population)

  sliding_windows = windows(p.pop, 2, step=2)


  return nothing


end

function cross!(lhs::Bitstring, rhs::Bitstring; split::Float16=0.5)

  new_s::Integer = length(lhs) * split

  return Bitstring(join(lhs.data[1:new_s], rhs.data[new_s:length(rhs)]))
end



# Fitness

f(x::Bitstring) = ones(x)


# Eval
evaluate_population(p::Population)::Bool = all(c -> f(c) > FINTESS_TARGET for c in p.pop)



function print_statistics(p::Population, gen::Integer)
  print("Found solution in $(gen) generations.\nPopulation with size: $(p.size) where first element is $(p.pop[1])")
end



function main()
  n = 1000

  population = generate_random_population(n)
  curr_gen = 1

  found_ideal_generation = false


  while curr_gen < MAX_GENERATIONS
    if evaluate_population(population)
      found_ideal_generation = true
      break
    end

    cross!(population)
    mutate!(population)

    curr_gen += 1
  end


  if found_ideal_generation
    print_statistics(population, curr_gen)
  else
    print("Better luck next time.")
  end
end

function test_main()

  pop = generate_random_population(6)

  println(pop)

  deterministic_select!(pop, 2)

end

Random.seed!(42)
test_main()
