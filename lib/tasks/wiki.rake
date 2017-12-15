require 'open-uri'
require 'openssl'
OpenSSL::SSL.module_eval {remove_const(:VERIFY_PEER)}
OpenSSL::SSL.const_set(:VERIFY_PEER, OpenSSL::SSL::VERIFY_NONE)
require 'nokogiri'

namespace :wiki do
  task :sync, [:url] => :environment do |task, args|
    url = args[:url]
    raise 'no url' unless url

    doc = Nokogiri::HTML.parse(open(url).read)
    megami = doc.xpath('id("pagetitle")').inner_text.strip
    doc.xpath('//table')[1].xpath('tr').drop(2).each do |node|
      tds = node.xpath('td')

      no = tds[0].inner_text.strip
      raise unless no

      card = Card.where('url = ? and no = ?', url, no).first
      card = Card.new unless card
      card.megami = megami
      card.no = tds[0] ? tds[0].inner_text.strip : ''
      card.name = tds[1] ? tds[1].inner_text.strip : ''
      card.main_type = tds[2] ? tds[2].inner_text.strip : ''
      card.sub_type = tds[3] ? tds[3].inner_text.strip : ''
      card.range = tds[4] ? tds[4].inner_text.strip : ''
      card.damage_aura = tds[5] ? tds[5].inner_text.strip : ''
      card.damage_life = tds[6] ? tds[6].inner_text.strip : ''
      card.osame = tds[7] ? tds[7].inner_text.strip : ''
      card.cost = tds[8] ? tds[8].inner_text.strip : ''
      card.description = tds[9] ? tds[9].inner_text.strip : ''
      card.url = url.strip
      card.save!
    end
  end

  task :sync_all => :environment do |task, args|
    [13, 16, 17, 18, 20, 21, 38, 39, 40, 41, 42, 43, 44, 71, 79, 93, 95, 117, 118].each do |page_num|
      Rake::Task['wiki:sync'].execute(url: "https://www65.atwiki.jp/sakura-arms/pages/#{page_num}.html")
    end
  end

  task :export => :environment do |task, args|
    File.binwrite('cards.json', Card.order(:megami,:no).all.to_json)
  end
end
