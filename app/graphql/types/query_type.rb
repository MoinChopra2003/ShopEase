module Types
    class QueryType < Types::BaseObject
        field :me, Types::UserType, null: true
        field :categories, [Types::CategoryType], null: false
        field :products, [Types::ProductType], null: false do
            argument :search, String, required: false
            argument :category_id, ID, required: false
            argument :min_price, Float, required: false
            argument :max_price, Float, required: false
            argument :minimum_price, Float, required: false
            argument :maximum_price, Float, required: false
            argument :in_stock, Boolean, required: false
            argument :in_stock_only, Boolean, required: false
            argument :sort, String, required: false
            argument :page, Int, required: false, default_value: 1
            argument :per_page, Int, required: false, default_value: 10
        end
        field :product, Types::ProductType, null: true do
            argument :id, ID, required: true
        end
        field :addresses, [Types::AddressType], null: false
        field :support_articles, [Types::SupportArticleType], null: false do
            argument :active, Boolean, required: false
        end

        field :orders, [Types::OrderType], null: false do
            argument :status, String, required: false
            argument :page, Int, required: false, default_value: 1
            argument :per_page, Int, required: false, default_value: 10
        end
        field :order, Types::OrderType, null: true do
            argument :id, ID, required: true
        end

        def me
            context[:current_user]
        end

        def categories
            Category.all
        end

        def products(search: nil, category_id: nil, min_price: nil, max_price: nil, minimum_price: nil, maximum_price: nil, in_stock: nil, in_stock_only: nil, sort: nil, page: 1, per_page: 10)
            query = Product.where(active: true)

            query = query.where("name ILIKE ? OR description ILIKE ?", "%#{search}%", "%#{search}%") if search.present?

            query = query.where(category_id: category_id) if category_id.present?

            min_value = min_price.presence || minimum_price
            max_value = max_price.presence || maximum_price

            query = query.where("price >= ?", min_value) if min_value.present?
            query = query.where("price <= ?", max_value) if max_value.present?

            query = query.where("stock > 0") if in_stock.present? && in_stock
            query = query.where("stock > 0") if in_stock_only.present? && in_stock_only

            case sort
            when "price_asc"
                query = query.order(price: :asc)
            when "price_desc"
                query = query.order(price: :desc)
            when "name_asc"
                query = query.order(name: :asc)
            when "name_desc"
                query = query.order(name: :desc)
            when "newest"
                query = query.order(created_at: :desc)
            else
                query = query.order(created_at: :desc)
            end

            offset = (page - 1) * per_page
            query.offset(offset).limit(per_page)
        end

        def product(id:)
            Product.find_by(id: id, active: true)
        end

        def support_articles(active: nil)
            query = SupportArticle.all
            query = query.where(active: active) unless active.nil?
            query.order(position: :asc, created_at: :desc)
        end

        def addresses
            current_user = context[:current_user]
            return [] unless current_user
            current_user.addresses
        end

        def orders(status: nil, page: 1, per_page: 10)
            current_user = context[:current_user]
            return [] unless current_user

            query = current_user.orders

            query = query.where(status: status) if status.present?

            query = query.order(created_at: :desc)

            offset = (page - 1) * per_page
            query.offset(offset).limit(per_page)
        end

        def order(id:)
            current_user = context[:current_user]
            return nil unless current_user
            current_user.orders.find_by(id: id)
        end
    end
end