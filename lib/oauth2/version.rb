module OAuth2
  class Version
    MAJOR = 1 unless defined? OAuth2::Version::MAJOR
    MINOR = 1 unless defined? OAuth2::Version::MINOR
    PATCH = 3 unless defined? OAuth2::Version::PATCH

    def self.to_s
      [MAJOR, MINOR, PATCH].compact.join('.')
    end
  end
end