class Reform::Contract::Result  
  private

  def filter_for(method, *args)
    @results.collect { |r| r.public_send(method, *args).to_h }
            .inject({}) { |hah, err| hah.merge(err) { |key, old_v, new_v| (new_v.is_a?(Array) ? (old_v |= new_v) : old_v.merge(new_v)) } }
            .find_all { |k, v| # filter :nested=>{:something=>["too nested!"]} #DISCUSS: do we want that here?
              if v.is_a?(Hash)
                nested_errors = v.select { |attr_key, val| attr_key.is_a?(Integer) && val.is_a?(Array) && val.any? }
                v = nested_errors.to_a if nested_errors.any?
              end
              v.is_a?(Array) || v.class.to_s == "ActiveModel::DeprecationHandlingMessageArray"
            }.to_h
  end
end
