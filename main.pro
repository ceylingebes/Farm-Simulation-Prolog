% Huriye Ceylin Gebeş
% 2021400306
% compiling: yes
% complete: yes


:- ['cmpefarm.pro'].
:- init_from_map.

% consult("main.pro").
% query: state(Agents, Objects, Time, TurnOrder).
% Agents = agent_dict{0:agents{children:0, energy_point:0, subtype:cow, type:herbivore, x:1, y:1}},
% Objects = object_dict{0:object{subtype:grass, type:food, x:1, y:2}, 1:object{subtype:grass, type:food, x:4, y:2}, 2:object{subtype:grass, type:food, x:2, y:3}},
% Time = 0,
% TurnOrder = [0].


% 1- agents_distance(+Agent1, +Agent2, -Distance) DONE
% query: state(Agents, _, _, _), agents_distance(Agents.0, Agents.1, Distance).
% Computes the Manhattan distance between two agents
agents_distance(Agent1, Agent2, Distance):-
    get_dict(x, Agent1, X1),
    get_dict(x, Agent2, X2),
    get_dict(y, Agent1, Y1),
    get_dict(y, Agent2, Y2),
    Distance is abs(X1 - X2) + abs(Y1 - Y2).



% 2- number_of_agents(+State, -NumberOfAgents) DONE
% query: state(Agents, Objects, Time, TurnOrder), State=[Agents, Objects, Time, TurnOrder], number_of_agents(State, NumberOfAgents).
% Finds the total number of agents in a State and unifies it with NumberOfAgents
number_of_agents(State, NumberOfAgents) :-
    State = [Agents, _, _, _], % Extracting the Agents from the State
    dict_pairs(Agents, _, Pairs), % Converting the Agents dictionary into pairs
    counting_helper(Pairs, 0, NumberOfAgents). % Counting the number of pairs

counting_helper([], Count, Count). % Base case: empty list
counting_helper([_|T], Count, NumberOfAgents) :-
    NewCount is Count + 1,
    counting_helper(T, NewCount, NumberOfAgents).


% 3- value_of_farm(+State, -Value)  DONE
% query: state(Agents, Objects, Time, TurnOrder), State=[Agents, Objects, Time, TurnOrder], value_of_farm(State, Value).
% Calculates the total value of all products on the farm
value_of_farm(State, Value) :-
    State = [Agents, Objects, _, _], % Extracting Agents and Objects from the State
    dict_pairs(Agents, _, AgentPairs), % Extracting the Agents as pairs
    dict_pairs(Objects, _, FoodPairs), % Extracting the Foods as pairs
    values_sum(AgentPairs, AgentValue), % Calculating the total value of the Agents
    values_sum(FoodPairs, FoodValue), % Calculating the total value of the Foods
    Value is AgentValue + FoodValue. % Summing the total value of Agents and Foods

% Helper function to calculate the total value of a list of objects
values_sum([], 0). % Base case: empty list
values_sum([_-Agent|T], Total) :-
    get_dict(subtype, Agent, Subtype), % Extract the subtype of the object or agent
    value(Subtype, Value), % Get the value of the subtype
    values_sum(T, Rest), % Recursively call the helper function with the remaining objects
    Total is Value + Rest.



% 4- find_food_coordinates(+State, +AgentId, -Coordinates) DONE
% query: state(Agents, Objects, Time, TurnOrder), State=[Agents, Objects, Time, TurnOrder], find_food_coordinates(State, 0, Coordinates).
% Finds the coordinates of all food objects that an agent can eat and are within its reach
find_food_coordinates(State, AgentId, Coordinates) :-
    State = [Agents, Objects, _, _], % Extracting Agents and Objects from the State
    get_dict(AgentId, Agents, Agent), % Getting the agent with the specified AgentId
    get_dict(subtype, Agent, AgentType), % Getting the type of the agent
    can_eat(AgentType, FoodType), % Getting the type of food the agent can eat
    dict_pairs(Objects, _, FoodPairs), % Extracting the Foods as pairs
    findall([X,Y], (
        member(_-Food, FoodPairs), % Iterate over food objects
        % Extract the coordinates of the food object
        get_dict(x, Food, X),
        get_dict(y, Food, Y),
        % Check if the food object is of the type the agent can eat
        get_dict(subtype, Food, FoodSubtype),
        FoodSubtype = FoodType
    ), Coordinates),
    Coordinates \= [], % Add this check to handle empty food coordinates
    !. % Cut to prevent backtracking


% helper function to find all agents' coordinates from the state
find_all_agent_coordinates(State, AgentCoordinates) :-
    State = [Agents, _, _, _], % Extracting Agents from the State
    findall([X, Y], (
        get_dict(_, Agents, Agent), % Get each agent in the dictionary
        Agent = agents{children:_, energy_point:_, subtype:_, type:_, x:X, y:Y} % Unify with the coordinates of the agent
    ), AgentCoordinates).


% %helper function to calculate manhattan distance between two points
manhattan_distance([x:X1, y:Y1], [x:X2, y:Y2], Distance) :-
    Distance is abs(X1 - X2) + abs(Y1 - Y2).
manhattan_distance([X1, Y1], [X2, Y2], Distance) :-
    Distance is abs(X1 - X2) + abs(Y1 - Y2).


