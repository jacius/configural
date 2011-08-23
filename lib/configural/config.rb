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

  class Config
    attr_accessor :app
    attr_accessor :fileclass

    def initialize( app )
      @app = app
      @files = {}
      @fileclass = Config::YAMLFile
    end

    def path
      @app.platform.config_path
    end

    def [](name)
      @files[name.to_s] ||= @fileclass.new(self, name.to_s)
    end

    def save_all
      @files.each_value{ |file| file.save }
      self
    end

  end


  # Base class for abstracting configuration file access. You
  # shouldn't use this class directly. Use YAMLFile instead.
  # 
  class Config::FileBase
    require 'enumerator'
    include Enumerable

    attr_accessor :name

    def initialize( config, name )
      @config = config
      @name = name
      @data = {}
    end

    def path
      File.join( @config.path, @name ) + extname
    end

    def clear
      @data.clear
      self
    end

    def delete
      File.rm(path, :force => true)
      self
    end

    def exists?
      File.exists?(path)
    end
    alias :exist?, :exists?

    def each(&block)
      load_if_uninitialized
      @data.each(&block)
    end

    def keys
      load_if_uninitialized
      @data.keys
    end

    def [](key)
      load_if_uninitialized
      @data[key.to_s]
    end

    def []=(key, value)
      load_if_uninitialized
      @data[key.to_s] = value
    end

    def load
      raise 'Method not implemented for base class.'
    end

    def save
      raise 'Method not implemented for base class.'
    end

    private

    def extname
      ''
    end

    def load_if_uninitialized
      load unless @data
    end

  end


  # Implementation of FileBase using YAML for serialization.
  # 
  class Config::YAMLFile < Config::FileBase
    def initialize(*args)
      require 'yaml'
      super
    end

    def extname
      '.yml'
    end

    def load
      @data = YAML.load_file(path) || {}
      self
    rescue Errno::ENOENT
      @data = {}
      self
    end

    def save
      require 'fileutils'
      FileUtils.mkdir_p( File.dirname(path) )
      File.open(path, 'w') { |f|
        YAML.dump(@data, f)
      }
      self
    end
  end

end
