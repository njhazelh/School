import sys

__author__ = 'Nick'

eq_constraints = []
ne_constraints = []
num_vars = 0
num_constraints = 0
vars_seen = 0
hash_table = None
variables = []


def main():
    get_inputs()
    #print(hash_table)
    make_components()
    print("\n\n\n\n\n\nFINISHED MAKING COMPONENTS\n\n\n\n\n")
    output_result(not has_conflicts())


def get_inputs():
    lines = sys.stdin.readlines()
    global num_vars
    global num_constraints
    global hash_table
    num_vars, num_constraints = [int(x) for x in lines[0].split(' ')]
    hash_table = VariableTable(num_vars)

    for line in lines[1:]:
        line = line.rstrip()
        #print(line)
        parse_line(line)


def make_components():
    for constraint in eq_constraints:
        #print('Making: {:s}'.format(str(constraint)))
        if constraint.var1.component.size > constraint.var2.component.size:
            constraint.var1.component.add(constraint.var2)
        else:
            constraint.var2.component.add(constraint.var1)


def output_result(satisfiable):
    if satisfiable:
        print('SATISFIABLE')
    else:
        print('NOT SATISFIABLE')


def has_conflicts():
    for constraint in ne_constraints:
        if constraint.var1.same_component(constraint.var2):
            print('CONFLICT: {:s}'.format(constraint))
            print('\tvar1 comp: {:s}'.format(constraint.var1.component))
            print('\tvar2 comp: {:s}'.format(constraint.var2.component))
            print('\tcomp size: {:d}'.format(constraint.var2.component.size))
            return True
    return False


def add_constraint_var(var1, comp, var2):
    add_constraint(Constraint(var1, comp, var2))


def add_constraint(constraint):
    if constraint.comp == '==':
        eq_constraints.append(constraint)
    else:
        ne_constraints.append(constraint)


def parse_line(line):
    var1, comp, var2 = line.split(' ')
    var1 = hash_table.add(var1)
    var2 = hash_table.add(var2)
    add_constraint_var(var1, comp, var2)


class Component:
    nodes = None
    size = 0
    id = 0

    def __init__(self, first_var, id):
        self.nodes = [first_var]
        self.size = 1
        self.id = id

    def add(self, var):
        if var.component.id != self.id:
            self.nodes.extend(var.component.nodes)
            self.size = len(self.nodes)
            for var_i in var.component.nodes:
                var_i.component = self
        else:
            print('{:d} == {:d}'.format(self.id, var.component.id))

    def __str__(self):
        return str(self.nodes)

    def __repr__(self):
        return self.__str__()

class Variable:
    name = None
    component = None

    def __init__(self, name):
        global vars_seen
        self.name = name
        self.component = Component(self, vars_seen)
        vars_seen += 1

    def __str__(self):
        return self.name

    def __repr__(self):
        return self.__str__()

    def same_component(self, other):
        return self.component.id == other.component.id


class Constraint:
    var1 = None
    comp = None
    var2 = None

    def __init__(self, var1, comp, var2):
        self.var1 = var1
        self.comp = comp
        self.var2 = var2

    def __str__(self):
        return '{:s} {:s} {:s}'.format(str(self.var1), self.comp, str(self.var2))

    def __repr__(self):
        return self.__str__()


class VariableTable:
    size = 0
    array = None

    def __init__(self, size):
        self.size = size
        self.array = [[] for _ in range(size)]

    def __str__(self):
        return str(self.array)

    def hash_variable(self, var):
        var_hash = 0
        for c in var:
            var_hash = (var_hash * 16777619) ^ ord(c) # FNV hash
        #print('hashed {:s} as {:d}'.format(var, var_hash))
        return var_hash % self.size

    def add(self, var_name, var_hash=None):

        if var_hash is None:
            var_hash = self.hash_variable(var_name)

        if self.contains(var_name, var_hash):
            return self.get(var_name, var_hash)
        else:
            variable = Variable(var_name)
            self.array[var_hash].append(variable)
            variables.append(variable)
            return variable

    def contains(self, var_name, var_hash=None):
        if var_hash is None:
            var_hash = self.hash_variable(var_name)
        return len([x for x in self.array[var_hash] if x.name == var_name]) > 0

    def get(self, var, var_hash =  None):
        if var_hash is None:
            var_hash = self.hash_variable(var)
        result = [x for x in self.array[var_hash] if x.name == var]

        if len(result) == 0:
            return None
        else:
            return result[0]


if __name__ == "__main__":
    main()