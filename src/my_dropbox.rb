require 'dropbox_api'

class MyDropbox
  def initialize
    @client = DropboxApi::Client.new(ENV['DROPBOX_TOKEN'])
  end
  attr_reader :client

  def download(fname)
    contents = nil
    file = @client.download(fname) do |x|
      contents = x
    end
    return file, contents
  end

  def upload(fname, data)
    @client.upload(fname, data, :mode => :overwrite)
  end

  def metadata(fname)
    @client.get_metadata(fname)
  end

  def list(folder)
    @client.list_folder(folder, :recursive => true)
  end
end

if __FILE__ == $0
  dropbox = MyDropbox.new

  pp dropbox.list(ARGV.shift)
end