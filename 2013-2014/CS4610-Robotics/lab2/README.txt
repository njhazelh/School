Group ***********************
Zach Ferland - ferland
Nick Jones - njhazelh
Qimeng Song - qimeng
*****************************

TO RUN GLOBAL NAV ***********
./run-class GlobalNav

TO RUN LOCAL NAV ************
./run-class LocalNav GoalX GoalY  # GoalX and GoalY are both Numbers given in mm.

BUGS OR INCOMPLETENESS ******

During our demo we didn't have the image server properly running  with global nav, 
but with the time betwen demo and submission we were able to implement the image 
server for global nav.

Note - the global nav currently doesn not take the boundary rectangle into consideration
when determining a path.

The local nav has a couple of bugs.  First, due to the wrapping of theta,
certain rotations will cause the robot to stall, since it never enters
the numeric range it looks for despite traveling through it physically.
Additionally, the robot will sometimes miss the goal theshold and continue 
indefinitely.  This can be avoided by increasing GOAL_THESHOLD size, but 
doing so also causes error.


CONTRIBUTION ***************

We spent a lot time working together on various parts. But Zach mainly focused 
on the implementing the Global Nav, Nick on the Local Nav, and Qimeng on the 
Image Server.
