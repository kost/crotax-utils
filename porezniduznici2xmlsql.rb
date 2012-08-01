#!/usr/bin/env ruby
# Extract Croatian Tax data. Copright(C) 2012 Kost. Distributed under GNU GPL. 

require 'net/http'
require 'nokogiri'

fourl="http://duznici.porezna-uprava.hr/fo/svi/" # 1.html"
pourl="http://duznici.porezna-uprava.hr/po/svi/" # 1.html"
grurl="http://duznici.porezna-uprava.hr/gr/svi/" # 1.html"

def process (url,fnprefix)
	maxpag=1
	curr=0
	sqlf=File.open(fnprefix+".sql", 'w')
	csvf=File.open(fnprefix+".csv", 'w')
	begin
		curr=curr+1
		html=Net::HTTP.get(URI.parse(url+curr.to_s+".html"))
		html_doc=Nokogiri::HTML(html)
		
		# determine number of pages
		if curr==1 then
			maxstr=html_doc.at_xpath("/html/body/div/div/table/tr/td/div[@class='navBarLinks']/a[text()='>>']")
			maxpag=maxstr.attributes['href'].to_s.gsub(/.html$/,'').to_i
			$stderr.puts "Number of pages: "+maxpag.to_s

			# header for CSV files
			html_doc.xpath("/html/body/div/div/table[@class='dataTable']/tr[@class='tableHeader']/td").each_with_index {|hdr,index|
				csvf.print '"'+hdr.content+'"'
				if index < hdr.parent.element_children.length - 1 then
					csvf.print ";"
				end
			}
			csvf.puts
		end

		# data itself
		html_doc.xpath("/html/body/div/div/table[@class='dataTable']/tr[@class='evenRow' or @class='oddRow']").each {|row|
			sqlf.print "INSERT INTO "+fnprefix+" VALUES("
			columns=row.xpath("./td")
			columns.each_with_index {|col,index|
				cell=col.content.strip
				sqlf.print "'"+cell.gsub(/\'/,'')+"'" # poor man bad stuff prevention
				csvf.print '"'+cell.gsub(/\"/,'')+'"' # poor man bad stuff prevention
				if index < col.parent.element_children.length - 1 then
					sqlf.print ","
					csvf.print ";"
				end
			}
			csvf.puts
			sqlf.puts ");"
		}
	end while curr<maxpag

	sqlf.close()
	csvf.close()
end

$stderr.puts "Processing: "+pourl
process(pourl,"po")
$stderr.puts "Processing: "+fourl
process(fourl,"fo")
$stderr.puts "Processing: "+grurl
process(grurl,"gr")

$stderr.puts "Done. Look for .csv and .sql files in current dir"

