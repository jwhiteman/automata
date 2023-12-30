Open this in a split buffer next to NFA.rb

Like DFA: we've got a hash with states as keys. The values are the rules
(themselves hashes) with a key for each legal char. But..the NFA values for
each char are Sets. And in some cases have special "epsilon" rules.

There are 5 reductions & 1 recursive function that go into this. A little
more complex than DFA, for sure. Let's break each one down.

1. Don't be fooled - the 1st reduce is to turn input chars into the ending state.
2. At each turn we have:
- a new input char
- a set of states we could be in

The 2nd reduction is, then: turn the old states into new states, given the new char
and the rules. Yes, we're doing "acc | ...", but that acc doesn't represent the
old states: The acc is Set.new; at each iteration through the old states,
we use the char with the rules to lookup the new states. Imagine you have
current possible states of {A, B, C}.

```
acc  = Set.new
char = 'x'
possible_states.each do |state|
  acc = acc + lookup_next(state, char)
end
```

If this isn't intuitive: {A, B, C} - we could be in any of these states.
With 'x', A -> {D, E}, B -> {F, G}, C -> {H, I}. So our possible states *now*
would be {D, E, F, G, H, I}. Again, not a lot of intersecting called for,
until the end - when we want to see if there is any overlap between the
target states and our possible-ending-states.

As a wrinkle: we iterate over the input chars, with the starting states initialized.
For each loop we turn the previous states into the current states. However,
Before we can lookup the "current states" (given the new char) we need to
deal with any epsilon rules: if a state has epsilon transitions, we've got
to chase down where they end so that we can add those states.

This process is nearly identical to the previous: we've got our states,
but we need to iterate over each one and do a lookup (this time against
the epsilon lookup). Another Set.new acc - this is easy. No intersections:
we start with a set of possible states, and we end up with another
set of possible states (albeit broader).

The conditional in `_ff_epsilon_transitions` says: if there are epsilon states
for this state, use those instead; otherwise just use the state as it is.
