require 'fileutils'
require 'exifr/jpeg'
require_relative 'my_s3'
require 'erb'

module Nojo
  class Image
    def initialize(path, dest)
      @path = path
      @dest = dest
      @s3_key = File.basename(path).downcase
      @thumb_key = 'thumb-' + @s3_key
      @exif = EXIFR::JPEG.new(path)
    end
    attr_reader :path, :s3_key, :thumb_key, :exif
    attr_reader :presigned, :thumb_presigned

    def <=>(other)
      @exif.date_time <=> other.exif.date_time
    end

    def make_presigned_url(s3)
      @presigned = s3.presigned(@s3_key, 604800-1)
      @thumb_presigned = s3.presigned(@thumb_key, 604800-1)
    end
  end

  class Site
    extend ERB::DefMethod
    def_erb_method('to_html', 'base.html')

    def initialize(src, dest='/tmp/nojo')
      @src = src
      @dest = dest
      @images = Dir.glob(src + '/*.jpg').map {|path| Image.new(path, dest)}
      @s3 = MyS3.new
      FileUtils.mkdir_p(dest) 
    end
    attr_reader :images, :s3

    def make_thumbnail_cmd
      args = @images.map {|x| x.path}
      %Q!magick #{args.join(' ')} -set filename:x "thumb-%t" -thumbnail "160x160" "#{@dest}/%[filename:x].jpg"!
    end

    def make_thumbnail
      system(make_thumbnail_cmd)
    end

    def make_presigned_url
      @images.each do |im|
        im.make_presigned_url(@s3)
      end
    end

    def upload(path, key)
      c = File.read(path)
      @s3.put_object(key, c)
    end

    def upload_image
      @images.each do |im|
        upload(im.path, im.s3_key)
      end
    end

    def upload_thumbnail
      @images.each do |im|
        upload("#{@dest}/#{im.thumb_key}", im.thumb_key)
      end
    end
  end
end

if __FILE__ == $0
  load 'env.rb' if File.exist?('env.rb')

  site = Nojo::Site.new(ARGV.shift)
  site.make_thumbnail
  # site.upload_image
  # site.upload_thumbnail
  site.make_presigned_url
  html = site.to_html
  site.s3.put_object('index.html', html)
end