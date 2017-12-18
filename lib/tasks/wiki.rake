require 'open-uri'
require 'openssl'
require 'nokogiri'
require 'tsukue'
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
    rows.map do |row|
      code = row[0].text
      raise 'no code' unless code

      next unless code =~ /.+?-\d+.*/

      card = Card.new
      card.megami_code = megami_code
      card.megami_name = megami_fullname.gsub(/\(.+?\)/, '').strip
      card.megami_fullname = megami_fullname
      card.code = code
      card.name = row[1].text
      card.main_type = row[2].text
      card.sub_type = row[3].text
      card.kasa = '-'
      card.range = row[4].text
      card.damage_aura = row[5].text
      card.damage_life = row[6].text
      card.osame = row[7].text
      card.cost = row[8].text
      card.description = row[9].text
      card
    end.flatten.compact
  end

  def parse_yukihi(rows, megami_code, megami_fullname)
    rows.map do |row|
      code = row[0].text
      raise 'no code' unless code

      next unless code =~ /.+?-\d+.*/

      card = Card.new
      card.megami_code = megami_code
      card.megami_name = megami_fullname.gsub(/\(.+?\)/, '').strip
      card.megami_fullname = megami_fullname
      card.code = code
      card.name = row[1].text
      card.main_type = row[2].text
      card.sub_type = row[3].text
      card.kasa = row[4].text
      card.range = row[5].text
      card.damage_aura = row[6].text
      card.damage_life = row[7].text
      card.osame = row[8].text
      card.cost = row[9].text
      card.description = row[10].text
      card
    end.flatten.compact
  end

  task :sync, [:megami_code] => :environment do |task, args|
    begin
      megami_code = args[:megami_code]
      url = "https://www65.atwiki.jp/sakura-arms/pages/#{megami_code}.html"
      raise 'no url' unless url

      doc = Nokogiri::HTML.parse(open(url).read)
      megami_fullname = doc.xpath('id("pagetitle")').try(:extract)
      raise 'no megami_fullname' unless megami_fullname

      table = Tsukue::Table.new(doc, 'id("wikibody")/table', {header: false, dup_rows: true, dup_cols: true})
      rows = table.rows.drop(2)
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
    File.binwrite('cards.json', Card.order(:megami_code, :code).all.reject{ |card| card.megami_fullname.include?('一幕') }.to_json)
  end
end
