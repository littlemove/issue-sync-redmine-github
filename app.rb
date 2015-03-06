require 'sinatra'
require 'newrelic_rpm'
require 'httparty'
require 'pry' if development?
require 'sinatra/activerecord'
require './config/environments'
require './config/mapping'
require './models/redmine_issue'
require './models/github_issue'
require './models/issue'

@@mapping = Mapping.new

get '/' do
  content_type :json
  Issue.order("ID DESC").all.to_json
end

post '/redmine_hook/:github_owner/:github_project' do

  data = JSON.parse(request.body.read)
  data["github_repo"] = "#{params[:github_owner]}/#{params[:github_project]}"
  redmine = RedmineIssue.new(data)

  issue =
    Issue.where("redmine_id = :redmine_id AND github_repo = :github_repo",
          { redmine_id: redmine.id,
            github_repo: redmine.github_repo }).first

  if issue.present?
    ## Update on Github if exist
    issue.update_on_github(redmine)
  else
    ## Only create Issue on Github when status is validated
    if redmine.open?
      issue = Issue.create(redmine_id: redmine.id, github_project: redmine.github_project)
      issue.create_on_github(redmine)
    end
  end

  "OK"
end

post '/github_hook' do
  data = JSON.parse(request.body.read)
  github = GithubIssue.new(data)

  issue = Issue.where(github_id: github.id).first

  ## Issue already created on Redmine
  if issue.present?
    issue.update_on_redmine(github)
  end

  "OK"
end

after do
  # Close the connection after the request is done so that we don't
  # deplete the ActiveRecord connection pool.
  ActiveRecord::Base.connection.close
end
