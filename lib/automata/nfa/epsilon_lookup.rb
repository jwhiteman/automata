class NFA
  module EpsilonLookup
    def build_epsilon_lookup(rules)
      rules.reduce({}) do |epsilon_lookup, (state, rule)|
        if rule[EPSILON]
          epsilon_lookup[state] =
            _build_epsilon_lookup(rule[EPSILON], rules, { state => true }) + Set[state]
        end

        epsilon_lookup
      end
    end

    def _build_epsilon_lookup(set_of_states, rules, seen)
      set_of_states.reduce(Set.new) do |acc, state|
        acc + if seen[state]
                Set[]
               elsif rules.dig(state, EPSILON)
                seen[state] = true

                epsilon_states = rules[state][EPSILON]

                epsilon_states +
                  _build_epsilon_lookup(epsilon_states, rules, seen)
              else
                Set[state]
              end
      end
    end
  end
end
