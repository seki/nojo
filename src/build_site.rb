require 'fileutils'

module Nojo
  class Site
    def initialize(src, dest='/tmp/nojo')
      @src = src
      @dest = dest
      @images = Dir.glob(src + '/*.jpg')
      FileUtils.mkdir_p(dest) 
    end
    attr_reader :images

    def make_thumbnail_cmd
      %Q!magick #{@src}/*.jpg -set filename:x "thumb-%t" -thumbnail "160x160" "#{@dest}/%[filename:x].jpg"!
    end

    def make_thumbnail
      system(make_thumbnail_cmd)
    end
  end
end

if __FILE__ == $0
  site = Nojo::Site.new(ARGV.shift)
  site.make_thumbnail
  pp site.images
end