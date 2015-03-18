class Array
  def sum
    return 0 if empty?
    inject(:+)
  end
end
