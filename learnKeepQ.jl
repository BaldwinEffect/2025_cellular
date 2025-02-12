
using Random
using IterTools

struct Agent
    rule::Vector{Int}
    stateN::Int
end

function learnAgents(agent::Agent)
    # Find indices where -1 appears

    vec=agent.rule
    
    missing_indices = findall(x -> x == -1, vec)
    
    if isempty(missing_indices)
        return [Agent(vec,agent.stateN)]
    end
    
    replacements = product(fill(0:agent.stateN-1, length(missing_indices))...)
    
    result = Vector{Agent}()
    for repl in replacements
        new_vec = copy(vec)
        new_vec[missing_indices] .= repl  # Assign replacements
        push!(result, Agent(new_vec,agent.stateN))
    end    
    return result
end



struct World
    states::Vector{Int} 
    center::Int    
end

function mutateRule(agent::Agent)

    idx = rand(2:length(agent.rule))

    old_value = agent.rule[idx]
    new_value = rand(-1:agent.stateN-1)

    while new_value==old_value
        new_value = rand(-1:agent.stateN-1)
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
        newStates[stateC+1]=agent.rule[parent] end

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
        if b==-1
            print("?")
        else
            print(b)
        end
    end
    print("\n")
end

function countNonzeros(v::AbstractVector)
    return count(!=(0), v)
end


function makeRule(stateN::Int,numberQ::Int)
    len = stateN^stateN
    vec = zeros(Int, len)

    if numberQs > len - 1
        error("numberQs f/p.")
    end

    possible_indices = 2:len 
    selected_indices = shuffle(possible_indices)[1:numberQ]

    vec[selected_indices] .= -1

    return vec
end


stateN=3
numberQs=5

attempts=50

println(3^numberQs)

agent=Agent(makeRule(stateN,numberQs),stateN)

printOut(agent)

maxYears=100

oldAgent=agent

genN=1000

best=-1

#initialWorld=[0,0,1,2,0,2,1,0,0]
initialWorld=[0,0,1,0,0]

for genC in 1:genN
    #print(genC," ")
    global agent,best,oldAgent,initialWorld

    years=[]
    
    agents=shuffle(learnAgents(agent))

    if length(agents)>attempts
        agents=agents[1:attempts]
    end
    
    for learnedAgent in agents
        yearC=0
        world=makeWorld(initialWorld)
        while length(world.states)>2 && yearC<maxYears
            world=updateWorld(world,learnedAgent)
            yearC+=1
        end
        push!(years,yearC)
    end

    yearC=maximum(years)
    
    if yearC==maxYears || yearC<best yearC==1 
        agent=oldAgent
    else
        if best<yearC
            print(genC," ",yearC," ")
            printOut(agent)
        end
        best=yearC
        oldAgent=agent
    end

    agent=mutateRule(agent)
    
end
