class Parser
  
  def self.parse(input)
    date_hash = {}
    day, month, year = "00", "00", "0000"
    # Minor Pre Cleanup
    input.strip!; input.gsub!('~','')
    
    if input.match('/') # 02/25/2008
      date_array = input.split('/')
      if date_array.length == 3
        begin
          parsed_date = Date.parse(self)
          month, day, year = parsed_date.month, parsed_date.day, parsed_date.year
        rescue
          month, day, year = date_array
        end
      elsif date_array.length == 2
        month, year = date_array
      end
    elsif input.length == 8 && is_numeric?(input) # 20080225
      year, month, day = input.slice(0..3), input.slice(4..5), input.slice(6..7)
    elsif input.match('-') # 2008-25-02 or 02-25-2008
      date_array = input.split('-')
      year = date_array.select{ |part| part.length == 4 }.first
      unless year.nil? || date_array.length != 3
        if date_array.first == year
          month = date_array.last
          day = date_array[1]
        else
          month = date_array[1]
          day = date_array.first
        end
      end
    elsif input.length == 4 # 2004
      year = input.to_s if (input.slice(0..1) == '19' || input.slice(0..1) == '20')
    elsif input.length == 2 # 85
      year = (input.to_i > Date.today.year.to_s.slice(2..4).to_i) ? "19#{input}" : "20#{input}"
    elsif input.match(/\w/) # Jun 23, 2004
      begin
        d = Date.parse(input)
        year, month, day = d.year.to_s, d.month.to_s, d.day.to_s
      rescue; end
    end
    
    date_hash = { :year => year, :month => month, :day => day }
    
    # Post parsing cleanup
    date_hash.each do |key, value|
      date_hash[key] = if value.nil?
        key.to_s == 'year' ? '0000' : '00'
      else
        date_hash[key] = value.to_s.strip
      end
    end
    
    # Cleanup the single digit values
    unless date_hash.empty?
      date_hash.each do |key,value|
        date_hash[key] = "0#{value}" if value.to_s.length == 1
      end
    end
    
    # Two character years
    if date_hash[:year].length == 2
      date_hash[:year] = date_hash[:year].to_i > Date.today.year.to_s.slice(2..4).to_i ? "19#{date_hash[:year]}" : "20#{date_hash[:year]}"
    end
    
    # Attempt to correct some known OCR issues
    if date_hash[:year].to_s.match('00') && date_hash[:year] != '0000'
      date_hash[:year] = "2#{date_hash[:year].slice(1..3)}"
    end
    
    return date_hash.empty? ? nil : date_hash
  end
  
end