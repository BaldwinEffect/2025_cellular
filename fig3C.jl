 
using StatsBase

groupSize = parse(Int, ARGS[1])

oneOverP = parse(Float64, ARGS[2])
t1=parse(Int, ARGS[3])
t2=parse(Int, ARGS[4])

global record=3794
global glider=0
global tested=0

global freqSave=500


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


function countUniqueRules(pop::Population)
    all_rules = [Tuple(agent.rule) for group in pop.groups for agent in group.agents]
    return length(unique(all_rules))
end

function mostFit(pop::Population)
    global record
    best=-1
    for group in pop.groups
        thisBest=maximum(group.fitness)
        if thisBest>best
            best=thisBest
            if thisBest>record
                for i in 1:length(group.fitness)
                    if group.fitness[i]>record

open("2025-02-14_longest.txt", "a") do file
    println(file, "$(group.fitness[i]) $(group.agents[i].rule)")
end

	                            record=group.fitness[i]
                    end
                end
            end
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
        totalF+=abs(f)^(1/oneOverP)
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

function convertToNumber(agent::Agent)
    number=0
    base=agent.stateN
    for c in 1:length(agent.rule)
        number+=agent.rule[c]*base^(c-1)
    end
    number
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
        parentMutate=false
        if rand()<mutateR
            agent=mutateRule(agent)
            if agentC==parentI
                parentMutate=true
            end
        end

        newAgents[agentC]=agent

        if agentC==parentI && parentMutate==true
            newFitness[agentC]=group.fitness[agentC]            
        else
            newFitness[agentC]=testAgent(agent,maxYears)
        end
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

function testAgent(agent::Agent,maxYears)

    global glider,tested
    tested+=1
    
    initialWorld=[0,0,1,0,0]
    fitness=-1
    
    world=makeWorld(initialWorld)

    worlds=[[1]]
    
    yearC=0
    
    while length(world.states)>2 && yearC<maxYears
        world=updateWorld(world,agent)
        trimmedWorld=trimZeros(world.states)
        for w in worlds
            if trimmedWorld==w
                yearC=maxYears-1
                glider+=1
                break
            end
        end
        push!(worlds,trimmedWorld)
        yearC+=1
    end
    
    if yearC!=maxYears
        fitness=yearC
    end

    return fitness
    
end

function trimZeros(states)
    first = findfirst(!=(0), states)
    last = findlast(!=(0), states)
    if first === nothing || last === nothing
        return []
    end
    return states[first:last]
end


function evolve(population::Population,genN,mutateR,maxYears,oneOverP,groupN,trialC,filename)

    mostFits=[]
        
    for genC in 1:genN

    
    	if genC%freqSave==0
		open(filename, "a") do file
                    unique=countUniqueRules(population)
	            println(file,"$(genC) $(trialC) $(oneOverP)  $(unique)")
		end
	end

    	minVal = minimum(population.fitness)
        minI = findall(x -> x == minVal, population.fitness)
        cullI=rand(minI)

	#best parent group
	if length(minI)<length(population.fitness)
	   maxVal = maximum(population.fitness)
	   maxI = findall(x -> x == maxVal, population.fitness)
        else
            maxI=setdiff(eachindex(population.fitness), cullI)
        end
        parentI = rand(maxI)


	population.groups[cullI]=breedNewGroup(population.groups[parentI],mutateR,maxYears)
	
	population.fitness[cullI]=groupFitness(population.groups[cullI],oneOverP)

	fitValue=mostFit(population)
	
	
	push!(mostFits,fitValue)
    end

    mostFits[end]

end


#agent=Agent(vcat(0, rand(0:2, 3^3-1)),3)


maxYears=5000

cullN=20000

best=-1

mutateR=0.75

oldLength=0

#groupSize=5
#groupN=20

totalN=100

filenameBase="fig3C/2025-04-07"

filename=filenameBase*"_"*string(oneOverP)*"_"*string(t1)*"_"*string(t2)*".txt"

begin

    global oldLength,glider,tested
    
    groupN=floor(Int,totalN/groupSize)
    genN=floor(Int,cullN/groupSize)
    
    for trialC = t1:t2
        
        groups=Vector{Group}(undef, groupN)
        
        for groupC in 1:groupN
        agents=[Agent(zeros(Int, 3^3),3) for _ in 1:groupSize]
            fitness=[-1 for _ in 1:groupSize]
            groups[groupC]=Group(agents,fitness)
        end
        
        population=Population(groups,[-1.0 for _ in 1:groupN])

	fitValue=evolve(population,genN,mutateR,maxYears,oneOverP,groupN,trialC,filename)
        
    end

    glider=0
    tested=0
end

