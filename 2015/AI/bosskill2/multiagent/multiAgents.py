# multiAgents.py
# --------------
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


from util import manhattanDistance
from game import Directions
import random, util

from game import Agent

class ReflexAgent(Agent):
    """
      A reflex agent chooses an action at each choice point by examining
      its alternatives via a state evaluation function.

      The code below is provided as a guide.  You are welcome to change
      it in any way you see fit, so long as you don't touch our method
      headers.
    """


    def getAction(self, gameState):
        """
        You do not need to change this method, but you're welcome to.

        getAction chooses among the best options according to the evaluation function.

        Just like in the previous project, getAction takes a GameState and returns
        some Directions.X for some X in the set {North, South, West, East, Stop}
        """
        # Collect legal moves and successor states
        legalMoves = gameState.getLegalActions()

        # Choose one of the best actions
        scores = [self.evaluationFunction(gameState, action) for action in legalMoves]
        bestScore = max(scores)
        bestIndices = [index for index in range(len(scores)) if scores[index] == bestScore]
        chosenIndex = random.choice(bestIndices) # Pick randomly among the best

        "Add more of your code here if you want to"

        return legalMoves[chosenIndex]

    def evaluationFunction(self, currentGameState, action):
        """
        Design a better evaluation function here.

        The evaluation function takes in the current and proposed successor
        GameStates (pacman.py) and returns a number, where higher numbers are better.

        The code below extracts some useful information from the state, like the
        remaining food (newFood) and Pacman position after moving (newPos).
        newScaredTimes holds the number of moves that each ghost will remain
        scared because of Pacman having eaten a power pellet.

        Print out these variables to see what you're getting, then combine them
        to create a masterful evaluation function.
        """
        # Useful information you can extract from a GameState (pacman.py)
        successorGameState = currentGameState.generatePacmanSuccessor(action)
        newPos = successorGameState.getPacmanPosition()
        newFoodGrid = successorGameState.getFood()
        maxDist = newFoodGrid.width + newFoodGrid.height

        # Ghost Score Calculation
        newGhostStates = successorGameState.getGhostStates()
        angryGhosts = filter(lambda ghost: ghost.scaredTimer is 0, newGhostStates)
        scaredGhosts = filter(lambda ghost: ghost.scaredTimer is not 0, newGhostStates)

        if len(angryGhosts) is 0:
            angryScore = 0
        else:
            minAngry = min([manhattanDistance(newPos, ghost.getPosition()) for ghost in angryGhosts])
            angryScore = maxDist / (minAngry + .01) ** 2

        if len(scaredGhosts) is 0:
            scaredScore = 0
        else:
            minScared = min([manhattanDistance(newPos, ghost.getPosition()) for ghost in scaredGhosts])
            scaredScore = maxDist / (minScared + .01) ** 2

        ghostScore = scaredScore - angryScore

        # Food Score Calculation
        newFood = newFoodGrid.asList()
        foodDists = [manhattanDistance(newPos, food) for food in newFood]
        minFood = .001 if len(foodDists) is 0 else min(foodDists)
        foodScore = maxDist / minFood**.1

        return successorGameState.getScore() + foodScore + ghostScore


def scoreEvaluationFunction(currentGameState):
    """
      This default evaluation function just returns the score of the state.
      The score is the same one displayed in the Pacman GUI.

      This evaluation function is meant for use with adversarial search agents
      (not reflex agents).
    """
    return currentGameState.getScore()

class MultiAgentSearchAgent(Agent):
    """
      This class provides some common elements to all of your
      multi-agent searchers.  Any methods defined here will be available
      to the MinimaxPacmanAgent, AlphaBetaPacmanAgent & ExpectimaxPacmanAgent.

      You *do not* need to make any changes here, but you can if you want to
      add functionality to all your adversarial search agents.  Please do not
      remove anything, however.

      Note: this is an abstract class: one that should not be instantiated.  It's
      only partially specified, and designed to be extended.  Agent (game.py)
      is another abstract class.
    """

    def __init__(self, evalFn = 'scoreEvaluationFunction', depth = '2'):
        self.index = 0 # Pacman is always agent index 0
        self.evaluationFunction = util.lookup(evalFn, globals())
        self.depth = int(depth)

