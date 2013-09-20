module Ginatra
  module RepoStats
    # Detect common OSS licenses
    def license(branch_name)
      ref = ref("refs/heads/#{branch_name}")
      last_commit = lookup(ref.target)
      license = blob_at(last_commit.oid, 'LICENSE') || blob_at(last_commit.oid, 'LICENSE.txt')

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
  end
end
