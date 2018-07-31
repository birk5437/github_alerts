class PullRequest

  attr_accessor :data

  def initialize(args={})
    #args takes json_data:, github_connector:
    @github_connector = args[:github_connector]
    @data = JSON.parse(args[:json_data])
  end

  def author
    @data["user"]["login"]
  end

  def number
    @data["number"]
  end

  def title
    @data["title"]
  end

  def branch_name
    @data["head"]["label"].gsub("#{repo_owner}:", "")
  end

  def created_at
    DateTime.parse(@data["created_at"])
  end

  def repo_name
    @data["head"]["repo"]["name"]
  end

  def repo_owner
    @data["head"]["repo"]["owner"]["login"]
  end

  def repo_clone_url
    @data["head"]["repo"]["clone_url"]
  end

  def head_sha
    @data["head"]["sha"]
  end

  def files
    @files ||= @github_connector.pull_requests.files(repo_owner, repo_name, number).body.map{ |hsh| hsh["filename"] }
  end

  def file_infos(smartling_manager)
    @file_infos ||= @github_connector.pull_requests.files(repo_owner, repo_name, number).body
  end

  def github_info_from_file_path(smartling_manager, file_path)
    begin
      @github_connector.repos.contents.get(repo_owner, repo_name, file_path, {:ref => branch_name})
    rescue Github::Error::NotFound => e
      nil
    end
  end

end
