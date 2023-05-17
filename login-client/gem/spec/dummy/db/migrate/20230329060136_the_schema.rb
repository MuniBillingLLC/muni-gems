# Because our spec_helper.rb does:
#   Rake::Task['db:migrate:reset'].invoke
# ... this file can be edited in situ, there's no need of
# multiple migration files.
class TheSchema < ActiveRecord::Migration[5.2]
  def change
    create_table :api_users do |t|
      t.string  :name
      t.string  :email
      t.string  :api_key
      t.timestamps
    end

    create_table :users do |t|
      t.string  :name
      t.string  :email
      t.boolean :locked_at
      t.timestamps
    end

    create_table :customers do |t|
      t.string  :first_name
      t.string  :last_name
      t.string  :email
      t.boolean :locked_at
      t.timestamps
    end

    create_table :secure_identities do |t|
      t.string  :sid
      t.string  :mod_name
      t.integer :mod_id
      t.boolean :locked_at
      t.timestamps
    end
  end
end
