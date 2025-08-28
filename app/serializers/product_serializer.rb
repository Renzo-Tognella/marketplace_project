class ProductSerializer
  def self.serialize(product)
    {
      id: product.id,
      name: product.name,
      price: product.price.to_f,
      category: product.category,
      created_at: product.created_at,
      updated_at: product.updated_at
    }
  end

  def self.serialize_collection(products)
    products.map { |product| serialize(product) }
  end

  def self.serialize_error(message, status = :unprocessable_entity)
    {
      error: message,
      status: status
    }
  end
end