class MinimaxAgent(MultiAgentSearchAgent):
    """
      Your minimax agent (question 2)
    """

    def _max_value(self, gameState, depth):
        if depth is 0 or gameState.isWin() or gameState.isLose():
            return self.evaluationFunction(gameState)
        else:
            best_score = float("-inf")
            for action in gameState.getLegalActions(0):
                score = self._min_value(gameState.generateSuccessor(0, action), depth)
                if score > best_score: best_score = score
            return best_score



    def _min_value(self, gameState, depth, agent=1):
        if gameState.isLose() or gameState.isWin():
            return self.evaluationFunction(gameState)
        elif (agent + 1) % gameState.getNumAgents() is 0:
            min_val = float("inf")
            for action in gameState.getLegalActions(agent):
                score = self._max_value(gameState.generateSuccessor(agent, action), depth - 1)
                if score < min_val: min_val = score
            return min_val
        else:
            min_val = float("inf")
            for action in gameState.getLegalActions(agent):
                score = self._min_value(gameState.generateSuccessor(agent, action), depth, agent + 1)
                if score < min_val: min_val = score
            return min_val

    def getAction(self, gameState):
        """
          Returns the minimax action from the current gameState using self.depth
          and self.evaluationFunction.

          Here are some method calls that might be useful when implementing minimax.

          gameState.getLegalActions(agentIndex):
            Returns a list of legal actions for an agent
            agentIndex=0 means Pacman, ghosts are >= 1

          gameState.generateSuccessor(agentIndex, action):
            Returns the successor game state after an agent takes an action

          gameState.getNumAgents():
            Returns the total number of agents in the game
        """
        best_action = None
        best_score = float("-inf")

        for action in gameState.getLegalActions(0):
            score = self._min_value(gameState.generateSuccessor(0, action), self.depth)
            if score > best_score:
                best_action = action
                best_score = score

        return best_action


class AlphaBetaAgent(MultiAgentSearchAgent):
    """
      Your minimax agent with alpha-beta pruning (question 3)
    """

    def _max_value(self, gameState, depth, alpha, beta):
        if depth is 0 or gameState.isWin() or gameState.isLose():
            return self.evaluationFunction(gameState)
        else:
            best_score = float("-inf")
            for action in gameState.getLegalActions(0):
                score = self._min_value(gameState.generateSuccessor(0, action), depth, alpha, beta)
                if score > best_score:
                    best_score = score
                if best_score > beta:
                    return best_score
                alpha = max(alpha, best_score)
            return best_score


    def _min_value(self, gameState, depth, alpha, beta, agent=1,):
        if gameState.isLose() or gameState.isWin():
            return self.evaluationFunction(gameState)
        elif (agent + 1) % gameState.getNumAgents() is 0:
            min_val = float("inf")
            for action in gameState.getLegalActions(agent):
                score = self._max_value(gameState.generateSuccessor(agent, action), depth - 1, alpha, beta)
                if score < min_val:
                    min_val = score
                if min_val < alpha:
                    return min_val
                beta = min(beta, min_val)
            return min_val
        else:
            min_val = float("inf")
            for action in gameState.getLegalActions(agent):
                score = self._min_value(gameState.generateSuccessor(agent, action), depth, alpha, beta, agent + 1)
                if score < min_val:
                    min_val = score
                if min_val < alpha:
                    return min_val
                beta = min(beta, min_val)
            return min_val

    def getAction(self, gameState):
        """
          Returns the alpha-beta action using self.depth and self.evaluationFunction
        """
        best_action = None
        best_score = float("-inf")
        alpha = float("-inf")
        beta = float("inf")

        for action in gameState.getLegalActions(0):
            score = self._min_value(gameState.generateSuccessor(0, action), self.depth, alpha, beta)
            if score > best_score:
                best_action = action
                best_score = score
            alpha = max(alpha, best_score)

        return best_action

