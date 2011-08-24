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

    def initialize( app )
      @app = app
      @files = {}
      self.format = 'yaml'
    end

    def format
      @format.format
    end

    def format=( fmt )
      @format = FileBase.get_format(fmt)
    end

    def path
      @app.platform.config_path
    end

    def [](name)
      @files[name.to_s] ||= @format.new(self, name.to_s)
    end

    def save_all
      @files.each_value{ |file| file.save }
      self
    end

  end


  # Base class for abstracting configuration file access. You
  # shouldn't use this class directly. Use one of the subclasses (e.g.
  # YAMLFile) instead.
  # 
  class Config::FileBase

    def self.inherited(subclass)
      @subclasses ||= []
      @subclasses << subclass
    end

    def self.get_format( fmt )
      format = @subclasses.reverse.find { |subclass|
        (subclass.format == fmt.to_s or
         subclass == fmt)
      }
      unless format
        raise "No class available for format: #{fmt.to_s}"
      end
      format
    end

    require 'enumerator'
    include Enumerable

    attr_accessor :name

    def initialize( config, name )
      @config = config
      @name = name
      @data = {}
    end

    def path
      pps = possible_paths
      pps.find{ |p| File.exists?(p) } || pps.first
    end

    def possible_paths
      self.class.extnames.collect{ |extname|
        File.join( @config.path, @name ) + extname
      }
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
    alias :exist? :exists?

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

    def extnames
      ['']
    end

    def load_if_uninitialized
      load unless @data
    end

  end


  # Implementation of FileBase using YAML for serialization.
  # 
  class Config::YAMLFile < Config::FileBase
    def self.format
      'yaml'
    end

    def self.extnames
      ['.yml', '.yaml']
    end


    def initialize(*args)
      require 'yaml'
      super
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


  # Implementation of FileBase using XML PList (Property List) for
  # serialization. This format is most commonly used on Mac OS.
  # 
  # You must have the 'plist' library installed to use this format.
  # See: <http://plist.rubyforge.org/>
  # 
  class Config::PlistFile < Config::FileBase
    def self.format
      'plist'
    end

    def self.extnames
      ['.plist']
    end


    def initialize(*args)
      require 'plist'
      super
    end

    def load
      @data = Plist.parse_xml(path) || {}
      self
    rescue Errno::ENOENT
      @data = {}
      self
    end

    def save
      require 'fileutils'
      FileUtils.mkdir_p( File.dirname(path) )
      File.open(path, 'w') { |f| f.write( @data.to_plist ) }
      self
    end
  end

end
