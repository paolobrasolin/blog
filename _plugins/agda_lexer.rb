# USEFUL REFERENCES
# * https://github.com/rouge-ruby/rouge/blob/60e4f8f39529a9298789f0fea2d3cfcd2f6eaa20/lib/rouge/lexers/haskell.rb
# * https://github.com/agda/agda/blob/master/src/full/Agda/Syntax/Parser/Lexer.x
# * https://www.rubydoc.info/gems/rouge/3.23.0/Rouge/RegexLexer
# * https://ruby-doc.org/core-2.7.2/Regexp.html
# * https://rouge-ruby.github.io/docs/file.LexerDevelopment.html
# * https://agda.readthedocs.io/en/v2.6.0.1/language/lexical-structure.html
# * https://github.com/rouge-ruby/rouge/wiki/List-of-tokens
# * https://pygments.org/docs/tokens/

require "rouge"

module Rouge
  module Lexers
    class Agda < RegexLexer
      title "AGDA"
      desc "The Agda programming language (github.com/agda/agda)"
      tag 'agda'
      aliases 'agda'
      filenames '*.agda'
      mimetypes 'text/x-agda'

      # IDENTIFIER = %r/
      #   ( (?!['\\_])          [ A-Za-z 0-9 \-!#$%&*+\/<=>^|~?`\[\],: '\\_ ]+
      #   | \\ (?![A-Za-z'\\_]) [ A-Za-z 0-9 \-!#$%&*+\/<=>^|~?`\[\],: '\\_ ]*
      #   | _                   [ A-Za-z 0-9 \-!#$%&*+\/<=>^|~?`\[\],: '\\_ ]+
      #   )
      # /x

      def self.keywords
        # = | -> → : ? \ λ ∀ .. ...
        @keywords ||= Set.new %w(
          abstract codata coinductive constructor data do eta-equality field forall hiding import in inductive infix infixl infixr instance let macro module mutual no-eta-equality open overlap pattern postulate primitive private public quote quoteContext quoteGoal quoteTerm record renaming rewrite syntax tactic unquote unquoteDecl unquoteDef using variable where with interleaved
        )
      end

      #=[ Whitespace ]================================================================

      state :whitespace do
        rule %r/\p{Space}+/, Text::Whitespace
      end

      #=[ Literals ]==================================================================

      state :float do
        rule %r/ -? [0-9]+ \. [0-9]+ ([eE] [+\-]? [0-9]+)? /x, Literal::Number::Float
        rule %r/ -? [0-9]+            [eE] [+\-]? [0-9]+   /x, Literal::Number::Float
      end

      state :integer do
        rule %r/ -? 0x [0-9a-fA-F]+ (_? [0-9a-fA-F]+)* /x, Literal::Number::Hex
        rule %r/ -? 0b [0-1]+       (_? [0-1]+      )* /x, Literal::Number::Bin
        rule %r/ -?    [0-9]+       (_? [0-9]+      )* /x, Literal::Number::Integer
      end

      ESCAPE_CODES = %w{
        \\d+
        0x[0-9A-Fa-f]+
        a b t n v f \\ ' "
        NUL SOH [SE]TX EOT ENQ ACK BEL BS HT LF VT FF CR S[OI] DLE
        DC[1-4] NAK SYN ETB CAN EM SUB ESC [FGRU]S SP DEL
      }

      state :character do
        rule /\\(#{ESCAPE_CODES.join('|')})/, Literal::String::Escape
        rule /(?!['])\p{Graph}/, Literal::String::Char
        rule /'/, Literal::String::Char, :pop!
      end

      state :string do
        rule /[^\\"]+/, Literal::String::Double 
        rule /\\./, Literal::String::Escape 
        rule /"/, Literal::String::Double, :pop!
      end

      state :literal do
        # NOTE: integer must be after float
        mixin :float
        mixin :integer
        rule %r/'/, Literal::String::Char, :character
        rule %r/"/, Literal::String::Double, :string
      end

      #=[ Holes ]=====================================================================

      state :hole do
        rule %r/ \? /x, Generic::Prompt
        rule %r/ ( \{! ((?!\{!).)* \g<1>* ((?!!\}).)* !\} ) /x, Generic::Prompt
      end

      #=[ Comments ]==================================================================

      state :comment do
        rule %r/ --.*$ /x, Comment::Single
        rule %r/ {- /x, Comment::Multiline, :nestable_multiline_comment
      end

      state :nestable_multiline_comment do
        rule %r/ -} /x, Comment::Multiline, :pop!
        rule %r/ {- /x, Comment::Multiline, :nestable_multiline_comment
        rule %r/ .  /xm, Comment::Multiline
      end

      #=[ Pragmas ]===================================================================

      # def self.pragmas
      #   @pragmas ||= Set.new %w(
      #     BUILTIN CATCHALL COMPILE FOREIGN DISPLAY ETA IMPOSSIBLE INJECTIVE
      #     INLINE NOINLINE LINE MEASURE NO_POSITIVITY_CHECK NO_TERMINATION_CHECK
      #     NO_UNIVERSE_CHECK NON_COVERING NON_TERMINATING OPTIONS POLARITY
      #     REWRITE STATIC TERMINATING WARNING_ON_USAGE WARNING_ON_IMPORT
      #   )
      # end

      state :pragma do
        rule %r/ {-\# /x, Comment::Preproc, :multiline_pragma
      end

      state :multiline_pragma do
        rule %r/ \#-} /x, Comment::Preproc, :pop!
        rule %r/ .  /xm, Comment::Preproc
      end

      #=[ Pragmas ]===================================================================

      state :root do
        mixin :whitespace
        mixin :pragma
        mixin :comment
        mixin :literal

        rule %r/open/, Keyword::Namespace, :open
        mixin :import

        rule %r/(=|:)/, Keyword::Declaration
        rule %r/(\\|->|→|λ|\\)/, Keyword::Pseudo
        rule %r/(\||\.\.|\.\.\.)/, Keyword::Pseudo
        rule %r/(∀|forall)/, Keyword::Pseudo

        mixin :hole

        rule %r/Set([0-9]+|[₀-₉]+)?/x, Keyword::Type

        rule /\p{Graph}+/ do |m|
          if self.class.keywords.include?(m[0])
            token Keyword
          elsif m[0] =~ /^\p{S}+$/
            token Operator
          elsif
            token Name
          end
        end
      end

      state :import do
        rule %r/ (import) (\p{Space}+) (\p{Graph}+) (\p{Space}+) (as) (\p{Space}+) (\p{Graph}+) /x do
          groups(Keyword::Namespace, Text::Whitespace, Name::Namespace, Text::Whitespace, Keyword::Pseudo, Text::Whitespace, Name::Namespace)
        end
        rule %r/ (import) (\p{Space}+) (\p{Graph}+) /x do
          groups(Keyword::Namespace, Text::Whitespace, Name::Namespace)
        end
      end

      state :open do
        mixin :whitespace
        mixin :import
        rule %r/ (using|hiding) (\p{Space}+) (\()/x do
          groups(
            Keyword::Namespace,
            Text::Whitespace, Punctuation
          )
          goto :open_list
        end
        rule %r/\p{Graph}+/, Name::Namespace, :pop!
      end

      state :open_list do
        mixin :whitespace
        rule %r/\p{Graph}+(?<![;\)])/x, Name
        rule %r/;/x, Punctuation
        rule %r/\)/x, Punctuation, :pop!
      end
    end
  end
end

Jekyll::Hooks.register :site, :pre_render do |site|
  class AGDALexer < Rouge::Lexers::Agda; end
end
