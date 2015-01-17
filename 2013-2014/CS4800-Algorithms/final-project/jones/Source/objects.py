#!/usr/bin/python3

import sys
import time

__author__ = 'Nick'

ne_constraints = []
comps_seen = 0
DEBUG = False

def main():
    '''
    ENTRY POINT
    @return: void
    '''
    start = time.clock()
    get_inputs()
    log("READ INPUT")
    log("FINISHED MAKING COMPONENTS")
    output_result(not has_conflicts())
    log('\nRuntime: {:f}'.format(time.clock() - start))


def log(out):
    '''
    Makes it easy to control whether all my debug output is printed
    Set DEBUG as true for output or False for none.
    @param out: The String to print
    @return: void
    '''
    if DEBUG:
        print(out)


def get_inputs():
    '''
    Reads all the lines from stdin until EOF
    Generates and stores Var objects in hash table as they are seen
    Also generates components for each '==' seen
    stores '!=' relationships for later checking
    @return: void
    '''
    num_vars, num_constraints = (int(x) for x in sys.stdin.readline().split(' '))
    hash_table = VariableTable(num_vars)

    log("num vars: {:d}\nnum constraints: {:d}\n".format(num_vars, num_constraints))

    for x in range(num_constraints):
        line = sys.stdin.readline().rstrip()
        parse_line(hash_table, line)

    hash_table.print_table_health()


def make_component(var1, var2):
    '''
    Puts two vars into the same component
    @param var1: First Variable
    @param var2: Second Variable
    @return: void, but it sets the components of the vars accordingly
    '''
    if not var1.component is None and var2.component is None:
        var1.component.add(var2)
    elif var1.component is None and not var2.component is None:
        var2.component.add(var1)
    elif var1.component is None and var2.component is None:
        global comps_seen
        var1.component = Component(var1, comps_seen)
        var1.component.add(var2)
        comps_seen += 1
    elif var1.component.size > var2.component.size:
        var1.component.add(var2)
    else:
        var2.component.add(var1)


def output_result(satisfiable):
    '''
    prints 'SATISFIABLE' or 'NOT SATISFIABLE'
    @param satisfiable: Boolean (true if SATISFIABLE)
    @return: void
    '''
    if satisfiable:
        sys.stdout.write('SATISFIABLE')
    else:
        sys.stdout.write('NOT SATISFIABLE')


def has_conflicts():
    '''
    Checks that for all constraints in ne_constraints, the vars in a constraints are not
    in the same component
    @return: True if there is at least one != where the vars have the same component
    '''
    for constraint in ne_constraints:
        if constraint.var1.same_component(constraint.var2):
            log('CONFLICT: {:s}'.format(constraint))
            log('\tvar1 comp: {:s}'.format(constraint.var1.component))
            log('\tvar2 comp: {:s}'.format(constraint.var2.component))
            log('\tcomp size: {:d}'.format(constraint.var2.component.size))
            return True
    return False


def add_constraint(var1, comp, var2):
    '''
    Make a constraint
    @param var1: First Variable
    @param comp: '!=' or '=='
    @param var2: Second Variable
    @return: void
    '''
    if comp == '==':
        make_component(var1, var2)
    else:
        ne_constraints.append(NEConstraint(var1, var2))


def parse_line(hash_table, line):
    '''
    parse a line into a constraint
    @param hash_table: Hash table to get Variable objects from Strings
    @param line: line to parse
    @return: void
    '''
    var1, comp, var2 = line.split(' ')
    var1 = hash_table.add(var1)
    var2 = hash_table.add(var2)
    add_constraint(var1, comp, var2)


class Component(object):
    '''
    Component is a class that represents the relationship between nodes in a graph that
    can reach each other.
    '''
    __slots__ = ['nodes', 'size', 'id']

    def __init__(self, first_var, id):
        '''
        CONSTRUCTOR
        @param first_var: The first Variable in the component
        @param id: The unique component id (Number)
        @return: The Component
        '''
        self.nodes = [first_var]
        self.size = 1
        self.id = id

    def add(self, var):
        '''
        Add var and all Variables in its component to this component
        @param var: The variable to add
        @return: void, adds var and all Variables in its component to this component
        Also, points each of those vars to this.
        '''
        if var.component is None:
            self.nodes.append(var)
            self.size += 1
            var.component = self
        elif var.component.id != self.id:
            self.nodes.extend(var.component.nodes)
            self.size = len(self.nodes)
            for var_i in var.component.nodes:
                var_i.component = self

    def __str__(self):
        '''
        String representation
        @return: A String representing this object
        '''
        return '#{:d} : {:s}'.format(self.id, str(self.nodes))

    def __repr__(self):
        '''
        Same as _str__
        @return: A String
        '''
        return self.__str__()


