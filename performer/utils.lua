function split_string(str, delimeter)
    lines = {}
    delimete_in_start = (str:find(delimeter) == 1)

    if delimete_in_start then
        table.insert(lines, "")
    end

    for line in str:gmatch("[^" .. delimeter .. "]+") do
        table.insert(lines, line)
    end

    return lines
end
