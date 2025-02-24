using StatsBase

struct Agent
    rule::Vector{Int}
    stateN::Int
end

struct Population
    agents::Vector{Agent}
    fitness::Vector{Int}
end

struct World
    states::Vector{Int} 
    center::Int    
end

function breed(parent1::Agent, parent2::Agent)
    new_rule = [rand(Bool) ? parent1.rule[i] : parent2.rule[i] for i in 1:length(parent1.rule)]
    return Agent(new_rule, parent1.stateN)
end


function repopulate(pop::Population,mutateR::Float64=0.5,deadFraction::Float64=0.5)
    n = length(pop.fitness)

    if all(pop.fitness .< 2)
        agents=[]
        for agent in pop.agents
            push!(agents,mutateRule(agent))
        end
        return Population(agents,fill(-1, n))
    end

    target_dead = floor(Int, deadFraction * n)  # we want at least this many fitness values to be -1
        
    current_dead = count(x -> x == -1, pop.fitness)

    
    if current_dead < target_dead

        surv_inds = findall(x -> x != -1, pop.fitness)

        sorted_inds = sort(surv_inds, by = i -> pop.fitness[i])
        num_to_cull = target_dead - current_dead
        for i in 1:num_to_cull
            pop.fitness[sorted_inds[i]] = -1
        end
    end

    survivors = [agent for (agent, fit) in zip(pop.agents, pop.fitness) if fit != -1]
    if isempty(survivors)
        error("No survivors available for breeding! f/p")
    end

    # Build new population arrays
    new_agents = Vector{Agent}(undef, n)
    new_fitness = Vector{Int}(undef, n)

    for i in 1:n
        if pop.fitness[i] != -1
            new_agents[i] = pop.agents[i]
            new_fitness[i] = pop.fitness[i]
        else
            parent1 = rand(survivors)
            parent2 = rand(survivors)
            child = breed(parent1, parent2)
            if rand() < mutateR
                child = mutateRule(child)
            end
            new_agents[i] = child
            new_fitness[i] = -1
        end
    end

    return Population(new_agents, new_fitness)
end    


function repopulateWithProximity(pop::Population,mutateR::Float64=0.5,deadFraction::Float64=0.5)
    n = length(pop.fitness)

    if all(pop.fitness .< 2)
        agents=[]
        for agent in pop.agents
            push!(agents,mutateRule(agent))
        end
        return Population(agents,fill(-1, n))
    end

    target_dead = floor(Int, deadFraction * n)  # we want at least this many fitness values to be -1
        
    current_dead = count(x -> x == -1, pop.fitness)

    
    if current_dead < target_dead

        surv_inds = findall(x -> x != -1, pop.fitness)

        sorted_inds = sort(surv_inds, by = i -> pop.fitness[i])
        num_to_cull = target_dead - current_dead
        for i in 1:num_to_cull
            pop.fitness[sorted_inds[i]] = -1
        end
    end

    survivors = [agent for (agent, fit) in zip(pop.agents, pop.fitness) if fit != -1]
    if isempty(survivors)
        error("No survivors available for breeding! f/p")
    end

    # Build new population arrays
    new_agents = Vector{Agent}(undef, n)
    new_fitness = Vector{Int}(undef, n)

    for i in 1:n
        if pop.fitness[i] != -1
            new_agents[i] = pop.agents[i]
            new_fitness[i] = pop.fitness[i]
        else
            
            parent1C = rand(1:length(survivors))
            parent2C = parent1C+1
            if parent2C>length(survivors)
                parent2C=1
            end
            
            parent1 = survivors[parent1C]
            parent2 = survivors[parent2C]
            child = breed(parent1, parent2)
            if rand() < mutateR
                child = mutateRule(child)
            end
            new_agents[i] = child
            new_fitness[i] = -1
        end
    end

    return Population(new_agents, new_fitness)
end    



