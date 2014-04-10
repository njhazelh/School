#!/usr/bin/python3

import sys
import time

__author__ = 'Nick'

ne_constraints = []
vars_seen = 0
DEBUG = False

def main():
    start = time.clock()
    get_inputs()
    log("READ INPUT")
    log("FINISHED MAKING COMPONENTS")
    output_result(not has_conflicts())
    log('\nRuntime: {:f}'.format(time.clock() - start))


def log(out):
    if DEBUG:
        print(out)


def get_inputs():
    num_vars, num_constraints = (int(x) for x in sys.stdin.readline().split(' '))
    hash_table = VariableTable(num_vars)

    log("num vars: {:d}\nnum constraints: {:d}\n".format(num_vars, num_constraints))

    for x in range(num_constraints):
        line = sys.stdin.readline().rstrip()
        parse_line(hash_table, line)

    hash_table.print_table_health()


def make_component(var1, var2):
    if not var1.component is None and var2.component is None:
        var1.component.add(var2)
    elif var1.component is None and not var2.component is None:
        var2.component.add(var1)
    elif var1.component is None and var2.component is None:
        var1.component = Component(var1, vars_seen)
        var1.component.add(var2)
    elif var1.component.size > var2.component.size:
        var1.component.add(var2)
    else:
        var2.component.add(var1)


def output_result(satisfiable):
    if satisfiable:
        sys.stdout.write('SATISFIABLE')
    else:
        sys.stdout.write('NOT SATISFIABLE')


def has_conflicts():
    for constraint in ne_constraints:
        if constraint.var1.same_component(constraint.var2):
            log('CONFLICT: {:s}'.format(constraint))
            log('\tvar1 comp: {:s}'.format(constraint.var1.component))
            log('\tvar2 comp: {:s}'.format(constraint.var2.component))
            log('\tcomp size: {:d}'.format(constraint.var2.component.size))
            return True
    return False


def add_constraint(var1, comp, var2):
    if comp == '==':
        make_component(var1, var2)
    else:
        ne_constraints.append(NEConstraint(var1, var2))


def parse_line(hash_table, line):
    var1, comp, var2 = line.split(' ')
    var1 = hash_table.add(var1)
    var2 = hash_table.add(var2)
    add_constraint(var1, comp, var2)


class Component(object):
    __slots__ = ['nodes', 'size', 'id']

    def __init__(self, first_var, id):
        self.nodes = [first_var]
        self.size = 1
        self.id = id

    def add(self, var):
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
        return str(self.nodes)

    def __repr__(self):
        return self.__str__()


class Variable(object):
    __slots__ = ['component']

    def __init__(self):
        global vars_seen
        self.component = None
        vars_seen += 1

    def __str__(self):
        return "<var>"

    def __repr__(self):
        return self.__str__()

    def same_component(self, other):
        return not self.component is None and not self.component is None and self.component.id == other.component.id


class NEConstraint(object):
    __slots__ = ['var1', 'var2']

    def __init__(self, var1, var2):
        self.var1 = var1
        self.var2 = var2

    def __str__(self):
        return '{:s} != {:s}'.format(str(self.var1), str(self.var2))

    def __repr__(self):
        return self.__str__()


class VariableTable:
    size = 0
    array = None

    def __init__(self, size):
        self.size = size
        self.array = [None for _ in range(size)]

    def __str__(self):
        return str(self.array)

    def print_table_health(self):
        if DEBUG:
            lengths = [1 if not x is None else 0 for x in self.array]
            zeros = lengths.count(0)
            ones = lengths.count(1)
            collisions = len(self.array) - ones - zeros
            print("\nHASH TABLE\n-----------")
            print("size: {:d}/{:d}\nzeros: {:d}\nones: {:d}\ncollisions: {:d}\nmax: {:d}\n"
                  .format(len(self.array), self.size, zeros, ones, collisions, max(lengths)))

    def hash_variable(self, var):
        return int(var[1:]) % self.size

    def add(self, var_name, var_hash=None):
        if var_hash is None:
            var_hash = self.hash_variable(var_name)
        if self.contains(var_name, var_hash):
            return self.get(var_name, var_hash)
        else:
            variable = Variable()
            if self.array[var_hash] is None:
                self.array[var_hash] = variable
            else:
                print("error: hash collision")
                exit()
            return variable

    def contains(self, var_name, var_hash=None):
        if var_hash is None:
            var_hash = self.hash_variable(var_name)
        return not self.array[var_hash] is None

    def get(self, var, var_hash=None):
        if var_hash is None:
            var_hash = self.hash_variable(var)

        return self.array[var_hash]


if __name__ == "__main__":
    main()