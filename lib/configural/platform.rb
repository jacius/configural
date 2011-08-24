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

require 'rbconfig'

module Configural

  class Platform
    def self.inherited(subclass)
      @subclasses ||= []
      @subclasses << subclass
    end

    def self.get_platform( app )
      platform = @subclasses.reverse.find { |subclass|
        subclass.match?( app )
      }
      unless platform
        raise 'Sorry, your operating system is not yet supported.'
      end
      platform
    end

    def self.match?( app )
      raise 'Method not implemented for base class.'
    end


    def initialize( app )
      @app = app
    end

    def cache_path
      raise 'Method not implemented for base class.'
    end

    def config_path
      raise 'Method not implemented for base class.'
    end

    def data_path
      raise 'Method not implemented for base class.'
    end
  end


  class LinuxPlatform < Platform
    def self.match?( app )
      true if /linux/ =~ RbConfig::CONFIG['host_os']
    end

    def cache_path
      File.join( ENV['HOME'], '.cache', @app.name )
    end

    def config_path
      File.join( ENV['HOME'], '.config', @app.name )
    end

    def data_path
      File.join( ENV['HOME'], '.local', 'share', @app.name )
    end
  end


  class MacPlatform < Platform
    def self.match?( app )
      true if /darwin/ =~ RbConfig::CONFIG['host_os']
    end

    def cache_path
      File.join( ENV['HOME'], 'Library', 'Caches', @app.name )
    end

    def config_path
      File.join( ENV['HOME'], 'Library', 'Preferences', @app.name )
    end

    def data_path
      File.join( ENV['HOME'], 'Library',
                 'Application Support', @app.name )
    end
  end


  class WindowsPlatform < Platform
    def self.match?( app )
      true if /mswin|mingw/ =~ RbConfig::CONFIG['host_os']
    end

    def cache_path
      File.join( ENV['APPDATA'], @app.name, 'Cache' )
    end

    def config_path
      File.join( ENV['APPDATA'], @app.name, 'Config' )
    end

    def data_path
      File.join( ENV['APPDATA'], @app.name, 'Data' )
    end
  end

end
