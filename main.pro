% Huriye Ceylin Gebeş
% 2021400306
% compiling: yes
% complete: yes


:- ['cmpefarm.pro'].
:- init_from_map.


% 1- agents_distance(+Agent1, +Agent2, -Distance)
% Computes the Manhattan distance between two agents DONE
agents_distance(Agent1, Agent2, Distance):-
    get_dict(x, Agent1, X1),
    get_dict(x, Agent2, X2),
    get_dict(y, Agent1, Y1),
    get_dict(y, Agent2, Y2),
    Distance is abs(X1 - X2) + abs(Y1 - Y2).



% 2- number_of_agents(+State, -NumberOfAgents)
% Finds the total number of agents in a State and unifies it with NumberOfAgents
number_of_agents(State, NumberOfAgents) :-
    State = [Agents, _, _, _], % Extracting the Agents from the State
    dict_pairs(Agents, _, Pairs), % Converting the Agents dictionary into pairs
    length(Pairs, NumberOfAgents). % Finding the length of the pairs, which represents the number of agents



% 3- value_of_farm(+State, -Value)
% Calculates the total value of all products on the farm
value_of_farm(State, Value) :-
    State = [Agents, Objects, _, _], % Extracting Agents and Objects from the State
    dict_pairs(Agents, _, Animals), % Extracting the Animals from the Agents
    dict_pairs(Objects, _, Foods), % Extracting the Foods from the Objects
    values_sum(Animals, AnimalValue), % Calculating the total value of the Animals
    values_sum(Foods, FoodValue), % Calculating the total value of the Foods
    Value is AnimalValue + FoodValue. % Summing the total value of Animals and Foods


% Helper function to calculate the total value of a list of objects
values_sum([], 0). % Base case: empty list
values_sum([_Type-Value|T], Total) :-
    values_sum(T, Rest),
    Total is Value + Rest.



% 4- find_food_coordinates(+State, +AgentId, -Coordinates)
% Finds the coordinates of all food objects that an agent can eat and are within its reach
find_food_coordinates(State, AgentId, Coordinates) :-
    State = [Agents, Objects, _, _], % Unpack the State into its components
    get_dict(AgentId, Agents, Agent), % Retrieve information about the agent with the given AgentId
    % Find all reachable food coordinates using findall
    findall([X,Y], (
        dict_pairs(Objects, _, ObjectList), % Iterate over all objects in the State
        member(_-Object, ObjectList),
        get_dict(subtype, Object, FoodType), % Extract the subtype of the object, representing its type
        can_eat(Agent.subtype, FoodType),
        agents_distance(Agent, Object, Distance),
        Distance =< Agent.subtype * 2, % Check if the food is within reach of the agent
        get_dict(x, Object, X),
        get_dict(y, Object, Y)
    ), Coordinates).



% 5- find_nearest_agent(+State, +AgentId, -Coordinates, -NearestAgent)
% Finds the coordinates and the identity of the nearest agent to the agent with the given AgentId in the State
find_nearest_agent(State, AgentId, Coordinates, NearestAgent) :-
    % Unpack the State into its components
    State = [Agents, _, _, _],
    % Ensure that Agents dictionary is non-empty
    dict_pairs(Agents, _, AgentList),
    AgentList \= [], % Add this check to handle empty agent list
    get_dict(AgentId, Agents, Agent),
    % Extract the current position of the agent
    get_dict(x, Agent, X),
    get_dict(y, Agent, Y),
    % Find all other agents in the State
    dict_pairs(Agents, _, AgentList),
    % Initialize variables for tracking the nearest agent and its distance
    MinDistance = infinity,
    NearestAgentId = null,
    % Iterate over all agents in the State
    find_nearest_helper(AgentId, AgentList, X, Y, MinDistance, NearestAgentId),
    % If a nearest agent is found, unify the Coordinates and NearestAgent variables
    (NearestAgentId \= null ->
        (get_dict(NearestAgentId, Agents, NearestAgent),
        Coordinates = [X_, Y_])
        ;
        (Coordinates = [], NearestAgent = null)
    ).


% Helper function to find the nearest agent to the agent with the given AgentId
find_nearest_agent_helper(_, [], _, _, _, _). % Base case: no agents left
find_nearest_agent_helper(AgentId, [Id-Agent_|T], X, Y, MinDistance, NearestAgentId) :-
    % Skip the agent with the given AgentId
    AgentId \= Id,
    % Extract the position of the current agent
    get_dict(x, Agent_, X_),
    get_dict(y, Agent_, Y_),
    % Calculate the Manhattan distance between the current agent and the given agent
    agents_distance(Agent, Agent_, Distance),
    % If the distance is smaller than the current minimum distance, update the nearest agent information
    (Distance < MinDistance ->
        (MinDistance = Distance, NearestAgentId = Id)
        ;
        true
    ),
    % Recursively call the helper function with the remaining agents
    find_nearest_agent_helper(AgentId, T, X, Y, MinDistance, NearestAgentId).



% 6- find_nearest_food(+State, +AgentId, -Coordinates, -FoodType, -Distance)
% Finds the coordinates, type, and distance of the nearest food object to the agent with the given AgentId in the State
find_nearest_food(State, AgentId, Coordinates, FoodType, Distance) :-
    State = [Agents, Objects, _, _],
    % Retrieve information about the agent with the given AgentId
    get_dict(AgentId, Agents, Agent),
    % Extract the current position of the agent
    get_dict(x, Agent, X),
    get_dict(y, Agent, Y),
    % Find all reachable food objects and their coordinates
    find_food_coordinates(State, AgentId, FoodCoordinates),
    % Initialize variables for tracking the nearest food object and its distance
    MinDistance = infinity,
    NearestFood = [],
    % Iterate over all food coordinates to find the nearest one
    find_nearest_food_helper(FoodCoordinates, X, Y, MinDistance, NearestFood),
    % Unify the result with the output variables
    (NearestFood = [X_, Y_] ->
        (Coordinates = [X_, Y_],
        % Find the type of the nearest food object
        get_dict([X_, Y_], Objects, Food),
        get_dict(subtype, Food, FoodType),
        % Calculate the distance to the nearest food object
        Distance is abs(X - X_) + abs(Y - Y_))
        ;
        (Coordinates = [], FoodType = null, Distance = infinity)
    ).


% Helper function to find the nearest food object
find_nearest_food_helper([], _, _, _, _). % Base case: no food objects left
find_nearest_food_helper([[X,Y]|T], XAgent, YAgent, MinDistance, NearestFood) :-
    % Calculate the Manhattan distance between the agent and the food object
    Distance is abs(XAgent - X) + abs(YAgent - Y),
    % If the distance is smaller than the current minimum distance, update the nearest food object information
    (Distance < MinDistance ->
        (MinDistance = Distance, NearestFood = [X, Y])
        ;
        true
    ),
    % Recursively call the helper function with the remaining food coordinates
    find_nearest_food_helper(T, XAgent, YAgent, MinDistance, NearestFood).



% 7- move_to_coordinate(+State, +AgentId, +X, +Y, -ActionList, +DepthLimit)

% 8- move_to_nearest_food(+State, +AgentId, -ActionList, +DepthLimit)

% 9- consume_all(+State, +AgentId, -NumberOfMoves, -Value, NumberOfChildren +DepthLimit)


