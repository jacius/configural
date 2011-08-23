#--
#
# This file is one part of:
#
# Configural - Easy configuration file management
#
# Copyright (c) 2011  John Croisant
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
#++


module Configural

  class Data
    attr_accessor :app

    def initialize( app )
      @app = app
      @files = {}
    end

    def path
      @app.platform.data_path
    end

    def [](name)
      @files[name.to_s] ||= Data::DataFile.new(self, name.to_s)
    end
  end


  class Data::DataFile
    def initialize( data, name )
      @data = data
      @name = name
    end

    def open( mode="w+", &block )
      require 'fileutils'
      path = File.join( @data.path, @name )
      FileUtils.mkdir_p( File.dirname(path) )
      File.open(path, mode, &block)
    end

    def read
      open('r'){ |f| f.read }
    end

    def write( contents )
      open('w'){ |f| f.write(contents) }
    end
  end


  class Cache < Data
    def path
      @app.platform.cache_path
    end
  end

end
