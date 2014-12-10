module Ginatra
  # A standard error class for inheritance.
  class Error < StandardError; end

  # Raised when repo not found in list.
  class RepoNotFound < Error; end

  # Raised when repo ref not found.
  class InvalidRef < Error; end
end
