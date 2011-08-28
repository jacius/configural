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

    def _load
      @data = Plist.parse_xml(path) || {}
    rescue Errno::ENOENT
      @data = {}
    end

    def _save
      require 'fileutils'
      FileUtils.mkdir_p( File.dirname(path) )
      File.open(path, 'w') { |f| f.write( @data.to_plist ) }
    end
  end

end
