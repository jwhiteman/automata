# McNaughton-Yamada-Thompson to convert regex to NFA
module Regex
  def self.build(regex_string)
    ast = Parser.new(regex_string).parse

    ast.to_nfa
  end

  module Helpers
    NEW_STATE_ID =
      Enumerator.new do |y|
        (1..1/0.0).each { |n| y << n }
      end

    def new_state
      NEW_STATE_ID.next
    end
  end

  class Epsilon
    include Helpers

    def to_nfa
      start_state, end_state = new_state, new_state

      rules = {
        start_state => { NFA::EPSILON => Set[end_state] }
      }

      NFA.new(Set[start_state], Set[end_state], rules)
    end
  end

  class Symbol < Struct.new(:char)
    include Helpers

    def inspect
      "Symbol(#{char})"
    end

    def to_nfa
      start_state, end_state = new_state, new_state

      rules = {
        start_state => { char => Set[end_state] }
      }

      NFA.new(Set[start_state], Set[end_state], rules)
    end
  end

  class Concatenate < Struct.new(:left, :right)
    def inspect
      "Concat(#{left.inspect}, #{right.inspect})"
    end

    def to_nfa
      left_nfa  = left.to_nfa
      right_nfa = right.to_nfa

      left_accept_states = left_nfa.accept_states
      right_start_states = right_nfa.start_states

      rules =
        left_accept_states.reduce({}) do |rules, left_accept_state|
          rules[left_accept_state] = { NFA::EPSILON => Set[*right_start_states] }

          rules
        end

      rules.merge!(left_nfa.rules)
      rules.merge!(right_nfa.rules)

      NFA.new(Set[*left_nfa.start_states], Set[*right_nfa.accept_states], rules)
    end
  end

  class Closure < Struct.new(:inner)
    include Helpers

    def inspect
      "Closure(#{inner.inspect})"
    end

    def to_nfa
      outer_start, outer_accept = new_state, new_state

      inner_nfa = inner.to_nfa

      # 1. ε outer-start to inner-start
      # 2. ε outer-start to outer-accept
      rules = {
        outer_start => { NFA::EPSILON => Set[*inner_nfa.start_states, outer_accept] }
      }

      # 3. ε inner-accept (multi) to inner-start
      # 4. ε inner-accept (multi) to outer-accept
      inner_nfa.accept_states.each do |inner_accept_state|
        rules[inner_accept_state] = { NFA::EPSILON => Set[*inner_nfa.start_states, outer_accept] }
      end

      rules.merge!(inner_nfa.rules)

      NFA.new(Set[outer_start], Set[outer_accept], rules)
    end
  end

  class Union < Struct.new(:left, :right)
    include Helpers

    def inspect
      "Union(#{left.inspect}, #{right.inspect})"
    end

    def to_nfa
      outer_start_state, outer_accept_state = new_state, new_state

      left_nfa  = left.to_nfa
      right_nfa = right.to_nfa

      inner_starting_states = left_nfa.start_states + right_nfa.start_states
      inner_accept_states   = left_nfa.accept_states + right_nfa.accept_states

      rules = {
        outer_start_state => { NFA::EPSILON => Set[*inner_starting_states] }
      }

      inner_accept_states.each do |inner_accept_state|
        rules[inner_accept_state] = { NFA::EPSILON => Set[outer_accept_state] }
      end

      [left_nfa.rules, right_nfa.rules].each do |inner_rules|
        rules.merge!(inner_rules) do |_key, v1, v2|
          v1.merge(v2) do |_key, iv1, iv2|
            iv1 + iv2
          end
        end
      end

      NFA.new(Set[outer_start_state], Set[outer_accept_state], rules)
    end
  end

  class Maybe < Struct.new(:regex)
    def inspect
      "Maybe(#{regex.inspect})"
    end

    def to_nfa
      Union.new(regex, Epsilon.new).to_nfa
    end
  end

  class OneOrMore < Struct.new(:regex)
    def inspect
      "OneOrMore(#{regex.inspect})"
    end

    def to_nfa
      Concatenate.new(regex, Closure.new(regex)).to_nfa
    end
  end
end
