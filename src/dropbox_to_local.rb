require_relative('../src/my_dropbox')

module DropboxToLocal
  module_function
  def main(src, dest)
    dropbox = MyDropbox.new
    list = dropbox.list(src)
    download_photo(dropbox, list, dir)
  end

  def download_photo(dropbox, list, dir)
    jpeg = list.entries.find_all {|x|
      x.path_lower.end_with?('jpg') || x.path_lower.end_with?('jpeg')
    }
    jpeg.map do |meta|
      path = meta.path_display
      dest_path = File.basename(meta.path_lower)
      _, contents = dropbox.download(path)
      File.open(dir + '/' + dest_path, "wb") {|fp| fp.write(contents)}
      dest_path
    end
  end
end

if __FILE__ == $0
  DropboxToLocal.main(ARGV.shift, '/tmp')
end