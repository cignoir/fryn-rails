require 'open-uri'
require 'openssl'
require 'nokogiri'
OpenSSL::SSL.module_eval {remove_const(:VERIFY_PEER)}
OpenSSL::SSL.const_set(:VERIFY_PEER, OpenSSL::SSL::VERIFY_NONE)

namespace :wiki do
  class Nokogiri::XML::Element
    def extract
      self.try(:inner_text).try(:strip)
    end
  end

  class Nokogiri::XML::NodeSet
    def extract
      self.try(:inner_text).try(:strip)
    end
  end

  def parse(rows, megami_code, megami_fullname)
    rows.map do |node|
      tds = node.xpath('td')

      code = tds[0].try(:extract)
      raise 'no code' unless code

      next unless code =~ /.+?-\d+.*/

      card = Card.new
      card.megami_code = megami_code
      card.megami_name = megami_fullname.gsub(/\(.+?\)/, '').strip
      card.megami_fullname = megami_fullname
      card.code = code
      card.name = tds[1].try(:extract)
      card.main_type = tds[2].try(:extract)
      card.sub_type = tds[3].try(:extract)
      card.kasa = '-'
      card.range = tds[4].try(:extract)
      card.damage_aura = tds[5].try(:extract)
      card.damage_life = tds[6].try(:extract)
      card.osame = tds[7].try(:extract)
      card.cost = tds[8].try(:extract)
      card.description = tds[9].try(:extract)
      card
    end.flatten.compact
  end

  # TODO: Implement a table parser which can recognize rowspan and colspan
  def parse_yukihi(rows, megami_code, megami_fullname)
    n1 = rows[0..1]
    n2 = rows[2..3]
    n3 = rows[4..5]
    n4 = rows[6]
    n5 = rows[7..8]
    n6 = rows[9..10]
    n7 = rows[11..12]
    s1 = rows[13..14]
    s2 = rows[15..16]
    s3 = rows[17]
    s4 = rows[18]

    single_group = [n4, s3, s4]
    multiple_group = [n1, n2, n3, n5, n6, n7, s1, s2]

    single = single_group.map do |node|
      tds = node.xpath('td')

      code = tds[0].try(:extract)
      raise 'no code' unless code

      next unless code =~ /.+?-\d+.*/

      card = Card.new
      card.megami_code = megami_code
      card.megami_name = megami_fullname.gsub(/\(.+?\)/, '').strip
      card.megami_fullname = megami_fullname
      card.code = code
      card.name = tds[1].try(:extract)
      card.main_type = tds[2].try(:extract)
      card.sub_type = tds[3].try(:extract)
      card.kasa = tds[4].try(:extract)
      card.range = tds[5].try(:extract)
      card.damage_aura = tds[6].try(:extract)
      card.damage_life = tds[7].try(:extract)
      card.osame = tds[8].try(:extract)
      card.cost = tds[9].try(:extract)
      card.description = tds[10].try(:extract)
      card
    end

    multiple = multiple_group.map do |multiple_rows|
      first_row = multiple_rows.first
      second_row = multiple_rows.last

      first_tds = first_row.xpath('td')
      second_tds = second_row.xpath('td')

      code = first_tds[0].try(:extract)
      raise 'no code' unless code

      first_card = Card.new
      second_card = Card.new

      [first_card, second_card].each do |card|
        card.megami_code = megami_code
        card.megami_name = megami_fullname.gsub(/\(.+?\)/, '').strip
        card.megami_fullname = megami_fullname
        card.code = code
      end

      second_col_cursor = 0

      first_card.name = first_tds[1].try(:extract)
      if first_tds[1].attributes['rowspan']
        second_card.name = first_card.name
      else
        second_card.name = second_tds[second_col_cursor].try(:extract)
        second_col_cursor += 1
      end

      first_card.main_type = first_tds[2].try(:extract)
      if first_tds[2].attributes['rowspan']
        second_card.main_type = first_card.main_type
      else
        second_card.main_type = second_tds[second_col_cursor].try(:extract)
        second_col_cursor += 1
      end

      first_card.sub_type = first_tds[3].try(:extract)
      if first_tds[3].attributes['rowspan']
        second_card.sub_type = first_card.sub_type
      else
        second_card.sub_type = second_tds[second_col_cursor].try(:extract)
        second_col_cursor += 1
      end

      first_card.kasa = first_tds[4].try(:extract)
      if first_tds[4].attributes['rowspan']
        second_card.kasa = first_card.kasa
      else
        second_card.kasa = second_tds[second_col_cursor].try(:extract)
        second_col_cursor += 1
      end

      first_card.range = first_tds[5].try(:extract)
      if first_tds[5].attributes['rowspan']
        second_card.range = first_card.range
      else
        second_card.range = second_tds[second_col_cursor].try(:extract)
        second_col_cursor += 1
      end

      first_card.damage_aura = first_tds[6].try(:extract)
      if first_tds[6].attributes['rowspan']
        second_card.damage_aura = first_card.damage_aura
      else
        second_card.damage_aura = second_tds[second_col_cursor].try(:extract)
        second_col_cursor += 1
      end

      first_card.damage_life = first_tds[7].try(:extract)
      if first_tds[7].attributes['rowspan']
        second_card.damage_life = first_card.damage_life
      else
        second_card.damage_life = second_tds[second_col_cursor].try(:extract)
        second_col_cursor += 1
      end

      first_card.osame = first_tds[8].try(:extract)
      if first_tds[8].attributes['rowspan']
        second_card.osame = first_card.osame
      else
        second_card.osame = second_tds[second_col_cursor].try(:extract)
        second_col_cursor += 1
      end

      first_card.cost = first_tds[9].try(:extract)
      if first_tds[9].attributes['rowspan']
        second_card.cost = first_card.cost
      else
        second_card.cost = second_tds[second_col_cursor].try(:extract)
        second_col_cursor += 1
      end

      first_card.description = first_tds[10].try(:extract)
      if first_tds[10].attributes['rowspan']
        second_card.description = first_card.description
      else
        second_card.description = second_tds[second_col_cursor].try(:extract)
        second_col_cursor += 1
      end

      [first_card, second_card]
    end

    [single, multiple].flatten.compact
  end

  task :sync, [:megami_code] => :environment do |task, args|
    begin
      megami_code = args[:megami_code]
      url = "https://www65.atwiki.jp/sakura-arms/pages/#{megami_code}.html"
      raise 'no url' unless url

      doc = Nokogiri::HTML.parse(open(url).read)
      megami_fullname = doc.xpath('id("pagetitle")').try(:extract)
      raise 'no megami_fullname' unless megami_fullname

      rows = doc.xpath('//table')[1].xpath('tr').drop(2)
      cards = megami_fullname.include?('ユキヒ') ? parse_yukihi(rows, megami_code, megami_fullname) : parse(rows, megami_code, megami_fullname)
      cards.each do |card|
        card.save!
        puts "#{megami_fullname},#{card.code}"
      end
    rescue => ex
      puts "Error: megami_code=#{megami_code},ex=#{ex.message},trace=#{ex.backtrace.join("\n")}"
    end
  end

  task :sync_all => :environment do |task, args|
    Card.truncate
    [13, 16, 17, 18, 20, 21, 38, 39, 40, 41, 42, 43, 44, 71, 79, 93, 95, 117, 118].each do |num|
      Rake::Task['wiki:sync'].execute(megami_code: num)
      sleep 1
    end
  end

  task :export => :environment do |task, args|
    File.binwrite('cards.json', Card.order(:megami_code, :code).all.to_json)
  end
end
