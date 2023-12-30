class NFA
  extend EpsilonLookup
  include Graphviz

  EPSILON = "ε".freeze

  attr_reader :start_states
  attr_reader :accept_states
  attr_reader :rules

  attr_reader :epsilon_lookup

  def initialize(start_states, accept_states, rules)
    @start_states   = start_states
    @accept_states  = accept_states
    @rules          = rules

    @epsilon_lookup = self.class.build_epsilon_lookup(rules)
  end

  def accepting?(input)
    chars = _input_to_chars(input)

    ending_states =
      chars.
      reduce(start_states) do |states, char|
        states = _ff_epsilon_transitions(states)

        states.reduce(Set.new) do |acc, state|
          acc + (rules.dig(state, char) || Set.new)
        end
      end

    ending_states = _ff_epsilon_transitions(ending_states)

    (ending_states & accept_states).any?
  end
  alias_method :accepts?, :accepting?
  alias_method :matches?, :accepting?

  def _ff_epsilon_transitions(states)
    states.reduce(Set.new) do |with_epsilon_transitions, state|
      with_epsilon_transitions + if epsilon_lookup[state]
                                   epsilon_lookup[state]
                                 else
                                   Set[state]
                                 end
    end
  end

  def _input_to_chars(input)
    input.split(//)
  end
end
