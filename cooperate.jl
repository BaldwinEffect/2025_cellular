using StatsBase

struct Agent
    rule::Vector{Int}
    stateN::Int
end

struct Group
    agents::Vector{Agent}
    fitness::Vector{Int}
end

struct Population
    groups::Vector{Group}
    fitness::Vector{Float64}
end

struct World
    states::Vector{Int} 
    center::Int    
end

function mostFit(pop::Population)
    best=-1
    for group in pop.groups
        thisBest=maximum(group.fitness)
        if thisBest>best
            best=thisBest
        end
    end
    best
end


function groupFitness(group::Group,oneOverP::Float64)
    if oneOverP==0.0
        return float(maximum(group.fitness))
    end

    totalF=0.0
    for f in group.fitness
        totalF+=abs(f)^1/oneOverP
    end

    totalF^oneOverP
end

function breed(parent1::Agent, parent2::Agent)
    new_rule = [rand(Bool) ? parent1.rule[i] : parent2.rule[i] for i in 1:length(parent1.rule)]
    return Agent(new_rule, parent1.stateN)
end


function breedNewGroup(group::Group,mutateR::Float64,maxYears::Int)

    newAgents=Vector{Agent}(undef, length(group.agents))
    newFitness=Vector{Int}(undef, length(group.agents))
    
    for agentC in 1:length(group.fitness)
        parent1=rand(group.agents)
        parent2=rand(group.agents)
        agent=breed(parent1,parent2)
        if rand()<mutateR
            agent=mutateRule(agent)
        end
        newAgents[agentC]=agent
        newFitness[agentC]=testAgent(agent,maxYears)
    end

    Group(newAgents,newFitness)

end


function breedNewGroupHaremetic(group::Group,mutateR::Float64,maxYears::Int)

    newAgents=Vector{Agent}(undef, length(group.agents))
    newFitness=Vector{Int}(undef, length(group.agents))

    bestVal=maximum(group.fitness)
    bestI=findall(x -> x == bestVal, group.fitness)
    parentI=rand(bestI)
    parent1=group.agents[parentI]

    
    for agentC in 1:length(group.fitness)
        parent2=group.agents[agentC]
        agent=breed(parent1,parent2)
        if agentC!=parentI && rand()<mutateR
            agent=mutateRule(agent)
        end
        newAgents[agentC]=agent
        newFitness[agentC]=testAgent(agent,maxYears)
    end

    Group(newAgents,newFitness)

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

function testAgent(agent::Agent,maxYears)

    initialWorld=[0,0,1,0,0]
    fitness=-1
    
    world=makeWorld(initialWorld)

    yearC=0
    
    while length(world.states)>2 && yearC<maxYears
        world=updateWorld(world,agent)
        yearC+=1
    end
    
    if yearC!=maxYears
        fitness=yearC
    end

    return fitness
    
end

function evolve(population::Population,genN,mutateR,maxYears,oneOverP)

    mostFits=[]
    for genC in 1:genN
        minVal = minimum(population.fitness)
        minI = findall(x -> x == minVal, population.fitness)
        cullI=rand(minI)
        
        if length(minI)<length(population.fitness)
            liveI=setdiff(eachindex(population.fitness), minI)
        else
            liveI=setdiff(eachindex(population.fitness), cullI)
        end
        parentI = rand(liveI)
        #population.groups[cullI]=breedNewGroupHaremetic(population.groups[parentI],mutateR,maxYears)
        population.groups[cullI]=breedNewGroup(population.groups[parentI],mutateR,maxYears)
        population.fitness[cullI]=groupFitness(population.groups[cullI],oneOverP)
        push!(mostFits,mostFit(population))
    end
    mostFits[end]

end


#agent=Agent(vcat(0, rand(0:2, 3^3-1)),3)

groupSize=5
groupN=20
maxYears=200

oneOverP=0.0

genN=1000

best=-1

mutateR=0.75

trialN=100

fitValues=[]

for trialC = 1:trialN

    global fitValues
    
    groups=Vector{Group}(undef, groupN)
    
    for groupC in 1:groupN
        agents=[Agent(zeros(Int, 3^3),3) for _ in 1:groupSize]
        fitness=[-1 for _ in 1:groupSize]
        groups[groupC]=Group(agents,fitness)
    end

    population=Population(groups,[-1.0 for _ in 1:groupN])
    
    push!(fitValues,evolve(population,genN,mutateR,maxYears,oneOverP))

end

println(mean(fitValues)," ",maximum(fitValues))
