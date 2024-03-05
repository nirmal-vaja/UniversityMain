# frozen_string_literal: true

# app/models/concerns/default_json_options.rb
module DefaultJsonOptions
  extend ActiveSupport::Concern

  included do
    def as_json(options = {})
      super(default_json_options(options).merge(options))
    end
  end

  private

  def default_json_options(options)
    default_except = %i[created_at updated_at]
    except = Array(options[:except])
    final_except = (default_except + except).uniq
    {
      except: final_except,
      methods: Array(options[:methods]) || [],
      include: Array(options[:include]) || []
    }
  end
end
