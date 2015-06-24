module Git::Webby
  module HttpBackendHelpers #:nodoc:
    include GitHelpers

    def service_request?
      not params[:service].nil?
    end

    # select_service feature
    def service
      @service = params[:service]
      return false if @service.nil?
      return false if @service[0, 4] != 'git-'
      @service = @service.gsub('git-', '')
    end

    # pkt_write feature
    def packet_write(line)
      (line.size + 4).to_s(16).rjust(4, '0') + line
    end

    # pkt_flush feature
    def packet_flush
      '0000'
    end

    # hdr_nocache feature
    def header_nocache
      headers 'Expires'       => 'Fri, 01 Jan 1980 00:00:00 GMT',
              'Pragma'        => 'no-cache',
              'Cache-Control' => 'no-cache, max-age=0, must-revalidate'
    end

    # hdr_cache_forever feature
    def header_cache_forever
      now = Time.now
      headers 'Date'          => now.to_s,
              'Expires'       => (now + 31536000).to_s,
              'Cache-Control' => 'public, max-age=31536000'
    end

    # select_getanyfile feature
    def read_any_file
      unless settings.get_any_file
        halt 403, 'Unsupported service: getanyfile'
      end
    end

    # get_text_file feature
    def read_text_file(*file)
      read_any_file
      header_nocache
      content_type 'text/plain'
      repository.read_file(*file)
    end

    # get_loose_object feature
    def send_loose_object(prefix, suffix)
      read_any_file
      header_cache_forever
      content_type_for_git :loose, :object
      send_file(repository.loose_object_path(prefix, suffix))
    end

    # get_pack_file and get_idx_file
    def send_pack_idx_file(pack, idx = false)
      read_any_file
      header_cache_forever
      content_type_for_git :packed, :objects, (idx ? :toc : nil)
      send_file(repository.pack_idx_path(pack))
    end

    def send_info_packs
      read_any_file
      header_nocache
      content_type 'text/plain; charset=utf-8'
      send_file(repository.info_packs_path)
    end

    # run_service feature
    def run_advertisement(service)
      header_nocache
      content_type_for_git service, :advertisement
      response.body.clear
      response.body << packet_write("# service=git-#{service}\n")
      response.body << packet_flush
      response.body << repository.run(service, '--stateless-rpc --advertise-refs .')
      response.finish
    end

    def run_process(service)
      content_type_for_git service, :result
      input   = request.body.read
      command = repository.cli(service, "--stateless-rpc #{git.repository}")
      # This source has extracted from Grack written by Scott Chacon.
      IO.popen(command, File::RDWR) do |pipe|
        pipe.write(input)
        while !pipe.eof?
          block = pipe.read(8192) # 8M at a time
          response.write block    # steam it to the client
        end
      end # IO
      response.finish
    end

  end # HttpBackendHelpers

  # The Smart HTTP handler server. This is the main Web application which respond to following requests:
  #
  # <repo.git>/HEAD           :: HEAD contents
  # <repo.git>/info/refs      :: Text file that contains references.
  # <repo.git>/objects/info/* :: Text file that contains all list of packets, alternates or http-alternates.
  # <repo.git>/objects/*/*    :: Git objects, packets or indexes.
  # <repo.git>/upload-pack    :: Post an upload packets.
  # <repo.git>/receive-pack   :: Post a receive packets.
  #
  # See ::configure for more details.
  class HttpBackend < Application

    set :authenticate, true
    set :get_any_file, true
    set :upload_pack,  true
    set :receive_pack, false

    helpers HttpBackendHelpers

    before do
      authenticate! if settings.authenticate
    end

    # implements the get_text_file function
    get '/:repository/HEAD' do
      read_text_file('HEAD')
    end

    # implements the get_info_refs function
    get '/:repository/info/refs' do
      if service_request? # by URL query parameters
        run_advertisement service
      else
        read_text_file(:info, :refs)
      end
    end

    # implements the get_text_file and get_info_packs functions
    get %r{/(.*?)/objects/info/(packs|alternates|http-alternates)$} do |repository, file|
      if file == 'packs'
        send_info_packs
      else
        read_text_file(:objects, :info, file)
      end
    end

    # implements the get_loose_object function
    get %r{/(.*?)/objects/([0-9a-f]{2})/([0-9a-f]{38})$} do |repository, prefix, suffix|
      send_loose_object(prefix, suffix)
    end

    # implements the get_pack_file and get_idx_file functions
    get %r{/(.*?)/objects/pack/(pack-[0-9a-f]{40}.(pack|idx))$} do |repository, pack, ext|
      send_pack_idx_file(pack, ext == 'idx')
    end

    # implements the service_rpc function
    post '/:repository/:service' do
      run_process service
    end

  private

    helpers AuthenticationHelpers
  end # HttpBackendServer
end # Git::Webby
