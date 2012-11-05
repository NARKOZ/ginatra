module Ginatra
  # A standard error class for inheritance.
  class Error < StandardError; end

  # An error related to a commit somewhere.
  class CommitsError < Error
    def initialize(repo)
      super("Something went wrong looking for the commits for #{repo}")
    end
  end

  # Error raised when commit ref passed in parameters
  # does not exist in repository
  class InvalidCommit < Error
    def initialize(id)
      super("Could not find a commit with the id of #{id}")
    end
  end
end
