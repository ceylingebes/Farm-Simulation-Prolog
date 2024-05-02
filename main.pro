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
values_sum([], 0).
values_sum([_Type-Value|T], Total) :-
    values_sum(T, Rest),
    Total is Value + Rest.


% 4- find_food_coordinates(+State, +AgentId, -Coordinates)

% 5- find_nearest_agent(+State, +AgentId, -Coordinates, -NearestAgent)

% 6- find_nearest_food(+State, +AgentId, -Coordinates, -FoodType, -Distance)

% 7- move_to_coordinate(+State, +AgentId, +X, +Y, -ActionList, +DepthLimit)

% 8- move_to_nearest_food(+State, +AgentId, -ActionList, +DepthLimit)

% 9- consume_all(+State, +AgentId, -NumberOfMoves, -Value, NumberOfChildren +DepthLimit)


