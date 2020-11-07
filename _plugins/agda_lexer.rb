Jekyll::Hooks.register :site, :pre_render do |site|
  require "rouge"

  # That'll do for the moment.
  class AGDALexer < Rouge::Lexers::Haskell
    title 'AGDA'
    aliases 'agda'
  end
end
