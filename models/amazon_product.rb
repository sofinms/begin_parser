# lib/models/amazon_product.rb
require 'sequel'
require_relative '../lib/o14/db'

DB = O14::DB.get_db

class AmazonProduct < Sequel::Model(DB[:amazon_products])
end