class CreateKortforsyningenTickets < ActiveRecord::Migration[5.1]
  def change
    create_table :kortforsyningen_tickets do |t|
    	t.text :code
      t.timestamps
    end
  end
end
