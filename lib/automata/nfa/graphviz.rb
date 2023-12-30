class NFA
  module Graphviz
    def self.included(base)
      base.extend(ClassMethods)
      base.include(InstanceMethods)
    end

    module InstanceMethods
      def to_png(name)
        self.class.nfa_rules_to_image(self.rules, name)

        true
      end
    end

    module ClassMethods
      GRAPHVIZ_RULE = /^\s*([^\s]+)\s*->\s*([^\s]+)\s\[label = ["']([^"']+)["']\];\s*$/
      def graphviz_to_nfa_rules(graphviz_string)
        rules_acc = Hash.new do |h, k|
          h[k] = Hash.new do |h2, k2|
            h2[k2] = Set.new
          end
        end

        # too lazy to wrap these all up in a single accumulator:
        sigma_acc  = Set.new # set of all chars in the language (- epsilon)
        states_acc = Set.new # true set of all states

        nfa_rules =
          graphviz_string.scan(GRAPHVIZ_RULE).
            reduce(rules_acc) do |acc, (state, next_state, char)|
              acc[state][char] << next_state

              states_acc << next_state
              sigma_acc  << char

              acc
            end

        # delete epsilon
        sigma_acc.delete("ε")

        # if there is a missing state (not state w/ outbound transitions),
        # then this will init it
        states_acc.reduce(nfa_rules) do |nfa_rules, state|
          nfa_rules[state]

          nfa_rules
        end

        # graphviz doesn't list the chars for a state that aren't used
        # i.e when char for a state is the empty set. this is a quirk of
        # how nfa is implemented here, currently. adding them here:
        nfa_rules.each do |state, rules|
          unless rules.has_key?("ε")
            sigma_acc.each do |char|
              rules[char] ||= Set.new
            end
          end
        end

        nfa_rules
      end

      def nfa_rules_to_graphviz(rules)
        graphviz = <<~S.chomp
        digraph finite_state_machine {
          fontname="Helvetica,Arial,sans-serif"
          node [fontname="Helvetica,Arial,sans-serif"]
          edge [fontname="Helvetica,Arial,sans-serif"]
          rankdir=LR;
          node [shape = circle];
        S

        def graphviz.append(s); self << s; end

        rules.reduce(graphviz) do |graphviz, (state, rules)|
          state = state.object_id if !state.kind_of?(String)

          rules.each do |char, possible_states|
            possible_states.each do |possible_state|
              possible_state = possible_state.object_id if !possible_state.kind_of?(String)

              graphviz << "\n  #{state} -> #{possible_state} [label = \"#{char}\"];"
            end
          end

          graphviz
        end.append("\n}")
      end

      def nfa_rules_to_image(rules, name="nfa")
        graphviz = nfa_rules_to_graphviz(rules)

        # can i just pipe this through instead of saving first?
        File.open("tmp/#{name}.gv", "w+") { |f| f<< graphviz }

        %x{dot -Tpng -otmp/#{name}.png tmp/#{name}.gv}

        true
      end
    end
  end
end
