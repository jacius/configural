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

  class App
    attr_accessor :name, :path
    attr_writer :config_path, :cache_path, :data_path
    attr_reader :user

    def initialize( name )
      @name = name
      @user = Configural::User.new(self)
    end


    def cache
      @cache ||=
        begin
          unless @cache_path
            raise 'you must set cache_path or path first'
          end
          Configural::Cache.new(self)
        end
    end

    def cache_path
      @cache_path || (@path and File.join(@path, 'cache'))
    end


    def config
      @config ||=
        begin
          unless @config_path
            raise 'you must set config_path or path first'
          end
          Configural::Config.new(self)
        end
    end

    def config_path
      @config_path || (@path and File.join(@path, 'config'))
    end


    def data
      @data ||=
        begin
          unless @data_path
            raise 'you must set data_path or path first'
          end
          Configural::Data.new(self)
        end
    end

    def data_path
      @data_path || (@path and File.join(@path, 'data'))
    end


    def save_all
      @config.save_all if @config
      @user.save_all if @user
      self
    end

  end

end
