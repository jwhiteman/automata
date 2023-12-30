# A DFA is just a wrapper around a states/transition maps:
#
# rules = {
#   a: { "0" => :b, "1" => :c },
#   b: { "0" => :c, "1" => :a }
# }
#
# The wrapper (i.e this DFA class) does 2 things:
# 1. Reads an input, char-by-char, and keeps track of the changing state
# 2. Let's you know if you're in an accept state at the end.
class DFA
  include Graphviz

  attr_reader :start_state
  attr_reader :accept_states
  attr_reader :rules

  def initialize(start_state:, accept_states:, rules:)
    @start_state   = start_state
    @accept_states = accept_states
    @rules         = rules
  end

  def accepting?(input)
    ending_state =
      input.
        split(//).
        reduce(start_state) do |current_state, char|
          rules.dig(current_state, char)
        end

    accept_states.include?(ending_state)
  end
end
