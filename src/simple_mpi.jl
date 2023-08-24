# using MPI

using Base.Threads
using Plots

const POPULATION_SIZE = 60
const GENES = -100:0.01:100
const TARGET = 0.0  # Target value (minimize f(x))

f(x) = x^3 + x^2 + x

mutable struct Individual
  gene::Float64
  fitness::Float64

  function Individual(gene)
    new(gene, cal_fitness(gene))
  end
end

mutated_gene() = rand(GENES)
create_gnome() = mutated_gene()

mate(par1::Individual, par2::Individual) = Individual((par1.gene + par2.gene) / 2.0)

@inline cal_fitness(gene) = abs(f(gene) - TARGET)

function saveplot(xs, ys, name="test")
  plot(xs, ys, label=name)

  xlabel!("Gen")
  ylabel!("Fitness")
  title!("GA over time")

  savefig("$(name).pdf")
end

function main()
  generation = 1
  tresh = 0.2
  found = false
  Δ = 1e-6

  population = [Individual(create_gnome()) for _ in 1:POPULATION_SIZE]

  ys::Vector{Float64} = []

  while !found
    # TODO: Parallel sort?
    @time sort!(population, by=x -> x.fitness)

    append!(ys, population[1].fitness)

    if population[1].fitness <= Δ
      found = true
      break
    end

    new_generation = Individual[]
    s = Int(tresh * POPULATION_SIZE)

    append!(new_generation, population[1:s])
    s = Int((1.0 - tresh) * POPULATION_SIZE)

    @threads for _ in 1:s
      parent1 = rand(population[1:Int(POPULATION_SIZE / 2)])
      parent2 = rand(population[1:Int(POPULATION_SIZE / 2)])
      child = mate(parent1, parent2)
      push!(new_generation, child)
    end

    population = new_generation

    println("Gen: $generation\tX: $(population[1].gene)\tFitness: $(population[1].fitness)")

    generation += 1
  end

  xs = 1:generation

  println("Good enough: Gen: $generation\tX: $(population[1].gene)\tFitness: $(population[1].fitness)")

  saveplot(xs, ys)

end

main()
