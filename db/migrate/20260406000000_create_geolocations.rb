class CreateGeolocations < ActiveRecord::Migration[8.1]
  def change
    create_table :geolocations do |t|
      t.string :zipcode, null: false
      t.decimal :latitude, precision: 10, scale: 6, null: false
      t.decimal :longitude, precision: 10, scale: 6, null: false

      t.timestamps
    end

    add_index :geolocations, :zipcode, unique: true
  end
end
