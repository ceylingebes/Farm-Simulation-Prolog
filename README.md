# Farm Simulation Project

## Overview
This Prolog project aims to simulate a farm environment where agents (animals) interact with objects (foods) within a given state. The project consists of several predicates to perform various actions such as calculating the value of the farm, finding food coordinates, locating nearest agents and food, moving agents to specific coordinates or nearest food, and consuming food items.

## Usage
To run the project, follow these steps:

1. Open SWI-Prolog:
    ```sh
    swipl
    ```

2. Consult the `main.pro` file:
    ```prolog
    consult('main.pro').
    ```

3. Use the provided predicates to perform actions on the farm. Below are the available predicates and their usage:

    1. **Calculating the Agents Distance (`agents_distance/3`)**
        ```prolog
        agents_distance(Agent1, Agent2, Distance)
        ```
        Computes the Manhattan distance between two agents.

    2. **Calculating the Number of Agents (`total_agents/2`)**:
        ```prolog
        total_agents(State, Total)
        ```
        Counts the total number of agents in the farm.

    3. **Calculating the Value of the Farm (`value_of_farm/2`)**:
        ```prolog
        value_of_farm(State, Value)
        ```
        Calculates the total value of all products on the farm.

    4. **Finding Food Coordinates (`find_food_coordinates/3`)**:
        ```prolog
        find_food_coordinates(State, AgentId, Coordinates)
        ```
        Finds the coordinates of foods consumable by a specific agent.

    5. **Finding Nearest Agent (`find_nearest_agent/4`)**:
        ```prolog
        find_nearest_agent(State, AgentId, Coordinates, NearestAgent)
        ```
        Finds the nearest agent to a given agent.

    6. **Finding Nearest Food (`find_nearest_food/5`)**:
        ```prolog
        find_nearest_food(State, AgentId, Coordinates, FoodType, Distance)
        ```
        Finds the nearest consumable food by an agent.

    7. **Moving to Coordinate (`move_to_coordinate/6`)**:
        ```prolog
        move_to_coordinate(State, AgentId, X, Y, ActionList, DepthLimit)
        ```
        Finds actions to move an agent to a specific coordinate.
