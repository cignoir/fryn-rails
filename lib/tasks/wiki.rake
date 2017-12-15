require 'open-uri'
require 'openssl'
OpenSSL::SSL.module_eval {remove_const(:VERIFY_PEER)}
OpenSSL::SSL.const_set(:VERIFY_PEER, OpenSSL::SSL::VERIFY_NONE)
require 'nokogiri'

namespace :wiki do
  class Nokogiri::XML::Element
    def extract
      self.try(:inner_text).try(:strip)
    end
  end

  task :sync, [:url] => :environment do |task, args|
    url = args[:url].strip
    raise 'no url' unless url

    doc = Nokogiri::HTML.parse(open(url).read)
    megami = doc.xpath('id("pagetitle")').try(:extract)
    raise 'no megami' unless megami

    doc.xpath('//table')[1].xpath('tr').drop(2).each do |node|
      tds = node.xpath('td')

      no = tds[0].try(:extract)
      raise "no no" unless no

      card = Card.where('url = ? and no = ?', url, no).first
      card = Card.new unless card
      card.megami = megami
      card.no = no
      card.name = tds[1].try(:extract)
      card.main_type = tds[2].try(:extract)
      card.sub_type = tds[3].try(:extract)
      card.range = tds[4].try(:extract)
      card.damage_aura = tds[5].try(:extract)
      card.damage_life = tds[6].try(:extract)
      card.osame = tds[7].try(:extract)
      card.cost = tds[8].try(:extract)
      card.description = tds[9].try(:extract)
      card.url = url
      card.save!
    end
  end

  task :sync_all => :environment do |task, args|
    [13, 16, 17, 18, 20, 21, 38, 39, 40, 41, 42, 43, 44, 71, 79, 93, 95, 117, 118].each do |page_num|
      Rake::Task['wiki:sync'].execute(url: "https://www65.atwiki.jp/sakura-arms/pages/#{page_num}.html")
    end
  end

  task :export => :environment do |task, args|
    File.binwrite('cards.json', Card.order(:megami, :no).all.to_json)
  end
end
