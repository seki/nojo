require 'aws-sdk-s3'

class MyS3
  def initialize(more={})
    env = ENV.to_hash.update(more)
    credentials = Aws::Credentials.new(env['S3_ACCESS_KEY_ID'], env['S3_SECRET_ACCESS_KEY'])
    region = env['S3_REGION'] || 'us-east-1'
    Aws.config.update(
      region: region,
      credentials: credentials
    )
    @s3 = Aws::S3::Client.new
    @bucket = env['S3_BUCKET'] || "nojo01"
  end
  attr_reader :s3, :bucket

  def put_object(key, body)
    @s3.put_object(bucket: @bucket, key: key, body: body)
  end

  def get_object(key)
    @s3.get_object(bucket: @bucket,key: key)
  end

  def copy_object(src, dest)
    @s3.copy_object(bucket: @bucket, 
      copy_source: @bucket + '/' + src,
      key: dest
    )
  end

  def list_objects(prefix="")
    @s3.list_objects(bucket: @bucket, prefix: prefix)
  end

  def presigned(key, expires=900)
    signer = Aws::S3::Presigner.new
    signer.presigned_url(
      :get_object, bucket: @bucket, key: key, expires_in: expires
    )
  end

  def time_to_key(time)
    Time.at((time.to_f / 600).ceil * 600).localtime.strftime("%Y%m%d.csv")
  end
end

if __FILE__ == $0
  load 'env.rb' if File.exist?('env.rb')

  mys3 = MyS3.new
  c = File.read('README.md')
  mys3.put_object("README.md", c)
end