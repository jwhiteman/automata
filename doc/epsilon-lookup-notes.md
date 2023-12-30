a lot of the same pattern.

5 reductions total:
3x: states.reduce(Set.new)
1x: chars.reduce(starting-states)
1x: rules.reduce({})

3x: states.reduce(Set.new):
why: we want to turn a set of states into a new set of states. either by:
1. using the rules to look them up (w/ the new char)
2. using the epsilon-lookup to lookup the epsilon transitions (to ff the free moves)
3. using the rules to figure out what the ff-epsilon states are for the given states

1x: chars.reduce(starting-states)
why: to transform the char input into ending sttes

1x: rules.reduce({})
why: to turn the rules into the epsilon lookup hash
