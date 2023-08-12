require_relative 'dropbox_to_local'

module Nojo
  class Site
    def initialize(src, dest='work')
      @dropbox_path = src
      @dest = dest
      @images = nil
      File.mkdir(dest)
    end

    def download_photo
      @images = DropboxToLocal.main(@dropbox_path, dest)
    end

    def make_thumbnail_cmd
      'magick *.jpg -set filename:x "thumb-%t" -thumbnail "160x160" "%[filename:x].jpg"'
    end
  end
end

if __FILE__ == $0
  site = Nojo::Site.new(ARGV.shift)
  site.download_photo
end