class Variable(object):
    '''
    Variable represents a single variable as a Node in a graph
    '''
    __slots__ = ['component', 'name']

    def __init__(self, name):
        '''
        CONSTRUCTOR
        @param name: String containing the variable name eg. x231 or x54
        @return: A Variable Object
        '''
        self.component = None
        self.name = name

    def __str__(self):
        '''
        @return: String representation containing the name
        '''
        return self.name

    def __repr__(self):
        '''
        @return: See __str__
        '''
        return self.__str__()

    def same_component(self, other):
        '''
        Is this Variable in the same component as other?
        @param other: The other Variable
        @return: True if they are in the same Component
        '''
        return not self.component is None and not other.component is None and self.component.id == other.component.id


class NEConstraint(object):
    '''
    NEConstraint is a pair of Variables representing x != y
    '''
    __slots__ = ['var1', 'var2']

    def __init__(self, var1, var2):
        '''
        CONSTRUCTOR
        @param var1: The first variable
        @param var2: The second variable
        @return: An NEConstraint
        '''
        self.var1 = var1
        self.var2 = var2

    def __str__(self):
        '''
        @return: 'var1.name != var2.name'
        '''
        return '{:s} != {:s}'.format(str(self.var1), str(self.var2))

    def __repr__(self):
        '''
        @return: See __str__
        '''
        return self.__str__()


class VariableTable:
    '''
    VariableTable is a hash table for getting Variable objects in O(1) time using
    the String variable name
    '''
    size = 0
    array = None

    def __init__(self, size):
        '''
        CONSTRUCTOR
        @param size: The number of cells to allocate. (Must be one for each variable read)
        @return: A VariableTable object
        '''
        self.size = size
        self.array = [None for _ in range(size)]

    def __str__(self):
        '''
        @return: String of all Variables in table
        '''
        return str(self.array)

    def print_table_health(self):
        '''
        FOR DEBUGGING
        prints table health stats
        @return: void
        '''
        if DEBUG:
            lengths = [1 if not x is None else 0 for x in self.array]
            zeros = lengths.count(0)
            ones = lengths.count(1)
            collisions = len(self.array) - ones - zeros
            print("\nHASH TABLE\n-----------")
            print("size: {:d}/{:d}\nzeros: {:d}\nones: {:d}\ncollisions: {:d}\nmax: {:d}\n"
                  .format(len(self.array), self.size, zeros, ones, collisions, max(lengths)))

    def hash_variable(self, var):
        '''
        Convert a String xi to a unique number representing the index in the table where
        xi is stored
        @param var: name of variable xi
        @return: The value i from xi.  Therefore xi will hash the same as yi for any y
        '''
        return int(var[1:]) % self.size

    def add(self, var_name, var_hash=None):
        '''
        hash the Variable var_name and make a corresponding Variable object if not already in the
        table, else just return the Variable at the hash index.
        @param var_name: String containing variable name xi
        @param var_hash: hash of var_name, for reducing number of times hash computed.
        Recalculated if not provided.
        @return: The Variable object at var_hash, errors and exits if hash collision
        '''
        if var_hash is None:
            var_hash = self.hash_variable(var_name)
        if self.contains(var_name, var_hash):
            return self.get(var_name, var_hash)
        else:
            variable = Variable(var_name)
            if self.array[var_hash] is None:
                self.array[var_hash] = variable
            else:
                print("error: hash collision")
                exit()
            return variable

    def contains(self, var_name, var_hash=None):
        '''
        Does the table contain the var name at var_hash
        @param var_name: String of the Variable name to look for
        @param var_hash: hash of var_name computed using hash_variable. Used to reduce number
        of times the hash is computed. If not provided then it is rehashed.
        @return: True if the table contains a Variable at index var_hash else False
        '''
        if var_hash is None:
            var_hash = self.hash_variable(var_name)
        return not self.array[var_hash] is None

    def get(self, var, var_hash=None):
        '''
        Get the Variable at var_hash
        @param var: Variable name to look for
        @param var_hash: hash of var_name computed using hash_variable. Used to reduce number
        of times the hash is computed. If not provided then it is rehashed.
        @return: value found at arra[var_hash]. Variable or None
        '''
        if var_hash is None:
            var_hash = self.hash_variable(var)

        return self.array[var_hash]


if __name__ == "__main__":
    main()