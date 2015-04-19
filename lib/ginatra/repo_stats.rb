module Ginatra
  class RepoStats
    # @param [Ginatra::Repo] repo Ginatra::Repo instance
    # @param [String] ref Branch or tag name of repository
    # @return [Ginatra::RepoStats]
    def initialize(repo, ref)
      @repo = repo
      @ref = repo.branch_exists?(ref) ? repo.ref("refs/heads/#{ref}") : repo.ref("refs/tags/#{ref}")
    end

    # Contributors to repository
    #
    # @return [Array] Information about contributors sorted by commits count
    def contributors
      contributors = {}
      walker = Rugged::Walker.new(@repo.to_rugged)
      walker.push(@ref.target)

      walker.each do |commit|
        author = commit.author
        email = author[:email]

        if contributors[email]
          contributors[email] = {
            author: author[:name],
            commits_count: contributors[email][:commits_count] + 1
          }
        else
          contributors[email] = {
            author: author[:name],
            commits_count: 1
          }
        end
      end

      contributors.sort_by {|c| c.last[:commits_count] }.reverse
    end

    # Detect common OSS licenses
    #
    # @return [String] License name
    def license
      last_commit = @ref.target
      license = @repo.blob_at(last_commit.oid, 'LICENSE') || @repo.blob_at(last_commit.oid, 'LICENSE.txt')

      if license.nil?
        'N/A'
      else
        license_text = license.text

        case license_text
        when /Apache License/
          'Apache'
        when /GNU GENERAL PUBLIC LICENSE/
          'GPL'
        when /GNU LESSER GENERAL PUBLIC LICENSE/
          'LGPL'
        when /Permission is hereby granted, free of charge,/
          'MIT'
        when /Redistribution and use in source and binary forms/
          'BSD'
        else
          'N/A'
        end
      end
    end

    # Repository created at time
    #
    # @return [Time] Date of first commit to repository
    def created_at
      walker = Rugged::Walker.new(@repo.to_rugged)
      walker.sorting(Rugged::SORT_TOPO)
      walker.push(@ref.target)
      commit = walker.to_a.last
      Time.at(commit.time)
    end

    # Commits count in defined branch
    #
    # @return [Integer] Commits count
    def commits_count
      walker = Rugged::Walker.new(@repo.to_rugged)
      walker.push(@ref.target)
      walker.count
    end
  end
end
