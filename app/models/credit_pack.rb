class CreditPack < ApplicationRecord
  # Validations
  validates :name, presence: true
  validates :credits_amount, presence: true, numericality: { greater_than: 0 }
  validates :price_cents, presence: true, numericality: { greater_than: 0 }

  # Scopes
  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(:price_cents) }

  # Helper methods
  def price_in_euros
    price_cents / 100.0
  end

  def price_formatted
    "€#{sprintf('%.2f', price_in_euros)}"
  end

  def credits_per_euro
    return 0 if price_in_euros.zero?
    (credits_amount / price_in_euros).round(2)
  end

  # Predefined packs
  def self.seed_default_packs
    [
      { name: '10 Crédits', credits_amount: 10, price_cents: 990, description: 'Pack idéal pour démarrer', active: true },
      { name: '25 Crédits', credits_amount: 25, price_cents: 1990, description: 'Pack populaire - Meilleur rapport qualité/prix', active: true },
      { name: '50 Crédits', credits_amount: 50, price_cents: 2990, description: 'Pack professionnel', active: true },
      { name: '100 Crédits', credits_amount: 100, price_cents: 4990, description: 'Pack premium - Maximum d\'économies', active: true }
    ].each do |pack_attrs|
      find_or_create_by(name: pack_attrs[:name]) do |pack|
        pack.assign_attributes(pack_attrs)
      end
    end
  end
end