class ExpectimaxAgent(MultiAgentSearchAgent):
    """
      Your expectimax agent (question 4)
    """

    def _max_value(self, gameState, depth):
        if depth is 0 or gameState.isWin() or gameState.isLose():
            return self.evaluationFunction(gameState)
        else:
            best_score = float("-inf")
            for action in gameState.getLegalActions(0):
                score = self._expected_value(gameState.generateSuccessor(0, action), depth)
                if score > best_score:
                    best_score = score
            return best_score

    def _expected_value(self, gameState, depth, agent=1):
        if gameState.isLose() or gameState.isWin():
            return self.evaluationFunction(gameState)
        elif (agent + 1) % gameState.getNumAgents() is 0:
            values = [self._max_value(gameState.generateSuccessor(agent, action), depth - 1) for action in
                      gameState.getLegalActions(agent)]
            return float(sum(values)) / len(values)
        else:
            values = [self._expected_value(gameState.generateSuccessor(agent, action), depth, agent + 1) for action in
                      gameState.getLegalActions(agent)]
            return float(sum(values)) / len(values)


    def getAction(self, gameState):
        """
          Returns the expectimax action using self.depth and self.evaluationFunction

          All ghosts should be modeled as choosing uniformly at random from their
          legal moves.
        """
        best_action = None
        best_score = float("-inf")

        for action in gameState.getLegalActions(0):
            score = self._expected_value(gameState.generateSuccessor(0, action), self.depth)
            if score > best_score:
                best_score = score
                best_action = action
        return best_action


def betterEvaluationFunction(currentGameState):
    """
      Your extreme ghost-hunting, pellet-nabbing, food-gobbling, unstoppable
      evaluation function (question 5).

      DESCRIPTION: I copied my evaluation function from problem 1, since in
        problem 1 the the first thing done was generating the successor state.
        Rather than doing it for the successor, I did it for the current.

        This evaluation consists of two parts (ghostScore and foodScore) which
        modify the gameScore.  The gameScore seemed a reasonable place to
        start, because it was provided and getting points is the goal off the
        game.  However, I also wanted to avoid ghosts that could kill pacman,
        target ghosts that are afraid, and move towards the nearest food ASAP.

        I also utilized inverse exponents to decrease the effect of far ghosts
        and increase the urgency of far food.

        Rather than try to scale the values of scared and attacking ghosts, I
        subtracted the angryScore as a penalty and added scaredScore as a reward.
        This is also true about foodScore.
    """
    newPos = currentGameState.getPacmanPosition()
    newFoodGrid = currentGameState.getFood()
    maxDist = newFoodGrid.width + newFoodGrid.height

    # Ghost Score Calculation
    newGhostStates = currentGameState.getGhostStates()
    angryGhosts = filter(lambda ghost: ghost.scaredTimer is 0, newGhostStates)
    scaredGhosts = filter(lambda ghost: ghost.scaredTimer is not 0, newGhostStates)

    if len(angryGhosts) is 0:
        angryScore = 0
    else:
        minAngry = min([manhattanDistance(newPos, ghost.getPosition()) for ghost in angryGhosts])
        angryScore = maxDist / (minAngry + .01) ** 2

    if len(scaredGhosts) is 0:
        scaredScore = 0
    else:
        minScared = min([manhattanDistance(newPos, ghost.getPosition()) for ghost in scaredGhosts])
        scaredScore = maxDist / (minScared + .01) ** 2

    ghostScore = scaredScore - angryScore

    # Food Score Calculation
    newFood = newFoodGrid.asList()
    foodDists = [manhattanDistance(newPos, food) for food in newFood]
    minFood = .001 if len(foodDists) is 0 else min(foodDists)
    foodScore = maxDist / minFood ** .1

    return currentGameState.getScore() + foodScore + ghostScore

# Abbreviation
better = betterEvaluationFunction

