class DFA
  module Graphviz
    def self.included(base)
      base.extend(ClassMethods)
      base.include(InstanceMethods)
    end

    module InstanceMethods
      def to_png(name)
        self.class.dfa_rules_to_image(self.rules, name)

        true
      end
    end

    module ClassMethods
      GRAPHVIZ_RULE = /^\s*([^\s]+)\s*->\s*([^\s]+)\s\[label = ["']([^"']+)["']\];\s*$/
      def graphviz_to_dfa_rules(graphviz_string)
        rules_acc = Hash.new do |h, k|
          h[k] = {}
        end

        graphviz_string.scan(GRAPHVIZ_RULE).
          reduce(rules_acc) do |acc, (state, next_state, char)|
            acc[state][char] = next_state

            acc
          end
      end

      def dfa_rules_to_graphviz(rules)
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
          rules.each do |char, to|
            graphviz << "\n  #{state} -> #{to} [label = \"#{char}\"];"
          end

          graphviz
        end.append("\n}")
      end

      def dfa_rules_to_image(rules, name="dfa")
        graphviz = dfa_rules_to_graphviz(rules)

        # can i just pipe this through instead of saving first?
        File.open("tmp/#{name}.gv", "w+") { |f| f<< graphviz }

        %x{dot -Tpng -otmp/#{name}.png tmp/#{name}.gv}

        true
      end
    end
  end
end
