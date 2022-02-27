class CreateLicenses < ActiveRecord::Migration[6.0]
  def change
    create_table :licenses do |t|
      t.string :paid_till
      t.string :max_version
      t.string :min_version

      t.timestamps
    end
  end
end