function repopulateWithRank(pop::Population,mutateR::Float64=0.5,gamma::Float64=1.0)
    n = length(pop.fitness)

    if all(pop.fitness .< 2)
        agents=[]
        for agent in pop.agents
            push!(agents,mutateRule(agent))
        end
        return Population(agents,fill(-1, n))
    end


    n = length(pop.fitness)
    target_dead = 50#div(n, 4)  # we want at least half the population to have fitness -1

    # --- Culling step ---
    current_dead = count(x -> x == -1, pop.fitness)
    if current_dead < target_dead
        # Find indices of agents that are still "alive" (fitness ≠ -1)
        surv_inds = findall(x -> x != -1, pop.fitness)
        # Sort these indices by fitness (lowest first, so that the worst performers come first)
        sorted_inds = sort(surv_inds, by = i -> pop.fitness[i])
        num_to_cull = target_dead - current_dead
        for i in 1:num_to_cull
            pop.fitness[sorted_inds[i]] = -1
        end
    end

    # --- Reproduction step ---

    # Get indices of survivors (agents with fitness ≠ -1)
    survivor_inds = findall(x -> x != -1, pop.fitness)
    if isempty(survivor_inds)
        error("No survivors available for breeding!")
    end

    # For weighted parent selection we need to rank survivors.
    # We sort survivors in descending order (fittest first).
    sorted_survivor_inds = sort(survivor_inds, by = i -> pop.fitness[i], rev = true)
    num_survivors = length(sorted_survivor_inds)
    # Compute weights according to rank: weight of rank i is i^(-gamma).
    weights = [i^(-gamma) for i in 1:num_survivors]
    # Create a weights object; this will automatically normalize.
    w = Weights(weights)

    # Prepare new population arrays.
    new_agents = Vector{Agent}(undef, n)
    new_fitness = Vector{Int}(undef, n)

    # For each position in the new population, if the old agent survived,
    # transfer it; otherwise, breed a new agent.
    for i in 1:n
        if pop.fitness[i] != -1
            new_agents[i] = pop.agents[i]
            new_fitness[i] = pop.fitness[i]
        else
            # Pick two parents using weighted sampling over survivors.
            # The index returned is with respect to the sorted list.
            idx1 = sample(1:num_survivors, w)
            idx2 = sample(1:num_survivors, w)
            parent1 = pop.agents[sorted_survivor_inds[idx1]]
            parent2 = pop.agents[sorted_survivor_inds[idx2]]
            child = breed(parent1, parent2)
            # With probability mutateR, mutate the child.
            if rand() < mutateR
                child = mutateRule(child)
            end
            new_agents[i] = child
            new_fitness[i] = -1
        end
    end

    return Population(new_agents, new_fitness)
end
    

function mutateRule(agent::Agent)

    idx = rand(2:length(agent.rule))

    old_value = agent.rule[idx]
    new_value = rand(0:agent.stateN-1)

    while new_value==old_value
        new_value = rand(0:agent.stateN-1)
    end
    
    new_rule = copy(agent.rule)
    new_rule[idx] = new_value

    Agent(new_rule, agent.stateN)

end

function toIndex(stateV,n)
    index=0
    for c in 0:length(stateV)-1
        index+=stateV[end-c]*n^c
    end
    index+1
end
   
function makeWorld(initial::Vector{Int}=[0,0,1,0,0],center::Int=2)
    World(initial, center)
end

function updateWorld(world::World,agent::Agent)
    newStates = zeros(Int, length(world.states)+2)
    center=world.center+1
    for stateC in 2:length(world.states)-1 
        parent=toIndex(world.states[stateC-1:stateC+1],agent.stateN)

        newStates[stateC+1]=agent.rule[parent]

    end

    start=1
    
    while start<length(newStates)-2 && newStates[start+2]==0
        start+=1
        center-=1
    end
    
    if newStates[end-1]!=0
        push!(newStates,0)
    else
        while length(newStates)>2 && newStates[end-2]==0 
            pop!(newStates)
        end
    end

    makeWorld(newStates[start:end],center)
 
end

function printOut(world::World)
    for b in world.states
        print(b)
    end
    print("\n")
end


function printOut(agent::Agent)
    for b in agent.rule
        print(b)
    end
    print("\n")
end

function countNonzeros(v::AbstractVector)
    return count(!=(0), v)
end

#initialWorld=[0,0,1,2,0,2,1,0,0]



function evolveAgents(popN,genN,maxYears,mutateR,deadFraction)


    agents=[Agent(zeros(Int, 3^3),3) for _ in 1:popN]
    fitness=[-1 for _ in 1:popN]
    
    pop=Population(agents,fitness)
    
    initialWorld=[0,0,1,0,0]
    best=-1
    
    for genC in 1:genN

        fitness=pop.fitness
        
        for i in 1:popN
            
        if fitness[i]==-1
            
            yearC=0
            
            world=makeWorld(initialWorld)
            
            while length(world.states)>2 && yearC<maxYears
                world=updateWorld(world,pop.agents[i])
                yearC+=1
            end
            
            if yearC==maxYears
                fitness[i]=-1
            else
                fitness[i]=yearC
            end
        end
            
        end


        for f in pop.fitness
            if f> best
                best=f
            end
        end

        #=
        print(genC," ",best," ",maximum(pop.fitness)," - ")
        
        for f in pop.fitness
            print(f," ")
        end
        println()
        =#
            
        pop=repopulate(pop,mutateR,deadFraction)
        
    end

    best

end


#agent=Agent(vcat(0, rand(0:2, 3^3-1)),3)

popN=100

maxYears=150


genN=500

best=-1

mutateR=0.5
deadFraction=0.5


trialN=100

mutateR=0.75
deadFraction=0.5

for popN in 10:20:200

    bestAverage=0
    allBest=-1
    for _ in 1:trialN
        local best
        best=evolveAgents(popN,genN,maxYears,mutateR,deadFraction)
        bestAverage+=best
        if best>allBest
            allBest=best
            end
    end
    println(mutateR," ",deadFraction," ",popN," ",bestAverage/trialN," ",allBest)
end

#
#for a in pop.agents
#    printOut(a)
#end
