require_relative '../parser'

$parser = BottomsUp.new(:QUERY) do |p|
  # Using (NON_TERMINAL | e) for option parts makes it easier to decord while reducing.
  # If the non terminals themselves were nullable, that would have to be detected on reduction.
  # With this grammar construction, we can safely assume they have contents on reuction.
  p.rule :QUERY,      [:SELECT, :FROM, [:WHERE, :e], [:GROUP_BY, :e], [:ORDER_BY, :e], [:LIMIT, :e]]
  p.rule :QUERY,      [:SELECT, :FROM, [:WHERE, :e], :GROUP_BY, :HAVING, [:ORDER_BY, :e], [:LIMIT, :e]]
  p.rule :SELECT,     [:select, :FIELD_LIST]
  p.rule :FIELD_LIST, [:FIELD_LIST, :',', :FIELD]
  p.rule :FIELD_LIST, [:FIELD]
  p.rule :FIELD,      [[:id, :'*']]
  p.rule :FIELD,      [:id, :as, :id]
  p.rule :FROM,       [:from, :id]
  p.rule :WHERE,      [:where, :EXPR]
  p.rule :LIMIT,      [:limit, :number] # TODO, int type?
  p.rule :GROUP_BY,   [:group, :by, :id] # TODO: multiple ids (ie FIELD_LIST)
  p.rule :HAVING,     [:having, :EXPR]
  p.rule :ORDER_BY,   [:order, :by, :id, [:asc, :desc, :e]] # TODO expression instead of ID?
  p.rule :EXPR,       [[:EQ_EXPR]]
  p.rule :EQ_EXPR,    [:id, [:'=', :'<>', :'>', :'<', :'>=', :'<=', :like], :LITERAL]
  p.rule :EQ_EXPR,    [:LITERAL, [:'=', :'<>', :'>', :'<', :'>=', :'<=', :like], :id]
  p.rule :LITERAL,    [[:number, :string]]

  # TODO: distinct
  # TODO:
  # TODO: Aggregate function expressions | eg: max(field) (e| as id)
  #   SPL: avg(), count(), first(), last(), max(), min(), sum()
  #   SQL: avg(), count(), first(), last(), max(), min(), sum()
  # TODO: If groupby present, select fields must = groupby fields + aggregate functions
  # TODO: convert eq_exprs to eval expressions in SPL
  # TODO: Multi eq expressions in where/having
end
