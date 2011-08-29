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

    attr_accessor :app, :options

    def initialize( app )
      @app = app
      @files = {}
      @options = {
        :default_format => 'yaml',
        :lazy_loading => false,
      }
    end

    def path
      @app.platform.config_path
    end

    def [](name)
      @files[name.to_s] ||= make_file(name.to_s)
    end

    def save_all
      @files.each_value{ |file| file.save }
      self
    end

    private

    def make_file(name)
      if File.extname(name).empty?
        # No file extension, so use the default format.
        format = FileBase.get_format_by_name(@options[:default_format])
      else
        # Has a file extension, so try to find a matching format.
        format = FileBase.get_format_by_extname(File.extname(name))
      end
      format.new(self, name)
    end

  end

end


require 'configural/config/file_base'
require 'configural/config/json_file'
require 'configural/config/plist_file'
require 'configural/config/sdl_file'
require 'configural/config/yaml_file'
