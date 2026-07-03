# Patches jekyll-github-card so {% github variable_name %} resolves the
# Liquid variable's value instead of passing the literal string to the API.

Jekyll::GithubCard::GithubRepoTag.class_eval do
  def render(context)
    repo = context[@repo] || @repo
    repo = repo.to_s.strip
    return error_card("No repository specified") if repo.empty?

    repo_data = fetch_repo_data(repo)
    return error_card(repo_data[:error]) if repo_data[:error]

    build_card(repo_data)
  end
end
