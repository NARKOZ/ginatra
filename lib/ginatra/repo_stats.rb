module Ginatra
  class RepoStats
    # @param [Ginatra::Repo] repo Ginatra::Repo instance
    # @param [String] branch_name Branch name of repository
    # @return [Ginatra::RepoStats]
    def initialize(repo, branch_name)
      @repo = repo
      @branch = branch_name
    end

    # Contributors to repository
    #
    # @return [Array] Information about contributors sorted by commits count
    def contributors
      contributors = {}
      ref = @repo.ref("refs/heads/#{@branch}")
      walker = Rugged::Walker.new(@repo.to_rugged)
      walker.push(ref.target)

      walker.each do |commit|
        process_commit(commit, contributors)
      end

      contributors.sort_by { |c| c.last[:commits_count] }.reverse
    end

    def process_commit(commit, contributors)
      author = commit.author
      email = author[:email]
      if contributors[email]
        update_contributor(author, email, contributors)
      else
        new_contributor(author, email, contributors)
      end
    end

    def update_contributor(author, email, contributors)
      contributors[email] = {
        author: author[:name],
        commits_count: contributors[email][:commits_count] + 1
      }
    end

    def new_contributor(author, email, contributors)
      contributors[email] = {
        author: author[:name],
        commits_count: 1
      }
    end

    # Detect common OSS licenses
    #
    # @return [String] License name
    def license
      last_commit = @repo.ref("refs/heads/#{@branch}").target
      license_file = @repo.blob_at(last_commit.oid, 'LICENSE')
      license_text_file =  @repo.blob_at(last_commit.oid, 'LICENSE.txt')
      license =  license_file || license_text_file

      if license.nil?
        'N/A'
      else
        return license_name(license.text)
      end
    end

    def license_name(license_text)
      gnu_regex = /GNU GENERAL PUBLIC LICENSE/
      lgpl_regex = /GNU LESSER GENERAL PUBLIC LICENSE/
      mit_regex = /Permission is hereby granted, free of charge,/
      bsd_regex = /Redistribution and use in source and binary forms/
      return 'Apache' if license_text.match /Apache License/
      return 'GPL' if license_text.match gnu_regex
      return 'LGPL' if license_text.match lgpl_regex
      return 'MIT' if license_text.match mit_regex
      return 'BSD' if license_text.match bsd_regex
      'N/A'
    end

    # Repository created at time
    #
    # @return [Time] Date of first commit to repository
    def created_at
      ref = @repo.ref("refs/heads/#{@branch}")

      walker = Rugged::Walker.new(@repo.to_rugged)
      walker.sorting(Rugged::SORT_TOPO)
      walker.push(ref.target)
      commit = walker.to_a.last
      Time.at(commit.time)
    end

    # Commits count in defined branch
    #
    # @return [Integer] Commits count
    def commits_count
      ref = @repo.ref("refs/heads/#{@branch}")

      walker = Rugged::Walker.new(@repo.to_rugged)
      walker.push(ref.target)
      walker.count
    end
  end
end
