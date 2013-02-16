class CreateUserModels < ActiveRecord::Migration
  def change
    create_table :user_models do |t|
      t.string :user
      t.string :password
      t.integer :count

      t.timestamps
    end
  end
end
