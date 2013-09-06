module Ginatra
  # A standard error class for inheritance.
  class Error < StandardError; end

  # An error related to a commit somewhere.
  class CommitsError < Error
    def initialize(repo)
      super("Something went wrong looking for the commits for #{repo}")
    end
  end
end
