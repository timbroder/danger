# http://devcenter.bitrise.io/docs/available-environment-variables
require "danger/request_sources/github/github"
require "danger/request_sources/gitlab"

module Danger
  # ### CI Setup
  #
  # In your Scrutinizer settings or `.scrutinizer.yml`:
  # ``` yml
  # build:
  #     environment:
  #         ruby: "2.4.0"
  #     dependencies:
  #         after:
  #             - bundle install
  #     project_setup:
  #         after: 
  #             - bundle exec danger
  # ```
  # ### Token Setup
  #
  # Add the `DANGER_GITHUB_API_TOKEN` to your Configuration Env Vars.
  #
  class Scrutinizer < CI
    def self.validates_as_ci?(env)
      env.key? "SCRUTINIZER"
    end

    def self.validates_as_pr?(env)
      return !env["SCRUTINIZER_PR_NUMBER"].to_s.empty?
    end

    def supported_request_sources
      @supported_request_sources ||= [Danger::RequestSources::GitHub]
    end

    def initialize(env)
      self.pull_request_id = env["SCRUTINIZER_PR_NUMBER"]

      # Gitlab does not support Scrutinizer https://gitlab.com/gitlab-org/gitlab-ce/issues/5846
      # Scrutinizer does not expose a repo url, but it can be derived
      self.repo_url = "git@github.com:" + env["SCRUTINIZER_PROJECT"][2..-1]

      repo_matches = self.repo_url.match(%r{([\/:])([^\/]+\/[^\/.]+)(?:.git)?$})
      self.repo_slug = repo_matches[2] unless repo_matches.nil?
    end
  end
end
