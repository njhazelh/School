# search.py
# ---------
# Licensing Information:  You are free to use or extend these projects for
# educational purposes provided that (1) you do not distribute or publish
# solutions, (2) you retain this notice, and (3) you provide clear
# attribution to UC Berkeley, including a link to http://ai.berkeley.edu.
#
# Attribution Information: The Pacman AI projects were developed at UC Berkeley.
# The core projects and autograders were primarily created by John DeNero
# (denero@cs.berkeley.edu) and Dan Klein (klein@cs.berkeley.edu).
# Student side autograding was added by Brad Miller, Nick Hay, and
# Pieter Abbeel (pabbeel@cs.berkeley.edu).


"""
In search.py, you will implement generic search algorithms which are called by
Pacman agents (in searchAgents.py).
"""
import util


class SearchProblem:
    """
    This class outlines the structure of a search problem, but doesn't implement
    any of the methods (in object-oriented terminology: an abstract class).

    You do not need to change anything in this class, ever.
    """

    def getStartState(self):
        """
        Returns the start state for the search problem.
        """
        util.raiseNotDefined()

    def isGoalState(self, state):
        """
          state: Search state

        Returns True if and only if the state is a valid goal state.
        """
        util.raiseNotDefined()

    def getSuccessors(self, state):
        """
          state: Search state

        For a given state, this should return a list of triples, (successor,
        action, stepCost), where 'successor' is a successor to the current
        state, 'action' is the action required to get there, and 'stepCost' is
        the incremental cost of expanding to that successor.
        """
        util.raiseNotDefined()

    def getCostOfActions(self, actions):
        """
         actions: A list of actions to take

        This method returns the total cost of a particular sequence of actions.
        The sequence must be composed of legal moves.
        """
        util.raiseNotDefined()


def tinyMazeSearch(problem):
    """
    Returns a sequence of moves that solves tinyMaze.  For any other maze, the
    sequence of moves will be incorrect, so only use this for tinyMaze.
    """
    from game import Directions

    s = Directions.SOUTH
    w = Directions.WEST
    return [s, s, w, s, w, w, s, w]


def depthFirstSearch(problem):
    """
    Search the deepest nodes in the search tree first.
    """
    startState = problem.getStartState()
    visited = []
    frontier = util.Stack()
    frontier.push(startState)
    pathMap = {}

    while not frontier.isEmpty():
        node = frontier.pop()
        if problem.isGoalState(node):
            # return the answer
            path = []
            next = node
            while next != startState:
                next, dirFromNext = pathMap[next]
                path.append(dirFromNext)
            path.reverse()
            return path
        elif node in visited:
            continue
        else:
            visited.append(node)
            for successor in problem.getSuccessors(node):
                neighbor, dirToNeighbor, _ = successor
                if neighbor not in visited:
                    pathMap[neighbor] = (node, dirToNeighbor)
                    frontier.push(neighbor)

    raise Exception("No path to goal")


def breadthFirstSearch(problem):
    """
    Search the shallowest nodes in the search tree first.
    """
    startState = problem.getStartState()
    visited = []
    frontier = util.Queue()
    frontier.push(startState)
    frontierSet = set()
    frontierSet.add(startState)
    pathMap = {}

    if problem.isGoalState(startState):
        return []

    while not frontier.isEmpty():
        node = frontier.pop()
        frontierSet.remove(node)
        visited.append(node)
        if problem.isGoalState(node):
            # return the answer
            path = []
            next = node
            while next is not startState:
                next, dirToEnd = pathMap[next]
                path.append(dirToEnd)
            path.reverse()
            return path
        for successor in problem.getSuccessors(node):
            neighbor, dirToNeighbor, _ = successor
            if neighbor not in visited and neighbor not in frontierSet:
                pathMap[neighbor] = (node, dirToNeighbor)
                frontier.push(neighbor)
                frontierSet.add(neighbor)

    raise Exception("No path to goal")


def uniformCostSearch(problem):
    """
    Search the node of least total cost first.
    """
    startState = problem.getStartState()
    visited = []
    frontier = util.PriorityQueue()
    frontier.push((startState, 0), 0)
    pathMap = {}
    costMap = {}

    if problem.isGoalState(startState):
        return []

    while not frontier.isEmpty():
        node, graphCost = frontier.pop()

        if problem.isGoalState(node):
            # return the answer
            path = []
            next = node
            while next is not startState:
                next, dirToEnd = pathMap[next]
                path.append(dirToEnd)
            path.reverse()
            return path

        visited.append(node)

        for successor in problem.getSuccessors(node):
            neighbor, dirToNeighbor, edgeCost = successor
            neighborCost = graphCost + edgeCost
            if neighbor in visited:
                continue
            elif neighbor not in costMap or neighborCost < costMap[neighbor]:
                pathMap[neighbor] = (node, dirToNeighbor)
                frontier.push((neighbor, neighborCost), neighborCost)
                costMap[neighbor] = neighborCost

    raise Exception("No path to goal")


def nullHeuristic(state, problem=None):
    """
    A heuristic function estimates the cost from the current state to the nearest
    goal in the provided SearchProblem.  This heuristic is trivial.
    """
    return 0


def aStarSearch(problem, heuristic=nullHeuristic):
    """
    Search the node that has the lowest combined cost and heuristic first.
    """
    startState = problem.getStartState()
    visited = []
    frontier = util.PriorityQueue()
    frontier.push((startState, 0), 0)
    pathMap = {}
    costMap = {}

    if problem.isGoalState(startState):
        return []

    while not frontier.isEmpty():
        node, graphCost = frontier.pop()

        if problem.isGoalState(node):
            # return the answer
            path = []
            next = node
            while next is not startState:
                next, dirToEnd = pathMap[next]
                path.append(dirToEnd)
            path.reverse()
            return path

        visited.append(node)

        for successor in problem.getSuccessors(node):
            neighbor, dirToNeighbor, edgeCost = successor
            neighborCost = graphCost + edgeCost
            if neighbor in visited:
                continue
            elif neighbor not in costMap or neighborCost < costMap[neighbor]:
                pathMap[neighbor] = (node, dirToNeighbor)
                frontier.push((neighbor, neighborCost), neighborCost + heuristic(neighbor, problem))
                costMap[neighbor] = neighborCost

    raise Exception("No path to goal")

# Abbreviations
bfs = breadthFirstSearch
dfs = depthFirstSearch
astar = aStarSearch
ucs = uniformCostSearch
