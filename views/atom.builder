xml.instruct! :xml, :version => '1.0', :encoding => 'utf-8'
xml.feed :'xml:lang' => 'en-US', :xmlns => 'http://www.w3.org/2005/Atom' do
  base_title = "#{@repo.name}: "
  base_url = "http://#{hostname}" + prefix_url("#{@repo.param}")
  if params[:ref]
    url = base_url + "/#{params[:ref]}"
    title = base_title + params[:ref]
  else
    url = base_url
    title = base_title + "master"
  end
  xml.id url
  xml.link :type => 'text/html', :href => url, :rel => 'alternate'
  xml.link :type => 'application/atom+xml', :href => "#{url}.atom", :rel => 'self'
  xml.title title
  xml.subtitle "#{h(@repo.description)}"
  xml.updated(@commits.first ? rfc_date(@commits.first.committed_date) : rfc_date(Time.now.utc))
  @commits.each do |commit|
    xml.entry do |entry|
      entry.id "#{base_url}/commit/#{commit.id_abbrev}"
      entry.link :type => 'text/html', :href => "#{base_url}/commit/#{commit.id_abbrev}", :rel => 'alternate'
      entry.updated rfc_date(commit.committed_date)
      entry.title   "Commit #{commit.id_abbrev} to #{@repo.name}"
      entry.summary h(commit.short_message)
      entry.content h(commit.message)
      entry.author do |author|
        author.name  commit.author.name
        author.email commit.author.email
      end
    end
  end
end
