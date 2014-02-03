module OAuth2Client
  class Version
    MAJOR = 1 unless defined? OAuth2Client::Version::MAJOR
    MINOR = 1 unless defined? OAuth2Client::Version::MINOR
    PATCH = 2 unless defined? OAuth2Client::Version::PATCH

    def self.to_s
      [MAJOR, MINOR, PATCH].compact.join('.')
    end
  end
end