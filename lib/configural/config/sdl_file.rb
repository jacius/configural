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

  # Implementation of FileBase using SDL (Simple Declarative Language)
  # for serialization.
  # 
  # You must have the 'sdl4r' library installed to use this format.
  # See: <http://sdl4r.rubyforge.org/>
  # 
  class Config::SDLFile < Config::FileBase
    def self.format
      'sdl'
    end

    def self.extnames
      ['.sdl']
    end


    def initialize(*args)
      require 'sdl4r'
      super
    end


    def _load
      root = File.open(path, 'r'){ |f| SDL4R.read(f) }
      @data = tag_to_hash( root )
    rescue Errno::ENOENT
      @data = {}
    rescue SDL4R::SdlParseError, Errno::EACCESS => e
      warn( "WARNING: Could not load config file #{path.inspect}:\n" +
            e.inspect + "\nUsing empty dataset instead." )
      @data = {}
    end


    def _save
      require 'fileutils'
      FileUtils.mkdir_p( File.dirname(path) )
      File.open(path, 'w') { |f|
        hash_to_tag(@data).write(f)
      }
    rescue ArgumentError, Errno::EACCES => e
      warn( "WARNING: Could not save config file #{path.inspect}:\n" +
            e.inspect )
    end


    private


    # Recursively convert a SDL4R::Tag and its children into a Hash.
    def tag_to_hash( tag )
      hash = {}

      if tag.namespace.empty?
        hash['@name'] = tag.name
      else
        hash['@name'] = tag.namespace + ':' + tag.name
      end

      unless tag.attributes.empty?
        hash['@attributes'] = tag.attributes
      end

      unless tag.values.empty?
        hash['@values'] = tag.values
      end

      unless tag.child_count < 1
        tag.children do |child|
          child_name =
            if child.namespace.empty?
              child.name
            else
              child.namespace + ':' + child.name
            end
          hash[child_name] ||= []
          hash[child_name] << tag_to_hash(child)
        end
      end

      hash
    end


    # Recursively convert a Hash into a SDL4R::Tag with children.
    def hash_to_tag( hash )
      tag = SDL4R::Tag.new( *(hash['@name'].to_s.split(':')[0,2]) )

      if hash['@attributes']
        hash['@attributes'].each do |key, value|
          if key.index(':')
            namespace, name = key.split(':')[0,2]
            tag.set_attribute(namespace, name, value)
          else
            tag.set_attribute('', key, value)
          end
        end
      end

      tag.values = hash['@values'] if hash['@values']

      child_names = hash.keys.reject{ |key| key.index('@') }
      child_names.each do |name|
        hash[name].each{ |child|
          tag.add_child( hash_to_tag(child) )
        }
      end

      tag
    end

  end
end
