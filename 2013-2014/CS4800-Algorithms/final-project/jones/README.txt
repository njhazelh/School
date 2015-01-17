Nicholas Jones
njhazelh@zimbra.ccs.neu.edu

1.) What language did you implement this in?

Python


2.) Does your code require building before it can be executed?

No


3) Describe in one paragraph or less the algorithm you implemented.

Read the first line and parse number of vars and number of constraints
Read each line that follows
    Collect parts
    Get Variable objects using hash table which also creates object if not existing
    if constraint is '==' merge components of the two vars
    else if constraint is '!=' store the two vars in NEConstraint object in ne_constraints
Check that for each NEConstraint in ne_constraints the vars are not in the same component


4) Does your implementation pass all of the given test cases? If not, specify which ones it fails on. This also includes failure to terminate within an appropriate amount of time.

Yes


5) Approximately how long does your solution take on very large inputs? (2.5 million variables, 2.5 million constraints).

15 seconds on aztarac.ccs.neu.edu


6) What is the worst case order notation run time of your implementation? Depending on what sort of data structure you implemented, it may be appropriate to do some amortized analysis here.

n vars, m constraints

For Each of m lines:
    Getting Vars from hash table: O(1)
    Merging components: O(n) over all iterations
        merging requires adding all the items in the smaller component to the larger one and pointing each addition to its new component.

checking that components for vars in '!=' are not equal: O(m)

Overall: O(n + m)