# frozen_string_literal: true
# Provides a {% github_user username %} Liquid tag that renders a GitHub user
# profile card using the same visual style as jekyll-github-card repo cards.

require "net/http"
require "json"
require "uri"
require "cgi"

module Jekyll
  module GithubCard
    class GithubUserTag < Liquid::Tag
      GITHUB_API_URL = "https://api.github.com/users"
      CACHE = {}

      def initialize(tag_name, markup, tokens)
        super
        @username = markup.strip
      end

      def render(context)
        # Resolve Liquid variable (same approach as github_card_variable_support.rb)
        username = @username
        context.scopes.each do |scope|
          if scope.respond_to?(:key?) && scope.key?(@username)
            username = scope[@username].to_s
            break
          end
        end
        username = username.strip
        return error_card("No username specified") if username.empty?

        user_data = fetch_user_data(username)
        return error_card(user_data[:error]) if user_data[:error]

        build_card(user_data)
      end

      private

      def fetch_user_data(username)
        return CACHE[username] if CACHE[username]

        uri = URI.parse("#{GITHUB_API_URL}/#{username}")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.open_timeout = 5
        http.read_timeout = 5

        request = Net::HTTP::Get.new(uri.request_uri)
        request["Accept"] = "application/vnd.github.v3+json"
        request["User-Agent"] = "Jekyll-Github-Card"
        request["Authorization"] = "token #{ENV['GITHUB_TOKEN']}" if ENV["GITHUB_TOKEN"]

        response = http.request(request)

        if response.code == "200"
          d = JSON.parse(response.body)
          CACHE[username] = {
            login:        d["login"],
            name:         d["name"],
            bio:          d["bio"],
            avatar_url:   d["avatar_url"],
            html_url:     d["html_url"],
            public_repos: d["public_repos"],
            followers:    d["followers"],
            location:     d["location"],
          }
        else
          { error: "User '#{username}' not found (HTTP #{response.code})" }
        end
      rescue StandardError => e
        { error: "Failed to fetch user: #{e.message}" }
      end

      def build_card(d)
        name     = CGI.escapeHTML(d[:name] || d[:login])
        login    = CGI.escapeHTML(d[:login])
        bio      = CGI.escapeHTML(d[:bio] || "")
        location = d[:location] ? CGI.escapeHTML(d[:location]) : nil

        bio_html = bio.empty? ? "" : <<~HTML
          <div class="github-card-body">
            <p class="github-card-description">#{bio}</p>
          </div>
        HTML

        location_html = location ? <<~HTML : ""
          <span class="github-card-stat" title="Location">
            <svg viewBox="0 0 16 16" width="14" height="14" aria-hidden="true">
              <path fill="currentColor" d="M8 0C5.24 0 3 2.24 3 5c0 3.75 5 11 5 11s5-7.25 5-11c0-2.76-2.24-5-5-5zm0 7.5C6.62 7.5 5.5 6.38 5.5 5S6.62 2.5 8 2.5 10.5 3.62 10.5 5 9.38 7.5 8 7.5z"/>
            </svg>
            #{location}
          </span>
        HTML

        <<~HTML
          <div class="github-card github-user-card">
            <div class="github-card-header github-user-header">
              <img class="github-user-avatar" src="#{d[:avatar_url]}" alt="#{login}" width="48" height="48">
              <div class="github-user-info">
                <a href="#{d[:html_url]}" target="_blank" rel="noopener noreferrer" class="github-card-link">
                  <span class="github-card-repo-name">#{name}</span>
                </a>
                <span class="github-user-login">@#{login}</span>
              </div>
            </div>
            #{bio_html}
            <div class="github-card-footer">
              #{location_html}
              <div class="github-card-stats">
                <span class="github-card-stat" title="Public repos">
                  <svg viewBox="0 0 16 16" width="16" height="16" aria-hidden="true">
                    <path fill="currentColor" d="M2 2.5A2.5 2.5 0 014.5 0h8.75a.75.75 0 01.75.75v12.5a.75.75 0 01-.75.75h-2.5a.75.75 0 110-1.5h1.75v-2h-8a1 1 0 00-.714 1.7.75.75 0 01-1.072 1.05A2.495 2.495 0 012 11.5v-9zm10.5-1V9h-8c-.356 0-.694.074-1 .208V2.5a1 1 0 011-1h8z"/>
                  </svg>
                  #{d[:public_repos]}
                </span>
                <span class="github-card-stat" title="Followers">
                  <svg viewBox="0 0 16 16" width="16" height="16" aria-hidden="true">
                    <path fill="currentColor" d="M2 5.5a3.5 3.5 0 115.898 2.549 5.507 5.507 0 013.034 4.084.75.75 0 11-1.482.235 4.001 4.001 0 00-7.9 0 .75.75 0 01-1.482-.236A5.507 5.507 0 013.102 8.05 3.493 3.493 0 012 5.5zM11 4a.75.75 0 100 1.5 1.5 1.5 0 01.666 2.844.75.75 0 00-.416.672v.352a.75.75 0 00.574.73c1.2.289 2.162 1.2 2.522 2.372a.75.75 0 101.434-.44 5.01 5.01 0 00-2.56-3.012A3 3 0 0011 4z"/>
                  </svg>
                  #{d[:followers]}
                </span>
              </div>
            </div>
          </div>
        HTML
      end

      def error_card(message)
        <<~HTML
          <div class="github-card github-card-error">
            <div class="github-card-body">
              <p class="github-card-error-message">⚠️ #{CGI.escapeHTML(message)}</p>
            </div>
          </div>
        HTML
      end
    end
  end
end

Liquid::Template.register_tag("github_user", Jekyll::GithubCard::GithubUserTag)
