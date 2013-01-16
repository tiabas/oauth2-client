module OAuth2
  class Version
    MAJOR = 0 unless defined? OAuth2::Version::MAJOR
    MINOR = 9 unless defined? OAuth2::Version::MINOR
    PATCH = 0 unless defined? OAuth2::Version::PATCH

    def self.to_s
      [MAJOR, MINOR, PATCH].compact.join('.')
    end
  end
end