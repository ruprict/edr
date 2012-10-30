require_relative '../lib/edr'

# STEP0: Schema
# --------------------------------------------------
ActiveRecord::Schema.define(:version => 1) do
  create_table "orders", :force => true do |t|
    t.decimal  "amount"
    t.date     "deliver_at"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "items", :force => true do |t|
    t.string   "name"
    t.decimal  "amount"
    t.integer  "order_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end
end



# STEP1: Define data objects
# --------------------------------------------------
class OrderData < ActiveRecord::Base
  self.table_name = "orders"

  attr_accessible :amount, :deliver_at

  validates :amount, numericality: true
  has_many :items, class_name: 'ItemData', foreign_key: 'order_id'
end

class ItemData < ActiveRecord::Base
  self.table_name = "items"

  attr_accessible :amount, :name

  validates :amount, numericality: true
  validates :name, presence: true
end



# STEP2: Define domain objects
# --------------------------------------------------
class Order
  include Edr::Model

  fields :id, :amount, :deliver_at
  associations :items

  def add_item attrs
    wrap association(:items).new(attrs)
  end
end

class Item
  include Edr::Model

  fields :id, :name, :amount
end



# STEP3: map data objects to domain objects
# --------------------------------------------------
Edr::Registry.define do
  map Order, OrderData
  map Item, ItemData
end



# STEP4: Define repository to access data
# --------------------------------------------------
module OrderRepository
  extend Edr::AR::Repository

  set_model_class Order, root: true

  def self.find_by_amount amount
    where(amount: amount).map do |data|
      Order.new data
    end
  end

  def self.find_by_id id
    where(id: id).map do |data|
      Order.new data
    end.first
  end
end



# STEP5: Profit
# --------------------------------------------------