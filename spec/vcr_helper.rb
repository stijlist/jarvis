VCR.configure do |config|
  config.cassette_library_dir = './spec/cassettes'
  config.hook_into(:webmock)
  config.filter_sensitive_data('<ZULIP_JARVIS_EMAIL>') { ENV.fetch('ZULIP_JARVIS_EMAIL') }
  config.filter_sensitive_data('<ZULIP_JARVIS_API_KEY>') { ENV.fetch('ZULIP_JARVIS_API_KEY') }
  config.filter_sensitive_data('<GOOGLE_JARVIS_CLIENT_EMAIL>') { ENV.fetch('GOOGLE_JARVIS_CLIENT_EMAIL') }
  config.filter_sensitive_data('<GOOGLE_JARVIS_CALENDAR_ID>') { ENV.fetch('GOOGLE_JARVIS_CALENDAR_ID') }
  config.filter_sensitive_data('<GOOGLE_JARVIS_PRIVATE_KEY>') { ENV.fetch('GOOGLE_JARVIS_PRIVATE_KEY') }
end
