function value_exists_in_table(tbl, search_value)
   for _, value in pairs(tbl) do
    if value == search_value then
      return true
    end
  end

  return false
end
