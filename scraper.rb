# This is a template for a Ruby scraper on Morph (https://morph.io)
# including some code snippets below that you should find helpful

# require 'scraperwiki'
# require 'mechanize'
#
# agent = Mechanize.new
#
# # Read in a page
# page = agent.get("http://foo.com")
#
# # Find somehing on the page using css selectors
# p page.at('div.content')
#
# # Write out to the sqlite database using scraperwiki library
# ScraperWiki.save_sqlite(["name"], {"name" => "susan", "occupation" => "software developer"})
#
# # An arbitrary query against the database
# ScraperWiki.select("* from data where 'name'='peter'")

# You don't have to do things with the Mechanize or ScraperWiki libraries. You can use whatever gems are installed
# on Morph for Ruby (https://github.com/openaustralia/morph-docker-ruby/blob/master/Gemfile) and all that matters
# is that your final data is written to an Sqlite database called data.sqlite in the current working directory which
# has at least a table called data.
require 'rubygems'
require 'httparty'
require 'open-uri'
require 'nokogiri'
require 'pp'
require 'sqlite3'
require 'htmlentities'


words = ['penta','pentagate']
words_search = words.join("+OR+")

p '+++'
p 'http://www.google.cl/search?q=allintitle:+'+words_search+'+site:.cl&lr=lang_es&cr=countryCL&biw=1366&bih=613&noj=1&tbs=qdr:d,lr:lang_1es,ctr:countryCL,sbd:1&source=lnt&sa=X&ei=4tKuVML3GouiNsbugLAP&ved=0CBMQpwU'
p '+++'
data = Nokogiri::HTML( open('http://www.google.cl/search?q=allintitle:+'+words_search+'+site:.cl&lr=lang_es&cr=countryCL&biw=1366&bih=613&noj=1&tbs=qdr:d,lr:lang_1es,ctr:countryCL,sbd:1&source=lnt&sa=X&ei=4tKuVML3GouiNsbugLAP&ved=0CBMQpwU') )
data.css('li.g').each do |article|
	puts '-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.'
	article.css('h3.r a').each do |link|
		#pp link['href']
		puts link.content
	end
	article.css('span.st').each do |content|
		puts '	' + content.content
	end
end

db = SQLite3::Database.new "data.sqlite"
db.execute <<-SQL

	DROP TABLE IF EXISTS data_searches;
SQL

db.execute <<-SQL

	CREATE TABLE data_searches (
		idx INTEGER PRIMARY KEY AUTOINCREMENT,
		url VARCHAR(512),
		title VARCHAR(256),
		content VARCHAR(256)
	);

SQL

coder = HTMLEntities.new

data.css('li.g').each do |article|
	article.css('h3.r a').each do |link|
		@data_link = link['href']
		@data_title_link = link.content
	end
	article.css('span.st').each do |content|
		@data_content = content.content.to_s
	end

	db.execute( 'INSERT INTO data_searches (url, title, content) VALUES (?,?,?)', @data_link, @data_title_link, @data_content )
end

db.execute( "select * from data_searches" ) do |row|
  p row
end
