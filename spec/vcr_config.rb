VCR.config do |config|
  config.cassette_library_dir = "spec/cassettes"
  config.stub_with :webmock
end
