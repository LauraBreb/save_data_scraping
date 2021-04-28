require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'pry'
require 'json'
require 'google_drive'
require 'csv'

class Scrapper
  
  def get_townhall_urls
    page = Nokogiri::HTML(URI.open("http://annuaire-des-mairies.com/val-d-oise.html"))   
    page.class
    href_array = Array.new
    url_array = Array.new
    href_array = page.xpath('//td[1]/p/a[@href] | //td[2]/p/a[@href] | //td[3]/p/a[@href]').map {|node| node["href"]}
    return url_array = href_array.map {|href| href.gsub("./", "http://annuaire-des-mairies.com/")}
  end

  def get_townhall_name
    page = Nokogiri::HTML(URI.open("http://annuaire-des-mairies.com/val-d-oise.html"))   
    page.class
    name_array = Array.new
    name_array = page.xpath('//td[1]/p/a[@href] | //td[2]/p/a[@href] | //td[3]/p/a[@href]').map {|node| node.text}
  end

  def get_townhall_email(townhall_url)
    page = Nokogiri::HTML(URI.open(townhall_url))    
    page.class
    townhall_email = page.xpath('//section[2]/div/table/tbody/tr[4]/td[2]').text
  end

  def gets_email_list
    email_list = Array.new
    url_array = get_townhall_urls
    name_array = get_townhall_name

    i = 0
    while url_array[i] != nil do
      email_list << Hash[name_array[i],get_townhall_email(url_array[i])]
      i +=1
    end

    email_list.to_a
  end

  def save_as_JSON(email_list)
     File.open("/Users/laurabreban/Desktop/THP2/JOUR3/save_data_scraping/db/emails.json","w") do |f|
      f.write(JSON.pretty_generate(email_list))
    end
  end

  def save_as_spreadsheet(email_list)
    session = GoogleDrive::Session.from_config("/Users/laurabreban/Desktop/THP2/JOUR3/config.json")
    ws = session.spreadsheet_by_key("19F8xUB5Ks2NsgfjALNG2OyX0hl1VqoajnLindjSsJsc").worksheets[0]
    ws[1, 1] = "Town"
    ws[1, 2] = "Email"

    i=2
    email_list.each do |hash|
      ws[i,1] = hash.keys.join()
      ws[i,2] = hash.values.join()
      i+= 1
    end
    ws.save
  end

  def save_as_CSV(email_list)
    CSV.open("/Users/laurabreban/Desktop/THP2/JOUR3/save_data_scraping/db/thing.csv","w") do |csv|
      csv << [:id, :town, :email]
      i = 1
      email_list.each do |hash|
        csv << [i, hash.keys.join(), hash.values.join()]
        i += 1
      end
    end
  end

  def perform
    email_list = gets_email_list
    save_as_JSON(email_list)
    save_as_spreadsheet(email_list)
    save_as_CSV(email_list)
  end

end