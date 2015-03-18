module ZanoxPublisher
  # Program Applications
  #
  # Apply to advertiser programs, get your applications, end partnerships.
  #
  # @attr [Integer]   id                  The programApplicationItems's identifer from Zanox
  # @attr [Program]   program             The program for which the application is made
  # @attr [AdSpace]   adspace             The ad space for which the application is made
  # @attr [String]    status              The status of the application
  # @attr [DateTime]  created_at          The date on which the application was created at
  # @attr [Boolean]   allow_tpv           States if the application allows for tpv tracking links
  # @attr [DateTime]  approved_date       The date on which the application was approved
  # @attr [String]    publisher_comment   The publishers' comment on the application
  # @attr [String]    advertiser_comment  The advertisers' comment on the application
  class ProgramApplication < Base
    RESOURCE_PATH = '/programapplications'

    PROGRAM_APPLICATION_STATUS_ENUM = %w(open confirmed rejected deferred waiting blocked terminated canceled called declined deleted)

    class << self
      # Retrieves all program applications dependent on search parameters.
      #
      # NOTE: Program applications are still returned even after the advertiser program has been paused discontinued.
      # The attribute "active" in the "program" element, indicates whether the program is still active.
      #
      # This is equivalent to the Zanox API method GetProgramApplications.
      # The method documentation can be found under {https://developer.zanox.com/web/guest/publisher-api-2011/get-programapplications}.
      #
      # Authentication: Requires signature.
      #
      # This can require multiple requests, as internally every page is pulled.
      # The ZanoxPublisher::ProgramApplication.page function can be used to better control the requests made.
      #
      # @param program [Program, Integer] Limits results to a particular program.
      # @param adspace [AdSpace, Integer] Limits results to incentives that have tracking links associated with this ad space.
      # @param status [String] Restrict results to program applications with certain status.
      #
      # @return [Array<ProgramApplication>]
      def all(options = {})
        retval = []
        current_page = 0
        options.merge!({ per_page: maximum_per_page })

        begin
          retval       += self.page(current_page, options)
          current_page += 1
        end while ProgramApplication.total > retval.size

        retval
      end

      # Returns a list of programApplicationItems
      #
      # This is equivalent to the Zanox API method GetProgramApplications.
      # The method documentation can be found under {https://developer.zanox.com/web/guest/publisher-api-2011/get-programapplications}.
      #
      # Authentication: Requires signature.
      #
      # @param page [Integer] the page position
      # @param per_page [Integer] number of items in the result set (API equivalent is items)
      # @param items [Integer] number of items in the result set (API name)
      # @param program [Program, Integer] Limits results to a particular program.
      # @param adspace [AdSpace, Integer] Limits results to incentives that have tracking links associated with this ad space.
      # @param status [String] Restrict results to program applications with certain status.
      #
      # @return [Array<ProgramApplication>]
      def page(page = 0, options = {})
        params = { query: { page: page } }

        per_page = nil
        per_page = options[:per_page] if per_page.nil?
        per_page = options[:items]    if per_page.nil?
        per_page = Program.per_page   if per_page.nil?
        params[:query].merge!({ items: per_page })

        program = options[:program]
        program = program.to_i      unless program.nil?

        adspace = options[:adspace]
        adspace = adspace.to_i      unless adspace.nil?

        status  = options[:status]
        status  = nil               unless PROGRAM_APPLICATION_STATUS_ENUM.include? status

        params[:query].merge!({ program: program })  unless program.nil?
        params[:query].merge!({ adspace: adspace })  unless adspace.nil?
        params[:query].merge!({ status:  status  })  unless status.nil?

        retval = []

        response = self.connection.signature_get(RESOURCE_PATH, params)

        ProgramApplication.total = response.fetch('total')
        program_applications = response.fetch('programApplicationItems', {}).fetch('programApplicationItem', [])

        program_applications.each do |application|
          retval << ProgramApplication.new(application)
        end

        retval
      end

      # A connection instance with Program Applications' relative_path
      #
      # @return [Connection]
      def connection
        @connection ||= Connection.new(RESOURCE_PATH)
      end
    end

    # TODO: {https://developer.zanox.com/web/guest/publisher-api-2011/post-programapplications-program-adspace}
    # TODO: {https://developer.zanox.com/web/guest/publisher-api-2011/delete-programapplications-program-adspace}
    def initialize(data = {})
      @id                 = data.fetch('@id').to_i
      @program            = Program.new(data.fetch('program'))
      @adspace            = AdSpace.new(data.fetch('adspace'))
      @status             = data.fetch('status')
      @created_at         = data.fetch('createDate')
      @allow_tpv          = data.fetch('allowTpv')
      @approved_date      = data.fetch('approvedDate', nil)
      @publisher_comment  = data.fetch('publisherComment', nil)
      @advertiser_comment = data.fetch('advertiserComment', nil)
    end

    attr_accessor :id, :program, :adspace, :status, :created_at, :allow_tpv,
                  :approved_date, :publisher_comment, :advertiser_comment

    # make API names available
    alias createDate created_at
    alias allowTpv allow_tpv
    alias approvedDate approved_date
    alias publisherComment publisher_comment
    alias advertiserComment advertiser_comment
  end
end
