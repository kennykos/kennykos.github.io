# frozen_string_literal: true
# Provides a {% github_repo repo_variable %} Liquid tag that renders a GitHub
# repository card matching the .github-card style from github-card.css.
# The variable should be a hash with "name" (e.g. "owner/repo") and optionally
# "contributions" (text describing the author's contributions).

require "net/http"
require "json"
require "uri"
require "cgi"
require "kramdown"

module Jekyll
  module GithubCard
    # Common language colours (subset). Falls back to grey if unknown.
    LANGUAGE_COLORS = {
      "C"          => "#555555",
      "C++"        => "#f34b7d",
      "C#"         => "#178600",
      "CSS"        => "#563d7c",
      "Go"         => "#00ADD8",
      "HTML"       => "#e34c26",
      "Java"       => "#b07219",
      "JavaScript" => "#f1e05a",
      "Julia"      => "#a270ba",
      "Kotlin"     => "#A97BFF",
      "Lua"        => "#000080",
      "MATLAB"     => "#e16737",
      "Objective-C"=> "#438eff",
      "PHP"        => "#4F5D95",
      "Python"     => "#3572A5",
      "R"          => "#198CE7",
      "Ruby"       => "#701516",
      "Rust"       => "#dea584",
      "Scala"      => "#c22d40",
      "Shell"      => "#89e051",
      "Swift"      => "#F05138",
      "TypeScript" => "#3178c6",
    }.freeze

    REPO_CACHE = {}

    class GithubRepoCardTag < Liquid::Tag
      GITHUB_API = "https://api.github.com/repos"

      def initialize(tag_name, markup, tokens)
        super
        @variable = markup.strip
      end

      def render(context)
        # Resolve Liquid variable to get the repo hash
        repo_obj = context[@variable]
        if repo_obj.nil?
          # Fallback: treat markup as a literal repo path string
          repo_path     = @variable
          contributions = nil
        else
          repo_path     = repo_obj["name"].to_s.strip
          contributions = repo_obj["contributions"].to_s.strip
          contributions = nil if contributions.empty?
        end

        return error_card("No repository specified") if repo_path.empty?

        data = fetch_repo_data(repo_path)
        return error_card(data[:error]) if data[:error]

        build_card(data, contributions)
      end

      private

      def fetch_repo_data(repo_path)
        return REPO_CACHE[repo_path] if REPO_CACHE[repo_path]

        uri  = URI.parse("#{GITHUB_API}/#{repo_path}")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl     = true
        http.open_timeout = 5
        http.read_timeout = 5

        req = Net::HTTP::Get.new(uri.request_uri)
        req["Accept"]     = "application/vnd.github.v3+json"
        req["User-Agent"] = "Jekyll-Github-Card"
        req["Authorization"] = "token #{ENV['GITHUB_TOKEN']}" if ENV["GITHUB_TOKEN"]

        resp = http.request(req)

        if resp.code == "200"
          d = JSON.parse(resp.body)
          REPO_CACHE[repo_path] = {
            full_name:   d["full_name"],
            name:        d["name"],
            html_url:    d["html_url"],
            description: d["description"],
            stars:       d["stargazers_count"],
            forks:       d["forks_count"],
            language:    d["language"],
            owner:       d.dig("owner", "login"),
          }
        else
          { error: "'#{repo_path}' not found (HTTP #{resp.code})" }
        end
      rescue StandardError => e
        { error: "Failed to fetch repo: #{e.message}" }
      end

      def build_card(d, contributions)
        full_name   = CGI.escapeHTML(d[:full_name])
        owner       = CGI.escapeHTML(d[:owner] || "")
        repo_name   = CGI.escapeHTML(d[:name])
        html_url    = CGI.escapeHTML(d[:html_url])
        description = d[:description] ? CGI.escapeHTML(d[:description]) : nil
        stars       = d[:stars] || 0
        forks       = d[:forks] || 0
        language    = d[:language]

        desc_html = description ? <<~HTML : ""
          <div class="github-card-body">
            <p class="github-card-description">#{description}</p>
          </div>
        HTML

        lang_html = language ? <<~HTML : ""
          <span class="github-card-language">
            <span class="github-card-language-dot" style="background-color: #{LANGUAGE_COLORS.fetch(language, '#8b949e')};"></span>
            #{CGI.escapeHTML(language)}
          </span>
        HTML

        contributions_md = contributions ? Kramdown::Document.new(contributions).to_html.strip : nil
        contributions_html = contributions_md ? <<~HTML : ""
          <div class="github-card-contributions">
            <div class="github-card-contributions-title">My Contributions</div>
            <div class="github-card-contributions-text">#{contributions_md}</div>
          </div>
        HTML

        <<~HTML
          <div class="github-card github-repo-card">
            <div class="github-card-header">
              <svg class="github-card-icon" viewBox="0 0 16 16" width="16" height="16" aria-hidden="true">
                <path fill="currentColor" d="M2 2.5A2.5 2.5 0 014.5 0h8.75a.75.75 0 01.75.75v12.5a.75.75 0 01-.75.75h-2.5a.75.75 0 110-1.5h1.75v-2h-8a1 1 0 00-.714 1.7.75.75 0 01-1.072 1.05A2.495 2.495 0 012 11.5v-9zm10.5-1V9h-8c-.356 0-.694.074-1 .208V2.5a1 1 0 011-1h8z"/>
              </svg>
              <a href="#{html_url}" target="_blank" rel="noopener noreferrer" class="github-card-link">
                <span class="github-card-repo-name">#{owner}/<strong>#{repo_name}</strong></span>
              </a>
            </div>
            #{desc_html}
            <div class="github-card-footer">
              #{lang_html}
              <div class="github-card-stats">
                <span class="github-card-stat" title="Stars">
                  <svg viewBox="0 0 16 16" width="16" height="16" aria-hidden="true">
                    <path fill="currentColor" d="M8 .25a.75.75 0 01.673.418l1.882 3.815 4.21.612a.75.75 0 01.416 1.279l-3.046 2.97.719 4.192a.75.75 0 01-1.088.791L8 12.347l-3.766 1.98a.75.75 0 01-1.088-.79l.72-4.194L.873 6.374a.75.75 0 01.416-1.28l4.21-.611L7.327.668A.75.75 0 018 .25z"/>
                  </svg>
                  #{stars}
                </span>
                <span class="github-card-stat" title="Forks">
                  <svg viewBox="0 0 16 16" width="16" height="16" aria-hidden="true">
                    <path fill="currentColor" d="M5 3.25a.75.75 0 11-1.5 0 .75.75 0 011.5 0zm0 2.122a2.25 2.25 0 10-1.5 0v.878A2.25 2.25 0 005.75 8.5h1.5v2.128a2.251 2.251 0 101.5 0V8.5h1.5a2.25 2.25 0 002.25-2.25v-.878a2.25 2.25 0 10-1.5 0v.878a.75.75 0 01-.75.75h-4.5A.75.75 0 015 6.25v-.878zm3.75 7.378a.75.75 0 11-1.5 0 .75.75 0 011.5 0zm3-8.75a.75.75 0 11-1.5 0 .75.75 0 011.5 0z"/>
                  </svg>
                  #{forks}
                </span>
              </div>
            </div>
            #{contributions_html}
          </div>
        HTML
      end

      def error_card(message)
        <<~HTML
          <div class="github-card github-card-error">
            <div class="github-card-body">
              <p class="github-card-error-message">&#x26A0;&#xFE0F; #{CGI.escapeHTML(message)}</p>
            </div>
          </div>
        HTML
      end
    end
  end
end

Liquid::Template.register_tag("github_repo", Jekyll::GithubCard::GithubRepoCardTag)
