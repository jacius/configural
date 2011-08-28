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

  # Base class for abstracting configuration file access. You
  # shouldn't use this class directly. Use one of the subclasses (e.g.
  # YAMLFile) instead.
  # 
  class Config::FileBase

    def self.inherited(subclass)
      @subclasses ||= []
      @subclasses << subclass
    end


    def self.get_format_by_name( format )
      @subclasses.reverse.find { |subclass|
        subclass.format == format
      } or raise "Unrecognized file format: #{format}"
    end

    def self.get_format_by_extname( extname )
      @subclasses.reverse.find { |subclass|
        subclass.extnames.include?(extname)
      } or raise "Unrecognized file extension: #{extname}"
    end


    def self.format
      raise 'Method not implemented for base class.'
    end

    def self.extnames
      raise 'Method not implemented for base class.'
    end


    require 'enumerator'
    include Enumerable

    attr_accessor :name

    def initialize( config, name )
      @config = config
      @name = name
      @data = {}
      @loaded = false
      load unless @config.options[:lazy_loading]
    end

    def path
      pps = possible_paths
      pps.find{ |p| File.exists?(p) } || pps.first
    end

    def possible_paths
      if File.extname(@name).empty?
        # Name has no extension, try appending each extension.
        self.class.extnames.collect{ |extname|
          File.join( @config.path, @name ) + extname
        }
      else
        # Name has an extension, so don't append anything.
        [File.join( @config.path, @name )]
      end
    end

    def clear
      @data = {}
      @loaded = true
      self
    end

    def close
      @data = {}
      @loaded = false
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
      load unless @loaded
      @data.each(&block)
    end

    def keys
      load unless @loaded
      @data.keys
    end

    def [](key)
      load unless @loaded
      @data[key.to_s]
    end

    def []=(key, value)
      load unless @loaded
      @data[key.to_s] = value
    end

    def to_hash
      load unless @loaded
      @data.dup
    end

    def load
      load! unless @loaded
      self
    end

    def load!
      _load
      @loaded = true
      self
    end

    def save
      _save unless not @loaded
      self
    end

    def save!
      _save
      self
    end

    private

    def _load
      raise 'Method not implemented for base class.'
    end

    def _save
      raise 'Method not implemented for base class.'
    end

  end

end