% 5- find_nearest_agent(+State, +AgentId, -Coordinates, -NearestAgent)
% query: state(Agents, Objects, Time, TurnOrder), State=[Agents, Objects, Time, TurnOrder], find_nearest_agent(State, AgentId, Coordinates, NearestAgent).
% Finds the coordinates and the identity of the nearest agent to the agent with the given AgentId in the State
find_nearest_agent(State, AgentId, Coordinates, NearestAgent) :-
    State = [Agents, _, _, _], % Extracting Agents and Objects from the State
    get_dict(AgentId, Agents, Agent), % Getting the agent with the specified AgentId
    get_dict(x, Agent, AgentX), % Getting the X coordinate of the agent
    get_dict(y, Agent, AgentY), % Getting the Y coordinate of the agent
    findall([[OtherX, OtherY], OtherAgent], (
        dict_pairs(Agents, _, AgentPairs), % Convert Agents dictionary into pairs
        member(_-OtherAgent, AgentPairs), % Iterate over agent pairs
        OtherAgent \= Agent, % Exclude the current agent
        get_dict(x, OtherAgent, OtherX), % Get the X coordinate of the other agent
        get_dict(y, OtherAgent, OtherY) % Get the Y coordinate of the other agent
    ), OtherAgentCoordinates), % List of all agent coordinates
    find_nearest_agent_helper(OtherAgentCoordinates, AgentX, AgentY, Coordinates, NearestAgent),
    !. % Find the nearest agent

% Helper predicate to find the nearest agent
find_nearest_agent_helper([], _, _, null, _). % Base case: no other agents found
find_nearest_agent_helper([[[X, Y], Agent]|Rest], AgentX, AgentY, Coordinates, NearestAgent) :-
    manhattan_distance([X, Y], [AgentX, AgentY], Dist),
    find_nearest_agent_helper(Rest, AgentX, AgentY, RestCoordinates, RestNearestAgent),
    (
        (RestCoordinates = null ; Dist < RestNearestAgentDistance),
        Coordinates = [X, Y],
        NearestAgent = Agent,
        RestNearestAgentDistance = Dist
    ;
        Coordinates = RestCoordinates,
        NearestAgent = RestNearestAgent
    ).



% 6- find_nearest_food(+State, +AgentId, -Coordinates, -FoodType, -Distance)
% query: state(Agents, Objects, Time, TurnOrder), State=[Agents, Objects, Time, TurnOrder], find_nearest_food(State, AgentId, Coordinates, FoodType, Distance).
% Finds the coordinates, type, and distance of the nearest food object to the agent with the given AgentId in the State
find_nearest_food(State, AgentId, Coordinates, FoodType, Distance) :-
    find_food_coordinates(State, AgentId, FoodCoordinates), % Find coordinates of all food objects that the agent can eat
    State = [Agents, _, _, _], % Extracting Agents from the State
    get_dict(AgentId, Agents, Agent), % Getting the agent with the specified AgentId
    get_dict(x, Agent, AgentX), % Getting the X coordinate of the agent
    get_dict(y, Agent, AgentY), % Getting the Y coordinate of the agent
    find_nearest_food_helper(FoodCoordinates, AgentX, AgentY, null, 999999, null, null, null, NearestDistance), % Find the nearest food
    Distance = NearestDistance, % Unify Distance with the nearest food's distance
    manhattan_distance([x:AgentX, y:AgentY], [x:Coordinates, y:_], Distance), % Calculate distance between agent and food
    get_dict(subtype, Food, FoodType), % Get the type of the nearest food
    get_dict(x, Food, Coordinates). % Unify Coordinates with the nearest food's coordinates


% Helper predicate to find the nearest food
find_nearest_food_helper([], _, _, FoodType, NearestDistance, NearestX, NearestY, NearestFoodType, NearestDistance) :-
    FoodType \= null.
find_nearest_food_helper([], _, _, _, _, _, _, _, _).
find_nearest_food_helper([[X, Y]|Rest], AgentX, AgentY, FoodType, NearestDistance, NearestX, NearestY, NearestFoodType, NearestDistance) :-
    manhattan_distance([x:AgentX, y:AgentY], [x:X, y:Y], Distance), % Calculate distance between agent and food
    Distance < NearestDistance, % Check if this food is closer than the previous nearest one
    find_nearest_food_helper(Rest, AgentX, AgentY, FoodType, Distance, X, Y, FoodType, Distance). % Continue searching for nearest food
find_nearest_food_helper([[X, Y]|Rest], AgentX, AgentY, FoodType, NearestDistance, NearestX, NearestY, NearestFoodType, NearestDistance) :-
    manhattan_distance([x:AgentX, y:AgentY], [x:X, y:Y], Distance), % Calculate distance between agent and food
    Distance >= NearestDistance, % Check if this food is not closer than the previous nearest one
    find_nearest_food_helper(Rest, AgentX, AgentY, FoodType, NearestDistance, NearestX, NearestY, NearestFoodType, NearestDistance). % Continue searching for nearest food

% 7- move_to_coordinate(+State, +AgentId, +X, +Y, -ActionList, +DepthLimit)




% 8- move_to_nearest_food(+State, +AgentId, -ActionList, +DepthLimit)

% 9- consume_all(+State, +AgentId, -NumberOfMoves, -Value, NumberOfChildren +DepthLimit)


