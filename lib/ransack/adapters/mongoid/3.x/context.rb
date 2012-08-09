require 'ransack/context'
require 'polyamorous'

module Ransack
  module Adapters
    module Mongoid
      class Context < ::Ransack::Context        
        def initialize(object, options = {})
          super
        end

        def evaluate(search, opts = {})
          viz = Visitor.new
          relation = @object.where(viz.accept(search.base))
          if search.sorts.any?
            relation = relation.except(:order).order(viz.accept(search.sorts))
          end
        end

        def attribute_method?(str, klass = @klass)
          ransackable_attribute?(str, klass)
        end

        def table_for(parent)
          parent.collection
        end

        def klassify(obj)
          if Class === obj && obj.respond_to?(:field)
            obj
          elsif obj.respond_to? :klass
            obj.klass
          elsif obj.respond_to? :active_record
            obj.active_record
          else
            raise ArgumentError, "Don't know how to klassify #{obj}"
          end
        end

        def type_for(attr)
          return nil unless attr && attr.valid?
          name        = attr.name.to_s

          # name of class which relation attribute points to
          collection_class  = search_attribute(attr).relation

          unless collection_exists?(collection_class)
            raise "No collection named #{collection_class.name} exists"
          end

          # get type of attribute via collection_class
          collection_class.attribute(name).type
        end

        private

        def get_parent_and_attribute_name(str, parent = @base)
          attr_name = nil

          if ransackable_attribute?(str, klassify(parent))
            # ??
          end

          [parent, attr_name]
        end

        def get_association(str, parent = @base)
          klass = klassify parent
          ransackable_association?(str, klass) &&          
        end
      end
    end
  end
end
