# frozen_string_literal: true

require_relative "automata/version"

require_relative "automata/dfa/graphviz"
require_relative "automata/dfa"

require_relative "automata/nfa/epsilon_lookup"
require_relative "automata/nfa/graphviz"
require_relative "automata/nfa"

require_relative "automata/regex"
require_relative "automata/regex/parser"

module Automata
  class Error < StandardError; end
end
