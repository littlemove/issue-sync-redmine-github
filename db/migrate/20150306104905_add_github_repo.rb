class AddGithubRepo < ActiveRecord::Migration
  def change
    change_table :issues do |t|
      t.string :github_repo
    end
  end
end
