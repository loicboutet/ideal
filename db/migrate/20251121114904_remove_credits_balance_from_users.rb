class RemoveCreditsBalanceFromUsers < ActiveRecord::Migration[8.0]
  def change
    remove_column :users, :credits_balance, :integer
  end
end
