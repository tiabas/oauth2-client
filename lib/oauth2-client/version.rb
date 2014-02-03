module OAuth2Client
  class Version
    MAJOR = 2 unless defined? OAuth2Client::Version::MAJOR
    MINOR = 0 unless defined? OAuth2Client::Version::MINOR
    PATCH = 0 unless defined? OAuth2Client::Version::PATCH

    def self.to_s
      [MAJOR, MINOR, PATCH].compact.join('.')
    end
  end
end