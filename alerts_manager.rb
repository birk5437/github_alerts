class AlertsManager

  def initialize(args={})
    @github_username = args[:github_username]
    @github_api_key = args[:github_api_key]
    @repo_owner = args[:repo_owner]
    @repo_name = args[:repo_name]

    @github_auth = [@github_username, @github_api_key]
  end

  def has_internet?
    require "resolv"
    dns_resolver = Resolv::DNS.new()
    begin
      dns_resolver.getaddress("google.com")
      return true
    rescue Resolv::ResolvError => e
      return false
    end
  end


  def pull_requests(force_reload=false)
    if force_reload
      @pull_requests = github(true).pull_requests.list(@repo_owner, @repo_name).body.map{ |hashie| PullRequest.new({json_data: hashie.to_json, github_connector: github}) }
    else
      @pull_requests ||= github.pull_requests.list(@repo_owner, @repo_name).body.map{ |hashie| PullRequest.new({json_data: hashie.to_json, github_connector: github}) }
    end
    cutoff_date = 1.month.ago.beginning_of_day
    @pull_requests.select!{ |pr| (pr.created_at.end_of_day >= cutoff_date) }
    @pull_requests
  end

  def github(force_reload=false)
    if force_reload
      @github = Github.new(basic_auth: "#{@github_auth.join(':')}", auto_pagination: true)
    else
      @github ||= Github.new(basic_auth: "#{@github_auth.join(':')}", auto_pagination: true)
    end
  end
end
