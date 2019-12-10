begin
  require_relative "../ffi-gosu/lib/gosu"
rescue LoadError
  require "gosu"
end

require "os"

require_relative "lib/window"
require_relative "lib/generator"
require_relative "lib/instrument"
require_relative "lib/driver"
require_relative "lib/instruments/saw"

Synthesizer::Window.new.show